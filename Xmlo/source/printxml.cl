
//************************************************************************************************
// API contextualisées
//************************************************************************************************


[printSimple(ctx:context,self:(string U char U boolean U integer U float U port)) : void ->
	case self
		(string princ(url_encode(self)),
		char princ(url_encode(make_string(1, self))),
		blob (encode64(self,cout(),64),
			//[-100] printing blob,
			set_index(self,0)),
		port (//[-100] Warning : printing a port cannot be node many times, 
			encode64(self,cout(),64)),
		(integer U boolean U float) print(self))]


[printXmlOneKey(ctx:context, p:property, self:(string U char U boolean U integer U float), indent:integer, key:any) : void ->
	//[V_XMLOBJECTS] ~AprintXmlOneKey(property = ~S, simple = ~S, key = ~S) // make_string(2 * indent, ' '), p, self,key,
	let pnm! := p.name.module!, addns? := not(ctx.xmlns?[pnm!]) in
		(printf("~I<~I:~IEntry ~Ikey=\"~I\">~I</~I:~IEntry>", 
				printIndent(indent),
				printXmlName(pnm!),
				printXmlName(p),
				printNamespaces(ctx), // (if addns? (ctx.xmlns?[pnm!] := true, printf("xmlns:~I=~S ",printXmlName(pnm!),nsurl!(ctx,pnm!)))),
				printSimple(ctx,key),
				printSimple(ctx,self),
				printXmlName(pnm!),
				printXmlName(p)),
		if addns? ctx.xmlns?[pnm!] := false)]

[printXmlTwoKey(ctx:context, p:property, self:(string U char U boolean U integer U float), indent:integer, key1:any, key2:any) : void ->
	//[V_XMLOBJECTS] ~AprintXmlTwoKey(property = ~S, simple = ~S, key1 = ~S, key2 = ~S) // make_string(2 * indent, ' '), p, self,key1,key2,
	let pnm! := p.name.module!, addns? := not(ctx.xmlns?[pnm!]) in
		(printf("~I<~I:~IEntry ~Ikeys=\"~I,~I\">~I</~I:~IEntry>",
				printIndent(indent), 
				printXmlName(pnm!),
				printXmlName(p),
				printNamespaces(ctx), // (if addns? (ctx.xmlns?[pnm!] := true, printf("xmlns:~I=~S ",printXmlName(pnm!),nsurl!(ctx,pnm!)))),
				printSimple(ctx,key1),
				printSimple(ctx,key2),
				printSimple(ctx,self),
				printXmlName(pnm!),
				printXmlName(p)),
		if addns? ctx.xmlns?[pnm!] := false)]

[printXmlOneKey(ctx:context, p:property, self:bag, indent:integer, key:any) : void ->
	//[V_XMLOBJECTS] ~AprintXmlOneKey(property = ~S, bag = ~S, key = ~S) // make_string(2 * indent, ' '), p, self,key,
	let pnm! := p.name.module!, addns? := not(ctx.xmlns?[pnm!]) in
		(printf("~I<~I:~IEntry ~Ikey=\"~I\">~I~I</~I:~IEntry>", 
			printIndent(indent),
			printXmlName(pnm!),
			printXmlName(p),
			printNamespaces(ctx), // (if addns? (ctx.xmlns?[pnm!] := true, printf("xmlns:~I=~S ",printXmlName(pnm!),nsurl!(ctx,pnm!)))),
			printSimple(ctx,key),
			(for i in self printXml(ctx, i, indent + 1)),
			printIndent(indent),
			printXmlName(pnm!),
			printXmlName(p)),
		if addns? ctx.xmlns?[pnm!] := false)]

