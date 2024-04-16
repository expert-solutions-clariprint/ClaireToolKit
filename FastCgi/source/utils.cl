
FCGI_REQUEST_COMPLETE :: 0
FCGI_CANT_MPX_CONN    :: 1
FCGI_OVERLOADED       :: 2
FCGI_UNKNOWN_ROLE     :: 3


[dualbytes(str:string) : integer
-> let i := 0
	in (externC(" i += (int)str[1];"),
		externC(" i += ((int)str[0] << 1);"),
		i)]

[geti2(p:port) : integer
-> (geti(p) << 8) + geti(p)]

[geti(p:port) : integer
-> integer!(getc(p))]


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




[cgi_tuple(p:port) : tuple(string,string)
->	let name_len := getlen(p),
		value_len := getlen(p)
	in (tuple(fread(p,name_len), fread(p,value_len)))]

[cgi_tuples(p:port,len:integer) : list[tuple]
->	let b := blob!(),
		res := list<tuple>()
	in (freadwrite(p,b,len),
		while not(eof?(b)) res :add cgi_tuple(b),
		res)]







record_port <: filter(pendingr:blob,
				request_id:integer = 0,
				pendingw:blob,
				on_record?:boolean = false,
				add_empty_chunk?:boolean = false,
				eof_reached?:boolean = false)

//<sb> @doc Chunked transfer coding
// chunker!(self) creates a read/write filter that handle chunked encoded
// datas.
record_port!(self:port) : record_port ->
	filter!(record_port(pendingr = blob!(),
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
	externC("h.type = (int)kind"),
	externC("long req_id = (long)self->request_id"),
	externC("h.requestIdB1 = (int)((0xFF00 & req_id) >> 8)"),
	externC("h.requestIdB0 = (int)(0xFF & req_id)"),
	externC("h.contentLengthB1 = (int)(0xFF00 & len) >> 8"),
	externC("h.contentLengthB0 = (int)(0xFF & len)"),
	externC("h.paddingLength = 1"),
	externC("h.reserved = 0"),
	externC("char tmp[8]"),
	externC("memcpy(tmp,&h,8)"),
	// externC("printf(\"req_id %d : %d - %d \\n\",req_id,h.requestIdB1,h.requestIdB0)"),
	// externC("printf(\"contentLength %d : %d - %d \\n\",len,h.contentLengthB1,h.contentLengthB0)"),
	write_port(self.target, externC("tmp",char*),8)]

 
[send_fcgi_end_request(self:record_port)  : void
-> 	//[2] send_fcgi_end_request(),
	send_header(self,8,FCGI_REQUEST_COMPLETE),
	externC("FCGI_EndRequestBody h;"),
	externC("h.appStatusB3 = 0"),
	externC("h.appStatusB2 = 0"),
	externC("h.appStatusB1 = 0"),
	externC("h.appStatusB0 = 0"),
	externC("h.protocolStatus = 0"),
	externC("h.reserved[0] = 0"),
	externC("h.reserved[1] = 0"),
	externC("h.reserved[2] = 0"),
	externC("char tmp[8]"),
	externC("memcpy(tmp,&h,8)"),
	write_port(self.target, externC("tmp",char*),8)]

flush_port(self:record_port) : void ->
	let pend := self.pendingw,
		len := length(pend)
	in (//[2] flush_port FCGI_STDOUT,
		if (self.on_record? = false)
			send_header(self,len,FCGI_STDOUT),
		write_port(self.target, pend.Core/data, len),
		write_port(self.target,"\0",1),
		self.on_record? := false,
		set_length(pend, 0))


write_port(self:record_port, buf:char*, len:integer) : integer ->
	let pend := self.pendingw
	in (write_port(pend, buf, len),
		if (length(pend) > 1024)
			flush_port(self),
		len)

close_port(self:record_port) : void ->
	(
	flush_port(self),
	send_fcgi_end_request(self),
	erase(target,self), // remove filter
	fclose(self.pendingr),
	fclose(self.pendingw))

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

