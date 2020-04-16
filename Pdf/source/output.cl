
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * output.cl                                                         *
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

[self_pdf(self:pdf_document) : void ->
	let xref := list<integer>(),
		sig := unknown,
		before_sig := port!(),
		after_sig := port!(),
		p := port!(),
		old := cout(),
		out := before_sig,
		pos := 16
	in (fwrite("%PDF-1.4\n%âãÏÓ\n", out),
		for o in self.objects
			case o
				(pdf_signature
					(sig := o,
					out := after_sig,
					fwrite("\n>>\nendobj\n", out)),
				any (set_length(p, 0),
					use_as_output(p),
					self_pdf(o),
					use_as_output(out),
					xref :add pos,
					pos :+ length(p),
					while not(eof?(p))
						princ(fread(p, 1024)))),
		printf("\nxref\n0 ~A\n0000000000 65535 f \n",length(xref) + 1),
		for i in xref
			let s := string!(i)
			in printf("~A~A 00000 n \n", substring("0000000000", 1, 10 - length(s)), s),
		printf("\ntrailer\n  << /Size ~S\n  /Root ~S 0 R\n  /Info ~S 0 R\n",
					length(xref) + 1,
					self.catalog.id,
					self.info.id),
		printf("  >>\nstartxref\n~S\n%%EOF\n", pos),
		use_as_output(old),
		if known?(sig) sign_pdf(sig, before_sig, after_sig)
		else
			(while not(eof?(before_sig))
				princ(fread(before_sig, 1024)),
			while not(eof?(after_sig))
				princ(fread(after_sig, 1024))))]

[self_pdf(self:pdf_catalog) : void ->
	printf("\n~S 0 obj\n<<\n", self.id),
	printf("  /Type /Catalog\n"),
	printf("  /Pages ~S 0 R\n", self.page_tree_root.id),
	if known?(acro_form, self)
		printf("  /AcroForm ~S 0 R\n", self.acro_form.id),
	when toc := some(x in self.doc.objects|x % toc_entry)
	in (printf("  /Outlines ~S 0 R\n", toc.id),
		printf("  /PageMode /UseOutlines\n")),
	princ(">>\nendobj\n")]

[self_pdf(self:pdf_page_tree) : void ->
	printf("\n~S 0 obj\n<< /Type /Pages\n/Kids [", self.id),
	//for o in self.ref_catalog.sections
	//	printf("~S 0 R\n", o.id),
	for t in self.doc.section_order
		printf("~S 0 R\n", t[2].id),
	let n := 0
	in (for i in list{x in self.doc.objects|x % pdf_page} n :+ 1,
		printf("]\n/Count ~S", n),
	princ("\n>>\nendobj\n"))]

[self_pdf(self:pdf_info) : void ->
	printf("\n~S 0 obj\n<<\n", self.id),
	printf("  /Producer (Claire v~A, module Pdf ~A)\n", release(), get(version, Pdf)),
	printf("  /CreationDate (D:~A)\n", strftime("%Y%m%d",self.doc.creation_date)),
	if known?(title, self)
		printf("  /Title (~A)\n", self.title),
	princ(">>\nendobj\n")]

// *********************************************************************
// *   Part 2: page                                                    *
// *********************************************************************

[self_pdf(self:pdf_section) : void ->
	printf("\n~S 0 obj\n<< /Type /Pages", self.id),
	let n := 0, imageC? := false
	in (printf("\n/Parent ~A 0 R", self.section_root.page_tree_root.id),
		printf("\n/Kids ["),
		for o in self.kids
			(printf("~S 0 R\n", o.id), n :+ 1),
		printf("]\n/Count ~S", n),
		printf("\n/Resources << ~I >>",
			(let l := list{p in self.doc.objects|p % pdf_font}
			in (if l printf("\n/Font << ~I >>",
							for o in l
									printf("\n/F~S ~S 0 R", o.fontnum, o.id))),
			let l := list{p in self.doc.objects|p % pdf_extgstate}
			in (if l printf("\n/ExtGState << ~I >>",
							for o in l
									printf("\n/GS~S ~S 0 R", o.id, o.id))),
			let l := list{p in self.doc.objects|p % pdf_image}
			in (imageC? := true,
				if l printf("\n/XObject << ~I >>",
							for o in l
									printf("\n/I~S ~S 0 R", o.imid, o.id))))),
		let l := self.dim
		in printf("\n/MediaBox [~S ~S ~S ~S]", l.left, l.bottom, l.right, l.top),
		printf("\n/Procset [/PDF /text~I]", (if imageC? princ(" /ImageC"))),
		princ("\n>>\nendobj\n"))]

