



// *********************************************************************
// *   Part 2: tools                                             *
// *********************************************************************


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

CGI_HOST:string := ""
CGI_SOCKET:string := ""
CGI_PORT:integer := 0

record_port <: filter

// *********************************************************************
// *   Part 2: tools                                             *
// *********************************************************************

fcgi_record <: ephemeral_object(
	vers:integer,
	kind:integer,
	request_id:integer)

fcgi_begin_request       <: fcgi_record(role:integer,flags:integer)
fcgi_abort_request       <: fcgi_record()
fcgi_end_request         <: fcgi_record()
fcgi_params              <: fcgi_record()
fcgi_stdin               <: fcgi_record(final?:boolean = false)
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
		p.request_id := geti2(p),
		t.request_id := p.request_id,
		//[2] id : ~A // t.request_id,
		let content_len := geti2(p),
			padding_len := geti(p),
			reserved := getc(p),
			b := blob!()
		in (//[2] content_len : ~A // content_len,
			//[2] padding_len : ~A // padding_len,
			//[2] reserved : ~A // reserved, 
			decode_content(p,t,content_len),			
			if (padding_len > 0) (
				fread(p,padding_len),
				//[2] padding read
			) else //[2] no padding
			),
		//[1]  ==> ~S // t,
		add(FCGI_RECORDS, t),
		t)]


[decode_records(p:port) : void
-> //[1] decode_records(~S) // p,
	while (when t := decode_record(p) in (process(p,t)) else true) (none)]






[option_respond(self:{"-fastcgi"},l: list) : void -> serve()]
[option_usage(opt:{"-fastcgi"}) : tuple(string, string, string) ->
	tuple("Start FastCgi server",
			"-fastcgi",
			"Star a FastCgi server. Default create a socket name /tmp/<processname>.sock. " /+
			"Use -cgi-socket or -cgi-port change connection mode")]

