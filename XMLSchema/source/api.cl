//*********************************************************************
//* XMLSchema                                       Xavier Pechoultres*
//* api.cl                                                            *
//* Copyright (C) 2005 - 2006 xl. All Rights Reserved                 *
//*********************************************************************

TRACE_READ_1 :: 1
TRACE_READ_2 :: 2
TRACE_WRITE_1 :: 1
TRACE_WRITE_2 :: 2


// get namespace (claire module) from URL namespace
[get_schema(self:string) : (schema U {unknown}) -> unknown]

(abstract(get_schema))

// default namespace for shema
[get_schema(self:{"http://www.w3.org/2001/XMLSchema"}) : (schema U {unknown}) ->	schema(url = "http://www.w3.org/2001/XMLSchema",
																			base_namespace = XMLSchema)]

[get_schema(self:{"http://www.w3.org/2001/XMLSchema-instance"}) : (schema U {unknown}) ->	schema(url = "http://www.w3.org/2001/XMLSchema-instance",
																			base_namespace = XMLSchema)]

// get url based namespace
[get_schema(self:module) : (schema U {unknown})  -> unknown]

[get_schema(self:{XMLSchema}) : schema -> schema(url = "http://www.w3.org/2001/XMLSchema",
												base_namespace = XMLSchema)]

[get_targetNamespace(self:{XMLSchema}) : string -> "http://www.w3.org/2001/XMLSchema"]


//--------------------------------------------------------------
//	part 2: SAX
//--------------------------------------------------------------

xmlschema_context <: ephemeral_object(
		ctx_schema:schema,
		initialized:boolean = false,
		defaultNamespace:module,
		used_namespaces:table,
		used_namespaces_reverse:table,
		objectstack:list[any])

[parse_attributes(ctx:xmlschema_context,self:schema_object,attrs:table) : void
-> (for sl in slots(owner(self)) (
		if attribute?(self,selector(sl)) (
			let prop := selector(sl),
				att_name := string!(name(prop)),
				att_mod := module!(name(prop))
			in (when schem := get_schema(att_mod)
				in (if not(schem.attributeFormDefaultQualified?) (
						if (attrs[att_name] != "") set_attribute(ctx,self,sl,attrs[att_name]))
					else (when ns_alias := ctx.used_namespaces_reverse[schem.base_namespace]
						in (let qualified_name := ns_alias /+ ":" /+ att_name
							in (if (attrs[qualified_name] != "") set_attribute(ctx,self,sl,attrs[qualified_name])))
							else error("XMLSchema: error : unknown alias for ~S",  schem.base_namespace )))
				else error("XMLSchema: error : unknown schema for ~S attribute: ~S", att_mod, sl)))))]

[set_attribute(ctx:xmlschema_context,self:schema_object,s:slot,val:string) : void
->	if (range(s) <= simpleType) (
		let o := new(range(s))
		in (cdata!(o,val),
			write(selector(s),self,o)))
	else if (range(s) <= string) write(selector(s),self,val)
	else if (range(s) <= integer) write(selector(s),self,integer!(val))
	else if (range(s) <= float) write(selector(s),self,float!(val))
	else error("XMLSchema: attribute range error : ~S on ~S for val : ~S",  range(s), self, val)]
	

[init_context(self:xmlschema_context,tag:string,attrs:table) : xmlschema_context
->	//[TRACE_READ_1] init_context(~S, ~S) // self,attrs,
	self.used_namespaces := make_table(string,module,unknown),
	self.used_namespaces_reverse := make_table(module,string,unknown),
	let l := attrs.mClaire/graph,
		c := length(l),
		i := 1
	in (while (i < c) (
			when val := l[i + 1]
			in let attr := l[i]
			in (if (attr = "xmlns") (
					//[TRACE_READ_2] getting get_schema(~S) -> ~S // l[i + 1], get_schema(l[i + 1]),
					when s := get_schema(val) 
					in (self.ctx_schema := s,
						self.defaultNamespace := self.ctx_schema.base_namespace)
					else error("error (XMLSchema) ~A:~A schema not found",attr,val))
				else if (left(attr,6) = "xmlns:")
					let exattr := explode(attr,":")
					in (when s := get_schema(val)
						in (//[TRACE_READ_2] attach namespace ~S : ~S // exattr[2], s.base_namespace,
							self.used_namespaces[exattr[2]] := s.base_namespace,
							self.used_namespaces_reverse[s.base_namespace] := exattr[2])
						else error("error (XMLSchema) xlmns:~A=~A schema not found",exattr[2],val))),
			i :+ 2),
		self.objectstack := list<any>(self.ctx_schema),
		self.initialized := true,
		//[TRACE_READ_2] init_context -> self.objectstack = ~S // self.objectstack,
		//[TRACE_READ_2] init_context -> self.ctx_schema = ~S // self.ctx_schema,
		self)]
		
