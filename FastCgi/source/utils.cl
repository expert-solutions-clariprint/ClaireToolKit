
FCGI_REQUEST_COMPLETE :: 0
FCGI_CANT_MPX_CONN    :: 1
FCGI_OVERLOADED       :: 2
FCGI_UNKNOWN_ROLE     :: 3

// *********************************************************************
// *   Part 2: tools                                             *
// *********************************************************************

// @doc tools
// read 2 chars and return integer
[geti2(p:port) : integer
-> (geti(p) << 8) + geti(p)]

// @doc tools
// read 1 chars and return integer
[geti(p:port) : integer
-> integer!(getc(p))]


// @doc tools
// read 1 ou 4 chars and return equivalent integer
[getlen(p:port) : integer
-> let i := geti(p),
		n := 0
	in (if (i[7]) (
			i :- 128, // remove 7th bit
			i :<< 24,
			let c := geti(p) in i :+ (c << 16),
			let c := geti(p) in i :+ (c << 8),
			let c := geti(p) in i :+ c),
		i)]


// @doc tools
// return tuple
[cgi_tuple(p:port) : tuple(string,string)
->	let name_len := getlen(p),
		value_len := getlen(p)
	in (tuple(fread(p,name_len), fread(p,value_len)))]

// @doc tools
// return tuples
[cgi_tuples(p:port,len:integer) : list[tuple]
->	let b := blob!(),
		res := list<tuple>()
	in (freadwrite(p,b,len),
		while not(eof?(b)) res :add cgi_tuple(b),
		//[2] ~S // res,
		res)]


[cgiType(i:integer) : string
-> case i (
		{ 1} "FCGI_BEGIN_REQUEST",
		{ 2} "FCGI_ABORT_REQUEST",
		{ 3} "FCGI_END_REQUEST",
		{ 4} "FCGI_PARAMS",
		{ 5} "FCGI_STDIN",
		{ 6} "FCGI_STDOUT",
		{ 7} "FCGI_STDERR",
		{ 8} "FCGI_DATA",
		{ 9} "FCGI_GET_VALUES",
		{10} "FCGI_GET_VALUES_RESULT",
		{11} "FCGI_UNKNOWN_TYPE",
		any "?")]

// *********************************************************************
// *   Part 2: record_port                                             *
// *********************************************************************


record_port <: filter( // pendingr:blob,
				cgi_params:table = make_table(string,string,""),
				cgi_stdin:blob,
				stdin?:boolean = false,
				request_id:integer = 0,
				vers:integer,
				kind:integer,
				role:integer,
				flags:integer,
				end_request?:boolean = false,

				pendingw:blob,
				eof_reached?:boolean = false)

//<sb> @doc Chunked transfer coding
// chunker!(self) creates a read/write filter that handle chunked encoded
// datas.
record_port!(self:port) : record_port ->
	filter!(record_port(// pendingr = blob!(),
					pendingw = blob!()), self)

/*
typedef struct {
            unsigned char version;
            unsigned char type;
            unsigned char requestIdB1;
            unsigned char requestIdB0;
            unsigned char contentLengthB1;
            unsigned char contentLengthB0;
            unsigned char paddingLength;
            unsigned char reserved;
            unsigned char contentData[contentLength];
            unsigned char paddingData[paddingLength];
        } FCGI_Record;
*/

[send_header(self:record_port,len:integer,kind:integer) : void
->	//[2] send_header(~S,~A,~A) // self, len, kind,
	externC("FCGI_Record_Header h;"),
	externC("h.version = 1"),
	externC("h.type = (char)(0xFF & kind)"),
	externC("long req_id = (long)self->request_id"),
	externC("h.requestIdB1 = (char)(0xFF & (req_id >> 8))"),
	externC("h.requestIdB0 = (char)(0xFF & req_id)"),
	externC("h.contentLengthB1 = (char)(0xFF & (len >> 8))"),
	externC("h.contentLengthB0 = (char)(0xFF & len)"),
	externC("h.paddingLength = 0"),
	externC("h.reserved = 0"),
	write_port(self.target, externC("&h",char*),8)]

 
