
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * model.cl                                                          *
// * Copyright (C) 2000 - 2004 xl. All Rights Reserved                 *
// *********************************************************************

// *********************************************************************
// *   Part 1: pdf model                                               *
// *   Part 2: content                                                 *
// *   Part 3: annotation                                              *
// *   Part 4: image                                                   *
// *   Part 5: text                                                    *
// *   Part 6: color                                                   *
// *   Part 7: graphic state                                           *
// *   Part 8: path                                                    *
// *   Part 9: interactive form                                        *
// *   Part 10: TOC                                                    *
// *   Part 11: Signature field                                        *
// *********************************************************************

// @presentation
// The Pdf module is used to write and read PDF (Portable Document Format)
// documents. On the one hand the PDF writer comes with a set of low level API to
// create pages, text boxes (using AFM font descriptions), graphic objects, PNG
// images, annotations, attachments, outlines and digital signatures. On top of
// this low level tools, the PDF writer has a (user extensible) HTML renderer
// with automated page layouting. On the second hand the PDF reader allow us
// to inspect the object structure of a PDF document and verify digital signature.
// @presentation

// @author Sylvain BENILAN


// 	@@sec Introduction
// 		@@cat What is PDF ?
// 		@@cat Pdf module design
// 		@@cat Rectangles
// 	@@sec Writer side - low level
// 		@@cat Document creation								@@ document pdf_document
// 		@@cat Sections and pages							@@ section sections page pages
// 		@@cat Graphic state									@@ gstate matrix
// 		@@cat Path construction								@@ path paths
// 		@@cat Rectangles, circles, quads and triangles		@@ simple_shape
// 		@@cat Fonts and AFM file metrics					@@ afm font fonts
// 		@@cat Text layout									@@ text_layout
// 		@@cat Text objects									@@ text texts
// 		@@cat Images										@@ image
// 		@@cat Invisible attachments							@@ attachment attachments
// 		@@cat Invisible digital signatures					@@ signature signatures
// 	@@sec Writer side - HTML/CSS renderer
// 		@@cat Design consideration
// 		@@cat CSS support									@@ css styling style styler
// 		@@cat HTML redirection and Wcl syntax
// 		@@cat XObject and simple HTML formated boxes		@@ xobject xobjects
// 		@@cat Main document HTML stream
// 		@@cat Headers and footer							@@ header footer
// 		@@cat Driving page break algorithm					@@ page-break
// 	@@sec Special HTML elements
// 		@@cat User area element								@@ area areas
// 		@@cat XObject element
// 		@@cat pagenum/pagecount elements					@@ pagenum pagecount
// 		@@cat Attachment element
// 		@@cat Digital signature element
// 		@@cat Index generator and outliner					@@ toc outline outlines
// 	@@sec Extensibility
// 		@@cat User defined HTML elements					@@ substitution
// 		@@cat Blockquote implementation						@@ blockquote blockquotes
// 		@@cat Bullet implementation							@@ bullet bullets
// 		@@cat List implementation
// 	@@sec Reader side
// 		@@cat Loading and inspecting a PDF document
// 		@@cat Attachment extraction
// 		@@cat Digital signature verification

// @cat What is PDF ?
// PDF stands for Portable Document Format. As the name implies, it is a data
// format that can be used to describe documents. Adobe, the developers of PDF,
// market software to create, edit and visualize PDF files. Because the
// specifications of the file format are publicly available, a lot of other
// companies develop software for PDF as well. In prepress, PDF is used more and
// more as a format to exchange data between applications. For authenticity
// consideration PDF came with the ability to be digitally signed and/or
// crypt.\br
// This module will creates document according to "PDF Reference third edition"
// (Version 1.4).
// @cat

