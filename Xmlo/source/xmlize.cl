
V_XMLOBJECTS:integer := 2
V_XMLOBJECTS_BUGS:integer := 3


// Old global model 
XML_PROPERTIES?[p:property] : (boolean U {unknown}) := unknown
XML_DESCENDENTS?[c:class] : boolean := false
		


// Special map tool

name_to_object_hash_table <: ephemeral_object(content:list[any])

map_node <: ephemeral_object
map_node <: ephemeral_object(nkey:string, nval:any, next:map_node)

XMLIZED :: name_to_object_hash_table(content = make_list(2047,any,0))


[nth=(self:name_to_object_hash_table, key:string, val:any) : void ->
	let h := 0, len := length(key), g := self.content
	in (#if compiler.loading?
			(for i in (0 .. len - 1)
				externC("h += key[i]; h += (h << 10); h ^= (h >> 6)"),
			externC("h += (h << 3); h ^= (h >> 11); h += (h << 15)"),
			externC("h &= 2047"),
			h :max 1,
			let x := g[h]
			in (if (x = 0)
					(if known?(val) g[h] := map_node(nkey = key, nval = val))
				else let ok? := false
					in (while known?(x)
							let n := x as map_node
							in (if (n.nkey = key)
									(n.nval := val,
									ok? := true,
									break()),
								x := get(next,n)),
						if not(ok?)
							g[h] := map_node(nkey = key, nval = val, next = g[h])))))]
							


[nth(self:name_to_object_hash_table, key:string) : any ->
	let h := 0, len := length(key), g := self.content
	in (#if compiler.loading?
			(for i in (0 .. len - 1)
				externC("h += key[i]; h += (h << 10); h ^= (h >> 6)"),
			externC("h += (h << 3); h ^= (h >> 11); h += (h << 15)"),
			externC("h &= 2047"),
			h :max 1,
			let x := g[h], res := unknown
			in (if (x != 0)
					while known?(x)
						let n := x as map_node
						in (if (n.nkey = key)
								(res := n.nval,
								break()),
							x := get(next,n)),
				res)))]



(#if compiler.loading?
	(XMLIZED["claire:boolean"] := boolean,
	XMLIZED["claire:float"] := float,
	XMLIZED["claire:integer"] := integer,
	XMLIZED["claire:char"] := char))

xmlPrint :: property(open = 3)

[xmlPrint(self:class) : void -> c_princ(string!(self.name))]
[xmlPrint(self:property) : void -> c_princ(string!(self.name))]


[xmlPrint(self:module) : void -> let x := string!(self.name) in (if (left(lower(x),3) = "xml") princ("ns"), c_princ(x))]


//<sb> xmlPrint should'nt use fast dispatch since one may for instance
// redefine xmlPrint @ {myClass} that would work...

//(interface(xmlPrint))

CLASS_U_PROPERTY_U_MODULE :: (class U property U module)

[xmlName(self:CLASS_U_PROPERTY_U_MODULE) : string -> 
	print_in_string(),
	xmlPrint(self),
	end_of_string()]

[printXmlName(self:CLASS_U_PROPERTY_U_MODULE) : void =>
	xmlPrint(self)]





[printIndent(self:integer) : void -> none]

//	while (self > 0)
//		(princ(" "), self :- 1)]




[xmlizeClass(c:class) : void ->
	if not(XML_DESCENDENTS?[c])
		XMLIZED[xmlName(c.name.module!) /+ ":" /+ xmlName(c)] := c,
	for i in (c.slots but (isa @ object) but (name @ thing))
		(if (i.domain[1] = c)
			(XMLIZED[xmlName(i.selector.name.module!) /+ ":" /+ xmlName(i.selector)] := i.selector,
			XML_PROPERTIES?[i.selector] := true))]

[xmlize(l:listargs) : void -> 
	for p in l
		(case p
			(class xmlizeClass(p),
			property (XMLIZED[xmlName(p.name.module!) /+ ":" /+ xmlName(p)] := p,
						XML_PROPERTIES?[p] := true),
			any error("wrong argument ~S for xmlize", p)))]

[xmlizeBut(c:class, l:listargs) : void -> 
	XMLIZED[xmlName(c.name.module!) /+ ":" /+ xmlName(c)] := c,
	for i in (c.slots but (isa @ object) but (name @ thing))
		(if (not(i.selector % l)) // & i.domain[1] = c)
			(XMLIZED[xmlName(i.selector.name.module!) /+ ":" /+ xmlName(i.selector)] := i.selector,
			XML_PROPERTIES?[i.selector] := true))]


