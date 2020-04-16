
//*********************************************************************
//* CLAIRE                                            Sylvain Benilan *
//* cgi.cl                                                            *
//* Copyright (C) 2000 - 2004 xl. All Rights Reserved                 *
//*********************************************************************

// @presentation
// The Wcl module defines an HTTP derived handler suitable for serving
// dynamic content over the web in the CLAIRE language. Wcl handles
// tracing support in CGI environment, manages client sessions
// and provides an on-page reporting for errors issued by scripts.
// It also handles the interface the mod_wcl Apache 2.x module and
// describes how to configure the Apache web server.
// @presentation

// @author Sylvain BENILAN


// @cat mod_wcl Apache 2.x module configuration
// Communications between the Apache 2.x web server and a Web CLAIRE
// agent goes through the mod_wcl Apache 2.x module that requires
// to be configured in the Apache configuration syntax. The mod_wcl
// module understands a set of directives used to configure one or
// multiple Web CLAIRE services. mod_wcl supports per-directory
// configurations, also it's a good habbit to define a Web CLAIRE
// service inside a location block, for instance if we have a single
// service we may define our mod_wcl directives in a location block
// bound to the root path of the server :
// \code
// <location />
// 	mod_wcl directives ...
// </location>
// \/code
// The minimal configuration consists in two directives, first we need the
// WclCommand directive that specifies the path of the binary executable
// of our service including command line options, this binary have to be compiled 
// with the module Wcl which, in order to behave as expected, should be launched with
// the -wcl option,
// on the other hand we have to specify a (wildcard) filter for the set of files
// that are handled by our service (usualy *.wcl that specifies that we handle
// all files with extension wcl) :
// \code
// <location />
// 	WclCommand /path/of/the/binary -wcl
// 	WclFileFilter *.wcl
// </location>
// \/code
// The file filter is necessary since mod_wcl is declared as a 'really first'
// apache module. Such modules have an opportunity to perform task
// as soon as a request is handled by apache. This is a requirement for our
// architecture because we have to properly handle session ID that we appear
// on the URL when session_url is used, the session ID have to
// be removed from the request URI in an early step such, for instance, images
// can be handled normaly by apache.\br
// Then we may define some user environment variables with the following
// directive :
// \code
// WclUserEnv ENV_VAR_NAME env_var_value
// \/code
// These environment variables will be added to the CGI (like) environment in which
// the service is launched (they will be available from the service via
// getenv("ENV_VAR_NAME")).\br
// We may also specify the name of a file that is taken a the default one when
// none are specified, this is done with the WclDefaultIndex directive. It allows
// the generation of an index page in a dynamic flavor without the need of an existing file :
// \code
// WclDefaultIndex name_of_default_index
// \/code
// mod_wcl will set the request URI to this file if none is actualy requested.
// For instance, the default Web CLAIRE configuration installed by the 
// webclaire package specifies 'inspect.wcl' as the default index. Notice that such handling
// can only be made by a compiled handler.\br
// When we use sessions from our service (that is our service calls session_url or
// session_cookie) we have to specify a directory where
// session files are saved, optionaly we can specify a session name that will be used
// to generate the session file name :
// \code
// WclSessionName NAME_OF_THE_SESSION
// WclSessionPath /path/to/session_folder
// \/code
// We may also specify a path where trace lines resulting of a script execution are saved
// (each request appends its trace to the file) :
// \code
// WclTraceFile /path/to/trace_file
// \/code
// Last some configuration paths can be specifies using environment variables that when used
// will be substituted by the environment variable value. The substitution environment includes
// variables defined with WlcUserEnv directive. The paths that are subject to subtitution are :
// \ul
// \li WclCommand
// \li WclSessionPath
// \li WclTraceFile
// \li WclUploadPath
// \/ul
// For instance the following configuration is valid :
// \code
// WclUserEnv HOME_DIR /path/to/custom/root_folder
// WclUserEnv SERVICE_BINARY the_name_of_my_binary
// WclCommand $(HOME_DIR)/path/to/$(SERVICE_BINARY)
// \/code
// For instance, it would be verry kind if we could have a per-client trace file. Such a
// configuration is possible using environment subtitution as in :
// \code
// WclTraceFile /path/to/trace_folder/$(REMOTE_ADDR).trace
// \/code
// @cat

// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: wcl_handler                                             *
// *   Part 2: environment substitution                                *
// *   Part 3: cmdline option                                          *
// *   Part 4: session id managment                                    *
// *********************************************************************


// *********************************************************************
// *   Part 1: wcl_handler                                             *
// *********************************************************************

wcl_report_item <: ephemeral_object()
	wcl_parent_report_item <: wcl_report_item(report:blob)
	wcl_child_report_item <: wcl_report_item(childok?:boolean, child_socket:socket)


wcl_handler <: Http/http_handler(
					//<sb> tell weither wcl_main has been called
					wcl_main_called?:boolean = false,
					//<sb> amount of time spent to handle the request
					// note: setup at metatLoad, reset as soon as a
					// a child is created
					request_real_time:float = timer!(),
					//<sb> session related stuff
					session_id:string = "",
					claire/session_url?:boolean = false,
					claire/session_started?:boolean = false,
					session_locked?:boolean = false,
					session_locked_file:port = stdout,
					cookie_path:string = "/",
					cookie_date:float,
					//<sb> session variables
					registered_objects:table = make_table(string,any,false),
					registered_object:set[string],
					registered_tree_object:set[string],
					//<sb> tell wheither the request is a soap request
					soap_request?:boolean = false,
					//<sb> a port where traces are redirected
					trace_file:port,
					//<sb> some debug bounds
					main_trace!:integer = 0,
					//maxdebug!:integer = -1,
					//<sb> the amount of unhandled exceptions
					// issued during the handling of the request
					script_error_count:integer = 0,
					//<sb> the stack of pending open files
					// see include @ string
					file_stack:list[port],
					//<sb> the compiled handler is an existing
					// restriction of load_wcl that matches
					// the requested file
					compiled_handler:restriction,
					//<sb> report trace and backtrace of exception
					// the report is appended on the page if at least
					// one error occur
					report:port,
					reports:list[wcl_report_item],
					//<sb> report child processes also
					last_pair:tuple(socket, socket),
					pid_path:string = string!(getpid()),
					child?:boolean = false,
					parent_socket:socket)



//<sb> this is the singleton handler for wcl engine
wcl_handler_instance :: wcl_handler(Http/low_output = stdout)
(time_set())

//<sb> @doc HTTP headers
// header(h) adds a custom HTTP header to the response. The specified header
// h should be a single line header without terminating CRLF. For instances :
// \code
// header("Some-Header: header-value")
// \/code
claire/header(h:string) : void -> header(wcl_handler_instance, h)

claire/script_error?() : boolean ->
	(wcl_handler_instance.script_error_count > 0)

claire/session_url?() : boolean ->
	wcl_handler_instance.session_url?

//<sb> @doc HTTP headers
// force_content_length() forces the response to contain a Content-Length
// HTTP header. The default for HTTP/1.1 client is to transfer the response
// by chunks (chunked coding transfer). This would be necessary for instance
// when sending an application/pdf content type response to a Win32 client that uses
// Internet Explorer, this browser has difficulties to transmit a chunked encoded
// response to the Adobe Acrobat plugin...
claire/force_content_length() : void ->
	force_content_length(wcl_handler_instance)

have_http_header_out?(self:string) : boolean ->
	Http/have_http_header_out?(wcl_handler_instance, self)

have_http_header_in?(self:string) : boolean ->
	Http/have_http_header_in?(wcl_handler_instance, self)


[apply_wcl_callback(self:method, val:any) : boolean ->
	let e := get(exception!,system)
	in (try
			try
				(//[-100] == Apply WCL callback ~S(~S) // self, val,
				apply(self, list(val)),
				//[-100] == WCL callback ~S(~S) applied // self, val,
				put(exception!, system, e),
				true)
			catch selector_error[selector = self.selector]
				(//[-100] == WCL callback ~S(~S) undefined // self, val,
				put(exception!, system, e),
				true)
		catch any
			(//[-100] == WCL callback ~S(~S) failed:\n~S // self, val, exception!(),
			if isenv?("WCL_DEBUG") close(exception!()),
			put(exception!, system, e),
			false))]


[apply_wcl_callback(self:property, val:any) : boolean ->
	let e := get(exception!,system)
	in (try
			try
				(//[-100] == Apply WCL callback ~S(~S) // self, val,
				apply(self, list(val)),
				//[-100] == WCL callback ~S(~S) applied // self, val,
				put(exception!, system, e),
				true)
			catch selector_error[selector = self]
				(//[-100] == WCL callback ~S(~S) undefined // self, val,
				put(exception!, system, e),
				false)
		catch any
			(//[-100] == WCL callback ~S(~S) failed:\n~S // self, val, exception!(),
			if isenv?("WCL_DEBUG") close(exception!()),
			put(exception!, system, e),
			false))]