[option_respond(self:{"-cgi-socket"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	CGI_SOCKET := l[1],
	l << 1)]
[option_usage(opt:{"-cgi-socket"}) : tuple(string, string, string) ->
	tuple("Setting socket file",
			"-cgi-socket <socket_path:string>",
			"Create a socket file a specified path fo incoming connexion. If not specified use default socket.")]

[option_respond(self:{"-socket"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	CGI_SOCKET := l[1],
	l << 1)]
[option_usage(opt:{"-socket"}) : tuple(string, string, string) ->
	tuple("Setting socket file",
			"-socket <socket_path:string>",
			"Create a socket file a specified path fo incoming connexion. If not specified use default socket.")]


[option_respond(self:{"-cgi-port"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	CGI_PORT := integer!(l[1]),
	l << 1)]
[option_usage(opt:{"-cgi-port"}) : tuple(string, string, string) ->
	tuple("Setting listening port",
			"-cgi-port <port:integer>",
			"Setting listening port. If not specified socket mode.")]

[decode_content(p:record_port,self:fcgi_record,len:integer)
->	//[1] unknown content ~S // self,
	if (len > 0) fread(p,len)]

/*
typedef struct {
            unsigned char roleB1;
            unsigned char roleB0;
            unsigned char flags;
            unsigned char reserved[5];
        } FCGI_BeginRequestBody;
 */
[decode_content(p:record_port,self:fcgi_begin_request,len:integer)
->	//[1] decode_content@fcgi_begin_request ~S   len: ~A // self , len,
	if (len = 8)
		(	p.role := geti2(p),
			p.flags := geti(p),
			fread(p,5), // reserved
			//[3] role:  ~A // p.role,
			//[3] flags: ~A // p.flags
				)]


[decode_content(p:record_port, self:fcgi_params, len:integer)
->	//[0] decode_content@fcgi_params ~S   len: ~A // self , len,
	if (len > 0) (
		for i in cgi_tuples(p,len) p.cgi_params[i[1]] := i[2]
		// self.values := cgi_tuples(p,len)
	) else (
		//[3] no values
		)]

[decode_content(p:record_port, self:fcgi_stdin, len:integer)
->	//[0] decode_content ~S len:~A // self, len,
	if (len > 0) (
		p.stdin? := true,
		if not(known?(cgi_stdin,p)) p.cgi_stdin := blob!(),
		freadwrite(p,p.cgi_stdin,len)
		 
	) else (
		//[0] ====== FINAL ,
		self.final? := true
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
[option_usage(opt:{"-cgi-user"}) : tuple(string, string, string) ->
	tuple("Return CGI Info (debug)",
			"-cgi-user <u:user>",
			"Run under specified user privilege.")]


[process(p:port,self:fcgi_record) : boolean
-> //[0] process ~S // self,
	true]

request_count:integer := 0
[process(p:port,self:fcgi_stdin) : boolean
-> //[0] process ~S  final? ~S // self, self.final?,
	not(self.final?)]

cgi_handler <: object(
	callback:property,
	callback_ctx:any,
	priority:integer = 10)

cgi_handlers:list[cgi_handler] := list<cgi_handler>()

[sort_cgi_handler(a:cgi_handler,b:cgi_handler) : boolean 
-> a.priority < b.priority]


[add_handler(p:property,ctx:any,prio:integer)
->	add(cgi_handlers,
		cgi_handler(callback = p , callback_ctx = ctx, priority = prio ))]

[reponse_mirror(pp:record_port,b:boolean) : void
-> 	fwrite("Content-Type: text/plain\r\n",pp),
	fwrite("\r\n",pp),
	when d := get(cgi_stdin,pp) in (
		//[0] wrote stdin to stdout ~Sb // length(d),
		let n := freadwrite(d,pp)
		in //[0] freadwrite(~S => ~S) = > ~Ab // d, pp , n
	) else (
		//[0] no input data
	)]



[option_respond(self:{"-cgi-mirror"},l: list) : void -> add_handler(reponse_mirror,true,15)]
[option_usage(opt:{"-cgi-mirror"}) : tuple(string, string, string) ->
	tuple("create a mirror cgi (debug)",
			"-cgi-mirror",
			"Add a simple FastCGI handler which resend the input request (mirror)")]


[reponse_info(pp:record_port,b:boolean) : void
->	random!(),
	let oldp := use_as_output(pp)
	in (	
		sleep(5000 + random(10000)),
		printf("content-type: text/plain\n\n"),

		printf("id request ~A \n",pp.request_id),
		printf("process id ~A \n",getpid()),
		///printf("n request ~A \n",request_count),
		printf("params ~S \n",pp.cgi_params),
		if (known?(cgi_stdin,pp ))
			printf("stdin : ~Ab\n",length(pp.cgi_stdin))
		else printf("stdin: empty"),
		
		use_as_output(oldp))]

[option_usage(opt:{"-cgi-info"}) : tuple(string, string, string) ->
	tuple("Return CGI Info (debug)",
			"-cgi-info",
			"Add a simple FastCGI handler which display some CGI data et request information")]

[option_respond(self:{"-cgi-info"}, l:list) : void -> add_handler(reponse_info,true,5)]



[option_respond(self:{"-cgi"},l: list) : void -> script()]
[option_usage(opt:{"-cgi"}) : tuple(string, string, string) ->
	tuple("run as classic cgi",
			"-cgi",
			"run as classic cgi script")]

 

[option_respond(self:{"-appConnTimeout"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	//[0] appConnTimeout,
	l << 1)]

[option_respond(self:{"-idle-timeout"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	//[0] idle-timeout,
	l << 1)]

[option_respond(self:{"-initial-env"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	//[0] initial-env,
	l << 1)]


[option_respond(self:{"-init-start-delay"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	//[0] init-start-delay,
	l << 1)]

[option_respond(self:{"-flush"},l: list) : void 
-> (// if not(l) invalid_option_argument(),
	//[0] flush,
	// l << 1
	none
	)]


[option_respond(self:{"-listen-queue-depth"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	//[0] init-start-delay,
	l << 1)]
[option_usage(opt:{"-listen-queue-depth"}) : tuple(string, string, string) ->
	tuple("listen-queue-depth",
			"-listen-queue-depth n (100)",
			"The depth of listen() queue (also known as the backlog) shared by all of the instances of this application. A deeper listen queue allows the server to cope with transient load fluctuations without rejecting requests; it does not increase throughput. Adding additional application instances may increase throughput/performance, depending upon the application and the host.
")]

[option_respond(self:{"-min-server-life"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	//[0] min-server-life,
	l << 1)]
[option_usage(opt:{"-min-server-life"}) : tuple(string, string, string) ->
	tuple("min-server-life",
			"-min-server-life n (30)",
			"The minimum number of seconds the application must run for before its restart interval is increased to 600 seconds. The server will get 3 tries to run for at least this number of seconds.
")]


[option_respond(self:{"-nph"},l: list) : void 
-> (//[0] -nph
	)]
[option_usage(opt:{"-nph"}) : tuple(string, string, string) ->
	tuple("nph",
			"-nph",
			"Instructs mod_fastcgi not to parse the headers. See the Apache documentation for more information about nph (non parse header) scripts.
")]

[option_respond(self:{"-pass-header"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	//[0] pass-header,
	l << 1)]
[option_usage(opt:{"-pass-header"}) : tuple(string, string, string) ->
	tuple("pass-header",
			"-pass-header header",
			"The name of an HTTP Request Header to be passed in the request environment. This option makes available the contents of headers which are normally not available (e.g. Authorization) to a CGI environment.")]


[option_respond(self:{"-port"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	//[0] port,
	CGI_PORT := integer!(l[1]),
	l << 1)]
[option_usage(opt:{"-port"}) : tuple(string, string, string) ->
	tuple("port",
			"-port n",
			"The TCP port number (1-65535) the application will use for communication with the web server. This option makes the application accessible from other machines on the network (as well as this one). The -socket and -port options are mutually exclusive.")]


[option_respond(self:{"-priority"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	//[0] priority,
	// CGI_PORT := integer!(l[1]),
	l << 1)]
[option_usage(opt:{"-priority"}) : tuple(string, string, string) ->
	tuple("priority",
			"-priority n",
			"The process priority to be assigned to the application instances (using setpriority()).")]


[option_respond(self:{"-processes"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	//[0] processes,
	// CGI_PORT := integer!(l[1]),
	l << 1)]
[option_usage(opt:{"-processes"}) : tuple(string, string, string) ->
	tuple("processes",
			"-processes n (1)",
			"The number of instances of the application to spawn at server initialization.")]

[option_respond(self:{"-restart-delay"},l: list) : void 
-> (if not(l) invalid_option_argument(),
	//[0] processes,
	// CGI_PORT := integer!(l[1]),
	l << 1)]
[option_usage(opt:{"-restart-delay"}) : tuple(string, string, string) ->
	tuple("restart-delay",
			"-restart-delay n (5 seconds)",
			"The minimum number of seconds between the respawning of failed instances of this application. This delay prevents a broken application from soaking up too much of the system.
")]

