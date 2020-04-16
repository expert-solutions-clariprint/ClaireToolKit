//
// classe.cl module XML
// Xavier pechoultres
//


// forwards
Node <: ephemeral_object
DocumentType <: Node
Document <: Node
XMLNode <: ephemeral_object
XMLAttr <: ephemeral_object
Attr <: Node

Element <: Node

CharacterData <: Node
Text <: CharacterData
Comment <: CharacterData
CDATASection <: Text
EntityReference <: Node


// @chapter 1
// DOMImplementation
// Namespace object
DOMImplementation <: ephemeral_object(ownerDocument:Document)

[createDocument(_namespace:string,qualifiedname:string,_doctype:DocumentType) : Document
->	let doc := Document(namespaceURI = _namespace, doctype = _doctype)
	in (if (qualifiedname != "") doc.documentElement := createElement(doc,qualifiedname),
		doc)]

[createDocument(_namespace:string,qualifiedname:string) : Document
->	let doc := Document(namespaceURI = _namespace)
	in (if (qualifiedname != "") doc.documentElement := createElement(doc,qualifiedname),
		doc)]

[createDocumentType(qualifiedName:string,publicId:string,systemId:string) : DocumentType
->	DocumentType()]

[hasFeature(feature:string,version:string) : boolean -> true]

// @chapter 1
// DOMException
// error message
DOMException <: exception(code:integer)

INDEX_SIZE_ERR :: 1
DOMSTRING_SIZE_ERR :: 2
HIERARCHY_REQUEST_ERR :: 3
WRONG_DOCUMENT_ERR :: 4
INVALID_CHARACTER_ERR :: 5
NO_DATA_ALLOWED_ERR :: 6
NO_MODIFICATION_ALLOWED_ERR :: 7
NOT_FOUND_ERR :: 8
NOT_SUPPORTED_ERR :: 9
INUSE_ATTRIBUTE_ERR :: 10
INVALID_STATE_ERR :: 11
SYNTAX_ERR :: 12
INVALID_MODIFICATION_ERR :: 13
NAMESPACE_ERR :: 14
INVALID_ACCESS_ERR :: 15

// @chapter 1
// a node of an XML tree
Node <: ephemeral_object(
			nodeName:string,
			nodeValue:string,
			nodeType:integer,
			parentNode:Node,
			childNodes:list[Node],
			firstChild:Node,
			lastChild:Node,
			previousSibling:Node,
			nextSibling:Node,
			attributes:list[Attr],
			ownerDocument:Document,
			namespaceURI:string,
			prefix:string,
			localName:string,
			xmlStandalone:boolean = false, // An attribute specifying, as part of the XML declaration, whether this document is standalone. This is false when unspecified
			xmlVersion:string = "1.0" // An attribute specifying, as part of the XML declaration, the version number of this document.
			)

// @chapter 1
// DOM Document interface
// @see http://www.w3.org/TR/DOM-Level-2-Core/core.html#i-Document
Document <: Node(
		doctype:DocumentType,
		implementation:DOMImplementation = DOMImplementation(),
		documentElement:Element,
		minimize?:boolean = false,
		mime:string = "application/xml",
		interfaceEncoding:string = "UTF-8", // encoding used when getting string
		xmlEncoding:string = "UTF-8") // An attribute specifying, as part of the XML declaration, the encoding of this document

DocumentFragment <: Node()
EntityReference <: Node()

[close(self:Document) : Document 
->	self.ownerDocument := self,
	self.implementation := DOMImplementation(ownerDocument = self),
	self]

[createElement(doc:Document,tagname:string) : Element -> Element(ownerDocument = doc, tagName = tagname)]

[createElement(elem:Element,tagname:string) : Element ->
	let e := Element(ownerDocument = elem.ownerDocument,
			tagName = tagname)
	in (appendChild(elem,e),
		e)]

[createDocumentFragment(doc:Document) : DocumentFragment -> DocumentFragment()]
[createTextNode(doc:Document,_data:string) : Text -> Text(data = _data, ownerDocument = doc)]
/*
 * usefulle but not DOM3 compliant
 */
