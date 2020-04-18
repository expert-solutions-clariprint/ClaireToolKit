/*	File : smtp.cl SMTP protocol
	Module : Mail general mail purpose
	expert-solutions SARL
	Xavier Pechoultres
	
	1. Model
	2. Connection management
	3. General Information
	4. Mail management
	5. Error handling
	6. Utilities
*/

TRACE_SMTP :: -100
TRACE_SMTP_PRIVATE :: -100

//-------------------------------------------------------------------------
// 		1.	Model
//-------------------------------------------------------------------------
smtp_server <: ephemeral_object(
				_localhostname:string = "localhost",
				_hostname:string,
				_from:string,
				_port:integer = 25,
				_sock:port)



// global smtp error
smtp_error <: exception(comment:string = "unknown error")

[self_print(self:smtp_error) : void
-> printf("SMTP: ~S",self.comment)]

SMTP :: 0
//-------------------------------------------------------------------------
// 		2.	Connection management
//-------------------------------------------------------------------------
[smtp_connect(host:string,from:string,localname:string) : smtp_server
->	//[TRACE_SMTP] smtp_connect(~S,~S,~S) // host,from,localname,
	smtp_connect(smtp_server(_hostname = host,
							_from = from,
							_localhostname = localname))]

[smtp_connect(host:string,from:string) : smtp_server
-> //[TRACE_SMTP] smtp_connect(~S,~S) // host,from,
	smtp_connect(smtp_server(_hostname = host, _from = from))]

[smtp_connect(self:smtp_server) : smtp_server
->	//[TRACE_SMTP] smtp_connect(~S) // self,
	try (self._sock := client!(self._hostname,self._port),
		smtp_check_error(self._sock),
		smtp_command(self,"HELO ",self._localhostname),
		//[TRACE_SMTP] smtp_connect(~S) ... connected :) // self,
		self)
	catch socket_error
		(fclose(self._sock),
		//[TRACE_SMTP] smtp_connect(~S) ... unconnected :( // self,
		smtp_error(comment = "unable to connect server")),
	self]

[smtp_disconnect(self:smtp_server) : void
->	//[TRACE_SMTP] smtp_disconnect(~S) // self,
	smtp_command(self,"QUIT"),
	fclose(self._sock)]


[private/smtp_command(s:smtp_server, command:string) : string
->	smtp_command(s,command,"")]

[private/smtp_command(s:smtp_server, command:string, data:string) : string
->	//[TRACE_SMTP_PRIVATE] smtp_command ~S ~S // command, data,
	fwrite(command,s._sock),
	fwrite(data,s._sock),
	fwrite("\r\n",s._sock),
	smtp_check_error(s._sock)]

[private/smtp_header(s:smtp_server, head:string, data:string) : void
->	//[TRACE_SMTP_PRIVATE] smtp_header ~S ~S // head, data,
	fwrite(head,s._sock),
	fwrite(data,s._sock),
	fwrite("\r\n",s._sock)]

//-------------------------------------------------------------------------
// 		3.	 General Information
//-------------------------------------------------------------------------

//-------------------------------------------------------------------------
// 		4.	Mail management
//-------------------------------------------------------------------------



[smtp_send(self:smtp_server,to:list[string],msg:email_base) : void
->	//[TRACE_SMTP] smtp_send(~S , ~S , ~S) // self,to,msg,
	smtp_command(self,"MAIL FROM:", address!(self._from)),
	for i in to
		(let a := address!(i) in
			(if (find(a,"@") > 0) 
				smtp_command(self,"RCPT TO:", address!(i)))),

	smtp_command(self,"DATA "),
	write(msg,self._sock),
	smtp_command(self,"\r\n.")]

[smtp_send(smtp_host:string,
		smtp_account:string,
		domain:string,
		to:list[string],
		msg:email_base) : void
->	smtp_send(smtp_connect(smtp_host,smtp_account,domain),to,msg)]
		
	
//-------------------------------------------------------------------------
// 		5.	Error handling
//-------------------------------------------------------------------------
	
//		if (find(f,"-ERR") > 0) rmtp_error( comment = err),
//		f)]
	
	
[private/smtp_check_error(p:port) : string
->	//[TRACE_SMTP_PRIVATE] smtp_check_error(~S) // p,
	let f := get_line(p)
	in (//[SMTP] checkError ~S // f,
		let res := explode(f," ")
		in (case integer!(res[1]) (
				{354} none,
				{220} none,
				{221} none,
				{250} none,
				
				any smtp_error(comment = res[1])),
			f))]


