
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * model.cl                                                          *
// * Copyright (C) 2005 xl. All Rights Reserved                        *
// *********************************************************************


// @presentation
// The module Http defines the a low level handler for HTTP protocol in a
// CGI environment. It defines various filters for handling encoding in such
// environment (chunked encoding, gzip response, content length spying, boundrary reading).
// The Http module also defines the $, $key and $value table that are filled
// with form datas, it manages application/x-www-form-urlencoded and
// multipart/form-data protocols.
//
// V1.1 Add better support for some Http 1.1 feature as 100 continue.
// @presentation

 
// ***************************************************************************
// * part 1: http_handler                                                    *
// ***************************************************************************

//<sb> both read and write ends of an http handler have
// its own filter chain and therefore implemented has devices
http_end <: device( source:port)


// <xp> the output filter have a pointer to the input for checking 
// potential http command like 100 continue or abort
http_output <: http_end(input_device:device)


eof_port?(self:http_end) : boolean -> eof_port?(self.source)

flush_port(self:http_end) : void -> flush_port(self.source)

read_port(self:http_end, buf:char*, len:integer) : integer ->
	read_port(self.source, buf, len)

write_port(self:http_end, buf:char*, len:integer) : integer ->
	write_port(self.source, buf, len)

//<xp> output buffer check input for continue or abort http command
// Todo : best management when connexion must abort (zera lenth chunk .. see HTTP RFC)
pwrite_port(self:http_output, buf:char*, len:integer) : integer ->
	(//[2] write_port(~S, ~S, ~S) // self,buf,len,
	if not(self.input_device.source % descriptor)
		//[1] ***** warning input devise is not a descriptor !!!,
	read!(self.input_device.source),
	write!(self.input_device.source),
	if (select?())
		(if (readable?(self.input_device.source) & not(eof?(self.input_device.source))) (
			//[1] ***** Warning : we got input data ..,
			if parse_continue_header?(self.input_device.source) //[1] continue .. OK
			else //[1] ***** Warning the connexion must be aborted
			),
		write_port(self.source, buf, len))
	else (
		//[1] ***** Warning select?() return false,
		0))

// <xp> Add support for receiving header during the sending process.
// clean connection stop is to do.
[parse_continue_header?(self:port) : boolean
->	//[1] << parse_continue_header? : receive http header on ~S // self,
	let head := freadline(self),
		lhead := lower(head),
		heads := list<string>(),
		continue? := true,
		first? := true
	in (while (head != "") (
			if first?  continue? := match_wildcard?(lhead, "http/1.? 1?? continue")
			else heads add head,
			head := freadline(self.source)),
		continue?)]


[apply_callback(self:property, val:any) : void ->
	let start := mClaire/index!()
	in (mClaire/push!(val),
		let m := find_which(self, start, owner(val))
		in (if (case m (method m.domain[1] != void))
				(//[-100] == Apply HTTP callback ~S(~S) // m, val,
				try
					(eval_message(self, m, start, false),
					//[-100] == HTTP callback ~S(~S) applied // m, val
					)
				catch any
					//[-100] == HTTP callback ~S(~S) failed:\n~S // m, val, exception!()
				)
			else
				//[-100] == HTTP callback ~S(~S) undefined // self, val
			))]


//<sb> handler for (a subset of) the HTTP/1.1 protocol that
// handles the HTTP layer of a message
http_handler <: device(
				//<sb> low level input and output (e.g socket, stdout ...),
				low_input:port,
				low_output:port,
				
				//<xp> to be used for server mode.
				is_server?:boolean = false,
				http_method:string = "",	// filled by parse_input if is_server?
				http_url:string = "",
				http_version:string = "HTTP/1.1",

				//<sb> redirected input and output (e.g gziper, buffer ...)
				input:port,
				output:port,
				http_status_in:string,
				http_status_out:string,
				headers_in:list[string],
				headers_out:list[string],
				headers_out_sent?:boolean = false,
				content-length?:boolean = false,
				force-content-type-html?:boolean = false,
				output_gizped?:boolean = false,

				is_client?:boolean = false)
	

flush_port(self:http_handler) : void ->
	(if known?(output, self) flush_port(self.output))

