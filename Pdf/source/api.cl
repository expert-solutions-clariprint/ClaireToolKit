
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * api.cl                                                            *
// * Copyright (C) 2000 - 2004 xl. All Rights Reserved                 *
// *********************************************************************


// *********************************************************************
// *   Part 1: document                                                *
// *   Part 2: page                                                    *
// *   Part 3: sections                                                *
// *   Part 4: annotation                                              *
// *   Part 5: graphic state                                           *
// *   Part 6: path construction                                       *
// *   Part 7: text objects                                            *
// *   Part 8: color                                                   *
// *   Part 9: images                                                  *
// *   Part 10: html objects                                           *
// *   Part 11: signature                                              *
// *   Part 12: automated TOC                                          *
// *********************************************************************


// *********************************************************************
// *   Part 1: document                                                *
// *********************************************************************

// @cat document
// The whole writer API relies on a document object of class pdf_document.
// To create a new PDF document we would call document! and give
// a page format, margin and orientation :
// \code
// doc :: Pdf/document!(
// 		"A4",		// format
// 		false,		// landscape?
// 		5)			// margin in %tage of the format
// \/code
// The format is given as a string and may be one of the following format :
// \ul
// \li 4A0, 2A0
// \li A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10
// \li B0, B1, B2, B3, B4, B5, B6, B7, B8, B9, B10
// \li C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10
// \li RA0, RA1, RA2, RA3, RA4
// \li SRA0, SRA1, SRA2, SRA3, SRA4
// \li LETTER, LEGAL, EXECUTIVE, FOLIO
// \/ul
// Once a document as been filled with section and pages, texts (etc...) it would be
// rendered and printed on a port or saved to a file :
// \code
// (Pdf/print_in_port(doc, stdout))
// (Pdf/print_in_file(doc, "test.pdf"))
// \/code
// @cat

unknown_element :: mClaire/new!(html_element)

[close(self:pdf_document) : pdf_document ->
	self.creation_date := now(),
	self.info := pdf_info(doc = self),
	self.font_map := make_table(integer, (font_descriptor U {unknown}), unknown),
	self.xobject_map := make_table(tuple(string,string), (pdf_form_xobject U {unknown}), unknown),
	self.catalog := pdf_catalog(doc = self),
	self.catalog.names := pdf_names(doc = self),
	self.catalog.page_tree_root := pdf_page_tree(doc = self),
	self.html_name_map := make_table(string, html_element U {unknown}, unknown),
	new_section(self, "body"),
	set_dimension(self.catalog.current_section, self.page_format),
	if self.landscape?
		let r := self.catalog.current_section.dim,
			c := copy(r)
		in (r.left := c.bottom,
			r.right := c.top,
			r.top := c.right,
			r.bottom := c.left),
	if (self.left_margin < 0.0)
		let p% := -(self.left_margin),
			r := self.catalog.current_section.dim
		in (self.left_margin := (r.right - r.left) * p% / 100.,
			self.right_margin := self.left_margin,
			self.top_margin := (r.top - r.bottom) * p% / 100.,
			self.bottom_margin := self.top_margin),
	load_core_css(self),
	self]



// @doc document
// document!() creates a document instance with the format "A4" and no
// margins.
[document!() : pdf_document => pdf_document()]



// @doc document
// document!(s, lndscp?) creates a document instance with the
// format s, with the landscape orientation when lndscp? is true and with
// no margins.
[document!(s:string, lndscp?:boolean) : pdf_document =>
	pdf_document(page_format = s, landscape? = lndscp?)]

// @doc document
// document!(c, s, lndscp?) creates a document instance with the
// format s, with the landscape orientation when lndscp? is true and with
// no margins. c is a class that should inherit from pdf_document.
[document!(c:class, s:string, lndscp?:boolean) : pdf_document =>
	let doc := unknown
	in (if (c inherit? pdf_document)
			(doc := mClaire/new!(c),
			(doc as pdf_document).page_format := s,
			(doc as pdf_document).landscape? := lndscp?,
			close(doc as pdf_document))
		else error("document! error, ~S is not a descendent of pf_document", c),
		doc as pdf_document)]


[set_user_data(self:pdf_document, ud:any) : void => self.doc_userdata := ud]

// @doc document
// print_in_port(self, f) renders the current state of given document self
// in the PDF format and save it in a file.
[print_in_port(self:pdf_document, f:port) : void ->
	let p := use_as_output(f)
	in (self_pdf(self),
		use_as_output(p))]

// @doc document
// print_in_file(self, f) renders the current state of given document self
// in the PDF format and save it in a file.
[print_in_file(self:pdf_document, f:string) : void ->
	let fd := fopen(f, "w"),
		p := use_as_output(fd)
	in (self_pdf(self),
		use_as_output(p),
		fclose(fd))]



