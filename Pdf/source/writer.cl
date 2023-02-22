
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * writer.cl                                                         *
// * Copyright (C) 2000 - 2004 xl. All Rights Reserved                 *
// *********************************************************************


// *********************************************************************
// *   Part 1: document                                                *
// *   Part 2: page                                                    *
// *   Part 3: annotation                                              *
// *   Part 4: graphic operations                                      *
// *   Part 5: images                                                  *
// *   Part 6: interactive form                                        *
// *   Part 7: html to pdf                                             *
// *********************************************************************


// *********************************************************************
// *   Part 1: document                                                *
// *********************************************************************

self_pdf_date(f:float) : void -> princ(strftime("%Y%m%d%H%M%SZ00'00'", f))

SELF_FLOAT_BUF :: make_string(30, ' ')

self_float(f:float) : void ->
	(externC("char fbuf[16]"),
	if externC("((floor(f) == f || ((floor(f) - f) < 0.001 && (floor(f) - f) > -0.001)) ? CTRUE : CFALSE)", boolean)
		printf(" ~S", externC("(int)f", integer))
	else let s := externC("fbuf", string),
			n := externC("sprintf(s,\"%.3lf\", f)", integer)
		in (while (s[n] = '0') n :- 1,
			princ(" "),
			princ(s, 1, n)))


//<sb> rgb color
[self_pdf_color(self:tuple(float,float,float)) : void ->
	for f in self
		self_float(f)]


[object_less?(o1:pdf_object, o2:pdf_object) : boolean -> o1.id < o2.id]

[self_pdf(self:pdf_object) : void -> none]


[self_pdf(self:pdf_document) : void ->
	render_sections(self),
	update_page_number(self),
	let xref := list<integer>(),
		sig := unknown,
		before_sig := port!(),
		after_sig := port!(),
		p := port!(),
		old := cout(),
		out := before_sig,
		pos := 16
	in (fwrite("%PDF-1.4\n%‚„œ”\n", out),
		for o in sort(object_less? @ pdf_object, self.objects)
			case o
				(pdf_signature_field
					(sig := o,
					out := after_sig,
					xref :add pos,
					pos :+ sig_length(sig),
					use_as_output(after_sig)),
				any (set_length(p, 0),
					use_as_output(p),
					self_pdf(o),
					use_as_output(out),
					xref :add pos,
					pos :+ freadwrite(p, cout()))),
		printf("\nxref\n0 ~A\n0000000000 65535 f \n",length(xref) + 1),
		for i in xref
			let s := string!(i)
			in printf("~A~A 00000 n \n", substring("0000000000", 1, 10 - length(s)), s),
		printf("\ntrailer\n  <</Size ~S/Root ~S 0 R/Info ~S 0 R",
					length(xref) + 1,
					self.catalog.id,
					self.info.id),
		printf(">>\nstartxref\n~S\n%%EOF\n", pos),
		use_as_output(old),
		if known?(sig) sign_pdf(sig, before_sig, after_sig)
		else
			(freadwrite(before_sig, cout()),
			freadwrite(after_sig, cout())))]

[self_pdf(self:pdf_names) : void ->
	printf("\n~S 0 obj\n", self.id),
	printf("<</EmbeddedFiles <</Names [~I]>>",
				for n in self.embeddedfiles
					printf("(~A)~S 0 R", n.adbeid, n.id)),
	printf("/JavaScript <</Names [~I]>>",
				for n in self.javascripts
					printf("(docjs~A) ~S 0 R", n.id, n.id)),
	princ(">>\nendobj")]

[self_pdf(self:pdf_javascript) : void ->
	printf("\n~S 0 obj\n", self.id),
	printf("<</S/JavaScript/JS (~I)", filter_pdf_string(self.script)),
	princ(">>\nendobj")]
	

[self_pdf(self:pdf_catalog) : void ->
	printf("\n~S 0 obj\n", self.id),
	printf("<</Type/Catalog"),
	printf("/Pages ~S 0 R", self.page_tree_root.id),
	if known?(acro_form, self)
		printf("/AcroForm ~S 0 R", self.acro_form.id),
	when toc := some(x in self.doc.objects|x % toc_entry)
	in (printf("/Outlines ~S 0 R", toc.id),
		printf("/PageMode/UseOutlines")),
	printf("/PageMode/UseAttachments"),
	printf("/Names ~S 0 R", self.names.id),
	princ(">>\nendobj")]

[self_pdf(self:pdf_page_tree) : void ->
	printf("\n~S 0 obj\n<</Type/Pages\n/Kids [", self.id),
	for t in self.doc.section_order
		printf(" ~S 0 R", t[2].id),
	let n := 0
	in (for i in list{x in self.doc.objects|x % pdf_page} n :+ 1,
		printf("]\n/Count ~S", n),
		princ(">>\nendobj"))]

[self_pdf(self:pdf_info) : void ->
	printf("\n~S 0 obj\n<<", self.id),
	printf("/Producer (Claire v~A, module Pdf ~A)\n", release(), get(version, Pdf)),
	printf("/CreationDate (D:~I)\n", self_pdf_date(self.doc.creation_date)),
	printf("/ModDate (D:~I)\n", self_pdf_date(now())),
	if known?(title, self)
		printf("/Title (~A)", self.title),
	princ(">>\nendobj")]

// *********************************************************************
// *   Part 2: page                                                    *
// *********************************************************************