//-------------------------------------------------------------------------
// 		6.	Utilities
//-------------------------------------------------------------------------


[private/address!(self:string) : string
->	//[TRACE_SMTP_PRIVATE] address!(~S) // self,
	let i := find(self,"<"),
		j := find(self,">",i)
	in (if (j > 0 & i > 0)
			substring(self, i, j)
		else ("<" /+ self /+ ">"))]



/*
[private/format_address(self:string) : string
-> if 
*/
/*
[smtp_send(self:smtp_server,mail:email,from:string,to:list[string]) : void
->	
[sendMail(smtp_server:string,from:string,to:string,subject:string,body:string) : void
-> sendMail(smtp_server,from,list(to),list(),subject,body)]

[sendMail(smtp_server:string,from:string,to:list[string],headers:list[string], subject:string,body:string) : void
->	let c := client!(smtp_server,25),
		reponse := ""
	in (smtp_comm
		send(c,"HELO server \r\n"),
		reponse := recv(c),
		//[0] ~S // reponse,
		send(c,"MAIL FROM: <" /+ from /+ ">\r\n"),
		reponse := recv(c),
		//[0] ~S // reponse,
		for i in to
			send(c,"RCPT TO: <" /+ i /+ ">\r\n"),
		reponse := recv(c),
		//[0] ~S // reponse,

		send(c,"DATA \r\n"),
		send(c,"MIME-Version: 1.0\r\n"),
	
//		send(c,"Return-ID: 12340\r\n"),
//		send(c,"References: 12340\r\n"),

//		send(c,"Content-Type: text/plain; charset=ISO-8859-1; format=flowed\r\n"),
		send(c,"Content-Transfer-Encoding: quoted-printable\r\n"),
		for h in headers (
			fwrite(h,c),
			fwrite("\r\n",c)),
		send(c,"FROM: " /+ from /+ "\r\n"),
		send(c,"SUBJECT: "),
		send(c,mime_encode(subject)),
		send(c,"\r\n"),

		reponse := send(c,mime_encode(body)),
		//[0] ~S // reponse,
		send(c,"\r\n.\r\n"),
		send(c,"QUIT \r\n"),
		fclose(c))] 

[sendMail(smtp_server:string,from:string,to:list[string],msg:email) : void
-> sendMail(smtp_server,from,to,msg,list())]


[sendMail(smtp_server:string,from:string,to:list[string],msg:email,heads:list[tuple(string,string)]) : void
-> 	let c := client!(smtp_server,25),
		reponse := ""
	in (send(c,"HELO server \r\n"),
		reponse := recv(c),
		//[0] ~S // reponse,
		send(c,"MAIL FROM: <" /+ from /+ ">\r\n"),
		reponse := recv(c),
		//[0] ~S // reponse,
		for i in to
			send(c,"RCPT TO: <" /+ i /+ ">\r\n"),
		reponse := recv(c),
		//[0] ~S // reponse,

		send(c,"DATA \r\n"),
		if (getHeader(msg,"from") = "") (
			send(c,"FROM: "),
			send(c,from),
			send(c,"\r\n")),
		send(c,"SUBJECT: "),
		if known?(eSubject,msg)
			send(c,msg.eSubject)
		else 
			send(c,getHeader(msg,"subject")),
		send(c,"\r\n"),
		if (getHeader(msg,"Reply-To") = "") (
			send(c,"Reply-To: "),
			send(c,from),
			send(c,"\r\n")
		),
		for i in  heads (
			send(c,i[1]),
			send(c,": "),
			send(c,i[2]),
			send(c,"\r\n")),

		for i in  msg.eHeaders (
			send(c,i[1]),
			send(c,": "),
			send(c,i[2]),
			send(c,"\r\n")),

		send(c,"\r\n"),
		;for i in (1 .. length(msg.eBody))
		;	putc(msg.eBody[i],c),
		let len := length(msg.eBody), i := 1
		in (while (i <= len)
			let n := min(i + 1024, len)
			in (fwrite(mime_encode(substring(msg.eBody,i, n)), c),
				i := n + 1)),
		send(c,"\r\n.\r\n"),
		send(c,"QUIT \r\n"),
		fclose(c))] 
*/