[self_pdf(self:pdf_page) : void ->
	printf("\n~S 0 obj\n<< /Type /Page", self.id),
	printf("\n/Parent ~A 0 R", self.parent.id),
	if self.contents
		(printf("\n/Contents ["),
		for o in self.contents
			printf("  \n~S 0 R", o.id),
		printf("\n]")),
	if self.annots
		(printf("\n/Annots ["),
		for o in self.annots
			printf("  \n~S 0 R", o.id),
		printf("\n]")),
	princ("\n>>\nendobj\n")]

[self_pdf(self:pdf_font) : void ->
	printf("\n~S 0 obj\n<< /Type /Font", self.id),
	printf("\n/Subtype /Type1"),
	printf("\n/Name /F~S", self.fontnum),
	printf("\n/BaseFont /~A", self.font.FontName),
	printf("\n/Encoding /WinAnsiEncoding"),
	princ("\n>>\nendobj\n")]


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
	printf("\n~I /Length ~S ",
		(if self.deflate? printf(" /Filter /FlateDecode")),
		length(self.streambuf)),
	printf(">>\nstream\n~I",
			while not(eof?(self.streambuf))
				princ(fread(self.streambuf, 1024))),
	princ("\nendstream"),
	fclose(self.streambuf)]

[self_pdf(self:pdf_content) : void ->
	printf("\n~S 0 obj\n<<~I~I~I\nendobj\n",
		self.id,
		begin_stream(self.doc),
		for x in list{o in self.operations | not(o.inside_html_area?)}
			printf(" ~I", self_pdf(x)),
		end_stream(self.doc))]


// *********************************************************************
// *   Part 3: annotation                                              *
// *********************************************************************

[self_pdf(self:pdf_file_attachment) : void ->
	printf("\n~S 0 obj\n<< /Type /Annot\n/Subtype /FileAttachment", self.id),
	princ("\n/Rect [0 0 0 0]"),
	printf("\n/Contents (~I)", filter_pdf_string(self.content)),
//	printf("\n/Name /~A", self.name),
	printf("\n/FS << /Type /Filespec /F (~I)", filter_pdf_string(self.content)),
	printf("\n/EF << /F ~S 0 R >> >>", self.embeddedfile.id),
	princ("\n>>\nendobj\n")]

[self_pdf(self:pdf_embedded_file) : void ->
	printf("\n~S 0 obj\n<< /Type /EmbeddedFile", self.id),
	printf("\n/Subtype /~I", print_string_to_pdf_name(self.mimetype)),
	if known?(filepath, self)
		(printf("\n/Params <<"),
		printf("\n  /Size ~A", integer!(fsize(self.filepath))),
		printf("\n  /CreationDate (D:~A)", strftime("%Y%m%d",fchanged(self.filepath))),
		printf("\n  /ModDate (D:~A)", strftime("%Y%m%d",fmodified(self.filepath))),
		printf(" >>"),
		begin_stream(self.doc),
		let f := fopen(self.filepath,"rb")
		in (while not(eof?(f)) princ(fread(f,1024)),
			fclose(f)),
		end_stream(self.doc))
	else
		(printf("\n/Params <<"),
		let f := port!()
		in (fill_attachment(self.userdata, f),
			printf("\n  /Size ~A", length(f)),
			printf("\n  /CreationDate (D:~A)", strftime("%Y%m%d",self.doc.creation_date)),
			printf("\n  /ModDate (D:~A)", strftime("%Y%m%d",self.doc.creation_date)),
			printf(" >>"),
			begin_stream(self.doc),
			while not(eof?(f)) princ(fread(f,1024)),
			fclose(f),
			end_stream(self.doc))),
	printf("\nendobj\n")]


