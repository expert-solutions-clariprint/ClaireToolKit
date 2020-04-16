
// @chapter 4
// default printing method
[self_print(self:Node) : void
->	printf("<~A~I",(if known?(tagName,self) tagName(self) else "?"),(if not(hasChildNodes(self)) princ("/>")
								else princ(" ..>")))]

[self_print(self:Document) : void
->	printf("[DOM/~I]",(when o := get(documentElement,self) in self_print(o) else princ("?")))]


[self_print(self:Attr) : void
->	printf("[~A=~S]",get(name,self), get(value,self))]

// @chapter 4
// calculate the level of indentation of an element in an XML tree 
[indentlevel(n:Node) : integer
-> let i := 2 in (while (known?(parentNode,n)) (i :+ 1, n := n.parentNode), i)]

// @chapter 4
// just prints spaces according to the indentation level
[indent(n:Node) : string
-> if (n.ownerDocument.minimize?) "" else
	let res := "\n"
	in (for i in (2 .. indentlevel(n) - 1) res :/+ "\t", res)]

// @chapter 4
// prints an attribute (attrName="attrValue")
[print(a:Attr) : void
-> if (known?(value,a) & known?(name,a))
	printf(" ~A=\"~A\"",a.name,strescape(a.value))]
// @chapter 4
// prints an attribute (attrName="attrValue")
[print(a:Attr,indent?:boolean) : void
-> if (a.ownerDocument.minimize?) indent? := false,
	if (known?(value,a) & known?(name,a))
	printf("~A~A=\"~A\"",(if indent? indent(a) else " "),a.name,strescape(a.value))]


// @chapter 4
// prints a node and its subnodes if has some
[print(n:Element) : void
->	if known?(tagName,n) (
		princ(indent(n) /+ "<" /+ n.tagName),
		if known?(attributes,n) (for a in n.attributes print(a, (length(n.attributes) > 10))),
		if hasChildNodes(n)
			(princ(">"),
			for sn in n.childNodes print(sn),
			princ(indent(n)),
			if known?(tagName,n) princ("</" /+ n.tagName /+ ">"))
		else princ("/>"))]

[print(n:CharacterData) : void -> princ(n.data)]
[print(n:Comment) : void
-> princ(indent(n)), princ("<!--"), princ(n.data) ,princ("-->")]

// @chapter 4
// prints an XML document
[print(d:Document) : void
->	printf("<?xml~I~I?>",
			(when vers := get(xmlVersion,d) in printf(" version=~S",vers)),
			(when enc := get(xmlEncoding,d) in printf(" encoding=~S",enc))),
	print(d.documentElement)]

// @chapter 4
// save an xml doc in a file
[save(d:Document,filename:string) : void
-> let p:port := fopen(filename,"w")
   in (use_as_output(p), print(d), fclose(p))]

// @chapter 4
// pretty prints an XML tree in a string
[save(d:Document) : string
-> (print_in_string(), print(d), end_of_string())]


// @chapter 4
// escape a string confirming to XML spec
[strescape(src:string) : string -> 
let result:string  := "" in
(
externC("
		char *res = (char*)malloc(LENGTH_STRING(src)*6 + 1);
	if(res == 0) Cerror(61, _string_(\"escape @ string\"),0);
	char *travel = res;
	while(*src) {
		int c = integer_I_char(_char_(*src));
		if(c < 0) c = 256 + c;
		if(c > 256) c -= 256;
		
		if(c >= 32 && c <= 64) {
			switch(c) {
				case '\"': strcpy(travel,\"&quot;\"); travel += 6; break;
				case '\\'': strcpy(travel,\"&#39;\"); travel += 5; break;
				case '<': strcpy(travel,\"&lt;\"); travel += 4; break;
				case '>': strcpy(travel,\"&gt;\"); travel += 4; break;
				case '&': strcpy(travel,\"&amp;\"); travel += 5; break;
				default: *travel++ = c;
			}
		} else *travel++ = c;
		src++;
	}
	*travel = 0;
	travel = copy_string1(res, travel - res);
	free(res);
	
	result = travel;
	"),
	result)]

// @chapter 4
// unescape a string confirming to XML spec
[strunescape(src:string) : string -> 
let result:string  := "" in
	(externC("
	char *anch = src;
	int len = LENGTH_STRING(src);
	char *res = (char*)malloc(len+1);
	if(res == 0) Cerror(61, _string_(\"unescape @ string\"),0);
	char *travel = res;
	while(*src) {
		if(*src != '&') *travel++ = *src++;
		else {
			src++;
			if(*src == 0) {*travel++ = '&'; break;}
			else if(strncmp(src,\"lt;\",3) == 0) {*travel++ = '<'; src += 3;}
			else if(strncmp(src,\"gt;\",3) == 0) {*travel++ = '>'; src += 3;}
			else if(strncmp(src,\"#39;\",4) == 0) {*travel++ = '\\''; src += 4;}
			else if(strncmp(src,\"amp;\",4) == 0) {*travel++ = '&'; src += 4;}
			else if(strncmp(src,\"apos;\",5) == 0) {*travel++ = '\\''; src += 5;}
			else if(strncmp(src,\"quot;\",5) == 0) {*travel++ = '\"'; src += 5;}
			else {*travel++ = '&'; *travel++ = *src++; }
		}
	}
	*travel = 0;
	travel = copy_string1(res, travel-res);
	free(res);
	result = travel;"
	),
	result)]