[self_resource_procset(self:set[pdf_resource]) : void ->
	let image? := false
	in (printf("\n/Resources <<~I~I~I>>",
		(if exists(res in self | res % pdf_font)
			printf("/Font <<~I>>",
				for o in list{o in self | o % pdf_font}
					printf("/F~S ~S 0 R", o.fontnum, o.id))),
		(if exists(res in self | res % pdf_extgstate)
			printf("/ExtGState <<~I>>",
				for o in list{o in self | o % pdf_extgstate}
					printf("/GS~S ~S 0 R", o.id, o.id))),
		(if exists(res in self | res % pdf_image | res % pdf_form_xobject)
			(image? := true,
			printf("/XObject <<~I~I>>",
				for o in list{o in self | o % pdf_form_xobject}
					printf("/XO~S ~S 0 R", o.id, o.id),
				for o in list{o in self | o % pdf_image}
					printf("/Im~S ~S 0 R", o.imid, o.id))))),
		printf("\n/ProcSet [/PDF/Text~I]",
			(if image? princ("/ImageB/ImageC/ImageI"))))]
	

[self_pdf(self:pdf_section) : void ->
	printf("\n~S 0 obj\n<</Type/Pages", self.id),
	let n := 0
	in (printf("\n/Parent ~A 0 R", self.section_root.page_tree_root.id),
		printf("\n/Kids ["),
		for o in self.kids
			(printf(" ~S 0 R", o.id), n :+ 1),
		printf("]\n/Count ~S", n),
		self_resource_procset(self.resources),
		let l := self.dim
		in printf("\n/MediaBox [~I~I~I~I]",
				self_float(l.left), self_float(l.bottom),
				self_float(l.right), self_float(l.top)),
		princ(">>\nendobj"))]

[self_pdf(self:pdf_page) : void ->
	printf("\n~S 0 obj\n<</Type/Page", self.id),
	printf("/Parent ~A 0 R", self.parent.id),
	if self.contents
		(printf("\n/Contents ["),
		for o in self.contents
			printf(" ~S 0 R", o.id),
		printf("]")),
	if self.annots
		(printf("\n/Annots ["),
		for o in self.annots
			printf(" ~S 0 R", o.id),
		printf("]")),
	princ(">>\nendobj")]

[self_pdf(self:pdf_font) : void ->
	printf("\n~S 0 obj\n<</Type/Font", self.id),
	printf("/Subtype/Type1/Name/F~S", self.fontnum),
	printf("/BaseFont/~A", self.font.FontName),
	if (lower(self.font.CharacterSet) != "special")
		printf("/Encoding/WinAnsiEncoding"),
	princ(">>\nendobj")]


[begin_stream(self:pdf_document) : void ->
	self.streambuf := port!(),
	if self.deflate?
		self.streamport := Zlib/deflater!(self.streambuf)
	else self.streamport := self.streambuf,
	self.streamoldport := use_as_output(self.streamport)]

[end_stream(self:pdf_document) : void ->
	if self.deflate?
		Zlib/finish(self.streamport),
	use_as_output(self.streamoldport),
	if self.deflate?
		fclose(self.streamport),
	printf("~I/Length ~S",
		(if self.deflate? printf("/Filter/FlateDecode")),
		length(self.streambuf)),
	printf(">>\nstream\n~I", freadwrite(self.streambuf, cout())),
	princ("\nendstream"),
	fclose(self.streamport)]

[self_pdf(self:pdf_content) : void ->
	printf("\n~S 0 obj\n<<~I~I~I\nendobj",
		self.id,
		begin_stream(self.doc),
		for x in list{o in self.operations | not(o.inside_html_area?)}
			printf(" ~I", self_pdf(x)),
		end_stream(self.doc))]


// *********************************************************************
// *   Part 3: annotation                                              *
// *********************************************************************

[self_pdf(self:pdf_embedded_file) : void ->
	printf("\n~S 0 obj<</Type/EmbeddedFile", self.id),
	printf("/Subtype/~I", print_string_to_pdf_name(self.mimetype)),
	printf("/Params <<"),
	if known?(filepath, self)
		(printf("/Size ~A", integer!(fsize(self.filepath))),
		printf("/CreationDate (D:~I)", self_pdf_date(fchanged(self.filepath))),
		printf("/ModDate (D:~I)", self_pdf_date(fmodified(self.filepath))),
		printf(">>"),
		begin_stream(self.doc),
		let f := fopen(self.filepath,"r")
		in (freadwrite(f, cout()),
			fclose(f)),
		end_stream(self.doc))
	else if known?(inline_data, self)
		(printf("/Size ~A", length(self.inline_data)),
		if not(self.ignoredate?)
			(printf("/CreationDate (D:~I)", self_pdf_date(self.doc.creation_date)),
			printf("/ModDate (D:~I)", self_pdf_date(self.doc.creation_date))),
		printf(">>"),
		begin_stream(self.doc),
		set_index(self.inline_data, 0),
		freadwrite(self.inline_data, cout()),
		end_stream(self.doc))
	else
		let f := port!()
		in (try
				fill_attachment(self.userdata, f)
			catch selector_error[selector = fill_attachment]
				fill_attachment(self.doc, self.userdata, f),
			set_index(f, 0),
			printf("/Size ~A", length(f)),
			printf("/CreationDate (D:~I)", self_pdf_date(self.doc.creation_date)),
			printf("/ModDate (D:~I)", self_pdf_date(self.doc.creation_date)),
			printf(">>"),
			begin_stream(self.doc),
			freadwrite(f, cout()),
			fclose(f),
			end_stream(self.doc)),
	printf("endobj")]


[self_pdf(self:pdf_appearance_stream) : void ->
	printf("\n~S 0 obj\n<<", self.id),
	when N := get(normal, self)
	in printf("/N ~S 0 R", N.id),
	when R := get(rollover, self)
	in printf("/R ~S 0 R", R.id)
	else when N := get(normal, self)
		in printf("/R ~S 0 R", N.id),
	when D := get(down, self)
	in printf("/D ~S 0 R", D.id)
	else when N := get(normal, self)
		in printf("/D ~S 0 R", N.id),
	princ(">>\nendobj")]


