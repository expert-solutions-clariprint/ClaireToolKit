
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * html.cl                                                           *
// * Copyright (C) 2000 - 2004 xl. All Rights Reserved                 *
// *********************************************************************


// @cat Design consideration
// This module embeds an HTML/CSS engine used to submit a content in a stream
// oriented way. Only a subset of specified HTML elements are implemented and some,
// unspecified, have been added for convenience in describing interactive
// PDF features such as annotations or signature. The goal here is to use
// this Pdf module in combination with Wcl syntax such to describe any layout/style
// information in the HTML/CSS languages that have shown to be very concise.\br

// The conversion (HTML > PDF) is achieved with an auto-lay-outing algorithm based on
// RFC1942. Computed boxes are converted in simple PDF graphic operations
// affected to PDF pages using a page-break algorithm (as would do a web
// browser when processing an HTML page for a printer device).\br

// The dictionary of understood HTML elements may be extended by
// defining substitution handlers for new elements. The description of new
// elements is done in HTML and would rely on simpler elements.\br
// @cat



// *********************************************************************
// *   Part 1: DOM model                                               *
// *********************************************************************

html_attribute <: ephemeral_object(
	attr_name:string,
	attr_value:string,
	next:html_attribute)

html_placed_entity <: ephemeral_object


html_entity <: ephemeral_object(
		//<sb> layout
		ref_doc:pdf_document,
		hparent:html_element)

	html_line <: html_entity(
			words:list[ephemeral_object],
			lineheight:float,
			baseline:float,
			width:float,
			X:float,
			Y:float,
			last?:boolean = false)

	html_basic_word <: html_entity(word:string)
	
	html_scalable_entity <: html_entity(
		scale:float = 1.)


		html_word_chunk <: html_scalable_entity(
				X:float,
				Y:float, // baseline
				width:float,
				height:float,
				ascender:float,
				word:string,
				space_count:integer = 0,
				word_spacing:float)

		html_space <: html_word_chunk()

	html_inline_content <: html_entity(
			last_space:html_space,
			onspace?:boolean = false,
			height:float,
			lines:list[html_line])


		// named element
		html_element <: html_scalable_entity(
				element_name:string,
				target_section:pdf_section,
				style:css_styler,
				attr_list:html_attribute,
				hchildren:list[html_entity])

		html_br <: html_element()

		html_inline_element <: html_element()

			html_a <: html_inline_element(curlink:pdf_html_link, pageid:integer, Ypage:float)
			html_u <: html_inline_element()
			html_b <: html_inline_element()
			html_i <: html_inline_element()
			html_em <: html_inline_element()
			html_sup <: html_inline_element()
			html_sub <: html_inline_element()
			html_font <: html_inline_element()
			html_span <: html_inline_element()
			
			html_pseudo_element <: html_inline_element()
			
		html_element_with_box <: html_element(
				width:float,
				height:float,
				X:float,
				Y:float) // top

			html_block_element <: html_element_with_box(
					minwidth:float,
					maxwidth:float,
					placed?:boolean = false)

				html_document <: html_block_element()

				html_p <: html_block_element()
				html_center <: html_block_element()
				html_code <: html_block_element()
				html_blockquote <: html_block_element()
				html_hr <: html_block_element()
				html_h <: html_block_element(level:(1 .. 6), pageid:integer, Ypage:float)
				
				html_div <: html_block_element()
				
				html_li <: html_block_element()
				html_list_container <: html_block_element()
					html_ul <: html_list_container()
					html_ol <: html_list_container()

				html_dl <: html_block_element()
				html_dt <: html_block_element()
				html_dd <: html_block_element()
			

				html_table_group <: html_block_element()

					html_thead <: html_table_group()
					html_tfoot <: html_table_group()
					html_tbody <: html_table_group()
					html_tr <: html_table_group(group:html_table_group)

				html_td <: html_block_element(
						colspan:integer = 1,
						rowspan:integer = 1,
						col:integer,
						row:integer)
					
						html_th <: html_td()

				html_table <: html_block_element(
						thead:html_thead,
						tbody:html_tbody,
						body_groups:list[html_table_group],
						tfoot:html_tfoot,
						nrows:integer = 0,
						ncols:integer = 0,
						col:integer = 0,
						row:integer = 0,
						mincolwidths:list[float],
						maxcolwidths:list[float],
						td_matrix:list[list[html_td]])

			html_appearance <: html_block_element(ref_xobject:pdf_form_xobject)
			html_annotation <: html_block_element(
					placedbox:html_placed_entity,
					normal:html_appearance,
					rollover:html_appearance,
					down:html_appearance,
					ref_annot:pdf_annot)

				html_attachment <: html_annotation()
				html_widget <: html_annotation()
					html_signature <: html_widget()

		html_embeded_element <: html_element_with_box(ascender:float)

			html_img <: html_embeded_element(src:pdf_image)
			html_background  <: html_img()
			html_xobject <: html_embeded_element(ref_xobject:pdf_form_xobject)
			
			html_lazy_element <: html_embeded_element(index:string)
				html_pagenum <: html_lazy_element()
				html_pagecount <: html_lazy_element()
				html_pageof <: html_lazy_element(target:html_element)

			html_area <: html_embeded_element(
					userdata:any,
					area_operations:list[pdf_graphic_operation])
				html_bullet <: html_area(bullet_type:string)			

		element_context <: ephemeral_object
		html_substitution <: html_inline_element(
			context:element_context)

	html_placed_entity <: ephemeral_object(target:html_entity, height:float)

		html_placed_line <: html_placed_entity()
		html_placed_word <: html_placed_entity(X:float)
		html_placed_block <: html_placed_entity(Y:float, add_footer?:boolean = true)


[self_print(self:html_element) : void ->
	printf("<~S>", get(element_name, self))]

[self_print(self:html_line) : void ->
	printf("<line:~S ~I>",
		self.X,
		(for w in self.words print(w)))]


[self_print(self:html_basic_word) : void ->
	printf("<~S:~S>", get(element_name, self.hparent), self.word)]

[self_print(self:html_word_chunk) : void ->
	printf("<~S:~S:~S>", get(element_name, self.hparent), self.X, self.word)]

[self_print(self:html_placed_word) : void ->
	printf("<<~S:~S:~S>>", get(element_name, self.target.hparent), self.X, self.target.word)]


[self_print(self:html_space) : void ->
	printf("<~S:space>", get(element_name, self.hparent))]

[self_print(self:html_embeded_element) : void ->
	printf("<~S:~S>", get(element_name, self.hparent), get(element_name, self))]

[get_html_document(self:html_entity) : html_document ->
	case self
		(html_document self,
		any doc_of_element(self.hparent))]

[rm_last_empty_inline_content(self:pdf_document) : void ->
	when inl := get(last_inline_content, self)
	in (if not(inl.lines[1].words)
			(inl.hparent.hchildren delete inl,
			erase(last_inline_content, self)))]

[nth(self:html_element, n:integer) : html_entity => self.hchildren[n]]

[nth(self:html_element, attr:string) : (string U {unknown}) ->
	when att := get(attr_list, self)
	in (let val:(string U {unknown}) := unknown
		in (while true
				(if (att.attr_name = attr) (val := att.attr_value, break())
				else if unknown?(next, att) break()
				else att := att.next),
			val))
	else unknown]

[nth=(self:html_element, attr:string, val:string) : void ->
	if unknown?(attr_list, self)
		self.attr_list := html_attribute(attr_name = attr, attr_value = val)
	else let cur := self.attr_list
		in (while known?(next, cur) cur := cur.next,
			cur.next := html_attribute(attr_name = attr, attr_value = val))]


CURRENT_XOBJECT:any := unknown

[pdf_html_link!(self:html_entity, h:string) : pdf_html_link ->
	pdf_html_link(doc = self.ref_doc, href = h)]


[close(self:html_entity) : html_entity ->
	if known?(hparent, self)
		let p := self.hparent
		in (self.ref_doc := p.ref_doc,
			case self
				(html_embeded_element none,
				html_element
					(while (p % html_inline_element)
						p := p.hparent,
					p.hchildren add self),
				html_inline_content
					(rm_last_empty_inline_content(self.ref_doc),
					self.hparent.hchildren add self,
					self.ref_doc.last_inline_content := self)),
			if (self % html_block_element)
				rm_last_empty_inline_content(self.ref_doc)),
	if (self % html_element)
		self.target_section := self.ref_doc.catalog.current_section,
	self]


[add_pseudo_content(self:html_pseudo_element, ct:list) : void ->
	for x in ct
		case x
			(css_string html_text!(self, x.value),
			css_counter_reference html_text!(self, get_counter_value(self, x)),
			string
				let area := html_bullet(hparent = self,
										bullet_type = x,
										element_name = "bullet")
				in (embeded_element!(area),
					area.userdata := area))]


[add_pseudo_before(self:html_element) : void ->
	let ps := html_pseudo_element(hparent = self,
						element_name = self.element_name /+ ":before")
	in (build_css_styler(self.ref_doc.style_sheet, ps),
		if known?(style, ps)
			let ct := css_get(ps, css_content)
			in (case ct
					(list add_pseudo_content(ps, ct),
					any self.hchildren delete ps))
		else self.hchildren delete ps)]

[add_pseudo_after(self:html_element) : void ->
	let ps := html_pseudo_element(hparent = self,
						element_name = self.element_name /+ ":after")
	in (build_css_styler(self.ref_doc.style_sheet, ps),
		if known?(style, ps)
			let ct := css_get(ps, css_content)
			in (case ct
					(list add_pseudo_content(ps, ct),
					any self.hchildren delete ps))
		else self.hchildren delete ps)]

[get_height(self:html_entity) : float ->
	case self
		(html_word_chunk self.height,
		html_element_with_box self.height,
		html_inline_content self.height,
		html_inline_element
			let h := 0.
			in (for e in self.hchildren
					h :+ get_height(e),
				h),
		html_entity
			get_height(self.hparent))]


[get_y_top(self:html_entity) : float ->
	case self
		(html_word_chunk
			self.Y + self.ascender,
		html_element_with_box
			self.Y,
		html_inline_element
			let top := -(self.ref_doc.catalog.current_section.dim.top)
			in (for e in self.hchildren
					top :max get_y_top(e),
				if (top = 0.) get_y_top(self.hparent)
				else top),
		html_entity
			get_y_top(self.hparent))]

[get_y_bottom(self:html_entity) : float ->
	case self
		(html_word_chunk
			self.Y + self.ascender - self.height,
		html_element_with_box
			self.Y - self.height,
		html_inline_element
			let top := 0.0
			in (for e in self.hchildren
					top :min get_y_bottom(e),
				if (top = 0.) get_y_bottom(self.hparent)
				else top),
		html_entity
			get_y_bottom(self.hparent))]


// *********************************************************************
// *   Part 2: sax html parser                                         *
// *********************************************************************

// @cat User area element
// @alias area areas
// Our HTML dialect understand the special area element. An area element
// is defined by either a tuple (name, value) or user object. Areas are used
// as owner-draw boxes, a callback (fill_area restriction) is responsible to
// draw the area content :
// \code
// (print_in_html(doc)
//  ?><area name="my_area" value="my_area_value" /><?
// end_of_html(doc))
// \/code
// Or with a custom user data :
// \code
// my_data_class <: ephemeral_object()
// DATA :: my_data_class()
//
// (print_in_html(doc)
// 	?><area userdata="<?oid DATA ?>" /><?
// end_of_html(doc))
// \/code
// A fill_area restriction should be defined by the user with
// an appropriate domain and would contain drawing operations (using the
// low level API) for the area content :
// \code
// Pdf/fill_area(self:pdf_document, val:{"my_area"}, val:{"my_area_value"}, wdth:float, hght:float) ->
// 	...
// \/code
// Or for an area having a user data :
// \code
// Pdf/fill_area(self:pdf_document, userdata:my_data_class, wdth:float, hght:float) ->
// 	...
// \/code
// When the fill_area callback is applied the transformation matrix is defined such
// the area lower left is the current origin. Additionally a
// fill_area restriction takes the width and the height of the lay-outed box.
// We may, for instance, define a fill_area callback that fills the area box with a blue
// rectangle :
// \code
// Pdf/fill_area(self:pdf_document, userdata:my_data_class, wdth:float, hght:float) ->
// 	stroked_rectangle(self, rectangle!(0., hght, wdth, 0.), 1., "blue")
// \/code
// As for any element the width and the height is inferred by the layout algorithm unless
// the area element contains a width or height attribute.\br
// Here is a complete sample that draws an area two times in boxes that will be lay-outed
// differently :
// creates a new document, a section and a page
// \code
// doc :: Pdf/document!()
// 
// // userdata used for the fill_area callback
// my_data_class <: ephemeral_object()
// DATA :: my_data_class()
// 
// Pdf/fill_area(self:pdf_document, userdata:my_data_class, wdth:float, hght:float) ->
//      filled_rectangle(self, rectangle!(0., hght, wdth, 0.), "blue")
// 
// // use our area in the main HTML stream
// (print_in_html(doc)
// ?><area userdata="<?oid DATA ?>" />
// <table border=1>
// 	<tr>
// 		<td>cell
// 		<td>cell
// 	<tr>
// 		<td>cell
// 		<td>
// 			<area userdata="<?oid DATA ?>" />
// </table><?
// end_of_html(doc))
// 
// // save the document in file test.pdf
// (Pdf/print_in_file(doc,"test.pdf"))
// \/code
// @cat


// HTML handlers
html_begin_element :: property(open = 3)
html_end_element :: property(open = 3)

// @doc User area element
fill_area :: property(open = 3, range = tuple(float, float))



[html_read_upto(p:port, s:subtype[string]) : tuple(string, string) =>
	let t := freadline(p, s) as tuple(string, string)
	in (if not(t[2] % s) error("html syntax error : one of ~S expected", s), t)]

[html_read_upto(p:port, s:string, error?:boolean) : string =>
	let t := freadline(p, s)
	in (if (error? & eof?(p)) error("html premature end of file: ~S expected", s), t)]

[html_read_upto(p:port, s:string) : string -> html_read_upto(p, s, true)]


//<sb> apply "safely" an HTML handler
[apply_html_handler(p:property, l:list, def:any) : any ->
	//[2] apply handler ~S(~A) // p, l,
	try
		apply(p,l)
	catch selector_error[selector = p]
		def]



//<sb> html separators
SEP1 :: {"="," ","/>",">"}
SEP2 :: {"\"", "'"," ","\t","\n","\r","/>",">"}
SEP3 :: {" ","\t","\n","\r","/>",">"}
SEP4 :: {"/>", ">"}
QTE :: {"\"", "'"}

//<sb> parse a single attribute and add it to the given
// attribute table
[parse_one_attr(p:port, e:html_element) : string ->
	let (attr, eq) := html_read_upto(p, SEP1)
	in (attr := trim(lower(attr)),
		if (eq != "=")
			(e[attr] := "", eq)
		else
			let (dummy, qte) := html_read_upto(p, SEP2)
		in (if (qte % QTE) // quoted attribute  (align='left' / align="left")
				(e[attr] := html_read_upto(p, qte),
				html_read_upto(p, SEP3)[2])
			else (e[attr] := dummy, qte)))] // plain attribute (align=left)

//<sb> here are global lists used for callback arguments
// avoid the construction of a new list each time a callback
// is applied
larg2 :: list<any>(0,0)

//<sb> build an arg list (2, 3 or 4 arguments) for a callback
build_larg2(x:any, y:any) : list => (larg2[1] := x, larg2[2] := y, larg2)

//<sb> here is our main parser code. All tag/attr names are lowered
// before a handler is applied. If a handler causes an issue a trace
// is generated but the error is ignored (allow malformed HTML).
// each time a new element is reached, the data returned by the
// begin handler is pushed such when the element is leaved we can
// call the end handler with the corresponding data.
[parse_html(p:port, data:html_element) : void ->
	let ts := data.ref_doc.tables
	in (shrink(ts, 0),
		add_pseudo_before(data),
		internal_parse_html(p, data),
		rm_last_empty_inline_content(data.ref_doc),
		for t in ts
			pre_process_table(t))]

