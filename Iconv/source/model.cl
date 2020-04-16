
TRACE_DEBUG :: 10
TRACE_API :: 1

iconv_t <: import()

(c_interface(iconv_t,"iconv_t "))


ENCODINGS :: {
			// European
				"ASCII",
				"ISO-8859-1", "ISO-8859-2", "ISO-8859-3",
				"ISO-8859-4", "ISO-8859-5", "ISO-8859-7",
				"ISO-8859-9", "ISO-8859-10", "ISO-8859-13",
				"ISO-8859-14", "ISO-8859-15", "ISO-8859-16",
				"KOI8-R", "KOI8-U", "KOI8-RU",
				"CP1250", "CP1251", "CP1252", "CP1253",
				"CP1254", "CP1257", "CP850", "CP866", "CP437",
				"MacRoman", "MacCentralEurope", "MacIceland",
				"MacCroatian", "MacRomania", "MacCyril-lic",
				"MacUkraine", "MacGreek", "MacTurkish", "Macintosh",
			// Japanese
				"ISO-8859-6", "ISO-8859-8",
				"CP1255", "CP1256", "CP862", "CP932",
				"MacHebrew", "MacArabic",
				"EUC-JP", "SHIFT_JIS",
				"ISO-2022-JP", "ISO-2022-JP-2", "ISO-2022-JP-1",
			// Chinese
				"EUC-CN", "HZ", "GBK", "GB18030", "EUC-TW",
				"BIG5", "CP950", "BIG5-HKSCS",
				"ISO-2022-CN", "ISO-2022-CN-EXT",
			// Korean
				"EUC-KR", "CP949", "ISO-2022-KR", "JOHAB",
			// Armenian
				"ARMSCII-8",
			// Georgian
				"Georgian-Academy", "Georgian-PS",
			// Tajik
				"KOI8-T",
			// Thai
				"TIS-620", "CP874", "MacThai",
			// Laotian
				"MuleLao-1", "CP1133",
			// Vietnamese
				"VISCII", "TCVN", "CP1258",
			// Platform specifics
				"HP-ROMAN8", "NEXTSTEP",
			// Full Unicode
				"UTF-7", "UTF-8",
				"UCS-2", "UCS-2BE", "UCS-2LE",
				"UCS-4", "UCS-4BE", "UCS-4LE",
				"UTF-16", "UTF-16BE", "UTF-16LE",
				"UTF-32", "UTF-32BE", "UTF-32LE",
				"C99", "JAVA",
			// Full Unicode, in terms of uint16_t or uint32_t
			// (with machine dependent endianness and alignment)
				"UCS-2-INTERNAL", "UCS-4-INTERNAL"
}

iconv_open_error <: exception(tocode:ENCODINGS, fromcode:ENCODINGS)
iconv_error <: exception(code:integer,info:string = "unknwon error")

[self_print(self:iconv_open_error) : void ->
	printf("Iconv error :\nThe conversion from ~A to ~A is not supported  by the implementation",
			self.fromcode, self.tocode)]