[send_fcgi_end_request(self:record_port)  : void
-> 	//[0] send_fcgi_end_request(),
	send_header(self,8,FCGI_END_REQUEST),
	externC("FCGI_EndRequestBody h;"),
	externC("h.appStatusB3 = 0"),
	externC("h.appStatusB2 = 0"),
	externC("h.appStatusB1 = 0"),
	externC("h.appStatusB0 = 0"),
	externC("h.protocolStatus = 0"),
	externC("h.reserved[0] = 0"),
	externC("h.reserved[1] = 0"),
	externC("h.reserved[2] = 0"),
	//externC("char tmp[8]"),
	//externC("memcpy(tmp,&h,8)"),
	write_port(self.target, externC("&h",char*),8),
	self.end_request? := true]


// MAX_RECORD_DATA_SIZE :: 65535
MAX_RECORD_DATA_SIZE :: 8192   // set un small record content size for better reliability

flush_port(self:record_port) : void ->
	let pend := self.pendingw,
		d := self.pendingw.Core/data,
		len  := length(pend)
	in (//[0] flush_port FCGI_STDOUT ~A  ~S // len, self.end_request?,
		if (len > 0) (
			while (len > 0) (
				let tosent :=  min(MAX_RECORD_DATA_SIZE,len) // j'en envoie tosent avec au max  MAX_RECORD_DATA_SIZE
				in (
					//[3] ----- flush_port ~A // tosent,
					send_header(self,tosent,FCGI_STDOUT),
					write_port(self.target,d , tosent),
					// externC("printf(\"d = %x  tosent = %ld\",d,tosent)"),
					externC("d += tosent"),
					// externC("printf(\" => %x  \\n\",d)"),
					// write_port(self.target,"\0",1),
					len :- tosent // il reste len a enoyer
				)),
			self.pendingw := blob!(),
			//[3] after flush =======> length ~A // length(self.pendingw)
		))

write_port(self:record_port, buf:char*, len:integer) : integer ->
	let pend := self.pendingw,
		tosend := len
	in (write_port(pend, buf, len),
		if (length(self.pendingw) >= MAX_RECORD_DATA_SIZE) flush_port(self),
		len)

close_port(self:record_port) : void ->
	(//[0] will ... close ? ~S // self.end_request?,
	if not(self.end_request?) (
			flush_port(self),
			send_header(self,0,FCGI_STDOUT),
			send_fcgi_end_request(self),
			//[0] remove has filter ,
			erase(target,self),
			// fclose(self.pendingr),
			// fclose(self.pendingw),
			//[0] closed
			))

eof_port?(self:record_port) : boolean -> self.eof_reached?

read_port_(self:record_port, buf:char*, len:integer) : integer ->
	let n := 0,
		pend := self.pendingr
	in (while (not(self.eof_reached?) & len > 0)
			(if eof_port?(pend)
				(if eof_port?(self.target)
					error("Premature end of file on ~S", self),
				let s := freadline(self.target, "\r\n"),
					chunk_length := 0
				in (if (length(s) = 0) s := freadline(self.target, "\r\n"),
					externC("sscanf(s, \"%x\", &chunk_length)"),
					set_length(pend, 0),
					if (chunk_length = 0)
						(freadline(self.target, "\r\n"),
						self.eof_reached? := true,
						break()),
					Core/write_attempt(pend, chunk_length),
					pend.Core/write_index := read_port(self.target, pend.Core/data, chunk_length))),
			let m := read_port(pend, buf, len)
			in (n :+ m,
				len :- m,
				buf :+ m)), n)

[params_to_env(self:record_port) : void
-> when t := get(cgi_params,self)
	in let  _graph := t.mClaire/graph in 
		(for i in (1 .. (length(_graph) / 2))
			when v := _graph[2 * i]
			in (setenv(_graph[2 * i - 1] /+ "=" /+ v)))]

