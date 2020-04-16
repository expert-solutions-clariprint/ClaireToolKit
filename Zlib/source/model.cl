//*********************************************************************
//* Zlib                                              Sylvain Benilan *
//* model.cl                                                          *
//* Copyright (C) 2005 xl. All Rights Reserved                        *
//*********************************************************************

// @presentation
// The Zlib module is a wrapper for the popular zlib library. It provides
// two filters that handles compression and decompression for the deflate
// and gzip formats.
// @presentation

// @cat Compression filters
// This module implements compression algorithm as decribed by RFC 1951
// (deflate format) and RFC 1950 (gzip format). This module relies on the
// popular zlib library. This implementation defines two kind of filter :
// \code
// Zlib/deflater <: filter
// Zlib/gziper <: Zlib/deflater
// \/code
// That are respectively instanciated by deflater! @ port and gziper! @ port.
// As an exemple we could write a fopen like method that handles compressed
// files :
// \code
// gzopen(f:string, mode:{"r", "w"}) : gziper ->
// 	let f := fopen(f, mode)
// 	in close_target!(Zlib/gziper!(f))
// \/code
// Then we would write a compression method that take the name of an input file
// and the name of a target compressed file as follow :
// \code
// compress_file(fin:string, fout:string) : void ->
// 	let f := fopen(fin, "r"),
// 		gz := gzopen(fout, "w")
// 	in (freadwrite(f, gz),
// 		fclose(f),
// 		fclose(gz))
// \/code
// @cat

// ********************************************************************
// * part 1: model                                                    *
// ********************************************************************


// @doc Compression filters
// zlibversion() return the version of the underlying zlib library.
zlibversion() : string -> externC("(char*)zlibVersion()", string)


z_stream* <: import()
(c_interface(z_stream*, "z_stream*"))

unsigned_long* <: import()
(c_interface(unsigned_long*, "unsigned long*"))

deflater <: filter(ratio:integer = 0,
					eof_reached?:boolean = false,
					data:char*,
					datalen:integer = 0,
					aborted?:boolean = false,
					crc:unsigned_long*,
					skip_crc?:boolean = true,
					zin:z_stream*,
					in_init?:boolean = false,
					zout:z_stream*,
					out_init?:boolean = false,
					data_written?:boolean = false)

	gziper <: deflater(read_gzip_header?:boolean = true,
						write_gzip_header?:boolean = true)


// ********************************************************************
// * part 2: error handling                                           *
// ********************************************************************

zlib_error <: error(src:deflater, msg:string, from:string)

zlib_error!(p:deflater,f:string, m:string) : void ->
	zlib_error(src = p, from = f, msg = m)

self_print(self:zlib_error) : void ->
	printf("**** Zlib (~A) error on ~S:\n~A~I~I",
			zlibversion(),
			self.src,
			self.from,
			(if (length(self.msg) > 0)
				printf(": ~A", self.msg)),
			(if (self.src.datalen > 0)
				printf("\ncurrent data to inflate : ~S", string!(self.src.data, self.src.datalen))))


private/check_zlib_rc(p:deflater, rc:integer, from:string) : void ->
	(if externC("(rc == Z_BUF_ERROR ? CTRUE : CFALSE)", boolean)
		zlib_error!(p, from, "output buffer too small")
	else if externC("(rc == Z_STREAM_ERROR ? CTRUE : CFALSE)", boolean)
		zlib_error!(p, from, "inconsistent state of zlib internal structure")
	else if externC("(rc == Z_MEM_ERROR ? CTRUE : CFALSE)", boolean)
		zlib_error!(p, from, "memory overflow")
	else if externC("(rc == Z_DATA_ERROR ? CTRUE : CFALSE)", boolean)
		zlib_error!(p, from, "corrupted input data"))


// ********************************************************************
// * part 3: zstream allocation                                       *
// ********************************************************************


