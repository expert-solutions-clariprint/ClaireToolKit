
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * png.cl                                                            *
// * Copyright (C) 2000 - 2004 xl. All Rights Reserved                 *
// *********************************************************************

// *********************************************************************
// *   Part 1: png tools                                               *
// *   Part 2: png api                                                 *
// *********************************************************************


// *********************************************************************
// *   Part 1: png tools                                               *
// *********************************************************************

[ord(self:char) : integer ->
	let n := integer!(self)
	in (if (n < 0) n := -(n),
		if (n > 255) n - 256
		else n)]


[getbytes(data:string, pos:integer, num:integer) : integer ->
	let ret := 0, i := 0
	in (while (i < num)
			(ret :* 256,
			ret :+ ord(data[pos + i]),
			i :+ 1), ret)]


// @doc Images
[png_image_size(self:string) : tuple(float,float) ->
	let fp := fopen(self,"r"),
		header := "\211PNG\r\n\032\\n",
		data := fread(fp, 256),
		width := 0.0,
		height := 0.0
	in (fclose(fp),
		if (substring(data, 1, 8) != header)
      		error("The file ~A does not have a valid PNG header", self),
		let chunkLen := getbytes(data, 9, 4),
      		chunkType := substring(data, 13, 16)
      	in (if (chunkType = "IHDR")
      			(width := float!(getbytes(data, 17, 4)),
			  	height := float!(getbytes(data, 21, 4))),
			tuple(width,height)))]

// *********************************************************************
// *   Part 2: png api                                                 *
// *********************************************************************

DOC_IMAGES[self:pdf_document, src:string] : (pdf_image U {unknown}) := unknown

[load_png(self:pdf_document, f:string) : pdf_image ->
	f := realpath(f),
	if (isfile?(f /+ "8")) load_png(self, (f /+ "8"))
	else when png := DOC_IMAGES[self, f]
		in (use_resource(png),
			png)
		else let fp := fopen(f,"r"),
				png := load_png(self, fp)
				in (fclose(fp),
					DOC_IMAGES[self, f] := png,
				png)]