lastdoc:any := unknown
[internal_parse_html(p:port, data:html_element) : html_element ->
	let top := data,
		pdf := data.ref_doc,
		st := pdf.style_sheet
	in (while not(eof?(p))
		let cdata := html_read_upto(p, "<", false),
			c := fread(p, 1)
		in (if eof?(p) // pending cdatas
				(if (length(cdata) > 0)
					html_text!(data, cdata))
			else if (c = "!") // comment
				(if (length(cdata) > 0)
					html_text!(data, cdata),
				if (fread(p, 2) = "--") freadline(p, "-->")
				else freadline(p, ">"))
			else if (c = "/") // end tag
				let tag := html_read_upto(p, ">", false)
				in let tagname := lower(trim(tag))
				in (if (length(cdata) > 0) html_text!(data, cdata),
					data := apply_html_handler(html_end_element,
													build_larg2(tagname,data), data) as html_element)
			else // start tag
				let (tag, sep) := html_read_upto(p, SEP3)
				in let tagname := lower(c /+ tag)
				in (if (length(cdata) > 0) html_text!(data, cdata),
					data := apply_html_handler(html_begin_element,
												build_larg2(tagname,data), data) as html_element,
					data.element_name := tagname,
					let x := data
					in (while not(sep % SEP4) sep := parse_one_attr(p, data),
						build_css_styler(st, data),
						when nm := data["name"]
						in pdf.html_name_map[nm] := data,
						case data
							(html_hr
								(add_pseudo_before(data),
								data := data.hparent),
							html_br
								let inl := get_last_inline_content(data),
									l := inl.lines[1].words
									in (add_pseudo_before(data),
										l add data,
										add_pseudo_after(data),
										data := data.hparent),
							html_embeded_element
								(add_pseudo_before(data),
								embeded_element!(data),
								add_pseudo_after(data),
								data := data.hparent),
							any add_pseudo_before(data)),
						case x
							(html_substitution
								(data := apply_begin_substitution(x, p),
								if (sep = "/>")
									data := apply_html_handler(html_end_element,
												build_larg2(tagname,data), data) as html_element),
							html_pageof setup_pageof(x),
							html_img load_img(x),
							html_xobject setup_xobject(x),
							html_signature setup_signature(x),
							html_attachment setup_attachment(x),
							html_area setup_area(x),
							html_td td!(x))))),
		lastdoc := top,
		data)]


// *********************************************************************
// *   Part 2: text entity tools                                       *
// *********************************************************************

[normalize_pre(self:html_element, inl:html_inline_content, f:integer, cdata:string) : void ->
	let line := inl.lines[1].words,
		first? := true
	in (if inl.onspace? line add inl.last_space,
		inl.onspace? := false,
		for e in explode(cdata,"\n")
			(if first? first? := false
			else line add html_br(hparent = self),
			if (length(e) > 0)
				let w := html_basic_word(ref_doc = self.ref_doc,
									hparent = self,
									word = replace(unescape(replace(e, "\t", "    ")),"\240", " "))
				in (//self.hchildren add w,
					line add w)))]

[normalize_nowrap(self:html_element, inl:html_inline_content, f:integer, cdata:string) : void ->
	let line := inl.lines[1].words
	in (if inl.onspace? line add inl.last_space,
		inl.onspace? := false,
		let b := blob!(cdata),
			out := blob!(),
			first? := true
		in (if (cdata[1] % {' ', '\n', '\r', '\t'})
				putc(' ', out),
			while not(eof?(b))
				let (data, sp) := freadline(b, {' ', '\n', '\r', '\t'})
				in (if (length(data) > 0)
						(if first? first? := false
						else putc(' ', out),
						fwrite(replace(unescape(data), "\240", " "), out))),
			if (not(first?) & cdata[length(cdata)] % {' ', '\n', '\r', '\t'})
				putc(' ', out),
			let w := html_basic_word(ref_doc = self.ref_doc,
								hparent = self,
								word = string!(out))
			in (//self.hchildren add w,
				line add w),
			fclose(b),
			fclose(out)))]

[normalize_normal(self:html_element, inl:html_inline_content, f:integer, cdata:string) : void ->
	let line := inl.lines[1].words,
		first? := true,
		sp? := false,
		sz := css_get_float(self, css_font-size),
		spc := html_space(hparent = self,
							word = " ",
							width = get_text_width(self.ref_doc, " ", f, sz))
	in (if inl.onspace? line add inl.last_space
		else if (line & cdata[1] % {' ', '\n', '\r', '\t'})
			line add spc,
		inl.onspace? := false,
		let b := blob!(cdata)
		in (while not(eof?(b))
				let (data, sp) := freadline(b, {' ', '\n', '\r', '\t'})
				in (if (length(data) > 0)
						let w := html_basic_word(ref_doc = self.ref_doc,
											hparent = self,
											word = replace(unescape(data), "\240", " "))
						in (if first? first? := false
							else line add spc,
							//self.hchildren add w,
							line add w,
							sp? := sp != "")),
			if sp?
				(inl.onspace? := true,
				inl.last_space := spc),
			fclose(b)))]

// finds the previous sibling inline content associated to
// the parent block element.
[get_last_inline_content(self:html_element) : html_inline_content ->
	let lc := self.hchildren,
		len := length(lc)
	in (case self
		(html_block_element
			(if not(self.hchildren)
				let inl := html_inline_content(hparent = self)
				in (inl.lines add html_line(hparent = self),
					inl)
			else let lc := self.hchildren,
						c := last(lc)
				in case c
					(html_inline_content c,
					any let i := len
						in (while (i > 0)
								(if (lc[i] % html_inline_content)
									break(),
								if (lc[i] % html_block_element)
									(i := 0,
									break()),
								i :- 1),
							if (i = 0)
								let inl := html_inline_content(hparent = self)
								in (inl.lines add html_line(hparent = self),
									inl)
							else lc[i] as html_inline_content))),
		any get_last_inline_content(self.hparent)))]


[pseudo_first_letter(self:html_element) : (html_pseudo_element U {unknown}) ->
	let ps := html_pseudo_element(hparent = self,
						element_name = self.element_name /+ ":first-letter")
	in (build_css_styler(self.ref_doc.style_sheet, ps),
		if known?(style, ps)
			(if (unknown?(next, ps.style) &
					length(ps.style.selector.properties) = 2 &
					ps.style.selector.properties[1] = css_debug)
				(self.hchildren delete ps,
				unknown)
			else ps)
		else (self.hchildren delete ps,
			unknown))]


// a new text has parsed (cdata) creates necessary
// inline content according to css white-space/text-transform rules
[html_text!(self:html_element, cdata:string) : void ->
	let inl := get_last_inline_content(self),
		whsp := css_get(self, css_white-space),
		f := css_get_font(self),
		ttf := css_get(inl, css_text-transform),
		lw := inl.lines[1].words
	in (if ((not(lw) | inl.onspace?) & whsp != "pre")
			cdata := ltrim(cdata),
		if (length(cdata) > 0 & not(self % html_pseudo_element) &
									not(exists(w in lw | w.hparent = self)))
			when pfl := pseudo_first_letter(self)
			in (pfl.hparent := self,
				let c := left(cdata, 1),
					nfirst := 2
				in (if (c % {"\240", "\n", "\t", "\r"}) c := " "
					else if (c = "&")
						let n := find(cdata, ";")
						in (if (n > 0)
								(c := unescape(substring(cdata, 1, n)),
								if (c = "\240") c := " ",
								nfirst := n + 1)),
					case css_get(pfl, css_text-transform)
						({"capitalize", "uppercase"} c := upper(c),
						{"lowercase"} c := lower(c)),
					if inl.onspace? lw add inl.last_space,
					inl.onspace? := false,
					lw add html_basic_word(ref_doc = self.ref_doc, hparent = pfl, word = c),
					cdata := substring(cdata, nfirst, length(cdata)))),
		if (length(cdata) > 0)
			(case ttf
				({"capitalize"}
					(cdata := lower(cdata),
					let b := blob!(cdata),
						out := blob!()
					in (while not(eof?(b))
							let (wd, sp) := freadline(b, {" ", "\n", "\r", "\t"})
							in (if (length(wd) > 0)
									(wd[1] := upper(string!(wd[1]))[1],
									fwrite(wd, out)),
								fwrite(sp, out)),
						cdata := string!(out),
						fclose(b),
						fclose(out))),
				{"uppercase"}
					cdata := upper(cdata),
				{"lowercase"}
					cdata := lower(cdata)),
			case whsp
				({"pre"} normalize_pre(self, inl, f, cdata),
				{"nowrap"} normalize_nowrap(self, inl, f, cdata),
				{"normal"} normalize_normal(self, inl, f, cdata))))]
	
[embeded_element!(self:html_embeded_element) : void ->
	let inl := get_last_inline_content(self.hparent),
		line := inl.lines[1].words
	in (if inl.onspace?
			(inl.onspace? := false,
			line add inl.last_space),
		line add self)]


// *********************************************************************
// *   Part 3: table tools                                             *
// *********************************************************************

unknown_td :: mClaire/new!(html_td)

//<sb> syntactical sugar to manipulate a table element seen as a matrix of td
nth(self:html_table, r:integer, c:integer) : (html_td U {unknown}) =>
	(if (r < 1 | c < 1) unknown
	else if (r > self.nrows | c > self.ncols) unknown
	else let x := self.td_matrix[r][c]
		in (if (x = unknown_td) unknown else x))


[group!(self:html_table) : void =>
	self.row := length(self.td_matrix)]

[tr!(self:html_table) : void =>
	self.row :+ 1,
	self.col := 1]
	
[nth=(self:html_table, r:integer, c:integer, td:html_td) : void ->
	let m := self.td_matrix
	in (self.ncols :max c,
		self.nrows :max r,
		if (known?(tbody, self) & td.hparent.hparent = self.tbody)
			(if (length(m) < r)
				(self.tbody.hchildren delete td.hparent,
				self.body_groups add html_tbody(element_name = "tbody", hparent = self),
				self.tbody := last(self.body_groups),
				build_css_styler(self.ref_doc.style_sheet, self.tbody),
				td.hparent.group := self.tbody,
				td.hparent.hparent := self.tbody),
			if unknown?(group, td.hparent)
				td.hparent.group := last(self.body_groups),
			if not(td.hparent % last(self.body_groups).hchildren)
				last(self.body_groups).hchildren add td.hparent)
		else if (known?(thead, self) & td.hparent.hparent = self.thead)
			(if unknown?(group, td.hparent)
				td.hparent.group := self.thead)
		else if (known?(tfoot, self) & td.hparent.hparent = self.tfoot)
			(if unknown?(group, td.hparent)
				td.hparent.group := self.tfoot),
		while (length(m) < r)
			m add list<html_td>(),
		let row := m[r]
		in (while (length(row) < c)
				row add unknown_td,
			if (row[c] = unknown_td) row[c] := td
			else (while (row[c] != unknown_td)
					(c :+ 1,
					if (c > length(row))
						row add unknown_td),
				self.ncols :max c,
				row[c] := td)))]

[td!(td:html_td) : void ->
	when cs := td["colspan"]
	in (td.colspan := integer!(cs)),
;		if (td.colspan <= 0)
;			td.colspan := 1),
	when rs := td["rowspan"]
	in (td.rowspan := integer!(rs)),
;		if (td.rowspan <= 0)
;			td.rowspan := 1),
	let t := td.hparent.hparent.hparent,
		c0 := t.col,
		r0 := t.row,
		rsp := (if (td.rowspan <= 0) 0 else td.rowspan - 1),
		csp := (if (td.colspan <= 0) 0 else td.colspan - 1)
	in (for c in (c0 .. c0 + csp)
			for r in (r0 .. r0 + rsp)
				t[r,c] := td,
		td.col := c0,
		td.row := r0,
		t.col :+ csp + 1)]

[pre_process_table(self:html_table) : void ->
	normalize_rows(self),
	extend_null_span(self)]

[normalize_rows(self:html_table) : void ->
	let m := self.td_matrix
	in for r in (1 .. self.nrows)
		let row := m[r]
		in (while (length(row) < self.ncols)
				row add unknown_td)]

[extend_null_span(self:html_table) : void ->
	let m := self.td_matrix
	in for r in (1 .. self.nrows)
		for c in (1 .. self.ncols)
			let td := m[r][c]
			in (if (td.rowspan = 0) td.rowspan := 1,
				if (td.colspan = 0)
					(td.colspan := 1,
					while can_move_column?(m, td, r, c)
						(move_column(m, td, r, c),
						td.colspan :+ 1,
						c :+ 1)))]

[can_move_column?(m:list[list[html_td]], td:html_td, r:integer, c:integer) : boolean ->
	c < length(m[r]) &
		forall(j in (0 .. td.rowspan - 1) | m[r + j][c + 1] = unknown_td |
					can_move_column?(m, m[r][c + j], r + j, c + 1))]

[move_column(m:list[list[html_td]], td:html_td, r:integer, c:integer) : void ->
	for j in (0 .. td.rowspan - 1)
		(if (m[r + j][c + 1] != unknown_td)
			move_column(m, m[r + j][c + 1], r + j, c + 1),
		m[r + j][c + 1] := td)]



// *********************************************************************
// *   Part 6: link tool                                               *
// *********************************************************************

[get_a_href(self:html_entity) : (html_a U {unknown}) ->
	case self
		(html_a
			(when href := self["href"]
			in self else unknown),
		html_block_element unknown,
		html_entity get_a_href(self.hparent),
		any unknown)]

[get_block_a_href(self:html_block_element) : (html_a U {unknown}) ->
	when p := get(hparent, self)
	in get_a_href(self.hparent)
	else unknown]

[create_links(self:html_line, pg:pdf_page) : void ->
	let l := self.words,
		len := length(l),
		i := 1,
		in_a := unknown
	in (while (i <= len)
			let aw := l[i]
			in (i :+ 1,
				if (aw % html_word_chunk | aw % html_embeded_element | aw % html_placed_word)
					let w := (case aw (html_placed_word aw.target, any aw))
					in (when a := get_a_href(w)
						in (if (a = in_a)
								let r := a.curlink.linkrect
								in (case aw
										(html_word_chunk
											(r.right := w.X + w.width,
											r.top :max w.Y + w.ascender,
											r.bottom :min w.Y + w.ascender - w.height),
										html_placed_word
											(r.right := aw.X + w.width,
											r.top :max aw.height + w.ascender,
											r.bottom :min aw.height + w.ascender - w.height),
										html_lazy_element
											(r.right := w.X + w.width,
											r.top :max w.Y + w.ascender,
											r.bottom :min w.Y + w.ascender - w.height),
										html_embeded_element
											(r.right := w.X + w.width,
											r.top :max w.Y,
											r.bottom :min w.Y - w.height)))
							else
								let lk := pdf_html_link!(w, a["href"])
								in (pg.annots add lk,
									in_a := a,
									a.curlink := lk,
									case aw
										(html_word_chunk
											lk.linkrect :=
												rectangle!(w.X, w.Y + w.ascender,
														w.X + w.width, w.Y + w.ascender - w.height),
										html_placed_word
											lk.linkrect :=
												rectangle!(aw.X, aw.height + w.ascender,
														aw.X + w.width, aw.height + w.ascender - w.height),
										html_lazy_element
											lk.linkrect :=
												rectangle!(w.X, w.Y + w.ascender,
														w.X + w.width, w.Y + w.ascender - w.height),
										html_embeded_element
											lk.linkrect :=
												rectangle!(w.X, w.Y,
														w.X + w.width, w.Y - w.height)))))
				else in_a := unknown))]



// *********************************************************************
// *   Part 6: element handler                                         *
// *********************************************************************


[html_begin_element(self:{"a"}, e:html_element) : html_element ->
	html_a(hparent = e)]

[html_begin_element(self:{"b"}, e:html_element) : html_element ->
	html_b(hparent = e)]

[html_begin_element(self:{"i"}, e:html_element) : html_element ->
	html_i(hparent = e)]

[html_begin_element(self:{"em"}, e:html_element) : html_element ->
	html_em(hparent = e)]

[html_begin_element(self:{"u"}, e:html_element) : html_element ->
	html_u(hparent = e)]

[html_begin_element(self:{"sup"}, e:html_element) : html_element ->
	html_sup(hparent = e)]

[html_begin_element(self:{"sub"}, e:html_element) : html_element ->
	html_sub(hparent = e)]

[html_begin_element(self:{"font"}, e:html_element) : html_element ->
	html_font(hparent = e)]

[html_begin_element(self:{"span"}, e:html_element) : html_element ->
	html_span(hparent = e)]


[html_begin_element(self:{"br"}, e:html_element) : html_element ->
	html_br(hparent = e)]

[html_begin_element(self:{"img"}, e:html_element) : html_element ->
	html_img(hparent = e)]

[html_begin_element(self:{"background"}, e:html_element) : html_element ->
	html_background(hparent = e)]


