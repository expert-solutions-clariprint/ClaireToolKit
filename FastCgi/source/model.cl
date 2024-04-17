

FCGI_BEGIN_REQUEST      ::  1
FCGI_ABORT_REQUEST      ::  2
FCGI_END_REQUEST        ::  3
FCGI_PARAMS             ::  4
FCGI_STDIN              ::  5
FCGI_STDOUT             ::  6
FCGI_STDERR             ::  7
FCGI_DATA               ::  8
FCGI_GET_VALUES         ::  9
FCGI_GET_VALUES_RESULT  :: 10
FCGI_UNKNOWN_TYPE       :: 11

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





FCGI_BEGIN_REQUEST :: 1
/*
typedef struct {
            unsigned char roleB1;
            unsigned char roleB0;
            unsigned char flags;
            unsigned char reserved[5];
        } FCGI_BeginRequestBody
*/


fcgi_request_id:integer := 0

fcgi_context <: ephemeral_object()
fcgi_record <: ephemeral_object(
	vers:integer,
	kind:integer,
	request_id:integer)

fcgi_begin_request       <: fcgi_record(role:integer,flags:integer)
fcgi_abort_request       <: fcgi_record()
fcgi_end_request         <: fcgi_record()
fcgi_params              <: fcgi_record(values:list[tuple])
fcgi_stdin               <: fcgi_record(datas:blob)
fcgi_stdout              <: fcgi_record()
fcgi_stderr              <: fcgi_record()
fcgi_data                <: fcgi_record()
fcgi_get_values          <: fcgi_record()
fcgi_get_values_result   <: fcgi_record()
fcgi_unknown_type        <: fcgi_record()

[fcgi_record!(k:integer) : fcgi_record
-> let x := (case k (
		{ 1} fcgi_begin_request(),
		{ 2} fcgi_abort_request(),
		{ 3} fcgi_end_request(),
		{ 4} fcgi_params(),
		{ 5} fcgi_stdin(),
		{ 6} fcgi_stdout(),
		{ 7} fcgi_stderr(),
		{ 8} fcgi_data(),
		{ 9} fcgi_get_values(),
		{10} fcgi_get_values_result(),
		{11} fcgi_unknown_type(),
		any fcgi_unknown_type())) in (x.kind := k, x)]

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

FCGI_RESPONDER :: 1
FCGI_AUTHORIZER :: 1
FCGI_FILTER :: 1

FCGI_RECORDS:list := list<fcgi_record>()


[decode_record(p:port) : fcgi_record
->	//[0] decode_record readable ? ~S // readable?(p),
	let v := geti(p),
		k := geti(p),
		t := fcgi_record!(k)
	in (t.vers := v,
		//[2] version : ~A // t.vers,
		//[2] type : ~S // cgiType(t.kind),
		t.request_id := geti2(p),
		//[2] id : ~A // t.request_id,
		let content_len := geti2(p),
			padding_len := geti(p),
			reserved := getc(p),
			b := blob!()
		in (//[2] content_len : ~A // content_len,
			//[2] padding_len : ~A // padding_len,
			//[2] reserved : ~A // reserved, 
			if (content_len > 0) decode_content(p,t,content_len),			
			if (padding_len > 0) (
				fread(p,padding_len),
				//[2] padding read
			) else //[2] no padding
			),
		//[1]  ==> ~S // t,
		add(FCGI_RECORDS, t),
		t)]

[decode_records_ok(p:port) : void
-> while (
	//[1] decode_records...,
	when t := decode_record(p) in (process(p,t)) else true) (none)]

[decode_records(p:port) : void
-> //[1] decode_records(~S) // p,
	while (when t := decode_record(p) in (process(p,t)) else true) (none)]


CGI_HOST:string := ""
CGI_SOCKET:string := ""
CGI_PORT:integer := 0




[create_server() : listener
->	if (CGI_HOST != "" & CGI_PORT > 0) server!(CGI_HOST, CGI_PORT, 10)
	else if (CGI_PORT > 0) server!(CGI_PORT)
	else if (CGI_SOCKET != "") server!(CGI_SOCKET)
	else (
		CGI_SOCKET := "/tmp/" /+ last(explode(getenv("_"),"/")) /+ ".sock",
		//[0] use socket ~S // CGI_SOCKET,
		server!(CGI_SOCKET))]

/* Server */
[serve() : void
->	//[0] server pid: ~S // getpid(),
	let s := create_server()
	in (while true (
			if (forker?())
				(
				//[0] wait child,
				waitpid(-1))
			else (
				let c := accept(s)
				in (//[0] accept,
					decode_records(c),
					send_reponse(c),
					//[0] end process,
					flush(c),
					fclose(c),
					//[0] exit,
					exit(0)))))]