[self_pdf(self:pdf_widget) : void ->
	printf("\n~S 0 obj\n<< /Type /Annot", self.id),
	printf("\n/Subtype /Widget"),
	printf("\n/Rect [ 0 0 0 0 ]"), 
	printf("\n/M (D:~A)", strftime("%Y%m%d",self.doc.creation_date)),
	printf("\n/P ~S 0 R ", self.wpage.id),
	printf("\n/Parent ~S 0 R ", self.wparent.id),
	printf("\n>>\nendobj\n")]


// *********************************************************************
// *   Part 4: graphic operations                                      *
// *********************************************************************


[self_pdf(self:pdf_moveto) : void -> printf("~S ~S m", self.x, self.y)]
[self_pdf(self:pdf_begin_text) : void ->
	if (self.angle = 0.0)
		printf("BT ~S ~S Td", self.x, self.y)
	else let a := self.angle, ca := cos(a), sa := sin(a)
		in printf("BT ~S ~S ~S ~S ~S ~S Tm", ca, -(sa), sa, ca, self.x, self.y)]
[self_pdf(self:pdf_show_text) : void -> printf("(~I) Tj", filter_pdf_string(self.text))]
[self_pdf(self:pdf_end_text) : void -> printf("ET")]
[self_pdf(self:pdf_select_font) : void -> printf("/F~S ~S Tf", self.fontnum, self.fontsize)]
[self_pdf(self:pdf_color) : void -> printf("~S ~S ~S rg", self.r, self.g, self.b)]
[self_pdf(self:pdf_alpha) : void -> printf("/GS~S gs", self.extgstate.id)]
[self_pdf(self:pdf_stroke_color) : void -> printf("~S ~S ~S RG", self.r, self.g, self.b)]
[self_pdf(self:pdf_begin_path) : void -> printf("~S ~S m", self.x, self.y)]
[self_pdf(self:pdf_lineto) : void -> printf("~S ~S l", self.x, self.y)]
[self_pdf(self:pdf_end_path) : void -> princ(self.endop)]

[self_pdf(self:pdf_extgstate) : void ->
	printf("\n~S 0 obj\n<< /Type /ExtGState /ca ~S >>\nendobj\n", self.id, self.opacity)]

[self_pdf(self:pdf_push_state) : void -> printf("q")]
[self_pdf(self:pdf_pop_state) : void -> printf("Q")]
[self_pdf(self:pdf_set_matrix) : void ->
	printf("~S ~S ~S ~S ~S ~S cm",
			self._a, self._b, self._c, self._d, self._e, self._f)]

[self_pdf(self:pdf_line_width) : void -> printf("~S w", self.w)]
[self_pdf(self:pdf_line_join) : void -> printf("~S j", self.m)]
[self_pdf(self:pdf_line_cap) : void -> printf("~S J", self.m)]
[self_pdf(self:pdf_line_dash) : void ->
	if (self.dashon = 0 & self.dashoff = 0)
		printf("[] ~S d", self.dashphase)
	else if (self.dashoff = 0)
		printf("[~S] ~S d", self.dashon, self.dashphase)
	else printf("[~S ~S] ~S d", self.dashon, self.dashoff, self.dashphase)]


// *********************************************************************
// *   Part 5: images                                                  *
// *********************************************************************

[self_pdf(self:pdf_image_colorspace) : void ->
	printf("\n~S 0 obj\n<< /Length ~S >>\nstream\n~A\nendstream\nendobj\n",
		self.id,
		length(self.spdata),
		self.spdata)]

[self_pdf(self:pdf_png) : void ->
	printf("\n~S 0 obj\n<< /Type /XObject", self.id),
	printf("\n/Subtype /Image"),
	printf("\n/Filter /FlateDecode"),
	printf("\n/Width ~S\n/Height ~S", integer!(self.imwidth), integer!(self.imheight)),
	printf("\n/DecodeParms << /Predictor 15 /Colors ~S /Columns ~S /BitsPerComponent ~A >>",
				self.ncolor, integer!(self.imwidth), self.bitdepth),
	let x := self.colorspace,
		len := length(x.spdata)
	in (if (len > 0)
			(printf("\n/ColorSpace [ /Indexed /DeviceRGB ~S ~S 0 R ]", len / 3 - 1, x.id),
			if (self.t_type = "indexed")
				printf("\n/Mask [ ~S ~S ]", self.t_data, self.t_data))
		else printf("\n/ColorSpace /~A", self.colorspace.space)),
	printf("\n/BitsPerComponent ~A", self.bitdepth),
	printf("\n/Length ~S >>", length(self.pngdata)),
	printf("\nstream\n~A\nendstream\nendobj\n", self.pngdata)]