[html_begin_element(self:{"pagenum"}, e:html_element) : html_element ->
	html_pagenum(hparent = e)]

[html_begin_element(self:{"pagecount"}, e:html_element) : html_element ->
	html_pagecount(hparent = e)]

[html_begin_element(self:{"pageof"}, e:html_element) : html_element ->
	html_pageof(hparent = e)]

[setup_pageof(self:html_pageof) : void ->
	when x := self["target"]
	in self.target := Core/Oid~(x)]


[load_img(self:html_img) : void ->
	when att := self["src"]
	in (let im := load_pngUjpg(self.ref_doc, att)
		in (self.src := im))
	else when oid := self["data"]
		in (let p := Core/Oid~(oid)
			in (case p 
					(blob
						(set_index(p, 0),
						self.src := load_pngUjpg(self.ref_doc, p)),
					port self.src := load_pngUjpg(self.ref_doc, p))))]

[html_begin_element(self:{"area"}, e:html_element) : html_element ->
	html_area(hparent = e)]

[setup_area(self:html_area) : void ->
	when x := self["userdata"]
	in self.userdata := Core/Oid~(x)]

[html_begin_element(self:{"xobject"}, e:html_element) : html_element ->
	html_xobject(hparent = e)]

[setup_xobject(self:html_xobject) : void ->
	let val := "", nm := ""
	in (when z := self["name"] in nm := z,
		when z := self["value"] in val := z,
		when xo := self.ref_doc.xobject_map[nm, val]
		in (self.ref_xobject := xo,
			use_resource(xo)))]
		


[start_block_element(e:html_element, c:class) : html_element ->
	let x := mClaire/new!(c) as html_element
	in (x.hparent := e,
		x.ref_doc := e.ref_doc,
		close(x),
		x)]

[html_begin_element(self:{"ul"}, e:html_element) : html_element ->
	start_block_element(e, html_ul)]

[html_begin_element(self:{"ol"}, e:html_element) : html_element ->
	start_block_element(e, html_ol)]

[html_begin_element(self:{"dl"}, e:html_element) : html_element ->
	start_block_element(e, html_dl)]

[html_begin_element(self:{"li"}, e:html_element) : html_element ->
	while (e % html_inline_element) e := e.hparent,
	case e
		(html_li html_li(hparent = e.hparent),
		html_list_container html_li(hparent = e),
		any html_li(hparent = e))]

[html_begin_element(self:{"dt"}, e:html_element) : html_element ->
	while (e % html_inline_element) e := e.hparent,
	case e
		(html_dt html_dt(hparent = e.hparent),
		html_dd html_dt(hparent = e.hparent),
		html_dl html_dt(hparent = e),
		any html_dt(hparent = e))]

[html_begin_element(self:{"dd"}, e:html_element) : html_element ->
	while (e % html_inline_element) e := e.hparent,
	case e
		(html_dt html_dd(hparent = e.hparent),
		html_dd html_dd(hparent = e.hparent),
		html_dl html_dd(hparent = e),
		any html_dd(hparent = e))]


[html_begin_element(self:{"p"}, e:html_element) : html_element ->
	start_block_element(e, html_p)]

[html_begin_element(self:{"div"}, e:html_element) : html_element ->
	start_block_element(e, html_div)]

[html_begin_element(self:{"code"}, e:html_element) : html_element ->
	start_block_element(e, html_code)]

[html_begin_element(self:{"center"}, e:html_element) : html_element ->
	start_block_element(e, html_center)]

[html_begin_element(self:{"blockquote"}, e:html_element) : html_element ->
	start_block_element(e, html_blockquote)]

[html_begin_element(self:{"hr"}, e:html_element) : html_element ->
	start_block_element(e, html_hr)]

ANNOTATION?:boolean := false

[html_begin_element(self:{"attachment"}, e:html_element) : html_element ->
	if ANNOTATION? error("No support for recursive annotation"),
	ANNOTATION? := true,
	let att := start_block_element(e, html_attachment) as html_attachment
	in (att.ref_annot := pdf_file_attachment(
			doc = att.ref_doc, src = att,
			embeddedfile = pdf_embedded_file(doc = att.ref_doc)),
		att)]

[setup_attachment(self:html_attachment) : void ->
	let att := (self.ref_annot as pdf_file_attachment),
		emb := att.embeddedfile
	in (when x := self["userdata"]
		in emb.userdata := Core/Oid~(x),
		when x := self["content"]
		in att.content := x,
		when x := self["mimetype"]
		in emb.mimetype := x,
		when x := self["filepath"]
		in emb.filepath := x)]

[html_begin_element(self:{"signature"}, e:html_element) : html_element ->
	if ANNOTATION? error("No support for recursive annotation"),
	ANNOTATION? := true,
	let s := start_block_element(e, html_signature) as html_signature,
		d := e.ref_doc,
		sig := pdf_signature_widget(doc = d, src = s, signature = pdf_signature_field(doc = d))
	in (if unknown?(acro_form, d.catalog)
			d.catalog.acro_form := pdf_interactive_form(doc = d),
		s.ref_annot := sig,
		d.catalog.acro_form.fields :add sig,
		s)]

[setup_signature(self:html_signature) : void ->
	let sig := (self.ref_annot as pdf_signature_widget).signature
	in (when x:any := self["certificate"]
		in (x := Core/Oid~(x), case x (Openssl/X509 sig.certificate := x)),
		when x:any := self["chain"]
		in (x := Core/Oid~(x), case x (list[Openssl/X509] sig.cert_chain := x)),
		when x:any := self["key"]
		in (x := Core/Oid~(x), case x (Openssl/key sig.private_key := x)),
		when x := self["reason"] in (sig.reason := x),
		when x := self["location"] in (sig.siglocation := x),
		when x := self["contact-info"] in (sig.contact_info := x),
		when x := self["subfilter"] in (case x (SIGNATURE_FORMAT sig.sig_format := x)))]

[html_begin_element(self:{"normal", "rollover", "down"}, x:html_element) : html_element ->
	let e := x
	in (while (known?(hparent, x) & not(x % html_annotation))
			x := x.hparent,
		case x
			(html_annotation
				let xo := pdf_appearance_xobject(doc = x.ref_doc, src = x, kind = upper(substring(self,1,1)))
				in (if unknown?(appearance, x.ref_annot)
						x.ref_annot.appearance := pdf_appearance_stream(doc = x.ref_doc),
					CURRENT_XOBJECT := xo,
					push_resource_target(xo),
					let p := (case self ({"normal"} normal, {"rollover"} rollover, any down)),
						app := start_block_element(x, html_appearance) as html_appearance
					in (write(p, x, app),
						app.ref_xobject := xo,
						write(p, x.ref_annot.appearance, xo),
						app)),
			any e))]

[html_begin_element(self:{"data"}, x:html_element) : html_element ->
	let e := x
	in (while (known?(hparent, x) & not(x % html_attachment)) x := x.hparent,
		case x
			(html_attachment
				x.ref_annot.embeddedfile.inline_data := blob!(unescape(freadline(x.ref_doc.pdfport, "</data>")))),
		e)]

[html_begin_element(self:{"h1","h2","h3","h4","h5","h6"}, e:html_element) : html_element ->
	let h := start_block_element(e, html_h)
	in (h.level := integer!(explode_wildcard(self,"h*")[1]),
		h)]

[html_begin_element(self:{"table"}, e:html_element) : html_element ->
	let t := start_block_element(e, html_table)
	in (t.ref_doc.tables add t as html_table,
		t)]

[html_begin_element(self:{"tbody"}, e:html_element) : html_element ->
	while (known?(hparent, e) & not(e % html_table))
		e := e.hparent,
	case e
		(html_table
			(if known?(tbody, e) e.tbody
			else (e.tbody := html_tbody(hparent = e),
					group!(e),
					e.tbody)),
		any e)]

[html_begin_element(self:{"thead"}, e:html_element) : html_element ->
	while (known?(hparent, e) & not(e % html_table))
		e := e.hparent,
	case e
		(html_table
			(if known?(thead, e) e.thead
			else (e.thead := html_thead(hparent = e),
					group!(e),
					e.thead)),
		any e)]

[html_begin_element(self:{"tfoot"}, e:html_element) : html_element ->
	while (known?(hparent, e) & not(e % html_table))
		e := e.hparent,
	case e
		(html_table
			(if known?(tfoot, e) e.tfoot
			else (e.tfoot := html_tfoot(hparent = e),
					group!(e),
					e.tfoot)),
		any e)]


[html_begin_element(self:{"tr"}, e:html_element) : html_element ->
	while (known?(hparent, e) &
			not(e % html_table | e % html_tbody | e % html_tfoot | e % html_thead))
		e := e.hparent,
	case e
		(html_table
			(e.tbody := html_tbody(element_name = "tbody", hparent = e), // implicit tbody
			build_css_styler(e.ref_doc.style_sheet, e.tbody),
			group!(e),
			tr!(e),
			html_tr(hparent = e.tbody)),
		html_table_group
			(tr!(e.hparent),
			html_tr(hparent = e)),
		any e)]

[html_begin_element(self:{"td"}, e:html_element) : html_element ->
	while (known?(hparent, e) & not(e % html_tr))
		e := e.hparent,
	case e
		(html_tr
			html_td(hparent = e),
		any e)]

[html_begin_element(self:{"th"}, e:html_element) : html_element ->
	while (known?(hparent, e) & not(e % html_tr))
		e := e.hparent,
	case e
		(html_tr
			html_th(hparent = e),
		any e)]


//<sb> end tag handlers


[end_inline_element(x:html_element, c:class) : html_element ->
	let inline_chain := list<html_inline_element>()
	in (while true
			(if (x % c)
				(add_pseudo_after(x),
				if known?(hparent, x) x := x.hparent,
				break()),
			if unknown?(hparent, x) break(),
			case x
				(html_block_element shrink(inline_chain, 0), //none, //break(),
				html_inline_element inline_chain add x),
			x := x.hparent),
		if inline_chain
			let p := x,
				res:html_element := x
			in (for e in inline_chain
					(res := mClaire/new!(owner(e)) as html_element,
					res.hparent := p,
					res.ref_doc := res.hparent.ref_doc,
					close(res),
					res.element_name := e.element_name,
					res.style := e.style,
					put(attr_list, res, get(attr_list, e)),
					p := res),
				res)
		else x)]

	
[html_end_element(self:{"a"}, x:html_element) : html_element ->
	end_inline_element(x, html_a)]

[html_end_element(self:{"i"}, x:html_element) : html_element ->
	end_inline_element(x, html_i)]

[html_end_element(self:{"em"}, x:html_element) : html_element ->
	end_inline_element(x, html_em)]

[html_end_element(self:{"u"}, x:html_element) : html_element ->
	end_inline_element(x, html_u)]

[html_end_element(self:{"b"}, x:html_element) : html_element ->
	end_inline_element(x, html_b)]

[html_end_element(self:{"sup"}, x:html_element) : html_element ->
	end_inline_element(x, html_sup)]

[html_end_element(self:{"sub"}, x:html_element) : html_element ->
	end_inline_element(x, html_sub)]

[html_end_element(self:{"font"}, x:html_element) : html_element ->
	end_inline_element(x, html_font)]

[html_end_element(self:{"span"}, x:html_element) : html_element ->
	end_inline_element(x, html_span)]


[end_block_element(x:html_element, c:class) : html_element ->
	while true
		(if (x % c)
			(x := x.hparent,
			break()),
		if unknown?(hparent, x) break(),
		x := x.hparent),
	let b := x
	in (while (b % html_inline_element)
			b := b.hparent,
		case b
			(html_block_element
				let inl := html_inline_content(hparent = b)
				in inl.lines add html_line(hparent = b))),
	x]

[html_end_element(self:{"p"}, x:html_element) : html_element -> end_block_element(x, html_p)]
[html_end_element(self:{"code"}, x:html_element) : html_element -> end_block_element(x, html_code)]
[html_end_element(self:{"blockquote"}, x:html_element) : html_element -> end_block_element(x, html_blockquote)]

[html_end_element(self:{"h1","h2","h3","h4","h5","h6"}, x:html_element) : html_element ->
	end_block_element(x, html_h)]

[html_end_element(self:{"table"}, x:html_element) : html_element -> end_block_element(x, html_table)]
[html_end_element(self:{"tr"}, x:html_element) : html_element -> end_block_element(x, html_tr)]
[html_end_element(self:{"td"}, x:html_element) : html_element -> end_block_element(x, html_td)]
[html_end_element(self:{"th"}, x:html_element) : html_element -> end_block_element(x, html_th)]
[html_end_element(self:{"tbody"}, x:html_element) : html_element -> end_block_element(x, html_tbody)]
[html_end_element(self:{"tfoot"}, x:html_element) : html_element -> end_block_element(x, html_tfoot)]
[html_end_element(self:{"thead"}, x:html_element) : html_element -> end_block_element(x, html_thead)]
[html_end_element(self:{"ul"}, x:html_element) : html_element -> end_block_element(x, html_ul)]
[html_end_element(self:{"ol"}, x:html_element) : html_element -> end_block_element(x, html_ol)]
[html_end_element(self:{"li"}, x:html_element) : html_element -> end_block_element(x, html_li)]
[html_end_element(self:{"div"}, x:html_element) : html_element -> end_block_element(x, html_div)]
[html_end_element(self:{"center"}, x:html_element) : html_element -> end_block_element(x, html_center)]
[html_end_element(self:{"dl"}, x:html_element) : html_element -> end_block_element(x, html_dl)]
[html_end_element(self:{"dt"}, x:html_element) : html_element -> end_block_element(x, html_dt)]
[html_end_element(self:{"dd"}, x:html_element) : html_element -> end_block_element(x, html_dd)]

[html_end_element(self:{"attachment"}, e:html_element) : html_element ->
	ANNOTATION? := false,
	if known?(CURRENT_XOBJECT)
		(CURRENT_XOBJECT := unknown,
		pop_resource_target(e.ref_doc)),
	end_block_element(e, html_attachment)]

[html_end_element(self:{"signature"}, e:html_element) : html_element ->
	ANNOTATION? := false,
	if known?(CURRENT_XOBJECT)
		(CURRENT_XOBJECT := unknown,
		pop_resource_target(e.ref_doc)),
	end_block_element(e, html_attachment)]

[html_end_element(self:{"normal", "rollover", "down"}, x:html_element) : html_element ->
	if known?(CURRENT_XOBJECT)
		(CURRENT_XOBJECT := unknown,
		pop_resource_target(x.ref_doc)),
	end_block_element(x, html_appearance)]

// *********************************************************************
// *   Part 8: element transformation (scale/translate)                *
// *********************************************************************


//<sb>
// @cat Design consideration
// A scale factor may be applied implicitly for elements that overflows
// the parent element box. Unlike for screen device that may handle such
// overflow by inflating the parent box and finally add scroll bars.
// A scale processing is introduced to avoid artifacts generated by
// arbitrary wide elements. In a web browser UI, the problem is fixed
// with scroll bars and of course there is no scroll bar on a printed
// document! The renderer will fix this artifact by applying a scale on
// elements that are too wide.
// In the theory only root elements may need to be scaled. This assumption
// usually fails due to the recursive implementation of the layout processing
// which produce floating point mistakes at various level of the recursion.
// Then, nested scaling are sometimes applied to fix this issue.
// @cat


[apply_translate(self:html_embeded_element, dx:float, dy:float) : void -> none]
[apply_translate(self:html_entity, dx:float, dy:float) : void -> none]

[apply_translate(self:html_inline_element, dx:float, dy:float) : void -> none]
/*	for e in self.hchildren
		apply_translate(e, dx, dy)]*/

[apply_translate(self:html_block_element, dx:float, dy:float) : void ->
	self.X :+ dx,
	self.Y :+ dy,
	for e in self.hchildren
		apply_translate(e, dx, dy)]

[apply_translate(self:html_inline_content, dx:float, dy:float) : void ->
	for ln in self.lines
		(ln.X :+ dx,
		ln.Y :+ dy,
		for w in ln.words
			(case w
				(html_word_chunk
					(w.X :+ dx,
					w.Y :+ dy),
				html_embeded_element
					(w.X :+ dx,
					w.Y :+ dy))))]

[apply_translate(self:html_table, dx:float, dy:float) : void ->
	self.X :+ dx,
	self.Y :+ dy,
	when h := get(thead, self) in apply_translate(h, dx, dy),
	for e in self.body_groups
		apply_translate(e, dx, dy),
	when h := get(tfoot, self) in apply_translate(h, dx, dy)]