[apply_wcl_callback(self:property, val1:any, val2:any) : boolean ->
	let e := get(exception!,system)
	in (try
			try
				(//[-100] == Apply WCL callback ~S(~S, ~S) // self, val1, val2,
				apply(self, list(val1, val2)),
				//[-100] == WCL callback ~S(~S, ~S) applied // self, val1, val2,
				put(exception!, system, e),
				true)
			catch selector_error[selector = self]
				(//[-100] == WCL callback ~S(~S, ~S) undefined // self, val1, val2,
				put(exception!, system, e),
				false)
		catch any
			(//[-100] == WCL callback ~S(~S, ~S) failed:\n~S // self, val1, val2, exception!(),
			if isenv?("WCL_DEBUG") close(exception!()),
			put(exception!, system, e),
			false))]


// *********************************************************************
// *   Part 2: environment substitution                                *
// *********************************************************************

//<sb> process some environment variable substitution
[substitute_cgi_env() : void ->
	for wclv in {"WCL_TRACE_FILE", "WCL_UPLOAD_FOLDER",
						"WCL_SESSION_PATH", "WCL_SAVE_REQUEST_PATH"}
		(if isenv?(wclv)
			let tf := getenv(wclv),
				p := 1, p1 := 1
			in (while (p := find(tf, "$(", p), 
						p1 := find(tf, ")", p),
						p > 0 & p1 > 0 & tf[p + 1] = '(')
					let v := substring(tf, p + 2, p1 - 1)
					in tf := replace(tf,"$(" /+ v /+ ")",getenv(v)),
				setenv(wclv /+ "=" /+ tf)))]


// *********************************************************************
// *   Part 3: cmdline option                                          *
// *********************************************************************


[option_usage(opt:{"-wcl"}) : tuple(string, string, string) ->
	tuple("Wcl srcipt",
			"-wcl [<file:path>]",
			"Load the requested wcl file. One may test a single wcl file " /+
			"by specifying a <file> argument unless PATH_TRANSLATED is defined " /+
			"in the environment. In the later case a CGI environment is assumed " /+
			"as built by the mod_wcl Apache 2.x module.")]

[option_respond(opt:{"-wcl"}, l:list) : void ->
	if (upper(getenv("HTTP_METHOD")) = "HEAD")
		(printf("Content-type: text/html\r\n"),
		printf("Content-length: 0\r\n\r\n"),
		exit(0)),
	if (l & not(isenv?("PATH_TRANSLATED")))
		let f := l[1]
		in (setenv("PATH_TRANSLATED=" /+ f),
			setenv("PATH_INFO=" /+ f),
			setenv("WCL_DEBUG=1"),
			setenv("WCL_AVOID_GZIP=1"))
	else ctrace() := null!(),
	try
		wcl_main()
	catch any
		printf("BAD: ~S\n", exception!()),
	exit(1)]


[option_usage(opt:{"-xwcl", "-xwcl?-?"}) : tuple(string, string, string) ->
	tuple("Wcl script",
			"{-xwcl | -xwcl<S:(0 .. 9)>-<W:(0 .. 9)>} <file:path>",
			"Load the wcl script <file>. A (unix) file may have execution rights and one " /+
			"can make a wcl script by adding as the first line of the script something like :\n" /+
			"  #!/usr/local/bin/claire -xwcl\n" /+
			"When <S> and <W> are specified they are used to inititalize CLAIRE memory (see option -s).")]

[option_respond(opt:{"-xwcl", "-xwcl?-?"}, l:list) : void ->
	if (upper(getenv("HTTP_METHOD")) = "HEAD")
		(printf("Content-type: text/html\r\n"),
		printf("Content-length: 0\r\n\r\n"),
		exit(0)),
	if not(l) invalid_option_argument(),
	let f := l[1]
	in (setenv("PATH_TRANSLATED=" /+ f),
		setenv("PATH_INFO=" /+ f),
		wcl_main())]  //<sb> no return

// *********************************************************************
// *   Part 4: session id managment                                    *
// *********************************************************************