// @cat Pdf module design
// \h4 Writer side\/h4
// On the writer side Pdf contains three layers of abstraction for PDF
// creation.
// \h5 Close to the PDF object model at the low level\/h5
// The low level API is close to the PDF object model, we may
// create pages and fill them by hand with text objects, graphic objects,
// attachments and digitally sign. A set of text layout API is made available
// in order to help at rendering styled text.\br
// \h5 HTML renderer\/h5
// The second level is the HTML renderer, the
// content of the document may be given in the HTML/CSS format which is a
// concise format for layout and style description, the renderer would apply an auto-layout
// and auto page-break algorithm to render an HTML stream in multiple PDF pages.\br
// Additionally to traditional html elements, we introduce some custom elements intended to
// handle special PDF (interactive) features :
// \ul
// \li area : areas are replaced elements that behaves like an owner-draw control : they
// are connected to an handler that would draw the area content using the low level API
// (including HTML formated boxes).
// \li xobject : replaced by the content of an xobject
// \li attachment : would insert a new attachment in the document with data either
// inline or submitted by callback and interactive appearance sub elements.
// \li signature : signature are special elements that would add a digital signature
// object to the document and given an interactive appearance.
// \/ul
// \h5 Extensible\/h5
// At a last level of abstraction we find the ability to substitute elements,
// new elements are always described using simpler elements such the layout
// and page-break naturally handles new elements. New elements would naturally
// be handled by the style sheet that could even be extended with new properties.
// \h4 Reader side\/h4
// On the reader side any PDF document may be loaded, the model used by
// the reader differs from the one used by the writer. A PDF document can be
// represented as a dictionary (like a file system) and the reader API is designed
// as a generic accessor to objects given their 'path'. For convenience there
// is specialized API like loading attachments or verifying signature.\br
// @cat

// *********************************************************************
// *   Part 1: pdf model                                               *
// *********************************************************************

// @doc Rectangles
// rectangle is a simple class that represents a rectangular box with the
// same orientation as the page. It is holds the position of the
// four borders of the rectangle box.
rectangle <: ephemeral_object(
	left:float,
	top:float,
	right:float,
	bottom:float)

css_style_sheet <: ephemeral_object
css_selector <: ephemeral_object

element_context <: ephemeral_object

html_attribute <: ephemeral_object

html_entity <: ephemeral_object
	html_inline_content <: html_entity
	html_scalable_entity <: html_entity
		html_word <: html_scalable_entity
		html_word_chunk <: html_scalable_entity
		html_element <: html_scalable_entity
			html_inline_element <: html_element

				html_a <: html_inline_element
				html_u <: html_inline_element
				html_b <: html_inline_element
				html_i <: html_inline_element
				html_em <: html_inline_element
				html_sup <: html_inline_element
				html_sub <: html_inline_element
				html_pseudo_element <: html_inline_element

			html_element_with_box <: html_element
				html_block_element <: html_element_with_box
					html_document <: html_block_element
					html_table <: html_block_element
					html_td <: html_block_element
					html_h <: html_block_element
					html_appearance <: html_block_element
					html_annotation <: html_block_element
						html_attachment <: html_annotation
						html_widget <: html_annotation
					
				html_embeded_element <: html_element_with_box
					html_img <: html_embeded_element
					html_xobject <: html_embeded_element
					html_area <: html_embeded_element

pdf_object <: ephemeral_object
	pdf_info <: pdf_object
	pdf_page <: pdf_object
	pdf_catalog <: pdf_object
	pdf_resource <: pdf_object
		pdf_font <: pdf_resource
		pdf_image <: pdf_resource
	pdf_content <: pdf_object
	pdf_annot <: pdf_object
	pdf_section <: pdf_object
	pdf_interactive_form <: pdf_object
	
font_descriptor <: ephemeral_object

pdf_graphic_operation <: ephemeral_object

page_created :: property(open = 3)