[self_pdf(self:pdf_form_xobject) : void ->
	printf("\n~S 0 obj\n<</Type/XObject/Subtype/Form", self.id),
	when e := get(src, self)
	in printf("/BBox [~I~I~I~I]",
			self_float(e.X), 
			self_float(e.Y - e.height),
			self_float(e.X + e.width),
			self_float(e.Y))
	else let d := self.doc.catalog.current_section.dim
		in printf("/BBox [0 0~I~I]", self_float(d.right), self_float(d.top)),
	princ("/FormType 1"),
	princ("/Matrix [1 0 0 1 0 0]"),
	self_resource_procset(self.resources),
	begin_stream(self.doc),
	for e in self.xobject_elements draw_background(e),
	for e in self.xobject_elements self_pdf(e),
	for e in self.xobject_elements draw_borders(e),
	end_stream(self.doc),
	princ("\nendobj")]

[self_pdf(self:pdf_debug_xobject) : void ->
	printf("\n~S 0 obj\n<</Type/XObject/Subtype/Form", self.id),
	let d := self.doc.catalog.current_section.dim
	in printf("/BBox [0 0~I~I]", self_float(d.right), self_float(d.top)),
	if self.resources
		self_resource_procset(self.resources),
	if self.deflate?
		(begin_stream(self.doc),
		freadwrite(self.datastream, cout()),
		end_stream(self.doc))
	else 
		(printf("/Length ~S", length(self.datastream)),
		printf(">>\nstream\n"),
		freadwrite(self.datastream, cout()),
		princ("\nendstream")),
	princ("\nendobj")]


[self_pdf(self:pdf_appearance_xobject) : void ->
	printf("\n~S 0 obj\n<</Type/XObject/Subtype/Form", self.id),
	when e := get(src, self)
	in printf("/BBox [~I~I~I~I]",
			self_float(e.X), 
			self_float(e.placedbox.Y - e.height),
			self_float(e.X + e.width),
			self_float(e.placedbox.Y))
	else let d := self.doc.catalog.current_section.dim
		in printf("/BBox [0 0~I~I]", self_float(d.right), self_float(d.top)),
	princ("/FormType 1"),
	princ("/Matrix [1 0 0 1 0 0]"),
	self_resource_procset(self.resources),
	begin_stream(self.doc),
	for e in self.xobject_elements draw_background(e),
	for e in self.xobject_elements self_pdf(e),
	for e in self.xobject_elements draw_borders(e),
	end_stream(self.doc),
	princ("\nendobj")]


[annot_intro(self:pdf_annot) : void ->
	printf("\n~S 0 obj\n<</Type/Annot", self.id),
	when zone := get(src, self)
	in (printf("/Rect [~I~I~I~I]",
				self_float(zone.X),
				self_float(zone.placedbox.Y - zone.height),
				self_float(zone.X + zone.width),
				self_float(zone.placedbox.Y)),
		when nm := zone["name"]
		in printf("/T (~I)", filter_pdf_string(nm)),
		if known?(appearance, self)
			printf("/AP ~S 0 R", self.appearance.id)
		else
			printf("/C [~I]", self_pdf_color(css_get(zone, css_color))))
	//<sb> no associated element -> make an hidden attachment
	// with a null rect
	else princ("/Rect [0 0 0 0]"),
	// printf("\n/P ~S 0 R", self.target_page.id),
	printf("/Contents (~I)", filter_pdf_string(self.content))]

[self_pdf(self:pdf_file_attachment) : void ->
	annot_intro(self),
	printf("\n/Name/~A", self.name),
	printf("/Subtype/FileAttachment", self.id),
	printf("/FS <</Type/Filespec/F (~I)", filter_pdf_string(self.content)),
	printf("/EF <</F ~S 0 R>>>> ", self.embeddedfile.id),
	princ(">>\nendobj")]
	
[self_pdf(self:pdf_filespec) : void ->
	printf("\n~S 0 obj\n<<", self.id),
	printf("/Type/Filespec/F (~I)", filter_pdf_string(self.name)),
	printf("/EF<</F ~S 0 R>>", self.embeddedfile.id),
	princ(">>\nendobj")]

[self_pdf(self:pdf_free_annot) : void ->
	printf("\n~S 0 obj\n<</Type/Annot", self.id),
	printf("/Subtype/FreeText"),
	printf("/Border [0 0 0]"),
	let r := self.debug_box
	in printf("/Rect [~I~I~I~I]",
		self_float(r.left), self_float(r.bottom),
		self_float(r.right), self_float(r.top)),
	printf("/CA 0"),
	printf("/AP ~S 0 R", self.appearance.id),
	printf("/Contents ()"),
	printf("/DA ()"),
	princ(">>\nendobj")]

[self_pdf(self:pdf_text_annot) : void ->
	printf("\n~S 0 obj\n<</Type/Annot", self.id),
	printf("/Subtype/Text"),
	printf("/Border [0 0 0]"),
	printf("/Name/Help"),
	printf("/Contents (~I)", filter_pdf_string(self.content)),
	let r := self.debug_box
	in printf("/Rect [~I~I~I~I]",
		self_float(r.left), self_float(r.bottom),
		self_float(r.right), self_float(r.top)),
//	printf("\n/CA 0"),
	princ(">>\nendobj")]