// [init_object(parent:module, self:string) : any -> get_root_element(parent,self)]

[process_val(ctx:xmlschema_context,parent:complexType,tag:string) : any
->	//[TRACE_READ_2] process_val(~S,~S) // parent,tag,
	let extag := explode(tag,":"),
		t := (if (length(extag) = 2) extag[2] else tag),
		ns := (if (length(extag) = 2) ctx.used_namespaces[extag[1]] else ctx.defaultNamespace)
	in (when p := some(i in slots(owner(parent)) | string!(name(selector(i))) = t & module!(name(selector(i))) = ns)
		in (if (range(p) < bag) (
				if unknown?(selector(p),parent) write(selector(p),parent,make_list(mClaire/t1(range(p)),1)),
				let o := new(mClaire/t1(range(p)))
				in (add(get(selector(p),parent),o), 
					o))
			else let o := new(range(p)) in (
//					if unknown?(root,ctx.ctx_schema) ctx.ctx_schema.root := o,
					write(selector(p),parent,o), o))
		else error("unknown slot"))]

[process_val(ctx:xmlschema_context,parent:simpleType,tag:string) : any -> error("sub-elements not authorized in simpleType")]


[sax_begin_element(ctx:xmlschema_context,tag:string,attrs:table) : xmlschema_context
->	//[TRACE_READ_2] sax_begin_element(~S, ~S, ~S) // ctx,tag,attrs,
	if not(ctx.initialized) init_context(ctx,tag,attrs),
	when obj := process_val(ctx,last(ctx.objectstack),tag)
	in (parse_attributes(ctx,obj,attrs),
		ctx.objectstack :add obj,
		ctx)
	else (error("Erreur process_val return unknwon"), ctx)]

/*		
	let l := explode(tag,":"),
		t := last(l),
		_module := (if (length(l) = 2) ctx.used_namespaces[l[1]] else ctx.defaultNamespace)
	in (when obj := get_value(_module,t) in (
			parse_attributes(obj,attrs),
			if (length(ctx.objectstack) = 0) ctx.objectstack :add l
			else (let parent := last(ctx.objectstack)
				in ( 
	]
*/

[cdata!(self:complexType, cdata:string) : void
->	//[TRACE_READ_2] Warning: cdata on complexType unsupported,
	none]

[cdata!(self:simpleType, cdata:string) : void
->	//[TRACE_READ_1] Warning: cdata on simpleType ~S:~S unsupported // owner(self),self,
	none]

[sax_end_element(ctx:xmlschema_context,tag:string,cdata:string) : any
->	cdata!(last(ctx.objectstack),cdata),
	shrink(ctx.objectstack,length(ctx.objectstack) - 1)]


[unxml!(self:port,ctx:xmlschema_context) : xmlschema_context
->	Expat/sax(self,sax_begin_element, sax_end_element, ctx),
	ctx]

[unxml!(self:port) : schema
->	let ctx := xmlschema_context()
	in (unxml!(self,ctx),
		ctx.ctx_schema)]


//----------

[self_xml(self:schema_object) : void
->	//[TRACE_WRITE_1] unsuported !!!!
	]

[self_xml(self:schema,sl:slot) : void
->	printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"),
	self_xml(self,self,sl)]

[self_xml(self:schema) : void
->	//[TRACE_WRITE_1] self_xml(~S) // self,
//	if unknown?(root,self) error("error in self_xml(~S) : root element is unknwon !",self),
	printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"),
	for sl in  slots(owner(self)) (
		if (range(sl) < XMLSchema/schema_object) self_xml(self,self,sl))]

//	when prop := some(i in slots(owner(self)) | selector(i) != root & get(selector(i),self) = self.root)
//	in self_xml(self,self,prop)
//	else error("error in self_xml(~S) : unknwon root property is unknwon !",self)]

[alias(self:module) : string -> string!(name(self))]
(abstract(alias))

[alias(self:{XMLSchema}) : string -> "xsd"]

