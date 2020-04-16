
// @chapter 2
// construct an XML tree given a raw of string
[domStartHandler(parser:Sax/sax_parser, _x:Node,tag:string,attrTable:table) : any
->	//[3] create Element ...,
	let n := (createElement(_x.ownerDocument,tag)),
		_graph := attrTable.mClaire/graph
    in (appendChild(_x,n),
		//[3] appendChild OK,
    	for i in (1 .. (length(_graph) / 2))
    		let key := _graph[2 * i - 1],
    			_value := _graph[2 * i] in
    		(if known?(key) setAttribute(n,key,strunescape(_value))),
		//[3] << domStartHandler,
    	n)]

[domCDATAHandler(parser:Sax/sax_parser, _x:any,cdata:string) : any
->	appendChild(_x,createTextNode(_x.ownerDocument,cdata))]


[domCommentHandler(parser:Sax/sax_parser, _x:any,cdata:string) : any
-> appendChild(_x,createCommentNode(_x.ownerDocument,replace(cdata,"\r","")))]


[domEndHandler(parser:Sax/sax_parser, _x:Element,tag:string,cdata:string) : any
->	let d := trim(cdata) in (if (d != "") appendChild(_x,createTextNode(_x.ownerDocument,cdata))),
	when p := get(parentNode,_x) in p
	else _x.ownerDocument]

[domEndHandler(parser:Sax/sax_parser, _x:Document,tag:string,cdata:string) : any
->	//[3] <<  End of Document,
	_x]

[domEndHandler(parser:Sax/sax_parser, _x:any,tag:string,cdata:string) : any
->	//[3] << domEndHandler(~S,~A,~A) // _x,tag,cdata,
	_x]

[domDocTypeHandler(parser:Sax/sax_parser, _x:any,attrs:table) : any
-> //[3] domDocTypeHandler(~S,~S) // _x,attrs,
	_x]

[domDeclarationHandler(parser:Sax/sax_parser, attrs:table,_x:Document) : any
-> //[3] domDeclarationHandler(~S,~S) // _x,attrs,
	if (attrs["version"] != "") _x.xmlVersion := attrs["version"],
	if (attrs["encoding"] != "") (
		_x.xmlEncoding := attrs["encoding"]),
	_x]

[private/setupSax() : Sax/sax_parser
->	Sax/sax_parser(	Sax/xml_begin_element_handler = domStartHandler,
					
//					Sax/xml_doctype_handler = domDocTypeHandler,	
//					Sax/xml_signature_handler = domDocTypeHandler,
					Sax/xml_declaration_handler = domDeclarationHandler,
//					Sax/xml_cdata_handler = domCDATAHandler,
					Sax/xml_comment_handler = domCommentHandler,
					Sax/xml_end_element_handler = domEndHandler
					)]

// @chapter 2
// construct an XML tree given a raw of string
[document!(rawtext:string) : Document
-> let d := Document(),
		p := port!(rawtext)
   in (Sax/sax(p,domStartHandler,domEndHandler,d), d)]

// construct an XML tree given a raw of string
[document!(p:port) : Document
-> let d := Document(),
		parser := setupSax()
	in (parser.Sax/input := p,
		parser.Sax/xml_data := d,
		Sax/sax(parser),
		d)]

[file(s:string) : Document
-> let f := fopen(s,"r"), res := document!(f) in (fclose(f),res)]