[self_pdf(self:pdf_button) : void ->
	printf("\n~S 0 obj\n<</Type/Annot", self.id),
	printf("/Subtype/Widget"),
	printf("/Border [0 0 0]"),
	printf("/FT/Btn/F 6/H/N/Ff 65536"),
	printf("/P ~S 0 R", self.pageid),
	printf("/T (button~S)", self.id),
	let r := self.debug_box
	in printf("/Rect [~I~I~I~I]",
		self_float(r.left), self_float(r.bottom),
		self_float(r.right), self_float(r.top)),
	printf("/AP <</N ~S 0 R>>", self.ref_xobject.id),
	princ(">>\nendobj")]

[self_pdf(self:pdf_show_hide_button) : void ->
	printf("\n~S 0 obj\n<</Type/Annot", self.id),
	printf("/Subtype/Widget"),
	printf("/Border [0 0 0]"),
	printf("/FT/Btn/F 4/H/N/Ff 65536"),
	printf("/P ~S 0 R", self.pageid),
	printf("/T (button~S)", self.id),
	let r := self.debug_box
	in printf("/Rect [~I~I~I~I]",
		self_float(r.left), self_float(r.bottom),
		self_float(r.right), self_float(r.top)),
	printf("/CA 0/AA <<~I~I\n>>",
	printf("\n/U <</S/JavaScript/JS (this.exportDataObject({cName: ~S,nLaunch: 2});)>>",
				self.debug_file.adbeid),
	printf("\n/E <</S/Hide/T (button~S)/H false>>/X <</S/Hide/T (button~S)>>",
				self.rollover.id, self.rollover.id)),
	princ(">>\nendobj")]




[self_pdf(self:pdf_html_link) : void ->
	printf("\n~S 0 obj\n<</Type/Annot", self.id),
	printf("/Subtype/Link"),
	printf("/Border [0 0 0]"),
	let zone := self.linkrect
	in printf("/Rect [~I~I~I~I]", self_float(zone.left), self_float(zone.bottom),
											self_float(zone.right), self_float(zone.top)),
	if match_wildcard?(self.href, "####*")
		let prm := explode_wildcard(self.href, "####*")[1],
			(pid, pnum, y) := get_element_page_info(self.doc, Core/Oid~(prm))
		in printf("/Dest [~A 0 R /XYZ null~I null]", pid, self_float(y))
	else if match_wildcard?(self.href, "##*")			
		(when trgt := self.doc.html_name_map[explode_wildcard(self.href, "##*")[1]]
		in (if known?(pageid, trgt)
				(case trgt
					(html_a
						printf("/Dest [~S 0 R /XYZ null~I null]",
									trgt.pageid, self_float(trgt.Ypage))))
			else let (pid, pnum, y) := get_element_page_info(self.doc, trgt)
			in (case trgt
					(html_a
						printf("/Dest [~S 0 R /XYZ null~I null]", pid, self_float(y))))))
	else 
		(printf("/T (~I)", filter_pdf_string(self.href)),
		printf("/A <</S/URI/URI (~I)>>", filter_pdf_string(self.href))),
	printf(">>\nendobj")]
	


[widget_intro(self:pdf_widget) : void ->
	annot_intro(self),
	printf("/Subtype/Widget")]

[self_pdf(self:pdf_signature_widget) : void ->
	widget_intro(self),
	printf("/FT/Sig"),
	printf("/T (Signature~S)", self.id),
	printf("/V ~S 0 R", self.signature.id),
	printf(">>\nendobj")]


// *********************************************************************
// *   Part 4: graphic operations                                      *
// *********************************************************************


[self_pdf(self:pdf_moveto) : void ->
	printf("~I~I m", self_float(self.x), self_float(self.y))]

[self_pdf(self:pdf_begin_text) : void ->
	if (self.angle = 0.0)
		printf("BT~I~I Td", self_float(self.x), self_float(self.y))
	else let a := self.angle, ca := cos(a), sa := sin(a)
		in printf("BT~I~I~I~I~I~I Tm", self_float(ca),
					self_float(sa), self_float(-(sa)),
					self_float(ca), self_float(self.x),
					self_float(self.y))]

[self_pdf(self:pdf_show_text) : void -> printf("(~I) Tj", filter_pdf_string(self.text))]
[self_pdf(self:pdf_new_text_line) : void -> printf("~I TL T*", self_float(self.TL))]
[self_pdf(self:pdf_end_text) : void -> printf("ET")]

[self_pdf(self:pdf_select_font) : void ->
	printf("/F~S~I Tf", self.fontnum, self_float(self.fontsize))]
[self_pdf(self:pdf_color) : void ->
	printf("~I~I~I rg", self_float(self.r), self_float(self.g), self_float(self.b))]
[self_pdf(self:pdf_alpha) : void -> printf("/GS~S gs", self.extgstate.id)]
[self_pdf(self:pdf_stroke_color) : void ->
	printf("~I~I~I RG", self_float(self.r), self_float(self.g), self_float(self.b))]
[self_pdf(self:pdf_begin_path) : void -> printf("~I~I m", self_float(self.x), self_float(self.y))]
[self_pdf(self:pdf_lineto) : void -> printf("~I~I l", self_float(self.x), self_float(self.y))]
[self_pdf(self:pdf_curveto) : void ->
	printf("~I~I~I~I~I~I c", self_float(self.cx1),
		self_float(self.cy1), self_float(self.cx2),
		self_float(self.cy2), self_float(self.cx3),
		self_float(self.cy3))]
[self_pdf(self:pdf_end_path) : void -> princ(self.endop)]

[self_pdf(self:pdf_extgstate) : void ->
	printf("\n~S 0 obj\n<</Type/ExtGState/ca ~S>>\nendobj", self.id, self.opacity)]