[apply_scale(self:html_embeded_element, x:float, y:float, sc:float) : void -> none]
[apply_scale(self:html_entity, x:float, y:float, sc:float) : void -> none]

[apply_scale(self:html_inline_element, x:float, y:float, sc:float) : void -> none]
//	for e in self.hchildren apply_scale(e, x, y, sc)]

[apply_scale(self:html_block_element, x:float, y:float, sc:float) : void ->
	self.scale :* sc,
	self.width :* sc,
	self.height :* sc,
	self.X := x + sc * (self.X - x),
	self.Y := y + sc * (self.Y - y),
	for e in self.hchildren
		apply_scale(e, x, y, sc)]

[apply_scale(self:html_table, x:float, y:float, sc:float) : void ->
	self.scale :* sc,
	self.width :* sc,
	self.height :* sc,
	self.X := x + sc * (self.X - x),
	self.Y := y + sc * (self.Y - y),
	when h := get(thead, self) in apply_scale(h, x, y, sc),
	for e in self.body_groups
		apply_scale(e, x, y, sc),
	when h := get(tfoot, self) in apply_scale(h, x, y, sc)]


[apply_scale(self:html_inline_content, x:float, y:float, sc:float) : void ->
	self.height :* sc,
	for ln in self.lines
		(ln.width :* sc,
		ln.Y := y + sc * (ln.Y - y),
		ln.X := x + sc * (ln.X - x),
		ln.lineheight :* sc,
		ln.baseline :* sc,
		for w in ln.words
			(case w
				(html_word_chunk
					(w.scale :* sc,
					w.ascender :* sc,
					w.width :* sc,
					w.height :* sc,
					w.Y := y + sc * (w.Y - y),
					w.X := x + sc * (w.X - x)),
				html_embeded_element
					(w.scale :* sc,
					w.width :* sc,
					w.height :* sc,
					w.Y := y + sc * (w.Y - y),
					w.X := x + sc * (w.X - x)))))]


// *********************************************************************
// *   Part 8: min / max widths processing                             *
// *********************************************************************

minmax <: ephemeral_object(mmin:float, mmax:float)

//<sb> implementation of the auto-layout algorithm described in RFC1942
// first pass : compute min/max widths of each element recursively


[process_min_max_widths(self:html_inline_element, pmm:minmax) : void -> none]

[process_min_max_widths(self:html_block_element, pmm:minmax) : void ->
	add_pseudo_after(self),
	let mm := minmax()
	in (for x in self.hchildren
			process_min_max_widths(x, mm),
		self.minwidth := mm.mmin,
		self.maxwidth := mm.mmax),
	let pad := css_get_surrounding_left(self) +
					css_get_surrounding_right(self),
		w := css_get(self, css_width)
	in (self.minwidth :+ pad,
		self.maxwidth :+ pad,
		case w
			(float
				(if (w > 0.)
					(if (self.minwidth < w)
						(self.minwidth := w,
						self.maxwidth := w)
					//<sb> the constraint cannot be satisfied
					// so force the element in its min box such
					// to be, as far as possible, near to the constraint
					else self.maxwidth := self.minwidth))),
		pmm.mmin :max self.minwidth,
		pmm.mmax :max self.maxwidth)]

[process_min_max_widths(self:html_entity, mm:minmax) : void -> none]
[process_min_max_widths(self:html_embeded_element, mm:minmax) : void -> none]


// for inline contents the min size is the wider word and the
// max size is the size of the unwrapped line
[process_min_max_widths(self:html_inline_content, mm:minmax) : void ->
	let d := self.ref_doc,
		linemax := 0.,
		wordmax := 0.,
		l := self.lines[1].words,
		len := length(l),
		prevp := unknown,
		prevfont := 0,
		prevsz := 0.
	in (for i in (1 .. len)
			let w := l[i]
			in (case w
					(html_br
						(mm.mmax :max linemax,
						linemax := 0.,
						wordmax := 0.),
					html_lazy_element
						let p := w.hparent,
							sz := css_get_float(w, css_font-size),
							f := css_get_font(w),
							ww := get_text_width(d, "9999", f, sz)
						in (wordmax :+ ww,
							prevp := p,
							prevsz := sz,
							prevfont := f,
							mm.mmin :max wordmax,
							linemax :+ ww),
					html_embeded_element
						(intrinsic_layout(w),
						linemax :+ w.width),
					html_space
						(wordmax := 0.,
						linemax :+ w.width),
					html_basic_word
						let p := w.hparent,
							sz := (if (prevp = p) prevsz else css_get_float(w, css_font-size)),
							f := (if (prevp = p) prevfont else css_get_font(w)),
							ww := get_text_width(d, w.word, f, sz)
						in (wordmax :+ ww,
							prevp := p,
							prevsz := sz,
							prevfont := f,
							mm.mmin :max wordmax,
							linemax :+ ww))),
		mm.mmin :max wordmax,
		if (linemax <= 1.001 * wordmax)
			mm.mmax :max 1.1 * wordmax
		else mm.mmax :max linemax)]



//<sb> for tables we solve min/max width of columns
// when a cell spans multiple cols its width is equally
// apportioned on each column it spans
// note that siding columns account the width of the
// table border and a half of a spacing resulting
// in heterogeneous apportion
[process_min_max_widths(self:html_table, pmm:minmax) : void ->
	let mleft := css_get_float(self, css_margin-left),
		mright := css_get_float(self, css_margin-right),
		spacing := css_get_float(self, css_border-spacing),
		bleft := css_get_float(self, css_border-left-width),
		bright := css_get_float(self, css_border-right-width)
	in (self.maxwidth := mleft + mright + bleft + bright,
		self.minwidth := self.maxwidth,
		for c in (1 .. self.ncols)
			let maxcolwidth := 0.0,
				mincolwidth := 0.0
			in (self.maxwidth :+ spacing,
				self.minwidth :+ spacing,
				for r in (1 .. self.nrows)
					when td := self[r, c]
					in (if (td != self[r - 1, c]) // filter spanned rows
							(if (td != self[r, c - 1]) // filter spanned cols
								process_min_max_widths(td, minmax())),
						let span := float!(td.colspan),
							span-1 := float!(td.colspan - 1)
						in (maxcolwidth :max (td.maxwidth - span-1 * spacing) / span,
							mincolwidth :max (td.minwidth - span-1 * spacing) / span)),
				if (mincolwidth = maxcolwidth)
					maxcolwidth :* 1.0000001,
				self.mincolwidths add mincolwidth,
				self.maxcolwidths add maxcolwidth,
				self.maxwidth :+ maxcolwidth,
				self.minwidth :+ mincolwidth),
		self.maxwidth :+ spacing,
		self.minwidth :+ spacing,
		pmm.mmin :max self.minwidth,
		pmm.mmax :max self.maxwidth)]


// *********************************************************************
// *   Part 9: layout processing                                       *
// *********************************************************************


wrap_box <: ephemeral_object(
				X:float,
				Y:float,
				width:float,
				height:float,
				bheight:float)


//<sb> apply styler constraints on the given box and
// apply a scale factor on the box when the content overflows
[apply_css_width(self:html_block_element, b:wrap_box) : wrap_box ->
	let wst := css_get(self, css_width),
		wconstraint := b.width
	in (if (wst != "auto")
			(//<sb> the styler defines a width: we use that width
			// as a constraint in which the element should fit
			case wst
				(css_percentage
					(if (wst.value > 0.)
						wconstraint :* (wst.value min 100.) / 100.),
				float wconstraint := wst),
			//<sb> when the constraint is wider than the box a scale
			// factor is applied
			b.width := wconstraint),
		b)]

[apply_css_height(self:html_block_element, b:wrap_box) : boolean ->
	let hst := css_get(self, css_height),
		hconstraint := b.bheight
	in (if (hst != "auto")
			(//<sb> the styler defines a width: we use that width
			// as a constraint in which the element should fit
			case hst
				(css_percentage
					(if (hst.value > 0.)
						hconstraint :* (hst.value min 100.) / 100.),
				float hconstraint := hst),
			//<sb> when the constraint is wider than the box a scale
			// factor is applied
			b.bheight := hconstraint,
			true) else false)]


[auto_layout_html(self:html_document, w:float, h:float) : void ->
	process_min_max_widths(self, minmax()),
	auto_layout(self, wrap_box(width = w, bheight = h))]


[auto_layout(self:html_entity, freebox:wrap_box) : void -> none]
[auto_layout(self:html_embeded_element, freebox:wrap_box) : void -> none]

[auto_layout(self:html_inline_element, freebox:wrap_box) : void -> none]
//	for x in self.hchildren
	//	auto_layout(x, freebox)]

[auto_layout(self:html_block_element, freebox:wrap_box) : void ->
	let stop := css_get_surrounding_top(self),
		sbottom := css_get_surrounding_bottom(self),
		sleft := css_get_surrounding_left(self),
		sright := css_get_surrounding_right(self),
		localbox := wrap_box(bheight = freebox.bheight)
	in (self.X := freebox.X,
		self.Y := freebox.Y,
		localbox.height := stop,
		localbox.X := freebox.X + sleft,
		localbox.Y := freebox.Y - stop,
		localbox.width := freebox.width,
		apply_css_width(self, localbox),
		self.width := localbox.width,
		localbox.width :- sleft + sright,
		for x in self.hchildren
			let h := localbox.height
			in (auto_layout(x, localbox),
				localbox.Y :- localbox.height - h),
		localbox.height :+ sbottom,
		self.height := localbox.height,
		if (self.width > freebox.width)
			apply_scale(self, freebox.X, freebox.Y, freebox.width / self.width),
		let innerwidth := self.width - sright - sleft
		in for c in self.hchildren
			(case c
				(html_block_element
					let dx := innerwidth - c.width
					in (if (dx > 0.)
							let cl := css_get(c, css_margin-left),
								cr := css_get(c, css_margin-right)
							in (if (cl = "auto" & cr = "auto")
									apply_translate(c, 0.5 * dx, 0.)
								else if (cl = "auto")
									apply_translate(c, dx, 0.))))),
		freebox.height :+ self.height)]

[auto_layout(self:html_annotation, freebox:wrap_box) : void ->
	let stop := css_get_surrounding_top(self),
		sbottom := css_get_surrounding_bottom(self),
		sleft := css_get_surrounding_left(self),
		sright := css_get_surrounding_right(self),
		localbox := wrap_box(bheight = freebox.bheight)
	in (self.X := freebox.X,
		self.Y := freebox.Y,
		localbox.X := freebox.X + sleft,
		localbox.Y := freebox.Y - stop,
		localbox.width := freebox.width,
		apply_css_width(self, localbox),
		self.width := localbox.width,
		localbox.width :- sleft + sright,
		let maxh := 0.
		in (for x in self.hchildren
				(localbox.height := 0.,
				auto_layout(x, localbox),
				maxh :max localbox.height),
			localbox.height := maxh + sbottom + stop),
		self.height := localbox.height,
/*		if h?
			(if (self.height > localbox.bheight)
				apply_scale(self, freebox.X, freebox.Y, localbox.bheight / self.height)
			else let sheight := self.height,
					valign := css_get(self, css_vertical-align),
					dy := sheight - localbox.bheight
				in (self.height := localbox.bheight,
					if (dy < 0.)
						case valign
							({"middle"}
								for e in self.hchildren
									apply_translate(e, 0., 0.5 * dy),
							{"bottom"}
								for e in self.hchildren
									apply_translate(e, 0., dy)))),*/
		if (self.width > freebox.width)
			apply_scale(self, freebox.X, freebox.Y, freebox.width / self.width),
		freebox.height :+ self.height)]

		

[add_word(self:list[ephemeral_object], w:html_basic_word, f:integer, sz:float, x:float, y:float, wd:float) : void ->
	let added? := false
	in (if self
			let lw := last(self),
				sp? := false,
				spw := 0.
			in (case lw
					(html_space
						(sp? := true,
						spw := lw.width,	
						lw := self[length(self) - 1] as html_entity)),
				case lw
					(html_word_chunk
						(if (lw.hparent = w.hparent)
							(added? := true,
							lw.width :+ wd + spw,
							if sp?
								(rmlast(self),
								lw.space_count :+ 1,
								lw.word :/+ (" " /+ w.word))
							else lw.word :/+ w.word)))),
		if not(added?)
			let p := w.hparent,
				nw := html_word_chunk(
					ref_doc = w.ref_doc,
					hparent = p,
					word = w.word,
					X = x,
					Y = y,
					width = wd,
					height = get_font_height(w.ref_doc, f, sz))
			in (self add nw,
				nw.ascender := y))]

[auto_layout(self:html_inline_content, freebox:wrap_box) : void ->
	//[1] auto_layout(~S,~S) // self, freebox,
	if (self.lines[1].words)
		let d := self.ref_doc,
			l := self.lines,
			n := length(l[1].words),
			len := 1,
			xmax := (freebox.X + freebox.width) * 1.00001, // fix float rounding mistake
			j := 1,
			i := 1,
			x := freebox.X,
			prevp := unknown,
			prevsz := 0.,
			prevfont := 0,
			line := html_line(ref_doc = self.ref_doc, X = x, hparent = self.hparent)
		in (nth+(l, len, line),
			len :+ 1,
			while (i <= n)
				let w := l[len].words[i]
				in (case w
						(html_br
							(x := freebox.X,
							i :+ 1,
							j := i,
							let sz := css_get_float(w, css_font-size),
								f := css_get_font(w),
								bs := get_baseline(d, f, sz)
							in line.baseline :max bs,
							line.words add w,
							line := html_line(ref_doc = self.ref_doc, 
									hparent = self.hparent, X = x),
							nth+(l, len, line),
							len :+ 1),
						html_space
							(if (i > j)
								(line.words add w,
								w.X := x,
								x :+ w.width),
							i :+ 1),
						html_lazy_element
							let sz := css_get_float(w, css_font-size),
								f := css_get_font(w),
								ww := get_text_width(d, "9999", f, sz), // prediction
								bs := get_baseline(d, f, sz)
							in (w.ascender := bs,
								w.X := x,
								w.height := get_font_height(d, f, sz),
								w.Y := bs,
								if (i > j & x + ww > xmax & l[len].words[i - 1] % html_space)
									(x := freebox.X,
									j := i,
									line := html_line(ref_doc = self.ref_doc,
												hparent = self.hparent, X = x),
									nth+(l, len, line),
									len :+ 1,
									line.baseline :max bs,
									line.words add w,
									x :+ ww,
									line.width := x - freebox.X,
									i :+ 1)
								else
									(line.baseline :max bs,
									line.words add w,
									i :+ 1,
									x :+ ww,
									line.width := x - freebox.X)),
						html_embeded_element
							(if (i > j & x + w.width > xmax & l[len].words[i - 1] % html_space)
								(x := freebox.X,
								j := i,
								line := html_line(ref_doc = self.ref_doc, 
											hparent = self.hparent, X = x),
								nth+(l, len, line),
								len :+ 1,
								w.X := x,
								w.Y := w.height,
								x :+ w.width,
								line.baseline :max w.height,
								line.words add w,
								line.width := x - freebox.X,
								i :+ 1)
							else
								(line.baseline :max w.height,
								w.X := x,
								w.Y := w.height,
								line.words add w,
								i :+ 1,
								x :+ w.width,
								line.width := x - freebox.X)),
						html_basic_word
							let p := w.hparent,
								sz := (if (prevp = p) prevsz else css_get_float(w, css_font-size)),
								f := (if (prevp = p) prevfont else css_get_font(w)),
								ww := get_text_width(d, w.word, f, sz),
								bs := get_baseline(d, f, sz)
							in (prevp := p,
								prevsz := sz,
								prevfont := f,
								if (i > j & x + ww > xmax & l[len].words[i - 1] % html_space)
									(x := freebox.X,
									j := i,
									line := html_line(ref_doc = self.ref_doc,
												hparent = self.hparent, X = x),
									nth+(l, len, line),
									len :+ 1,
									line.baseline :max bs,
									add_word(line.words, w, f, sz, x, bs, ww),
									x :+ ww,
									line.width := x - freebox.X,
									i :+ 1)
								else
									(line.baseline :max bs,
									add_word(line.words, w, f, sz, x, bs, ww),
									i :+ 1,
									x :+ ww,
									line.width := x - freebox.X)),
						any (//[0] warning : found any in auto_layout(~S,~S) ~S // self,freebox,w,
							i :+ 1))),
			shrink(l, len - 1),
			post_layout(self, freebox))]