[print_dependences(self:module,mod_done:list[module]) : void
->	if not(self % mod_done) (
		when s := get_schema(self) in
			printf(" xmlns:~A=~S", alias(s.base_namespace), s.url),
		mod_done :add self,
		for m in uses(self)
			print_dependences(m,mod_done))]

[print_dependences(self:schema) : void
->	printf(" xmlns=~S", self.url),
	let mod_done := list<module>()
	in (mod_done :add self.base_namespace,
		for m in self.base_namespace.uses print_dependences(m,mod_done))]

[self_xml_name(p:slot,base_ns:module) : void => self_xml_name(selector(p),base_ns)]
[self_xml_attname(p:slot,base_ns:module) : void => self_xml_attname(selector(p),base_ns)]

[self_xml_attname(p:property,base_ns:module) : void
->	let m := module!(name(p))
	in (if (m = base_ns) printf("~A",string!(name(p)))
		else (when ms := get_schema(m)
			in (if ms.attributeFormDefaultQualified?
					printf("~A:~A",alias(m),string!(name(p)))
				else printf("~A",string!(name(p))))
			else error("error: XMLSchema, try to print a non-shema property ~S",p)))]

[self_xml_name(p:property,base_ns:module) : void
->	let m := module!(name(p))
	in (if (m = base_ns) printf("~A",string!(name(p)))
		else (when ms := get_schema(m)
			in (if ms.elementFormDefaultQualified?
					printf("~A:~A",alias(m),string!(name(p)))
				else printf("~A",string!(name(p))))
			else error("error: XMLSchema, try to print a non-shema property ~S",p)))]


[attribute?(c:object,self:property) : boolean -> false]
(abstract(attribute?))

[print_tabs(ctx:schema) : void ->	for i in (1 .. ctx.tab_deep) princ("\t")]

[self_xml(ctx:schema,self:schema_object,ps:slot) : void
->	//[TRACE_WRITE_1] self_xml(~S,~S,~S) // ctx,self,ps, 
	let prop := selector(ps),
		mprop := module!(name(prop))
	in (if (range(ps) < bag)
			(for o in get(prop,self) self_xml(ctx,self,ps,o))
		else (
			when o := get(prop,self)
			in self_xml(ctx,self,ps,o)))]

[self_xml(ctx:schema,parent:schema_object,ps:slot,o:schema_object) : void
->	printf("~I<~I~I~I>\n",
			(print_tabs(ctx)),
			(self_xml_name(ps,ctx.base_namespace)),
			(if (parent % schema) print_dependences(parent)),
			(for i in slots(owner(o))
				(if attribute?(o,selector(i)) self_attribute(i,o,ctx.base_namespace)))),
	ctx.tab_deep :+ 1,
	if (o % complexType) (
		for sl in slots(owner(o))
			(if (not(attribute?(o,selector(sl))) & (range(sl) < subtype[XMLSchema/schema_object] | range(sl) < XMLSchema/schema_object))
					self_xml(ctx,o,sl)))
	else self_xml_cdata(o),
	ctx.tab_deep :- 1,
	printf("~I</~I>\n",(print_tabs(ctx)), (self_xml_name(ps,ctx.base_namespace)))]


[self_xml(ctx:schema,parent:schema_object,ps:slot,o:simpleType) : void
->	if simple_known?(o) (
	printf("~I<~I~I>~I</~I>\n",
			(print_tabs(ctx)),
			(self_xml_name(ps,ctx.base_namespace)),
			(for i in slots(owner(o))
				(if attribute?(o,selector(i)) self_attribute(i,o,ctx.base_namespace))),
			(self_xml_cdata(o)),
			(self_xml_name(ps,ctx.base_namespace))))]



[self_attribute(s:slot,self:schema_object,basens:module) : void
->	//[TRACE_WRITE_2] self_attribute(~S,~S,~S) // s,self,basens, 
	when val := get(selector(s),self)
	in (//[TRACE_WRITE_2] ++++ printing attribute ~S.~S : (~S) // self,s, get(selector(s),self),
		printf(" ~I=\"~I\"",
			(self_xml_attname(s,basens)),
			case (val) (
				schema_object self_xml_cdata(val),
				integer princ(val),
				string princ(val),
				boolean (if val princ("true") else princ("false")),
				any error("connot print ~S", val))))
	else //[TRACE_WRITE_2] ***** attribute ~S.~S is unknown (~S) // self,s, get(selector(s),self)
		]
						
