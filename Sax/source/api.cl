//*********************************************************************
//* Sax                                               Sylvain Benilan *
//* api.cl                                                            *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*********************************************************************
DEBUG :: 3

// @presentation
// The Sax module provides a simple yet efficient SAX XML parser.
// @presentation

sax_parser <: ephemeral_object

// @cat SAX parsing
// Sax is a simple efficient SAX parser (Simple API for XML). It is used
// to parse simple XML stream in an event oriented way. It is fully written
// in CLAIRE (it has no dependency on a third party library).\br
// Here is a sample that shows how to use the parser. Let us consider the
// following XML that is inserted in a blob :
// \code
// b :: blob!("
// 	<company name='XL'>
// 		<employee name='Sylvain'>
// 			<email>s.benilan@claire-language.com</email>
// 		</employee>
// 	</company>
// 	")
// \/code
// We associate to this simple XML a simple CLAIRE class model :
// \code
// employee <: object  // predef
//
// company <: object(
// 			name:string,
// 			employees:list[employee])
//
// employee <: object(
// 			name:string,
// 			email:string)
// \/code
// We now have to define an event responder for the company element. Notice that,
// in CLAIRE, we may define a really precise domain for our event responder
// (the dynamic dispatch engine of CLAIRE is smart enought to find the
// appropriate restriction). So we can define a restriction of
// xml_enter that takes precisely an element with name "company" :
// \code
// xml_enter(data:list[company], elem:{"company"}, attrs:table) : company ->
// 	let c := company(name = attrs["name"])
// 	in (data add c,
//  	c)
// xml_leave(data:list[company], elem:{"company"}, cdata:string) : employee ->
// 	none
// \/code
// Note that we return a new instance of company, this instance will be used
// as the data transmited to company's sub elements (i.e. emloyees). Then we
// need a responder for the employee element :
// \code
// xml_enter(data:company, elem:{"employee"}, attrs:table) : employee ->
// 	let e := employee(name = attrs["name"])
// 	in (data.employee add e,
// 		e)
// xml_leave(data:company, elem:{"employee"}, cdata:string) : employee ->
// 	none
// \/code
// Here, the domain of our responder is more precise again since we only want
// a data that is of range company. Then we need a responder for the email property
// of an employee, we'll define here a responder for an element 'leave' event :
// \code
// xml_enter(data:employee, elem:{"email"}, attrs:table) : void ->
// 	none
// xml_leave(data:employee, elem:{"email"}, cdata:string) : void ->
// 	(data.email := cdata)
// \/code
// Now that our model is defined, we may invoke the SAX parser which is achieved with :
// \code
// let companies := list[company]
// in (Sax/sax(b, xml_enter, xml_leave, companies),
// 		... // something that uses companies
// 		)
// \/code
[xml_read_upto(p:port, s:subtype[string]) : tuple(string, string) =>
	let t := freadline(p, s) as tuple(string, string)
	in (if not(t[2] % s) error("xml syntax error : one of ~S expected", s), t)]

[xml_read_upto(p:port, s:string, error?:boolean) : string =>
	let t := freadline(p, s)
	in (if (error? & eof?(p)) error("xml premature end of file: ~S expected", s), t)]

[xml_read_upto(p:port, s:string) : string -> xml_read_upto(p, s, true)]


//<sb> xml separators
SEP1 :: {"="," ","\t", "/>",">"}
SEP2 :: {"\"", "'"," ","\t","\n","\r","/>",">"}
AFTER_TAG :: {" ","\t","\n","\r","/>",">"}
SEP4 :: {"/>", ">"}
QTE :: {"\"", "'"}

//<sb> parse a single attribute and add it to the given
// attribute table
[parse_one_attr(parser:sax_parser, p:port, t:table) : string ->
	let (attr, eq) := xml_read_upto(p, SEP1)
	in (attr := trim(attr),
		if (eq != "=")
			(if (length(attr) > 0)
				t[attr] := "",
			eq)
		else
			let (dummy, qte) := xml_read_upto(p, SEP2)
		in (//[DEBUG] parse_one_attr attr:~S dummy:~S, qte:~S // attr, dummy, qte,
			if (qte % QTE) // quoted attribute  (align='left' / align="left")
				(let v := xml_read_upto(p, qte) in 
				 	(t[attr] := v,
					if (left(attr,5) = "xmlns") (
						if (attr[6] = ':') (
							//[DEBUG] add namespace : ~S => ~S // right(attr,length(attr) - 6), v,
							parser.nsmap[right(attr,length(attr) - 6)] := v)
						else (
							//[DEBUG] set current_ns : ~S // v,
							parser.currentns := v)
					)),
				xml_read_upto(p, AFTER_TAG)[2])
			else (t[attr] := dummy, qte)))] // plain attribute (align=left)

//<sb> here are global lists used for callback arguments
// avoid the construction of a new list each time a callback
// is applied
larg4 :: list<any>(0,0,0,0)
build_larg4(x:any, y:any, z:any,a:any) : list =>
	let l := larg4 in (l[1] := x, l[2] := y, l[3] := z, l[4] := a, l)