[intrinsic_layout(self:html_background) : void -> none]

[intrinsic_layout(self:html_img) : void ->
	let stop := css_get_surrounding_top(self),
		sbottom := css_get_surrounding_bottom(self),
		sleft := css_get_surrounding_left(self),
		sright := css_get_surrounding_right(self),
		wd := css_get(self, css_width),
		hd := css_get(self, css_height)
	in (when im := get(src, self)
		in (case wd
				(float self.width := wd), 
			case hd
				(float self.height := hd), 
			if (self.height = 0.)
				self.height := 0.9 * im.imheight,// assume pixel size
			if (self.width = 0.)
				self.width := 0.9 * im.imwidth,	
			self.width :+ sleft + sbottom,
			self.height :+ stop + sright)
		else
			(self.width := css_get_float(self, css_font-size),
			self.height := self.width))]

[intrinsic_layout(self:html_xobject) : void ->
	let stop := css_get_surrounding_top(self),
		sbottom := css_get_surrounding_bottom(self),
		sleft := css_get_surrounding_left(self),
		sright := css_get_surrounding_right(self),
		wd := css_get(self, css_width),
		hd := css_get(self, css_height)
	in (when xo := get(ref_xobject, self)
		in (case wd
				(float self.width := wd),
			case hd
				(float self.height := hd), 
			if (self.height = 0.)
				self.height := xo.xobject_elements[1].height,
			if (self.width = 0.)
				self.width := xo.xobject_elements[1].target.width,
			self.width :+ sleft + sbottom,
			self.height :+ stop + sright))]



[intrinsic_layout(self:html_area) : void ->
	let stop := css_get_surrounding_top(self),
		sbottom := css_get_surrounding_bottom(self),
		sleft := css_get_surrounding_left(self),
		sright := css_get_surrounding_right(self),
		wd := css_get(self, css_width),
		hd := css_get(self, css_height),
		aw := 0.,
		ah := 0.
	in (case wd (float aw := wd),
		case hd (float ah := hd),
		self.width := sleft + sright,
		self.height := sbottom + stop,
		self.target_section.current_area := self,
		self.target_section.inside_html_area? := true,
		let twh := unknown
		in (if known?(userdata, self)
				twh := fill_area(self.ref_doc, self.userdata, aw, ah)
			else
				(when nm := self["name"]
				in (when val := self["value"]
					in twh := fill_area(self.ref_doc, nm, val, aw, ah))),
			case twh
				(tuple(float,float)
					(self.width :+ twh[1],
					self.height :+ twh[2]))),
		self.target_section.inside_html_area? := false)]



[post_layout(self:html_inline_content, freebox:wrap_box) : void ->
	let y := freebox.Y,
		ls := self.lines,
		len := length(ls),
		wmax := freebox.width
	in (for i in (1 .. len) wmax :max ls[i].width,
		for i in (1 .. len)
			let l := ls[i]
			in (l.Y := y,
				post_layout(l, freebox, wmax, i = len),
				y :- l.lineheight,
				l.width := wmax,
				self.height :+ l.lineheight),
		if (wmax > freebox.width)
			apply_scale(self, freebox.X, freebox.Y, freebox.width / wmax),
		freebox.height :+ self.height)]


[post_layout(self:html_line, freebox:wrap_box, wmax:float, lastline?:boolean) : void ->
	let bs := self.baseline,
		wrds := self.words,
		maxdescender := 0.,
		maxascender := 0.
	in (while (wrds & last(wrds) % html_space) rmlast(wrds),
		self.last? := lastline?,
		for w in wrds
			case w
				(html_br
					let fs := css_get_float(w, css_font-size),
						fd := get_descender(w.ref_doc, css_get_font(w), fs)
					in (self.lineheight :max bs + fd,
						self.lineheight :max css_get_lineheight(w)),
				html_lazy_element
					let fs := css_get_float(w, css_font-size),
						fd := get_descender(w.ref_doc, css_get_font(w), fs)
					in (self.lineheight :max bs + fd,
						self.lineheight :max css_get_lineheight(w)),
				html_embeded_element
					(self.lineheight :max w.height,
					self.lineheight :max css_get_lineheight(w)),
				html_word_chunk
					let fs := css_get_float(w, css_font-size),
						fd := get_descender(w.ref_doc, css_get_font(w), fs)
					in (self.lineheight :max bs + fd,
						self.lineheight :max css_get_lineheight(w))),
		for w in wrds
			case w
				(html_lazy_element
					case css_get(w, css_vertical-align)
						({"super"}
							let f := css_get_font(self.hparent),
								sz := css_get_float(self.hparent, css_font-size),
								pbs := get_baseline(w.ref_doc, f, sz)
							in (w.Y := self.Y - bs + pbs - w.Y),
						{"sub"}
							let sz := css_get_float(w, css_font-size),
								fd := get_descender(w.ref_doc, css_get_font(w), sz)
							in (w.Y := self.Y - bs - fd),
						any
							w.Y := self.Y - w.Y - (bs - w.Y)),
				html_embeded_element
					w.Y := self.Y - self.baseline + w.height,
				html_word_chunk
					case css_get(w, css_vertical-align)
						({"super"}
							let f := css_get_font(self.hparent),
								sz := css_get_float(self.hparent, css_font-size),
								pbs := get_baseline(w.ref_doc, f, sz)
							in (w.Y := self.Y - bs + pbs - w.Y),
						{"sub"}
							let sz := css_get_float(w, css_font-size),
								fd := get_descender(w.ref_doc, css_get_font(w), sz)
							in (w.Y := self.Y - bs - fd),
						any
							w.Y := self.Y - w.Y - (bs - w.Y))))]


[lazy_layout(self:html_placed_line, pgnum:integer, pgcnt:integer) : void ->
	let line := self.target as html_line,
		wrds := line.words,
		d := line.ref_doc,
		wline := 0.,
		x := line.X
	in (for w in wrds
			(case w
				(html_pageof
					let (pid, pnum, y) := get_element_page_info(d, w.target),
						idx := string!(pnum),
						sz := css_scaled_get(w, css_font-size),
						f := css_get_font(w),
						ww := get_text_width(d, idx, f, sz)
					in (w.index := idx,
						w.width := ww,
						wline :+ ww),
				html_lazy_element
					let idx := string!((case w
								(html_pagenum pgnum,
								any pgcnt))),
						sz := css_scaled_get(w, css_font-size),
						f := css_get_font(w),
						ww := get_text_width(d, idx, f, sz)
					in (w.index := idx,
						w.width := ww,
						wline :+ ww),
				html_embeded_element wline :+ w.width,
				html_placed_word wline :+ w.target.width,
				html_word_chunk wline :+ w.width)),
		let dx := line.width - wline
		in (if (dx > 0.)
				case css_get(line, css_text-align)
					({"left"}
						for w in wrds
							case w
								(html_embeded_element (w.X := x, x :+ w.width),
								html_placed_word (w.X := x, x :+ w.target.width),
								html_word_chunk (w.X := x, x :+ w.width)),
					{"right"}
						(x :+ dx,
						for w in wrds
							case w
								(html_embeded_element (w.X := x, x :+ w.width),
								html_placed_word (w.X := x, x :+ w.target.width),
								html_word_chunk (w.X := x, x :+ w.width))),
					{"center"}
						(x :+ 0.5 * dx,
						for w in wrds
							case w
								(html_embeded_element (w.X := x, x :+ w.width),
								html_placed_word (w.X := x, x :+ w.target.width),
								html_word_chunk (w.X := x, x :+ w.width))),
					{"justify"}
						let nw := 0
						in (if not(line.last?) // do not justify last line !
								let nsp := 0.
								in (for w in wrds
										case w
											(html_space nsp :+ 1.,
											html_word_chunk nsp :+ float!(w.space_count),
											html_placed_word nsp :+ float!(w.target.space_count)),
									if (dx > 0. & nsp > 0.)
										let dw := dx / nsp
										in for w in wrds
											case w
												(html_embeded_element
													(w.X := x, x :+ w.width),
												html_placed_word
													let fsp := float!(w.target.space_count)
													in (w.target.word_spacing := dw,
														w.X := x,
														w.target.width :+ dw * fsp,
														x :+ w.target.width),
												html_space
													(w.X := x,
													w.width :+ dw,
													x :+ w.width),
												html_word_chunk
													let fsp := float!(w.space_count)
													in (w.word_spacing := dw,
														w.X := x,
														w.width :+ dw * fsp,
														x :+ w.width)))))))]


// unlike block elements td's freebox is already accounted
// of the td width style
[auto_layout(self:html_td, freebox:wrap_box) : void ->
	let stop := css_get_surrounding_top(self),
		sbottom := css_get_surrounding_bottom(self),
		sleft := css_get_surrounding_left(self),
		sright := css_get_surrounding_right(self),
		localbox := wrap_box(bheight = freebox.bheight)
	in (self.X := freebox.X,
		self.Y := freebox.Y,
		localbox.height := stop,
		localbox.X := freebox.X + sleft,
		localbox.Y := freebox.Y - stop,
		localbox.width := freebox.width,
		self.width := localbox.width,
		localbox.width :- sleft + sright,
		for x in self.hchildren
			let h := localbox.height
			in (auto_layout(x, localbox),
				localbox.Y :- localbox.height - h),
		localbox.height :+ sbottom,
		self.height := localbox.height,
		let innerwidth := self.width - sright - sleft
		in for c in self.hchildren
			(case c
				(html_block_element
					let dx := innerwidth - c.width
					in (if (dx > 0.)
							let cl := css_get(c, css_margin-left),
								cr := css_get(c, css_margin-right)
							in (if (cl = "auto" & cr = "auto")
									apply_translate(c, 0.5 * dx, 0.)
								else if (cl = "auto")
									apply_translate(c, dx, 0.))))),
		freebox.height :+ localbox.height)]


// apportion cells
[process_cell_widths(self:html_table, total_content_width:float) : list[float] ->
	let t% := css_get(self, css_width) % css_percentage,
		ncol := self.ncols,
		widths := make_list(ncol, float, 0.),
		minw := 0.,
		maxw := 0.
	in (for r in (1 .. self.nrows)
			for c in (1 .. ncol)
				when td := self[r, c]
				in (if (td != self[r - 1, c] & td != self[r, c - 1])
						let w := css_get(td, css_width)
						in (case w
								(css_percentage
									(if (w.value < 100. & w.value > 0.)
										widths[c] :max w.value * total_content_width / 100.),
								float
									(if (w > 0.)
										widths[c] :max w)))),
		for c in (1 .. ncol)
			(if (widths[c] = 0.)
				(if (self.mincolwidths[c] != self.maxcolwidths[c])
					(minw :+ self.mincolwidths[c],
					maxw :+ self.maxcolwidths[c])
				else widths[c] := self.mincolwidths[c])),
		let w% := 0.,
			n% := 0
		in (for c in (1 .. ncol)
				(if (widths[c] > 0.)
					(w% :+ widths[c],
					n% :+ 1)),
			if (t% & w% + maxw < total_content_width)
				let W := (total_content_width - w% - maxw),
					D := (maxw - minw)
				in for c in (1 .. ncol)
					(if (widths[c] = 0.)
						let cmax := self.maxcolwidths[c],
							d := (cmax - self.mincolwidths[c])
						in widths[c] :=  cmax + d * W / D)
			else if (w% + minw > total_content_width)
				let c% := (w% + minw - total_content_width) / float!(n%)
				in for c in (1 .. ncol)
					(if (widths[c] = 0.) widths[c] := self.mincolwidths[c])
			else if (w% + maxw < total_content_width)
				for c in (1 .. ncol)
					(if (widths[c] = 0.)
						widths[c] := self.maxcolwidths[c])
			else if (n% < ncol)
				let W := (total_content_width - w% - minw),
					D := (maxw - minw)
				in for c in (1 .. ncol)
					(if (widths[c] = 0.)
						let cmin := self.mincolwidths[c],
							d := (self.maxcolwidths[c] - cmin)
						in widths[c] :=  cmin + d * W / D)),
		widths)]


[process_cell_height(self:html_td, cellheight:float) : void ->
	let tdheight := self.height,
		valign := css_get(self, css_vertical-align),
		dy := tdheight - cellheight
	in (self.height :max cellheight,
		if (dy < 0.)
			case valign
				({"middle"}
					for e in self.hchildren
						apply_translate(e, 0., 0.5 * dy),
				{"bottom"}
					for e in self.hchildren
						apply_translate(e, 0., dy)))]


[auto_layout(self:html_table, freebox:wrap_box) : void ->
	let Mleft := css_get(self, css_margin-left),
		Mright := css_get(self, css_margin-right),
		mleft := (case Mleft (float Mleft, any 0.)),
		mright := (case Mright (float Mright, any 0.)),
		mtop := css_get_float(self, css_margin-top),
		mbottom := css_get_float(self, css_margin-bottom),
		spacing := css_get_float(self, css_border-spacing),
		bleft := css_get_float(self, css_border-left-width),
		bright := css_get_float(self, css_border-right-width),
		btop := css_get_float(self, css_border-top-width),
		bbottom := css_get_float(self, css_border-bottom-width),
		wb := apply_css_width(self, copy(freebox)),
		total_spacing := mleft + bleft +
							float!(self.ncols + 1) * spacing +
													bright + mright,
		total_content_width := (wb.width max self.minwidth) - total_spacing,
		colwidths := process_cell_widths(self, total_content_width),
		y := freebox.Y,
		x := freebox.X,
		colbox := wrap_box()
	in (self.X := x,
		self.Y := y,
		y :- mtop + btop,
		x :+ mleft + bleft,
		for r in (1 .. self.nrows)
			let rowheight := 0.,
				oldx := x,
				row:(html_tr U {unknown}) := unknown
			in (y :- spacing,
				for c in (1 .. self.ncols)
					(x :+ spacing,
					if (c > 1)
						x :+ colwidths[c - 1],
					when td := self[r, c]
					in (if (td != self[r, c - 1]) // filter spanned cells
							let span := float!(td.rowspan),
								span-1 := span - 1.
							in (if (td != self[r - 1, c])
									let w := float!(td.colspan - 1) * spacing
									in (colbox.X := x,
										colbox.Y := y,
										colbox.bheight := wb.bheight,
										colbox.height := 0.,
										for i in (1 .. td.colspan)
											w :+ colwidths[c + i - 1],
										colbox.width := w,
										auto_layout(td, colbox),
										let rw := td.hparent as html_tr
										in (row := rw,
											if (rw.X = 0.) (rw.X := x, rw.Y := y),
											if (rw.group.Y = 0.)
												(rw.group.X := x,
												rw.group.Y := y)),
										rowheight :max (colbox.height - spacing * span-1) / span)
								else rowheight :max (td.height - spacing * span-1) / span))),
				case row
					(html_tr
						(row.height := rowheight,
						row.group.height :max (row.group.Y - (row.Y - rowheight)))),
				x := oldx,
				y :- rowheight,
				for c in (1 .. self.ncols)
					when td := self[r, c]
					in (if (td != self[r, c - 1])
					 		(if (td.rowspan = 1) process_cell_height(td, rowheight)
							else if (td = self[r - 1, c]) process_cell_height(td, td.Y - y)))),
		y :- spacing + bbottom + mbottom,
		self.height := self.Y - y,
		self.width := total_spacing,
		for colw in colwidths self.width :+ colw,
		if (self.width > wb.width)
			apply_scale(self, self.X, self.Y, wb.width / self.width),
		freebox.height :+ self.height)]




// *********************************************************************
// *   Part 12: automated page break                                   *
// *********************************************************************