write_port(self:http_handler, buf:char*, len:integer) : integer ->
	(if (len > 0)
		(if not(self.headers_out_sent?)
			//<sb> send HTTP response headers prior to write out the
			// first byte of the response.
			ensure_http_headers_sent(self),
		//[4] write_port@http_handler(~S) on ~S // string!(buf, len), self.output,
		write_port(self.output, buf, len))
	else 0)


eof_port?(self:http_handler) : boolean -> eof_port?(self.input)

read_port(self:http_handler, buf:char*, len:integer) : integer ->
	read_port(self.input, buf, len)

close_port(self:http_handler) : void -> (none)


[http_handler!(io:port) : http_handler -> http_handler!(io, io)]
[http_handler!(i:port, o:port) : http_handler ->
	let http := http_handler()
	in (initialize_low_io(http, i , o),
		http)]

[initialize_low_io(self:http_handler, i:port, o:port) : void ->
	if isenv?("WCL_WATCH_IO")
		(//<sb> when defined, save IO messages on disk for debug purpose
		// note : files are opened unbuffered !
		let watch_in := html_watcher!(i, getenv("WCL_WATCH_IO") /+ ".in"),
			watch_out := html_watcher!(o, getenv("WCL_WATCH_IO") /+ ".out")
		in (self.low_input := watch_in,
			self.low_output := watch_out,
			printf(watch_in.watch_file, "==========================================================\n"),
			printf(watch_in.watch_file, "  Input message dump ~A\n", strftime("%c", now())),
			printf(watch_in.watch_file, "  Input is ~S\n", i),
			printf(watch_in.watch_file, "==========================================================\n"),
			printf(watch_out.watch_file, "===========================================================\n"),
			printf(watch_out.watch_file, "  Output message dump ~A\n", strftime("%c", now())),
			printf(watch_out.watch_file, "  Output is ~S\n", o),
			printf(watch_out.watch_file, "===========================================================\n")))
	else
		(self.low_input := i,
		self.low_output := o),
	self.input := http_end(source = self.low_input),
	self.output := http_output(
						input_device = self.input,
						source = self.low_output)]


// ***************************************************************************
// * part 2: response HTTP headers                                           *
// ***************************************************************************

claire/on_http_header_sent :: property(open = 3)

claire/header(self:http_handler, h:string) : void ->
	(if self.headers_out_sent?
		error("HTTP headers already sent, cannot add header ~A", trim(h)),
	let heads := self.headers_out,
		len := length(heads),
		nh := lower(explode(h, ": ")[1] /+ ":")
	in (if not(for i in (1 .. len)
				let hh := heads[i]
				in (if (find(lower(hh), nh) = 1)
						(heads[i] := trim(h),
						break(true))))
			heads add trim(h)))

claire/header(head:string) : void ->
	let p := Core/get_device(cout())
	in (case p
			(http_handler header(p, head),
			any error("Missing HTTP handler for header ~S", head)))

get_http_header_out(self:http_handler, h:string) : (string U {unknown}) ->
	some(hh in self.headers_out | find(lower(hh), lower(h)) = 1)

have_http_header_out?(self:http_handler, h:string) : boolean ->
	exists(hh in self.headers_out | find(lower(hh), lower(h)) = 1)

get_http_header_in(self:http_handler, h:string) : (string U {unknown}) ->
	some(hh in self.headers_in | find(lower(hh), lower(h)) = 1)


have_http_header_in?(self:http_handler, h:string) : boolean ->
	exists(hh in self.headers_in | find(lower(hh), lower(h)) = 1)