[printXmlTwoKey(ctx:context, p:property, self:bag, indent:integer, key1:any, key2:any) : void ->
	//[V_XMLOBJECTS] ~AprintXmlTwoKey(property = ~S, bag = ~S, key1 = ~S, key2 = ~S) // make_string(2 * indent, ' '), p, self,key1,key2,
	let pnm! := p.name.module!, addns? := not(ctx.xmlns?[pnm!]) in
		(printf("~I<~I:~IEntry ~Ikeys=\"~I,~I\">~I~I</~I:~IEntry>", 
			printIndent(indent),
			printXmlName(pnm!),
			printXmlName(p),
			printNamespaces(ctx), // (if addns? (ctx.xmlns?[pnm!] := true, printf("xmlns:~I=~S ",printXmlName(pnm!),nsurl!(ctx,pnm!)))),
			printSimple(ctx,key1),
			printSimple(ctx,key2),
			(for i in self printXml(ctx, i, indent + 1)),
			printIndent(indent),
			printXmlName(pnm!),
			printXmlName(p)),
		if addns? ctx.xmlns?[pnm!] := false)]




[printXml(ctx:context, self:property, val:(integer U float U boolean), indent:integer) : void ->	
	//[V_XMLOBJECTS] ~AprintXml(property = ~S, intUfloatUbool = ~S) // make_string(2 * indent, ' '), self, val,
	let pnm! := self.name.module!, addns? := not(ctx.xmlns?[pnm!]) in
		(printf("~I<~I:~I~I>~S</~I:~I>",
				printIndent(indent), 
				printXmlName(pnm!),
				printXmlName(self),
				printNamespaces(ctx), // (if addns? (ctx.xmlns?[pnm!] := true, printf(" xmlns:~I=~S",printXmlName(pnm!),nsurl!(ctx,pnm!)))),
				val,
				printXmlName(pnm!),
				printXmlName(self)),
		if addns? ctx.xmlns?[pnm!] := false)]

[printXml(ctx:context, self:property, val:(string U char), indent:integer) : void ->	
	//[V_XMLOBJECTS] ~AprintXml(property = ~S, stringUchar = ~S) // make_string(2 * indent, ' '), self, val,
	let pnm! := self.name.module!, addns? := not(ctx.xmlns?[pnm!]) in
		(printf("~I<~I:~I~I>~A</~I:~I>",
				printIndent(indent),
				printXmlName(pnm!),
				printXmlName(self),
				printNamespaces(ctx), // (if addns? (ctx.xmlns?[pnm!] := true, printf(" xmlns:~I=~S",printXmlName(pnm!),nsurl!(ctx,pnm!)))),
				(case val (char url_encode(string!(val)),
							any url_encode(val))),
				printXmlName(pnm!),
				printXmlName(self)),
		if addns? ctx.xmlns?[pnm!] := false)]

[printXml(ctx:context, self:property, val:port, indent:integer) : void ->	
	//[V_XMLOBJECTS] ~AprintXml(property = ~S, port = ~S) // make_string(2 * indent, ' '), self, val,
	let pnm! := self.name.module!, addns? := not(ctx.xmlns?[pnm!]) in
		(printf("~I<~I:~I~I>~I</~I:~I>",
				printIndent(indent),
				printXmlName(pnm!),
				printXmlName(self),
				printNamespaces(ctx), // (if addns? (ctx.xmlns?[pnm!] := true, printf(" xmlns:~I=~S",printXmlName(pnm!),nsurl!(ctx,pnm!)))),
				(encode64(val,cout(),76), if (val % blob) set_index(val,0) else //[0] Warning : printing a port will work one time
				),
				printXmlName(pnm!),
				printXmlName(self)),
		if addns? ctx.xmlns?[pnm!] := false)]



[printXml(ctx:context, self:(string U char U boolean U integer U float U port), indent:integer) : void ->
	//[V_XMLOBJECTS] ~AprintXml(simple = ~S) // make_string(2 * indent, ' '), self,
	let own := owner(self), pnm! := own.name.module!, addns? := not(ctx.xmlns?[pnm!]) in
		(printf("~I<~I:~I~I>~I</~I:~I>", 
				printIndent(indent),
				printXmlName(pnm!),
				printXmlName(own),
				printNamespaces(ctx), //  (if addns? (ctx.xmlns?[pnm!] := true, printf(" xmlns:~I=~S ",printXmlName(pnm!),nsurl!(ctx,pnm!)))),
				printSimple(ctx,self),
				printXmlName(pnm!),
				printXmlName(own)),
		if addns? ctx.xmlns?[pnm!] := false)]