[self_pdf(self:pdf_push_state) : void -> printf("q")]
[self_pdf(self:pdf_pop_state) : void -> printf("Q")]
[self_pdf(self:pdf_set_matrix) : void ->
	printf("~I~I~I~I~I~I cm",
		self_float(self._a), self_float(self._b),
		self_float(self._c), self_float(self._d),
		self_float(self._e), self_float(self._f))]

[self_pdf(self:pdf_line_width) : void -> printf("~I w", self_float(self.w))]
[self_pdf(self:pdf_line_join) : void -> printf(" ~S j", self.m)]
[self_pdf(self:pdf_line_cap) : void -> printf(" ~S J", self.m)]
[self_pdf(self:pdf_line_dash) : void ->
	if not(self.dash)
		printf("[]~I d", self_float(self.dashphase))
	else (princ("["),
		while (self.dash & last(self.dash) = 0.)
			nth-(self.dash, length(self.dash)),
		for d in self.dash
			self_float(d),
			printf("]~I d", self_float(self.dashphase)))]


// *********************************************************************
// *   Part 5: images                                                  *
// *********************************************************************

[self_pdf(self:pdf_image_colorspace) : void ->
	if known?(spdata,self)
	printf("\n~S 0 obj\n<</Length ~S>>\nstream\n~A\nendstream\nendobj",
		self.id,
		length(self.spdata),
		self.spdata)]

[self_pdf(self:pdf_png) : void ->
	//[-100] self_pdf@png(~S) // self,
	if (known?(ncolor,self) & known?(imwidth,self) & known?(bitdepth,self)) (
		printf("\n~S 0 obj\n<</Type/XObject", self.id),
		printf("/Subtype/Image"),
		printf("/Filter/FlateDecode"),
		printf("/Width ~S/Height ~S", integer!(self.imwidth), integer!(self.imheight)),
		printf("/DecodeParms <</Predictor 15/Colors ~S/Columns ~S/BitsPerComponent ~A>>",
					self.ncolor, integer!(self.imwidth), self.bitdepth),
		let x := self.colorspace,
			len := length(x.spdata)
		in (if (len > 0)
				(printf("/ColorSpace [/Indexed/DeviceRGB ~S ~S 0 R]", len / 3 - 1, x.id),
				if (self.t_type = "indexed")
					printf("/Mask [~S ~S]", self.t_data, self.t_data))
			else printf("/ColorSpace/~A", self.colorspace.space)),
		printf("/BitsPerComponent ~A", self.bitdepth),
		printf("/Length ~S>>", length(self.pngdata)),
		printf("\nstream\n~A\nendstream\nendobj", self.pngdata)
	)]

[self_pdf(self:pdf_image_show) : void ->
	printf(" q ~S 0 0 ~S ~S ~S cm /Im~S Do Q ",
			self.imwidth, self.imheight,
			self.imx, self.imy,
			self.im.imid)]

//
[self_pdf(self:pdf_jpg) : void ->
	//[-100] self_pdf@jpg(~S) // self,
	printf("\n~S 0 obj\n<< /Type /XObject", self.id),
	printf("\n/Subtype /Image"),
	printf("\n/Filter /DCTDecode"),
	printf("\n/Width ~S\n/Height ~S", integer!(self.imwidth), integer!(self.imheight)),
	printf("\n/ColorSpace /~A", self.colorspace.space),
	printf("\n/BitsPerComponent ~A", self.bitdepth),
	printf("\n/Length ~S >>", length(self.jpgdata)),
	printf("\nstream\n~I\nendstream\nendobj\n", 
			(	set_index(self.jpgdata,0),
				while not(eof?(self.jpgdata)) putc(getc(self.jpgdata),cout()) ))]


// *********************************************************************
// *   Part 6: interactive form                                        *
// *********************************************************************

[self_pdf(self:pdf_interactive_form) : void ->
	printf("\n~S 0 obj\n<</Fields [~I]/SigFlags ~S",
				self.id,
				(for x in self.fields
					printf(" ~S 0 R", x.id)),
				self.sig_flags),
	printf("/DR <</Font /F1>>"),
	printf("/DA ()"),
	printf(">>\nendobj")]


//<sb> sig_length prints the object introduction with
// the known part (at this time in this implementation) of the
// signature dictionary. sig_length then return the amount of byte necessary
// to print the end of the dictionary (the document signature as the encrypted
// document digest).
[sig_length(self:pdf_signature_field) : integer ->
	let bc := byte_counter!(cout()),
		old := use_as_output(bc)
	in (printf("\n~S 0 obj\n<<", self.id),
		printf("/Type/Sig"),
		//<sb> the name is the common name of signer's certificate
		printf("/Name (~I)", filter_pdf_string(Openssl/get_subject_entry(self.certificate, "CN"))),
		printf("/Reason (~I)", filter_pdf_string(self.reason)),
		printf("/Location (~I)", filter_pdf_string(self.siglocation)),
		printf("/ContactInfo (~I)", filter_pdf_string(self.contact_info)),
		printf("/Filter/Adobe.PPKLite"),
		printf("/M (D:~I)", self_pdf_date(now())),
		case self.sig_format
			({"x509.rsa_sha1"}
				(printf("/SubFilter/adbe.x509.rsa_sha1"),
				printf("\n/Cert [(~I)~I]",
						filter_pdf_string(Openssl/i2d(self.certificate)),
						(for c in self.cert_chain
							printf(" (~I)", filter_pdf_string(Openssl/i2d(c))))),
				printf("\n/Contents "),
				let n := written_bytes(bc)
				in (fclose(bc),
					use_as_output(old),
					n + Openssl/key_size(self.private_key) * 2 + 8 + 49 + 10 + 2)),
			any // "pkcs7.sha1"
				(printf("/SubFilter/adbe.pkcs7.sha1"),
				printf("\n/Contents "),
				let n := written_bytes(bc)
				in (fclose(bc),
					use_as_output(old),
					n + 7000 + 49 + 10 + 2))))]

