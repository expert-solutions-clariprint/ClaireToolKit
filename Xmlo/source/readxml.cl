
Entry1 <: ephemeral_object(content:list[any], key:any, range:type)
Entry2 <: ephemeral_object(content:list[any], key1:any, key2:any, range:type)


Anch <: ephemeral_object(content:list[any])
BagAnch <: Anch(range:type)
ListAnch <: BagAnch()
SetAnch <: BagAnch()
TupleAnch <: Anch()
CsvList <: Anch()

STACK:list[any] := list<any>()

[peek(ctx:context, i:integer) : any => if (length(ctx.stack) - i < 1) false else ctx.stack[length(ctx.stack) - i]]

[pop(ctx:context) : any => let x := peek(ctx,0) in (shrink(ctx.stack, length(ctx.stack) - 1), x)]
[pop(ctx:context,i:integer) : any => let x := peek(ctx,i) in (shrink(ctx.stack, length(ctx.stack) - i), x)]

[currentRange(ctx:context) : any ->
	try let prop := peek(ctx,0),
			obj := peek(ctx,1),
			rng := range(@(prop, owner((if (obj % (Entry1 U Entry2)) content(obj) else obj))))
		in (//[V_XMLOBJECTS_BUGS] currentRange -> ~S // rng,
			rng) catch any false]


[currentObject(ctx:context) : any ->
	let o := peek(ctx,1)
	in case o ((Entry1 U Entry2) content(o), any o)]

// STACK: [... obj prop]
[basicValue?(ctx:context,self:property) : boolean =>
	peek(ctx,0) = self & currentRange(ctx) % {string, integer,char,float,boolean}]

[basicType?(self:type) : boolean =>
	self % {string, integer, char, float, boolean}]

// STACK [... obj prop subobj]

[castString(self:string, X:type,parser:Sax/sax_parser) : any ->
	self := trim(self),
	case X
		({integer} integer!(self),
		{string} Iconv/latin!(url_decode(self)),
		{boolean} get_value(self),
		{port} (let p := port!() in (decode64(port!(self),p),p)),
		{char} url_decode(self)[1],
		{float} float!(self))]

enterTag :: property(open = 3)
leaveTag :: property(open = 3)



/*


nouvelle gesito

*/