//@cat Driving page break algorithm
// The auto-break algorithm may be driven by a set of attribute allowed
// for any HTML element. These attributes are inspired by CSS. The goal
// of the auto-page-break algorithm is to maximize the amount of elements
// rendered on a single page. Notice that the page-break algorithm would
// only be applied on the main HTML stream, the one which is inserted
// with print_in_html/end_of_html.
// A set of the following attribute policies
// are used constrain the breaking policy of an element :
// \ul
// \li \b page-break-before\/b  can take value "auto", "avoid" or "always"
// \li \b page-break-inside\/b  can take value "auto" or "avoid"
// \li \b page-break-after\/b  can take value "auto", "avoid" or "always"
// \/ul
// For instance the h1 element (title level 1) have by default the attribute
// page-break-before set to always, which means that the auto-page-break algorithm
// have to insert a page break before each h1 element.\br
// Other elements would have by default the "auto" policy for each before/inside/after
// attributes.\br
// For instance if we had a paragraph that explain something followed by a table that
// illustrate that thing we may need to avoid page break inside and between the two
// elements, we would write :
// \code
// (print_in_html(doc)
// 	?><p style='page-break-inside: avoid; page-break-after: avoid'>
// 		This paragraph shows key aspect concerning the following results...
// 	</p>
// 	<table border=1 style='page-break-inside: avoid'>
// 		<tr>
// 			<th>implementation<th>CPU<th>overhead
// 		<tr>
// 			<td>C++<td>12<td>4
//
// 		...
//
// 	</table><?
// end_of_html(doc))
// \/code
// The above group of element (p + table) makes un unbreakable entity unless
// an overflow occurs which would force a page break to occur.\br
// Notice that the before policy and the after policy are someway related for
// a pair of contiguous elements, and a contradiction appends when an element avoids
// after page-breaks and that the following one requires before page-breaks
// (or vice versa). In case of such contradiction the avoid policy takes precedence
// over the always one.
//@cat

//      +--------+           +--------+
//      |  +--+  |           |  +--+  |
//      |  |  |  |           |  |  |  |          |
//      |  +--+  |-+---------|  +--+  |----------v--
//      |  |  |  |  \        +--------+       padding
//      |  |  |  |   `-------|  +--+  |----------^--
//      |  +--+  |           |  |  |  |          |
//      |  |  |  |           |  |  |  |  
//      |  |  |  |           |  +--+  |  


page_break_context <: ephemeral_object(
		ref_doc:pdf_document,			//<sb> pdf document target (where new pages are added)
		empty?:boolean = true,			//<sb> tell if the last operation was a page break (and not a page_add)
		page_height:float,				//<sb> the height of single page (constant)
		page_offset:float,
		page_remaining_height:float,
		current_page_height:float,
		top_paddings:list[float],
		bottom_paddings:list[float],
		entities:list[any],
		pagenum:integer = 1,
		body:html_placed_block,
		target_section:pdf_section,
		page:list[ephemeral_object])			//<sb> elements that have been placed on the current page (flat list)


		self_print(self:page_break_context) : void ->
			printf("<PG(offset ~S, Hrem ~S, [~A] [~A] [~A])",
					self.page_offset, self.page_remaining_height,
					self.entities, self.top_paddings, self.bottom_paddings)

		self_print(self:html_placed_line) : void ->
			printf("<H:~S>", self.height)
		self_print(self:html_placed_block) : void ->
			printf("<~S H:~S Y:~S>", owner(self.target), self.height, self.Y)

[not_empty!(self:page_break_context) : void ->
	self.empty? := false,
	for e in self.entities
		(case e
			(html_placed_entity
				(if not(e % self.page) self.page add e)))]

[fit_page?(pg:page_break_context, h:float) : boolean =>
	(known?(CURRENT_XOBJECT) | h < pg.page_remaining_height)]

[update_link(self:html_entity, y:float) : void ->
	when p := get(hparent, self)
	in case p
		(html_a (p.pageid := get_current_page(p.ref_doc), p.Ypage :max y),
		html_inline_element update_link(p, y))]

on_page_before :: property(open = 3)
on_page_after :: property(open = 3)

[break_page(self:page_break_context) : void ->
	if unknown?(CURRENT_XOBJECT)
		(new_page(self.ref_doc),
		try on_page_before(self.ref_doc,
						get_section_name(self.ref_doc.catalog.current_section))
		catch selector_error[selector = on_page_before] none),
	self.page_offset :+ self.page_height,
	self.page_offset :- self.page_remaining_height,
	if (unknown?(CURRENT_XOBJECT) & known?(body, self))
		self.body.height :+ self.page_remaining_height,
	for v in self.bottom_paddings
		self.page_offset :- v,
	let l := copy(self.entities),
		tm := copy(self.top_paddings),
		bm := copy(self.bottom_paddings),
		pgelems := self.page,
		len := length(pgelems)
	in (while self.entities pop_element(self),
		self.page_remaining_height := self.page_height,
		if (unknown?(CURRENT_XOBJECT) & bm)
			add_page_footer(self, bm),
		self.empty? := true,
		for i in (1 .. len)
			let e := pgelems[i]
			in case e (html_placed_block
							(if (e.target % html_table & e.add_footer?)
								insert_footer(e, self))),
		if known?(CURRENT_XOBJECT)
			(CURRENT_XOBJECT as pdf_form_xobject).xobject_elements := self.page
		else pdf_html_operation(ref_doc = self.ref_doc, html_page_elements = self.page),
		for e in self.page
			(case e
				(html_placed_line
					(for w in (e.target as html_line).words
						(case w
							(html_word_chunk update_link(w, w.Y + w.ascender),
							html_embeded_element update_link(w, w.Y)),
					if known?(CURRENT_XOBJECT)
						lazy_layout(e, -1, -1))),
				html_placed_word update_link(e.target, e.height),
				html_placed_block
					(if (e.target % html_h)
						(e.target.pageid := get_current_page(e.target.ref_doc),
						e.target.Ypage := e.Y)
					else if (e.target % html_annotation)
						(e.target.placedbox := e,
						self.ref_doc.current_page.annots add e.target.ref_annot),
					update_link(e.target, e.Y),
					if unknown?(CURRENT_XOBJECT)
						when a := get_block_a_href(e.target)
						in let lk := pdf_html_link!(e.target, a["href"])
							in (self.ref_doc.current_page.annots add lk,
								lk.linkrect := rectangle!(e.target.X, e.Y,
												e.target.X + e.target.width,
												e.Y - e.height))))),
		self.page := list<ephemeral_object>(),
		self.pagenum :+ 1,
		if (unknown?(CURRENT_XOBJECT) & bm)
			add_page_header(self),
		self.empty? := true,
		for i in (1 .. length(l))
			let e := l[i]
			in case e
				(html_placed_entity push_vertical_padding(e.target, self),
				float push_vertical_padding(self, tm[i], bm[i], 0.)),
		for v in self.top_paddings
			self.page_offset :- v),
		try on_page_after(self.ref_doc,
				get_section_name(self.ref_doc.catalog.current_section))
		catch selector_error[selector = on_page_after] none]

[set_current_page_height(self:page_break_context) : void ->
	self.current_page_height := self.page_height,
	if known?(body, self)
		self.current_page_height :-
			css_get_surrounding_top(self.body.target) +
			css_get_surrounding_bottom(self.body.target),
	if (self.target_section.footer_docs)
		let n := self.pagenum min length(self.target_section.footer_docs),
			htdoc := self.target_section.footer_docs[n]
		in self.current_page_height :- htdoc.height,
	if (self.target_section.header_docs)
		let n := self.pagenum min length(self.target_section.header_docs),
			htdoc := self.target_section.header_docs[n]
		in self.current_page_height :- htdoc.height]

[add_page_header(self:page_break_context) : void ->
	if (self.target_section.header_docs)
		let n := self.pagenum min length(self.target_section.header_docs),
			htdoc := self.target_section.header_docs[n],
			po := self.page_offset
		in (self.page_offset := self.page_height,
			place!(htdoc, self, true),
			self.page_remaining_height :- htdoc.height,
			self.page_offset := po - htdoc.height)]

[push_footer_padding(self:page_break_context) : void ->
	if self.target_section.footer_docs
		let htdoc := self.target_section.footer_docs[1]
		in push_vertical_padding(self, 0., htdoc.height, 0.)]

[add_page_footer(self:page_break_context, l:list[float]) : void ->
	let vpad := 0., tpad := 0.
	in (if (self.target_section.footer_docs)
			let len := length(self.target_section.footer_docs),
				n := self.pagenum min len,
				n+1 := (self.pagenum + 1) min len,
				htdoc := self.target_section.footer_docs[n],
				po := self.page_offset
			in (self.page_offset := htdoc.height,
				place!(htdoc, self, true),
				l[1] := self.target_section.footer_docs[n+1].height,
				self.page_offset := po))]


[place!(self:html_line, pg:page_break_context, copy?:boolean) : void ->
	not_empty!(pg),
	if copy?
		let cpy := copy(self),
			e := html_placed_line(target = cpy)
		in (cpy.words := make_list(ephemeral_object, length(self.words)),
			pg.page add e,
			e.height := self.lineheight,
			for w in self.words
				case w
					(html_word_chunk
						cpy.words add html_placed_word(target = w, X = w.X, height = w.Y + pg.page_offset),
					html_lazy_element
						let cw := copy(w)
						in (cw.Y := w.Y + pg.page_offset,
							cpy.words add cw),
					html_embeded_element
						cpy.words add html_placed_word(target = w, X = w.X, height = w.Y + pg.page_offset)))
	else
		let e := html_placed_line(target = self)
		in (e.height := self.lineheight,
			for w in self.words
				case w
					(html_word_chunk w.Y :+ pg.page_offset,
					html_embeded_element w.Y :+ pg.page_offset),
			pg.page add e)]


[place!(self:html_inline_content, pg:page_break_context, copy?:boolean) : void ->
	for l in self.lines place!(l, pg, copy?)]

[place!(self:html_entity, pg:page_break_context, copy?:boolean) : void -> none]

[place!(self:html_inline_element, pg:page_break_context, copy?:boolean) : void -> none]

[place!(self:html_table_group, pg:page_break_context, copy?:boolean) : void ->
	for c in self.hchildren place!(c, pg, copy?)]

[place!(self:html_table, pg:page_break_context, copy?:boolean) : void ->
	let e := html_placed_block(target = self)
	in (not_empty!(pg),
		e.Y := self.Y + pg.page_offset,
		e.height := self.height,
		pg.page add e,
		e.add_footer? := false,
		when x := get(thead, self) in place!(x, pg, copy?),
		for g in self.body_groups place!(g, pg, copy?),
		when x := get(tfoot, self) in place!(x, pg, copy?))]

[place!(self:html_block_element, pg:page_break_context, copy?:boolean) : void ->
	let e := html_placed_block(target = self)
	in (not_empty!(pg),
		e.Y := self.Y + pg.page_offset,
		e.height := self.height,
		pg.page add e,
		for c in self.hchildren
			place!(c, pg, copy?))]

[pop_element(pg:page_break_context) : void ->
	rmlast(pg.top_paddings),
	rmlast(pg.bottom_paddings),
	let l := pg.entities,
		len := length(l)
	in (if (len > 1)
			let elen := l[len],
				elen-1 := l[len - 1] 
			in (case elen
					(html_placed_entity
						case elen-1
							(html_placed_entity elen-1.height :+ elen.height,
							float l[len - 1] := elen-1 + elen.height),
					float
						case elen-1
							(html_placed_entity elen-1.height :+ elen,
							float l[len - 1] := elen-1 + elen)))),
	rmlast(pg.entities)]

[push_vertical_padding(pg:page_break_context, tpad:float, vpad:float, h:float) : void ->
	pg.page_remaining_height :- tpad + vpad,
	pg.top_paddings add tpad,
	pg.bottom_paddings add vpad,
	pg.entities add h]


[push_vertical_padding(self:html_line, pg:page_break_context) : void ->
	not_empty!(pg),
	let e := html_placed_line(target = self)
	in (e.height := self.lineheight,
		pg.page_remaining_height :- e.height,
		for w in self.words
			case w
				(html_word_chunk w.Y :+ pg.page_offset,
				html_embeded_element w.Y :+ pg.page_offset),
		pg.page add e,
		pg.entities add e,
		pg.top_paddings add 0.,
		pg.bottom_paddings add 0.)]

[push_vertical_padding(self:html_block_element, pg:page_break_context) : void ->
	let e := html_placed_block(target = self),
		ht := css_get_surrounding_top(self) * self.scale,
		hb := css_get_surrounding_bottom(self) * self.scale
	in (e.Y := pg.page_remaining_height,
		for v in pg.bottom_paddings
			e.Y :+ v,
		pg.page_remaining_height :- ht + hb,
		e.height := ht + hb,
		pg.entities add e,
		pg.top_paddings add ht,
		pg.bottom_paddings add hb,
		e)]

[push_vertical_padding(self:html_document, pg:page_break_context) : void ->
	push_vertical_padding@html_block_element(self, pg),
	if unknown?(CURRENT_XOBJECT)
		pg.body := last(pg.entities),
	set_current_page_height(pg)]

[push_vertical_padding(self:html_table, pg:page_break_context) : void ->
	let e := html_placed_block(target = self),
		mtop := css_scaled_get(self, css_margin-top),
		mbottom := css_scaled_get(self, css_margin-bottom),
		btop := css_scaled_get(self, css_border-top-width),
		bbottom := css_scaled_get(self, css_border-bottom-width),
		spacing := css_scaled_get(self, css_border-spacing)
	in (pg.entities add e,
		e.Y := pg.page_remaining_height,
		for v in pg.bottom_paddings
			e.Y :+ v,
		pg.top_paddings add (mtop + btop),
		when tf := get(tfoot, self) in bbottom :+ tf.height + spacing,
		pg.bottom_paddings add (mbottom + bbottom),
		pg.page_remaining_height :- mtop + btop + mbottom + bbottom,
		e.height := mtop + btop + mbottom + bbottom)]

[process_page_breaks(self:html_document, h:float, prem:float) : void ->
	let pg := page_break_context(ref_doc = self.ref_doc)
	in (pg.target_section := self.target_section,
		pg.page_height := h,
		pg.page_remaining_height := prem,
		pg.page_offset := h,
		if unknown?(CURRENT_XOBJECT)
			(push_footer_padding(pg),
			add_page_header(pg)),
		pg.empty? := true,
		process_page_breaks(self, pg),
		if not(pg.empty?) break_page(pg))]

[process_page_breaks(self:html_entity, pg:page_break_context) : void -> none]

[process_page_breaks(self:html_inline_element, pg:page_break_context) : void -> none]

[process_page_breaks(self:html_inline_content, pg:page_break_context) : void ->
	let h := 0
	in for l in self.lines
		(if not(fit_page?(pg, l.lineheight))
			break_page(pg),
		push_vertical_padding(l, pg),
		pop_element(pg))]

[process_page_breaks(self:html_block_element, pg:page_break_context) : void ->
	break_before_if_needed(self, pg),
	let h0 := self.height
	in (if lazy_layout_height(self, pg.current_page_height)
			(push_vertical_padding(pg, 0., 0., self.height),
			place!(self, pg, false),
			pop_element(pg),
			pg.page_offset :- self.height - h0,
			pg.page_remaining_height :- self.height)
		else if (not(self.hchildren) | css_get(self, css_height) != "auto")
			(if not(fit_page?(pg, self.height)) break_page(pg),
			place!(self, pg, false),
			pg.page_remaining_height :- self.height,
			push_vertical_padding(pg, 0., 0., self.height),
			pop_element(pg))
		else
			(push_vertical_padding(self, pg),
			for e in self.hchildren
				process_page_breaks(e, pg),
			pop_element(pg)))]


[fill_appearence(self:html_appearance, pg:page_break_context) : void ->
	CURRENT_XOBJECT := self.ref_xobject,
	push_resource_target(self.ref_xobject),
	let xpg := copy(pg)
	in (xpg.entities := list<any>(),
		xpg.top_paddings := list<float>(),
		xpg.bottom_paddings := list<float>(),
		xpg.page := list<ephemeral_object>(),
		place!(self, xpg, true),
		break_page(xpg)),
	CURRENT_XOBJECT := unknown,
	pop_resource_target(self.ref_doc)]


[process_page_breaks(self:html_annotation, pg:page_break_context) : void ->
	break_before_if_needed(self, pg),
	not_empty!(pg),
	when N := get(normal, self) in fill_appearence(N, pg),
	when R := get(rollover, self) in fill_appearence(R, pg),
	when D := get(down, self) in fill_appearence(D, pg),
	let e := html_placed_block(target = self, height = self.height)
	in (e.Y := pg.page_remaining_height,
		for v in pg.bottom_paddings
			e.Y :+ v,
		pg.page_remaining_height :- e.height,
		pg.page add e,
		pg.entities add e,
		pg.top_paddings add 0.,
		pg.bottom_paddings add 0.,
		pop_element(pg))]


[process_page_breaks(self:html_table_group, pg:page_break_context, spacing:float) : void ->
	if not(fit_page?(pg, self.height + spacing))
		(push_vertical_padding(pg, 0., 0., spacing),
		pop_element(pg),
		break_page(pg),
		insert_header(self.hparent, pg, true, spacing)),
	push_vertical_padding(pg, 0., 0., self.height + spacing),
	place!(self, pg, false),
	pop_element(pg),
	pg.page_remaining_height :- self.height + spacing]