[load_png(self:pdf_document, fp:port) : pdf_png ->
	//[-100] load_jpg(),
	let png := pdf_png(doc = self),
		header := "\211PNG\r\n\032\\n",
		data := "", idata := "", pdata := "",
		p := 9, len := 0,
		haveHeader? := false,
		transparency? := false
	in (while not(eof?(fp)) data :/+ fread(fp,1024),
		if (substring(data,1,8) != header)
			error("The port ~S does not have a valid PNG header", fp),
		len := length(data),
		self.current_image_id :+ 1,
		png.imid := self.current_image_id,
		while (p < len)
			let chunkLen := getbytes(data, p, 4)
			in (case substring(data,p + 4, p + 7) // chunk type
					({"IHDR"} // this is where all the file information comes from
						(png.imwidth := float!(getbytes(data, p + 8, 4)),
						png.imheight := float!(getbytes(data, p + 12, 4)),
						png.bitdepth := ord(data[p + 16]),
						png.colortype := ord(data[p + 17]),
						png.m_compression := ord(data[p + 18]),
						png.m_filter := ord(data[p + 19]),
						png.m_interlaced := ord(data[p + 20]),
						haveHeader? := true,
						if (png.m_compression != 0)
							error("unknown compression method for PNG file ~S", fp),
						if (png.m_filter != 0)
							error("unsupported filter method for PNG file ~S", fp)),

					{"PLTE"} pdata :/+ substring(data, p + 8, p + 7 + chunkLen),

					{"IDAT"} idata :/+ substring(data, p + 8, p + 7 + chunkLen),

					{"tRNS"} //this chunk can only occur once and it must occur after the PLTE chunk and before IDAT chunk 
						(transparency? := true,
						case png.colortype
							// indexed color, rbg 	
							// corresponding to entries in the plte chunk 
							//  Alpha for palette index 0: 1 byte 
							//  Alpha for palette index 1: 1 byte 
							//  etc... 
							// there will be one entry for each palette entry. up until the last non-opaque entry.
							// set up an array, stretching over all palette entries which will be o (opaque) or 1 (transparent)
							({3} let trans := 0, i := chunkLen
								in (png.t_type := "indexed",
									while (i >= 0)
										(if (ord(data[p + 8 + i]) = 0) trans := i,
										i :- 1),
									png.t_data := trans),
						
							// grayscale 
							// corresponding to entries in the plte chunk 
							//  Gray: 2 bytes, range 0 .. (2 ^ bitdepth) - 1 
							{0} (png.t_type := "indexed",
								png.t_data := ord(data[p + 9])),

							// truecolor 
							// corresponding to entries in the plte chunk 
							//  Red: 2 bytes, range 0 .. (2 ^ bitdepth) - 1 
							//  Green: 2 bytes, range 0 .. (2 ^ bitdepth) - 1 
							//  Blue: 2 bytes, range 0 .. (2 ^ bitdepth) - 1 
							{2} (png.t_r := getbytes(data,p + 8,2), // r from truecolor 
								png.t_g := getbytes(data,p + 10,2), // g from truecolor 
								png.t_b := getbytes(data,p + 12,2)), // b from truecolor 
							any
								//unsupported transparency type 
								error("unsupported transparency type for PNG file ~S", fp)))),
				p :+ chunkLen + 12),
		if not(haveHeader?)
			error("Information header is missing for PNG file ~S", fp),
		if (known?(m_interlaced, png) & png.m_interlaced > 0)
			error("There appears to be no support for interlaced images in pdf for PNG file ~S", fp),
		if (png.bitdepth > 8)
			error("Only bit depth of 8 or less is supported for PNG file ~S", fp),
		if not(png.colortype % {0,2,3})
			error("Transparancey alpha channel not supported, transparency only supported for palette images for PNG file ~S", fp),
		let cs := pdf_image_colorspace(doc = self, spdata = pdata)
		in (case png.colortype
				({3} (cs.space := "DeviceRGB", png.ncolor := 1),
				{2} (cs.space := "DeviceRGB", png.ncolor := 3),
				{0} (cs.space := "DeviceGray", png.ncolor := 1)),
			png.pngdata := idata,
			png.colorspace := cs),
		use_resource(png),
		png)]
	

[show_image(self:pdf_image, x:float, y:float, w:float, h:float) : void ->
	if (w = 0.0) w := h / self.imheight * self.imwidth,
	if (h = 0.0) h := w * self.imheight / self.imwidth,
	self.doc.current_content.operations :add
		pdf_image_show(ref_doc = self.doc, im = self, imx = x, imy = y, imwidth = w, imheight = h)]

[show_image(self:pdf_image, x:float, y:float) : void =>
	show_image(self, x, y, self.imwidth, self.imheight)]

[show_image(self:pdf_image, r:rectangle) : void =>
	self.doc.current_content.operations :add
		pdf_image_show(ref_doc = self.doc, im = self, imx = r.left, imy = r.bottom, imwidth = width(r), imheight = height(r))]


[normalize(self:pdf_image, w:float, h:float) : tuple(float, float) ->
	let WoverH := self.imwidth / self.imheight,
		woverh := w / h,
		f := WoverH / woverh
	in (if (f > 1.)
			tuple(w, h / f)
		else tuple(w * f, h))]


// *********************************************************************
// *   Part 2: jpg api                                                 *
// *********************************************************************

[load_jpg(self:pdf_document, f:string) : pdf_image ->
	f := realpath(f),
	if (isfile?(f /+ "8")) load_jpg(self, (f /+ "8"))
	else when png := DOC_IMAGES[self, f]
		in (use_resource(png),
			png)
		else let fp := fopen(f,"r"),
				png := load_jpg(self, fp)
				in (fclose(fp),
					DOC_IMAGES[self, f] := png,
				png)]