larg3 :: list<any>(0,0,0)
build_larg3(x:any, y:any, z:any) : list =>
	let l := larg3 in (l[1] := x, l[2] := y, l[3] := z, l)
larg2 :: list<any>(0,0)
build_larg2(x:any, y:any) : list =>
	let l := larg2 in (l[1] := x, l[2] := y, l)
larg1 :: list<any>(0)
build_larg1(x:any) : list =>
	let l := larg1 in (l[1] := x, l)


HANDLER_SET?:boolean := false
BEGIN_HANDLER:property := isa
END_HANDLER:property := isa

xml_handler(parser:sax_parser, attrs:table) : any -> any
xml_handler(parser:sax_parser, attrs:table, userdata:any) : any -> any

doctype_handler(parser:sax_parser, attrs:table) : any -> any
doctype_handler(parser:sax_parser, attrs:table, userdata:any) : any -> any

XML_HANDLER:property := xml_handler
DOCTYPE_HANDLER:property := doctype_handler


set_xml_handler(p:property) : property -> (let oldp := XML_HANDLER in (XML_HANDLER := p, oldp))
set_doctype_handler(p:property) : property -> (let oldp := DOCTYPE_HANDLER in (DOCTYPE_HANDLER := p, oldp))


// @doc SAX parsing
// set_handlers(xml_begin_element, xml_end_element) allows to change the selector
// of the event receivers from within an event receiver.
[set_handler(xml_begin_element:property, xml_end_element:property) : void ->
	HANDLER_SET? := true,
	BEGIN_HANDLER := xml_begin_element,
	END_HANDLER := xml_end_element]


[set_handler(self:sax_parser,xml_begin_element:property, xml_end_element:property) : void ->
	HANDLER_SET? := true,
	self.xml_begin_element_handler := xml_begin_element,
	self.xml_end_element_handler := xml_end_element]

private/DEFAULT_CORE_CHARSET:string := "UTF-8"
private/DEFAULT_FILE_CHARSET:string := "UTF-8"


[set_default_core_charset(self:string) : string -> let old  := DEFAULT_CORE_CHARSET in (DEFAULT_CORE_CHARSET := self, old)]
[set_default_file_charset(self:string) : string -> let old  := DEFAULT_FILE_CHARSET in (DEFAULT_FILE_CHARSET := self, old)]

// @doc SAX parsing
// The parser object definition
sax_parser <: ephemeral_object(
	applyToCallback:boolean = false,
	input:port,
	nsmap:table,
	currentns:string = "",
	xml_begin_element_handler:property,
	xml_end_element_handler:property,	
	xml_doctype_handler:property = doctype_handler,	
	xml_signature_handler:property = doctype_handler,
	xml_declaration_handler:property = xml_handler,
	xml_cdata_handler:property,
	xml_comment_handler:property,
	core_charset:string = "",
	file_charset:string = "",
	xml_data:any)

[close(self:sax_parser) : sax_parser ->
	if unknown?(nsmap,self)
		self.nsmap := make_table(string,(string U {unknown}),unknown),
	if (self.core_charset = "") self.core_charset := DEFAULT_CORE_CHARSET,
	if (self.file_charset = "") self.file_charset := DEFAULT_FILE_CHARSET,
	self]


// @doc SAX parsing
// sax(p,xml_begin_element, xml_end_element) is equivalent to
// sax(p,xml_begin_element, xml_end_element, unknown).
[sax(self:port, xml_begin_element:property, xml_end_element:property) : any =>
	sax(self, xml_begin_element, xml_end_element, unknown)]


// @doc SAX parsing
// sax(p, xml_begin_element, xml_end_element, data) read on the port p an XML stream
// in an event oriented way. Each time an element is entered (resp. leaved) the property
// xml_begin_element (resp. xml_end_element) is applied. The user code should define the
// appropriate restrictions of given properties as a receiver of generated events. The
// given data will be sent to event receivers and the returned value of an enter receiver
// will be used as the data sent to receivers of child elements.
// The event receiver should be defined with the following prototype :
// \code
// xml_begin_element(parser:Sax/sax_parser,data:any, element_name:string, attributes:table) -> any
// xml_end_element(parser:Sax/sax_parser, data:any, element_name:string, cdata:string) -> void
// \/code
// Where attributes is a table containing the attributes of an XML element which associates
// an attribute name to its value, both of range string. cdata is a string that contain 
// the string data of an XML element.\br
// If data is unknown then the prototype of receivers is simplified in :
// \code
// xml_begin_element(element_name:string, attributes:table) -> void
// xml_end_element(element_name:string, cdata:string) -> void
// \/code
[sax(p:port, xml_begin_element:property, xml_end_element:property, data:any) : any ->
	sax(sax_parser( input = p,
					xml_begin_element_handler = xml_begin_element,
					xml_end_element_handler = xml_end_element,
					xml_data = data))]


