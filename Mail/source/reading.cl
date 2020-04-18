/*	File : model.cl email protocol
	Module : Mail general mail purpose
	expert-solutions SARL
	Xavier Pechoultres
	
	1. Reading email
*/
//-------------------------------------------------------------------------
// 		1.	Reading email
//-------------------------------------------------------------------------

[private/parse_header(self:string) : tuple(string,string) 
->	let	head:string := "",
		data:string := "",
		head_end := find(self,":") 
	in (if (self[1] % list( ' ' , '\t') | head_end = 0) (
			 data := trim(self))
		else (head := trim(substring(self,1,head_end - 1)),
				data := trim(substring(self,head_end + 1,length(self)))),
		tuple(head,data))]					

[private/read_headers(self:email_base,p:port) : void
->	//[MAIL_2] read_headers(m,p) ,
	let tmp := "",
		last_header:string := ""
		in (while ((tmp := get_line(p)) != "\r\n" & tmp != "\n" & tmp != "") (
				let o := parse_header(tmp)
				in (if (o[1] = "")
						self._headers[last_header] := self._headers[last_header] /+ o[2]
					else (last_header := o[1],
						self._headers[last_header] := o[2]))))]	

[read_email(self:email_base,p:port,boundary:string) : boolean
-> 	//[MAIL_0] read_email(self,port, ~S) // boundary,
	read_headers(self,p),
	//[MAIL_2] read_email -> headers OK,
	if (substring(self._headers["content-type"],"multipart",true) > 0) (
		let h := self._headers["Content-Type"],
			boundary_in := clean_boundary(substring(h, substring(h,"boundary=",true) + 9, length(h)))
		in (// contenu multiple
			//[MAIL_2] read_email -> multiple content ,
			read_to_bundary(p, boundary_in),
			//[MAIL_2] read_email -> reading multiple content ,
			while (	let i := email_base()
					in (self._sub_contents :add i,
						read_email(i,p,boundary_in)))
				none),
			check_next_bundary(p, boundary))
	else
		read_content(self,p,boundary)]


[read_email(self:email_base,p:port) : void
->	//[MAIL_0] --------------- read_email(self,port) ,
	//[MAIL_2] ------------------- reading headers,
	read_headers(self,p),
	if (substring(self._headers["content-type"],"multipart",true) > 0) (
		let h := self._headers["Content-Type"],
			boundary := clean_boundary(substring(h, substring(h,"boundary=",true) + 9, length(h)))
		in (// contenu multiple
			read_to_bundary(p, boundary),
			while (	let i := email_base()
					in (self._sub_contents :add i,
						read_email(i,p,boundary))) none))
	else (
		//[MAIL_2] ----------------- read_email(self,port) : contenu simple,
		read_content(self,p))]

// increment port pointer after next boundary
[read_to_bundary(p:port,boundary:string) : void
-> 	let boundary_on := "--" /+ boundary /+ "\r\n",
		boundary_on2 := "--" /+ boundary /+ "\n"
	in	(//[MAIL_0] read_to_bundary(self,~S) // boundary , 
		while not(get_line(p) % list(boundary_on,boundary_on2)) none)]

[check_next_bundary(p:port,boundary:string) : boolean
-> 	let boundary_on := "--" /+ boundary /+ "\r\n",
		boundary_on2 := "--" /+ boundary /+ "\n",
		boundary_off := "--" /+ boundary /+ "--\r\n",
		boundary_off2 := "--" /+ boundary /+ "--\n",
		res := true
	in	(//[MAIL_0] >>>>> check_next_bundary(port,~S) // boundary , 
		while true (
			let tmp := get_line(p)
			in (if (tmp % list(boundary_on,boundary_on2)) (
					res := true,break())
				else if (tmp % list(boundary_off,boundary_off2)) (
					res := false,break()))),
		//[MAIL_0] <<<<<<<<< check_next_bundary(port,~S) // boundary , 
		res)]

// read content
[read_content(self:email_base,p:port) : void
->	//[MAIL_0] read_content(self,p) ,
	let b := port!() in (
		if check_header_value?(self,"Content-Transfer-Encoding",ENCODING_TEXT) (
			//[MAIL_0] -------- READING ~S // ENCODING_TEXT,
			rwport_decode(p,b,ENCODING_TEXT))
		else if check_header_value?(self,"Content-Transfer-Encoding",ENCODING_BINARY) (
			//[MAIL_0] -------- READING ~S // ENCODING_BINARY,
			rwport_decode(p,b,ENCODING_BINARY))
		else (
			//[MAIL_0] -------- READING BINARY,
			rwport(p,b)),
		self._body := b)]

// read content to next boundary
[read_content(self:email_base,p:port,boundary:string) : boolean
->	//[MAIL_0] read_content(self,p,~S) // boundary,
	let b := port!(),
		boundary_on := "--" /+ clean_boundary(boundary) /+ "\r\n",
		boundary_off := ("--" /+ clean_boundary(boundary) /+ "--\r\n"),
		boundary_on2 := "--" /+ clean_boundary(boundary) /+ "\n",
		boundary_off2 := ("--" /+ clean_boundary(boundary) /+ "--\n"),
		res:boolean := false
	in (while true (
			let tmp := get_line(p)
			in (//[MAIL_0] read_content(self,p,~S) -> ~S// boundary, tmp,
				if (tmp = boundary_on | tmp = boundary_on2 /* |  tmp = boundary_on3 |  tmp = boundary_on4 */ ) (
					res := true, break())
				else if (tmp = boundary_off | tmp = boundary_off2 /* | tmp = boundary_off3 | tmp = boundary_off4 */ ) (
					res := false, break())
				else (fwrite(tmp,b)))),

		if check_header_value?(self,"Content-Transfer-Encoding",ENCODING_TEXT)
			(
			//[MAIL_0] -------- READING ~S // ENCODING_TEXT,
			self._body := port!(),
			rwport_decode(b,self._body,ENCODING_TEXT),
			fclose(b))
		else if check_header_value?(self,"Content-Transfer-Encoding",ENCODING_BINARY)
			(self._body := port!(),
			//[MAIL_0] -------- READING ~S // ENCODING_BINARY,
			rwport_decode(b,self._body,ENCODING_BINARY),
			fclose(b)) 
		else (//[MAIL_0] -------- READING BYTE TO BYTE,
			self._body := b),
		res)]

[clean_boundary(self:string) : string
-> 	let res := self in (
		res := trim(res),
		if (res[1] = ';') res := right(res,length(res) - 1 ),
		if (res[length(res)] = ';') res := left(res,length(res) - 1),
		if (res[1] = '"') res := right(res,length(res) - 1 ),
		if (res[length(res)] = '"') res := left(res,length(res) - 1),
		res)]


[read_email(p:port) : email_base
-> let m := email() in (read_email(m,p),m)]