/*

function jpegProps(data) {          // data is an array of bytes
    var off = 0;
    while(off<data.length) {
        while(data[off]==0xff) off++;
        var mrkr = data[off];  off++;
        
        if(mrkr==0xd8) continue;    // SOI
        if(mrkr==0xd9) break;       // EOI
        if(0xd0<=mrkr && mrkr<=0xd7) continue;
        if(mrkr==0x01) continue;    // TEM
        
        var len = (data[off]<<8) | data[off+1];  off+=2;  
        
        if(mrkr==0xc0) return {
            bpc : data[off],     // precission (bits per channel)
            h   : (data[off+1]<<8) | data[off+2],
            w   : (data[off+3]<<8) | data[off+4],
            cps : data[off+5]    // number of color components
        }
        off+=len-2;
    }
}
*/
//
[jpegProps(fp:blob) : (tuple U {unknown})
-> //[-100] jpegProps(),
	set_index(fp,0),
	let res:(tuple U {unknown}) := unknown	 
	in (while not(eof?(fp)) 
		let mrkr := integer!(getc(fp))
		in (while (mrkr = \xFF & not(eof?(fp))) mrkr := integer!(getc(fp)),
			// mrkr := integer!(getc(fp)),
			//[-100] ~S // mrkr,
			
			if (mrkr = \xd8) (//[-100] mrkr = \\xd8,
								getc(fp))					// SOI
			else if (mrkr = \xd9) (//[-100] mrkr = \\xd9,
									getc(fp),break())	// EOI
			else if (\xd0 <= mrkr & mrkr <= \xd7) (//[-100] mrkr % (\\xd0 .. \\xd7),
									getc(fp))
			else if (mrkr = \x01) (//[-100] mrkr = \\x01,
									getc(fp))			// TEM
			else let len := (integer!(getc(fp)) << 8 + integer!(getc(fp)))
				in (//[-100] len = ~S // len,
					if (mrkr = \xc0) 
						(res := tuple(
								integer!(getc(fp)),	// precission (bits per channel)
								integer!(getc(fp)) << 8 + integer!(getc(fp)),	// h
								integer!(getc(fp)) << 8 + integer!(getc(fp)),	// w
								integer!(getc(fp)) // number of color components
							),
						//[-100] mrkr = \\xc0 => res:~S // res,
						break())
					else (//[-100] skip(~S) // len - 2,
							fskip(fp,len - 2))
				)),
		set_index(fp,0),
		res)]

//
[load_jpg(self:pdf_document, fp:port) : pdf_jpg ->
	//[-100] load_jpg(),
	let fb := (if (fp % blob) fp else blob!(fp)) in 
	when jpgProps := jpegProps(fb)
	in let (ncol,h,w,bpc) := jpgProps in 
		let jpg:pdf_jpg := pdf_jpg(doc = self, imwidth = float!(w), imheight = float!(h), bitdepth = bpc, colortype = ncol, ncolor = 3)
	in (
		self.current_image_id :+ 1,
		jpg.imid := self.current_image_id,
	
		if not(jpg.colortype % {0,2,3})
			error("Transparancey alpha channel not supported, transparency only supported for palette images for jpg file ~S", fp),
		let cs := pdf_image_colorspace(doc = self, space = "DeviceRGB")
		in (case jpg.colortype
				({3} (cs.space := "DeviceRGB", jpg.ncolor := 1),
				{2} (cs.space := "DeviceRGB", jpg.ncolor := 3),
				{0} (cs.space := "DeviceGray", jpg.ncolor := 1)),
			jpg.jpgdata := fb,
			jpg.colorspace := cs),
		use_resource(jpg),
		jpg)
	else (	error("Unable to extract jpg properties from jpg file ~S",fp),
			pdf_jpg())]

[load_pngUjpg(self:pdf_document, fp:port) : (pdf_jpg U pdf_png)
-> try load_png(self,fp) 
	catch any (//[-100] try load_png ... catch (~S) // exception!(),
				load_jpg(self,fp))]

[load_pngUjpg(self:pdf_document, f:string) : pdf_image ->
	f := realpath(f),
	if (isfile?(f /+ "8")) load_pngUjpg(self, (f /+ "8"))
	else when png := DOC_IMAGES[self, f]
		in (use_resource(png),
			png)
		else let fp := fopen(f,"r"),
				png := load_pngUjpg(self, fp)
				in (fclose(fp),
					DOC_IMAGES[self, f] := png,
				png)]
