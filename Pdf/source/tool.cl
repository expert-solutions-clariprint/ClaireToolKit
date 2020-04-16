
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * tool.cl                                                           *
// * Copyright (C) 2000 - 2004 xl. All Rights Reserved                 *
// *********************************************************************


// *********************************************************************
// *   Part 1: document dimension                                      *
// *   Part 2: escaping pdf strings                                    *
// *   Part 3: rectangles                                              *
// *   Part 4: miscellaneous math methods                              *
// *   Part 5: X11 color names                                         *
// *   Part 6: MAC/WIN char encoding                                   *
// *********************************************************************


// *********************************************************************
// *   Part 1: document dimension                                      *
// *********************************************************************


[set_dimension(self:pdf_section, s:string) : void ->
	self.dim := (case upper(s)
		({"4A0"} rectangle!(0.0,6740.79,4767.87,0.0),
		{"2A0"} rectangle!(0.0,4767.87,3370.39,0.0),
		{"A0"} rectangle!(0.0,3370.39,2383.94,0.0),
		{"A1"} rectangle!(0.0,2383.94,1683.78,0.0),
		{"A2"} rectangle!(0.0,1683.78,1190.55,0.0),
		{"A4"} rectangle!(0.0,841.89,595.28,0.0),
		{"A3"} rectangle!(0.0,1190.55,841.89,0.0),
		{"A5"} rectangle!(0.0,595.28,419.53,0.0),
		{"A6"} rectangle!(0.0,419.53,297.64,0.0),
		{"A7"} rectangle!(0.0,297.64,209.76,0.0),
		{"A8"} rectangle!(0.0,209.76,147.40,0.0),
		{"A9"} rectangle!(0.0,147.40,104.88,0.0),
		{"A10"} rectangle!(0.0,104.88,73.70,0.0),
		{"B0"} rectangle!(0.0,4008.19,2834.65,0.0),
		{"B1"} rectangle!(0.0,2834.65,2004.09,0.0),
		{"B2"} rectangle!(0.0,2004.09,1417.32,0.0),
		{"B3"} rectangle!(0.0,1417.32,1000.63,0.0),
		{"B4"} rectangle!(0.0,1000.63,708.66,0.0),
		{"B5"} rectangle!(0.0,708.66,498.90,0.0),
		{"B6"} rectangle!(0.0,498.90,354.33,0.0),
		{"B7"} rectangle!(0.0,354.33,249.45,0.0),
		{"B8"} rectangle!(0.0,249.45,175.75,0.0),
		{"B9"} rectangle!(0.0,175.75,124.72,0.0),
		{"B10"} rectangle!(0.0,124.72,87.87,0.0),
		{"C0"} rectangle!(0.0,3676.54,2599.37,0.0),
		{"C1"} rectangle!(0.0,2599.37,1836.85,0.0),
		{"C2"} rectangle!(0.0,1836.85,1298.27,0.0),
		{"C3"} rectangle!(0.0,1298.27,918.43,0.0),
		{"C4"} rectangle!(0.0,918.43,649.13,0.0),
		{"C5"} rectangle!(0.0,649.13,459.21,0.0),
		{"C6"} rectangle!(0.0,459.21,323.15,0.0),
		{"C7"} rectangle!(0.0,323.15,229.61,0.0),
		{"C8"} rectangle!(0.0,229.61,161.57,0.0),
		{"C9"} rectangle!(0.0,161.57,113.39,0.0),
		{"C10"} rectangle!(0.0,113.39,79.37,0.0),
		{"RA0"} rectangle!(0.0,3458.27,2437.80,0.0),
		{"RA1"} rectangle!(0.0,2437.80,1729.13,0.0),
		{"RA2"} rectangle!(0.0,1729.13,1218.90,0.0),
		{"RA3"} rectangle!(0.0,1218.90,864.57,0.0),
		{"RA4"} rectangle!(0.0,864.57,609.45,0.0),
		{"SRA0"} rectangle!(0.0,3628.35,2551.18,0.0),
		{"SRA1"} rectangle!(0.0,2551.18,1814.17,0.0),
		{"SRA2"} rectangle!(0.0,1814.17,1275.59,0.0),
		{"SRA3"} rectangle!(0.0,1275.59,907.09,0.0),
		{"SRA4"} rectangle!(0.0,907.09,637.80,0.0),
		{"LETTER"} rectangle!(0.0,792.00,612.00,0.0),
		{"LEGAL"} rectangle!(0.0,1008.00,612.00,0.0),
		{"EXECUTIVE"} rectangle!(0.0,756.00,521.86,0.0),
		{"FOLIO"} rectangle!(0.0,936.00,612.00,0.0),
		any rectangle!(0.0,841.89,595.28,0.0)))]