//<sb> allow a custom convertion of a object to tag (e.g. Soap)
objectToEnterTag :: property(open = 3)
objectToLeaveTag :: property(open = 3)

[objectToEnterTag(ctx:context,self:object) : boolean ->
	let own := owner(self), pnm! := own.name.module!, addns? := not(ctx.xmlns?[pnm!])
	in (printf("~I:~I~I",
				printXmlName(pnm!),
				printXmlName(own),
				printNamespaces(ctx)),
		true)]
				
[objectToLeaveTag(ctx:context, self:object) : void ->
	let own := owner(self), pnm! := own.name.module!
	in (printf("~I:~I",
				printXmlName(pnm!),
				printXmlName(own)),
		if (ctx.xmlnso?[self]) ctx.xmlns?[pnm!] := false,
		true)]


[printXml(ctx:context, self:any, indent:integer) : void ->
	//[V_XMLOBJECTS] ~AprintXml(ctx=~S, any = ~S) // make_string(2 * indent, ' '), ctx, self,
	let own := owner(self),
		allProps := xmlizedTree?(ctx,own)
	in printf("~I<~I>~I~I</~I>", 
				printIndent(indent),
				(objectToEnterTag(ctx,self) as boolean),
				(for i in {s in (own.slots but (isa @ object)) |
							(allProps & not(xmlized?(ctx,i.selector,own))) |
							xmlized?(ctx,i.selector,own)}
					printXml(ctx, i.selector, get(i.selector, self), indent + 1)),
				printIndent(indent),
				objectToLeaveTag(ctx,self))]


[printXml(ctx:context,self:list, indent:integer) : void ->
	//[V_XMLOBJECTS] ~AprintXml(tuple = ~S) // make_string(2 * indent, ' '), self,
	printf("~I<claire:list~I~I>~I</claire:list>", 
			printIndent(indent),
			(if of(self) printf(" of=\"~I/~I\"",printXmlName(of(self).name.module!),printXmlName(of(self)))),
			printNamespaces(ctx), // (if addns? (ctx.xmlns?[pnm!] := false, printf(" xmlns:~I=~S",printXmlName(pnm!),nsurl!(ctx,pnm!)))),
			(let subindent := indent + 1 in for i in self printXml(ctx,i, subindent)))]
	
[printXml(ctx:context,self:tuple, indent:integer) : void ->
	//[V_XMLOBJECTS] ~AprintXml(tuple = ~S) // make_string(2 * indent, ' '), self,
	for i in self printXml(ctx,i, indent)]

[printXml(ctx:context,self:property, val:table, indent:integer) : void ->	
	//[V_XMLOBJECTS] ~AprintXml(property = ~S,table = ~S) // make_string(2 * indent, ' '),self, val,
	let pnm! := self.name.module!,
		addns?:boolean := not(ctx.xmlns?[pnm!])
	in
		(printf("~I<~I:~I~I>~I~I</~I:~I>",
				printIndent(indent),
				printXmlName(pnm!),
				printXmlName(self),
				printNamespaces(ctx), // (if addns? (ctx.xmlns?[pnm!] := false, printf(" xmlns:~I=~S",printXmlName(pnm!),nsurl!(ctx,pnm!)))),
				(for i in (1 .. length(val.mClaire/graph))
					(if (((i + 2) mod 2) = 1 & known?(val.mClaire/graph[i]))
						(if (domain(val) % tuple)
							printXmlTwoKey(ctx,self,val.mClaire/graph[i + 1],
											indent + 1,
											val.mClaire/graph[i][1],
											val.mClaire/graph[i][2])
						else printXmlOneKey(ctx,self,val.mClaire/graph[i + 1],
											indent + 1,
											val.mClaire/graph[i])))),
				printIndent(indent),
				printXmlName(pnm!),
				printXmlName(self)),
		if addns? ctx.xmlns?[pnm!] := false)]		