//<sb> called once at the first write attempt and ensure
// that HTTP headers are sent prior to the response body.
// note that the headers are written on the low level output
// and that the ouput filter is built
ensure_http_headers_sent(self:http_handler) : void ->
	(if not(self.headers_out_sent?)
		(self.headers_out_sent? := true,
		//[-100] == Send HTTP headers on ~S : // self.low_output,
		if known?(http_status_out, self)
			(//[-100] ~A // self.http_status_out,
			printf(self.low_output, "~A\r\n", self.http_status_out)),
		if not(self.content-length?)
			(if not(have_http_header_out?(self, "Content-type"))
				(//[-100] Content-Type: text/html (default),
				printf(self.low_output, "Content-Type: text/html\r\n"))),

		//<sb> deal with cache and proxy. since page are generated
		// dynamicaly we need to avoid caching of these pages
		if not(have_http_header_out?(self, "Content-type"))
			(//<sb> When no-cache is specified IE doesn't cache
			// the page which cause an issue whith the acrobat IE
			// plugin, so avoid the cache header for content other
			// than HTML...
			if not(have_http_header_out?(self, "Pragma"))
				(//[-100] Pragma: no-cache (default),
				printf(self.low_output, "Pragma: no-cache\r\n")),
			if not(have_http_header_out?(self, "Cache-Control"))
				(//[-100] Cache-Control: no-cache (default),
				printf(self.low_output, "Cache-Control: no-cache, no-store, must-revalidate, no-transform, max-age=0, private \r\n")))
		else if not(have_http_header_out?(self, "Expires"))
			(//[-100] Expires: 0 (default),
			printf(self.low_output, "Expires: 0\r\n")),

		//<sb> deal with the content encoding (compressed pages)
		if not(have_http_header_out?(self, "Accept-Encoding"))
			(//[-100] Accept-Encoding: gzip (default),
			printf(self.low_output, "Accept-Encoding: gzip\r\n")),
		for h in self.headers_out
			(if not(self.content-length? & find(lower(h), "content-type:") = 1)
				(//[-100] ~A // h,
				printf(self.low_output, "~A\r\n", h))),
		self.output := byte_counter!(self.output),

		//<sb> deal with the body length (content-length vs. chunked)
		if (self.content-length?)
			(//[-100] == Did not send all HTTP headers, waiting for content length ...,
			self.output := blob!())
		else if (getenv("SERVER_PROTOCOL") = "HTTP/1.0")
			(self.content-length? := true,
			//[-100] == Did not send all HTTP headers due to HTTP/1.0 client, waiting for content length ...,
			self.output := blob!())
		else if (self.is_client?)
			(
			self.output := chunker!(buffer!(self.output, 4096)),
			printf(self.low_output, "Transfer-Encoding: chunked\r\n"),
			//[-100] is client,
			//[-100] Transfer-Encoding: chunked,
			//[-100] == HTTP headers sent,
			printf(self.low_output, "\r\n"))
		else (
//			self.output := chunker!(buffer!(self.output, 4096)),
//			printf(self.low_output, "Transfer-Encoding: chunked\r\n"),
//			//[-100] Transfer-Encoding: Apache !,
			//[-100] == HTTP headers sent,
			printf(self.low_output, "\r\n")),
			
		if self.output_gizped?
			self.output := buffer!(Zlib/gziper!(self.output), 4096),
		//[-100] == Output redirected on ~S // self.output,
		flush(self.low_output),
		apply_callback(on_http_header_sent, self)))


[claire/force_content_length(self:http_handler) : void ->
	if not(self.content-length?)
		(if self.headers_out_sent?
			error("force_content_length(~S) failed, HTTP headers already sent", self),
		//[-100] == force_content_length(~S), output is ~S // self, cout(),
		self.content-length? := true)]

[send_http_response(self:http_handler,status:integer) : void ->
	self.http_status_out := "HTTP/1.1 " /+ string!(status) /+ " " /+ Http/status_message(status)]

[status_message(self:integer) : string
->  case self
		({200} "OK",
		{201} "Created",
		{202} "Accepted",
		{204} "No Content",
		{301} "Moved Permanently",
		{302} "Found",
		{304} "Not Modified",
		{400} "Bad Request",
		{401} "Unauthorized",
		{403} "Forbidden",
		{404} "Not Found",
		{500} "Internal Server Error",
		{501} "Not Implemented",
		{502} "Bad Gateway",
		{503} "Service Unavailable",
		any "Unknown Status")]


// ***************************************************************************
// * part 3: httd_filter from CGI env                                        *
// ***************************************************************************

// @cat Maximun POST size
// @section Request input processing
// As a security concern, we may define the environment variable WCL_MAX_POST
// that specifies a maximun size in mega-octet for POST data. When this variable
// is specified the request input processor checks that the length of the input
// message is lesser than the specified maximun POST size and raise an error
// otherwise.
// @cat