[self_pdf(self:pdf_image_show) : void ->
	printf("\nq\n~S 0 0 ~S ~S ~S cm\n/I~S Do\nQ\n",
			self.imwidth, self.imheight,
			self.imx, self.imy,
			self.im.imid)]

// *********************************************************************
// *   Part 6: interactive form                                        *
// *********************************************************************

[self_pdf(self:pdf_interactive_form) : void ->
	printf("\n~S 0 obj\n<< /Fields [~I]\n /SigFlags ~S >>\nendobj\n",
				self.id,
				(for x in self.fields
					printf(" ~S 0 R", x.id)),
				self.sig_flags)]


[self_pdf(self:pdf_sigtnature_field) : void ->
	printf("\n~S 0 obj\n<<", self.id),
	printf("\n/FT /Sig"),
	printf("\n/T (Signature~S)", self.id),
	printf("\n/Kids [ ~S 0 R ]", self.widget.id),
	printf("\n/V ~S 0 R", self.signature.id),
	printf("\n>>\nendobj\n")]

[sign_pdf(self:pdf_signature, before_sig:port, after_sig:port) : void ->
/*	let old := use_as_output(before_sig),
		bytes_range := port!(),
		contents_padding := 140,
		bytes_range_padding := 50
	in (printf("\n~S 0 obj\n<<", self.id),
		printf("\n/Type /Sig"),
		printf("\n/Name (~I)", filter_pdf_string(self.name)),
		printf("\n/Reason (~I)", filter_pdf_string(self.reason)),
		printf("\n/Filter /Adobe.PPKLite"),
		printf("\n/M (D:~A)", strftime("%Y%m%d",self.doc.creation_date)),
		printf("\n/ADBE_PwdTime 8"),
		printf("\n/SubFilter /adbe.x509.rsa_sha1"),
		printf("\n/Cert (~I)", filter_pdf_string(Openssl/i2d(self.certificate))),
		//printf("\n/Cert (~A)", Openssl/i2d(self.certificate)), // X509 to DER format
		printf("\n/Contents "),
		use_as_output(bytes_range),
		printf("\n/ByteRange [0 ~S ~S ~S]",
					length(before_sig),
					length(before_sig) + contents_padding + 2,
					length(after_sig) + bytes_range_padding),
		let remain := bytes_range_padding - length(bytes_range)
		in for i in (1 .. remain) putc(' ', bytes_range),
		let ctx := Openssl/digest_context!("sha1")
		in (Openssl/sign_init(ctx),
			// update digest
			while not(eof?(before_sig))
				Openssl/sign_update(ctx, fread(before_sig, 1024)),
			while not(eof?(bytes_range))
				Openssl/sign_update(ctx, fread(bytes_range, 1024)),
			while not(eof?(after_sig))
				Openssl/sign_update(ctx, fread(after_sig, 1024)),
			// flush what is before signature
			use_as_output(old),
			set_index(before_sig,0),
			while not(eof?(before_sig))
				princ(fread(before_sig, 1024)),
			// flush signature 
			printf("<~I>",
			(let digest := Openssl/string2hex(
							Openssl/sign_final(ctx, self.private_key))
			in (princ(digest),
				let remain := contents_padding - length(digest)
				in for i in (1 .. remain) princ('0')))),
			// flush byte range
			set_index(bytes_range,0),
			while not(eof?(bytes_range))
				princ(fread(bytes_range, 1024)),
			// flush what is after signature
			set_index(after_sig,0),
			while not(eof?(after_sig))
				princ(fread(after_sig, 1024))))]*/ none]



