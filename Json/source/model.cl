

JSON_DATATYPE :: (table U string U float U integer U boolean U {unknown} U list U tuple)
//private/JSON_DATATYPE :: any 

private/START :: { '{', // start table
		'[', //start array
		't', // true
		'f', //false,
		'"', // string
		'n', // null
		'-','0','1','2','3','4','5','6','7','8','9'} // number

private/ENDCHAR :: { '}',
		']',
		',',
		':',
		' ' }

private/DELIMETER :: {'{', '}', // table
		'[',']',
		',',
		':',
		't', // true
		'f', //false,
		'"', // string
		'n', // null
		'-','0','1','2','3','4','5','6','7','8','9'}

private/dummy <: object()
private/dummy_key <: object()
private/dummy_unstack <: object()
private/dummy_next <: private/dummy_unstack()

/*
private/dummy_end_table <: object()
private/dummy_end_list <: object()
private/dummy_next <: object() */

[hex2char(self:string) : char ->
	let x := 0,
		c1 := self[1],
		c2 := self[2]
	in (if (c1 > '0' & c1 <= '9')
	 		x :+ ((integer!(c1) - integer!('0')))
		else if (c1 >= 'A' & c1 <= 'F')
			x :+ ((integer!(c1) - integer!('A') + 10))
		else if (c1 >= 'a' & c1 <= 'f')
			x :+ ((integer!(c1) - integer!('a') + 10)),
		x :* 16,
		if (c2 > '0' & c2 <= '9')
	 		x :+ ((integer!(c2) - integer!('0')) * 1)
		else if (c2 >= 'A' & c2 <= 'F')
			x :+ ((integer!(c2) - integer!('A') + 10) * 1)
		else if (c2 >= 'a' & c2 <= 'f')
			x :+ ((integer!(c2) - integer!('a') + 10) * 1),
		//[4] hex2char(self:~S) : ~S // self, x,
		char!(x))]

[private/read_string(p:port) : string
->	let res := ""
	in (while (let x := freadline(p,{'"',"\\u"})
				in (// //[0] x = ~S // x,
					if (x[2] = "\\u")
						let u := (/* fread(p,1), */ ""),
							str := "",
							v1 := fread(p,2),
							v2 := fread(p,2)
						in (str :/+ string!(hex2char(v1)),
							str :/+ string!(hex2char(v2)),
							res :/+ x[1],
							//[4] x[1] : ~S / ~A | str: ~S / ~A // x[1], length(x[1]), str,length(str),
							let uu := Iconv/iconv(str,"UTF-8","UTF-16BE")
							in (//[4] uu:~S / ~A // uu, length(uu),
									res :/+ uu),
							true)
					else (res :/+ x[1],
						if (length(res) > 0)
							(if (res[length(res)] = '\\') (res :/+ string!(x[2]), true) else false)
							else false
							))) none,
		res)]

[private/read_number(p:port) : (float U integer)
->	let x := freadline(p,ENDCHAR),
		v := x[1]
	in (// //[0] x = ~S , eof? = ~S // x,
		if (x[2] != "") unget(p,x[2]),
		if (find(v,".") > 0) float!(v)
		else integer!(v))]

[decode(p:string) : JSON_DATATYPE -> decode(port!(p))]

[decode_file(filename:string) : JSON_DATATYPE -> 
	let f := fopen(filename,"r"),
		res := decode(f)
	in (fclose(f),
		res)]
/*
[print_stack(l:list) : void
->	printf("=========\nstack(~I) \n=========\n",
		(for i in l
			(if (i % object) printf("~S,",isa(i)) else printf("~S,",i))))]
*/
[table!() : table -> make_table(string,JSON_DATATYPE,unknown)]

// STACK:list := nil

[decode(p:port) : JSON_DATATYPE
->	let escape?:boolean := false,
		deep:integer := 0,
		c:char := EOF,
		stack := list<JSON_DATATYPE>(),
		current:JSON_DATATYPE := unknown,
		UNSTACK := dummy_unstack(),
		NEXT := dummy_next(),
		KEY := dummy_key(),
		res:JSON_DATATYPE := unknown
	in (// STACK := stack,
		while (not(eof?(p)))
			let x := freadline(p,DELIMETER),
				val := (
					//[2] x : ~S // x,
					case x[2] (
						{'"'} read_string(p),
						{'['} (deep :+ 1, list<JSON_DATATYPE>()), 
						{'t'} (fread(p,3), true),
						{'f'} (fread(p,4), false),
						{'n'} (fread(p,3), unknown),
						{'{'} (deep :+ 1, make_table(string,JSON_DATATYPE,"")),
						{'}',']'} (deep :- 1, UNSTACK),
						{','} KEY,
						{'$', ':' } KEY,
						any (unget(p,x[2]), read_number(p))))
			in (//[2] -----------------------------------------------------------------------,
				//[2] val : ~S x = ~S  deep: ~S stack:~S// val,x,deep,length(stack),
				// print_stack(stack),
				case val (
					dummy_key (none),
					dummy_unstack
						(//[2] unstack ~S ... // stack,
						shrink(stack,length(stack) - 1),
						//[3] ... unstack ~S // stack,
						none),
					any (//[2] any :  ~S // val,
						if (length(stack) = 0) (if unknown?(res) res := val, stack :add val)
						else if (last(stack) % list)
							(
							//[2] add to list :  ~S // val,
							let l := last(stack) in l :add val,
							if (val % (list U table)) stack :add val)
						else if (last(stack) % table & val % (string))
							stack :add val
						else if (last(stack) % string & stack[length(stack) - 1] % table)
							(
							let k := last(stack),
								t := stack[length(stack) - 1]
							in (t[k] := val,
								shrink(stack,length(stack) - 1),
								if (val % (list U table)) stack :add val))
						else error("??")))),
		res)]

[encode(self:string) : boolean -> printf("~S",self),true]

[encode(self:tuple) : boolean -> encode(list!(self))]


[encode(self:float) : boolean -> printf("~A",self),true]

[encode(self:integer) : boolean -> printf("~A",self),true]

[encode(self:boolean) : boolean -> if self princ("true") else princ("false"), true]


[encode(self:table) : void -> 
	printf("{~I}",
		(let _graph := self.mClaire/graph,
			first? := true
		in	for i in (1 .. (length(_graph) / 2))
				let key := _graph[2 * i - 1],
					_value := _graph[2 * i]
				in	(if known?(_value)
						(if first? first? := false else printf(","),
						printf("~S:~I",key,encode(_value))))))]
//					else printf("~S:null"))))]

[encode(self:list) : boolean -> 
	printf("[~I]",(let first?  := true
					in (for i in self
							(if first? first? := false else printf(","),
							encode(i))))),
	true]

[encode(self:JSON_DATATYPE,p:port) : port ->
	let oldp := use_as_output(p)
	in (encode(self),use_as_output(oldp),p)]

[encode(self:JSON_DATATYPE,filename:string,mode:string) : void ->
	fclose(encode(self,fopen(filename,mode)))]

[encode(self:JSON_DATATYPE,filename:string) : void -> encode(self,filename,"w")]
	