pdf_document <: ephemeral_object(
		creation_date:float,
		//<sb> output processing's buffers
		oldport:port,
		pdfport:port,
		css_oldport:port,
		streambuf:port,
		streamport:port,
		streamoldport:port,
		deflate?:boolean = true, //<sb> enable zlib compression for page contents
		left_margin:float, //<sb> document margins
		top_margin:float,
		right_margin:float,
		bottom_margin:float,
		//<sb> in this implementation a document is seen as a list of
		// named and ordered sections with their own page numbering system
		section_order:list[tuple(string, pdf_section)],
		page_format:string = "A4", //<sb> see tools.cl for available formats
		landscape?:boolean = false, //<sb> page orientation
		current_id:integer = 0, //<sb> object id generator
		current_font_id:integer = 0, //<sb> font id generator
		current_image_id:integer = 0, //<sb> image id generator
		//<sb> content is a container for textual and graphical page operations
		// this one is the current content of the current page of the current section !
		// as for other current_xx ...
		current_content:pdf_content,
		current_font:pdf_font,
		current_fontsize:float,
		current_page:pdf_page,
		//<sb> at the root of a PDF document we have and an info object (creator, subject ...)
		// and a catalog (resources, page tree, outlines ...)
		info:pdf_info,
		catalog:pdf_catalog,
		//<sb> fonts used in this document see font.cl
		fonts:set[pdf_font],
		font_map:table,
		in_a_with_name:string = "",
		style_sheet:css_style_sheet,
		tables:list[html_table],
		last_inline_content:html_inline_content,
		html_name_map:table, //<sb> destinations of a document are global (inter sections)
		xobject_map:table,
		pagecount:integer = 0,
		element_id:integer = 0, //<sb> element unique name generator
		resource_target_stack:list[pdf_object],
		objects:list[pdf_object],
		pending_annots:list[pdf_annot],
		doc_userdata:any,
		base_url:string = "",
		last_debug_location:any)


pdf_object <: ephemeral_object(
		id:integer,
		doc:pdf_document)

(inverse(doc) := objects)

[close(self:pdf_object) : pdf_object ->
	self.doc.current_id :+ 1,
	self.id := self.doc.current_id,
	self]

[self_print(self:pdf_object) : void ->
	printf("<~S ~S>", owner(self), get(id, self))]

pdf_resource <: pdf_object()

[set_resource_target(self:pdf_object) : void ->
	self.doc.resource_target_stack := list<pdf_object>(self)]

[push_resource_target(self:pdf_object) : void ->
	self.doc.resource_target_stack add self]

[pop_resource_target(self:pdf_document) : void ->
	let l := self.resource_target_stack
	in shrink(l, (length(l) - 1) max 0)]

[use_resource(self:pdf_resource) : void =>
	self.doc.resource_target_stack[length(self.doc.resource_target_stack)].resources add self]

pdf_info <: pdf_object(
		title:string,
		author:string,
		producer:string,
		subject:string)


pdf_section <: pdf_object(
	dim:rectangle,
	resources:set[pdf_resource],
	current_html_document:html_document,
	template_margin:float,
	section_root:pdf_catalog,
	//<sb> tell that new operations should be added in the processed area
	inside_html_area?:boolean = false,
	areas:list[html_area],
	current_area:html_area,
	pb_processed?:boolean = false,
	header_docs:list[html_document],
	maxh_header:float,
	footer_docs:list[html_document],
	maxh_footer:float,
	//<sb> track transformation matrices such we can get user space coordinates
	// of a point in the the current space
	matrices:list[list[float]] = list<list[float]>(list(1.,0.,0.,1.,0.,0.)),
	kids:list[pdf_page])

pdf_page <: pdf_object(
	parent:pdf_section,					// parent page tree node
	pagenum:integer = 0,				// page number
	annots:list[pdf_annot],				// page annotations
	contents:list[pdf_content])         // a list of content associated with the page

(inverse(kids) := parent)

pdf_page_tree <: pdf_object(
	ref_catalog:pdf_catalog)

pdf_embedded_file <: pdf_object

pdf_filespec <: pdf_object(name:string, adbeid:string,embeddedfile:pdf_embedded_file)

pdf_javascript <: pdf_object(script:string)

pdf_names <: pdf_object(
	javascripts:list[pdf_javascript],
	embeddedfiles:list[pdf_filespec])

pdf_catalog <: pdf_object(
	page_tree_root:pdf_page_tree,
	sections:list[pdf_section],
	toc_section:pdf_section,
	current_section:pdf_section,				// the document page tree root
	names:pdf_names,
	acro_form:pdf_interactive_form)