[self_pdf(self:toc_entry) : void ->
	printf("\n~S 0 obj\n<<~I\n>>", self.id,
		(let sub := self.subitems
		in (printf("\n/Count ~S", (if known?(parentitem, self) 0 else length(sub))),
			if sub
				(printf("\n/First ~S 0 R", sub[1].id),
				printf("\n/Last ~S 0 R",  sub[length(sub)].id)),
			if known?(target, self)
				let s := element_to_string(self.target)
				in (if (length(s) > 0)
					(if not(self.root?)
						(printf("\n/Dest [ ~S 0 R /XYZ null ~S null ]",
									get_page_id(self.target),
									self.target.Y),
					printf("\n/Title (~I)", filter_pdf_string(s))))),
			if known?(parentitem, self)
				let psub := self.parentitem.subitems,
					plen := length(psub),
					idx := some(i in (1 .. plen)|psub[i] = self)
				in (printf("\n/Parent ~S 0 R", self.parentitem.id),
					if (idx > 1) printf("\n/Prev ~S 0 R", psub[idx - 1].id),
					if (idx < plen) printf("\n/Next ~S 0 R", psub[idx + 1].id)))))]


// *********************************************************************
// *   Part 7: html to pdf                                             *
// *********************************************************************


[self_pdf(self:tuple(float,float,float)) : void ->
	printf(" ~S ~S ~S", self[1], self[2], self[3])]

[self_pdf(self:pdf_html_operation) : void -> self_pdf(self.root)]


[align_parent(self:html_element) : void ->
	let H := 0.0,
		p := self.hparent,
		l := p.hchildren,
		Xalign := 0.0,
		Yalign := 0.0,
		st := self.style
	in (for x in l H :+ x.height,
		case st.align
			({A_CENTER} Xalign := (p.width - self.width) / 2.,
			{A_RIGHT} Xalign := (p.width - self.width)),
		case st.valign
			({A_CENTER} Yalign := (p.height - H) / -2.,
			{A_BOTTOM} Yalign := -(self.hparent.height - H)),
		if (Xalign != 0.0 | Yalign != 0.0)
			printf(" 1 0 0 1 ~S ~S cm", Xalign, Yalign),
		if (st.angle != 0.)
			let a := st.angle, ca := cos(a), sa := sin(a)
			in printf(" ~S ~S ~S ~S ~S ~S cm 1 0 0 1 ~S ~S cm",
						ca, -(sa), sa, ca, self.width / 2., self.height / 2.,
						-(self.width / 2.), -(self.height / 2.))
		)]

[html2pdf(self:html_element) : void ->
	printf(" q~I~I Q",
			(case self
				(html_td none,
				html_tr none,
				any align_parent(self))),
			self_pdf(self))]


[self_pdf(self:html_element) : void ->
	for x in self.hchildren
		(html2pdf(x),
		if (x.height != 0.0)
			printf(" 1 0 0 1 0 ~S cm", -(x.height)))]

[self_pdf(self:html_area) : void ->
	printf(" q 1 0 0 1 0 ~S cm ~I Q",
		-(self.height),
		(for x in self.area_operations
			printf(" ~I", self_pdf(x))))]

[self_pdf(self:html_hr) : void ->
	printf(" q~I RG ~S w 0 0 m ~S 0 l S Q", 
		self_pdf(self.style.bordercolor),
		self.style.height,
		self.width)]

[self_pdf(self:html_bullet) : void ->
	let half := self.width / 2.,
		quater := self.width / 4.
	in printf(" q~I rg  1 0 0 1 0 ~S cm 0 ~S m ~S ~S l 0 ~S l f Q", 
		self_pdf(self.style.textcolor),
		-(quater),
		-(quater),
		self.width,
		-(self.width / 2.),
		-(self.width) + quater)]

[self_pdf(self:html_document) : void ->
	printf("\nq 1 0 0 1 ~S ~S cm ~I Q\n", self.xstart, self.ystart,
		self_pdf@html_element(self))]

[self_pdf(self:html_blockquote) : void ->
	printf("\nq 1 0 0 1 ~S 0 cm ~I Q\n", self.xoffset,
		(self.width :- self.xoffset,
		self_pdf@html_element(self)))]


