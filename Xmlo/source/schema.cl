

schema <: ephemeral_object(
	current:module,
	tostore:set[class],
	stored:set[class],
	map:table,
	out:port)


[schema!(self:class) : void
-> let x := schema()
	in (x.tostore :add self,
		schema!(x))]

[xmlized?(self:class) : boolean ->
	when x := Xmlo/XMLIZED[Xmlo/xmlName(self.name.module!) /+ ":" /+ Xmlo/xmlName(self)] in true else false]



[schema!(self:schema) : void -> schema!(self,true)]

[schema!(self:schema,xml_manifest:boolean) : void
->	if (xml_manifest) printf("<?xml version=~S encoding=~S?>\n","1.0","UTF-8"),
	printf("<xs:schema xmlns:xs=\"http://www.w3.org/2001/XMLSchema\">"),
	while (length(self.tostore) > 0) schema!(self,some( z in self.tostore | true)),
	printf("</xs:schema>")]

[inherit(self:schema,c:class) : class
->	if (c = any) c
	else let x := c.superclass in (
		if (x % self.stored) x
		else if (xmlized?(x)) x 
		else inherit(self,x))]

DEEP:integer := 0

[schema!(self:schema,x:class) : void
->	DEEP :+ 1,
	//[5] ~A schema!(~S,~S) // DEEP, self,x,
	if (xmlized?(x)) (
		if (not(x % self.stored)) 
		let sp := inherit(self,x) in (
		printf("\n<xs:element name=\"~I:~I\">",printXmlName(x.name.module!),printXmlName(x)),
		if (sp != any) printf("<xs:complexContent><xs:extension base=\"~I\">",type!(self,sp))
		else printf("<xs:complexType><xs:sequence>"),
		let allProps := false // (x = any) // xmlizedTree?(x)
		in (//[5] ==> ~S //  x,
			for s in {sl in (x.slots but (isa @ object)) | (XML_PROPERTIES?[sl.selector] = true & sl.domain[1] < sp)}
				(//[5] ~S // s,
				schema!(self,x,s))),
		if (sp != any) printf("</xs:extension></xs:complexContent>")
		else printf("</xs:sequence></xs:complexType>"),
		printf("</xs:element>"),
		self.tostore :delete x),
		//[5] == subclasses of (.., ~S) // x,
		self.stored :add x),
	for i in x.subclass schema!(self,i),
	//[3] ~A ==> schema(.., ~S) // DEEP, x,
	DEEP :- 1,
	none]

[private/type!(self:schema,c:class) 
->	if (xmlized?(c)) (
		printf("~I:~I",printXmlName(c.name.module!), printXmlName(c)),
		if not(c % self.stored) (
			//[5] add ~S to store // c,
			self.tostore :add c))
	else let x := inherit(self,c) in (if (x != any) private/type!(self,x) else printf("~I:~I",printXmlName(c.name.module!), printXmlName(c)))]

[private/type!(self:schema,c:{port}) -> printf("claire:string")]
[private/type!(self:schema,c:{boolean}) -> printf("claire:boolean")]
[private/type!(self:schema,c:{integer}) -> printf("claire:integer")]
[private/type!(self:schema,c:{float}) -> printf("claire:decimal")]
[private/type!(self:schema,c:{string}) -> printf("claire:string")]
[private/type!(self:schema,c:Union) -> 
	//[5] type!(...,Union),
	printf("~I ~I",private/type!(self,c.mClaire/t1),private/type!(self,c.mClaire/t2))]
[private/type!(self:schema,c:table) -> printf("claire:table")]

[private/type!(self:schema,c:any) -> printf("claire:any")]

[schema!(self:class,file:string) : void
->	let f := fopen(file,"w"),
		old := use_as_output(f)
	in (schema!(self),
		use_as_output(old),
		fclose(f))]

[private/schema!(self:schema,c:class,s:slot) : void
->	//[2] schema!(self:~S,c:~S,s:~S) tuple?:~S // self,c,s,(s.range % tuple),
	if (s.range <= tuple)
		(printf("\n<xs:element name=\"~A:~A\">",string!(s.selector.name.module!.name),string!(s.selector.name)),
	printf("<xs:complexType>"),
	printf("<xs:sequence>"),
	for i in s.range printf("<xs:element name=\"~A:~A\" type=\"~I\"/>",
					string!(s.selector.name.module!.name),string!(s.selector.name),
					private/type!(self,i)),
	printf("</xs:sequence>"),
	printf("</xs:complexType>"),
	printf("</xs:element>"))
	else printf("\n<xs:element name=\"~I:~I\" type=\"~I\" ~I />",
						printXmlName(s.selector.name.module!),
						printXmlName(s.selector),
						(//[3] ~S // s.range,
						if (s.range % Union) private/type!(self,s.range)
						else if (s.range % subtype[bag])
							type!(self,s.range.mClaire/t1)
						else type!(self,s.range)),
						(if (s.range % subtype[bag]) printf("maxOccurs=\"unbounded\"")))]