//<sb> check for a session id on the URL or in a cookie
[setup_session_id_from_env(self:wcl_handler) : void ->
	let url_session := getenv("WCL_SESSION")
	in (if (length(url_session) = 26 & digit?(url_session))
			(self.session_id := url_session,
			self.session_url? := true)
		else
			let pi := getenv("PATH_INFO")
			in (when sid := some(sid in explode(pi,"/")|length(sid) = 26 & digit?(sid))
				in //<sb> a session id is present in the url !
					(setenv("WCL_SESSION=" /+ sid),
					self.session_id := sid,
					self.session_url? := true,
					let pt := getenv("PATH_TRANSLATED")
					in (pi := replace(pi, "/" /+ sid, ""),
						pt := replace(pt, *fs* /+ sid, ""),
						setenv("PATH_INFO=" /+ pi),
						setenv("PATH_TRANSLATED=" /+ pt),
						true))
				else let cookies := explode(getenv("HTTP_COOKIE"), ";")
					in (for c in cookies //<sb> look for a session id in HTTP cookies
							let t := explode(trim(c),"=")
							in (if (length(t) = 2 & t[1] = getenv("WCL_SESSION_NAME"))
									(setenv("WCL_SESSION=" /+ t[2]),
									self.session_url? := false,
									self.session_id := t[2])))))]


// *********************************************************************
// *   Part 7: trace file support                                      *
// *********************************************************************


//<sb> @doc Misceleanous
// die() properly aborts the execution of the script and exits. If a session
// has been started and no error where issued by the script then the session
// is saved.
[claire/die() : void ->
	//[-100] == Die called,
	dump_report(wcl_handler_instance),
	Http/terminate_http_response(wcl_handler_instance),
	terminate_wcl_response(wcl_handler_instance),
	exit(0)]


//<sb> look for a compiled responder for load_wcl for the given path
// info with a wildcard based dynamic dispacth. In the case where two
// or more restriction match, the longest one (i.e the more restrictive)
// apllies
[look_for_compiled_handler(pathinfo:string) : (method U {unknown}) ->
	let rlen := 0,
		candidate:(method U {unknown}) := unknown
	in (for restr in list{rx in claire/load_wcl.restrictions|
							length(rx.domain) = 1 & rx.domain[1] % set[string]}
			(for piw:string in restr.domain[1]
				(if (length(piw) > rlen &
						match_wildcard?(pathinfo, piw))
					(candidate := restr as method,
					rlen := length(piw)))),
		candidate)]



on_request_file_not_found :: property(open = 3)

requested_file_not_found <: exception(src:string)

[self_print(self:requested_file_not_found) : void ->
//	when x := wcl_handler_instance in x.Http/http_status_out := "404 File Not Found",
	if isenv?("WCL_DEBUG") printf("Requested file not found")]

//<sb> sets the working directory for the request execution
// and check that the requested file exists
[set_working_directory(self:wcl_handler) : void ->
	let path := getenv("PATH_TRANSLATED"),
		wd := substring(path, 1, rfind(path, *fs*))
	in (if self.soap_request?
			(//[-100] == Setting SOAP working directory [~A] // wd,
			try
				setcwd(wd)
			catch any
				(if self.soap_request?
					//[-100] == Note: failed to change working directory to ~A, continue [SOAP mode] // wd
				))
		else
			(//<sb> requested file not found
			if (unknown?(compiled_handler, self) & not(isfile?(path)))
				(if not(apply_wcl_callback(on_request_file_not_found, self))
					requested_file_not_found(src = path)),
			try (setcwd(wd),
				//[-100] == Setting working directory [~A] // wd
				)
			catch any
				(if known?(compiled_handler, self)
					//[-100] == Note: failed to change working directory to ~A, continue [Compile mode] // wd
				else close(exception!()))))]


on_http_header_sent(self:wcl_handler) : void ->
	apply_wcl_callback(on_http_header_sent, void)

//<sb> defined in Soap
handle_soap_message :: property(open = 3)

claire/wcl_startup :: property(open = 3)
claire/wcl_startup_completed :: property(open = 3)
claire/wcl_finish :: property(open = 3)
claire/soap_startup :: property(open = 3)
claire/soap_finish :: property(open = 3)