[createCommentNode(doc:Document,_data:string) : Comment -> Comment(data = _data, ownerDocument = doc)]
[createCDATASection(doc:Document,data:string) : CDATASection -> CDATASection(ownerDocument = doc)]
[createAttribute(doc:Document,attrname:string) : Attr -> Attr(ownerDocument = doc)]
[createEntityReference(doc:Document) : EntityReference -> EntityReference(ownerDocument = doc)]
[getElementsByTagName(doc:Document, tagname:string) : list[Element] -> 
	let l := list<Element>() in (fillElementsByTagName(doc.documentElement,tagname,l), l)]

[private/fillElementsByTagName(e:Element,tagname:string,l:list[Element]) : list[Element]
->	if (e.tagName = tagname) l :add e,
	for subs in e.childNodes (if (subs % Element) fillElementsByTagName(subs,tagname,l)),
	l]

[getElementById(elem:Node,id:string) : (Element U {unknown}) -> unknown]

[getElementById(elem:Element,id:string) : (Element U {unknown}) -> 
	if (elem["ID"] = id) elem as Element
	else (let res:(Element U {unknown}) := unknown in 
			(for subs in elem.childNodes
				(when ok := getElementById(subs,id)
				in (res := ok,
					break(ok))), res))]

[getElementById(doc:Document,id:string) : (Element U {unknown}) -> getElementById(doc.documentElement,id)]

[importNode(doc:Document,node:Node,deep:boolean) : Node -> Node(ownerDocument = doc)]

[createElementNS(doc:Document,namespaceuri:string,qualifiedname:string) : Element -> Element()]

[createAttributeNS(doc:Document,namespaceURI:string, qualifiedName:string) : Attr -> Attr()]


[private/find(self:any,l:list) : integer
->	let res := 0,
		x := 0
	in (while (x < length(l))
		 	(if (l[x] = self) (res := x, x := length(l)),
			x :+ 1),
		res)]


[private/updateFirtsLastChilds(node:Node) : void 
->	//[3] updateFirtsLastChilds(~S) // node,
	if (length(node.childNodes) > 0)
		(node.firstChild := node.childNodes[1],
		node.lastChild := last(node.childNodes))
	else (erase(firstChild,node), erase(lastChild,node))]

[insertBefore(node:Node,newChild:Node,beforechild:Node) : Node -> newChild]
[replaceChild(node:Node,newChild:Node,oldchild:Node) : Node -> newChild]

[removeChild(node:Node,oldchild:Node) : Node ->
	node.childNodes :delete oldchild,
	erase(parentNode,oldchild),
	updateFirtsLastChilds(node),
	oldchild]

[appendChild(node:Node,newChild:Node) : Node -> 
	//[3] appendChild(~S,~S) // node, newChild,
	node.childNodes :add newChild,
	newChild.parentNode := node,
	updateFirtsLastChilds(node),
	newChild]

[appendChild(doc:Document,newChild:Node) : Node -> 
	if known?(documentElement,doc) error("appendChild@Document : documentElement already set"),
	doc.documentElement := newChild,
	erase(parentNode,newChild),
	newChild]

[appendChild(node:Node,newChilds:list[Node]) : Node ->
	//[3] appendChild(~S,~S) // node, newChilds,
	for n in newChilds appendChild(node,n),
	if (length(newChilds) > 0) last(newChilds)
	else node]



[hasChildNodes(node:Node) : boolean -> length(node.childNodes) > 0]

[cloneNode(node:Node,deep:boolean) : Node -> copy(node)]

[normalize(node:Node) : void -> none]

[isSupported(node:Node,feature:string,_version:string) : boolean -> true]

[hasAttributes(node:Node) : boolean -> true]


// @chapter 2
// access to XML Node attribute
[nth(self:Node,key:string) : string
->	when attrib := some( a in self.attributes | (a.name = key)) in 
		(if (attrib.ownerDocument.xmlEncoding != attrib.ownerDocument.interfaceEncoding)
			Iconv/iconv(attrib.value,attrib.ownerDocument.interfaceEncoding,attrib.ownerDocument.xmlEncoding)
		else attrib.value ) else ""]

// @chapter 2
// setting XML Node attribute
[nth=(self:Node,key:string,val:string) : void
->	if (self.ownerDocument.xmlEncoding != self.ownerDocument.interfaceEncoding)
		val := Iconv/iconv(val,self.ownerDocument.xmlEncoding,self.ownerDocument.interfaceEncoding),
	when attrib := some( a in self.attributes | (a.name = key)) in (
		attrib.value := val )
	else self.attributes :add Attr(parentNode = self, ownerDocument = self.ownerDocument, name = key, value = val)]