//<sb> perform C allocation for zlib internal structures
init_z_port(self:port, z:deflater, gzip?:boolean, level:integer) : type[z] ->
	(externC("z->zin = (z_stream*)malloc(sizeof(z_stream))"),
	externC("z->data = (char*)malloc(256)"),
	externC("z->zin->zalloc = Z_NULL; z->zin->zfree = Z_NULL; z->zin->next_in = Z_NULL; z->zin->avail_in = 0"),
	externC("z->zout = (z_stream*)malloc(sizeof(z_stream))"),
	externC("z->zout->zalloc = Z_NULL; z->zout->zfree = Z_NULL; z->zout->next_in = Z_NULL; z->zout->avail_in = 0"),
	externC("z->crc = (unsigned long*)malloc(sizeof(unsigned long)); *z->crc = 0;"),
	if externC("((z->data == NULL || z->zin == NULL || z->zout == NULL || z->crc == NULL) ? CTRUE : CFALSE)", boolean)
		(fclose(z),
		error("Failed to allocate external memory for a zlib filter on ~S", self)),
	if externC("(inflateInit2(z->zin, gzip_ask == CTRUE ? -15 : 15) == Z_OK ? CFALSE : CTRUE)", boolean)
		(fclose(z),
		error("Failed to initialize zlib input structure on ~S", self)),
	z.in_init? := true,
	if externC("(deflateInit2(z->zout,level,Z_DEFLATED,gzip_ask == CTRUE ? -15 : 15, 9, Z_DEFAULT_STRATEGY) == Z_OK ? CFALSE : CTRUE)", boolean)
		(fclose(z),
		error("Failed to initialize zlib output structure on ~S", self)),
	externC("z->zin->next_out = (Bytef*)z->data"),
	z.out_init? := true,
	filter!(z, self))

//<sb> free the associated zlib resource
close_port(self:deflater) : void ->
	(if not(self.aborted?)
		finish(self),
	if (self.out_init? & not(self.aborted?))
		(self.ratio :=
			externC("(self->zout == NULL ? 0 :
						(self->zout->total_in == 0 ? 0 :
							100 * self->zout->total_out / self->zout->total_in))", integer),
		case self (gziper add_footer(self)),
		externC("deflateEnd(self->zout)")),
	if self.in_init?
		externC("deflateEnd(self->zin)"),
	externC("if (self->zin) free(self->zin)"),
	externC("if (self->data) free(self->data)"),
	externC("if (self->zout) free(self->zout)"),
	externC("if (self->crc) free(self->crc)"))

//<sb> for a zlib stream we add a footer with the CRC check sum
// and the length of the message
add_footer(self:gziper) : void ->
	(if self.data_written?
		(externC("char buf[8]"),
		externC("unsigned long x = *self->crc"),
		externC("buf[0] = (unsigned char)(x & 0xff)"),
		externC("buf[1] = (unsigned char)((x & 0xff00) >> 8)"),
		externC("buf[2] = (unsigned char)((x & 0xff0000) >> 16)"),
		externC("buf[3] = (unsigned char)((x & 0xff000000) >> 24)"),
		externC("x = self->zout->total_in"),
		externC("buf[4] = (unsigned char)(x & 0xff)"),
		externC("buf[5] = (unsigned char)((x & 0xff00) >> 8)"),
		externC("buf[6] = (unsigned char)((x & 0xff0000) >> 16)"),
		externC("buf[7] = (unsigned char)((x & 0xff000000) >> 24)"),
		write_port(self.target, externC("buf", char*), 8)))


// ********************************************************************
// * part 3: deflate filter                                           *
// ********************************************************************


// @doc Compression filters
// deflater!(self) is equivalent to deflater!(self, 6)
deflater!(self:port) : deflater -> deflater!(self, 6)

// @doc Compression filters
// deflater!(self, compression_level) creates a new deflate filter
// on the port self. compression_level is an integer in the range (0 .. 9)
// and drives the compression strategy :
// \ul
// \li 1 gives best speed,
// \li 9 gives best compression,
// \li 0 gives no compression at all (the input data is simply copied a block at a time)
// \/ul
deflater!(self:port, compression_level:(0 .. 9)) : deflater ->
	init_z_port(self, deflater(), false, compression_level)

eof_port?(self:deflater) : boolean -> self.eof_reached?

[read_port(self:deflater, buf:char*, len:integer) : integer ->
	case self
		(gziper
			(//<sb> first, read the gzip header
			if self.read_gzip_header?
				(if (fskip(self.target, 10) != 10)
					error("Premature eof on ~S while reading gzip header", self),
				self.read_gzip_header? := false))),
	let rc := 0
	in (externC("z_stream *i = self->zin"),
		externC("i->next_out = (Bytef*)buf; i->avail_out = len"),
		while (not(self.eof_reached?) & externC("(i->avail_out > 0 ? CTRUE : CFALSE)", boolean))
			(externC("int before = i->avail_out"),
			if externC("(i->avail_in == 0 ? CTRUE : CFALSE)", boolean)
				(//<sb> fill in internal data to inflate
				if eof_port?(self.target)
					error("Premautre eof of compressed stream ~S", self),
				let nread := read_port(self.target, self.data, 256)
				in (self.datalen := nread,
					externC("i->next_in = (Bytef*)self->data"),
					externC("i->avail_in = nread"))),
			rc := externC("inflate(i, Z_NO_FLUSH)", integer),
			if (rc != externC("Z_OK",integer))
				check_zlib_rc(self, rc, "read_port @ deflater"),
			if externC("(rc == Z_STREAM_END ? CTRUE : CFALSE)", boolean)
				self.eof_reached? := true),
		externC("(len - i->avail_out)", integer))]