[insert_header(self:html_table, pg:page_break_context, inner?:boolean, spacing:float) : void ->
	when th := get(thead, self)
	in (let po := pg.page_offset,
			ft := pg.top_paddings[length(pg.entities) - 1],
			e := pg.entities[length(pg.entities) - 1]
		in (push_vertical_padding(pg, 0., 0., th.height + spacing),
			if inner? pg.page_offset := -(th.Y) + e.Y - ft - spacing,
			place!(th, pg, true),
			if inner?
				pg.page_offset := po - th.height - spacing,
			pop_element(pg),
			pg.page_remaining_height :- th.height + spacing))]

[insert_footer(self:html_placed_block, pg:page_break_context) : void ->
	let t := self.target as html_table
	in (when tf := get(tfoot, t) 
		in let po := pg.page_offset,
				spacing := css_scaled_get(t, css_border-spacing),
				mbottom := css_scaled_get(t, css_margin-bottom),
				bbottom := css_scaled_get(t, css_border-bottom-width)
			in (pg.page_offset := -(tf.Y) + self.Y - self.height + tf.height + spacing + bbottom + mbottom,
				place!(tf, pg, true),
				pg.page_offset := po))]

[process_page_breaks(self:html_table, pg:page_break_context) : void ->
	let spacing := css_scaled_get(self, css_border-spacing),
		vmin := 3. * spacing,
		h0 := self.height
	in (break_before_if_needed(self, pg),
		if lazy_layout_height(self, pg.current_page_height)
			(push_vertical_padding(pg, 0., 0., self.height),
			place!(self, pg, false),
			pop_element(pg),
			pg.page_offset :- self.height - h0,
			pg.page_remaining_height :- self.height)
		else if fit_page?(pg, self.height)
			(push_vertical_padding(pg, 0., 0., self.height),
			place!(self, pg, false),
			pop_element(pg),
			pg.page_remaining_height :- self.height)
		else
			(if not(pg.empty?)
				(when th := get(thead, self) in vmin :+ th.height,
				when tf := get(tfoot, self) in vmin :+ tf.height,
				if self.body_groups
					vmin :+ self.body_groups[1].height,
				if not(fit_page?(pg, vmin))
					break_page(pg)),
			push_vertical_padding(self, pg),
			push_vertical_padding(pg, 0., spacing, 0.),
			insert_header(self, pg, false, spacing),
			for e in self.body_groups
				(if e.hchildren
					process_page_breaks(e, pg, spacing)),
			pop_element(pg),
			push_vertical_padding(pg, 0., 0., spacing),
			pop_element(pg),
			pop_element(pg)))]




[next_element(self:html_entity) : (html_entity U {unknown}) ->
	when p := get(hparent, self)
	in (while (p % html_inline_element) p := p.hparent,
		let pc := p.hchildren,
			len := length(pc),
			i := get(pc, self)
		in (if (i = len) next_element(p)
			else let n := pc[i + 1]
				in (case n
						(html_inline_element next_element(n),
						any n as html_entity))))
	else unknown]


[prev_element(self:html_entity) : (html_entity U {unknown}) ->
	when p := get(hparent, self)
	in (while (p % html_inline_element) p := p.hparent,
		let pc := p.hchildren,
			len := length(pc),
			i := get(pc, self)
		in (if (i = 1) prev_element(p)
			else let n := pc[i - 1]
				in (case n
						(html_inline_element prev_element(n),
						any n as html_entity))))
	else unknown]




[chain_height(self:html_inline_content, pg:page_break_context) : float ->
	if (css_get(self, css_page-break-inside) = "avoid" | not(breakable?(self)))
		self.height +
			(when n := next_element(self)
			in (case css_get(self, css_page-break-after)
				({"avoid"} chain_height(n, pg),
				{"always"} 0.,
				any (if (css_get(n, css_page-break-before) = "avoid")
						chain_height(n, pg)
					else min_height(n, pg))))
			else 0.)
	else min_height(self, pg)]

[chain_height(self:html_element, pg:page_break_context) : float ->
	if (css_get(self, css_page-break-inside) = "avoid" | not(breakable?(self)))
		(let ch := css_get(self, css_height)
		in (if (ch != "auto")
				case ch
					(css_percentage ch.value * pg.current_page_height / 100.,
					float ch,
					any self.height) else self.height)) +
			(when n := next_element(self)
			in (case css_get(self, css_page-break-after)
				({"avoid"} chain_height(n, pg),
				{"always"} 0.,
				any (if (css_get(n, css_page-break-before) = "avoid")
						chain_height(n, pg)
					else min_height(n, pg))))
			else 0.)
	else min_height(self, pg)]

[break_before_if_needed(self:html_element, pg:page_break_context) : void -> 
	if (unknown?(CURRENT_XOBJECT) & not(pg.empty?))
		(case css_get(self, css_page-break-after)
			({"always"} none,
			{"avoid"}
				(if not(fit_page?(pg, chain_height(self, pg)))
					break_page(pg)),
			any when prev := prev_element(self)
				in (let pafter := css_get(prev, css_page-break-after)
					in (if (pafter = "always")
							break_page(pg)
						else if (pafter != "avoid" & css_get(self, css_page-break-before) = "always")
							break_page(pg)
						else if not(fit_page?(pg, chain_height(self, pg)))
							break_page(pg)))
				else (if not(fit_page?(pg, chain_height(self, pg)))
						break_page(pg))))]

[min_height(self:html_entity, pg:page_break_context) : float -> 0.]

[min_height(self:html_block_element, pg:page_break_context) : float ->
	let ch := css_get(self, css_height)
	in (if (ch != "auto")
			case ch
				(css_percentage ch.value * pg.current_page_height / 100.,
				float ch,
				any self.height)
		else
			(case css_get(self, css_page-break-inside)
				({"avoid"} self.height,
				any
					(css_get_surrounding_top(self) +
							(if self.hchildren min_height(self.hchildren[1], pg)
							else 0.) +
						css_get_surrounding_bottom(self)))))]

[min_height(self:html_inline_content, pg:page_break_context) : float -> self.lines[1].lineheight]

[min_height(self:html_inline_element, pg:page_break_context) : float ->
	(if self.hchildren min_height(self.hchildren[1], pg)
	else 0.)]

[min_height(self:html_table, pg:page_break_context) : float ->
	let ch := css_get(self, css_height)
	in (if (ch != "auto")
			case ch
				(css_percentage ch.value * pg.current_page_height / 100.,
				any self.height)
		else case css_get(self, css_page-break-inside)
			({"avoid"} self.height,
			any
				let spacing := css_get(self, css_border-spacing)
				in (css_get_surrounding_top(self) +
						spacing + 
							(when th := get(thead, self) in th.height + spacing else 0.) +
						(if (self.body_groups)
							(self.body_groups[1].height + spacing)
						else 0.) +
					css_get_surrounding_bottom(self))))]

[breakable?(self:html_entity) : boolean -> false]

[breakable?(self:html_block_element) : boolean ->
	let n := 0, cb? := false
	in (for c in self.hchildren
			(case c
				(html_inline_content
					(n :+ 1,
					cb? := breakable?(c)),
				html_block_element
					(n :+ 1,
					cb? := breakable?(c))),
			if (n > 1 | cb?)
				break(true)))]

[breakable?(self:html_inline_content) : boolean -> length(self.lines) > 1]

[breakable?(self:html_inline_element) : boolean ->
	exists(c in self.hchildren|breakable?(c))]

[breakable?(self:html_table) : boolean -> length(self.body_groups) > 1]


// *********************************************************************
// *   Part 13: lazy layout of height                                  *
// *********************************************************************

[lazy_layout_height(self:html_entity, h:float) : boolean -> false]


[lazy_layout_height(self:html_block_element, h:float) : boolean ->
	let ch := css_get(self, css_height)
	in (if (ch = "auto") false
		else
			(case ch
				(css_percentage h := ch.value * h / 100.,
				float h := ch),
			h :max self.height,
			let valign := css_get(self, css_vertical-align),
				dy := self.height - h
			in (self.height := h,
				let sur := css_get_surrounding_top(self) +
								css_get_surrounding_bottom(self)
				in (for e in self.hchildren
					lazy_layout_height(e, h - sur)),
				if (dy < 0.)
					case valign
						({"middle"}
							for e in self.hchildren
								apply_translate(e, 0., 0.5 * dy),
						{"bottom"}
							for e in self.hchildren
								apply_translate(e, 0., dy)),
				true)))]


/*[lazy_layout_height(self:html_inline_content, h:float) : boolean ->
	let valign := css_get(self, css_vertical-align),
		dy := self.height - h
	in (self.height := h,
		//[0] lazy_layout_height td dy ~S // dy,
		if (dy < 0.)
			case valign
				({"middle"} apply_translate(self, 0., 0.5 * dy),
				{"bottom"} apply_translate(self, 0., dy)),
		true)]*/


[lazy_layout_height(self:html_td, h:float, y:float) : boolean ->
	if (self.Y != y) apply_translate(self, 0., y - self.Y),
	let valign := css_get(self, css_vertical-align)
	in (let sur := self.scale * css_get_surrounding_top(self) +
						self.scale * css_get_surrounding_bottom(self),
			tdh := sur
		in (self.height := h,
			for e in self.hchildren
				(lazy_layout_height(e, h - sur),
				case e
					(html_block_element tdh :+ e.height,
					html_inline_content tdh :+ e.height)),
			let dy := tdh - h
			in (if (dy < 0.)
					case valign
						({"middle"}
							for e in self.hchildren
								apply_translate(e, 0., 0.5 * dy),
						{"bottom"}
							for e in self.hchildren
								apply_translate(e, 0., dy)))),
		true)]

[lazy_layout_height(self:html_table, h:float) : boolean ->
	let ch := css_get(self, css_height)
	in (if (ch = "auto") false
		else
			(case ch
				(css_percentage h := ch.value * h / 100.,
				float h := ch),
			h :max self.height,
			self.height := h,
			let spacing := css_scaled_get(self, css_border-spacing),
				y := self.Y - self.scale * css_get_surrounding_top(self),
				sur := self.scale * css_get_surrounding_top(self) +
							float!(self.nrows + 1) * spacing +
							self.scale * css_get_surrounding_bottom(self),
				heigths := process_cell_heights(self, h - sur)
			in (for r in (1 .. self.nrows)
					(y :- spacing,
					for c in (1 .. self.ncols)
						(when td := self[r, c]
						in (if (td != self[r - 1, c] & td != self[r, c - 1])
								let  htd := 0.
								in (for s in (1 .. td.rowspan)
										(if (htd > 0.) htd :+ spacing,
										htd :+ heigths[r + s - 1]),
									lazy_layout_height(td, htd, y)))),
					y :- heigths[r]),
				y :- spacing + self.scale * css_get_surrounding_bottom(self),
				self.height := self.Y - y,
				true)))]
			

[process_cell_heights(self:html_table, total_content_height:float) : list[float] ->
	let t% := css_get(self, css_height) % css_percentage,
		nrow := self.nrows,
		heights := make_list(nrow, float, -99999999.0),
		minh := 0.,
		maxh := 0.
	in (for c in (1 .. self.ncols)
			for r in (1 .. nrow)
				(when td := self[r, c]
				in (if (td != self[r - 1, c] & td != self[r, c - 1])
						let h := css_get(td, css_height)
						in (case h
								(css_percentage
									(if (h.value <= 100. & h.value >= 0.)
										heights[r] :max h.value * total_content_height / 100.),
								float
									(if (h > 0.)
										heights[r] :max h),
								any heights[r] :max -(td.height))))),
		for c in (1 .. nrow)
			(if (heights[c] < 0.)
				(minh :+ -(heights[c]),
				maxh :+ -(1.0001 * heights[c]))),
		let h% := 0.,
			n% := 0
		in (for c in (1 .. nrow)
				(if (heights[c] > 0.)
					(h% :+ heights[c],
					n% :+ 1)),
			if (t% & h% + maxh < total_content_height)
				let W := (total_content_height - h% - maxh),
					D := (maxh - minh)
				in for c in (1 .. nrow)
					(if (heights[c] < 0.)
						let cmax := -(1.0001 * heights[c]),
							d := (cmax - -(heights[c]))
						in heights[c] :=  cmax + d * W / D)
			else if (h% + minh > total_content_height)
				let c% := (h% + minh - total_content_height) / float!(n%)
				in for c in (1 .. nrow)
					(if (heights[c] < 0.) heights[c] := -(heights[c]))
			else if (h% + maxh < total_content_height)
				for c in (1 .. nrow)
					(if (heights[c] < 0.)
						heights[c] := -(1.0001 * heights[c]))
			else if (n% < nrow)
				let W := (total_content_height - h% - minh),
					D := (maxh - minh)
				in for c in (1 .. nrow)
					(if (heights[c] < 0.)
						let cmin := -(heights[c]),
							d := (-(1.0001 * heights[c]) - cmin)
						in heights[c] :=  cmin + d * W / D)),
		heights)]

	
// *********************************************************************
// *   Part 13: debug annots                                           *
// *********************************************************************

[print_dom_path(self:html_entity, fz:integer) : void ->
	if known?(hparent, self) print_dom_path(self.hparent, fz - 1),
	?><font style='font-size: <?= fz ?>pt'><?
	case self
		(html_element printf("~A", get(element_name, self)),
		html_word_chunk princ("#text")),
	if (fz != 20) princ("&nbsp;<b>&gt;</b> ")
	?></font><? ]

[draw_bound(self:pdf_document, e:html_entity, pw:float, ph:float, x:float, y:float, w:float, h:float) : void ->
	case e
		(html_word_chunk
			(princ("q 0.3 w 0.8 0.2 0.3 RG "),
			printf("0~I m ~I~I l S Q ", self_float(e.Y), self_float(pw), self_float(e.Y))),
		html_lazy_element
			(princ("q 0.3 w 0.8 0.2 0.3 RG "),
			printf("0~I m ~I~I l S Q ", self_float(e.Y), self_float(pw), self_float(e.Y)))),
	princ("q 0.3 w 0.6 0.6 0.6 RG"),
	printf("~I 0~I~I re S", self_float(x), self_float(w), self_float(ph)),
	printf(" 0~I~I~I re S", self_float(y - h), self_float(pw), self_float(h)),
	printf(" 1 w 0 0 1 RG~I~I~I~I re S Q", self_float(x), self_float(y - h), self_float(w), self_float(h))]

[draw_info(self:pdf_page, e:html_entity, pw:float, ph:float, x:float, y:float, w:float, h:float) : void ->
	?><style>body {font-size:7pt} table {border-collapse:collapse} td {padding:0 3 0 3}</style><?
	?><script language="javascript">function init() { window.resizeTo(450, 700);}</script><?
	?><body  OnLoad="javascript: init()"><?
	?><h2><? print_dom_path(e, 20) ?></h2><?
	?><table border=1 cellpadding=2><tr bgcolor="#DDDDDD"><th>Page<th>Scale<th>X<th>Y<th>Width<th>Height<?
		?><tr><td><?= self.pagenum ?><td><?= e.scale ?><td><?= x ?><td><?= y ?><td><?= w ?><td><?= h
	?></table><br><?
	?><table border=1 cellpadding=2><?
	css_debug_cascade(e)
	?></table></body><? ]

[create_debug_annot(self:pdf_page, x:float, y:float, w:float, h:float) : tuple(pdf_debug_xobject,pdf_embedded_file) ->
	if unknown?(acro_form, self.doc.catalog)
		self.doc.catalog.acro_form := pdf_interactive_form(doc = self.doc),
	let sec := self.doc.catalog.current_section,
		d := sec.dim,
		rollannot := pdf_button(doc = self.doc,
							pageid = self.id,
							debug_box = rectangle!(0., d.top, d.right, 0.)),
		debugfile := pdf_embedded_file(doc = self.doc,
											ignoredate? = true,
											inline_data = blob!(),
											mimetype = "text/html"),
		fspec := pdf_filespec(doc = self.doc, adbeid = uid(), embeddedfile = debugfile),
		shannot := pdf_show_hide_button(doc = self.doc,
							pageid = self.id,
							rollover = rollannot,
							debug_file = fspec,
							debug_box = rectangle!(x, y, x + w, y - h))
	in (fspec.name := "debug" /+ string!(fspec.id) /+ ".html",
		self.doc.catalog.names.embeddedfiles add fspec,
		self.annots add rollannot,
		self.annots add shannot,
		self.doc.catalog.acro_form.fields :add rollannot,
		self.doc.catalog.acro_form.fields :add shannot,
		let rollxo := pdf_debug_xobject(doc = self.doc, deflate? = false)
		in (rollannot.ref_xobject := rollxo,
			tuple(rollxo, debugfile)))]

