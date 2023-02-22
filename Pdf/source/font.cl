
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * font.cl                                                           *
// * Copyright (C) 2000 - 2004 xl. All Rights Reserved                 *
// *********************************************************************


// *********************************************************************
// *   Part 1: font descriptor (afm)                                   *
// *   Part 2: pdf font / font descriptor mapping                      *
// *   Part 3: text metrics                                            *
// *********************************************************************


// *********************************************************************
// *   Part 1: font descriptor (afm)                                   *
// *********************************************************************

// @cat afm
// In order to properly handle text object we need font metrics information,
// this information is use the calculate the dimension of a text object as
// the computation of the sum of glyph dimension.
// Pdf support handling of AFM (Adobe Font Metrics) file format. The Pdf
// module distribution comes with default AFM files for default PDF fonts
// those that are supposed to be handled by any reader application. The Pdf
// module has to be informed where to find AFM files in order to properly
// load a font metrics description :
// \code
// (Pdf/set_afm_path("/path/to/AFM/files/folder"))
// \/code
// For each loaded AFM file, Pdf will attempt to created a cached version
// of the file in order to make AFM loading faster the next time. The cached
// version is made using the serialize facility.
// So we would also specify a folder where serialized files are saved :
// \code
// (Pdf/set_serialized_afm_path("/path/to/serialized/AFM/files/folder"))
// \/code
// Notice that if set_afm_path or set_serialized_afm_path are omitted then the
// font repository is assumed to be "fonts".
// @cat

FONT_FORMAT_VERSION:string := "V3"

font_descriptor <: ephemeral_object(
		format_version:string = FONT_FORMAT_VERSION,
		fontface:string,
		italic?:boolean,
		bold?:boolean,
		FontName:string = "",
		FullName:string = "",
		FamilyName:string = "",
		Weight:string = "",
		ItalicAngle:float = 0.0,
		IsFixedPitch:boolean,
		CharacterSet:string = "",
		FontBBox:tuple(float,float,float,float),
		UnderlinePosition:float = 0.0,
		UnderlineThickness:float = 0.0,
		EncodingScheme:string,
		CapHeight:float = 0.0,
		XHeight:float = 0.0,
		Ascender:float = 0.0,
		Descender:float = 0.0,
		StdHW:float = 0.0,
		StdVW:float = 0.0,
		maxc:float = 0.0,
		C:array<any>,
		C-1:table)

NORM :: 0
BOLD :: 1
ITALIC :: 2
BOLD_ITALIC :: 3

AFM_PATH:string := "fonts"
SERIALIZED_AFM_PATH:string := "fonts"

// @doc font
[set_afm_path(self:string) : void -> AFM_PATH := self]
// @doc font
[set_serialized_afm_path(self:string) : void -> SERIALIZED_AFM_PATH := self]

FONTS[fontname:string, bi:{NORM,BOLD,ITALIC,BOLD_ITALIC}] : (font_descriptor U {unknown}) := unknown