[xmlizeDescendents(self:class) : void ->
	XML_DESCENDENTS?[self] := true]

[xmlizedTree?(self:class) : boolean ->
	if (self = object) false
	else if XML_DESCENDENTS?[self] true
	else if (known?(superclass, self) & xmlizedTree?(self.superclass))
		(XML_DESCENDENTS?[self] := true,
		xmlizeClass(self),
		true)
	else false]

//<sb> allow a custom convertion of a tag (e.g. Soap)

tagToClass :: property(open = 3)





[tagToClass(parser:Sax/sax_parser, nspc:string, tag:string) : class -> tagToClass(nspc,tag)]

[tagToClass(nspc:string, tag:string) : class ->
	error("tagToClass(~S,~S) undefined", nspc, tag),
	any]

[tagToClass(parser:Sax/sax_parser, tag:string) : class -> tagToClass(tag)]

[tagToClass(tag:string) : class ->
	error("tagToClass(~S) undefined", tag),
	any]
/*
[ns2module(self:string,nsmap:table) : (module U {unknown})
->	when x := get_value(self) in (x as module)
	else when x := nsmap[self] in
			(case x (
				module x,
				string (when z := get_value(last(explode("/",self))) in (if (z % module) (nsmap[self] := z, z) else unknown) else unknown),
				any unknown))
			else unknown]
*/


[conform_namespace(self:string, parser:Sax/sax_parser) : string
->	if (left(self,7) = "claire:") self
	else let offset := find(self,":")
		in (if (offset = 0) self
			else let ns := left(self,offset - 1),
					tag := right(self,length(self) - offset),
					c_ns := (
							if ((let x := get_value(ns) in (x % module))) ns
							else if ((let nns := right(ns,length(ns) - 2), x := get_value(nns) in (x % module))) right(ns,length(ns) - 2)
					 		else  
								(when _xmlns := parser.Sax/nsmap[ns]
								in (if (get_value(_xmlns) % module) _xmlns
									else if (left(_xmlns,7) = "http://" & get_value(right(_xmlns, length(_xmlns) -  rfind(_xmlns,"/"))) % module)
											(let nx := right(_xmlns, length(_xmlns) -  rfind(_xmlns,"/"))
											in (parser.Sax/nsmap[ns] := nx,
												nx))
									else ns) 
								else ns)) as string
				in (c_ns /+ ":" /+ tag))]

/*
[xmlNameToObject(self:string,parser:Sax/sax_parser) : (class U property) -> 
	let z := conform_namespace(self,parser),
		x := XMLIZED[z]
	in (if unknown?(x)
			let l := explode(self, ":")
			in (if (self = "claire:list") x := list
				else if (self = "claire:string") x := string
				else if (length(l) = 2) x := tagToClass(l[1], l[2])
				else if (length(l) = 1) x := tagToClass(self)
				else error("~S cannot be converted to (class U property)", self)),
		x as (class U property))]
*/
//<sb> allow a custom convertion of a value (e.g. Soap)

tagToValue :: property(open = 3)

UNKNOWN :: thing() //<sb> something unique!

[tagToValue(tag:string, cdata:string) : any -> UNKNOWN]







//***********************************************************************************
// New context model
//***********************************************************************************

node <: ephemeral_object

context <: ephemeral_object(
	inner_charset:string = "",
	src_charset:string = "",
	new_list_mode:boolean = true,
	ns2mod:table,
	mod2ns:table,
	stack:list[any] = list<any>(),
	xmlized?:name_to_object_hash_table,
	anonymous:list[node],
	properties?:table,
	descendants:table,
	xmlns?:table,
	xmlnso?:table
	)


[getmodule(self:ephemeral_object) : module -> module!(name(isa(self)))]
[getmodule(self:object) : module -> module!(name(isa(self)))]
[getmodule(self:thing) : module -> module!(name(self))]
[getmodule(self:any) : module -> claire]


[current_namespace(self:context) : module -> when x := last(self.stack) in getmodule(x) else claire]


	
[close(self:context) : context 
->	self.mod2ns := make_table(module,string,unknown),
	self.ns2mod := make_table(string,module,unknown),
	self.properties? := make_table(property,boolean,unknown),
	self.descendants := make_table(class,boolean,false),
	self.xmlns? := make_table(module,boolean,false),
	self.xmlnso? := make_table(any,boolean,false),
	self.xmlized? := name_to_object_hash_table(content = make_list(2047,any,0)),
	self]