[push_debug_xobject(self:pdf_debug_xobject) : port ->
	CURRENT_XOBJECT := self,
	push_resource_target(self),
	self.datastream := blob!(),
	use_as_output(self.datastream)]

[push_debug_xobject(self:pdf_embedded_file) : port ->
	use_as_output(self.inline_data)]

[draw_debug_annot(pg:pdf_page, self:html_entity, pw:float, ph:float) : void -> none]

[draw_debug_annot(pg:pdf_page, self:html_word_chunk, pw:float, ph:float) : void ->
	let (r,d) := create_debug_annot(pg, self.X, self.Y + self.ascender, self.width, self.height),
		old := push_debug_xobject(r)
	in (CURRENT_XOBJECT := r,
		draw_bound(pg.doc, self, pw, ph, self.X, self.Y + self.ascender, self.width, self.height),
		pop_resource_target(pg.doc),
		CURRENT_XOBJECT := unknown,
		push_debug_xobject(d),
		draw_info(pg, self, pw, ph, self.X, self.Y + self.ascender, self.width, self.height),
		use_as_output(old))]


[draw_debug_annot(pg:pdf_page, self:html_embeded_element, pw:float, ph:float) : void ->
	let (r,d) := create_debug_annot(pg, self.X, self.Y, self.width, self.height),
		old := push_debug_xobject(r)
	in (CURRENT_XOBJECT := r,
		draw_bound(pg.doc, self, pw, ph, self.X, self.Y, self.width, self.height),
		pop_resource_target(pg.doc),
		CURRENT_XOBJECT := unknown,
		push_debug_xobject(d),
		draw_info(pg, self, pw, ph, self.X, self.Y, self.width, self.height),
		use_as_output(old))]

[draw_debug_annot(pg:pdf_page, self:html_lazy_element, pw:float, ph:float) : void ->
	let (r,d) := create_debug_annot(pg, self.X, self.Y + self.ascender, self.width, self.height),
		old := push_debug_xobject(r)
	in (CURRENT_XOBJECT := r,
		draw_bound(pg.doc, self, pw, ph, self.X, self.Y + self.ascender, self.width, self.height),
		pop_resource_target(pg.doc),
		CURRENT_XOBJECT := unknown,
		push_debug_xobject(d),
		draw_info(pg, self, pw, ph, self.X, self.Y + self.ascender, self.width, self.height),
		use_as_output(old))]

[draw_debug_annot(pg:pdf_page, self:html_placed_word, pw:float, ph:float) : void ->
	let (r,d) := create_debug_annot(pg, self.X, self.height + self.target.ascender, self.target.width, self.target.height),
		old := push_debug_xobject(r)
	in (CURRENT_XOBJECT := r,
		draw_bound(pg.doc, self.target, pw, ph, self.X, self.height + self.target.ascender, self.target.width, self.target.height),
		pop_resource_target(pg.doc),
		CURRENT_XOBJECT := unknown,
		push_debug_xobject(d),
		draw_info(pg, self.target, pw, ph, self.X, self.height + self.target.ascender, self.target.width, self.target.height),
		use_as_output(old))]

[draw_debug_annot(pg:pdf_page, self:html_placed_block, pw:float, ph:float) : void ->
	let (r,d) := create_debug_annot(pg, self.target.X, self.Y, self.target.width, self.height),
		old := push_debug_xobject(r)
	in (draw_bound(pg.doc, self.target, pw, ph, self.target.X, self.Y, self.target.width, self.height),
		pop_resource_target(pg.doc),
		CURRENT_XOBJECT := unknown,
		push_debug_xobject(d),
		draw_info(pg, self.target, pw, ph, self.target.X, self.Y, self.target.width, self.height),
		use_as_output(old))]

[draw_debug_annot(pg:pdf_page, self:html_placed_line, pw:float, ph:float) : void ->
	for w in (self.target as html_line).words
		case w
			(html_placed_word
				(if (css_get(w.target, css_debug) = "yes")
					draw_debug_annot(pg, w, pw, ph)),
			html_entity
				(if (css_get(w, css_debug) = "yes")
					draw_debug_annot(pg, w, pw, ph)))]


[create_debug_annots(self:pdf_page, ops:pdf_html_operation) : void ->
	let sec := self.parent
	in (for e in ops.html_page_elements
			(case e
				(html_placed_line
					draw_debug_annot(self, e, sec.dim.right, sec.dim.top),
				html_entity
					(if (css_get(e, css_debug) = "yes")
						draw_debug_annot(self, e, sec.dim.right, sec.dim.top)),
				html_placed_entity
					(if (css_get(e.target, css_debug) = "yes")
						draw_debug_annot(self, e, sec.dim.right, sec.dim.top)))),
		sec.inside_html_area? := false)]


// *********************************************************************
// *   Part 13: inserting html content                                 *
// *********************************************************************


//<sb> take the current html document of the section and dispatch
// it on section pages
[render_section(self:pdf_section) : void ->
	//[1] render section,
	let cur := self.doc.catalog.current_section
	in when htdoc := get(current_html_document, self)
		in (set_current_section(self),
			auto_layout_html(htdoc, self.dim.right, self.dim.height),
			process_page_breaks(htdoc, self.dim.height, self.dim.height),
			erase(current_html_document, self),
			set_current_section(cur))]



[render_sections(self:pdf_document) : void ->
	for s in self.section_order
		render_section(s[2])]


//<sb> concat an HTML data stream to the current section of
// the PDF document
[insert_html(self:pdf_document, p:port) : void ->
	let sec := self.catalog.current_section
	in (if unknown?(current_html_document, sec)
			(sec.current_html_document := html_document(ref_doc = self, element_name = "body"),
			sec.current_html_document["section"] := get_section_name(sec),
			build_css_styler(self.style_sheet, sec.current_html_document)),
		parse_html(p, sec.current_html_document))]


[insert_html_xobject(self:pdf_document, p:port, n:string, v:string) : tuple(float,float) =>
	let rect := get_page_rect(self)
	in insert_html_xobject(self, p, n, v, width(rect))]

[insert_html_xobject(self:pdf_document, p:port, n:string, v:string, wdth:float) : tuple(float,float) ->
	let sec := self.catalog.current_section,
		xo := pdf_form_xobject(doc = self),
		xold := CURRENT_XOBJECT,
		htdoc := (push_resource_target(xo),
				html_document(ref_doc = self, element_name = "xobjectbody"))
	in (build_css_styler(self.style_sheet, htdoc),
		self.xobject_map[n, v] := xo,
		xo.src := htdoc,
		CURRENT_XOBJECT := xo,
		set_index(p, 0),
		parse_html(p, htdoc),
		auto_layout_html(htdoc, wdth, self.catalog.current_section.dim.height),
		process_page_breaks(htdoc, 0., 0.),
		pop_resource_target(self),
		CURRENT_XOBJECT := xold,
		tuple(htdoc.width, htdoc.height))]

(interface(auto_layout))
(interface(process_min_max_widths))


// *********************************************************************
// *   Part 14: element substitution                                   *
// *********************************************************************


// @cat User defined HTML elements
// @alias extensibility
// The dictionary of handled element may be extended. For a given element name
// we may define a substitution handler that describes the stream substituted
// in place of the element so that such element always relies on core elements.
// This is a convenient way to add new elements definition while being smoothly
// handled by the auto-layout and auto page-break engines. Substitution is used to
// implement block-quotes lists and bullet, and soonly you're own definitions...\br
// The substitution is achieve inside general html element handlers that would
// defaults to all unknown elements. When a candidate restriction of substitution
// handlers (begin_substitution/end_substitution) is found for the requested element
// name, it is applied with an additional context arguments that may be handle with
// the above methods. Contexts are organized in a chained list, only made of substituted
// elements. This hides to the user the hierarchy of elements that are added by the
// substitution handler, the parent element from the context point of view is the first
// (if any) actual parent element that has itself been substituted.\br
// The context also contain the table of attribute such that the substituted element may
// have its own attribute handling. The bracket notation may be used to get an attribute
// value.
// In some situation it is also necessary to transmit a value to a related sub element, in
// such situation one may use the context to store a per-context userdata
// (see lists implementation for a sample usage).
// @cat

// @doc extensibility
begin_substitution :: property(open = 3)
// @doc extensibility
end_substitution :: property(open = 3)

begin_substitution(self:pdf_document, tag:string, e:element_context) : void -> none
end_substitution(self:pdf_document, tag:string, e:element_context) : void -> none


//<sb> for that task, we use an element context given as a parameter
// of substitution handler
element_context <: ephemeral_object(
				userdata:any,
				parser_input:port,
				element:html_element,
				parent_context:element_context)


[html_begin_element(tag:string, data:html_element) : any ->
	let x:any := data
	in (while (known?(x) & not(x % html_substitution))
			x := get(hparent, x),
		let ctx := element_context(),
			s := html_substitution(hparent = data, context = ctx)
		in (ctx.element := s,
			case x
				(html_substitution
					s.context.parent_context := x.context),
			s))]

[apply_begin_substitution(self:html_substitution, pi:port) : html_element ->
	let p := blob!(),
		old := use_as_output(p)
	in (self.context.parser_input := pi,
		apply(begin_substitution, list(self.ref_doc, self.element_name, self.context)),
		if (length(p) > 0)
			let res := internal_parse_html(p, self)
			in (use_as_output(old),
				fclose(p),
				case res
					(html_block_element res,
					any
						(add_pseudo_after(res),
						self.hparent)))
		else (use_as_output(old),
				fclose(p),
				self.hparent))]

[html_end_element(tag:string, data:html_element) : html_element ->
	let x:any := data
	in (while (known?(x) & not(x % html_substitution & x.element_name = tag))
			x := get(hparent, x),
		case x
			(html_substitution
				let p := blob!(),
					old := use_as_output(p)
				in (apply(end_substitution, list(x.ref_doc, tag, x.context)),
					let res := internal_parse_html(p, data)
					in (use_as_output(old),
						fclose(p),
						add_pseudo_after(x),
						x.hparent)),
			any data))]

begin_substitution(self:pdf_document, tag:{"style"}, ctx:element_context) : void ->
	let s := trim(freadline(ctx.parser_input, "</style>", false))
	in (if (length(s) > 0)
			let b := blob!(s)
			in (read_css(self.style_sheet, b),
				fclose(b)))

begin_substitution(self:pdf_document, tag:{"script"}, ctx:element_context) : void ->
	freadline(ctx.parser_input, "</script>", false)

begin_substitution(self:pdf_document, tag:{"head"}, ctx:element_context) : void ->
	let (dum, st?) := freadline(ctx.parser_input, {"<style>", "</head>"}, false)
	in (if (st? = "<style>")
			(begin_substitution(self, "style", ctx),
			freadline(ctx.parser_input, "</head>", false)))
			


/*
//<sb> here are tool to simplify the usage of the context in
// subtitution handlers

//<sb> attribute access can be made with this sugar
[nth(e:element_context, attr:string) : string ->
	when v := e.attributes[attr]
	in v as string else ""]

[nth(e:element_context, attr:string, def:string) : string ->
	when v := e.attributes[attr]
	in v as string else def]

// @doc extensibility
[get_element_name(e:element_context) : string => e.element_tag]
// @doc extensibility
[get_user_data(e:element_context) : any => get(userdata, e)]
// @doc extensibility
[set_user_data(e:element_context, data:any) : void => e.userdata := data]
// @doc extensibility
[get_styler(e:element_context) : pdf_styler => e.parent_data.style]
// @doc extensibility
[get_document(e:element_context) : pdf_document => e.ref_doc]


//<sb> get a safe parent context given its tag
// @doc extensibility
[get_parent(e:element_context, tag:string) : element_context ->
	let p := get(parent_context, e)
	in (if unknown?(p)
			error("substitution hierarchy corrupted, can't find a <~A> parent for <~A>",
					tag, e.element_tag),
		if (p.element_tag != tag) get_parent(p, tag)
		else p as element_context)]

// @doc extensibility
[get_parent(e:element_context) : element_context =>
	let p := get(parent_context, e)
	in (if unknown?(p)
			error("substitution context invalid, <~A> has no parent !", e.element_tag),
		p as element_context)]

//<sb> get a safe parent context that have a tag in tags
// @doc extensibility
[get_parent(e:element_context, tags:subtype[string]) : element_context ->
	let p := get(parent_context, e)
	in (if unknown?(p)
			error("substitution context invalid, <~A> isn't a child of <~A> (one of ~S expected)",
					e.element_tag, p.element_tag, tags),
		if not(p.element_tag % tags) get_parent(p, tags)
		else p as element_context)]

//<sb> print back an argument in the current stream
// @doc extensibility
[relayed_attr(e:element_context, attr:string) : void -> relayed_attr(e, attr, "")]
// @doc extensibility
[relayed_attr(e:element_context, attr:string, def:string) : void ->
	when v := e.attributes[attr]
	in printf(" ~A=\"~A\"", attr, v)
	else
		(if (length(def) > 0)
			printf(" ~A=\"~A\"", attr, def))]

//<sb> or a list of arguments
// @doc extensibility
[relayed_attr(e:element_context, attrs:subtype[string]) : void ->
	for s in attrs
		relayed_attr(e, s)]

//<sb> or any arguments
// @doc extensibility
[relayed_attr(e:element_context) : void ->
	let g := e.attributes.mClaire/graph
	in for i in (1 .. length(g) - 1)
		(if (i mod 2 = 1 & known?(g[i + 1]))
			printf(" ~A=\"~A\"", g[i], g[i + 1]))]

//<sb> the attribute is printed back after having translated its name
// @doc extensibility
[translated_attr(e:element_context, attr:string, newname:string) : void ->
	translated_attr(e, attr, newname, "")]
// @doc extensibility
[translated_attr(e:element_context, attr:string, newname:string, def:string) : void ->
	when v := e.attributes[attr]
	in printf(" ~A=\"~A\"", newname, v)
	else
		(if (length(def) > 0)
			printf(" ~A=\"~A\"", newname, def))]



// *********************************************************************
// *   Part 15: substituted elements                                   *
// *********************************************************************

*/


// Here is the fill_area handler for bullet, the size of the bullet
// is inferred by the height a lower 'x' character in the current font,
// note that we have to manually handle the spacing before attribute
// of the element styler such that the bullet would be vertically
// aligned with the text.
[fill_area(self:pdf_document, ctx:html_bullet, w:float, h:float) : tuple(float, float) ->
	let c := css_get(ctx, css_color),
		f := css_get_font(ctx),
		sz := css_get(ctx, css_font-size),
		asc := get_baseline(self, f, sz),
		xh := get_xheight(self, f, sz),
		r := rectangle!(0.8 * xh, 0.8 * xh)
	in (push_state(self),
		move(self, 0.5 * xh, 0.5 * xh), // translate to the bullet center
		case ctx.bullet_type // draw the bullet as the specified shape
			({"circle"} stroked_circle(self, r, 0.1 * sz, c),
			{"square"} filled_rectangle(self, r, c),
			{"rectangle"} stroked_rectangle(self, r, 0.1 * sz, c),
			{"triangle"} filled_triangle(self, r, c),
			{"disc"} filled_circle(self, r, c),
			{"star"} filled_star(self, r, c),
			any filled_quad(self, r, c)),
		pop_state(self),
		tuple(xh, asc))]



//<sb> handling dynamic elements that depends on document
// user data
/*
user_img :: property(open = 3)
user_text :: property(open = 3)

begin_substitution(doc:pdf_document, self:{"user_img"}, e:element_context) : void ->
	let id := e["id", ""]
	in (if unknown?(doc_userdata, doc)
			error("Failed to add a user image since document user data is unknown (see set_user_data)."),
		if (length(id) = 0)
			error("Failed to add a user image since the id attribute is unknown."),
		?><img <? relayed_attr(e) ?> src="<?= user_img(doc.doc_userdata, id) ?>"><? )

begin_substitution(doc:pdf_document, self:{"user_text"}, e:element_context) : void ->
	let id := e["id", ""]
	in (if unknown?(doc_userdata, doc)
			error("Failed to add a user image since document user data is unknown (see set_user_data)."),
		if (length(id) = 0)
			error("Failed to add a user image since the id attribute is unknown."),
		?><?== user_text(doc.doc_userdata, id) ?><? )

*/