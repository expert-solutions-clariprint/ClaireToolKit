
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * moedl.cl                                                          *
// * Copyright (C) 2000 - 2004 xl. All Rights Reserved                 *
// *********************************************************************


// *********************************************************************
// * 1 - model                                                         *
// *********************************************************************


		
png_chunk <: ephemeral_object(
				length:integer,
				name:string,
				data:string,
				crc:string)

png <: ephemeral_object(chunks:list[png_chunk])

self_print(self:png_chunk) : void ->
	printf("<~A:~S>", self.name, self.length)


// *********************************************************************
// * 2 - crc                                                           *
// *********************************************************************


crc!(self:png_chunk) : string ->
	let res := make_string(4)
	in (externC("
		unsigned long crc_table[256];
        unsigned long c;
		unsigned char *buf;
		int len = length_string(self->data);
        int n, k;
        for (n = 0; n < 256; n++) {
          c = (unsigned long) n;
          for (k = 0; k < 8; k++) {
            if (c & 1)
              c = 0xedb88320L ^ (c >> 1);
            else
              c = c >> 1;
          }
          crc_table[n] = c;
        }
        c = 0xffffffffL;
        buf = (unsigned char *)self->name;
        for (n = 0; n < 4; n++)
          c = crc_table[(c ^ buf[n]) & 0xff] ^ (c >> 8);
        buf = (unsigned char *)self->data;
		for (n = 0; n < len; n++)
          c = crc_table[(c ^ buf[n]) & 0xff] ^ (c >> 8);
		c = c ^ 0xffffffffL;
		res[0] = (unsigned char)((c & 0xFF000000) >> 24);
		res[1] = (unsigned char)((c & 0x00FF0000) >> 16);
		res[2] = (unsigned char)((c & 0x0000FF00) >> 8);
		res[3] = (unsigned char)((c & 0x000000FF))"), res)


// *********************************************************************
// * 2 - load/save                                                     *
// *********************************************************************


read_chunk_length(f:port) : integer ->
	let ii := fread(f, 4)
	in (externC("unsigned char* i = (unsigned char*)ii"),
		externC("((((unsigned)i[0]) << 24) |
					(((unsigned)i[1]) << 16) |
					(((unsigned)i[2]) << 8) |
					(((unsigned)i[3])))", integer))


load_png(self:string) : png ->
	let f := fopen(self, "r"),
		im := png(),
		ok? := true
	in (if (fread(f, 8) != "\211PNG\r\n\032\\n")
			error("Bad PNG header on file ~A", self),
		while ok?
			let c := png_chunk()
			in (c.length := read_chunk_length(f),
				c.name := fread(f, 4),
				c.data := fread(f, c.length),
				c.crc := fread(f, 4),
				im.chunks :add c,
				if (c.crc != crc!(c))
					error("corrupted PNG file ~A (invalid check sum of chunk ~A)",
								self, c.name),
				if (c.name = "IEND") ok? := false),
		im)

write_chunk(c:png_chunk, f:port) : void ->
	(externC("f->puts((char*)&c->length, 4)"),
	fwrite(c.name, f),
	fwrite(c.data, f),
	fwrite(crc!(c), f))

save_png(im:png, self:string) : void ->
	let f := fopen(self, "w")
	in (fwrite("\211PNG\r\n\032\\n", f),
		for c in im.chunks
			write_chunk(c, f),
		fclose(f))


// *********************************************************************
// * 3 - palette                                                       *
// *********************************************************************


//<sb> get the palette of src and set it to dst
replace_palette(dst:png, src:png) : void ->
	(when c := some(c in src.chunks | c.name = "PLTE")
	in when d := some(d in dst.chunks | d.name = "PLTE")
	in (d.length := c.length,
		d.data := c.data,
		d.crc := c.crc))


//<sb> get ith color from the palette (if any)
palette_color_count(self:png) : integer ->
	let plt:png_chunk := some(c in self.chunks | c.name = "PLTE")
	in (if unknown?(plt) error("Sorry, the PNG doesn't have palette"),
		plt.length / 3)
	

//<sb> get ith color from the palette (if any)
nth(self:png, i:integer) : tuple(integer, integer, integer) ->
	let plt:png_chunk := some(c in self.chunks | c.name = "PLTE")
	in (if unknown?(plt) error("Sorry, the PNG doesn't have palette"),
		let offset := 3 * (i - 1)
		in (if (offset + 2 >= plt.length)
				error("nth @ png, out of bound color index ~S for PNG palette", i),
			let d := plt.data,
				r := externC("(int)((unsigned char)d[offset])", integer),
				g := externC("(int)((unsigned char)d[offset+1])", integer),
				b := externC("(int)((unsigned char)d[offset+2])", integer)
			in tuple(r, g, b)))

//<sb> set ith color in the palette (if any)
nth=(self:png, i:integer, col:tuple(integer, integer, integer)) : void ->
	let plt:png_chunk := some(c in self.chunks | c.name = "PLTE")
	in (if unknown?(plt) error("Sorry, the PNG doesn't have palette"),
		let offset := 3 * (i - 1)
		in (if (offset + 2 >= plt.length)
				error("nth= @ png, out of bound color index ~S for PNG palette", i),
			let d := plt.data,
				r := col[1],
				g := col[2],
				b := col[3]
			in (externC("d[offset] = (unsigned char)r"),
				externC("d[offset+1] = (unsigned char)g"),
				externC("d[offset+2] = (unsigned char)b"))))