// @doc SAX parsing
// sax(parser) parse XML using parser object
// @author Xavier Pechoultres
[sax(parser:sax_parser) : any
->	let t := make_table(string, string, ""),
		deep := 0,
		hasdata? := known?(xml_data,parser),
		datastack := list<any>(),
		p := parser.input,
		data := get(xml_data,parser),
		ok? := true,
		mindeep := 0
	in (when ud := get(xml_data,parser) in (datastack :add ud, deep :+ 1,mindeep := 1),
		try
			while (not(eof?(p)) & ok? & deep >= mindeep)
				let cdata := xml_read_upto(p, "<",false),
					c := fread(p, 1),
					go? := true
				in (if eof?(p) none
					//else if (c = "?") freadline(p, "?>")
					else if (c = "/") // end tag
						let tag := xml_read_upto(p, ">", false),
							tagname := trim(tag)
						in (if (deep < mindeep)
								error("Malformed XML near end tag </~A>", tagname),
							if hasdata? apply(parser.xml_end_element_handler, build_larg4(parser,last(datastack), tagname, cdata))
							else apply(parser.xml_end_element_handler, build_larg3(parser, tagname, cdata)),
							if HANDLER_SET?
								(HANDLER_SET? := false),
							deep :- 1,
							if (deep = mindeep) (ok? :=  false,
											//[DEBUG] break on deep=0,
								 			break()),
							shrink(datastack, deep))
					else // start tag
						(if (c = "!") //<sb> handle XML comments/DOCTYPE
							let tmp := fread(p, 2)
							in (if (tmp = "--")
									(go? := false,
									//[0] read comment,
									//c :/+ tmp,
									when comment_handler := get(xml_comment_handler,parser)
									in (if hasdata?  apply(comment_handler, build_larg3(parser, last(datastack), freadline(p, "-->")))
										else apply(comment_handler, build_larg2(parser, freadline(p, "-->"))))
									else freadline(p, "-->"))
								else c :/+ tmp),
						when cdata_handler := get(xml_cdata_handler,parser)
						in (if hasdata? cdata := apply(cdata_handler,build_larg3(parser, last(datastack),cdata ))
							else cdata := apply(cdata_handler,build_larg2(parser, cdata))),
						if go?
							let (tag, sep) := xml_read_upto(p, AFTER_TAG)
							in let tagname := c /+ tag
							in (while not(sep % SEP4) sep := parse_one_attr(parser,p, t),
								if (tagname = "?xml")
									(deep :- 1,
									if hasdata? apply(parser.xml_declaration_handler, build_larg3(parser, t,data))
									else apply(parser.xml_declaration_handler, build_larg2(parser, t)))
								else if (tagname = "!DOCTYPE")
									(deep :- 1,
									if hasdata? apply(parser.xml_doctype_handler, build_larg3(parser, t, data))
									else apply(parser.xml_doctype_handler, build_larg2(parser, t)))
								else
									if hasdata?
										(when x := apply(parser.xml_begin_element_handler, build_larg4(parser, last(datastack), tagname, t))
										in datastack add x
										else datastack add last(datastack))
									else apply(parser.xml_begin_element_handler, build_larg3(parser, tagname, t)),
									if (size(t.mClaire/graph) > 1)
										put(mClaire/graph, t, make_list(29,unknown)),
									if HANDLER_SET?
										( HANDLER_SET? := false /*,
										parser.xml_begin_element_handler := BEGIN_HANDLER,
										parser.xml_end_element_handler := END_HANDLER */ ),
									deep :+ 1,
									if (sep = "/>")
										(if hasdata? apply(parser.xml_end_element_handler, build_larg4(parser, last(datastack), tagname, ""))
										else apply(parser.xml_end_element_handler, build_larg3(parser, tagname, "")),
										if HANDLER_SET?
											(HANDLER_SET? := false /*,
										parser.xml_begin_element_handler := BEGIN_HANDLER,
										parser.xml_end_element_handler := END_HANDLER */ ),
										deep :- 1,
										if (deep = mindeep) (
											//[DEBUG] exit Sax, reach end of xml,
											break()),
										shrink(datastack, deep)))))
				catch any
					(XML_HANDLER := xml_handler,
					DOCTYPE_HANDLER := doctype_handler,
					close(exception!())),
				XML_HANDLER := xml_handler,
				DOCTYPE_HANDLER := doctype_handler,
				data)]

DEBUG_WILDCARD:string := "*"

debug_xml_handler(parser:sax_parser, attrs:table) : any ->
	printf("``BLACK<?xml ~S?>\n", attrs)
debug_doctype_handler(parser:sax_parser,attrs:table) : any ->
	printf("``BLACK<!DOCTYPE ~S>\n", attrs)


debug_enter(parser:sax_parser, s:string, attrs:table) : void ->
	(if match_wildcard?(s,DEBUG_WILDCARD)
		printf("``BLACK<~A ~S>\n", s, attrs))

debug_leave(parser:sax_parser, s:string, cdata:string) : void ->
	(if match_wildcard?(s,DEBUG_WILDCARD)
		printf("``BLACKCDATA[~A]\n</~A>\n", cdata, s))

sax_debug(p:port, wildcard:string) : void ->
	(DEBUG_WILDCARD := wildcard,
	set_xml_handler(debug_xml_handler),
	set_doctype_handler(debug_doctype_handler),
	sax(p, debug_enter, debug_leave, unknown))
	