[printXml(ctx:context,self:property, val:bag, indent:integer) : void ->	
	//[V_XMLOBJECTS] ~AprintXml(property = ~S,bag = ~S) // make_string(2 * indent, ' '),self, val,
	let pnm! := self.name.module!,
		addns?:boolean := not(ctx.xmlns?[pnm!])
	in (printf("~I<~I:~I~I>~I~I</~I:~I>",
			printIndent(indent),
			printXmlName(pnm!),
			printXmlName(self),
			printNamespaces(ctx), // (if addns? (ctx.xmlns?[pnm!] := true, printf(" xmlns:~I=~S",printXmlName(pnm!),nsurl!(ctx,pnm!)))),
			(for i in val printXml(ctx,i, indent + 1)),
			printIndent(indent),
			printXmlName(pnm!),
			printXmlName(self)),
		if addns? ctx.xmlns?[pnm!] := false)]

[sortbyclass(a:any,b:any) : boolean -> Core/Oid(a.isa) < Core/Oid(b.isa)]
// [sortbyclass(a:any,b:any) : boolean -> a.isa.name.name < b.isa.name.name]


[implode(s:set[string],sep:string) : string
-> let f? := true,
		str := ""
	in (for x in s 
			(if f? f? := false else str :/+ sep, 
			str :/+ x),
		str)]

[implode(s:list[string],sep:string) : string
-> let f? := true,
		str := ""
	in (for x in s 
			(if f? f? := false else str :/+ sep, 
			str :/+ x),
		str)]



[printXmlCsv(ctx:context,self:property, val:bag, indent:integer) : void ->	
	//[V_XMLOBJECTS] ~AprintXml(property = ~S,bag = ~S) // make_string(2 * indent, ' '),self, val,
	if (length(val) > 0)
		let pnm! := self.name.module!,
			addns?:boolean := not(ctx.xmlns?[pnm!])
		in (printf("~I<~I:~I~I>~I==\n</Xmlo:CsvList></~I:~I>",
				printIndent(indent),
				printXmlName(pnm!),
				printXmlName(self),
				printNamespaces(ctx), // (if addns? (ctx.xmlns?[pnm!] := true, printf(" xmlns:~I=~S",printXmlName(pnm!),nsurl!(ctx,pnm!)))),
				(let c_class := any,
					properties:list[slot] := nil
				in (for o in sort(sortbyclass @ any,val)
						(if (o.isa != c_class) (
							if (c_class != any) printf("==\n</Xmlo:CsvList>"),
							c_class := o.isa,
							properties := list{x in c_class.slots | Xmlo/xmlized?( ctx, selector(x), c_class)},
							printf("<Xmlo:CsvList of=\"~I:~I\" properties=\"~I\">",
									printXmlName(c_class.name.module!),
									printXmlName(c_class),
									(let sep := "" in (
										for x in properties (printf("~A~I:~I",sep,printXmlName(x.selector.name.module!),printXmlName(selector(x))), sep := ";"))))),
						let first? := true 
						in for p in properties
							let val := get(selector(p),o)
							in (if first? (first? := false) else princ(";"),
								case val (string princ(url_encode(val)),
											boolean princ((if val "true" else "false")),
											(integer U float) princ(val),
											bag princ(url_encode(implode(val,";"))))),
						princ("\n"),
						none))),
				printXmlName(pnm!),
				printXmlName(self)),
			if addns? ctx.xmlns?[pnm!] := false)]



[printXml(ctx:context,self:property, val:list[(integer U string U integer U float U port U boolean U char)], indent:integer) : void ->	
	//[V_XMLOBJECTS] ~AprintXml(property = ~S, set[simple] = ~S) // make_string(2 * indent, ' '),self, val,
	let pnm! := self.name.module!,
		addns?:boolean := not(ctx.xmlns?[pnm!])
	in (printf("~I<~I:~I~I>~I~I</~I:~I>",
				printIndent(indent),
				printXmlName(pnm!),
				printXmlName(self),
				printNamespaces(ctx), // (if addns? (ctx.xmlns?[pnm!] := true, printf(" xmlns:~I=~S",printXmlName(pnm!),nsurl!(ctx,pnm!)))),
				(for i in val (
					if known?(i)
					printf("~I<~I>~I</~I>",
						printIndent(indent + 1),
						printBaseType(ctx,i),
						printSimple(ctx,i),
						printBaseType(ctx,i)))),
				printIndent(indent),
				printXmlName(pnm!),
				printXmlName(self)),
		if (addns?) ctx.xmlns?[pnm!] := false)]