[enterTag(parser:Sax/sax_parser, ctx:context,tag:string, attrs:table) : void ->
	//[V_XMLOBJECTS] enterTag <~A> ctx.stack[~A] , key=~S, keys=~S// tag, ctx.stack, attrs["key"], attrs["keys"],
	let ak := attrs["key"] as string
	in (if (length(ak) > 0)
			let t := get(peek(ctx,0), peek(ctx,1))
			in ctx.stack :add Entry1(key = castString(ak, t.domain,parser),
								range = range(t))
		else
			let aks := attrs["keys"] as string
			in (if (length(aks) > 0)
					let t := get(peek(ctx,0), peek(ctx,1)),
						l := explode(aks, ",")
					in ctx.stack :add Entry2(key1 = castString(l[1], t.domain[1], parser),
											key2 = castString(l[2], t.domain[2], parser),
											range = range(t))
				else let x := xmlNameToObject(ctx,tag,parser)
						in case x
							(
							{CsvList} (
								let p := parser.Sax/input,
									csv_class := xmlNameToObject(ctx,attrs["of"],parser),
									csv_slots := list{@(xmlNameToObject(ctx,prop,parser), csv_class)  | prop in explode(attrs["properties"],";")},
									next := true,
									anch := peek(ctx,0)
								in (
									//[-1] Read CSV ~S ~S // csv_class, csv_slots,
									while (next)
										let obj := new(csv_class)
										in (//[-1] new : ~S // obj,
											for sl in csv_slots
												let t := freadline(p,{";","\n"}) , i := t[1] in (
													//[-1] Slot : ~S value : ~S // sl,t,
													if (t[1] = "==") (
														next := false,
														break())
													else if (length(t[1]) > 0) (
														case range(sl) (
															{string}	put(selector(sl),obj,url_decode(t[1])),
															{boolean}	put(selector(sl),obj,(if (t[1] = "true") true else false)),
															{integer}	put(selector(sl),obj,integer!(t[1])),
															{float}		put(selector(sl),obj,float!(t[1])),
														// any void
															subtype		put(selector(sl),obj, cast!(set!(explode(url_decode(t[1]),";")) but "",string) 	)
															))),
											if next add(content,anch,obj)))),
							class (
								ctx.stack :add (case x
													(
													{float} 0.0,
													{boolean} false,
													{integer} 0,
													{char} ' ',
													{string} "",
													{list} (when typ := (let typen := explode(attrs["of"],"/"),
																			typmod := (if (length(typen) = 2)
																						when m := get_value(typen[1]) in m else module!() else module!())
																		 in (get_value(typmod,last(typen))))
															in make_list(typ,0)
															else make_list(any,0)),
													{set} make_set(0),
													any (xmlizedTree?(x),
														new(x)))),
									let p0 := peek(ctx,0)
									in for s in {s in x.slots|XML_PROPERTIES?[s.selector] = true & not(s.range % subtype[table])}
										erase(s.selector, p0)),
							property (
									ctx.stack :add x,
										let r := range(@(x, owner(peek(ctx,1)))),
											b := true /* (try not(mClaire/t1(r) % {string,integer,float,boolean,char,port}) catch any true) */
										in (if b case r
												(subtype[tuple]
													(ctx.stack :add TupleAnch()),
												subtype[set]
													(ctx.stack :add SetAnch(range = of(get(x, peek(ctx,1))))),
												subtype[list]
													(ctx.stack :add ListAnch(range = of(get(x, peek(ctx,1)))))))))))]

[castInto(t:type) : type ->
	let tt1 := mClaire/t1(t),tt2 := mClaire/t2(t) in
	case t
		(Union (if (tt1 % tuple | tt2 % tuple) tuple
				else if (tt1 % subtype[list]) tt1
				else if (tt2 % subtype[list]) tt2
				else if (tt1 % subtype[set]) tt1
				else if (tt2 % subtype[set]) tt2
				else t),
		any t)]