[self_print(self:iconv_error) : void ->
	printf("Iconv error (~S) :\n~I", self.code,
		(if (self.code = (#if compiler.loading? externC("EINVAL",integer) else 0))
				printf("An incomplete  multibyte  sequence  has been encountered in the input")
		else if (self.code = (#if compiler.loading? externC("EILSEQ",integer) else 0))
				printf("An invalid multibyte sequence has been encountered in the input")
		else if (self.code = (#if compiler.loading? externC("E2BIG",integer) else 0))
		 	printf("There is not sufficient room in the output buffer")
		else print(self.info)))]
			

[_iconv(s:string, _tocode:ENCODINGS, _fromcode:ENCODINGS, opt:{"","//TRANSLIT","//IGNORE"}) : string ->
	let _to := _tocode /+ opt,
		cd := externC("iconv_open(_to, _fromcode)", iconv_t),
		inbytesleft := length(s),
		outbytesleft := 8 * inbytesleft,
		len := outbytesleft,
		ret := 0
	in (externC("ClEnv->bufferStart()"),
		externC("ClEnv->pushAttempt(8 * inbytesleft)"),
		if (externC("((CL_INT)cd)", integer) = -1) iconv_open_error(tocode = _tocode, fromcode = _fromcode),
		externC("char *inbuf = s; char *outbuf = ClEnv->buffer"),
		externC("int (*fp) (iconv_t, char**, size_t*, char**, size_t*) = (int (*) (iconv_t, char**, size_t*, char**, size_t*))iconv;"),
		ret := externC("(fp(cd, &inbuf, (size_t*)&inbytesleft, &outbuf, (size_t*)&outbytesleft))", integer),
		externC("iconv_close(cd)"),
		if (ret = -1) iconv_error(code = externC("errno", integer)),
		copy(externC("ClEnv->buffer", string), len - outbytesleft))]


[iconv(s:string, _tocode:ENCODINGS, _fromcode:ENCODINGS) : string -> _iconv(s, _tocode, _fromcode, "")]
[iconv_translit(s:string, _tocode:ENCODINGS, _fromcode:ENCODINGS) : string -> _iconv(s, _tocode, _fromcode, "//TRANSLIT")]
[iconv_ignore(s:string, _tocode:ENCODINGS, _fromcode:ENCODINGS) : string -> _iconv(s, _tocode, _fromcode, "//IGNORE")]


UTF8_BASE_ESCAPE_CHAR:string :=  string!(char!(195))

// fast utf8? check only standard latin1 
[utf8?(self:string) : boolean -> (find(self,UTF8_BASE_ESCAPE_CHAR) > 0)]

[_utf8?(self:string) : boolean ->
let l := length(self)
in (externC("(utf8::is_valid(self, self + l) ? CTRUE : CFALSE)",boolean))]

[utf8!(self:string) : string -> utf8!(self,"ISO-8859-15")]

[utf8!(self:string,from:ENCODINGS) : string -> if utf8?(self) self else iconv(self,"UTF-8",from)]

[latin!(self:string) : string -> if utf8?(self) iconv_ignore(self,"ISO-8859-15","UTF-8") else self]

converter <: filter(
		input_encoding:ENCODINGS = "ASCII",
		output_encoding:ENCODINGS = "ASCII",
		option:{"","//TRANSLIT","//IGNORE"} = "",
		iconvt:iconv_t,
		n_converted:integer = 0,
		wpending:char*,
		wpending_length:integer = 0)

converter!(from:ENCODINGS,to:ENCODINGS,opt:{"","//TRANSLIT","//IGNORE"}) : converter
-> converter(input_encoding = from,output_encoding = to,option = opt )

converter!(from:ENCODINGS,to:ENCODINGS) : converter -> converter!(from,to,"")

[close(self:converter) : converter ->
	//[TRACE_API] close(~S) // self,
	let _to := self.output_encoding /+ self.option,
		_fromcode := self.input_encoding
	in (//[TRACE_DEBUG] iconv converter from : ~S to ~S // _fromcode,_to,
		self.iconvt := externC("iconv_open(_to, _fromcode)", iconv_t)),
	self]

[free!(self:converter) : void ->
	//[TRACE_API] free!(~S) // self, 
	when x := get(iconvt,self) in externC("iconv_close(x)"),
	externC("if (self->wpending) free(self->wpending)")]

[flush_port(self:converter) : void ->
	//[TRACE_API] flush_port(~S)  : ~S / ~S // self, self.wpending_length,self.n_converted,
	if (self.wpending_length > 0)
		write_port(self,self.wpending,0)]

/*
[close_target!(self:converter) : converter
->	//[0] close_target!(~S) // self, 
	if (self.wpending_length > 0) flush(self),
	self]
*/

[close_port(self:converter) : void ->
	//[TRACE_API] close_port(~S) // self, 
	if (self.wpending_length > 0) (
			flush(self)),
	flush(self.target)
	]

[write_port(self:converter, buf:char*, len:integer) : integer ->
	//[TRACE_API] write_port(~S,~S,~A) // self,buf,len,
	let inbuf := (if (self.wpending_length = 0) buf
				else (let x := (externC("(char*) malloc(len + self->wpending_length)",char*))
				 	in (//[TRACE_DEBUG] has pending data ~S ~S // self.wpending_length, self.wpending,
						externC("memcpy(x,self->wpending, self->wpending_length)"),
						externC("memcpy(x + self->wpending_length,buf,len)"),
						len :+ self.wpending_length,
						externC("if (self->wpending) free(self->wpending)"),
						erase(wpending,self),
						self.wpending_length := 0,
						
						x))),
		outbuf:char* := externC("(char*)malloc(len * 8)",char*),
		outbufref := outbuf,
		ict:iconv_t := self.iconvt,
		nleft:integer := len,
		refout := len * 8,
		nout := len * 8,
		outlen := (refout - nout),
		converted := 0,
		_EILSEQ := (externC("EILSEQ",integer)), // invalid multibyte sequence
		_EINVAL := (externC("EINVAL",integer)), // incomplete multibyte sequence
		_E2BIG := (externC("E2BIG",integer)) // The output buffer has no more room for the next converted character
	in (while (let n := externC("(int)iconv(ict,&inbuf,(size_t*)&nleft,&outbufref,(size_t*)&nout)",integer)
				in (//[TRACE_DEBUG] converted ~S byte / nleft: ~S  / nout:~S // n,nleft,nout,
					if (n = -1) (
						let _errno := (externC("errno", integer))
						in (if (_errno = _EILSEQ) (iconv_error(code = _EILSEQ), false)
							else if (_errno = _E2BIG | _errno = _EINVAL) (
									if (_errno = _E2BIG) //[TRACE_DEBUG] The output buffer has no more room for the next converted character : add pending data
									else //[TRACE_DEBUG] incomplete multibyte sequence : add pending data,
									let x := (externC("(char*) malloc(nleft)",char*))
									in (externC("memcpy(x,inbuf, nleft)"),
										self.wpending_length :=  nleft,
										self.wpending := x),
									none
									)
							else iconv_error(code = _errno),
							false))
					else  (
						converted :+ n,
						(n > 0)))) (none),
		self.n_converted :+ (refout -  nout),
		write_port(self.target, outbuf, (refout -  nout)))]

[read_port(self:converter, buf:char*, len:integer) : integer ->
	//[TRACE_API] > read_port( ~S, ~S, ~S) // self,buf,len,
	let in_buff := (let _buf := externC("(char*) malloc(len + self->wpending_length)",char*)
				 	in (if (self.wpending_length = 0) externC("(char*) malloc(len + self->wpending_length)")
						else (
							//[TRACE_DEBUG] has pending data ~S ~S // self.wpending_length, self.wpending,
							externC("memcpy(_buf,self->wpending, self->wpending_length)"),
							externC("memcpy(_buf + self->wpending_length,buf,len)"),
							len :+ self.wpending_length,
							externC("if (self->wpending) free(self->wpending)"),
							erase(wpending,self),
							self.wpending_length := 0),
						_buf)),
		outbytesleft:integer := len ,
		ict:iconv_t := self.iconvt,
		toread := len,
		converted := 0,
		_EILSEQ := (externC("EILSEQ",integer)), // invalid multibyte sequence
		_EINVAL := (externC("EINVAL",integer)), // incomplete multibyte sequence
		_E2BIG := (externC("E2BIG",integer)), // The output buffer has no more room for the next converted character
		nread := read_port(self.target,in_buff,toread),
		nleft := nread
	in (//[TRACE_DEBUG] read ~S bytes on target of ~S // nread, len,
		if (not(eof?(self.target)) & nleft > 0)
			let _yy := 0
			in (
				while (let n := externC("(int)iconv(ict,&in_buff,(size_t*)&nleft,&buf,(size_t*)&outbytesleft)",integer)
					in (//[TRACE_DEBUG] while n=~S writted=~S // n,  (len * 8) - outbytesleft,
						if (n = -1) (
						let _errno := (externC("errno", integer))
						in (if (_errno = _EILSEQ) (
								//[TRACE_DEBUG] invalid multibyte sequence,
								iconv_error(code = _EILSEQ), false)
							else if (_errno = _E2BIG | _errno = _EINVAL) (
						  			if (code = _E2BIG) //[TRACE_DEBUG] output buff to small : add to local buff
									else //[TRACE_DEBUG] incomplete multibyte sequence : add to local buff,
									(let x := (externC("(char*) malloc(nleft)",char*))
									in (externC("memcpy(x,in_buff, nleft)"),
										self.wpending_length :=  nleft,
										self.wpending := x)),
									none
									)
							else iconv_error(code = _errno),
							false))
					else  (
						converted :+ n,
						(n > 0)))) (none)),
		converted)]