[attribute!(ctx:context,self:property, val:any, indent:integer) : void ->	
	//[V_XMLOBJECTS] ~AprintXml(property = ~S,any = ~S) // make_string(2 * indent, ' '),self, val,
	let pnm! := self.name.module! in
		(if known?(val)
			printf(" ~I:~I=~I ",
					 printXmlName(pnm!),
						printXmlName(self),
							printXml(ctx,val,0)
				))]


[printBaseType(ctx:context,x:integer) : void -> printf("claire:integer")]
[printBaseType(ctx:context,x:string) : void -> printf("claire:string")]
[printBaseType(ctx:context,x:float) : void -> printf("claire:float")]
[printBaseType(ctx:context,x:port) : void -> printf("claire:binary")]
[printBaseType(ctx:context,x:boolean) : void -> printf("claire:boolean")]
[printBaseType(ctx:context,x:char) : void -> printf("claire:integer")]

[printXml(ctx:context,self:property, val:set[(integer U string U float U port U boolean U char)], indent:integer) : void ->	
	//[V_XMLOBJECTS] ~AprintXml(property = ~S, set[simple] = ~S) // make_string(2 * indent, ' '),self, val,
	let pnm! := self.name.module!,
		addns?:boolean := not(ctx.xmlns?[pnm!])
	in (printf("~I<~I:~I~I>~I~I</~I:~I>",
				printIndent(indent),
				printXmlName(pnm!),
				printXmlName(self),
				printNamespaces(ctx), // (if addns? (ctx.xmlns?[pnm!] := true, printf(" xmlns:~I=~S",printXmlName(pnm!),nsurl!(ctx,pnm!)))),
				(for i in val (
					if known?(i)
					printf("~I<~I>~I</~I>",
						printIndent(indent + 1),
						printBaseType(ctx,i),
						printSimple(ctx,i),
						printBaseType(ctx,i)))),
				printIndent(indent),
				printXmlName(pnm!),
				printXmlName(self)),
			
		if (addns?) ctx.xmlns?[pnm!] := false)]


[printNamespaces(ctx:context) : void
-> (if not(ctx.xmlns?[claire]) (
					for m in {module!(name(x)) | x in { x in Xmlo/XML_PROPERTIES?.mClaire/graph | x % property }}
						(if not(ctx.xmlns?[m]) (
							ctx.xmlns?[m] := true,
							printf(" xmlns:~I=~S",printXmlName(m),nsurl!(ctx,m))))))]



[printXml(ctx:context,self:property, val:any, indent:integer) : void ->	
	//[V_XMLOBJECTS] ~AprintXml(ctx:~S, property = ~S,any = ~S) // make_string(2 * indent, ' '),ctx, self, val,
	let pnm! := self.name.module!
	 in (if known?(val)
			let addns?:boolean := not(ctx.xmlns?[pnm!]) in (
			printf("~I<~I:~I~I>~I~I</~I:~I>",
				printIndent(indent),
				printXmlName(pnm!),
				printXmlName(self),
				printNamespaces(ctx),
				printXml(ctx,val, indent + 1),
				printIndent(indent),
				printXmlName(pnm!),
				printXmlName(self)),
				if addns? ctx.xmlns?[pnm!] := false))]

[xml!(self:object, p:port) : void -> 
	let ctx := context(),
		old := use_as_output(p)
	in (printXml(ctx,self, 0),
		use_as_output(old))]

[xmlInFile!(path:string, self:any) : void ->
	let f:port := fopen(path, "w")
	in (xml!(self,f), fclose(f))]

[xml!(self:any) : string ->
	let p:port := port!(),
		op:port := use_as_output(p),
		res := (xml!(self,p),string!(p))
	in (use_as_output(op),fclose(p), res)]