[leaveTag(parser:Sax/sax_parser, ctx:context,tag:string, cdata:string) : void ->
	//[V_XMLOBJECTS] leaveTag </~A> ctx.stack[~A] // tag, ctx.stack,
	try let p := xmlNameToObject(ctx,tag,parser)
		in case p
			({CsvList} (none),
			property
				(//[V_XMLOBJECTS_BUGS]    property ~S // p,
				case peek(ctx,0)
					(ListAnch (
						if (trim(cdata) != "") 
						(
							let r := range(@(p, owner(peek(ctx,2))) as slot),
								r2 := (case r (subtype mClaire/t1(r), any any))
							in (if (r2 % {string,integer,float,boolean,char,port})
									add(p,peek(ctx,2),castString(cdata, r2, parser))
								)
						) else write(p, peek(ctx,2), cast!(peek(ctx,0).content, peek(ctx,0).range)),
						pop(ctx,2)),
					SetAnch (
						if (trim(cdata) != "") 
						else write(p, peek(ctx,2), cast!(set!(peek(ctx,0).content), peek(ctx,0).range)), pop(ctx,2)),
					TupleAnch (write(p, peek(ctx,2), tuple!(peek(ctx,0).content)), pop(ctx,2)),
					property 	(
								let r := range(@(p, owner(peek(ctx,1))) as slot)
								in (if (r != table) write(p, peek(ctx,1), castString(cdata, r, parser))),
									pop(ctx)),
					any (if (length(ctx.stack) > 2)
							(write(p, peek(ctx,2), peek(ctx,0)),
							pop(ctx,2))))),
			class 
				(//[V_XMLOBJECTS_BUGS]    class ~S // p,
				let testval := tagToValue(tag, cdata)
				in (if (testval != UNKNOWN)
						ctx.stack[length(ctx.stack)] := testval
					else if (p % {boolean,string,integer,float,char,port})
						ctx.stack[length(ctx.stack)] := castString(cdata,p, parser),
					case peek(ctx,1)
					(property (
							if (peek(ctx,2) % any & get(peek(ctx,1),peek(ctx,2)) % bag)
								(let prop := peek(ctx,1), obj := peek(ctx,2) in
								(add(prop,obj,castString(cdata, p, parser))),
								pop(ctx)),
							none),
					list (peek(ctx,1) add peek(ctx,0), pop(ctx)),
					set (peek(ctx,1) add peek(ctx,0), pop(ctx)),
					Entry1 (peek(ctx,1).content :add peek(ctx,0), pop(ctx)),
					Entry2 (peek(ctx,1).content :add peek(ctx,0), pop(ctx)),
					BagAnch (peek(ctx,1).content :add peek(ctx,0), pop(ctx)),
					TupleAnch (peek(ctx,1).content :add peek(ctx,0), pop(ctx))))))
	catch any 
		(//[V_XMLOBJECTS_BUGS]    not(class|property) ~S [~S] // peek(ctx,0), exception!(),
		let e := peek(ctx,0),
			t := (try castInto(e.range) catch any e.range),
			val := (if (t = tuple) tuple!(e.content)
					else if (t % subtype[list]) cast!(e.content, mClaire/t1(t))
					else if (t % subtype[set]) cast!(set!(e.content), mClaire/t1(t))
					else if basicType?(t) castString(cdata, t, parser)
					else e.content[1])
		in case e
			(Entry1 (nth=(get(peek(ctx,1),peek(ctx,2)), e.key, val), pop(ctx)),
			Entry2 (nth=(get(peek(ctx,1),peek(ctx,2)), e.key1, e.key2, val), pop(ctx)),
			any //[V_XMLOBJECTS]    error! // 
				)),
	//[V_XMLOBJECTS_BUGS] <<< leaveTag </~A> ctx.stack[~A] // tag, ctx.stack
	]


[unXml!(self:string) : any ->
	let bb := blob!(self),
		res := unXml!(bb)
	in (fclose(bb),
		res)]

[unXml!(self:port) : any ->
	let ctx := context() in
		(Sax/sax(self, enterTag, leaveTag,ctx),
		if (length(ctx.stack) > 0) ctx.stack[1] else unknown)]

[unXml!(self:port,charset:string) : any ->
	let ctx := context()
	in (
		Sax/sax(filter!(Iconv/converter!("UTF-8",charset),self), enterTag, leaveTag,ctx),
		if (length(ctx.stack) > 0) ctx.stack[1] else unknown)]

[unXml!(self:port,sax:Sax/sax_parser) : any ->
	let ctx := context(),
		parser := Sax/sax_parser(Sax/input = self,
								Sax/nsmap = sax.Sax/nsmap,
								Sax/currentns = sax.Sax/currentns,
								Sax/xml_begin_element_handler = enterTag,
								Sax/xml_end_element_handler = leaveTag,
								Sax/core_charset = sax.Sax/core_charset,
								Sax/file_charset = sax.Sax/file_charset,
								Sax/xml_data = ctx)
	in (Sax/sax(parser),
		if (length(ctx.stack) > 0) ctx.stack[1] else unknown)]



[unXmlFile!(filename:string) : any ->
let fi := fopen(filename,"r"),
	res := unXml!(fi)
in	(fclose(fi), res)]


[read_csv(self:string,current:integer) : tuple(string,integer,boolean)
->	let first := current,
		quoted? := false,
		eol? := false
	in (while (current <= length(self)) (
			if (self[current] = '\\') current :+ 2,
 			if (self[current] % {',','\n'}) (
				break()
			),
			current :+ 1	
			),
		tuple(substring(self,first,current - 1),current + 1,current >= length(self)))]


csv_list <: ephemeral_object(
	objects_class:class,
	properties:list[property])