//<sb> print the signature object
[sign_pdf(self:pdf_signature_field, before_sig:port, after_sig:port) : void ->
	case self.sig_format
		({"x509.rsa_sha1"} sign_pdf_x509_rsa_sha1(self, before_sig, after_sig),
		{"pkcs7.sha1"} sign_pdf_pkcs7_sha1(self, before_sig, after_sig),
		any error("unsupported signature format ~A", self.sig_format))]

[sign_pdf_pkcs7_sha1(self:pdf_signature_field, before_sig:port, after_sig:port) : void ->
	let bytes_range := port!(),
		old := use_as_output(bytes_range),
		contents_padding := 7000,
		bytes_range_padding := 49, //<sb> length of "\n/ByteRange [xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx]"
		p7 := Openssl/PKCS7!(self.certificate, self.private_key), //<sb> the PKCS#7 object used for signing
		ctx := Openssl/digest_context!("sha1")
	in (for x in self.cert_chain
			Openssl/add_certificate(p7, x),
		//<sb> process the range on which the digest is performed
		printf("\n/ByteRange [0 ~S ~S ~S]",
					length(before_sig),
					length(before_sig) + contents_padding + 2, //<sb> + 2 for /Contents's hex string angles (i.e '<' and '>')
					length(after_sig) + bytes_range_padding + 10), //<sb> 3 bytes for the dictionary ending (i.e. "\n>>")
																	// + 7 bytes for "\nendobj"
		let remain := bytes_range_padding - length(bytes_range)
		in for i in (1 .. remain) princ(" "), //<sb> pads byte range
		printf("\n>>\nendobj"),
		//<sb> process sha1 document digest
		Openssl/digest_init(ctx),
		let s := make_string(1024, ' ')
		in while (fread(before_sig, s) > 0) Openssl/digest_update(ctx, s),
		let s := make_string(1024, ' ')
		in while (fread(bytes_range, s) > 0) Openssl/digest_update(ctx, s),
		let s := make_string(1024, ' ')
		in while (fread(after_sig, s) > 0) Openssl/digest_update(ctx, s),
		//<sb> sign our digest into the PKCS#7 object
		Openssl/sign(p7, Openssl/digest_final(ctx)),
		//<sb> flush what is before signature
		use_as_output(old),
		set_index(before_sig, 0),
		freadwrite(before_sig, old),
		//<sb> flush signature (hex encoded binary PKCS#7 object with sha1 signed digest data)
		printf("<~I>", 
			(let sig := Openssl/string2hex(Openssl/i2d(p7))
			in (princ(sig),
				let remain := contents_padding - length(sig)
				in for i in (1 .. remain) princ('0')))),
		//<sb> flush byte range
		set_index(bytes_range, 0),
		freadwrite(bytes_range, old),
		//<sb> flush what is after signature
		set_index(after_sig, 0),
		freadwrite(after_sig, old))]

[sign_pdf_x509_rsa_sha1(self:pdf_signature_field, before_sig:port, after_sig:port) : void ->
	let bytes_range := port!(),
		old := use_as_output(bytes_range),
		contents_padding := Openssl/key_size(self.private_key) * 2 + 8, //<sb> hex encoding signature length
		bytes_range_padding := 49, //<sb> length of "\n/ByteRange [xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx]"
		ctx := Openssl/digest_context!("sha1")
	in (//<sb> process the range on which the digest is performed
		printf("\n/ByteRange [0 ~S ~S ~S]",
					length(before_sig),
					length(before_sig) + contents_padding + 2, //<sb> + 2 for /Contents's hex string angles (i.e '<' and '>')
					length(after_sig) + bytes_range_padding + 10), //<sb> 3 bytes for the dictionary ending (i.e. "\n>>")
																	// + 7 bytes for "\nendobj"
		let remain := bytes_range_padding - length(bytes_range)
		in for i in (1 .. remain) princ(" "), //<sb> pads byte range
		printf("\n>>\nendobj"),
		//<sb> process sha1 document digest
		Openssl/sign_init(ctx),
		let s := make_string(1024, ' ')
		in while (fread(before_sig, s) > 0) Openssl/sign_update(ctx, s),
		let s := make_string(1024, ' ')
		in while (fread(bytes_range, s) > 0) Openssl/sign_update(ctx, s),
		let s := make_string(1024, ' ')
		in while (fread(after_sig, s) > 0) Openssl/sign_update(ctx, s),
		//<sb> flush what is before signature
		use_as_output(old),
		set_index(before_sig, 0),
		freadwrite(before_sig, old),
		//<sb> flush signature (sha1 digest signed with an RSA private key)
		printf("<~I>", //<sb> BER encoding of our signature 
			(let sig := Openssl/sign_final(ctx, self.private_key),
					digest := Openssl/string2hex(Openssl/i2d_octet_string(sig))
			in (princ(digest),
				let remain := contents_padding - length(digest)
				in for i in (1 .. remain) princ('0')))),
		//<sb> flush byte range
		set_index(bytes_range, 0),
		freadwrite(bytes_range, old),
		//<sb> flush what is after signature
		set_index(after_sig, 0),
		freadwrite(after_sig, old))]


