



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

RequestBody <: ephemeral_object()


fcgi_request_id:integer := 0

fcgi_context <: ephemeral_object()
fcgi_record <: ephemeral_object(
	vers:integer,
	kind:integer,
	request_id:integer,
	body:RequestBody)

fcgi_begin_request       <: fcgi_record(role:integer,flags:integer)
fcgi_abort_request       <: fcgi_record()
fcgi_end_request         <: fcgi_record()
fcgi_params              <: fcgi_record(values:list[tuple])
fcgi_stdin               <: fcgi_record()
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

[decode_record(p:port) : fcgi_record
->	//[1] decode_record,
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
		t)]

[decode_records(p:port) : void
-> while (
	//[1] decode_records...,
	when t := decode_record(p) in process(p,t) else true) (none)]


[serve() : void
->	let s := server!(1212)
	in (while true (
			let c := accept(s)
			in (//[0] accept, 
				decode_records(c),
				//[0] end process
				)))]


/* request body */

EmptyBody <: ephemeral_object()



[decode_content(p:port,self:fcgi_record,len:integer)
->	//[0] unknown content ~S // self,
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
			//[2] role:  ~A // self.role,
			//[2] flags: ~A // self.flags
				)]


[decode_content(p:port,self:fcgi_params,len:integer)
->	//[1] decode_content@fcgi_params ~S   len: ~A // self , len,
	if (len > 0) (
		self.values := cgi_tuples(p,len),
		//[2] values : ~S // self.values
	) else (
		//[1] no values
		)]



[option_respond(self:{"-fastcgi"},l: list) : void -> serve()]


[process(p:port,self:fcgi_record) : boolean
-> //[0] process ~S // self,
	fcgi_request_id := self.request_id,
	true]

request_count:integer := 0
[process(p:port,self:fcgi_stdin) : boolean
-> //[0] process ~S // self,
	let pp := record_port!(p),
		old_p := use_as_output(pp)
	in (pp.request_id  := fcgi_request_id,
			//[0] Send content ..,
			request_count :+ 1,
			fwrite("content-type: text-plain\n\n",pp), 
			fwrite("coucou coucou \n",pp),
			printf("id request ~A \n",fcgi_request_id),
			printf("n request ~A \n",request_count),
			//[0] end request ..,
			use_as_output(old_p),
			fclose(p),
			false)]