//<sb> entry point of the wcl_handler, the handler is initialized
// from a CGI-like environment. usualy such process is started by the apache
// server via the apache module mod_wcl (included in xlclaire distribution)
// and with the option -wcl given on the command line
[wcl_main() : void -> wcl_main(Core/Clib_stdin, stdout)]
[wcl_main(i:port, o:port) : void ->
	let wcl := wcl_handler_instance
	in (wcl.main_trace! := system.trace!,
		try
			(wcl.soap_request? := isenv?("HTTP_SOAPACTION"),
			wcl.wcl_main_called? := true,
			new_parent_report(wcl),
			wcl.Http/low_output := o, //<sb> setup by hand, used by fatal error handler
			substitute_cgi_env(),
			setup_session_id_from_env(wcl),
			setup_trace_file_from_env(wcl, o),
			Http/initialize_low_io(wcl, i, o),
			Http/initialize_from_cgi_env(wcl),
			put(compiled_handler, wcl,
					look_for_compiled_handler(getenv("PATH_INFO"))),
			set_working_directory(wcl),
			//[-100] == Wcl ready, output is ~S // cout(),
			try
				(apply_wcl_callback(wcl_startup, void),
				if (cout() != wcl)
					//[-100] == wcl_startup changed output: ~S // cout(),
				if wcl.soap_request?
					let soap_result := handle_soap_message(wcl)
					in (if parent_and_children_ok?(wcl)
						case soap_result
							(tuple
								(if (length(soap_result) = 2 & known?(soap_result[2]))
									(//[-100] == Soap call OK,
									Http/terminate_http_response(wcl),
									apply_wcl_callback(soap_finish, soap_result[1], soap_result[2]),
									terminate_wcl_response(wcl)))))
				else
					(handle_wcl_message(wcl),
					apply_wcl_callback(wcl_finish, void)))
			catch any wcl_error(wcl, true),
			if not(wcl.soap_request?) //<sb> Soap does reporting itself
				(terminate_wcl_response(wcl),
				dump_report(wcl)), //<sb> a report may be apended...
			Http/terminate_http_response(wcl))
		catch any
			(wcl_fatal_error(wcl),
			exit(1)),
		exit(0))]

(for r in wcl_main.restrictions
	Reader/NO_DEBUG_METHOD add r as method)

//<sb> called at request completion, session datas if any are saved on disk
// unless an error has occured during the request processing that may corrupt
// the session integrity, this is also convenient for a developper that has to
// reload a page that is often dirty during live edition
// Then close properly the trace file
[terminate_wcl_response(self:wcl_handler) : void ->
	if self.session_started?
		(if (self.script_error_count > 0)
			//[-100] == Session variable not saved due to script error(s)
		else claire/session_save()),
	close_trace_file(self)]
	

//<sb> does two things:
//		- applies ANY existing domain-compatible wcl_startup_completed restriction
//			(for instance to perform an automatic connection to a database)
//		- applies the matching load_wcl restriction which can be :
//			- a compiled restriction chosen with wildcard matching on the path info
//				(see look_for_compiled_include)
//			- the generic handler which attempt to load a file on disk by script name mathing
//				(see bellow)
[handle_wcl_message(self:wcl_handler) : void ->
	for r in list{r in wcl_startup_completed.restrictions|length(r.domain) = 1 & r.domain[1] = void}
		apply_wcl_callback(r, system),
	if known?(compiled_handler, self)
		apply(self.compiled_handler, list(getenv("PATH_INFO")))
	else
		load_wcl(getenv("PATH_TRANSLATED"))]

(Reader/NO_DEBUG_METHOD add (handle_wcl_message @ wcl_handler))


script_loader(self:string) : void => none

(inlineok?(script_loader @ string, "lambda[(self:string),none]"))