[self_pdf(self:toc_entry) : void ->
	printf("\n~S 0 obj\n<<~I>>\nendobj", self.id,
		(let sub := self.subitems
		in (printf(" /Count ~S", (if known?(parentitem, self) 0 else length(sub))),
			if sub
				(printf("\n/First ~S 0 R", sub[1].id),
				printf("\n/Last ~S 0 R",  sub[length(sub)].id)),
			if known?(target, self)
				let s := element_to_string(self.target)
				in (if (length(s) > 0)
					(if not(self.root?)
						(printf(" /Dest [~S 0 R /XYZ null ~S null]",
									self.target.pageid,
									self.target.Ypage),
					printf("\n/Title (~I)", filter_pdf_string(s))))),
			if known?(parentitem, self)
				let psub := self.parentitem.subitems,
					plen := length(psub),
					idx := some(i in (1 .. plen)|psub[i] = self)
				in (printf("\n/Parent ~S 0 R", self.parentitem.id),
					if (idx > 1) printf(" /Prev ~S 0 R", psub[idx - 1].id),
					if (idx < plen) printf(" /Next ~S 0 R", psub[idx + 1].id)))))]


// *********************************************************************
// *   Part 7: html to pdf                                             *
// *********************************************************************


//<sb> iterate all operation's elements and print them.
// the order is important, an element appears on the top
// of previous elements in the list, i.e. the list is
// be ordered with container elements first followed by their
// content
[self_pdf(self:pdf_html_operation) : void ->
	for e in list{e in self.html_page_elements | not(e % html_annotation)}
		draw_background(e),
	for e in list{e in self.html_page_elements | not(e % html_annotation)}
		self_pdf(e),
	for e in list{e in self.html_page_elements | not(e % html_annotation)}
		draw_borders(e)] // draw borders after content, avoids render artifacts


//<sb> general rendering of a block element background
[draw_background(self:html_entity) : void -> none]
[draw_background(self:html_table_group) : void -> none]
[draw_background(self:html_placed_entity) : void -> none]
[draw_background(self:html_element_with_box) : void ->
	draw_background(self, self.X, self.Y, self.width, self.height)]


[draw_background(self:html_placed_block) : void ->
	draw_background(self.target, self.target.X, self.Y, self.target.width, self.height)]


[draw_background(self:html_entity, x:float, y:float, w:float, h:float) : void ->
	let bg := css_get(self, css_background-color)
	in (if (bg != css_white)
			(case bg
				(tuple
					let mtop := css_scaled_get(self, css_margin-top),
						mbottom := css_scaled_get(self, css_margin-bottom),
						mleft := css_scaled_get(self, css_margin-left),
						mright := css_scaled_get(self, css_margin-right)
					in printf(" q~I rg~I~I~I~I re f Q",
						self_pdf_color(bg),
						self_float(x + mleft),
						self_float(y - h + mbottom),
						self_float(w - mleft - mright),
						self_float(h - mtop - mbottom)))))]


[draw_border(bc:tuple, w:float, st:string, x1:float, y1:float, x2:float, y2:float) : void ->
	printf(" q~I RG~I w", self_pdf_color(bc), self_float(w)),
	case st
		({"dotted"} printf(" 1 J [0~I] 0 d", self_float(2. * w)),
		{"dashed"} printf(" 2 J [~I~I] 0 d", self_float(3. * w), self_float(3. * w)),
		any princ(" 2 J")),
	printf("~I~I m~I~I l S Q", self_float(x1), self_float(y1), self_float(x2), self_float(y2))]

[draw_borders(self:html_scalable_entity, x:float, y:float, w:float, h:float) : void ->
	let btop := css_scaled_get(self, css_border-top-width),
		bbottom := css_scaled_get(self, css_border-bottom-width),
		bleft := css_scaled_get(self, css_border-left-width),
		bright := css_scaled_get(self, css_border-right-width),
		stop := css_get(self, css_border-top-style) as string,
		sbottom := css_get(self, css_border-bottom-style) as string,
		sleft := css_get(self, css_border-left-style) as string,
		sright := css_get(self, css_border-right-style) as string,
		mtop := css_scaled_get(self, css_margin-top),
		mbottom := css_scaled_get(self, css_margin-bottom),
		mleft := css_scaled_get(self, css_margin-left),
		mright := css_scaled_get(self, css_margin-right)
	in (if (btop > 0. & stop != "none")
			draw_border(css_get(self, css_border-top-color) as tuple, btop, stop,
							x + mleft + 0.5 * btop, y - mtop - 0.5 * btop,
							x + w - mright - 0.5 * btop, y - mtop - 0.5 * btop),
		if (bbottom > 0. & sbottom != "none")
			draw_border(css_get(self, css_border-bottom-color) as tuple, bbottom, sbottom,
							x + mleft + 0.5 * bbottom, y - h + mbottom + 0.5 * bbottom,
							x + self.width - mright - 0.5 * bbottom, y - h + mbottom + 0.5 * bbottom),
		if (bleft > 0. & sleft != "none")
			draw_border(css_get(self, css_border-left-color) as tuple, bleft, sleft,
							x + mleft + 0.5 * bleft, y - mtop - 0.5 * bleft,
							x + mleft + 0.5 * bleft, y - h + mbottom + 0.5 * bleft),
		if (bright > 0. & sright != "none")
			draw_border(css_get(self, css_border-right-color) as tuple, bright, sright,
							x + w - mright - 0.5 * bright, y - mtop - 0.5 * bright,
							x + w - mright - 0.5 * bright, y - h + mbottom + 0.5 * bright))]


//<sb> general rendering of an element borders
[draw_borders(self:html_entity) : void -> none]
[draw_borders(self:html_table_group) : void -> none]
[draw_borders(self:html_placed_entity) : void -> none]
[draw_borders(self:html_element_with_box) : void ->
	draw_borders(self, self.X, self.Y, self.width, self.height)]
[draw_borders(self:html_placed_block) : void ->
	draw_borders(self.target as html_block_element, self.target.X, self.Y, self.target.width, self.height)]