[write_port(self:deflater, buf:char*, len:integer) : integer ->
	case self
		(gziper
			(if self.write_gzip_header?
				(externC("char head[10] = {'\\037', '\\213', 8, 0, 0, 0, 0, 0, 0, 3}"),
				if not(Core/unix?()) externC("head[9] = 0x0b"),
				write_port(self.target, externC("head", char*), 10),
				self.write_gzip_header? := false),
			//<sb> update CRC
			externC("*self->crc = crc32(*self->crc, (const Bytef *)buf, len)"))),
	let m := 0, rc := 0, mm := 0
	in (externC("
			char obuf[1024];
			z_stream *o = self->zout;
			o->next_in = (Bytef*)buf;
			o->avail_in = len;"),
		while externC("(o->avail_in > 0 ? CTRUE : CFALSE)", boolean)
			(self.data_written? := true,
			externC("o->next_out = (Bytef*)obuf; o->avail_out = 1024"),
			rc := externC("deflate(o, Z_NO_FLUSH)", integer),
			if not(externC("(o->avail_out == 0 && rc == Z_BUF_ERROR ? CTRUE : CFALSE)", boolean))
				check_zlib_rc(self, rc, "write_port @ deflater"),
			externC("m = 1024 - o->avail_out"),
			if (m > 0) write_port(self.target, externC("obuf", char*), m),
			if externC("((rc != Z_STREAM_END && o->avail_out == 0) ? CFALSE : CTRUE)", boolean)
				break()),
		len)]

[full_flush(self:deflater) : void ->
	if not(self.data_written?)
		error("Incorrect use of full_flush on ~S that has not been written yet", self),
	let rc := 0, m := 0
	in (externC("
			char obuf[1024];
			z_stream *o = self->zout;
			o->next_in = (Bytef*)0;
			o->avail_in = 0;"),
		while true
			(externC("o->next_out = (Bytef*)obuf; o->avail_out = 1024"),
			rc := externC("deflate(o, Z_FULL_FLUSH)", integer),
			if not(externC("(o->avail_out == 0 && rc == Z_BUF_ERROR ? CTRUE : CFALSE)", boolean))
				check_zlib_rc(self, rc, "full_flush @ deflater"),
			externC("m = 1024 - o->avail_out"),
			if (m > 0) write_port(self.target, externC("obuf", char*), m),
			if externC("((rc != Z_STREAM_END && o->avail_out == 0) ? CFALSE : CTRUE)", boolean)
				break()))]

[finish(self:deflater) : void ->
	let m := 0, rc := 0
	in (externC("
			char obuf[1024];
			z_stream *o = self->zout;
			o->next_in = NULL;
			o->avail_in = 0;"),
		if self.data_written?
			while true
				(externC("o->next_out = (Bytef*)obuf; o->avail_out = 1024"),
				rc := externC("deflate(o, Z_FINISH)", integer),
				check_zlib_rc(self, rc, "write_port @ deflater"),
				externC("m = 1024 - o->avail_out"),
				if (m > 0) write_port(self.target, externC("obuf", char*), m),
				if externC("((rc != Z_STREAM_END && o->avail_out == 0) ? CFALSE : CTRUE)", boolean)
					break()))]
	

// ********************************************************************
// * part 3: gzip filter                                              *
// ********************************************************************


// @doc Compression filters
// gziper!(self) is equivalent to gziper!(self, 6).
gziper!(self:port) : gziper -> gziper!(self, 6)

// @doc Compression filters
// gziper!(self, compression_level) is similar to deflater!(self, compression_level)
// concerning the compression algorithm (gziper derive from deflater) but also adds a
// gzip specific header to the head of the compressed stream and a CRC check sum to the
// tail of stream (at close time).
gziper!(self:port, compression_level:(0 .. 9)) : gziper ->
	init_z_port(self, gziper(), true, compression_level)
	