[mm2pt(f:float) : float -> f * 2.834646]
[pt2mm(f:float) : float -> f / 2.834646]

// *********************************************************************
// *   Part 2: escaping pdf strings                                    *
// *********************************************************************


[print_string_to_pdf_name(self:string) : void ->
	for i in (1 .. length(self))
		let c := self[i], ascii := integer!(c)
		in (if (ascii < 32 | ascii > 126 | ascii = #//)
				printf("#~A", replace(hex!(ascii),"0",""))
			else princ(c))]

[filter_pdf_string(self:string) : void ->
	for i in (1 .. length(self))
		let c := self[i]
		in (//if (i mod 80 = 0) princ("\\\n"), //<sb> sanity line break (ignored at load time)
			if (c % {'(',')','\\'}) printf("\\~A", c)
			else if (c = '\r') princ("\\r")
			//else if (c = '\0') princ("\\000")
			else if (c = '\n') princ("\\n")
			else princ(self, i, i))]

[unfilter_pdf_string(self:string) : string ->
	print_in_string(),
	for i in (1 .. length(self))
		case self[i]
			({'\\'}
				case self[i + 1]
					({'r'} (i : + 1, princ("\r")),
					{'n'} (i : + 1, princ("\n")),
					{'t'} (i : + 1, princ("\t")),
					{'('} (i : + 1, princ("(")),
					{')'} (i : + 1, princ(")")),
					{'\\'} (i : + 1, princ("\\"))),
			any princ(self, i, i)), end_of_string()]


// *********************************************************************
// *   Part 3: rectangles                                              *
// *********************************************************************

// @cat Rectangles
// @alias rectangles
// A little class is introduce to handle a rectangle object that hold
// the position of a box in a page coordinate system with the same
// orientation as page's rectangle. Some API will require a rectangle
// as parameter as created by :
// \code
// rect :: Pdf/rectangle!(100., // left border's X
// 						200., // top border's Y
// 						200., // right border's X
// 						100.) // bottom border's Y
// \/code
// A rectangle may also be constructed centered on point (0., 0.) with
// a given width and height :
// \code
// rect :: Pdf/rectangle!(100., 100.)
// (assert(rect.Pdf/left = -50.))
// (assert(rect.Pdf/right = 50.))
// (assert(rect.Pdf/top = 50.))
// (assert(rect.Pdf/bottom = -50.))
// \/code
// @cat

// @doc rectangles
[rectangle!(left_X:float,top_Y:float,right_X:float,bottom_Y:float) : rectangle =>
	rectangle(left = left_X, top = top_Y, right = right_X, bottom = bottom_Y)]

// @doc rectangles
[rectangle!(dx:float, dy:float) : rectangle =>
	let dx2 := 0.5 * dx,
		dy2 := 0.5 * dy
	in rectangle(left = -(dx2), top = dy2, right = dx2, bottom = -(dy2))]



[self_print(self:rectangle) : void ->
	printf("[~S ~S ~S ~S]", self.left, self.top, self.right, self.bottom)]

// @doc rectangles
// width(r:rectangle) return the width of a rectangle (i.e. r.right - r.left).
[width(r:rectangle) : float => r.right - r.left]
// @doc rectangles
// height(r:rectangle) return the height of a rectangle (i.e. r.top - r.bottom).
[height(r:rectangle) : float => r.top - r.bottom]

// @doc rectangles
// inflate(r, d) inflates the supplied rectangle. Each border are
// moved of a distance d such that the rectangle area increases.
[inflate(r:rectangle, d:float) : rectangle =>
	r.left :- d,
	r.top :+ d,
	r.bottom :- d,
	r.right :+ d,
	r]


// @doc rectangles
// inflate%(r, d%) inflates the supplied rectangle. Verticals border are
// moved of a distance d = d% * r.width / 100. such that the rectangle area increases.
// So does the horizontal borders proportionally to the height.
[inflate%(r:rectangle, d%:float) : rectangle =>
	let w := d% * width(r) / 100.,
		h := d% * height(r) / 100.
	in (r.left :- w,
		r.right :+ w,
		r.bottom :- h,
		r.top :+ h,
		r)]


// @doc rectangles
// deflate(r, d) deflates the supplied rectangle. Each border are
// moved of a distance d such that the rectangle area decreases.
[deflate(r:rectangle, d:float) : rectangle =>
	r.left :+ d,
	r.top :- d,
	r.bottom :+ d,
	r.right :- d,
	r]

// @doc rectangles
// deflate%(r, d%) deflates the supplied rectangle. Verticals border are
// moved of a distance d = d% * r.width / 100. such that the rectangle area decreases.
// So does the horizontal borders proportionally to the height.
[deflate%(r:rectangle, d%:float) : rectangle =>
	let w := d% * width(r) / 100.,
		h := d% * height(r) / 100.
	in (r.left :+ w,
		r.right :- w,
		r.bottom :+ h,
		r.top :- h,
		r)]



// *********************************************************************
// *   Part 4: miscellaneous math methods                              *
// *********************************************************************

abs(x:float) : float => (if (x < 0.) -(x) else x)
/*
sin(a:float) : float -> externC("sin(a)", float)
cos(a:float) : float -> externC("cos(a)", float)
tan(a:float) : float -> externC("tan(a)", float)
*/



// *********************************************************************
// *   Part 5: X11 color names                                         *
// *********************************************************************

//<sb> defaults colors
BLACK :: tuple(0.,0.,0.)
WHITE :: tuple(1.,1.,1.)


X11_NAMES :: list<string>(
"ALICEBLUE", "ANTIQUEWHITE", "AQUA", "AQUAMARINE", "AZURE", "BEIGE", "BISQUE",
"BLACK", "BLANCHEDALMOND", "BLUE", "BLUEVIOLET", "BROWN", "BURLYWOOD", "CADETBLUE",
"CHARTREUSE", "CHOCOLATE", "CORAL", "CORNFLOWERBLUE", "CORNSILK", "CRIMSON", "CYAN",
"DARKBLUE", "DARKCYAN", "DARKGOLDENROD", "DARKGRAY", "DARKGREEN", "DARKKHAKI",
"DARKMAGENTA", "DARKOLIVEGREEN", "DARKORANGE", "DARKORCHID", "DARKRED", "DARKSALMON",
"DARKSEAGREEN", "DARKSLATEBLUE", "DARKSLATEGRAY", "DARKTURQUOISE", "DARKVIOLET",
"DEEPPINK", "DEEPSKYBLUE", "DIMGRAY", "DODGERBLUE", "FIREBRICK", "FLORALWHITE",
"FORESTGREEN", "FUCHSIA", "GAINSBORO", "GHOSTWHITE", "GOLD", "GOLDENROD", "GRAY",
"GREEN", "GREENYELLOW", "HONEYDEW", "HOTPINK", "INDIANRED", "INDIGO", "IVORY",
"KHAKI", "LAVENDER", "LAVENDERBLUSH", "LAWNGREEN", "LEMONCHIFFON", "LIGHTBLUE",
"LIGHTCORAL", "LIGHTCYAN", "LIGHTGOLDENRODYELLOW", "LIGHTGREEN", "LIGHTGREY",
"LIGHTPINK", "LIGHTSALMON", "LIGHTSEAGREEN", "LIGHTSKYBLUE", "LIGHTSLATEGRAY",
"LIGHTSTEELBLUE", "LIGHTYELLOW", "LIME", "LIMEGREEN", "LINEN", "MAGENTA", "MAROON",
"MEDIUMAQUAMARINE", "MEDIUMBLUE", "MEDIUMORCHID", "MEDIUMPURPLE", "MEDIUMSEAGREEN",
"MEDIUMSLATEBLUE", "MEDIUMSPRINGGREEN", "MEDIUMTURQUOISE", "MEDIUMVIOLETRED",
"MIDNIGHTBLUE", "MINTCREAM", "MISTYROSE", "MOCCASIN", "NAVAJOWHITE", "NAVY",
"OLDLACE", "OLIVE", "OLIVEDRAB", "ORANGE", "ORANGERED", "ORCHID", "PALEGOLDENROD",
"PALEGREEN", "PALETURQUOISE", "PALEVIOLETRED", "PAPAYAWHIP", "PEACHPUFF", "PERU",
"PINK", "PLUM", "POWDERBLUE", "PURPLE", "RED", "ROSYBROWN", "ROYALBLUE", "SADDLEBROWN",
"SALMON", "SANDYBROWN", "SEAGREEN", "SEASHELL", "SIENNA", "SILVER", "SKYBLUE",
"SLATEBLUE", "SLATEGRAY", "SNOW", "SPRINGGREEN", "STEELBLUE", "TAN", "TEAL", "THISTLE",
"TOMATO", "TURQUOISE", "VIOLET", "WHEAT", "WHITE", "WHITESMOKE", "YELLOW", "YELLOWGREEN", "GREY")

X11_COLORS :: list<string>(
"#F0F8FF", "#FAEBD7", "#00FFFF", "#7FFFD4", "#F0FFFF", "#F5F5DC", "#FFE4C4", "#000000",
"#FFEBCD", "#0000FF", "#8A2BE2", "#A52A2A", "#DEB887", "#5F9EA0", "#7FFF00", "#D2691E",
"#FF7F50", "#6495ED", "#FFF8DC", "#DC143C", "#00FFFF", "#00008B", "#008B8B", "#B8860B",
"#A9A9A9", "#006400", "#BDB76B", "#8B008B", "#556B2F", "#FF8C00", "#9932CC", "#8B0000",
"#E9967A", "#8FBC8F", "#483D8B", "#2F4F4F", "#00CED1", "#9400D3", "#FF1493", "#00BFFF",
"#696969", "#1E90FF", "#B22222", "#FFFAF0", "#228B22", "#FF00FF", "#DCDCDC", "#F8F8FF",
"#FFD700", "#DAA520", "#808080", "#008000", "#ADFF2F", "#F0FFF0", "#FF69B4", "#CD5C5C",
"#4B0082", "#FFFFF0", "#F0E68C", "#E6E6FA", "#FFF0F5", "#7CFC00", "#FFFACD", "#ADD8E6",
"#F08080", "#E0FFFF", "#FAFAD2", "#90EE90", "#D3D3D3", "#FFB6C1", "#FFA07A", "#20B2AA",
"#87CEFA", "#778899", "#B0C4DE", "#FFFFE0", "#00FF00", "#32CD32", "#FAF0E6", "#FF00FF",
"#800000", "#66CDAA", "#0000CD", "#BA55D3", "#9370DB", "#3CB371", "#7B68EE", "#00FA9A",
"#48D1CC", "#C71585", "#191970", "#F5FFFA", "#FFE4E1", "#FFE4B5", "#FFDEAD", "#000080",
"#FDF5E6", "#808000", "#6B8E23", "#FFA500", "#FF4500", "#DA70D6", "#EEE8AA", "#98FB98",
"#AFEEEE", "#DB7093", "#FFEFD5", "#FFDAB9", "#CD853F", "#FFC0CB", "#DDA0DD", "#B0E0E6",
"#800080", "#FF0000", "#BC8F8F", "#4169E1", "#8B4513", "#FA8072", "#F4A460", "#2E8B57",
"#FFF5EE", "#A0522D", "#C0C0C0", "#87CEEB", "#6A5ACD", "#708090", "#FFFAFA", "#00FF7F",
"#4682B4", "#D2B48C", "#008080", "#D8BFD8", "#FF6347", "#40E0D0", "#EE82EE", "#F5DEB3",
"#FFFFFF", "#F5F5F5", "#FFFF00", "#9ACD32", "#333333")

[hex2int(x:char) : (0 .. 15) ->
	let i := integer!(x)
	in (if (i > 97) i :- 32,
		if (i >= 65) 10 + i - 65 // 70 <=> 'A'
		else i - 48) as (0 .. 15)] // 48 <=> '0'
		
[hex2int(s:string) : integer ->
	let i := 0
	in (for x in (1 .. length(s))
			i := 16 * i + hex2int(s[x]),
		i)]
[hex2float(s:string) : float => float!(hex2int(s)) / 255.0]
	

[string2color(s:string) : tuple(float, float, float) ->
	s := upper(s),
	if match_wildcard?(s,"RGB(*%,*%,*%)")
		let expl := explode_wildcard(s,"RGB(*%,*%,*%)")
		in tuple(0.01 * float!(expl[1]), 0.01 * float!(expl[2]), 0.01 * float!(expl[3]))
	else if match_wildcard?(s,"RGB(*,*,*)")
		let expl := explode_wildcard(s,"RGB(*,*,*)")
		in tuple(float!(expl[1]) / 255., float!(expl[2]) / 255., float!(expl[3]) / 255.)
	else
		(when x := some(x in (1 .. length(X11_NAMES))| let sn:string := X11_NAMES[x] in sn = s)
		in s := X11_COLORS[x],
		try
			(if (length(s) = 7)
				tuple(hex2float(substring(s, 2, 3)), // #rrggbb
						hex2float(substring(s, 4, 5)),
						hex2float(substring(s, 6, 7)))
			else if (length(s) = 4)
				tuple(hex2float(substring(s, 2, 2) /+ substring(s, 2, 2)), // #rgb
					hex2float(substring(s, 3, 3) /+ substring(s, 3, 3)),
					hex2float(substring(s, 4, 4) /+ substring(s, 4, 4)))
			else BLACK)
		catch any BLACK)]



// *********************************************************************
// *   Part 6: MAC/WIN char encoding                                   *
// *********************************************************************

I256 :: (0 .. 255)

MAC2NAME[i:I256] : string := ""
MAC2WIN[mac:I256] : I256 := 1
WIN2MAC[win:I256] : I256 := 1

[name2char!(s:string,c1:I256,c2:I256) : void =>
	MAC2NAME[c1] := s,
	MAC2WIN[c1] := c2,
	WIN2MAC[c2] := c1]

[win!(i:I256) : I256 => MAC2WIN[i]]
[mac!(i:I256) : I256 => WIN2MAC[i]]

[mac2name(n:I256) : string => MAC2NAME[n]]

(for i in I256 (MAC2WIN[i] := i, WIN2MAC[i] := i))

(name2char!("Adieresis", 128, 196))
(name2char!("Aring", 129, 197))
(name2char!("Ccedilla", 130, 199))
(name2char!("Eacute", 131, 201))
(name2char!("Ntilde", 132, 209))
(name2char!("Odieresis", 133, 214))
(name2char!("Udieresis", 134, 220))
(name2char!("aacute", 135, 225))
(name2char!("agrave", 136, 224))
(name2char!("acircumflex", 137, 226))
(name2char!("adieresis", 138, 228))
(name2char!("atilde", 139, 227))
(name2char!("aring", 140, 229))
(name2char!("ccedilla", 141, 231))
(name2char!("eacute", 142, 233))
(name2char!("egrave", 143, 232))
(name2char!("ecircumflex", 144, 234))
(name2char!("edieresis", 145, 235))
(name2char!("iacute", 146, 237))
(name2char!("igrave", 147, 236))
(name2char!("icircumflex", 148, 238))
(name2char!("idieresis", 149, 239))
(name2char!("ntilde", 150, 241))
(name2char!("oacute", 151, 243))
(name2char!("ograve", 152, 242))
(name2char!("ocircumflex", 153, 244))
(name2char!("odieresis", 154, 246))
(name2char!("otilde", 155, 245))
(name2char!("uacute", 156, 250))
(name2char!("ugrave", 157, 249))
(name2char!("ucircumflex", 158, 251))
(name2char!("udieresis", 159, 252))
//(name2char!("dagger", 160, 134))
(name2char!("currency", 160, 164))
(name2char!("degree", 161, 176))
(name2char!("cent", 162, 162))
(name2char!("sterling", 163, 163))
(name2char!("section", 164, 167))
(name2char!("bullet", 165, 149))
(name2char!("paragraph", 166, 182))
(name2char!("germandbls", 167, 223))
(name2char!("registered", 168, 174))
(name2char!("copyright", 169, 169))
(name2char!("trademark", 170, 153))
(name2char!("acute", 171, 180))
(name2char!("dieresis", 172, 168))
(name2char!("AE", 174, 198))
(name2char!("Oslash", 175, 216))
(name2char!("plusminus", 177, 177))
(name2char!("yen", 180, 165))
(name2char!("mu", 181, 181))
(name2char!("ordfeminine", 187, 170))
(name2char!("ordmasculine", 188, 186))
(name2char!("ae", 190, 230))
(name2char!("oslash", 191, 248))
(name2char!("questiondown", 192, 191))
(name2char!("exclamdown", 193, 161))
(name2char!("logicalnot", 194, 172))
(name2char!("florin", 196, 131))
(name2char!("guillemotleft", 199, 171))
(name2char!("guillemotright", 200, 187))
(name2char!("ellipsis", 201, 133))
(name2char!("Agrave", 203, 192))
(name2char!("Atilde", 204, 195))
(name2char!("Otilde", 205, 213))
(name2char!("OE", 206, 140))
(name2char!("oe", 207, 156))
(name2char!("endash", 208, 150))
(name2char!("emdash", 209, 151))
(name2char!("quotedblleft", 210, 147))
(name2char!("quotedblright", 211, 148))
(name2char!("quoteleft", 212, 145))
(name2char!("quoteright", 213, 146))
(name2char!("divide", 214, 247))
(name2char!("multiply", 215, 120))
(name2char!("ydieresis", 216, 255))
(name2char!("Ydieresis", 217, 159))
(name2char!("Euro", 219, 128))
(name2char!("guilsinglleft", 220, 139))
(name2char!("guilsinglright", 221, 155))
(name2char!("daggerdbl", 224, 135))
(name2char!("periodcentered", 225, 183))
(name2char!("quotesinglbase", 226, 130))
(name2char!("quotedblbase", 227, 132))
(name2char!("perthousand", 228, 137))
(name2char!("Acircumflex", 229, 194))
(name2char!("Ecircumflex", 230, 202))
(name2char!("Aacute", 231, 193))
(name2char!("Edieresis", 232, 203))
(name2char!("Egrave", 233, 200))
(name2char!("Iacute", 234, 205))
(name2char!("Icircumflex", 235, 206))
(name2char!("Idieresis", 236, 207))
(name2char!("Igrave", 237, 204))
(name2char!("Oacute", 238, 211))
(name2char!("Ocircumflex", 239, 212))
(name2char!("Ograve", 241, 210))
(name2char!("Uacute", 242, 218))
(name2char!("Ucircumflex", 243, 219))
(name2char!("Ugrave", 244, 217))
(name2char!("circumflex", 246, 136))
(name2char!("tilde", 247, 152))
(name2char!("macron", 248, 175))
(name2char!("cedilla", 252, 184))