[load_font(self:string, bi:{NORM,BOLD,ITALIC,BOLD_ITALIC}) : font_descriptor ->
	self := upper(substring(self,1,1)) /+ lower(substring(self,2, length(self))),
	when x := FONTS[self,bi] in x as font_descriptor
	else let ext := (case bi
						({NORM} "", {BOLD} "-Bold",
						{ITALIC} "-Oblique", any "-BoldOblique")),
			ext2 := (case bi
						({NORM} "", {BOLD} "-Bold",
						{ITALIC} "-Italic", any "-BoldItalic"))
	in (if isfile?(SERIALIZED_AFM_PATH / self /+ ext /+ ".serialized")
			let f := fopen(SERIALIZED_AFM_PATH / self /+ ext /+ ".serialized","r"),
				nf := (try unserialize(f) catch any false)
			in (fclose(f),
				if (not(nf) | nf.format_version != FONT_FORMAT_VERSION)
					(unlink(SERIALIZED_AFM_PATH / self /+ ext /+ ".serialized"),
					//[-100] Old format of the serialized font ~A // self,
					nf := load_font(self, bi), //<sb> reload
					nf as font_descriptor)
				else
					(FONTS[self, bi] := nf,
					nf as font_descriptor))
		else if isfile?(SERIALIZED_AFM_PATH / self /+ ext2 /+ ".serialized")
			let f := fopen(SERIALIZED_AFM_PATH / self /+ ext2 /+ ".serialized","r"),
				nf := (try unserialize(f) catch any false)
			in (fclose(f),
				if (not(nf) | nf.format_version != FONT_FORMAT_VERSION)
					(unlink(SERIALIZED_AFM_PATH / self /+ ext2 /+ ".serialized"),
					//[-100] Old format of the serialized font ~A // self,
					nf := load_font(self, bi), //<sb> reload
					nf as font_descriptor)
				else
					(FONTS[self, bi] := nf,
					nf as font_descriptor))
		else let f := (if isfile?(AFM_PATH / self /+ ext /+ ".afm")
						fopen(AFM_PATH / self /+ ext /+ ".afm","r")
						else fopen(AFM_PATH / self /+ ext2 /+ ".afm","r")),
				nf := font_descriptor(C = make_array(256, any, unknown),
							C-1 = make_table(string, any, unknown),
							fontface = self,
							italic? = (bi % {ITALIC,BOLD_ITALIC}),
							bold? = (bi % {BOLD,BOLD_ITALIC}))
			in (while not(eof?(f))
					let ex := explode(freadline(f), " ")
					in (if ex case ex[1]
						({"FontName"} nf.FontName := ex[2],
						{"FullName"} nf.FullName := ex[2],
						{"FamilyName"} nf.FamilyName := ex[2],
						{"Weight"} nf.Weight := ex[2],
						{"ItalicAngle"} nf.ItalicAngle := float!(ex[2]),
						{"IsFixedPitch"} nf.IsFixedPitch := ex[2] = "true",
						{"CharacterSet"} nf.CharacterSet := ex[2],
						{"FontBBox"} nf.FontBBox := tuple(float!(ex[2]),float!(ex[3]),
															float!(ex[4]),float!(ex[5])),
						{"UnderlinePosition"} nf.UnderlinePosition := float!(ex[2]),
						{"UnderlineThickness"} nf.UnderlineThickness := float!(ex[2]),
						{"EncodingScheme"} nf.EncodingScheme := ex[2],
						{"CapHeight"} nf.CapHeight := float!(ex[2]),
						{"XHeight"} nf.XHeight := float!(ex[2]),
						{"Ascender"} nf.Ascender := float!(ex[2]),
						{"Descender"} nf.Descender := float!(ex[2]),
						{"StdHW"} nf.StdHW := float!(ex[2]),
						{"StdVW"} nf.StdVW := float!(ex[2]),
						{"C"} let i := integer!(ex[2])
							in (if (i = -1)
									let n := ex[8],
										w := float!(ex[5])
									in (nf.maxc :max w,
										if (w > 0.0)
											nf.C-1[n] := tuple(w,
													float!(ex[11]),
													float!(ex[12]),
													float!(ex[13]),
													float!(ex[14])))
								else if (i % (1 .. 256))
									let w := float!(ex[5])
									in (nf.maxc :max w,
										if (w > 0.0)
											nf.C[i] := tuple(w,
													float!(ex[11]),
													float!(ex[12]),
													float!(ex[13]),
													float!(ex[14])))))),
				fclose(f),
				FONTS[self, bi] := nf,
				f := fopen(SERIALIZED_AFM_PATH / self /+ ext /+ ".serialized","w"),
				serialize(f, nf),
				fclose(f),
				nf))]


// *********************************************************************
// *   Part 2: pdf font / font descriptor mapping                      *
// *********************************************************************

// @cat afm
// In this implementation, fonts are handled globally, for each loaded font file
// is associated a unique font descriptor id. A pdf_document object uses its own
// selection of system font. The method get_font would select a given font for
// a supplied document and if that font does not exists in the system an
// attempt would be made to load the font metrics from the repository :
// \code
// fontid :: Pdf/get_font(doc, "Helvetica", false, false) // Helvetica normal (not bold, not italic)
// \/code
// @cat

[get_font(self:pdf_document, face:string, bi:{NORM,BOLD,ITALIC,BOLD_ITALIC}) : integer ->
	for i in (1 .. length(face))
		let n := integer!(face[i])
		in (if (i = 1)
				(if (n >= 97 & n <= 122) face[i] := char!(n - 32))
			else if (n >= 65 & n <= 90) face[i] := char!(n + 32)),
	let ff := 
		(when x := FONTS[face, bi]
		in (when df := some(f in self.fonts|f.font = x) in df
			else let f := pdf_font(doc = self, font = x)
				in (self.current_font_id :+ 1,
					f.fontnum := self.current_font_id,
					self.current_font := f,
					self.font_map[f.fontnum] := f.font,
					self.fonts add f,
					f))
		else
			let fn := load_font(face, bi),
				f := pdf_font(doc = self, font = fn)
			in (self.current_font_id :+ 1,
				f.fontnum := self.current_font_id,
				self.current_font := f,
				self.font_map[f.fontnum] := f.font,
				self.fonts add f,
				f))
	in (use_resource(ff),
		ff.fontnum)]