[nth=(self:Node,key:string,val:integer) : void -> nth=(self,key,string!(val))]
[nth=(self:Node,key:string,val:float) : void -> nth=(self,key,string!(val))]


// @chapter 1
// CharacterData

CharacterData <: Node(data:string)
[substringData(node:CharacterData,offset:integer,count:integer) : string -> substring(node.data,offset,count)]
[appendData(node:CharacterData,str:string) : void -> node.data :/+ str]
[insertData(node:CharacterData,str:string,offset:integer) : void -> node.data :/+ str]

[deleteData(node:CharacterData,offset:integer,count:integer) : void -> none]

[replaceData(node:CharacterData,offset:integer,count:integer,arg:string) : void -> none]



// @chapter 1
// a node attribute
Attr <: Node(
			name:string, // was name in DOM
			specified:boolean = false,			
			value:string, // was value in DOM
			ownerElement:Element)

// @chapter 1
// DOM Element
Element <: Node(tagName:string)

[getAttribute(elem:Element,attrname:string) : string ->
	if (elem.ownerDocument.interfaceEncoding != elem.ownerDocument.xmlEncoding)
		Iconv/iconv(elem[attrname],elem.ownerDocument.interfaceEncoding,elem.ownerDocument.xmlEncoding)
	else elem[attrname]]

[setAttribute(elem:Element,attrname:string,val:string) : void ->
	if (elem.ownerDocument.interfaceEncoding != elem.ownerDocument.xmlEncoding)
		elem[attrname] := Iconv/iconv(val,elem.ownerDocument.xmlEncoding,elem.ownerDocument.interfaceEncoding)
	else elem[attrname] := val]

[removeAttribute(elem:Element,attrname:string) : void -> when attrib := some( a in elem.attributes | (a.name = attrname)) in delete(elem.attributes,attrib)]

[getAttributeNode(elem:Element,attrname:string) : (Attr U {unknown}) -> 
	when attrib := some( a in elem.attributes | (a.name = attrname)) in attrib else unknown]

[setAttributeNode(elem:Element,attr:Attr) : Attr ->
	removeAttribute(elem,attr.name),
	elem.attributes :add attr,
	attr.parentNode := elem,
	attr]

[getElementsByTagName(elem:Element,tagname:string) : list[Element] -> 
	let l := list<Element>()
	in	(for subs in elem.childNodes (if (subs % Element) fillElementsByTagName(subs,tagname,l)),
		l)]

[getAttributeNS(elem:Element,namespaceURI:string,localName:string) : string -> error("getAttributeNS() not implemented"),""]

[setAttributeNS(elem:Element,namespaceURI:string,qualifiedName:string,val:string) : void -> error("setAttributeNS() not implemented")]

[removeAttributeNS(elem:Element,namespaceURI:string,localName:string) : void -> error("removeAttributeNS() not implemented")]

[getAttributeNodeNS(elem:Element,namespaceURI:string,localName:string) : Attr -> error("getAttributeNodeNS() not implemented"), Attr()]

[setAttributeNodeNS(elem:Element,newAttr:Attr) : Attr ->  error("setAttributeNodeNS() not implemented"), newAttr]

[getElementsByTagNameNS(elem:Element,namespaceURI:string,localName:string) : list[Node] -> nil]

[hasAttribute(elem:Element,attrname:string) : boolean -> exists(e in elem.attributes | e.name = attrname)]

  // Introduced in DOM Level 2:
[hasAttributeNS(elem:Element,namespaceURI:string,localName:string) : boolean -> false]


// @chapter 1
// DOMInterface Text
Text <: CharacterData()

[splitText(node:Text,offset:integer) : Text -> Text()]


Comment <: CharacterData()
CDATASection <: Text()

DocumentType <: Node(
		name:string, // The name of DTD; i.e., the name immediately following the DOCTYPE keyword
		entities:table,
		notations:table,
		publicId:string,
		systemId:string,
		internalSubset:string)
		

Notation <: Node(
	publicId:string, // The public identifier of this notation. If the public identifier was not specified, this is null
	systemId:string // The system identifier of this notation. If the system identifier was not specified, this is null.
	)

Entity <: Node(
		publicId:string,
		systemId:string,
		notationName:string)
