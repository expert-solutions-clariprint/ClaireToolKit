/*	File : model.cl email protocol
	Module : Mail general mail purpose
	expert-solutions SARL
	Xavier Pechoultres
	
	1. Model
	2. Creating email
	3. Utilities
*/
//-------------------------------------------------------------------------
// 		1.	Model
//-------------------------------------------------------------------------

email_base <: ephemeral_object

// root class for email management
email_base <: ephemeral_object(
				private/_id:integer,
				private/_size:integer,
				private/_boundary:string,
				private/_body:port,
				private/_body_printing_stack:list[email_base],
				private/_body_port_printing_stack:list[port],
				private/_attachments_content:list[string] = list<string>(),
				_headers:string_table,
				_sub_contents:list[email_base])

email <: email_base()
email_body <: email_base()
email_alternative <: email_base()
email_attachment <: email_base()

[close(self:email_base) : email_base
->	self._headers := make_string_table(""),
	self]

email_error <: exception(comment:string = "unknown error")

[self_print(self:email_error) : void
-> printf("MAIL: ~S",self.comment)]

ENCODING_TEXT :: "quoted-printable"
ENCODING_BINARY :: "base64"

MAIL_2 :: 2
MAIL_0 :: 0

//-------------------------------------------------------------------------
// 		2.	Creating Mail
//-------------------------------------------------------------------------

// Adding a body
[print_in_body(self:email,content_type:string) : void
->	when b := some(i in self._sub_contents | i % email_body) in (
		let a := email_alternative()
		in (self._sub_contents :add email_alternative(),
			a._sub_contents :add b,
			self._sub_contents :delete b,
			let nb := email_body(_body = port!())
			in (a._sub_contents :add nb,
				self._body_printing_stack :add nb,
				self._body_port_printing_stack :add use_as_output(nb._body))))
	else (
		let nb := email_body(_body = port!())
		in (self._sub_contents :add nb,
			self._body_printing_stack :add nb,
			self._body_port_printing_stack :add use_as_output(nb._body)))]

// Printing in the latest body created
[print_in_body(self:email) : port
->	if not(self._body_printing_stack)
		email_error(comment = "no body created, must use print_in_body(self:email,content_type:string)")
	else use_as_output(last(self._body_printing_stack)._body)]

[end_of_body(self:email) : void
->	if (self._body_printing_stack) (
		use_as_output(last(self._body_port_printing_stack)),
		shrink(self._body_port_printing_stack, length(self._body_port_printing_stack) - 1),
		shrink(self._body_printing_stack, length(self._body_printing_stack) - 1))]

// Creating an attachment
[print_in_attachement(self:email,content_type:string) : port
->	self._attachments_content :add content_type,
	let p := port!() in
		(self._attachments :add p,
		use_as_output(p))]

// Printing in the latest attachment created
[print_in_attachement(self:email) : port
->	if not(self._attachments_content)
		email_error(comment = "no body created, must use print_in_attachement(self:email,content_type:string)")
	else use_as_output(last(self._attachments))]


// Adding a file as attachment
[add_attachment_file(self:email,content_type:string,file:string, encoding:string) : void
-> 	self._attachments_content :add (content_type /+ "\r\nContent-Disposition: attachment; filename=" /+ file),
	self._attachments_encoding :add encoding,
	self._attachments :add fopen(file,"rb")]


[get_header(self:email_base,head:string) : string
->	self._headers[head] ]
/*	when x := some( i in tolist(msg._headers) | substring(i[1],s, true) != 0)
	in (x[2] as string) else ""] 
*/
/*
[private/add_to_header(msg:email,head:string,data:string) : void
-> when i := some( i in (1 .. length(msg._headers)) | substring(msg._headers[i][1],s, true) != 0)
	in (let x := msg._headers[i] in (
			msg._headers[i] := tuple(x[1],x[2] /+ data)))]
*/

[set_header(self:email,head:string, value:string) : void
-> self._headers[head] := value]


[private/get_content_type(self:email) : string
->	if not(self._attachments_content) (
		if (length(self._bodies) = 1)
			self._bodies_content[1]
		else (
			self._boundary := uid(),
			"multipart/alternative; boundary=claire_mail_alternative_" /+ self._boundary))
	else (	self._boundary := uid(),
			"multipart/mixed; boundary=claire_mail_mixed______" /+ self._boundary /+ "")]


//-------------------------------------------------------------------------
// 		3.	Utilities
//-------------------------------------------------------------------------
		

[private/fwrite_header(head:string, data:string,p:port) : void
-> fwrite(head,p), fwrite(data,p), fwrite("\r\n",p)]

[private/fwrite_header(head:string, p:port) : void
-> fwrite(head,p), fwrite("\r\n",p)]

[private/fwrite_boundary(bound:string, p:port) : void
-> fwrite("\r\n--",p), fwrite(bound,p), fwrite("\r\n",p)]

[check_header_value?(self:email,val:string) : boolean
->	exists( h in self._headers |  (substring(h[2],val,true) > 0))]

[check_header_value?(self:email_base,head:string,val:string) : boolean
->	(substring(self._headers[head],val,true) > 0)]

[check_header_value?(self:email_base, val:string) : boolean
->	exists( h in self._headers |  (substring(h[2],val,true) > 0))]


//-------------------------------------------------------------------------
// 		4.	Data access
//-------------------------------------------------------------------------

[fill_with_body(self:email_base,contenttype:string,p:port,body?:boolean) : port
->	if body? (
		if check_header_value?(self,"content-type",contenttype)
			rwport(self._body,p))
	else (if check_header_value?(self,"content-type","multipart")
		(let alternative? := check_header_value?(self,"content-type","alternative") in
			for i in self._sub_contents
				fill_with_body(i,contenttype,p,alternative?))),
	p]

[fill_with_body(self:email_base,contenttype:string,p:port) : port
->	fill_with_body(self,contenttype,p,not(check_header_value?(self,"content-type","multipart")))]

[add_to_body(self:email_base,data:string) : void
-> 	if unknown?(_body,self)  self._body := port!(),
	fwrite(data,self._body)]

[fill_body(self:email_base,from:port) : void
->	if unknown?(_body,self)  self._body := port!(),
	rwport(from,self._body)]
