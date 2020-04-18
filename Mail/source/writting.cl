/*	File : writting.cl email protocol
	Module : Mail general mail purpose
	expert-solutions SARL
	Xavier Pechoultres
	
	1. Writting email
*/

TRACE_WRITE_API :: 0
TRACE_WRITE_KGB :: 0
//-------------------------------------------------------------------------
// 		1.	Writting email
//-------------------------------------------------------------------------*/
/*
// write an email into a port
[fwrite(self:email,p:port) : port
->	//[TRACE_WRITE_API]  fwrite(self,port),
	for h in tolist(self._headers)
		(if (h[2] != "") fwrite_header(h[1],h[2],p)),

	fwrite_header("Mime-Version: ","1.0",p),
	fwrite_header("X-Mailer: ","Claire Mail v" /+ Mail.version,p),
	fwrite_header("Content-Type: ",get_content_type(self),p),
	fwrite_header("","",p),
	fwrite_bodies(self,p),
//	fwrite_attachments(self,p),
	p]
*/
[write(self:email_base,p:port) : port
->	//[TRACE_WRITE_API]  fwrite(self,port),
	case length(self._sub_contents) (
		{0} (if known?(_body,self) (
				write_headers(self,p),
				write_body(self,p))),
		{1} (write_headers(self,p),
			write(self._sub_contents[1],p)),
		any (
			if unknown?(_boundary,self) self._boundary := uid(),
			write_headers(self,p),
			for i in self._sub_contents (
				write_boundary(self._boundary,p),
				write(i,p)),
			write_end_boundary(self._boundary,p))),
				
	p]


[write_headers(self:email_base,p:port) : void
->	//[TRACE_WRITE_API]  write_headers(self,port),
	if known?(_boundary,self) (
		if (substring(self._headers["content-type"],"boundary",true) > 0) (
			let contenttype := ""
			in (for i in explode(self._headers["content-type"],";") (
					if (substring(i,"boundary",true) > 0)
						contenttype :/+ ("boundary=" /+ self._boundary /+ "; ")
					else contenttype :/+ (i /+ "; ")),
				self._headers["content-type"] := contenttype))
		else (
			self._headers["content-type"] := self._headers["content-type"] /+ "; boundary=" /+ self._boundary)),
	for i in tolist(self._headers)
		write_header(i[1],i[2],p),
	fwrite("\r\n",p)]

[write_header(head:string,data:string,p:port) : void
->	//[TRACE_WRITE_API]  write_header(self,data,port),
	fwrite(head,p), fwrite(": ",p), fwrite(data,p) , fwrite("\r\n",p)]

[write_header(head:string,p:port) : void
->	//[TRACE_WRITE_API]  write_header(head,port),
	fwrite(head,p), fwrite(": ",p), fwrite("\r\n",p)]

[write_body(self:email_base,p:port) : void
->	//[TRACE_WRITE_API]  >>>> write_body(email_base,port) ~S // self._headers["content-type"],
	fwrite("\r\n",p),
	if known?(_body,self) (
		if check_header_value?(self,"Content-Transfer-Encoding",ENCODING_TEXT) (
			//[MAIL_0] -------- WRITING ~S // ENCODING_TEXT,
			rwport_encode(self._body,p,ENCODING_TEXT))
		else if check_header_value?(self,"Content-Transfer-Encoding",ENCODING_BINARY) (
			//[MAIL_0] -------- WRITING ~S // ENCODING_BINARY,
			rwport_encode(self._body,p,ENCODING_BINARY))
		else (
			//[MAIL_0] -------- WRITING BINARY,
			rwport(self._body,p))),
	fwrite("\r\n\r\n",p),
	//[TRACE_WRITE_API]  <<<<< write_body(email_base,port)
	]

[write_boundary(self:string,p:port) : void
->	fwrite("\r\n--",p),
	fwrite(self,p),
	fwrite("\r\n",p)]

[write_end_boundary(self:string,p:port) : void
->	fwrite("\r\n--",p),
	fwrite(self,p),
	fwrite("--\r\n",p)]
	

[mwrite(self:list[email_base], into:string) : void
->	setcwd(into),
	let id := 0 in
		for i in self
			let	f := fopen(string!(id :+ 1) /+ ".eml","w")
			in 	(write(i,f),
				fclose(f))]

//-------------------------------------------------------------------------
// 		2.	Utilitaires Ports
//-------------------------------------------------------------------------

[private/rwport(from:port,to:port) : void
=>	while not(eof?(from)) from > to]

[private/rwport(from:port,to:port,encoding:string) : void
=>	while not(eof?(from)) from > to]


[private/rwport(from:port,to:port,encoding:{ENCODING_TEXT}) : void
->	let tmp := ""
	in	while ((tmp := fread(from,1024)) != "") fwrite(mime_encode(tmp),to)]

/*
[private/rwport(from:port,to:port,encoding:{ENCODING_BINARY}) : void
->	let tmp := ""
	in	while ((tmp := fread(from,1024)) != "") fwrite(encode64(tmp),to)]
*/

[private/rwport_decode(from:port,to:port,encoding:{ENCODING_TEXT}) : void
->	let tmp := ""
	in	while ((tmp := fread(from,1024)) != "") fwrite(mime_decode(tmp),to)]



[private/rwport_decode(from:port,to:port,encoding:{ENCODING_BINARY}) : void
->	decode64(from,to)]
/*	let tmp := ""
	in	while ((tmp := fread(from,1024)) != "") fwrite(decode64(tmp),to)] */

[private/rwport_encode(from:port,to:port,encoding:{ENCODING_TEXT}) : void
->	let tmp := ""
	in	while ((tmp := fread(from,1024)) != "") fwrite(mime_encode(tmp),to)]

[private/rwport_encode(from:port,to:port,encoding:{ENCODING_BINARY}) : void
->	encode64(from,to,76)]