[option_respond(self:{"-fastcgi"},l: list) : void -> serve()]

[option_respond(self:{"-cgi-socket"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	CGI_SOCKET := l[1],
	l << 1)]

[option_respond(self:{"-cgi-port"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	CGI_PORT := integer!(l[1]),
	l << 1)]


[decode_content(p:port,self:fcgi_record,len:integer)
->	//[1] unknown content ~S // self,
	fread(p,len)]

/*
typedef struct {
            unsigned char roleB1;
            unsigned char roleB0;
            unsigned char flags;
            unsigned char reserved[5];
        } FCGI_BeginRequestBody;
 */
[decode_content(p:port,self:fcgi_begin_request,len:integer)
->	//[1] decode_content@fcgi_begin_request ~S   len: ~A // self , len,
	if (len = 8)
		(	self.role := geti2(p),
			self.flags := geti(p),
			fread(p,5), // reserved
			//[3] role:  ~A // self.role,
			//[3] flags: ~A // self.flags
				)]


[decode_content(p:port,self:fcgi_params,len:integer)
->	//[2] decode_content@fcgi_params ~S   len: ~A // self , len,
	if (len > 0) (
		self.values := cgi_tuples(p,len),
		//[3] values : ~S // self.values
	) else (
		//[3] no values
		)]
[decode_content(p:port,self:fcgi_stdin,len:integer)
->	//[2] decode_content ~S // self,
	let b := blob!() in 
	(
		freadwrite(p,b,len),
		self.datas := b
	)]


/* run permission */
passwd <: import()
(c_interface(passwd, "struct passwd *"))
[getpwnam(username:string) : passwd -> function!(getpwnam)]

[init_user(username:string) : void ->
	//[-100] == Change privilege for user ~A // username,
	let pw := getpwnam(username)
	in (if externC("(pw == NULL ? CTRUE : CFALSE)", boolean)
			externC("Cerrorno(74,_string_(\"getpwnam\"),0)"),
		if externC("(setgid(pw->pw_gid) ? CTRUE : CFALSE)", boolean)
			externC("Cerrorno(74,_string_(\"setgid\"),0)"),
		if externC("(setuid(pw->pw_uid) ? CTRUE : CFALSE)", boolean)
			externC("Cerrorno(74,_string_(\"setuid\"),0)"))]
		
option_respond(self:{"-cgi-user"},l: list) : void ->
	(if not(l) invalid_option_argument(),
	init_user(l[1]),
	l << 1)


[process(p:port,self:fcgi_record) : boolean
-> //[0] process ~S // self,
	fcgi_request_id := self.request_id,
	true]

request_count:integer := 0
[process(p:port,self:fcgi_stdin) : boolean
-> //[0] process ~S ~S // self, get(datas,self),
	known?(datas,self)]

/*	let pp := record_port!(p),
		old_p := use_as_output(pp)
	in (pp.request_id  := fcgi_request_id,
			//[0] Send content ..,
			request_count :+ 1,
			fwrite("content-type: text-plain\n\n",pp), 
			fwrite("coucou coucou \n",pp),
			printf("id request ~A \n",fcgi_request_id),
			printf("n request ~A \n",request_count),
			for r in FCGI_RECORDS
			(
				printf("~S\n",r),
				if (r % fcgi_params)
				(
					when vals := get(values,r)
					in for i in vals printf("~S : ~S \n",i[1],i[2])),
				if (r % fcgi_stdin)
				(
					when d := get(datas,r) in freadwrite(r.datas,cout())
				)
			),
			for i in (1 .. 1000)
			(
				printf("~A ~A\n",i, make_string(100,'X'))
			),

			//[0] end request ..,
			flush(pp),
			fclose(pp),

			use_as_output(old_p),
			true)]
*/
[send_reponse(p:port) : void
->	let pp := record_port!(p),
		old_p := use_as_output(pp)
	in (
		pp.request_id  := fcgi_request_id,
			//[0] Send content ..,
		request_count :+ 1,
		fwrite("content-type: text-plain\n\n",pp), 
		fwrite("coucou coucou \n",pp),
		printf("id request ~A \n",fcgi_request_id),
		printf("n request ~A \n",request_count),
		for r in FCGI_RECORDS
		(
			printf("~S\n",r),
			if (r % fcgi_params)
			(
				when vals := get(values,r)
				in for i in vals printf("~S : ~S \n",i[1],i[2])),
			if (r % fcgi_stdin)
			(
				when d := get(datas,r) in freadwrite(r.datas,cout())
			)
		),
		
		for i in (1 .. 1000)
		(
			printf("~A ~A\n",i, make_string(100,'X'))
		), 
		flush(pp),
		fclose(pp),
		use_as_output(old_p))]