//<sb> use this to initialize the handler from the environment (CGI).
// such environment is created by the HTTP server (e.g. apache + mod_wcl)
// Note: the input is parsed such to read a www-form url encoded
[initialize_from_cgi_env(self:http_handler) : void ->
	//<sb> check the length of the input POST message
	if (integer!(getenv("CONTENT_LENGTH")) > 0)
		(if (isenv?("WCL_MAX_POST") &
				integer!(getenv("CONTENT_LENGTH")) >
					integer!(float!(getenv("WCL_MAX_POST")) * 1048576.0))
			error("POST size exceeds allowed max size of ~AMo", getenv("WCL_MAX_POST")),
		self.input := content_length_spy!(self.input))
	else if (getenv("HTTP_TRANSFER_ENCODING") = "chunked")
		self.input := chunker!(self.input)
	else //<sb> handles the query string for GET message
		self.input := blob!(getenv("QUERY_STRING")),
	//<sb> check the content of the input message
	if (find(getenv("HTTP_CONTENT_ENCODING"), "gzip") > 0)
		self.input := buffer!(Zlib/gziper!(self.input), 4096),
	handle_form_data_from_env(self),
	//<sb> set the content of the output message
	if isenv?("WCL_AVOID_GZIP")
		//[-100] == Avoid gzip compression due to env var WCL_AVOID_GZIP
	else if (find(upper(getenv("HTTP_USER_AGENT")), "MSIE") > 0)
		//[-100] == Avoid gzip compression for MSIE client on ~S // self
	else
		(
//		self.headers_out :add "Content-Encoding: gzip",
		self.headers_out :add "Accept-Encoding: gzip",
//		self.output_gizped? := true,
		none),
	use_as_output(self)]



// ***************************************************************************
// * part 4: httd_filter from input port                                     *
// ***************************************************************************

//
[parse_input(self:http_handler, raiseError:boolean) : port ->
	//[-100] == Parse HTTP headers on ~S // self,
	let head := freadline(self.low_input),
		lhead := lower(head),
		heads := self.headers_in,
		chunked? := false,
		contenlength := -1,
		compress? := false,
		first? := true,
		out := self
	in (while (length(head) > 0)
			(heads :add head,
			//[-100] header : ~A // head,
			if first?
				(//<sb> skip info header
				self.http_status_in := lhead,
				if (self.is_server?) (
					let status_line := explode(head, " ")
					in (if (length(status_line) < 3)
							error("http_parse_headers(~S) read a malformed status line [~A]", self, head),
						self.http_method := upper(status_line[1]),
						self.http_url := status_line[2],
						self.http_version := status_line[3],
						self.http_status_out := "HTTP/1.1 200 OK",
						//[-100] HTTP Method: ~A, URL: ~A, Version: ~A // self.http_method, self.http_url, self.http_version,
						first? := false))
				else (
					//[-100] first header : ~A // lhead,
					if not(match_wildcard?(lhead, "http/1.? 1?? continue"))
						first? := false,
					//<sb> expect a success header (2xx family)
					if (not(match_wildcard?(lhead, "http/1.? 2?? *")) & raiseError)
						error("http_parse_headers(~S) read an error status [~A]", self, head)					
					)),
			if (find(lhead, "content-encoding: ") = 1 & (find(lhead, "gzip") > 0 | find(lhead, "deflate") > 0))
				compress? := true
			else if (find(lhead, "transfer-encoding: ") = 1 & find(lhead, "chunked") > 0)
				chunked? := true
			else if (find(lhead, "content-length") = 1)
				let t := explode(lhead, ": ")
				in (if (length(t) > 1)
						contenlength := integer!(trim(t[2]))),
			head := freadline(self.low_input),
			lhead := lower(head),
			if eof?(self) error("http_parse_headers(~S) encountered a premature eof", self)),
		if chunked?
			self.input := chunker!(self.input)
		else if (contenlength > -1)
			self.input := content_length_spy!(self.input, contenlength),
		if compress?
			self.input := buffer!(Zlib/gziper!(self.input), 4096),
		self.input)]

//
[parse_input(self:http_handler) : port -> parse_input(self,true)]


// ***************************************************************************
// * part 5: termination                                                     *
// ***************************************************************************

on_http_response_done :: property(open = 3)