[self_pdf(self:html_text_line) : void ->
	let h := 0.0, wp := self.width, s := self.style
	in for line in (1 .. self.nlines)
		printf(" q 0 0 0 RG 1 0 0 1 ~S ~S cm ~I Q ",
			(case self.style.align
				({A_CENTER} (wp - self.widthlines[line]) / 2.,
				{A_RIGHT} wp - self.widthlines[line],
				any 0.)),						
			-(self.baselines[line] + h),
			(let first? := true, x := 0.0, prev := unknown
			in for w in self.lines[line]
					(if first? first? := false
					else x :+ w.wspace,
					case w
						(html_img
							printf(" q ~S 0 0 ~S ~S 0 cm /I~S Do Q", w.width, w.height, x, w.src.imid),
						any
							let st := w.style
							in printf(" q 1 0 0 1 ~S 0 cm~I rg~I BT /F~S ~S Tf (~I ) Tj ET Q",
										x, self_pdf(st.textcolor),
										(if st.underlined?
											let (dy, th) := get_underline_metrics(self.ref_doc, st.fontnum, st.fontsize)
											in let dw := 0.
											in (if (known?(prev) & prev.style.underlined?)
													dw := w.wspace,
												printf(" q~I RG ~S w ~S ~S m ~S ~S l S Q",
														self_pdf(st.textcolor),
														th, -(dw), dy, w.width, dy))),
										st.fontnum, st.fontsize,
										filter_pdf_string(w.word))),
					prev := w,
					x :+ w.width),
			h :+ self.heightlines[line]))]


[self_pdf(self:html_table) : void ->
	let m := self.cell_map,
		s := self.style,
		WHITE := tuple(1.,1.,1.),
		BORDER := s.border,
		PADING := s.cellpadding,
		SPACING := s.cellspacing,
		padding*2 := PADING * 2.,
		border*2 :=  BORDER * 2.,
		border_half :=  BORDER / 2.
	in (if (self.scale != 1.0) //<sb> the table should be scaled
			printf(" q ~S 0 0 ~S 0 0 cm", self.scale, self.scale),
		if (BORDER > 0.0) //<sb> draw table's border
			(printf(" 1 0 0 1 ~S ~S cm", border_half, -(border_half)),
			printf("\n~I RG ~I rg ~S w 0 ~S ~S ~S re ~A",
						self_pdf(s.bordercolor), self_pdf(s.bgcolor), BORDER,
						-(self.height / self.scale - BORDER),
						self.width / self.scale  - BORDER,
						self.height / self.scale  - BORDER,
						(if (s.bgcolor = WHITE) "S" // stroke
						else "B")),
			printf(" 1 0 0 1 ~S ~S cm", border_half, -(border_half))),
		for r in (1 .. self.nrows)
			let maxheight := 0.0
			in (if (SPACING > 0.0) printf(" 1 0 0 1 0 ~S cm", -(SPACING)),
				princ(" q"),
				if (BORDER > 0.0) printf(" 1 0 0 1 0 ~S cm", -(border_half)),
				
				for c in (1 .. self.ncols)
					when td := m[r, c]
					in let s := td.style
					in (if (td != m[r - 1, c] & td != m[r, c - 1])
							(if (SPACING > 0.0)
								printf(" 1 0 0 1 ~S 0 cm", SPACING),
							if (BORDER > 0.0)
								printf(" 1 0 0 1 ~S 0 cm", border_half),
							if (c > 1 & m[r - 1, c - 1] = m[r, c - 1] & m[r, c - 1].rowspan > 1)
								printf(" 1 0 0 1 ~S 0 cm",
										SPACING + padding*2 +
										2. * BORDER + m[r, c - 1].width),
							princ(" q"),
							if (BORDER > 0.0)  //<sb> draw cell's border
								printf("~I RG~I rg ~S w 0 ~S ~S ~S re ~A",
										self_pdf(s.bordercolor), self_pdf(s.bgcolor), BORDER,
										-(td.height + padding*2 + BORDER),
										td.width + padding*2 + BORDER,
										td.height + padding*2 + BORDER,
										(if (s.bgcolor = WHITE) "S" // stroke
										else "B")),
							
							if (BORDER > 0.0)
								printf(" 1 0 0 1 ~S ~S cm", border_half, -(border_half)),
							
							if (PADING > 0.0)
								printf(" 1 0 0 1 ~S ~S cm", PADING, -(PADING)),

							printf(" ~I Q 1 0 0 1 ~S 0 cm", html2pdf(td),
									td.width + padding*2 + BORDER + border_half),
							if (td.rowspan = 1)
								maxheight :max td.height)),
				printf(" Q 1 0 0 1 0 ~S cm", -(maxheight + padding*2 + 2. * BORDER)))),
	if (self.scale != 1.0) //<sb> the table should be scaled
			printf(" Q")]