//<sb> container, do nothing, however it may have borders/background
// drawn by above methods
[self_pdf(self:html_block_element) : void -> none]
[self_pdf(self:html_placed_block) : void -> none]

[self_pdf(self:html_inline_content) : void ->
	for line in self.lines self_pdf(line)]

[draw_underline(self:html_entity, x:float, y:float, w:float) : void ->
	let p := self,
		clr := unknown,
		set? := false
	in (while known?(hparent, p)
			(if (css_get(p, css_text-decoration) = "underline")
				(set? := true,
				clr := css_get(p, css_color)),
			if (p % html_block_element) break()
			else p := p.hparent),
		if set?
			let (underpos, thickness) :=
					get_underline_metrics(self.ref_doc, css_get_font(self),
											css_scaled_get(self, css_font-size))
			in printf(" q~I RG~I w~I~I m~I~I l S  Q",
						self_pdf_color(clr),
						self_float(thickness),
						self_float(x), self_float(y + underpos),
						self_float(x + w), self_float(y + underpos)))]

[self_pdf_word(prev:any, w:html_word_chunk) : void ->
	if (w.hparent % html_inline_element)
		draw_background(w, w.X, w.Y + w.ascender, w.width, w.height),
	draw_underline(w, w.X, w.Y, w.width),
	//[0] self_pdf_word(~S) // w.word,
	printf("~I BT 1 0 0 1~I~I Tm~I (~I ) Tj ET",
			printf("~I rg", self_pdf_color(css_get(w, css_color))),
			self_float(w.X),
			self_float(w.Y),
			printf(" /F~S~I Tf~I Tw",
						css_get_font(w),
						self_float(css_scaled_get(w, css_font-size)),
						self_float(w.scale * w.word_spacing)),
			filter_pdf_string(w.word)),
	if (w.hparent % html_inline_element)
		draw_borders(w, w.X, w.Y + w.ascender, w.width, w.height)]

[self_pdf_lazy(prev:any, w:html_lazy_element) : void ->
	draw_background(w, w.X, w.Y + w.ascender, w.width, w.height),
	draw_underline(w, w.X, w.Y, w.width),
	printf("~I BT 1 0 0 1~I~I Tm~I (~I ) Tj ET",
			printf("~I rg", self_pdf_color(css_get(w, css_color))),
			self_float(w.X),
			self_float(w.Y),
			printf(" /F~S~I Tf",
						css_get_font(w),
						self_float(css_scaled_get(w, css_font-size))),
			filter_pdf_string(w.index)),
	draw_borders(w, w.X, w.Y + w.ascender, w.width, w.height)]

[self_pdf_placed_word(prev:any, self:html_placed_word) : void ->
	let ww := self.target
	in (ww.Y := self.height,
		ww.X := self.X,
		case ww
			(html_lazy_element self_pdf_lazy(prev, ww),
			html_embeded_element self_pdf(ww),
			html_word_chunk self_pdf_word(prev, ww)))]

	
[self_pdf(self:html_line) : void ->
	let prev := unknown
	in for w in self.words
		(case w
			(html_lazy_element self_pdf_lazy(prev, w),
			html_embeded_element self_pdf(w),
			html_placed_word self_pdf_placed_word(prev, w),
			html_word_chunk self_pdf_word(prev, w)),
		prev := w)]

[self_pdf(self:html_placed_line) : void ->
	self_pdf(self.target as html_line)]


[self_pdf(self:html_background) : void ->
	let rect := Pdf/get_page_full_rect(self.ref_doc)
	in printf(" q~I 0 0~I~I~I cm /Im~S Do Q",
					self_float(width(rect)),
					self_float(height(rect)),
					self_float(0.0),
					self_float(0.0),
					self.src.imid)]


[self_pdf(self:html_img) : void ->
	let sb := self.scale * css_get_surrounding_bottom(self),
		sl := self.scale * css_get_surrounding_left(self),
		st := self.scale * css_get_surrounding_top(self),
		sr := self.scale * css_get_surrounding_right(self)
	in (;if (self.hparent % html_inline_element)
			draw_background(self, self.X, self.Y, self.width, self.height),
		printf(" q~I 0 0~I~I~I cm /Im~S Do Q",
					self_float(self.width - sb - st),
					self_float(self.height - sl - sr),
					self_float(self.X + sl),
					self_float(self.Y - self.height + sb),
					self.src.imid),
		;if (self.hparent % html_inline_element)
			draw_borders(self, self.X, self.Y, self.width, self.height))]

[self_pdf(self:html_xobject) : void ->
	;if (self.hparent % html_inline_element)
		draw_background(self, self.X, self.Y, self.width, self.height),
	let hxo := self.ref_xobject.src
	in printf(" q~I 0 0~I~I~I cm /XO~S Do Q",
			self_float(self.width / hxo.width),
			self_float(self.height / hxo.height),
			self_float(self.X),
			self_float(self.Y),
			self.ref_xobject.id),
	;if (self.hparent % html_inline_element)
		draw_borders(self, self.X, self.Y, self.width, self.height)]

[self_pdf(self:html_area) : void ->
	if (self.hparent % html_inline_element)
		draw_background(self, self.X, self.Y, self.width, self.height),
	let sleft := self.scale * css_get_surrounding_left(self),
		sbottom := self.scale * css_get_surrounding_bottom(self)
	in printf(" q ~I 0 0~I~I~I cm ~I Q",
			self_float(self.scale),
			self_float(self.scale),
			self_float(self.X + sleft),
			self_float(self.Y - self.height + sbottom),
			(for x in self.area_operations
				printf(" ~I", self_pdf(x)))),
	if (self.hparent % html_inline_element)
		draw_borders(self, self.X, self.Y, self.width, self.height)]


(interface(self_pdf))