[close_http_filter_chain(self:http_handler) : void ->
	if known?(output, self)
		let p := Core/get_top_most(self.output)
		in while true
			(case p
				(Zlib/gziper
					(fclose(p),
					//[-100] == Compression: ~S% of initial size // Zlib/ratio(p)
					),
				byte_counter
					(fclose(p),
					//[-100] == ~S bytes sent // written_bytes(p)
					),
				http_end
					break(),
				blob
					(if self.force-content-type-html?
						(//[-100] == Force Content-Type: text/html,
						printf(self.low_output, "Content-Type: text/html\r\n"))
					else (when h := get_http_header_out(self, "Content-Type")
						in (//[-100] == Send ~A // h,
							printf(self.low_output, "~A\r\n", h))
						else
							(//[-100] == Send Content-Type: text/html,
							printf(self.low_output, "Content-Type: text/html\r\n"))),
					//[-100] == Send content length ~S // length(p),
					printf(self.low_output, "Content-Length: ~S\r\n\r\n", length(p)),
					freadwrite(p, self.low_output),
					fclose(p),
					break()),
				device break(),
				any fclose(p)),
			p := p.Core/target,
			self.output := p),
	self.output := null!()]

[terminate_http_response(self:http_handler) : void ->
	ensure_http_headers_sent(self),
	close_http_filter_chain(self),
	apply_callback(on_http_response_done, self),
	//[-100] == Close lowest output ~S // self.low_output,
	if (get(low_input,self) % html_watcher) // low_input may be unknown...
		fclose(self.low_input),
	if (self.low_output % html_watcher)
		(fclose(self.low_output),
		self.low_output := self.low_output.target),
	case self.low_output
		(socket linger(self.low_output),
		any fclose(self.low_output))]


[terminate_http_post(self:http_handler) : void ->
	ensure_http_headers_sent(self),
	close_http_filter_chain(self)]

//<sb> terminate_http_forked should be used from a
// process that have been forked, it will close
// the output end of the connection and sets the
// the output to a null port such the child can
// finish its job without interfere with parent output
[terminate_http_forked(self:http_handler) : void ->
	if known?(output, self)
		let p := Core/get_device(self.output)
		in (case p
				(http_end p.source := null!())),
	//[-100] == Close lowest output ~S of a forked process // self.low_output,
	fclose(self.low_output),
	self.low_output := null!(),
	self.headers_out_sent? := true]
	

// ***************************************************************************
// * part 6: doing GET/POST                                                  *
// ***************************************************************************

//<sb> extract components from an URL
explode_url(fullurl:string) : tuple(boolean, string, integer, string)
 -> let https? := match_wildcard?(fullurl, "https://*"),
 		http? := not(https?),
 		url := (if https? substring(fullurl, 9, length(fullurl))
 				else if match_wildcard?(fullurl, "http://*")
 					substring(fullurl, 8, length(fullurl))
               else fullurl),
        p := find(url, "/"),
        srv := (if (p = 0) url else substring(url, 1, p - 1)),
        f := (if (p = 0) "" else substring(url, p + 1, length(url))),
        tcpport := (let srvport := explode(srv,":") as list[string]
                   in (if (length(srvport) > 1)
                          (srv := srvport[1],
                          integer!(srvport[2]))
						else if https? 443
						else 80))
    in tuple(https?, srv, tcpport, "/" /+ f)


[http_get(self:port, server:string, f:string) : http_handler ->
	printf(self, "GET ~A HTTP/1.1\r\nHost: ~A\r\nUser-Agent: CLAIRE v~A, Http ~I\r\nAccept-Encoding: gzip\r\n\r\n",
					f, server, release(), Http.version),
	let http := http_handler!(self)
	in (parse_input(http),
		http)]



[http_get(url:string) : http_handler ->
	let (https?, s, p, f) := explode_url(url)
	in let c := (if https? Openssl/sclient!(s,p) else client!(s,p))
		in http_get(c, s, f)]


[initialize_http_post(url:string) : http_handler ->
	let (https?, s, p, f) := explode_url(url)
	in let c := (if https? Openssl/sclient!(s, p)
				else client!(s, p)),
		http := http_handler!(c)
	in (http.is_client? := true,
		http.http_status_out := "POST " /+ f /+ " HTTP/1.1",
		header(http, "User-Agent: CLAIRE v" /+ release() /+
									", Http module " /+ Http.version),
//		header(http, "Host: " /+ s /+ ":" /+ string!(p)),
		header(http, "Host: " /+ s),
		http)]


[set_auth(http:http_handler, login:string, passwd:string)
-> header(http, "Authorization: Basic " /+ encode64(login /+ ":" /+ passwd))]

