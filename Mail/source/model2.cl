
//*********************************************************************
//* CLAIRE                                            Sylvain Benilan *
//* model.cl                                                          *
//* Copyright (C) 2005 xl. All Rights Reserved                        *
//*********************************************************************


//**********************************************************************
// *   Part 1: model                                                   *
// *   Part 2: API                                                     *
// *   Part 3: MIME headers                                            *
// *   Part 4: Printing                                                *
// *   Part 5: SMTP                                                    *
// *   Part 6: Reading                                                 *
//**********************************************************************

// @author Sylvain Benilan

// @presentation
// The Mail module provide an API to generate and send email on the fly.
// @presentation

//**********************************************************************
// *   Part 1: model                                                   *
//**********************************************************************

// @cat Class model
// An email object is described by parts organised into a hierarchy.
// The email class contain a mainpart slot that can be used to inspect
// the part hierarchy. Parts are either single (singlepart) providing
// a data slot of type port or multiple (multipart) providing a subparts
// slot containing children parts. All parts have their own mime headers
// that are handled with the bracket notation. For instance here is a
// simple method that dumps the part hierarchy of a message :
// \code
// dump_parts(e:Mail/email) : void ->
// 	dump_parts(e.Mail/mainpart, "")
//
// dump_parts(p:Mail/singlepart, indent:string) : void ->
// 	printf("~ASingle part (~A)\n", indent, e["Content-Type"])
//
// dump_parts(p:Mail/multipart, indent:string) : void ->
// 	printf("~AMulti part (~A)\n~I", e["Content-Type"],
// 		for sp in p.Mail/subparts
// 			dump_parts(sp, indent /+ " "))
// \/code
// @cat

part <: ephemeral_object

part <: ephemeral_object(
			parentpart:part,
			mime_headers:list[string],
			old:port,
			data:port)

// @doc Class model
singlepart <: part()

// @doc Class model
multipart <: part(
				boundary:string,
				subparts:list[part])
	
// @doc Class model
email <: ephemeral_object(
			mainpart:part,
			pending_headers:list[string],
			currentpart:part)

(inverse(subparts) := parentpart)



//<sb> add a part to an email, update the current part
// when the added part is a multipart a new unique boundary
// string is created
[add_part(self:email, m:part, typepart:{"","related","mixed","alternative"}) : void ->
	if unknown?(mainpart, self)
		self.mainpart := m,
	if known?(currentpart, self)
		m.parentpart := self.currentpart,
	m.data := port!(),
	case m
		(multipart
			(m.boundary := typepart /+ "--" /+ uid(),
			m["Content-Type"] :=
				"multipart/" /+ typepart /+ ";\r\n\tboundary=\"" /+ m.boundary /+ "\"")),
	self.currentpart := m,
	for i in (1 .. length(self.pending_headers))
		(if (i mod 2 = 1)
			self[self.pending_headers[i]] := self.pending_headers[i + 1]),
	erase(pending_headers, self)]