// @doc font
[get_font(self:pdf_document, face:string, b?:boolean, i?:boolean) : integer =>
	get_font(self, face,
				(if b? (if i? BOLD_ITALIC else BOLD)
				else if i? ITALIC else NORM))]

[get_font(self:pdf_document, num:integer, b?:boolean, i?:boolean) : integer =>
	let f := self.font_map[num],
		face := f.fontface
	in get_font(self, face, b?, i?)]

// @doc font
// get_font_bold(self, num, b?) changes the current font and selects the font
// that have the same face as the font with id num and a bold attribute set (when
// b? is true) or not.  If no such font exists in the system an
// attempt is made to load a font metrics file. The returned value is the id of the
// selected font.
[get_font_bold(self:pdf_document, num:integer, b?:boolean) : integer ->
	let f := self.font_map[num],
		face := f.fontface,
		i? := f.italic?
	in get_font(self, face, b?, i?)]

// @doc font
// get_font_italic(self, num, b?) changes the current font and selects the font
// that have the same face as the font with id num and an italic attribute set (when
// b? is true) or not. If no such font exists in the system an
// attempt is made to load a font metrics file. The returned value is the id of the
// selected font.
[get_font_italic(self:pdf_document, num:integer, i?:boolean) : integer ->
	let f := self.font_map[num],
		face := f.fontface,
		b? := f.bold?
	in get_font(self, face, b?, i?)]

// @doc font
// get_font_face(self, num, face) changes the current font and selects the font
// that have the same bold and italic attribute as the font with id num but a
// different face. If no such font exists in the system an
// attempt is made to load a font metrics file. The returned value is the id of the
// selected font.
[get_font_face(self:pdf_document, num:integer, face:string) : integer ->
	let f := self.font_map[num],
		i? := f.italic?,
		b? := f.bold?
	in get_font(self, face, b?, i?)]

[get_italic(self:pdf_document, num:integer) : boolean => self.font_map[num].italic?]
[get_bold(self:pdf_document, num:integer) : boolean => self.font_map[num].bold?]


// *********************************************************************
// *   Part 3: text metrics                                            *
// *********************************************************************

// @cat text_layout
// In order to properly arrange text boxes a layout facility is provided to
// get various metrics and calculate the circumscribed rectangle of a given text
// (these methods are heavily used by the HTML renderer).
// This is achieved using the metrics of a font (defined in the associated AFM file)
// so that each layout API requires a font id (as returned by get_font) and the font
// size that would be used if the text was actually rendered.
// These layouts are always given in the identity matrix (untransformed).\br
// When lay-outing a text (with get_text_width or get_text_box), new line characters are handled
// like any other characters, that is by accounting the width of each glyph. The
// height of the lay-outed text would be set to the height metrics of the font modulo the font size.
// Notice that get_text_box would return a rectangle centered on the baseline of the font
// as illustrated by the method bellow that shows various layout informations for a given text and
// font :
// \code
// show_text_box_info(self:pdf_document,
// 					txt:string, // the text string to layout
// 					fontid:integer, // id of an font, as returned by get_font
// 					fsize:float) -> // a font size
// 	let rect := Pdf/get_text_box(self, "Hello World!", fontid, 14.),
// 		space_width := Pdf/get_text_width(self, " ", fontid, 14.),
// 		(underpos, thickness) := get_underline_metrics(self, fontid, 14.),
// 		xheight := get_xheight(self, fontid, 14.)
// 	in (printf("text box of [~A] ~S characters\\n", txt, length(txt)),
// 		printf("font size: ~Spt wide\\n", fsize),
// 		printf("space width: ~Spt long\\n", space_width),
// 		printf("height of lower 'x': ~Spt\\n", xheight),
// 		printf("underline position: ~Spt above baseline\\n", underpos),
// 		printf("underline tickness: ~Spt wide\\n", thickness),
// 		assert(rect.Pdf/left = 0.),
// 		printf("text ascender: ~Spt\\n", rect.Pdf/top),
// 		printf("text descender: ~Spt\\n", -(rect.Pdf/bottom)),
// 		printf("text width: ~Spt\\n", rect.Pdf/right))
// \/code
// @cat