(inverse(section_root) := sections)
(inverse(ref_catalog) := page_tree_root)


font_descriptor <: ephemeral_object

pdf_font <: pdf_resource(
		fontnum:integer,					// the id for the font object
		font:font_descriptor)					// the font descriptor object

// *********************************************************************
// *   Part 2: content                                                 *
// *********************************************************************

pdf_content <: pdf_object(
	page:pdf_page,							// the page that own this content
	operations:list[pdf_graphic_operation])


// *********************************************************************
// *   Part 4: image                                                   *
// *********************************************************************

pdf_image_colorspace <:  pdf_object(
		space:string,
		spdata:string)

pdf_image <: pdf_resource(
	imid:integer,
	imwidth:float,
	imheight:float)

	pdf_png <: pdf_image(
		pngdata:string,
		bitdepth:integer,
		colortype:integer,
		ncolor:integer,
		colorspace:pdf_image_colorspace,
		// methods
		m_compression:integer,
		m_filter:integer,
		m_interlaced:integer,
		// transparency
		t_type:string = "",
		t_data:integer,
		t_r:integer,
		t_g:integer,
		t_b:integer)

	pdf_jpg <: pdf_image(
		jpgdata:blob,
		bitdepth:integer,
		colortype:integer,
		ncolor:integer,
		colorspace:pdf_image_colorspace)


// *********************************************************************
// *   Part 5: text                                                    *
// *********************************************************************

pdf_graphic_operation <: ephemeral_object(
		ref_doc:pdf_document,
//		ref_content:pdf_content,
		inside_html_area?:boolean = false)

[close(self:pdf_graphic_operation) : pdf_graphic_operation ->
	let d := self.ref_doc,
		sec := d.catalog.current_section
	in (if (sec.inside_html_area?)
			(sec.current_area.area_operations add self,
			self.inside_html_area? := true)
		else when ct := get(current_content, d)
			in ct.operations add self,
		self)]
/*	let sec := self.ref_doc.catalog.current_section
	in (self.inside_html_area? := sec.inside_html_area?,
		if self.inside_html_area?
			sec.current_area.area_operations :add self,
		self)]*/


	pdf_moveto <: pdf_graphic_operation(x:float, y:float)

	pdf_text_operation <: pdf_graphic_operation()

		pdf_begin_text <: pdf_text_operation(x:float, y:float, angle:float)

		pdf_select_font <: pdf_text_operation(
			fontnum:integer,
			fontsize:float = 14.0)
	
		pdf_show_text <: pdf_text_operation(text:string)
		pdf_new_text_line <: pdf_text_operation(TL:float)

		pdf_end_text <: pdf_text_operation()


	pdf_image_show <: pdf_graphic_operation(
		im:pdf_image,
		imx:float,
		imy:float,
		imwidth:float,
		imheight:float)

	pdf_html_operation <: pdf_graphic_operation(
		html_page_elements:list[ephemeral_object])


// *********************************************************************
// *   Part 6: color                                                   *
// *********************************************************************


pdf_extgstate <: pdf_resource(opacity:float)

pdf_color <: pdf_graphic_operation(r:float, g:float, b:float)
pdf_stroke_color <: pdf_graphic_operation(r:float, g:float, b:float)
pdf_alpha <: pdf_graphic_operation(extgstate:pdf_extgstate)



// *********************************************************************
// *   Part 7: graphic state                                           *
// *********************************************************************


pdf_push_state <: pdf_graphic_operation()

pdf_pop_state <: pdf_graphic_operation()

pdf_set_matrix <: pdf_graphic_operation(
	_a:float, _b:float, _c:float,
	_d:float, _e:float, _f:float)

pdf_line_width <: pdf_graphic_operation(w:float)

MITTER_JOIN :: 0
ROUND_JOIN :: 1
BEVEL_JOIN :: 2

pdf_line_join <: pdf_graphic_operation(m:{MITTER_JOIN,ROUND_JOIN,BEVEL_JOIN})