[ns!(ctx:context,self:module) : string
->	when x := ctx.mod2ns[self] in x as string
	else let x := nsurl!(ctx,self)
		in (ctx.mod2ns[self] := x,
			ctx.ns2mod[x] := self,
			x as string)]

node <: ephemeral_object(
	parent:any,
	tagName:string,
	ns:string,
	attributes:table,
	childs:list[node])

// [nsurl!(ctx:context,self:module) : string -> nsurl!(ctx,self.part_of) / string!(self.name)]
[nsurl!(ctx:context,self:module) : string -> string!(self.name)]
// [nsurl!(ctx:context,self:{claire}) : string -> "http://www.claire-language.com"]
[nsurl2module(ctx:context,url:string) : module -> let aname := last(explode(url,"/")) in get_value(aname) as module]


[xmlizeClass(ctx:context,c:class) : void ->
	if not(XML_DESCENDENTS?[c])
		XMLIZED[xmlName(c.name.module!) /+ ":" /+ xmlName(c)] := c,
	for i in (c.slots but (isa @ object) but (name @ thing))
		(if (i.domain[1] = c)
			(XMLIZED[xmlName(i.selector.name.module!) /+ ":" /+ xmlName(i.selector)] := i.selector,
			XML_PROPERTIES?[i.selector] := true))]


/*
[xmlize(l:listargs) : void -> 
	for p in l
		(case p
			(class xmlizeClass(p),
			property (XMLIZED[xmlName(p.name.module!) /+ ":" /+ xmlName(p)] := p,
						XML_PROPERTIES?[p] := true),
			any error("wrong argument ~S for xmlize", p)))]

[xmlizeBut(c:class, l:listargs) : void -> 
	XMLIZED[xmlName(c.name.module!) /+ ":" /+ xmlName(c)] := c,
	for i in (c.slots but (isa @ object) but (name @ thing))
		(if (not(i.selector % l)) // & i.domain[1] = c)
			(XMLIZED[xmlName(i.selector.name.module!) /+ ":" /+ xmlName(i.selector)] := i.selector,
			XML_PROPERTIES?[i.selector] := true))]


[xmlizeDescendents(self:class) : void ->
	XML_DESCENDENTS?[self] := true]
*/

[xmlized?(ctx:context,p:property,c:class) : boolean
-> when x := XML_PROPERTIES?[p] in x else false]

[xmlized?(p:property,c:class) : boolean -> when x := XML_PROPERTIES?[p] in x else false]

[xmlizedTree?(ctx:context,self:class) : boolean ->
	if (self = object) false
	else if XML_DESCENDENTS?[self] true
	else if (known?(superclass, self) & xmlizedTree?(ctx,self.superclass))
		(XML_DESCENDENTS?[self] := true,
		xmlizeClass(ctx,self),
		true)
	else false]


[ns2module!(self:string) : (module U {unknown}) -> when x := get_value(self) in (if (x % module) x as module else unknown) else unknown]


BUFFER_xmlNameToObject[strkey:string] : (class U property U {unknown}) := unknown


[xmlNameToObject(ctx:context,tag:string,sax:Sax/sax_parser) : (class U property) -> 
let key := tag // Core/Oid(ctx) /+ tag /+ Core/Oid(sax)
in (when buf := BUFFER_xmlNameToObject[key]
	in buf
	else let buf := xmlNameToObject_unbuffered(ctx,tag,sax)
		in (BUFFER_xmlNameToObject[key] := buf,buf))]



[xmlNameToObject_unbuffered(ctx:context,tag:string,sax:Sax/sax_parser) : (class U property) -> 
	if (find(tag,":") = 0) tag := string!(name(current_namespace(ctx))) /+ ":" /+ tag,
	let self := conform_namespace(tag,sax),
		x := XMLIZED[self] // (when y := ctx.xmlized?[self] in y else XML_DESCENDENTSIZED[self])
	in (if unknown?(x)
			let l := explode(self, ":")
			in (if (self = "claire:list") x := list
				else if (self = "claire:string") x := string
				else if (length(l) = 2) 
					(when m := ns2module!(l[1])
					in (when vv := get_value(m,l[2]) in (if (vv % (class U property)) x := vv
					 									else x := tagToClass(sax,l[1], l[2]))
						else x := tagToClass(sax,l[1], l[2]))
					else x := tagToClass(sax,l[1], l[2]))
				else if (length(l) = 1) x := tagToClass(sax,self)
				else error("~S cannot be converted to (class U property)", self)),
		x as (class U property))]