[mblen(s:string) : integer -> externC("mblen(s,	strlen(s))", integer)]

private/UTF8_MODE:boolean := false

[set_utf8() : boolean => UTF8_MODE := true]
[unset_utf8() : boolean => UTF8_MODE := false]

[get_font_height(self:pdf_document, num:integer) : float ->
	let f := self.font_map[num] as font_descriptor
	in ((f.FontBBox[4] - f.FontBBox[2]) / 1000.0)]


[get_font_height(self:pdf_document, num:integer, s:float) : float ->
	let f := self.font_map[num] as font_descriptor
	in (s * (f.FontBBox[4] - f.FontBBox[2]) / 1000.0)]

[get_text_width_utf8(t:string, f:font_descriptor, s:float) : float ->
	let w := 0.0, fl := f.C, fl-1 := f.C-1
	in (for i in (1 .. length(t))
			let c := (#if compiler.loading?
							externC("(int)((unsigned char)t[i - 1])", integer)
						else integer!(t[i])) as I256,
				m! := mac!(c),
				m2n := mac2name(m!),
				flm! := fl[m!]
			in (case flm!
					(tuple
						(if (flm![1] <= 0.) w :+ f.maxc
						else w :+ flm![1] as float),
					any
						let fl-1m2n := fl-1[m2n]
						in case fl-1m2n
							(tuple
								(if (fl-1m2n[1] <= 0.) w :+ f.maxc
								else w :+ fl-1m2n[1] as float)))),
				//if known?(fl[m!]) w :+ fl[m!][1] as float
				//else if known?(fl-1[m2n]) w :+ fl-1[m2n][1] as float),
		w * s / 1000.0)]

[get_text_width(t:string, f:font_descriptor, s:float) : float ->
	let w := 0.0, fl := f.C, fl-1 := f.C-1
	in (for i in (1 .. length(t))
			let c := (#if compiler.loading?
							externC("(int)((unsigned char)t[i - 1])", integer)
						else integer!(t[i])) as I256,
				m! := mac!(c),
				m2n := mac2name(m!),
				flm! := fl[m!]
			in (case flm!
					(tuple
						(if (flm![1] <= 0.) w :+ f.maxc
						else w :+ flm![1] as float),
					any
						let fl-1m2n := fl-1[m2n]
						in case fl-1m2n
							(tuple
								(if (fl-1m2n[1] <= 0.) w :+ f.maxc
								else w :+ fl-1m2n[1] as float)))),
				//if known?(fl[m!]) w :+ fl[m!][1] as float
				//else if known?(fl-1[m2n]) w :+ fl-1[m2n][1] as float),
		w * s / 1000.0)]

[get_text_box(t:string, f:font_descriptor, s:float) : rectangle ->
	let z :=  s / 1000.0, fb := f.FontBBox
	in rectangle!(0.0, fb[4] * z, get_text_width(t,f,s), fb[2] * z)]

[get_baseline(f:font_descriptor, s:float) : float =>
	let z :=  s / 1000.0 in f.FontBBox[4] * z]

[get_descender(f:font_descriptor, s:float) : float =>
	let z :=  s / -1000.0 in f.FontBBox[2] * z]


// @doc text_layout
[get_text_box(self:pdf_document, t:string, f:integer, s:float) : rectangle ->
	let fn := self.font_map[f] as font_descriptor
	in get_text_box(t, fn, s)]

// @doc text_layout
[get_baseline(self:pdf_document, f:integer, s:float) : float =>
	let fn := self.font_map[f] as font_descriptor
	in get_baseline(fn, s)]

// @doc text_layout
[get_descender(self:pdf_document, f:integer, s:float) : float =>
	let fn := self.font_map[f] as font_descriptor
	in get_descender(fn, s)]
	
// @doc text_layout
[get_text_width(self:pdf_document, t:string, f:integer, s:float) : float ->
	let fn := self.font_map[f] as font_descriptor
	in get_text_width(t, fn, s)]

// @doc text_layout
[get_underline_metrics(self:pdf_document, num:integer, s:float) : tuple(float, float) ->
	let fn := self.font_map[num] as font_descriptor
	in tuple(s * fn.UnderlinePosition / 1000.0, s * fn.UnderlineThickness / 1000.0)]

// @doc text_layout
[get_xheight(self:pdf_document, f:integer, s:float) : float ->
	let fn := self.font_map[f] as font_descriptor
	in (s * fn.XHeight / 1000.0)]