BUTT_CAP :: 0
ROUND_CAP :: 1
SQUARE_CAP :: 2

pdf_line_cap <: pdf_graphic_operation(m:{BUTT_CAP,ROUND_CAP,SQUARE_CAP})

pdf_line_dash <: pdf_graphic_operation(
	dash:list[float],
	dashphase:float)
								

// *********************************************************************
// *   Part 8: path                                                    *
// *********************************************************************

pdf_begin_path <: pdf_graphic_operation(
	x:float,
	y:float)

pdf_lineto <: pdf_graphic_operation(
	x:float,
	y:float)

pdf_curveto <: pdf_graphic_operation(
	cx1:float,
	cy1:float,
	cx2:float,
	cy2:float,
	cx3:float,
	cy3:float)

pdf_end_path <: pdf_graphic_operation(endop:string)


// *********************************************************************
// *   Part 9: interactive form                                        *
// *********************************************************************

pdf_interactive_form <: pdf_object(
		src:html_element,
		fields:list[pdf_object],
		sig_flags:integer = 3) // SignatureExists | AppendOnly

// *********************************************************************
// *   Part 3: annotation                                              *
// *********************************************************************

pdf_form_xobject <: pdf_resource(
	src:html_element,
	resources:set[pdf_resource],
	xobject_elements:list[ephemeral_object])

pdf_debug_xobject <: pdf_resource(resources:set[pdf_resource], datastream:blob, deflate?:boolean = true)


pdf_appearance_xobject <: pdf_form_xobject(
	kind:{"N", "D", "R"})

pdf_appearance_stream <: pdf_object(
	normal:pdf_form_xobject,
	rollover:pdf_form_xobject,
	down:pdf_form_xobject)

pdf_embedded_file <: pdf_object(
	ignoredate?:boolean = false,
	inline_data:port,
	userdata:any,
	mimetype:string = "plain/text",
	filepath:string)

// @doc Invisible digital signatures
SIGNATURE_FORMAT :: {"x509.rsa_sha1", "pkcs7.sha1"}

pdf_signature_field <: pdf_object(
	reason:string = "unknown reason",
	siglocation:string = "unknown location",
	signer:string = "unknown signer",
	contact_info:string = "unknown contact info",
	sig_format:SIGNATURE_FORMAT = "x509.rsa_sha1",
	private_key:Openssl/key,
	certificate:Openssl/X509,
	cert_chain:list[Openssl/X509])


pdf_annot <: pdf_object(
				target_page:pdf_page,
				href:string,
				src:html_element,
				linkrect:rectangle,
				content:string = "unknown content",
				appearance:pdf_appearance_stream)

(inverse(annots) := target_page)

	fill_attachment :: property(open = 3)
	fill_attachment_name :: {"Graph", "PushPin", "Paperclip", "Tag"}
	pdf_file_attachment <: pdf_annot(
			embeddedfile:pdf_embedded_file,
			name:fill_attachment_name = "Paperclip")
	
	
	pdf_free_annot <: pdf_annot(debug_box:rectangle)
	pdf_text_annot <:  pdf_annot(debug_box:rectangle)

	pdf_link <: pdf_annot()
		pdf_html_link <: pdf_annot(dest:string)
			pdf_href_link <: pdf_html_link()

	pdf_widget <: pdf_annot()

		pdf_button <: pdf_annot(pageid:integer, debug_box:rectangle, ref_xobject:pdf_debug_xobject)
		pdf_show_hide_button <: pdf_button(rollover:pdf_button, debug_file:pdf_filespec)

		pdf_signature_widget <: pdf_widget(
			signature:pdf_signature_field)


// *********************************************************************
// *   Part 10: TOC                                                    *
// *********************************************************************

toc_entry <: pdf_object

toc_entry <: pdf_object(
				root?:boolean = false,
				level:integer = 0,
				target:html_h,
				parentitem:toc_entry,
				link:pdf_html_link,
				subitems:list[toc_entry])

(inverse(subitems) := parentitem)
