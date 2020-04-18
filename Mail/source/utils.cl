/*	File : model.cl email protocol
	Module : Mail general mail purpose
	expert-solutions SARL
	Xavier Pechoultres
	
	1. Custom table

*/

//-------------------------------------------------------------------------
// 		1.	Custom table
//-------------------------------------------------------------------------
TRACE_UTILS :: -100

string_table <: table()

[make_string_table(def:string) : string_table
->	let t := make_table(string,string,def)
	in (put(isa, t, string_table),
		t)]

nth(t:string_table, s:string) : string -> nth@table(t,lower(s))

nth=(t:string_table, s:string, val:string) : void -> nth=@table(t,lower(s),val)

[tolist(t:table) : list[tuple]
->	let res := list<tuple>(),
		n := length(t.mClaire/graph),
		i := 1
	in (while (i < n & known?(t.mClaire/graph[i]) )
			(if known?(t.mClaire/graph[i + 1])
				res :add tuple(t.mClaire/graph[i],t.mClaire/graph[i + 1]),
			i :+ 2),
		res)]


[get_line(self:port) : string -> 
	//[TRACE_UTILS] get_line(~S) // self,
	let tmp := freadline(self)
	in (//[0] freadline => ~S // tmp,
		tmp)]


//-------------------------------------------------------------------------
// 		2.	Amazing fast port to port transfer
//-------------------------------------------------------------------------

[fread(from:port,to:port,len:integer) : boolean
->	//[TRACE_UTILS] fread(~S,~S,len) // from,to,len, 
	externC(" char * buff = new char[len]"), 
	externC(" if (buff == 0) Cerror(61, _string_(\"Mail/fread\"),0) "), 
	externC(" from->imported()->gets(buff,len) "),
	externC(" to->imported()->puts(buff,len) "),
	externC(" delete [] buff "),
	eof?(from)]