[stream(self:pdf_document, filename:string) : void ->
	eval(read("
		(force_content_length(),
		header(\"Content-Type: application/pdf\"),
		header(\"Content-Disposition: inline; filename=\\\"" /+ filename /+ "\\\"\"))")),
	self_pdf(self)]

[stream(self:pdf_document) : void => stream(self, "file.pdf")]

// *********************************************************************
// *   Part 2: page                                                    *
// *********************************************************************

// @cat section
// In this implementation the pdf_document object is organized in named sections
// each one having their own index of contained pages, a document has at least one
// section and one page. Once a document is created we have to
// create a new section (e.g. section "body") and create a new page in order to have
// a valid page target for all operations performed on the document :
// \code
// (Pdf/new_section(doc, "body")) // may be omitted
// (Pdf/new_page(doc)) // page 1 of section "body"
// \/code
// Notice that the section body exists by default when a document is created with
// document!. Calling new_section with a name that already exists as a section name
// would only select that section as the current section (section name unicity).\br
// All operations performed with the low level API will take place in the current page
// of the current section, these current section/page may be selected and set by hand
// provided the following methods :
// \code
// (Pdf/set_current_section(doc, "some section"))
// (Pdf/set_current_page(doc, 2))
// 
// (assert(Pdf/get_current_section(doc) = "some section"))
// (assert(Pdf/get_current_page(doc) = 2))
// \/code
// Some error would be raised if the set section name or page index is wrong.\br
// Each section have its own representation of the current page so that changing
// the current section would also restore the current page of that section.
// @cat

[new_page_content(self:pdf_document) : pdf_document ->
	self.current_content := pdf_content(doc = self, page = self.current_page),
	self.current_page.contents :add self.current_content,
	self]

// @doc page
// new_page(self) is either called by hand or remotely by another page
// creator API and would call the page_created callback once the page
// is properly inserted. The new page is always appended at the end of
// document with a new page index that is returned. At return the index
// is the amount of page in the document :
[new_page(self:pdf_document) : integer ->
	let pages := self.catalog.current_section,
		p := pdf_page(doc = self, parent = pages)
	in (self.current_page := p,
		self.pagecount :+ 1,
		new_page_content(self),
		try
			(if page_created.restrictions
				page_created(self, get_current_section(self), p.id))
		catch selector_error[selector = page_created] none,
		for a in self.pending_annots
			p.annots :add a,
		shrink(self.pending_annots, 0),
		p.id)]


// @doc page
// insert_page_after(self, pid) creates a new page and moves it just after
// the page with index pid.
[insert_page_after(self:pdf_document, pid:integer) : integer ->
	let pgs := self.catalog.current_section.kids,
		np := 0
	in (when i := some(i in (1 .. length(pgs))|pgs[i].id = pid)
		in (np := new_page(self),
			nth-(pgs, length(pgs)),
			nth+(pgs, i + 1, self.current_page))
		else error("Invalid page id ~S for insert_page_after", pid),
		np)]

// @doc page
// insert_page_after(self, pid) creates a new page and moves it just before
// the page with index pid in the current section of the given document.
[insert_page_before(self:pdf_document, pid:integer) : integer ->
	let pgs := self.catalog.current_section.kids,
		np := 0
	in (when i := some(i in (1 .. length(pgs))|pgs[i].id = pid)
		in (np := new_page(self),
			nth-(pgs, length(pgs)),
			nth+(pgs, i, self.current_page))
		else error("Invalid page id ~S for insert_page_before", pid),
		np)]


// @doc page
// set_current_page(self, pid) selects the page with index pid in the
// current section of the given document.
[set_current_page(self:pdf_document, pid:integer) : void ->
	let pgs := self.catalog.current_section.kids
	in when i := some(i in (1 .. length(pgs))|pgs[i].id = pid)
	in (self.current_page := pgs[i],
		self.current_content := last(self.current_page.contents))
	else error("Invalid page id ~S for set_current_page", pid)]

[set_current_page(self:pdf_document, p:pdf_page) : void ->
	self.catalog.current_section := p.parent,
	self.current_page := p,
	self.current_content := last(p.contents)]


// @doc page
// get_page_rect(self) return the rectangle that correspond to the
// given document's page format accounted of document's margins.
[get_page_rect(self:pdf_document) : rectangle ->
	let r := self.catalog.current_section.dim
	in rectangle!(r.left + self.left_margin,
					r.top - self.top_margin,
					r.right - self.right_margin,
					r.bottom + self.bottom_margin)]

// @doc page
// get_page_rect(self) return the rectangle that correspond to the
// given document's page format (not accounted of document's margins).
[get_page_full_rect(self:pdf_document) : rectangle ->
	copy(self.catalog.current_section.dim)]


// @doc page
// get_current_page(self) returns the current page index in the
// current section of the given document.
[get_current_page(self:pdf_document) : integer =>
	self.current_page.id]

// @doc page
// get_page_count(self) returns the amount of page in the
// current section of the given document.
[get_page_count(self:pdf_document) : integer =>
	length(self.catalog.current_section.kids)]

[update_page_number(self:pdf_document) : void ->
	let pn := 1
	in (for sec in self.section_order
			for p in sec[2].kids
				(p.pagenum := pn,
				pn :+ 1),
		for sec in self.section_order
			for p in sec[2].kids
				for ct in p.contents
					for htmlop in list{hto in ct.operations|hto % pdf_html_operation}
						(for e in htmlop.html_page_elements
							case e
								(html_placed_line
									(lazy_layout(e, p.pagenum, self.pagecount),
									create_links(e.target, p))),
						create_debug_annots(p, htmlop)))]


[get_page_num(self:pdf_document, pid:integer) : integer ->
	let pn := 0
	in (for sec in self.section_order
			for p in sec[2].kids
				(pn :+ 1,
				if (p.id = pid)
					break()),
		pn)]

[get_element_page_info(self:pdf_document, hte:html_element) : tuple(integer, integer, float) ->
	let pnum := 0,
		pid := 0,
		y := 0.
	in (try
			for sec in self.section_order
				for p in sec[2].kids
					for ct in p.contents
						for htmlop in list{hto in ct.operations|hto % pdf_html_operation}
							(for e in htmlop.html_page_elements
								case e
									(html_placed_entity
										(if (e.target = hte)
											(pnum := p.pagenum,
											pid := p.id,
											y := e.Y,
											contradiction!()))))
		catch contradiction none,
		tuple(pid, pnum, y))]

// *********************************************************************
// *   Part 3: sections                                                *
// *********************************************************************

//<sb> In Pdf we may define nested "page trees". In this implementation
// We use two level of page tree : one at the document level and a second
// one at the section level.


// @doc section
[new_section(self:pdf_document, secname:string) : void ->
	when sec := some(sec in self.section_order | sec[1] = secname)
	in (self.catalog.current_section := sec[2],
		set_resource_target(sec[2]))
	else let sec := pdf_section(doc = self, section_root = self.catalog)
		in (//[0] add section with section_root = ~S // self.catalog,
			set_resource_target(sec),
			self.section_order :add tuple(secname, sec),
			set_dimension(sec, self.page_format),
			self.catalog.current_section := sec)]


// @doc section
// new_section_before(self, secname, bef) creates a new section with name secname that
// is inserted to the list of doc's sections just before the section
// with bef.
[new_section_before(self:pdf_document, secname:string, bef:string) : void ->
	when i := some(i in (1 .. length(self.section_order)) | self.section_order[i][1] = bef)
	in let sec := pdf_section(doc = self, section_root = self.catalog)
		in (set_dimension(sec, self.page_format),
			set_resource_target(sec),
			nth+(self.section_order, i, tuple(secname, sec)),
			self.catalog.current_section := sec)
	else error("new_section_before error, there is no section named ~A", bef)]

// @doc section
// new_section_after(self, secname, aft) creates a new section with name secname that
// is inserted to the list of doc's sections just after the section
// with name aft.
[new_section_after(self:pdf_document, secname:string, aft:string) : void ->
	when i := some(i in (1 .. length(self.section_order)) | self.section_order[i][1] = aft)
	in let sec := pdf_section(doc = self, section_root = self.catalog)
		in (set_dimension(sec, self.page_format),
			set_resource_target(sec),
			nth+(self.section_order, i, tuple(secname, sec)),
			self.catalog.current_section := sec)
	else error("new_section_after error, there is no section named ~A", aft)]

// @doc section
[get_current_section(self:pdf_document) : string ->
	when i := some(i in self.section_order | i[2] = self.catalog.current_section)
	in i[1]
	else (error("get_current_section, internal error"),
			"")]

[get_section_name(self:pdf_section) : string ->
	when i := some(i in self.doc.section_order | i[2] = self)
	in i[1]
	else (error("get_section_name, internal error"), "")]

// @doc section
// get_section_names(self) returns the list of section name that are currently defined
// in the given document.
[get_section_names(self:pdf_document) : list[string] ->
	list<string>{i[1]|i in self.section_order}]

// @doc section
[set_current_section(self:pdf_document, secname:string) : void ->
	when i := some(i in self.section_order | i[1] = secname)
	in (self.catalog.current_section := i[2],
		set_resource_target(i[2]))
	else error("set_current_section error, there is no section named ~A", secname)]

[set_current_section(self:pdf_section) : void ->
	self.doc.catalog.current_section := self,
	set_resource_target(self)]

// *********************************************************************
// *   Part 4: annotation                                              *
// *********************************************************************

// @cat attachment
// The PDF file format defines a way to embed file contents that could be
// extracted by a reader application. This is called attachment. Two methods are
// provided to insert a new attachment to the document. These two methods
// would add a new invisible attachment, i.e. without a visual appearance.
// When an attachment is submitted we have to specify a mime type for the
// attached file (e.g. "text/plain") :
// \code
// (Pdf/add_attachment(doc, "data.xml", "text/xml"))
// \/code
// Or, in a callback (a restriction of fill_attachment) oriented way with a
// submitted user data, this data will be used for the callback selection as in :
// \code
// Pdf/fill_attachment(usrdata:{1}, f:port) ->
// 		ptinrf(f, "Hello wolrd!")
//
// (Pdf/add_attachment(doc, "hello.txt", "text/plain", 1))
// \/code
// Notice that the fill_attachment callback will be called when
// the document is rendered either by print_in_port or print_in_file.
// @cat

// @doc Invisible attachments
[add_attachment(self:pdf_document, path:string, mime:string) : void ->
	let fname := last(explode(path, *fs*)),
		a := pdf_file_attachment(doc = self, content = fname)
	in (a.embeddedfile := pdf_embedded_file(doc = self, filepath = path, mimetype = mime),
		if known?(current_page, self)
			self.current_page.annots :add a
		else self.pending_annots :add a)]


// @doc Invisible attachments
[add_attachment(self:pdf_document, fname:string, mime:string, data:any) : void ->
	let a := pdf_file_attachment(doc = self, content = fname)
	in (a.embeddedfile := pdf_embedded_file(doc = self, mimetype = mime, userdata = data),
		if known?(current_page, self)
			self.current_page.annots :add a
		else self.pending_annots :add a)]


// @cat Attachment element
// An attachment file may be added to the document with the special
// attachment element. The file content is either inline (directly
// in the HTML stream), submitted by the fill_attachment callback or 
// even given as the path of a file. In the two former cases we would
// have to supply a content attribute as the name of the embedded file.
// In the case of an inline attachment the content has to be escaped in
// order to handle special characters '<', '&' and '>'.\br
// The mime type of the attached file is 'plain/text' by default or
// as specified by the mime-type attribute.\br
// Such an attachment (vs. invisible attachment created by add_attachment)
// would have a visual appearance that default to 'PaperClip' that can
// be customized in the appearance attribute with a value in "Graph", "PushPin",
// "Paperclip", "Tag" (case sensitive).\br
// For instance the following lines defines an attachment with name hello.txt
// that has an inline data and would default to a PaperClip appearance :
// \code
// (Pdf/print_in_html(doc)
// 	?><attachment content="hello.txt">
// 		<data>Hello world!</data>
// 	</attachment><?
// Pdf/end_of_html(doc))
// \/code
// The following attachment is filled with the content of a file (so we don't
// need to specify a file name that is infered to the supplied file name) :
// \code
// (Pdf/print_in_html(doc)
// 	?><attachment filepath="/the/path/of/a/file" mimetype="mime/type" /><?
// Pdf/end_of_html(doc))
// \/code
// When the attachment content is filled by a callback we have to specify a
// userdata attribute that will be used to apply the fill_attachment callback
// as in :
// \code
// my_attachment_data <: ephemeral_object()
// DATA :: my_attachment_data()
//
// fill_attachment(self:pdf_document, data:my_attachment_data, p:port) ->
// 	printf(p, "Hello world!")
//
// (Pdf/print_in_html(doc)
// 	?><attachment content="hello.txt" mimetype="text/plain"
// 			userdata="<?oid DATA ?>" /><?
// Pdf/end_of_html(doc))
// \/code
// Notice that a fill_attachment restriction may not take a pdf_document
// object as the first parameter.\br
// We may also support a user defined appearance for the attachment.
// Attachment are interactive features in the sense that the appearance
// may change its appearance depending on the user interaction. Three
// appearances may be defined :
// \ul
// \li normal : the normal (unselected) appearance
// \li rollover : the user moves the mouse over the attachment box
// \li down : the user as selected (by a click) the attachment
// \/ul
// Each of the above appearance are the name of elements that can be
// used inside the attachment element such to define a particular
// appearance with an HTML stream. For instance :
// \code
// (Pdf/print_in_html(doc)
// 	?><attachment content="hello.txt">
// 		<data>Hello world!</data>
// 		<normal>Put your mouse here <i>(normal appearance)</i></normal>
// 		<rollover>Click here to select <i>(rollover appearance)</i></rollover>
// 		<down>Selected, click here to deselect <i>(down appearance)</i></down>
// 	</attachment><?
// Pdf/end_of_html(doc))
// \/code
// @cat


// *********************************************************************
// *   Part 5: graphic state                                           *
// *********************************************************************

// @cat gstate
// @alias state matrix
// Graphic operations operate with a graphic state that drives the rendering
// of graphic operation : a transformation matrix would serve positioning and
// styling options like colors, line width (etc...). Notice that in this
// implementation transformation matrix and the graphic state are handled
// together in a general drawing state.
// These states are organized in a stack and all modification of the graphic
// state would apply to the available state which handles the innermost
// transformation,
// \code
// (Pdf/push_state(doc))
// // modification of the graphic state
// (Pdf/pop_state(doc)) // restore the previous state
// \/code
// \h4 Transformation matrix\/h4
// All drawing operations are made through a transformation matrix which
// defines a position and an orientation in the page. The default transformation
// applies at the lower left corner of a page, positive X-coordinate at right and
// positive Y-coordinate at left. The initial matrix is the identity and
// may be composed with a user supplied matrix describing a transformation
// in the plan of the page :
// \code
// (Pdf/set_matrix(doc, a, b, c, d, e, f))
// \/code
// So that a point (x,y) is transformed in a point (x',y') by the following matrix product :
// \table\border=0\cellpadding=10\cellspacing=10
// \tr \td
// 		\table\border=1\cellpadding=4\cellspacing=0\class=doc_code
// 		\tr \td x' \td y' \td 1
// 		\/table
// \td =
// \td 
// 		\table\border=1\cellpadding=4\cellspacing=0\class=doc_code
// 		\tr \td x \td y \td 1
// 		\/table
// \td *
// \td
// 		\table\border=1\cellpadding=4\cellspacing=0\class=doc_code
// 		\tr \td a \td b \td 0
// 		\tr \td c \td d \td 0
// 		\tr \td e \td f \td 1
// 		\/table
// \/table
// Some classical transformations are provided, all relying on the above
// method :
// \code
// (Pdf/move(doc, dx, dy)) // translate
// (Pdf/scale(doc, sx, sy))
// (Pdf/scale(doc, x, y, sx, sy)) // scale at (x,y)
// (PDf/rotate(doc, a))
// (PDf/rotate(doc, x, y, a)) // rotate at (x,y)
// (PDf/skew(doc, a, b))
// \/code
// @cat

// @doc state
[push_state(self:pdf_document) : void ->
	self.catalog.current_section.matrices :add copy(last(self.catalog.current_section.matrices)),
	pdf_push_state(ref_doc = self)]

// @doc state
[pop_state(self:pdf_document) : void ->
	let sec := self.catalog.current_section,
		len := length(sec.matrices)
	in (if (len = 1) error("Unbalanced pop_state"),
		shrink(sec.matrices, len - 1),
		pdf_pop_state(ref_doc = self))]

// @doc matrix
[set_matrix(self:pdf_document, a:float, b:float, c:float, d:float, e:float, f:float) : void ->
	let sec := self.catalog.current_section,
		x := pdf_set_matrix(ref_doc = self, _a = a, _b = b, _c = c, _d = d, _e = e, _f = f),
		len := length(sec.matrices),
		m := sec.matrices[len],
		nm := list<float>()
	in (nm :add (a * m[1] + b * m[3]),
		nm :add (a * m[2] + b * m[4]),
		nm :add (c * m[1] + d * m[3]),
		nm :add (c * m[2] + d * m[4]),
		nm :add (e * m[1] + f * m[3] + m[5]),
		nm :add (e * m[2] + f * m[4] + m[6]),
		sec.matrices[len] := nm)]

// @doc matrix
// move(self, dx, dy) applies a translation with vector (dx,dy) on the current matrix.
[move(self:pdf_document, dx:float, dy:float) : void ->
	set_matrix(self, 1.0, 0.0, 0.0, 1.0, dx, dy)]


// @doc matrix
// scale(self, sx, sy) applies a scale factor on the current matrix. sx and sy represent
// the scale factor (1.0 for identity) in the direction X and Y of the current matrix.
[scale(self:pdf_document, sx:float, sy:float) : void ->
	set_matrix(self, sx, 0.0, 0.0, sy, 0.0, 0.0)]

// @doc matrix
// scale(self, x, y, sx, sy) applies a scale factor on the current matrix at the position
// (x,y). sx and sy represent the scale factor (1.0 for identity) in the direction X and Y
// of the current matrix.
[scale(self:pdf_document, x:float, y:float, sx:float, sy:float) : void ->
	set_matrix(self, sx, 0.0, 0.0, sy, x, y)]

// @doc matrix
// rotate(self, sx, a) rotates the current matrix with an angle a
[rotate(self:pdf_document, a:float) : void ->
	let ca := cos(a), sa := sin(a)
	in set_matrix(self, ca, sa, -(sa), ca, 0.0, 0.0)]

// @doc matrix
// rotate(self, x, y, a) rotates the current matrix with an angle a around the origin (x,y).
[rotate(self:pdf_document, x:float, y:float, a:float) : void ->
	let ca := cos(a), sa := sin(a)
	in set_matrix(self, ca, sa, -(sa), ca, x, y)]

// @doc matrix
// skew(self, a, b) skews the X axis by an angle 
// a and the Y axis by an angle b (in radian). 
[skew(self:pdf_document, a:float, b:float) : void ->
	let ta := tan(a), tb := tan(b)
	in set_matrix(self, 1.0, ta, tb, 1.0, 0.0, 0.0)]

// @doc matrix
// skew(self, a, b) skews the X axis by an angle 
// a and the Y axis by an angle b (in radian) from the origin (x,y). 
[skew(self:pdf_document, x:float, y:float, a:float, b:float) : void ->
	let ta := tan(a), tb := tan(b)
	in set_matrix(self, 1.0, ta, tb, 1.0, x, y)]

// @cat gstate
// @alias join cap dash
// \h4 Path line style\/h4
// Path line are drawn using a set of options like line width, how to
// draw junction and lien termination or whether the line is dashed :
// \code
// (Pdf/line_width(doc, 4.)) // set line width to 4 point
// (Pdf/line_join(doc, Pdf/ROUND_JOIN))
// (Pdf/line_cap(doc, Pdf/ROUND_CAP))
// \/code
// @cat

LINE_JOIN_TYPE :: {MITTER_JOIN, ROUND_JOIN, BEVEL_JOIN}
LINE_CAP_TYPE :: {BUTT_CAP, ROUND_CAP, SQUARE_CAP}

// @doc state
// line_width(self, _w) set the current line width for the path drawing operation.
[line_width(self:pdf_document, _w:float) : void => pdf_line_width(ref_doc = self, w = _w)]

// @doc state
// line_join(self, _w) sets the current line join mode for the path drawing operation.
[line_join(self:pdf_document, _m:{MITTER_JOIN, ROUND_JOIN, BEVEL_JOIN}) : void =>
	pdf_line_join(ref_doc = self, m = _m)]

// @doc state
// line_cap(self, _m) sets the current line cap mode for the path drawing operation.
[line_cap(self:pdf_document, _m:{BUTT_CAP, ROUND_CAP, SQUARE_CAP}) : void =>
	pdf_line_cap(ref_doc = self, m = _m)]

// @doc state
// line_dash(self, non, noff, ph) sets the current line dash style for the path drawing operation.
// non specifies the length of an ON dash and noff the length of an OFF dash. ph specifies the phase.
[line_dash(self:pdf_document, non:float, noff:float, ph:float) : void =>
	pdf_line_dash(
			ref_doc = self,
			dash = list<float>(non, noff),
			dashphase = ph)]

// @doc state
// line_dash(self, non, noff) is equivalent to line_dash(self, non, noff, 0) (no phase).
[line_dash(self:pdf_document, non:float, noff:float) : void =>
	line_dash(self, non, noff, 0.)]

// @doc state
// line_dash(self, lonoff) specifies a dash template with a list off ON and OFF lengths
// alternatively with an initial phase of ph.
[line_dash(self:pdf_document, lonoff:list[float], ph:float) : void =>
	pdf_line_dash(
			ref_doc = self, 
			dash = lonoff,
			dashphase = ph)]

// @doc state
// line_dash(self, lonoff) specifies a dash template with a list off ON and OFF lengths
// alternatively with no initial phase.
[line_dash(self:pdf_document, lonoff:list[float]) : void =>
	line_dash(self, lonoff, 0.)]

// *********************************************************************
// *   Part 6: path construction                                       *
// *********************************************************************

// @cat paths
// A path object is made of an ordered list of points interconnected by
// a line or a bezier curve. A path may be stroked, filled or both with
// the current graphic state. In order to initialize a path object
// we call a begin_path restriction :
// \code
// (Pdf/begin_path(doc)) // starts a path at (0., 0.)
// (Pdf/begin_path(doc, x, y)) // starts a path at (x,y)
// \/code
// The former would initialize the path at the point (0,0)
// lower left corner of a page when the transformation matrix is the identity.
// And the later would initialize the path at (x,y). The point is said to be
// the insertion point, i.e. the origin of a line or a curve. A line is
// defined with the lineto method :
// \code
// (Pdf/lineto(doc, 100., 100.)) // insert a line from (0,0) to (100., 100.)
// \/code
// A Bezier curve would be inserted with the curveto method. A Bezier is defined
// by four points, the origin which is the current insertion point a pair of
// control point and a destination :
// \code
// (Pdf/curveto(doc, 0., 100., 100., 0, 100., 100.))
// \/code
// Once a path is initialized (begin_path), multiple lines and curve may be
// inserted, each new line or curve moves the insertion point at the end
// of the line (or curve), for instance the following code initialize
// a path containing the 4 lines of a square :
// \code
// (Pdf/begin_path(doc))
// (Pdf/lineto(doc, 0., 100.)) // left border
// (Pdf/lineto(doc, 100., 100.)) // top border
// (Pdf/lineto(doc, 100., 0.)) // right border
// (Pdf/lineto(doc, 0., 0.)) // bottom border
// \/code
// A path may contain multiple subpaths, a new subpath may be started with the
// moveto method, it would define a new insertion point :
// \code
// (Pdf/begin_path(doc))
// (Pdf/lineto(doc,...)) // insert component of the first subpath
// (Pdf/curveto(doc,...))
//
// (Pdf/moveto(doc, 200., 200.)) // start a new subpath at (200., 200.)
// (Pdf/lineto(doc,...)) // insert component of a second subpath
// (Pdf/curveto(doc,...))
// \/code
// Once a path as been constructed with lines and curves it may be render
// with a stroke, a fill or both operations. To stroke a path means to
// draw the path line with the current line options (line with, joins,
// stroke color...) of the graphic state and to fill means that the area
// that is enclosed by the path line is filled with the fill color currently
// defined in the graphic state. Stroke and fill operations may be applied
// simultaneously. A method with prefix 'close_' would, before actually fill
// or stroke, silently insert a line that would close the last sub-path (between
// the insertion point and the sub-path origin) :
// \code
// (Pdf/[close_][fill_][stroke_]path(doc))
// \/code
// Once a method above is called, the path is terminated so that using lineto,
// curveto or moveto would require a new path as created by begin_path.\br
// Pdf also defines variants of begin_path that would initialize a new path
// and insert lines or curves of predefined shapes :
// \code
// // rectangles are represented using four lines
// (Pdf/begin_path_rect(doc, rect))
//
// // a quad is like a rectangle but having rounded corner
// // quads are represented using curves
// (Pdf/begin_path_quad(doc, rect))
//
// // circles are approximations, they are defined by a given amount of segment
// // all segments are represented with a curve
// (Pdf/begin_path_circle(doc, rect)) // defaults to 16 segments
// (Pdf/begin_path_circle(doc, rect, 32))
//
// // triangles are represented using three lines
// // one edge on the left border of the given rectangle
// // and a node in the middle of the right border of the given rectangle
// (Pdf/begin_path_triangle(doc, rect))
// \/code
// Where rect is a rectangle circumscribed to the inserted shape. These
// methods have only initialized a new path, it may be continue with
// lineto, curveto or moveto operations and would have to be terminated
// by fill or stroke operation as described above.
// @cat


// @doc path
[begin_path(self:pdf_document, atx:float, aty:float) : void =>
	pdf_begin_path(ref_doc = self, x =  atx, y = aty)]

// @doc path
[begin_path(self:pdf_document) : void =>
	pdf_begin_path(ref_doc = self)]


// @doc path
[moveto(self:pdf_document, atx:float, aty:float) : void =>
	pdf_moveto(ref_doc = self, x =  atx, y = aty)]

// @doc path
[lineto(self:pdf_document, atx:float, aty:float) : void =>
	pdf_lineto(ref_doc = self, x = atx, y = aty)]

// @doc path
[curveto(self:pdf_document, x1:float, y1:float, x2:float, y2:float, x3:float, y3:float) : void ->
	pdf_curveto(ref_doc = self,
				cx1 = x1, cy1 = y1,
				cx2 = x2, cy2 = y2,
				cx3 = x3, cy3 = y3)]

//<sb> filling & stroking path

// @doc path
[stroke_path(self:pdf_document) : void => pdf_end_path(ref_doc = self, endop = "S")]

// @doc path
[close_stroke_path(self:pdf_document) : void => pdf_end_path(ref_doc = self, endop = "s")]

// @doc path
[close_fill_stroke_path(self:pdf_document) : void =>
	pdf_end_path(ref_doc = self, endop = "b")]

// @doc path
[fill_path(self:pdf_document) : void =>
	pdf_end_path(ref_doc = self, endop = "f")]

// @doc path
[fill_stroke_path(self:pdf_document) : void =>
	pdf_end_path(ref_doc = self, endop = "B")]


//<sb> followings are high level path construction
// that construct the path of a shape in the given
// bounding rectangle

// @doc path
[begin_path_rect(self:pdf_document, r:rectangle) : void =>
	begin_path(self,r.left, r.top),
	lineto(self, r.left, r.bottom),
	lineto(self, r.right, r.bottom),
	lineto(self, r.right, r.top),
	lineto(self, r.left, r.top)]


//<sb> quad is a bezier curve having its control points
// corresponding the rectangle points
// @doc path
[begin_path_quad(self:pdf_document, r:rectangle) : void ->
	let w2 := width(r) / 2.,
		h2 := height(r) / 2.
	in (begin_path(self, r.left, r.bottom + h2),
		curveto(self, r.left, r.top, r.left, r.top, r.left + w2, r.top),
		curveto(self, r.right, r.top, r.right, r.top, r.right, r.bottom + h2),
		curveto(self, r.right, r.bottom, r.right, r.bottom, r.left + w2, r.bottom),
		curveto(self, r.left, r.bottom, r.left, r.bottom, r.left, r.bottom + h2))]

//<sb> note the triangle is drawn as this : |>
// @doc path
[begin_path_triangle(self:pdf_document, r:rectangle) : void ->
	let h2 := height(r) / 2.
	in (begin_path(self, r.left, r.bottom),
		lineto(self, r.left, r.top),
		lineto(self, r.right, r.bottom + h2),
		lineto(self, r.left, r.bottom))]


//<sb> approx a circle with 'seg' bezier curves
// @doc path
[begin_path_circle(self:pdf_document, r:rectangle) : void -> begin_path_circle(self, r, 16)]
// @doc path
[begin_path_circle(self:pdf_document, r:rectangle, seg:integer) : void ->
	let N := seg max 8,
		w2 := width(r) / 2.,
		h2 := height(r) / 2.,
		rd := w2 min h2,
		da := 2. * 3.14159265358979323846 / float!(N),
		a := da,
		x1 := rd, x3 := rd * cos(a),
		y1 := 0., y3 := rd * sin(a),
		d := rd * (x3 - x1) / -(y1 + y3)
	in (push_state(self),
		move(self, r.left + w2, r.bottom + h2), //<sb> move to center
		begin_path(self, x1, y1),
		for i in (1 .. N)
			let x2 := x1 - d * y1 / rd,
				y2 := y1 + d * x1 / rd
			in (curveto(self, x2, y2, x2, y2, x3, y3),
				a :+ da,
				x1 := x3,
				y1 := y3,
				x3 := rd * cos(a),
				y3 := rd * sin(a)),
		pop_state(self))]


// @cat simple_shape
// Pdf also comes with various methods to insert predefined shapes in a single
// step. When the method name contains
// 'stroke' then the method take a w argument used a the line width, all 
// methods will take a color argument that have to be supplied as a string that
// identifies a named color. A named color is either made of a X11 name or
// an hexadecimal representation :
// \code
// (Pdf/stroked_rectangle(doc, rect, 4., "red"))
// (Pdf/filled_circle(doc, rect, "#FF0000")) // also red
// \/code
// @cat


// @doc simple_shape
[stroked_rectangle(self:pdf_document, rect:rectangle, w:float, c:string) : void =>
	stroked_rectangle(self, rect, w, string2color(c))]
[stroked_rectangle(self:pdf_document, rect:rectangle, w:float, c:tuple(float, float, float)) : void =>
	line_width(self, w),
	begin_path_rect(self, rect),
	stroke_color(self, c),
	stroke_path(self)]

// @doc simple_shape
[filled_rectangle(self:pdf_document, rect:rectangle, c:string) : void =>
	filled_rectangle(self, rect, string2color(c))]
[filled_rectangle(self:pdf_document, rect:rectangle, c:tuple(float, float, float)) : void =>
	begin_path_rect(self, rect),
	color(self, c),
	fill_path(self)]

// @doc simple_shape
[stroked_triangle(self:pdf_document, rect:rectangle, w:float, c:string) : void =>
	stroked_triangle(self, rect, w, string2color(c))]
[stroked_triangle(self:pdf_document, rect:rectangle, w:float, c:tuple(float, float, float)) : void =>
	line_width(self, w),
	begin_path_triangle(self, rect),
	stroke_color(self, c),
	stroke_path(self)]

// @doc simple_shape
[filled_triangle(self:pdf_document, rect:rectangle, c:string) : void =>
	filled_triangle(self, rect, string2color(c))]
[filled_triangle(self:pdf_document, rect:rectangle, c:tuple(float, float, float)) : void =>
	begin_path_triangle(self, rect),
	color(self, c),
	fill_path(self)]


// @doc simple_shape
[stroked_quad(self:pdf_document, rect:rectangle, w:float, c:string) : void =>
	stroked_quad(self, rect, w, string2color(c))]
[stroked_quad(self:pdf_document, rect:rectangle, w:float, c:tuple(float, float, float)) : void =>
	line_width(self, w),
	begin_path_quad(self, rect),
	stroke_color(self, c),
	stroke_path(self)]

// @doc simple_shape
[filled_quad(self:pdf_document, rect:rectangle, c:string) : void =>
	filled_quad(self, rect, string2color(c))]
[filled_quad(self:pdf_document, rect:rectangle, c:tuple(float, float, float)) : void =>
	begin_path_quad(self, rect),
	color(self, c),
	fill_path(self)]


// @doc simple_shape
[stroked_circle(self:pdf_document, rect:rectangle, w:float, c:string) : void =>
	stroked_circle(self, rect, w, string2color(c))]
[stroked_circle(self:pdf_document, rect:rectangle, w:float, c:tuple(float, float, float)) : void =>
	line_width(self, w),
	begin_path_circle(self, rect),
	stroke_color(self, c),
	stroke_path(self)]

// @doc simple_shape
[filled_circle(self:pdf_document, rect:rectangle, c:string) : void =>
	filled_circle(self, rect, string2color(c))]
[filled_circle(self:pdf_document, rect:rectangle, c:tuple(float, float, float)) : void =>
	begin_path_circle(self, rect),
	color(self, c),
	fill_path(self)]

// @doc simple_shape
[filled_star(self:pdf_document, rect:rectangle, c:string) : void =>
	filled_star(self, rect, string2color(c))]
[filled_star(self:pdf_document, r:rectangle, c:tuple(float, float, float)) : void ->
	let w2 := width(r) / 2.,
		h2 := height(r) / 2.,
		h4 := h2 / 4.
	in for i in (0 .. 5)
		(push_state(self),
		color(self, c),
		move(self, r.left + w2, r.bottom + h2), //<sb> move to center
		scale(self, 1.5, 1.5),
		rotate(self, float!(i) * 60. * 3.1415 / 180.),
		begin_path(self, 0., -(h4)),
		lineto(self, 0., h4),
		curveto(self, w2, 0., w2, 0., 0., -(h4)),
		fill_path(self),
		pop_state(self))]

// *********************************************************************
// *   Part 7: text objects                                            *
// *********************************************************************

// @cat text
// Mimicking the path construction API, we have a begin_text method that
// initialize a text object. Notice that texts, as paths, would be drawn using
// the current transformation matrix :
// \code
// // create a new text object at (0.,0.) in the current transformation matrix
// (Pdf/begin_text(doc))
//
// // create a new text object at (100.,100.) in the current transformation matrix
// (Pdf/begin_text(doc, 100., 100.))
//
// // create a new text object at (100.,100.) in the current transformation matrix
// // the text would be drawn with the given angle of 0.3 radian
// (Pdf/begin_text(doc, 100., 100., 0.3))
// \/code
// A text object would be rendered with the current font of the document which
// either the one that was last queried by get_font or the one that is 
// selected by select_font introduced for convenience :
// \code
// // select 12pt Helvetica, normal
// (Pdf/select_font(doc, 12., "Helvetica", false, false))
//
// // select 12pt Helvetica, bold
// (Pdf/select_font(doc, "Helvetica", 12., true, false))

// // select 14pt Helvetica, italic
// (Pdf/select_font(doc, "Helvetica", 14., false, true))
// \/code
// It is important to note that texts are handled as single lines
// even if they contain new line character. A text would be handled as a list of
// glyph, each having a particular description in the font metrics file, the
// new line character would sometimes be described with a null width which would
// not serve at word separation.
// It is up to the user code to handle new line character with the special new_text_line
// method (unless it uses show_multilined_text - see bellow). In order to insert a line of text we call
// show_text :
// \code
// (Pdf/show_text(doc, "Hello world!"))
// \/code
// And we may handle multiple lines using the new_text_line operator, for which is
// given a leading space between two lines :
// \code
// (Pdf/show_text(doc, "first line"))
// (Pdf/new_text_line(doc, 15.))
// (Pdf/show_text(doc, "A second line ..."))
// (Pdf/show_text(doc, "... second line continued"))
// (Pdf/new_text_line(doc, 15.))
// (Pdf/show_text(doc, "A third line"))
// ...
// \/code
// And when we are done with text showing operations we need to close the
// text object properly :
// \code
// (Pdf/end_text(doc))
// \/code
// We may modify the transformation matrix between two show_text's calls, this would
// produce a side effect inherent to PDF text handling. Indeed text operations
// are handled by a special matrix (the text matrix) that lives in the begin_text/end_text scope
// and modified each time show_text is called such incoming texts are appended to the
// current line (like above for the 'continued' second line). new_text_line operates on the
// current text matrix such incoming text begins on a new line.
// @cat



// @doc text
[begin_text(self:pdf_document) : void =>
	get_font(self, "Helvetica", NORM),
	pdf_begin_text(ref_doc = self)]

// @doc text
[begin_text(self:pdf_document, atx:float, aty:float) : void =>
	get_font(self, "Helvetica", NORM),
	pdf_begin_text(ref_doc = self, x = atx, y = aty)]

// @doc text
[begin_text(self:pdf_document, atx:float, aty:float, ang:float) : void =>
	get_font(self, "Helvetica", NORM),
	pdf_begin_text(ref_doc = self, x = atx, y = aty, angle = ang)]

// @doc text
[select_font(self:pdf_document, fs:float, face:string, b?:boolean, i?:boolean) : integer =>
	let f := get_font(self, face, b?, i?)
	in (pdf_select_font(ref_doc = self, fontsize = fs, fontnum = f), f)]

// @doc text
[select_font(self:pdf_document, fs:float, num:integer) : integer =>
	(pdf_select_font(ref_doc = self, fontsize = fs, fontnum = num), num)]


// @doc text
[show_text(self:pdf_document, txt:string) : void =>
	pdf_show_text(ref_doc = self, text = txt)]


// @cat text
// Pdf also comes with a special method that handles multilined text in a single
// step, it is an arrangement of the above methods which is a good illustration of
// text routines, it would also be a good base for a particular implementation :
// @code

// @doc text
show_multilined_text(self:Pdf/pdf_document, // target document
					txt:string, // string of text (may contain \n)
					f:integer, // font id (see get_font)
					fs:float, // font size in point
					il:float, // space between two lines
					x:float, y:float) -> // upper left corner
	let lines := explode(txt,"\n"),
		line_count := length(lines)
	in (Pdf/begin_text(self, x, y),
		Pdf/select_font(self, fs, f),
		for i in (1 .. line_count)
			let line := lines[i],
				rect := Pdf/get_text_box(self, line, f, fs)
			in (Pdf/show_text(self, line),
				Pdf/new_text_line(self, rect.top - rect.bottom - il)),
		Pdf/end_text(self))

// @code

// @cat text
// But the user will probably prefer to use the show_html_box instead...
// @cat

// @doc text
[new_text_line(self:pdf_document, leading:float) : void =>
	pdf_new_text_line(ref_doc = self, TL = leading)]


// @doc text
[end_text(self:pdf_document) : void => pdf_end_text(ref_doc = self)]



// *********************************************************************
// *   Part 8: color                                                   *
// *********************************************************************

// @cat gstate
// @alias colors opacity transparency
// \h4 Color and transparency\/h4
// When path and texts are rendered they are filled and or stroked, both with a given
// color. An alpha value may be optionally defined.
// \code
// (Pdf/color(doc, 0.0, 0.0, 0.0)) // sets line color and font color to black
// (Pdf/stroke_color(doc, 0.7, 0.2, 0.0)) // stroke with color red (with a few green)
// (Pdf/alpha(doc, 0.7)) // sets the opacity to 70%
// \/code
// @cat


//<sb> @doc colors
// color(self, c) is equivalent to color(self, c[1], c[3], c[3]).
[color(self:pdf_document, c:tuple(float, float, float)) : void => color(self, c[1], c[2], c[3])]
//<sb> @doc colors
// color(self, _r, _g, _b) sets the current color as an RGB value used for the fill operation.
[color(self:pdf_document, _r:float, _g:float, _b:float) : void =>
	pdf_color(ref_doc = self, r = _r, g = _g, b = _b)]

//<sb> sets the color used for stroke operation
//<sb> @doc colors
// stroke_color(self, c) is equivalent to stroke_color(self, c[1], c[3], c[3]).
[stroke_color(self:pdf_document, c:tuple(float, float, float)) : void => stroke_color(self, c[1], c[2], c[3])]
//<sb> @doc colors
// stroke_color(self, _r, _g, _b) sets the current color as an RGB value used for the stoke operation.
[stroke_color(self:pdf_document, _r:float, _g:float, _b:float) : void =>
	pdf_stroke_color(ref_doc = self, r = _r, g = _g, b = _b)]



//<sb> @doc colors
// alpha(self, _a) defines the current opacity %tage.
[alpha(self:pdf_document, _a:float) : void =>
	let res := pdf_extgstate(doc = self, opacity = _a)
	in (use_resource(res),
		pdf_alpha(ref_doc = self, extgstate = res))]


// *********************************************************************
// *   Part 9: images                                                  *
// *********************************************************************

// @cat Images
// This module comes with its own handling of PNG image (without dependency),
// we can insert a PNG image object on a page using the current transformation
// matrix. An image is supplied given a PNG image file path, the generated PDF
// document will always embed the image data such to avoid dependencies to external
// resource. Also we may need a position within the current transformation matrix
// and or size constraint at the insertion time :
// \code
// (Pdf/show_image(doc, "car.png",
// 			50., 50., // bottom left corner at (50., 50.) (in pt)
// 			100., 100.)) // apportioned to a 100. by 100. box (in pt)
//
//
// (Pdf/show_image(doc, "sun.png",
// 			rectangle!(50., 600., 100., 550.)) // apportioned to the given rectangle
// \/code
// @cat

// @doc images
[show_image(self:pdf_document, path:string, x:float, y:float, w:float, h:float) : void ->
	show_image(load_pngUjpg(self, path), x, y, w, h)]

[show_image(self:pdf_document, path:string, x:float, y:float) : void =>
	show_image(load_pngUjpg(self, path), x, y)]

// @doc images
[show_image(self:pdf_document, path:string, r:rectangle) : void =>
	show_image(load_pngUjpg(self, path), r)]

// *********************************************************************
// *   Part 10: html objects                                           *
// *********************************************************************

// @cat HTML redirection and Wcl syntax
// In order to use standard printing methods and Wcl syntax this modules
// comes with an HTML redirection support, a redirection scope is introduced
// by a call to print_in_html and terminated by a a call to a restriction
// of the end_of_html* method family :
// \code
// (Pdf/print_in_html(DOC)) // starts HTML redirection
// ( ?><p>
// 		Hello world!
// </p><? )
// (Pdf/enf_of_html*(DOC)) // ends redirection and apply a constructor
// \/code
// @cat

/* // @doc HTML redirection and Wcl syntax
[print_in_html(self:pdf_document) : void ->
	self.pdfport := port!(),
	self.oldport := use_as_output(self.pdfport)]*/

print_in_html <: Macro()

[macroexpand(self:print_in_html) : any ->
	let loc := Language/CODE_LOCS[self]
	in Do(args =
		list((if loc
				Gassign(var = get_value(Pdf, "CURRENT_LOCATION"),
					arg = tuple(loc[1], loc[2], "[print_in_html]"))
			else none),
			Call(put, list(pdfport, self.args[1], Call(blob!, list(system)))),
			Call(put, list(oldport, self.args[1],
					Call(use_as_output, list(Call(get, list(pdfport, self.args[1]))))))))]


// @cat xobject
// The HTML renderer can be used in a simple manner: render HTML
// in a given box. This would take place on the current page of the current
// section and would not use the auto page-break algorithm. If an overflow
// occurs during the process (i.e. the rendered HTML is wider than the supplied box)
// then a scale is applied such in any case, an arbitrary big HTML stream would fit
// the given box.\br
// The autofit? flag, when true, tells to apply a final scale such the rendered HTML
// exactly fits the supplied box (when the rendered box appears smaller than the supplied
// box).\br
// show_html_box is used to submit an HTML stream represented by a string :
// \code
// // autofit? true by default : auto-scaled to the box
// (Pdf/show_html_box(doc, "toto <i>titi</i>",
// 			Pdf/rectangle!(200., 300., 300., 200.)))
//
// // autofit? false : hopefully unscaled, unless an overflow occurs
// (Pdf/show_html_box(doc, "toto <i>titi</i>",
// 			Pdf/rectangle!(200., 600., 300., 400.),
// 			false))
// \/code
// Combined with the Wcl syntax we may submit a dynamic HTML stream in a more
// elegant way. For that we use print_in_html/end_of_html_box that defines an
// HTML redirection scope as shown by the following equivalent notation :
// \code
// (Pdf/print_in_html(doc))
// ( ?>toto <i>titi</i><? )
// (Pdf/end_of_html_box(doc, Pdf/rectangle!(200., 300., 300., 200.)))
// \/code
// Internaly such a stream is handled using an hidden XObject containing the rendered
// stream, this XObject is then referenced with the appriopriate scale in case of
// overflow or when autofit? is true.\br
// @cat



// @cat xobject
// XObject is a nice feature of PDF since it can hold a set of drawing routines and
// draw that XObject multiple times anywhere in the document each time with a particular
// transformation matrix (like an image).\br
// XObjects are named object bound to the document so that they can be referenced by any
// page of any section (their value would default to "" when unspecified).
// We may define our own xobject by hand which is handled by the end_of_html_xobject
// constructor family. width, when given, specifies the width of the virtual rendering
// window, otherwise the width of the current page is taken :
// \code
// (Pdf/new_html_xobject(doc, "<p align=center>My XObject!</p>",
// 				"my_first_object", "a_value", 100.))
// \/code
// Or with an HTML redirection as in :
// \code
// (Pdf/print_in_html(doc))
// ( ?><p align=center>My XObject!</p><? )
// (Pdf/end_of_html_xobject(doc, "my_first_object", "a_value")) // page width rendering
//
// (Pdf/print_in_html(doc))
// ( ?><p align=center>My XObject!</p><? )
// (Pdf/end_of_html_xobject(doc, "my_second_object", 100.)) // 100pt width rendering
// \/code
// end_of_html_xobject would return the actual size which may be wider than a page or
// the supplied with in case of overflow. In order to reference an XObject we can use
// the show_xobject method :
// \code
// (Pdf/show_xobject(doc, "my_first_object", "a_value",
// 				Pdf/rectangle!(200., 300., 300., 200.)))
// \/code
// For instance we may known understand how the show_html_box method is implemented,
// particularly how the hidden XObject is handled :
// @code

// @doc xobject
[show_html_box(self:pdf_document, html:string, rect:rectangle, autofit?:boolean) ->
 	(print_in_html(self),
 	princ(html),
 	let xname := uid() // unique name for the internal XObject
 	in (end_of_html_xobject(self, xname, width(rect)),
 		show_xobject(self, xname, rect, autofit?)))]

// @code



// @doc xobject
[show_html_box(self:pdf_document, html:string, rect:rectangle) : void =>
	show_html_box(self, html, rect, true)]

// @doc xobject
[end_of_html_box(self:pdf_document, rect:rectangle, autofit?:boolean) : void ->
 	let xname := uid() // unique name for the internal XObject
 	in (end_of_html_xobject(self, xname, width(rect)),
 		show_xobject(self, xname, rect, autofit?))]

// @doc xobject
[end_of_html_box(self:pdf_document, rect:rectangle) : void -> end_of_html_box(self, rect, true)]


// @cat xobject
// Last, here is a complete sample that shows a custom xobject creation and its
// use in a transformed matrix. This sample creates a single page document with
// a formated HTML rendered in a rotated box centered in the middle of the page.
// A sroked red rectangle is added to show the unrotated box :
// \code
// // creates a new document, a section and a page
// DOC :: Pdf/document!()
// 
// (Pdf/new_page(DOC))
// 
// // creates an XObject
// (Pdf/new_html_xobject(DOC, "<p border=1>toto <i>titi</i></p>", "xobj", 100.))
// 
// // the page rect
// pgrect :: Pdf/get_page_full_rect(DOC)
// 
// // a 100pt by 100pt rectangle centered on 0.0
// boxrect :: Pdf/rectangle!(100., 100.)
// 
// // move to the center of the page
// (Pdf/move(DOC, width(pgrect) / 2., height(pgrect) / 2.))
// 
// // shows the HTML box unrotated in red
// (Pdf/stroked_rectangle(DOC, boxrect, 1., "red"))
// 
// // rotation of 0.3 radians
// (Pdf/rotate(DOC, 0.3))
//
// // shows our XObject in the rotated matrix
// (Pdf/show_xobject(DOC, "xobj", "", boxrect, true))
// 
// // save the document in file test.pdf
// (Pdf/print_in_file(DOC,"test.pdf"))
// \/code
// @cat


// @doc xobject
[end_of_html_xobject(self:pdf_document, name:string) : tuple(float,float) ->
	end_of_html_xobject(self, name, "")]
// @doc xobject
[end_of_html_xobject(self:pdf_document, name:string, value:integer) : tuple(float,float) ->
	end_of_html_xobject(self, name, string!(value))]
// @doc xobject
[end_of_html_xobject(self:pdf_document, name:string, value:string) : tuple(float,float) ->
	use_as_output(self.oldport),
	erase(oldport, self),
	let t := insert_html_xobject(self, self.pdfport, name, value)
	in (fclose(self.pdfport), t)]

// @doc xobject
[end_of_html_xobject(self:pdf_document, name:string, width:float) : tuple(float,float) ->
	end_of_html_xobject(self, name, "", width)]
// @doc xobject
[end_of_html_xobject(self:pdf_document, name:string, value:integer, width:float) : tuple(float,float) ->
	end_of_html_xobject(self, name, string!(value), width)]
// @doc xobject
[end_of_html_xobject(self:pdf_document, name:string, value:string, width:float) : tuple(float,float) ->
	use_as_output(self.oldport),
	erase(oldport, self),
	let t := insert_html_xobject(self, self.pdfport, name, value, width)
	in (fclose(self.pdfport), t)]

// @doc xobject
[new_html_xobject(self:pdf_document, html:string, name:string, width:float) : tuple(float,float) ->
	new_html_xobject(self, html, name, "", width)]
// @doc xobject
[new_html_xobject(self:pdf_document, html:string, name:string, value:integer, width:float) : tuple(float,float) ->
	new_html_xobject(self, html, name, string!(value), width)]
// @doc xobject
[new_html_xobject(self:pdf_document, html:string, name:string, value:string, width:float) : tuple(float,float) ->
	print_in_html(self),
	princ(html),
	use_as_output(self.oldport),
	erase(oldport, self),
	let t := insert_html_xobject(self, self.pdfport, name, value, width)
	in (fclose(self.pdfport), t)]
	

// @doc xobject
[show_xobject(self:pdf_document, name:string, rect:rectangle, autofit?:boolean) : void =>
	show_xobject(self, name, "", rect, autofit?)]
// @doc xobject
[show_xobject(self:pdf_document, name:string, value:string, rect:rectangle, autofit?:boolean) : void ->
	when xo := self.xobject_map[name, value]
	in (let htdoc := html_document(ref_doc = self),
			wdoc := xo.src.width,
			hdoc := xo.src.height,
			wr := width(rect),
			hr := height(rect),
			hxo := html_xobject(hparent = htdoc)
		in (hxo.ref_xobject := xo,
			use_resource(xo),
			hxo.X := rect.left,
			hxo.Y := rect.top,
			hxo.width := (if autofit? wr else if (wdoc < wr) wdoc else wr),
			hxo.height := (if autofit? hr else if (hdoc < hr) hdoc else hr),
			let op := pdf_html_operation(ref_doc = self)
			in op.html_page_elements := list<ephemeral_object>(htdoc, hxo)))
	else error("xobject element reference invalid (name: ~S, value: ~S)", name, value)]


// @cat XObject element
// As seen above we can create XObjects (graphic objects that can be reference by any
// page of any section), these objet may be referenced for an HTML stream using the
// special element xobject :
// \code
// (Pdf/print_in_html(doc)
// 	?><xobject name="my_first_object" value="a_value" /><?
// Pdf/end_of_html(doc))
// \/code
// As for any element the width and the height is infered by the layout algorithm unless
// the xobject element contains a width or height attribute.
// @cat


// @cat Main document HTML stream
// HTML streams may also be submitted for an entire section of a document without
// taking care of page creation. This solution relies on an auto page-break algorithm
// take would automatically create pages as required. Given a current section we would
// use print_in_html/end_of_html to submit a new HTML chunk, print_in_html/end_of_html
// are intended to be used multiple times, each time a new chunk would be appended to the
// section's stream :
// \code
// (printf("Appending HTML chunks to section ~A\n", Pdf/get_current_section(doc)))
//
// (Pdf/print_in_html(doc))
// ( ?> first HTML chunk <? )
// (Pdf/end_of_html(doc))
//
// (Pdf/print_in_html(doc))
// ( ?> next HTML chunk <? )
// (Pdf/end_of_html(doc))
// \/code
// @cat


// @doc Main document HTML stream
[end_of_html(self:pdf_document) : void ->
	use_as_output(self.oldport),
	erase(oldport, self),
	insert_html(self, self.pdfport),
	fclose(self.pdfport)]

// @cat Headers and footer
// We may also define a header and a footer for the current section, both
// using HTML formatting :
// \code
// (printf("Initialize HTML header for section ~A\n", Pdf/get_current_section(doc)))
//
// (Pdf/print_in_html(doc))
// ( ?>Page header<? )
// (Pdf/end_of_html_header(doc))
// \/code
// And for the footer :
// \code
// (printf("Intitialize HTML footer for section ~A\n", Pdf/get_current_section(doc)))
//
// (Pdf/print_in_html(doc))
// ( ?>Page footer<? )
// (Pdf/end_of_html_footer(doc))
// \/code
// When a header (or a footer) is defined, it is accounted by the page-break algorithm in
// the sense that the available space in a page is shrinked by the size of the header
// (resp footer).\br
// We may call end_of_html_header (resp. end_of_html_footer) multiple times, this would
// define a different header for next pages :
// \code
// (Pdf/print_in_html(doc))
// ( ?>Header first page<? )
// (Pdf/end_of_html_header(doc))
//
// (Pdf/print_in_html(doc))
// ( ?>Header second page<? )
// (Pdf/end_of_html_header(doc))
//
// (Pdf/print_in_html(doc))
// ( ?>Header third page and following<? )
// (Pdf/end_of_html_header(doc))
// \/code
// When a header or a footer is created an implicit HTML element headerbody/footerboby
// is created with the following attributes :
// \ul
// \li section : with the value set to the current section
// \li page : with the index of the header (where the index is incremented each time
// end_of_header/end_of_footer is called)
// \/ul
// Given that elements we may define a CSS style for a given header/footer body of a given
// section, for instance :
// \code
// (print_in_css(DOC) ?>
// 	headerbody[section=body][page=1] {background-color: blue}
// <? end_of_css(DOC))
// \/code
// the above rule would apply a blue background of the first header of section "body".\br
// Notice that a header/footer may use special elements pagenum and pagecount that would
// be substituted by their actual value a the time of document generation.
// @cat


// @doc Headers and footer
[end_of_html_header(self:pdf_document) : void ->
	use_as_output(self.oldport),
	erase(oldport, self),
	let htdoc := html_document(ref_doc = self, element_name = "headerbody"),
		sec := self.catalog.current_section
	in (if sec.pb_processed?
			error("Attempt to add a header to the section ~A that has already been rendered.",
						get_section_name(sec)),
		htdoc["page"] := string!(length(sec.header_docs) + 1),
		htdoc["section"] := get_section_name(sec),
		build_css_styler(self.style_sheet, htdoc),
		parse_html(self.pdfport, htdoc),
		auto_layout_html(htdoc, sec.dim.right, sec.dim.top),
		fclose(self.pdfport),
		sec.header_docs :add htdoc)]

// @doc Headers and footer
[end_of_html_footer(self:pdf_document) : void ->
	use_as_output(self.oldport),
	erase(oldport, self),
	let htdoc := html_document(ref_doc = self, element_name = "footerbody"),
		sec := self.catalog.current_section
	in (if sec.pb_processed?
			error("Attempt to add a header to the section ~A that has already been rendered.",
						get_section_name(sec)),
		htdoc["class"] := "page" /+ string!(length(sec.footer_docs) + 1),
		build_css_styler(self.style_sheet, htdoc),
		parse_html(self.pdfport, htdoc),
		auto_layout_html(htdoc, sec.dim.right, sec.dim.top),
		fclose(self.pdfport),
		sec.footer_docs :add htdoc)]

[add_header(self:pdf_document, p:port) : void ->
	print_in_html(self),
	freadwrite(p, cout()),
	end_of_html_header(self)]

[add_footer(self:pdf_document, p:port) : void ->
	print_in_html(self),
	freadwrite(p, cout()),
	end_of_html_footer(self)]

// @cat pagenum
// A PDF document can be seen as a page rendering device (also called 'page media' in CSS).
// This module uses a page-break algorithm to render an arbitrary HTML stream in multiple
// page. The actual page where would take place a given piece of HTML is a priori unknown
// until a document is generated, so does the amount of page this document will contain.
// The page index or page amount can however be inserted with the right value provided
// special lazy elements pagenum and pagecount.
// A good place to use these elements is in a header or a footer, for instance the following
// code will add a footer to the current section with the current page :
// \code
// (Pdf/print_in_html(doc) ?>
// 	<table width=100%>
// 		<tr>
// 			<td align=right>
// 				<pagenum>/<pagecount>
// 	</table>
// <? Pdf/end_of_html_footer(doc))
// \/code
// As other elements pagenum and pagecount may be used to write a CSS selector.
// @cat

/*[end_of_html_template(self:pdf_document) : void ->
	use_as_output(self.oldport),
	erase(oldport, self),
	insert_html_template(self, self.pdfport),
	fclose(self.pdfport)]
*/

[doc_of_element(self:html_entity) : html_document ->
	case self
		(html_document self,
		any doc_of_element(self.hparent))]

[get_page_id(self:pdf_document, index:integer) : integer ->
	let pgs := self.catalog.current_section.kids
	in (if (index % (1 .. length(pgs))) pgs[index].id
		else (error("Invalid page index ~S for get_page_id", index),0))]

[get_page_id(self:html_element) : integer ->
	let pgid := -1
	in (for p in self.target_section.kids
			(for c in p.contents
				when x := some(o in c.operations|o % pdf_html_operation &
							exists(x in o.html_page_elements | x % html_placed_entity & x.target.hparent = self))
				in (pgid := p.id, break()),
			if (pgid != -1) break()),
		pgid)]

[get_page(self:html_word) : pdf_page -> get_page(self.hparent)]


[get_page(self:html_element) : pdf_page ->
	let pg := unknown
	in (for sec in self.ref_doc.section_order
			(for p in sec[2].kids
				(for c in p.contents
					when x := some(o in c.operations|o % pdf_html_operation & self % o.html_page_elements)
					in (pg := p, break()),
				if known?(pg) break()),
			if known?(pg) break()),
		if unknown?(pg)
			error("get_page@html_element error, the element ~S isn't affected to a page", self),
		pg as pdf_page)]


// *********************************************************************
// *   Part 11: signature                                              *
// *********************************************************************

// @cat Invisible digital signatures
// The PDF reference also specifies a general way to append a digital
// signature to a document. A reader application should have a signature
// handler able to verify a given signature format. In this implementation
// we support both x509.rsa_sha1 and  pkcs7.sha1 formats. The method
// sign appends a digital signature object to the given document. The
// actual signature value will be computed when the method print_in_file
// or print_in_port is called, the value of a signature is computed using
// Openssl module and we'll need a signer certificate and private key
// to complete the call to sign :
// \code
// // create a CA (Certificate Authority)
// ca_key :: Openssl/rsa!(512)
// ca :: Openssl/X509!(ca_key)
// 
// (Openssl/add_subject_entry(ca, "CN","CARoot"))
// (Openssl/add_subject_entry(ca, "O","expert-solutions"))
// (Openssl/add_subject_entry(ca, "C","FR"))
// (Openssl/set_issuer(ca,ca)) // self issued
// (Openssl/set_serial(ca,0))
// (Openssl/set_not_before(ca, -1))
// (Openssl/set_not_after(ca, 30))
// 
// (Openssl/set_basic_constraints(ca, "critical,CA:true,pathlen:0"))
// (Openssl/set_subject_key_identifier(ca, "hash"))
// (Openssl/set_authority_key_identifier(ca, "keyid:always,issuer:always"))
// (Openssl/set_key_usage(ca, "critical,keyCertSign,cRLSign"))
// 
// // create a user certificate
// cert_key :: Openssl/rsa!(512)
// cert :: Openssl/X509!(cert_key)
// 
// (Openssl/add_subject_entry(cert, "CN","bob"))
// (Openssl/add_subject_entry(cert, "O","expert-solutions"))
// (Openssl/add_subject_entry(cert, "C","FR"))
// (Openssl/set_issuer(cert,ca)) // issued by ca
// (Openssl/set_serial(cert,2))
// (Openssl/set_not_before(cert, -1))
// (Openssl/set_not_after(cert, 30))
// 
// (Openssl/set_key_usage(cert, "critical,digitalSignature,nonRepudiation,keyEncipherment"))
// (Openssl/set_subject_key_identifier(cert, "hash"))
// (Openssl/set_authority_key_identifier(cert, "keyid:always,issuer:always"))
// \/code
// So we can append a signature with the certificate cert and its private cert_key.
// we also submit our CA certificate for chain verification :
// \code
// (Pdf/sign(doc, cert, list(ca), cert_key))
// \/code
// Without a given signature format sign defaults to x509.rsa_sha1.\br
// Notice that a reader application should complain about the validity of the above
// signature the supplied certificate can't be verified (unless you actualy define
// the ca certificate as trusted from the reader application point of view). But you'll
// probably use a different certificate for signing...
// @cat

// @doc Invisible digital signatures
[sign(self:pdf_document, x509:Openssl/X509, chain:list[Openssl/X509], k:Openssl/key, frmt:SIGNATURE_FORMAT) : void ->
	self.catalog.acro_form := pdf_interactive_form(doc = self),
	let sf := pdf_signature_widget(doc = self,
				target_page = self.current_page,
				signature = pdf_signature_field(doc = self,
					sig_format = frmt,
					private_key = k,
					certificate = x509,
					cert_chain = chain))
	in (self.catalog.acro_form.fields :add sf,
		self.current_page.annots :add sf)]

// @doc Invisible digital signatures
[sign(self:pdf_document, x509:Openssl/X509, chain:list[Openssl/X509], k:Openssl/key) : void ->
	sign(self, x509, chain, k, "x509.rsa_sha1")]

// @cat Digital signature element
// As for attachments, signatures may be defined with a visual appearance. In the
// following sample we assume that certificates have been created like in the
// sample in the "Invisible signature" category :
// \code
// (print_in_html(doc)
// 	?><signature certificate=<?oid cert ?>
// 			key=<?oid cert_key ?>
// 			chain=<?oid list<Openssl/X509>(ca) ?>
// 			reason="I'm the author"
// 			location=my_city
// 			contact-info=0102030405>
// 		<normal>normal</normal>
// 		<rollover>rollover</rollover>
// 	</signature><?
// end_of_html(doc))
// \/code
// @cat


// *********************************************************************
// *   Part 12: automated TOC                                          *
// *********************************************************************

[build_toc(self:list[ephemeral_object], root:toc_entry) : void ->
	for e in self
		case e
			(html_placed_block
				let h := e.target
				in case h
					(html_h
						let lvl := h.level,
							toc := root
						in (while not(lvl - 1 = toc.level)
								toc := last(toc.subitems),
							toc_entry(doc = root.doc,
										parentitem = toc,
										target = h,
										level = lvl))))]



[element_to_string(self:html_word_chunk) : string -> self.word]
[element_to_string(self:html_element) : string ->
	print_in_string(),
	print_element(self),
	trim(end_of_string())]


[print_element(self:html_inline_element) : void ->
	for i in self.hchildren
		print_element(i)]

[print_element(self:html_block_element) : void ->
	for i in self.hchildren
		print_element(i)]

[print_element(self:html_inline_content) : void ->
	for line in self.lines
		for w in line.words
			(case w
				(html_word_chunk
					printf("~A ", w.word)))]


//<sb> generate the document index in the current section
// note the usage of page break policy : if a title h1 title has
// subtitles we avoid a page break after
[generate_entries(self:toc_entry, secname:string, upto_level:(1 .. 6)) : void ->
	if known?(target, self)
		let trgt := self.target,
			s := element_to_string(trgt),
			lvl := trgt.level
		in (if (length(s) > 0)
				( ?><table class="TOC H<?= lvl ?>">
						<tr>
							<td class="TOC_INDENT">
							<td class="TOC_ENTRY"><a href='##<?oid trgt ?>'><?== s ?></a>
							<td class="TOC_PAGENUM"><pageof target='<?oid trgt ?>'>
					</table><? )),
	if (self.level + 1 <= upto_level)
		for e in self.subitems
			generate_entries(e, secname, upto_level)]


[generate_toc(self:pdf_document) : void -> generate_toc(self, "body", 6)]
[generate_toc(self:pdf_document, upto_level:(1 .. 6)) : void -> generate_toc(self, "body", upto_level)]

//<sb> generate an index for the given section. Both a Pdf index and a page index
// are created, the former implements a Pdf interactive feature, any title of
// the document will appear in the Pdf index, the latter consist of text insertions
// in the current section of the document and ignores titles deeper than upto_level

// @cat Index generator and outliner
// HTML titles (h1 .. h6) may be used to generate both an index
// and outlines for given section. The generated index would be appended to
// the current section so that we generally create a new section specially
// intended to the index. The upto_level parameter sets how deep will
// be the index : only title lower than or equal to upto_level will be part
// of the index. Here is a complete sample :
// \code
// doc :: Pdf/document!()
// 
// // fill a document with titles...
// (print_in_html(doc)
// ?><h1>Introduction</h1>
// 	<h2>What is PDF ?</h2>
// 		<p>blablabla...</p>
// 	<h2>Design consideration</h2>
// 		<p>blablabla...</p>
// <? end_of_html(doc))
// 
// (print_in_html(doc)
// ?><h1>Writer side</h1>
// 	<h2>Low level API</h2>
// 		<p>blablabla...</p>
// 	<h2>HTML renderer</h2>
// 		<p>blablabla...</p>
// <? end_of_html(doc))
// 
// // create a new section for the index,
// // place this section before the body section
// (Pdf/new_section_before(doc, "toc", "body"))
// 
// // insert the 'Index' title in the toc section
// (print_in_html(doc) ?><h1>Index</h1><? end_of_html(doc))
// 
// // generate the index of section body in section toc
// (generate_toc(doc, "body", 2))
// 
// // save the document in file test.pdf
// (Pdf/print_in_file(doc,"test.pdf"))
// \/code
// @cat



// @doc Index generator and outliner
[generate_toc(self:pdf_document, secname:string, upto_level:(1 .. 6)) : void ->
	when sec := some(i in self.section_order | i[1] = secname)
	in let pgs := sec[2].kids,
			toc_root := toc_entry(doc = self, root? = true)
		in (render_section(sec[2]),
			for p in pgs
				for c in p.contents
					for o in list{o in c.operations|o % pdf_html_operation}
						build_toc(o.html_page_elements, toc_root),
			print_in_html(self),
			generate_entries(toc_root, secname, upto_level),
			end_of_html(self))
	else error("generate_toc error, there is no section named ~A", secname)]

	