//<sb> load a srcipt in the same way as load @ string but unlike the
// standard claire load, load_wcl handles all errors internaly. In other
// words local errors are supported which is kind for HTML dev in the sense
// that element completions have a chance to occur.
[claire/load_wcl(self:string) : void ->
	Reader/reader_push(),
	write(Reader/index, reader, 1),
	write(Reader/maxstack, reader, 1),
	//[-100] >>>>>> Load script ~A >>>>>> // self,
	let f := fopen_source(self),
		start := mClaire/base!(),
		top := mClaire/index!(),
		*item* := unknown,
		fake_call := Call(script_loader, list<any>(self)),
		fake_lambda := script_loader.restrictions[1].formula,
		wcl := wcl_handler_instance,
		len := length(wcl.file_stack)
	in (wcl.file_stack :add f,
		mClaire/set_base(top),
		reader.Reader/fromp := f,
		reader.Reader/toplevel := false,
		try *item* := readblock(reader.Reader/fromp)
		catch any wcl_error(wcl, false),
		while not(*item* = EOF)
			(//[3] load_wcl -> ~S // *item*,
			mClaire/set_base(top),
			mClaire/index_jump(top + (reader.Reader/maxstack + 1)),
			if not(*item* % string)
				try
					(case *item*
						(Defclaire fake_lambda.body := *item*,
						any
							(if Language/DEBUG?
								fake_lambda.body := 
									Do(list(Call(Core/push_frame, list(script_loader @ string)),
										Call(Core/push_arg, list("path", self)),
										Reader/equip(*item*),
										Call(Core/pop_frame, list(system))))
							else fake_lambda.body := *item*)),
					fake_lambda.dimension := reader.Reader/maxstack + 1,
					eval(fake_call))
				catch any wcl_error(wcl, true),
			reader.Reader/index := 1,
		    reader.Reader/maxstack := 1,
		    mClaire/set_index(top),
		    mClaire/set_base(top),
			try
				*item* := readblock(reader.Reader/fromp)
			catch any wcl_error(wcl, false)),
		Reader/reader_pop(),
		shrink(wcl.file_stack, len),
		mClaire/set_base(start),
		mClaire/set_index(top),
		//[-100] <<<<<< Script ~A loaded <<<<<< // self,
		fclose(f))]

(Reader/NO_DEBUG_METHOD add (load_wcl @ string))

//<sb> @doc Subscripts
// include(self) is the generic way (instead of calling load_wcl) to load
// sub-scripts. self is the path of the loaded subscript it is relative
// to the path of the main script.
[claire/include(self:string) : void ->
	try
		when candidate := look_for_compiled_handler(self)
		in (//[-100] >>>>>> Load compiled script ~A >>>>>> // self,
			apply(candidate, list(self)),
			//[-100] <<<<<< Compiled script ~A loaded <<<<<< // self
			)
		else load_wcl(self)
	catch any wcl_error(wcl_handler_instance, true)]

(Reader/NO_DEBUG_METHOD add (include @ string))


// *********************************************************************
// *   Part 6: wcl fork interface                                      *
// *********************************************************************


//<sb> before the fork we flush the current datas
// to avoid duplicates
[on_fork() : void ->
	let wcl := wcl_handler_instance
	in (if wcl.wcl_main_called?
			(flush(wcl),
			if isenv?("WCL_DEBUG")
				wcl.last_pair := socketpair()))]

//<sb> after the fork cleanup the child
[on_forked(is_child?:boolean) : void ->
	let wcl := wcl_handler_instance
	in (if wcl.wcl_main_called?
			(if is_child?
				(externC("ClAlloc->numGC = 0"), //<sb> reset GC count for child
				wcl.request_real_time := timer!(), //<sb> reset the request duration of the child
				time_get(),
				time_set(),
				wcl.script_error_count := 0,
				let fs := wcl.file_stack,
					rs := Reader/READER_STACK
				in (//<sb> it is necessary to reopen script files descriptors
					// because they are shared by the parent and the child
					// which would make the reader crazy
					for i in (1 .. length(fs))
						let f := fs[i],
							d := Core/get_device(f)
						in (fs[i] := reopen(f),
							if (Core/get_device(reader.Reader/fromp) = d)
								reader.Reader/fromp := fs[i],
							when r := some(r in rs | Core/get_device(r.Reader/fromp) = d)
								in r.Reader/fromp := fs[i],
							fclose(f))),
				if isenv?("WCL_DEBUG")
					(for r in wcl.reports
						case r
							(wcl_child_report_item
								fclose(r.child_socket),
							wcl_parent_report_item
								fclose(r.report)),
					shrink(wcl.reports, 0),
					new_parent_report(wcl),
					wcl.parent_socket := wcl.last_pair[1],
					fclose(wcl.last_pair[2])),
				Http/terminate_http_forked(wcl),
				wcl.pid_path :/ string!(getpid()),
				//[-100] == Child ~S forked // getpid(),
				wcl.child? := true)
			else
				(//[-100] == Fork called (child ~S created) // forked(),
				if isenv?("WCL_DEBUG")
					(fclose(wcl.last_pair[1]),
					add_child_report(wcl, wcl.last_pair[2])))))]