[hostname() : string
-> let result:string  := "" in (
		externC("
		size_t len = 300;
		char *name = (char*)malloc(300);
		gethostname(name, len);
		result = copy_string1(name, strlen(name));
		"),
		result)]

//**********************************************************************
// *   Part 2: API                                                     *
//**********************************************************************

// @cat Creating new messages
// The mail module uses the object 'email' to represent an email
// message. The email! method family is used to create a new instance of
// email. For instance let's create a new message with a single recipient :
// \code
// msg :: Mail/email!("sbenilan@claire-language.com", "someone@somedomain.com")
// \/code
// Mail headers are handled using the bracket notation, for instance :
// \code
// (msg["Subject"] := "[claire] Mail module is quite nice")
// \/code
// Notice that by default headers "Mime-Version", "Date", "Message-ID",
// "X-Mailer" are set automatically.
// @cat


// @doc Creating new messages
email!() : email ->
	let e := email()
	in (e["Mime-Version"] := "1.0",
		e["Date"] := strftime("%a, %d %b %Y %H:%m:%S %Z", now()),
		e["X-Mailer"] := "CLAIRE v" /+ release() /+ ", Mail module " /+ Mail.version,
		e)

// @doc Creating new messages
email!(from:string) : email ->
	let e := email!()
	in (e["From"] := from,
		e)

// @doc Creating new messages
email!(from:string, to:string) : email ->
	let e := email!(from)
	in (e["To"] := to,
		e)

// @doc Creating new messages
email!(from:string, tos:subtype[string]) : email ->
	let e := email!(from)
	in (for to in tos
			e["To"] := to,
		e)

// @cat Creating new messages
// Once we have a message instance we may submit a content. The Mail module
// is intended to provide a convenient way for such a task and encourage
// the user to use the Wcl syntax within a redirection scope introduced by
// a balance usage of print_in_xxx/end_of_part methods. The end_of_part
// method would return a so called part object, the user should be
// familiar with the hierarchical structure of parts.\br
// In order to illustrate the usage of print_in_xxx/en_of_part here is a quite
// complete sample that creates a message embedding an attached document and
// composed of two alternatives, a plain text alternative and an HTML alternative
// that refers to an attached image :
// \code
// msg :: Mail/email!("sbenilan@claire-language.com", "someone@somedomain.com")
//
// (msg["Subject"] := "Annual activity report",  // fill in the subject
// Mail/print_in_related(msg),
// 
// 	Mail/print_in_alternative(msg), // we'll define both text and HTML alternative
//
// 		// the text alternative
// 		Mail/print_in_email(msg, "text/plain; charset=ISO-8859-1"),
// 		?>Dear collaborator, please consult our annual report attached to this message<?
// 		Mail/end_of_part(e),
// 
// 		// the HTML alternative with a logo image
// 		Mail/print_in_email(msg, "text/html; charset=ISO-8859-1"), 
// 		?><img src="cid:logo"><br>
// 		Dear collaborator,<br>
// 		please consult our annual report attached to this message<?
// 		Mail/end_of_part(msg),
// 
// 	Mail/end_of_part(msg),
// 	
// 	// here we attach the logo image
// 	let att := Mail/add_attachment(msg, "/path/to/logo.png", "image/png")
// 	in att["Content-ID"] := "logo",
//
// 	// here we attach the PDF document
// 	Mail/add_attachment(msg, "/path/to/annual_report.pdf", "application/pdf"),
// 
// Mail/end_of_part(msg))
// \/code
// @cat

[print_in_multipart(self:email, typepart:string) : multipart ->
	let m := multipart()
	in (add_part(self, m, typepart),
		m.old := use_as_output(m.data),
		m)]

// @doc Creating new messages
[print_in_related(self:email) : multipart -> print_in_multipart(self, "related")]
// @doc Creating new messages
[print_in_mixed(self:email) : multipart -> print_in_multipart(self, "mixed")]
// @doc Creating new messages
[print_in_alternative(self:email) : multipart -> print_in_multipart(self, "alternative")]

// @doc Creating new messages
[print_in_email(self:email, content-type:string) : singlepart ->
	print_in_email(self, content-type, "quoted-printable")]
// @doc Creating new messages
[print_in_email(self:email, content-type:string, content-transfer-encoding:string) : singlepart ->
	let m := singlepart()
	in (add_part(self, m, ""),
		m["Content-Type"] := content-type,
		m["Content-Transfer-Encoding"] := content-transfer-encoding,
		m.old := use_as_output(m.data),
		m)]


// @doc Creating new messages
[end_of_part(self:email) : void ->
	let x := self.currentpart
	in (use_as_output(x.old),
		put(currentpart, self, get(parentpart, x)))]



// @doc Creating new messages
// equivalent to add_attachment(self, src, fname, content-type) where fname
// has been constructed as the last path component of src.
[add_attachment(self:email, src:string, content-type:string) : singlepart ->
	let ps := rfind(src, *fs*)
	in add_attachment(self, src,
				(if (ps > 0) substring(src, ps + 1, length(src))
				else src), content-type)]

// @doc Creating new messages
// add_attachment returns a new part added to the given email.
// it is convenient for attached document or a related image.
// In the latter case a Content-ID header may be defined such to
// link related parts.\br
// A "Content-Disposition" header is automatically added
// to the attachment part and set as inline and specifying fname as the
// file name that should be used for the image.
[add_attachment(self:email, src:string, fname:string, content-type:string) : singlepart ->
	let f := fopen(src, "rb"),
		ps := rfind(src, *fs*),
		a := print_in_email(self, content-type, "base64")
	in (a["Content-Disposition"] := "inline; filename=\"" /+ fname /+ "\"",
		freadwrite(f, cout()),
		end_of_part(self),
		a)]


//<sb> API for reading various email adresses contained in the message
[get_from(self:email) : string ->
	let x := self["From"]
	in (if unknown?(x) error("Undefined MIME header 'From'"),
		extract_angular(x as string))]
[get_to(self:email) : set[string] ->
	when x := self["To"]
	in extract_contacts(x as string)
	else set<string>()]
[get_cc(self:email) : set[string] ->
	when x := self["Cc"]
	in extract_contacts(x as string)
	else set<string>()]

//<sb> read the subject line of an email
[get_subject(self:email) : tuple(string, string) ->
	let x := self["Subject"]
	in (if unknown?(x)
			error("The message has no subject"),
		extract_subject(x as string))]

//<sb> set the subject line of an email
[set_subject(self:email, subject:string) : void ->
	self["Subject"] := build_subject(subject)]
[set_subject(self:email, subject:string, enc:string) : void ->
	self["Subject"] := build_subject(subject, enc)]

//<sb> get parts base on a Content-Type wildcard (eg. 'image/*')
[get_part(self:email, ctw:string) : list[singlepart] ->
	let l := list<singlepart>()
	in (fill_part(self.mainpart, ctw, l),
		l)]

	[fill_part(self:multipart, ctw:string, l:list[singlepart]) : void ->
		for p in self.subparts
			fill_part(p, ctw, l)]
	
	[fill_part(self:singlepart, ctw:string, l:list[singlepart]) : void ->
		if match_wildcard?(self["Content-Type"], ctw)
			l add self]

//**********************************************************************
// *   Part 3: MIME headers                                            *
//**********************************************************************

//<sb> deal with the angular form of an header value (email addresse,
// message-id ...)
extract_angular(self:string) : string ->
	let p1 := find(self,"<"),
		p2 := find(self,">",p1)
	in (if (p1 > 0 & p2 > 0) substring(self, p1 + 1, p2 - 1)
		else self)

build_angular(self:string) : string ->
	(if match_wildcard?(self, "<*>") self
	else "<" /+ self /+ ">")


extract_contacts(self:string) : set[string] ->
	let s := set<string>()
	in (for c in explode(self, ",")
			s :add extract_angular(c),
		s)


build_contact_string(self:string) : string ->
	(if match_wildcard?(self, "*<*.*>*")
		build_contact_string(extract_angular(self))
	else
		(print_in_string(),
		printf("\"~A\" <~A>", self, self),
		end_of_string()))

build_contact_string(self:set[string]) : string ->
	let f? := true
	in (print_in_string(),
		for x in self
			(if f? f? := false else princ(",\r\n\t"),
			princ(build_contact_string(x))),
		end_of_string())

[get_header(l:list[string], h:string) : (string U {unknown}) ->
	let lh := lower(h)
	in when i := some(i in (1 .. length(l)) | i mod 2 = 1 & lower(l[i]) = lh)
		in l[i + 1] else unknown]


//<sb> read a subject line with an encoding according to RFC 4096.
[extract_subject(self:string) : tuple(string, string) ->
	let val := self,
		chs := "iso-8859-1"
	in (if match_wildcard?(self, "=#?*#??#?*#?=")
			let len := length(self),
				p? := rfind(self, "?", len - 2),
				enc := upper(substring(self, p? - 1, p? - 1)),
				p1? := find(self, "?", 3)
			in (val := substring(self, p? + 1, len - 2),
				chs := substring(self, 3, p1? - 1),
				case enc
					({"Q"} val := mime_decode(val),
					{"B"}
						let b64 := port!(val)
						in (print_in_string(),
							decode64(b64, cout()),
							val := end_of_string(),
							fclose(b64)))),
		tuple(val, chs))]

[build_subject(self:string) : string -> build_subject(self, "iso-8859-1")]
[build_subject(self:string, chs:string) : string ->
	if match_wildcard?(self, "=#?*#??#?*#?=") self
	else "=?" /+ chs /+ "?Q?" /+ mime_encode(self) /+ "?="]

[insert_header(l:list[string], h:string, val:string) : void ->
	let lh := lower(h)
	in when i := some(i in (1 .. length(l)) | i mod 2 = 1 & lower(l[i]) = lh)
		in (case lh
				({"from"} l[i + 1] := build_contact_string(val),
				{"message-id"} l[i + 1] := build_angular(val),
				{"to", "cc"}
					let s := extract_contacts(val)
					in l[i + 1] := build_contact_string(s),
				{"subject"}
					l[i + 1] := build_subject(val),
				any l[i + 1] := val))
		else (l :add h,
				case lh
					({"from"} l :add  build_contact_string(val),
					{"message-id"} l :add  build_angular(val),
					{"to", "cc"}
						let s := extract_contacts(val)
						in l :add  build_contact_string(s),
					{"subject"}
						l :add  build_subject(val),
					any l :add  val))]


[nth=(self:email, h:string, val:subtype[string]) : void ->
	nth=(self, h, build_contact_string(set!(val)))]

[nth=(self:email, h:string, val:string) : void ->
	if unknown?(mainpart, self)
		insert_header(self.pending_headers, h, val)
	else nth=(self.mainpart, h, val)]
[nth=(self:part, h:string, val:string) : void ->
	insert_header(self.mime_headers, h, val)]


[nth(self:email, h:string) : (string U {unknown}) ->
	if unknown?(mainpart, self) get_header(self.pending_headers, h)
	else nth(self.mainpart, h)]
[nth(self:part, h:string) : (string U {unknown}) ->
	get_header(self.mime_headers, h)]



//**********************************************************************
// *   Part 4: Printing                                                *
//**********************************************************************


[print_headers(self:part) : void ->
	for i in (1 .. length(self.mime_headers))
		(if (i mod 2 = 1)
			printf("~A: ~A\r\n", self.mime_headers[i], self.mime_headers[i + 1])),
	princ("\r\n")]

[print_content(self:singlepart, escapedot?:boolean) : void ->
	set_index(self.data, 0),
	case self["Content-Transfer-Encoding"]
		({"quoted-printable"}
			let p := self.data
			in (if escapedot? princ(mime_encode(replace(fread(p),"\r\n","\n")))
				else while not(eof?(p))
					let l := freadline(p, "\r\n")
					in (//<sb> when a line of the body contains a dot
						// at the begining of the line, this dot should
						// be doubled (undoubled by the SMTP server)
						if (left(l, 1) = ".") princ("."),
						princ(mime_encode(l)),
						if not(eof?(p))
							princ("\r\n"))),
		{"base64"}
			encode64(self.data, cout(), 80),
		any freadwrite(self.data, cout()))]

[print_part(self:singlepart, escapedot?:boolean) : void ->
	print_headers(self),
	print_content(self, escapedot?),
	printf("\r\n")]


[print_part(self:multipart, escapedot?:boolean) : void ->
	print_headers(self),
	for ct in self.subparts
		(printf("--~A\r\n", self.boundary),
		print_part(ct, escapedot?)),
	printf("--~A--\r\n", self.boundary)]

[print_email(self:email, escapedot?:boolean) : void ->
	print_part(self.mainpart, escapedot?)]
	

//**********************************************************************
// *   Part 5: SMTP                                                    *
//**********************************************************************

// @cat Sending message through SMTP
// Once a message has been properly filled we may send the message through
// SMTP using the smtp_send method. Unless smtp_from is specified the "From"
// header of the message will be used to identify the sender with the SMTP
// server. For instance :
// \code
// (Mail/send(msg, "mailhost.somedomain.com"))
// \/code
// @cat

[smtp_check_result(p:port) : string ->
	let l := freadline(p)
	in (//[2] smtp_check_result : ~S // l,
		if not(left(l, 3) % {"250", "252", "220", "354"})
			error("SMTP error : ~A", l),
		if (length(l) > 3 & l[4] = '-') smtp_check_result(p)
		else l)]

[smtp_check_ok(p:port) : boolean ->
	let l := freadline(p)
	in (left(l, 3) % {"250", "252", "220", "354"})]


[smtp_command(self:string, p:port) : string ->
	//[2] smtp_command( ~S , ~S) // self,p,
	fwrite(self, p),
	fwrite("\r\n", p),
	smtp_check_result(p)]

// @doc Sending message through SMTP
[smtp_send(self:email, smtp_server:string) : void -> smtp_send(self, smtp_server, self["From"])]
// @doc Sending message through SMTP
[smtp_send(self:email, smtp_server:string, smtp_from:string) : void -> smtp_send(self, smtp_server, self["From"], self["To"])]

// @doc Sending message through SMTP
[smtp_send(self:email, smtp_server:string, smtp_from:string, smtp_to:string) : void ->
	let c := client!(smtp_server,25)
	in (smtp_check_result(c),
		if (isenv?("SMTP_AUTH")) (
			smtp_command("EHLO " /+ hostname(), c),
			let (usr,pass) := explode(getenv("SMTP_AUTH"),":") in smtp_command_auth_plain(usr,pass,c))
		else  smtp_command("HELO " /+ hostname(), c),
		smtp_command("MAIL FROM: <" /+ smtp_from /+ ">", c),
		when tos := smtp_to
		in for to in extract_contacts(tos)
			smtp_command("RCPT TO: <" /+ to /+ ">", c)
		else error("Undefined email recipients"),
		smtp_command("DATA", c),
		let op := use_as_output(c)
		in (print_email(self, true),
			use_as_output(op)),
		smtp_command(".\r\nQUIT\r\n", c),
		fclose(c))]



[smtp_command_auth_plain(usr:string,pass:string,p:port) : string ->
	let tmp := port!()
	in (
		
/*		smtp_command("AUTH PLAIN",p),
		smtp_check_result(p), */
		//[2] send auth ...,
		fwrite(usr, tmp),
		fwrite("\0", tmp),
		fwrite(usr, tmp),
		fwrite("\0", tmp),
		fwrite(pass, tmp),

		fwrite("AUTH PLAIN ", p),
		encode64(tmp,p,76),
		fwrite("\r\n", p),
		smtp_check_result(p))]

[smtp_send(self:email, smtp_server:string, smtp_from:string, usr:string,pass:string) : void ->
	let c := client!(smtp_server,25)
	in (smtp_check_result(c),
		smtp_command("EHLO " /+ hostname(), c),
		smtp_command_auth_plain(usr,pass,c),
		smtp_command("MAIL FROM: <" /+ smtp_from /+ ">", c),
		when tos := self["To"]
		in for to in extract_contacts(tos)
			smtp_command("RCPT TO: <" /+ to /+ ">", c)
		else error("Undefined email recipients"),
		smtp_command("DATA", c),
		let op := use_as_output(c)
		in (print_email(self, true),
			use_as_output(op)),
		smtp_command(".\r\nQUIT\r\n", c),
		fclose(c))]

		/*
[smtp_command_starttls(c) : void
->	//[2] smtp_command_starttls( ~S , ~S) // self,p,
	fwrite("STARTTLS\r\n", c),
	if (smtp_check_ok(c)) (
		let dev := Openssl
		
		)
*/


[smtp_send(self:email, smtp_server:string, smtp_from:string, usr:string,pass:string,smtpport:integer) : void ->
	let c := client!(smtp_server,smtpport)
	in (smtp_check_result(c),
		smtp_command("EHLO " /+ hostname(), c),
		smtp_command_auth_plain(usr,pass,c),
		smtp_command("MAIL FROM: <" /+ smtp_from /+ ">", c),
		when tos := self["To"]
		in for to in extract_contacts(tos)
			smtp_command("RCPT TO: <" /+ to /+ ">", c)
		else error("Undefined email recipients"),
		smtp_command("DATA", c),
		let op := use_as_output(c)
		in (print_email(self, true),
			use_as_output(op)),
		smtp_command(".\r\nQUIT\r\n", c),
		fclose(c))]




[verify(smtp_server:string, smtp_from:string) : string ->
	let c := client!(smtp_server,25),
		rc := ""
	in (smtp_check_result(c),
		smtp_command("HELO server", c),
		rc := smtp_command("VRFY <" /+ smtp_from /+ ">", c),
		fclose(c),
		rc)]

//**********************************************************************
// *   Part 6: Reading                                                 *
//**********************************************************************

// @cat Reading rough message
// The Mail module also provide a way to create a message from a rough
// content that should be supplied (as a readable port) to email!. One
// can inspect message headers using bracket notation and also inspect its
// parts with the email object.
// @cat

//<sb> construct a new email from a message that can be
// read on the given port

// @doc Reading rough message
email!(p:port) : email -> email(mainpart = parse_part(p))


//<sb> read a list of MIME header, stop at the first empty
// header line. take care of headers that span multiple lines
[header_lines(p:port) : list[string] ->
	let l := list<string>()
	in (if not(while not(eof?(p))
			let ln := freadline(p)
			in (if (length(ln) = 0) break(true),
				l :add ln))
			error("Premature end of file while reading email's MIME headers"),
		let i := 2
		in while (i <= length(l))
			(if (left(l[i], 1) % {" ", "\t"})
				(l[i - 1] :/+ "\r\n" /+ l[i],
				nth-(l, i))
			else i :+ 1),
		l)]

extract_boundary(self:string) : string ->
	(if not(match_wildcard?(self, "*boundary=\"*\"*"))
		error("Failed to extract boundary in MIME header ~S", self),
	let b := find(self, "boundary=\"") + 10
	in substring(self, b, find(self, "\"", b) - 1))

//<sb> parse a single part of the input message. A part is made of
// an header block and a body. A part may have sub-parts (recursive).
// the header block is interpreted and the values of the Content-Type
// and Content-Transfert-Encoding drives the parsing.
// By default the content type is assumed to be text/plain.
parse_part(p:port) : part ->
	let hl := header_lines(p),
		ct := some(l in hl | find(lower(l), "content-type:") = 1)
	in (if unknown?(ct)
			(ct := "Content-type: text/plain",
			hl add ct as string),
		let pp := (if (find(ct, "multipart/related") > 0 |
						find(ct, "multipart/alternative") > 0 |
						find(ct, "multipart/mixed") > 0)
					multipart(boundary = extract_boundary(ct))
				else singlepart())
		in (for h in hl
				let pdot := find(h, ":"),
					hv := substring(h, 1, pdot - 1),
					v := trim(substring(h, pdot + 1, length(h))) 
				in pp[hv] := v,
			case pp
				(multipart
					let br := Http/boundary_reader!(p, "--" /+ pp.boundary)
					in (while not((Http/reach_boundary(br),
									Http/last_boundary?(br)))
							pp.subparts :add parse_part(br),
						fclose(br)),
				singlepart
					(case pp["Content-Transfer-Encoding"]
						({"quoted-printable"}
							pp.data := port!(mime_decode(fread(p))),
						{"base64"}
							(pp.data := port!(),
							decode64(p, pp.data)),
						any
							(pp.data := port!(),
							freadwrite(p, pp.data))))),
			pp))


