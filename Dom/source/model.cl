

//
// classe.cl module XML
// Sylvain Benilan
//


// forwards

XMLDoc <: ephemeral_object
XMLNode <: ephemeral_object
XMLAttr <: ephemeral_object

// @chapter 1
// the root of an XML tree
XMLDoc <: ephemeral_object(children:list<XMLNode>,     // children list
                           filename:string)            // file


// @chapter 1
// a node of an XML tree
XMLNode <: ephemeral_object(children:list<XMLNode>,    // children list
                            father:(XMLNode U XMLDoc), // father node
                            tagname:string,            // the node name
                            text:string,               // the node data
                            attr:list<XMLAttr>)        // the attribute list


(inverse(children) := father)


// @chapter 1
// a node attribute
XMLAttr <: ephemeral_object(attrname:string,           // attribute name
                            text:string)               // attribute value



[self_print(self:XMLNode) : void
->	printf("<~A~I",(if known?(tagname,self) tagname(self) else "?"),(if ((unknown?(text,self) | self.text = "") & length(self.children) = 0) princ("/>")
								else princ(" ..>")))]
//
// xmlprint.cl module XML
// Sylvain Benilan
//

// @chapter 2
// calculate the level of indentation of an element in an XML tree 
[indentlevel(n:(XMLDoc U XMLNode)) : integer
-> let i := 1 in (while (n % XMLNode & known?(father,n)) (i :+ 1, n := n.father), i)]

// @chapter 4
// just prints spaces according to the indentation level
[indent(n:XMLNode) : string
-> let res := "\n"
   in (for i in (2 .. indentlevel(n) - 1) res :/+ "\t", res)]

// @chapter 4
// prints an attribute (attrName="attrValue")
[print(a:XMLAttr) : void
-> if (known?(text,a) & known?(attrname,a))
	printf(" ~A=\"~A\"",a.attrname,a.text)]
;-> princ(" " /+ a.attrname /+ "=\"" /+ a.text /+ "\"")]


// @chapter 4
// prints a node and its subnodes if has some
[print(n:XMLNode) : void
->	if known?(tagname,n) (
		princ(indent(n) /+ "<" /+ n.tagname),
		if known?(attr,n) (for a in n.attr print(a)),
		if ((unknown?(text,n) | n.text = "") & length(n.children) = 0) princ("/>")
		else (
			princ(">"),
			if known?(text,n) princ(n.text),
			if (length(n.children) > 0) (for sn in n.children print(sn), princ(indent(n))),
			if known?(tagname,n) princ("</" /+ n.tagname /+ ">")))]


// @chapter 4
// prints an XML document
[print(d:XMLDoc) : void
-> for n in d.children print(n)]

// @chapter 4
// save an xml doc in a file
[save(d:XMLDoc,filename:string) : void
-> let p:port := fopen(filename,"w")
   in (use_as_output(p), print(d), fclose(p))]

// @chapter 4
// pretty prints an XML tree in a string
[save(d:XMLDoc) : string
-> (print_in_string(), print(d), end_of_string())]

// @chapter 4
// pretty prints an xml node in a string
[save(n:XMLNode) : string
-> (print_in_string(), print(n), end_of_string())]

//
// xmlparser.cl module XML
// Sylvain Benilan
//


// @chapter 2
// construct an XML tree given file path
;[makeXMLDocFromFile(file:string) : XMLDoc
;-> let d := XMLDoc(filename = file)
;   in (current := d, parseXMLFile(d.filename), current := XMLNode(), d)]
;

[domStartHandler(_x:any,tag:string,attrTable:table) : any
-> if (_x % XMLDoc)
	//[3] >> domStartHandler(~S,~A,...) // _x,tag
	else //[3] >> domStartHandler(~S[~A],~A,...) // _x,(when x := get(tagname,_x) in x else "?"),tag,
	let n := XMLNode(tagname = tag),
		_graph := attrTable.mClaire/graph
    in (_x.children :add n,
    	for i in (1 .. (length(_graph) / 2))
    		let key := _graph[2 * i - 1],
    			_value := _graph[2 * i] in
    		(if known?(key)
    			n.attr :add XMLAttr(attrname = key, text = trim(_value))),
    	n)]

[domEndHandler(_x:any,tag:string,cdata:string) : any
-> if (_x % XMLDoc) //[3] << domEndHandler(~S,~A,~A) // _x,tag,cdata
	else //[3] << domEndHandler(~S[~A],~A,~A) // _x,_x.tagname,tag,cdata,
	if (_x % XMLDoc) _x
	else (_x.text := trim(cdata),_x.father)]

// @chapter 2
// construct an XML tree given a raw of string
[makeXMLDoc(rawtext:string) : XMLDoc
-> let d := XMLDoc(),
		p := port!(rawtext)
   in (Sax/sax(p,domStartHandler,domEndHandler,d), d)]

// construct an XML tree given a raw of string
[makeXMLDoc(p:port) : XMLDoc
-> let d := XMLDoc()
   in (Sax/sax(p,domStartHandler,domEndHandler,d), d)]

[makeXMLDocFromFile(pathFile:string) : XMLDoc
-> let d := XMLDoc(),
		p := fopen(pathFile,"r")
   in (Sax/sax(p,domStartHandler,domEndHandler,d), d)]


// @chapter 2
// construct a node base XML tree given a raw of string
[makeXMLNode(rawtext:string) : XMLNode
-> let d := XMLNode(),
		p := port!(rawtext)
   in (Sax/sax(p,domStartHandler,domEndHandler,d),
		d.children[1])]

// @chapter 2
// nodes count in a XML tree
[count(n:(XMLNode U XMLDoc)) : integer 
-> let i := 1 
   in (for sn in n.children (i :+ count(sn)),i)]


// @chapter 2
// access to XML Node attribute
[nth(self:XMLNode,key:string) : string
->	when attrib := some( a in self.attr | insensitive=(a.attrname,key)) in attrib.text else ""]

// @chapter 2
// setting XML Node attribute
[nth=(self:XMLNode,key:string,val:string) : void
->	when attrib := some( a in self.attr | insensitive=(a.attrname,key)) in attrib.text := val 
	else self.attr :add XMLAttr(attrname = key, text = val)]

// @chapter 2
// access to named sub node 
[subNodeOfName(self:XMLNode,nodeName:string) : (XMLNode U {unknown})
-> some(i in self.children | insensitive=(i.tagname,nodeName))]

// @chapter 2
// access to named sub nodes 
[subNodesOfName(self:Dom/XMLNode,nodeName:string) : set[Dom/XMLNode]
-> {i in self.children | insensitive=(i.tagname,nodeName)}]

// @chapter 2
// add named sub nodes 
[addSubNodeWithName(self:Dom/XMLNode,keyname:string) : Dom/XMLNode
->	let node := Dom/XMLNode(tagname = upper(keyname)) in (self.children :add node, node)]
