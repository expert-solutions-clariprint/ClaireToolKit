
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * reader.cl                                                         *
// * Copyright (C) 2000 - 2004 xl. All Rights Reserved                 *
// *********************************************************************


// *********************************************************************
// *   Part 1: reader classes                                          *
// *   Part 2: self printing                                           *
// *   Part 3: tools                                                   *
// *   Part 4: pdf reader                                              *
// *   Part 5: reflective api                                          *
// *********************************************************************


// *********************************************************************
// *   Part 1: reader classes                                          *
// *********************************************************************

pdf_read_document <: ephemeral_object


//<sb> mapping :
//                 claire  <=>  pdf
//                integer  <=>  integer number
//                  float  <=>  float number
//                 string  <=>  string (literal & hexa)
//                   list  <=>  array
//         pdf_dictionary  <=>  dictionary
// pdf_indirect_reference  <=>  indirect reference
//            true /false  <=>  true /false
//               PDF_NULL  <=>  null
//             pdf_stream  <=>  stream object
//               pdf_name  <=>  name


pdf_basic_object <: ephemeral_object()
	pdf_dictionary <: pdf_basic_object(
		keyvals:list[any])
	pdf_name <: pdf_basic_object(value:string)
	pdf_stream <: pdf_basic_object(
		dictionary:pdf_dictionary,
		byteoffset:integer,
		buf:blob)
	pdf_indirect_reference <: pdf_basic_object(
		rdoc:pdf_read_document,
		number:integer,
		rev:integer)


PDF_END_ARRAY :: pdf_basic_object()
PDF_NULL :: pdf_basic_object()

pdf_xref_entry <: ephemeral_object(
	byteoffset:integer,
	generationnumber:integer,
	freed?:boolean)
	
pdf_xref_section <: ephemeral_object(
	firstobj:integer,
	objcount:integer,
	refs:list[pdf_xref_entry])

pdf_xref <: ephemeral_object(
	byteoffset:integer,
	trailer:pdf_dictionary,
	xrefsections:list[pdf_xref_section])


pdf_read_document <: ephemeral_object(
	original:blob, //<sb> the original document is store (incremental update only)
	xrefs:list[pdf_xref],
	invmap:table,
	map:table)

// *********************************************************************
// *   Part 2: self printing                                           *
// *********************************************************************

[self_print(self:pdf_basic_object) : void -> princ("null")]

[self_print(self:pdf_name) : void ->
	printf("/~A", get(value, self))]

[self_print(self:pdf_indirect_reference) : void ->
	printf("~S ~S R", get(number, self), get(rev, self))]


[self_print(self:pdf_stream) : void ->
	printf("~Sstream(~S)", get(dictionary, self), get(byteoffset,self))]

[self_print(self:pdf_dictionary) : void ->
	printf("<<~I>>",
		(let first? := true
		in for i in (1 .. length(self.keyvals))
			(if (i mod 2 = 1)
				(if first? first? := false else princ(" "),
				printf("/~A ~S", self.keyvals[i], self.keyvals[i + 1])))))]

// *********************************************************************
// *   Part 3: tools                                                   *
// *********************************************************************


PDF_DELIMITERS :: {'(', ')', '{', '}', '<', '>', '[', ']', '/', '%'}
PDF_WHITE_SPACE :: {' ', '\t', '\r', '\n', '\0', '\014'}
PDF_READUNTIL :: {'(', ')', '{', '}', '<', '>', '[', ']', '/', '%', ' ', '\t', '\r', '\n', '\0', '\014'}


UNREAD_TOKENS:list[string] := list<string>()
NEXT_TOKEN:(string U {unknown}) := unknown

[reset_token() : void =>
	shrink(UNREAD_TOKENS, 0),
	NEXT_TOKEN := unknown]

[unread_token(token:string) : void => UNREAD_TOKENS :add token]


[read_token(p:blob) : string ->
	if UNREAD_TOKENS
		let res := last(UNREAD_TOKENS) as string
		in (shrink(UNREAD_TOKENS, length(UNREAD_TOKENS) - 1),
			res)
	else if known?(NEXT_TOKEN)
		let res := NEXT_TOKEN as string
		in (NEXT_TOKEN := unknown, res)
	else
		let (token, sep) := freadline(p, PDF_READUNTIL)
		in (if (length(token) = 0 & sep % PDF_WHITE_SPACE) read_token(p)
			else case sep
				({""} "",
				{'%'}
					(freadline(p), // skip until eol
					if (length(token) = 0) read_token(p)
					else token),
				any (if (length(token) = 0)
						(if (sep % PDF_WHITE_SPACE) read_token(p)
						else make_string(1,sep))
					else (if not(sep % PDF_WHITE_SPACE)
							NEXT_TOKEN := make_string(1, sep),
						token))))]

[pdf_number?(s:string) : boolean ->
	if (length(s) = 0) false
	else let i := 1, len := length(s)
		in (if (s[i] % {'+', '-'}) i :+ 1,
			if (i > len) false
			else
				(while (i <= len & digit?(s[i])) i :+ 1,
				if (i > len) true
				else if (s[i] = '.')
					(i :+ 1,
					while (i <= len & digit?(s[i])) i :+ 1,
					i > len)
				else false))]

[pdf_integer?(s:string) : boolean ->
	if (length(s) = 0) false
	else let i := 1, len := length(s)
		in (if (s[i] % {'+', '-'}) i :+ 1,
			if (i > len) false
			else
				(while (i <= len & digit?(s[i])) i :+ 1,
				i > len))]


// *********************************************************************
// *   Part 4: pdf reader                                              *
// *********************************************************************

OCTAL_DIGITS :: {"0","1","2","3","4","5","6","7"}

[read_literal_string(p:blob) : string ->
	let np := 0, res := port!(), s := ""
	in (while not(eof?(p))
			let (x, b) := freadline(p, {"(", ")", "\\"})
			in (case b
				({"\\"} //<sb> escape
					(fwrite(x, res),
					let c := fread(p, 1)
					in case c
						({"\n"} none, //<sb> the string continue onto the next line, ignore
						{"\r"} let nc := fread(p, 1)
								in (if (nc != "\n")
									fwrite(nc,res)),
						{"n"} fwrite("\n", res),
						{"r"} fwrite("\r", res),
						{"b"} fwrite("\008", res),
						{"f"} fwrite("\012", res),
						OCTAL_DIGITS  //<sb> support for octal characters \ooo
							let oct := 0, n := 3, nc := c
							in (while (nc % OCTAL_DIGITS & n > 0)
									(oct := 8 * oct + integer!(nc[1]) - integer!('0'),
									nc := fread(p, 1),
									n :- 1),
								putc(char!(oct), res),
								set_index(p, get_index(p) - 1)),
						any fwrite(c, res))),
				{"("} //<sb> pdf strings support balanced parenthesis
					(fwrite(x, res),
					fwrite(b, res),
					np :+ 1),
				{")"}
					(fwrite(x, res),
					if (np = 0) break(),
					fwrite(b, res),
					np :- 1))),
		s := string!(res),
		fclose(res),
		s)]


[read_hexa_string(p:blob, s:string) : string ->
	let eols := read_token(p)
	in (if (eols != ">")
			error("invalid end of hexa string <~A> (found ~S vs \">\")", s, eols)),
	let len := length(s),
		olen := len / 2
	in (if (len mod 2 != 0)
			(s :/+ "0", len :+ 1),
		s := lower(s),
		externC("ClEnv->bufferStart()"),
		externC("ClEnv->pushAttempt(olen + 1)"),
		externC("int i = 0; unsigned char *p = (unsigned char *)ClEnv->buffer"),
		externC("for(;i < len;i += 2, p++) {"),
			externC("unsigned char c1 = s[i], c2 = s[i + 1]"),
			externC("int h = (c1 >= 'a' ? 10 + c1 - 'a' : c1 - '0') * 16"),
			externC("h += (c2 >= 'a' ? 10 + c2 - 'a' : c2 - '0')"),
			externC("*p = h;}"),
		copy(externC("ClEnv->buffer", string), olen))]

[read_name(p:port) : string ->
	let s := read_token(p),
		i := 1,
		len := length(s)
	in (print_in_string(),
		while (i <= len)
			(if (s[i] = '#' & i + 2 <= len)
				(princ(char!(hex2int(s[i + 1]) * 16 + hex2int(s[i + 2]))),
				i :+ 3)
			else (princ(s[i]), i :+ 1)),
		end_of_string())]

[read_array(self:pdf_read_document, p:blob) : list[any] ->
	let ar := list<any>()
	in (while true
			let obj := read_basic_object(self, p)
			in (if (obj = PDF_END_ARRAY) break()
				else ar :add obj),
		cast!(ar, {}))]

[read_basic_object(self:pdf_read_document, p:blob) : any ->
	let token := read_token(p)
	in (case token
		({"null"} PDF_NULL,
		{"true"} true,
		{"false"} false,
		{"/"} pdf_name(value = read_name(p)),
		{"["} read_array(self, p),
		{"]"} PDF_END_ARRAY,
		{"("} read_literal_string(p),
		{"<"}
			(let ntoken := read_token(p)
			in case ntoken
				({"<"} read_dictionary(self, p),
				any read_hexa_string(p, ntoken))),
		any
			(if not(pdf_number?(token)) //<sb> what else could it be ?
				error("malformed number ~S", token),
			if pdf_integer?(token)
				let next := read_token(p)
				in (if pdf_integer?(next)
						let R := read_token(p)
						in (if (R != "R") //<sb> check for indirect reference
								(unread_token(R),
								unread_token(next),
								integer!(token))
							else pdf_indirect_reference(rdoc = self, number = integer!(token), rev = integer!(next)))
					else (unread_token(next),
							integer!(token)))
			else float!(token))))]


[read_dictionary(self:pdf_read_document, p:blob) : pdf_dictionary ->	
	let dict := pdf_dictionary()
	in (while true
			let token := read_token(p)
			in case token
				({"/"}
					(
					dict.keyvals :add read_token(p),
					dict.keyvals :add read_basic_object(self, p)),
				{">"}
					(if (read_token(p) != ">")
						error("invalid token \">\" found reading dictionary ~S", dict),
					break()),
				any error("invalid token ~S found reading dictionary ~S", token, dict)),
		dict)]

//<sb> called once we known the the length, i.e. when the
// object map of the document is filled up
[read_stream(self:pdf_stream, p:blob) : void ->
	self.buf := port!(),
	set_index(p, self.byteoffset),
	let len := get_attribute(self, "Length") //<sb> see the api section
	in case len
			(integer
				while (len > 0)
					let n := 1024 min len
					in (freadwrite(p, self.buf, n),
						len :- n),
			any error("length range error, ~S does not belong to integer", len))]


[read_indirect_object(self:pdf_read_document, p:blob) : any ->
	let n := 0, r := 0
	in (reset_token(),
		let token := read_token(p)
		in (if not(pdf_integer?(token)) error("invalid indirect object id ~S", token),
			n := integer!(token)),
		let token := read_token(p)
		in (if not(pdf_integer?(token)) error("invalid indirect object revision ~S", token),
			r := integer!(token)),
		let token := read_token(p)
		in (if (token != "obj") error("invalid indirect oject keyword ~S", token)),
		let res := unknown,
			token := read_token(p)
		in (case token
				({"<"} //<sb> '<<' keyword introduces the object's dictionary
					let ntoken := read_token(p)
					in (if (ntoken != "<") read_hexa_string(p, ntoken)
						else
							let dict := read_dictionary(self, p)
							in (ntoken := read_token(p),
								case ntoken
									//<sb> note : a pdf object may have a content stream. It is introduced
									// by the 'stream' keyword inside an indirect object definition.
									// The associated object's dictionary  must specify stream's length,
									// that can be given by a referenced object still undefined (unread yet).
									// So we prefer stop reading the object at the 'stream' keyword, we retain
									// the stream byte offset for later use once the length is fully defined :
									({"stream"}
										(	if (p[get_index(p)] = '\r')
											(if (getc(p) != '\n')
												error("invalid EOL marker after keyword stream")),
										if unknown?(dict)
											error("undefined length for stream object wihout dictionary"),
										res := pdf_stream(byteoffset = get_index(p), //<sb> index of the first stream byte
															dictionary = dict)),
									any res	:= dict))),

				any //<sb> no dictionary, should be a basic object
					(unread_token(token),
					res := read_basic_object(self, p))),
			self.map[n, r] := res,
			self.invmap[res] := tuple(n, r),
			res))]

[read_xref_section(p:blob, fobj:integer, n:integer) : pdf_xref_section ->
	let xrs := pdf_xref_section(firstobj = fobj, objcount = n), first? := true
	in (for i in (1 .. n)
		let entry := //<sb> xref's entries are always 20 bytes long "0000000000 11111 n \n"
					(if first?
						(first? := false,
						let pref := fread(p, 1)
						in (if (pref % {"\r","\n"})
								pref := fread(p, 1),
							if (pref % {"\r","\n"})
								pref := fread(p, 1),
							pref /+ fread(p, 19))) else fread(p, 20)),
			offset := substring(entry, 1 , 10),
			w1 :=  entry[11],
			gennumber := substring(entry, 12, 16),
			w2 :=  entry[17],
			nORf := entry[18],
			w3 := entry[19],
			w4 := entry[20]
		in (if (w1 != ' ' | w2 != ' ' | not(w3 % {' ', '\r'}) | w4 != '\n' | not(nORf % {'n', 'f'}) |
					not(pdf_integer?(offset)) | not(pdf_integer?(gennumber)))
				error("invalid cross reference entry ~S", entry),
			xrs.refs :add pdf_xref_entry(byteoffset = integer!(offset),
											generationnumber = integer!(gennumber),
											freed? = (nORf = 'f'))),
			xrs)]

[read_xref(self:pdf_read_document, p:blob) : pdf_xref ->
	let xr := pdf_xref(byteoffset = get_index(p))
	in (let token := read_token(p)
		in (if (token != "xref")
		 	error("expected xref keyword instead of ~S", token)),
		while true
			let token := read_token(p)
			in case token
				({"startxref"}
					error("missing document trailer"),
				{"trailer"}
					(let lt1 := read_token(p), lt2 := read_token(p)
					in (if (lt1 != "<" | lt2 != "<")
							error("Invalid trailer dictionary introduction ~S ~S", lt1, lt2)),
					xr.trailer := read_dictionary(self, p),
					let ntoken := read_token(p)
					in (if (ntoken != "startxref")
							error("expected startxref instead of ~S", ntoken)),
					break()),
				any
					(if not(pdf_integer?(token))
						error("expected an object id instead of ~S in cross reference", token),
					let n := read_token(p)
					in (if not(pdf_integer?(n))
							error("expected an object count instead of ~S in cross reference", n),
						xr.xrefsections :add
								read_xref_section(p, integer!(token), integer!(n))))),
		xr)]

//<sb> We follow these steps :
//   0 - put the document in a blob and store it as the original
//   1 - goto the end of the (buffered) document and backread the %%EOF marker
// 	 2 - backread one line -> byte offset of the xref table
//   3 - move to the given byte offset (i.e. on the char 'x' of the 'xref' keyword)
//   4 - read the xref -> byte offset <=> objects
//   5 - read the trailer (may contain a /Prev entry that is the byte offset
//       of a previous xref -> loop on step 3)
[read_document(p:port) : pdf_read_document ->
	let doc := pdf_read_document(
					original = port!(),
					invmap = make_table(any, tuple(integer,integer), tuple(0,0)),
					map = make_table(tuple(integer,integer), any, PDF_NULL)),
		buf:port := doc.original
	in (freadwrite(p, buf), //<sb> ... step 0
		buf := Core/reverser!(buf),
		let bos := "",
			bo := 0
		in (// go to end
			while (let x := freadline(buf, {"\n","\n\r"})
					in (trim(x[1]) != "FOE%%" )) none,
			bos := reverse(trim(freadline(buf, {"\n","\n\r"})[1])),
			if not(pdf_integer?(bos))
				error("invalid xref byte offset ~S", bos),
			bo := integer!(bos),                                           //<sb> ... step 2
			fclose(buf),
			buf := doc.original,
			while true 
				(set_index(buf, bo),                                        //<sb> ... step 3
				reset_token(),
				let xref := read_xref(doc, buf)                           //<sb> ... step 4
				in (doc.xrefs :add xref,
					for x in xref.xrefsections
						for y in x.refs
							(set_index(buf, y.byteoffset),
							read_indirect_object(doc, buf)),
					let g := doc.map.mClaire/graph
					in for i in {i in (1 .. length(g)) | i mod 2 = 1 & g[i + 1] % pdf_stream}
						read_stream(g[i + 1], buf),
					if unknown?(trailer, xref)
						error("missing xref's trailer"),
					let prev := get_attribute(xref.trailer, "Prev") //<sb> ... step 5
					in (case prev
							(integer bo := prev,
							any break(doc)))))), doc)]



// *********************************************************************
// *   Part 5: reflective api                                          *
// *********************************************************************


[nth(self:pdf_dictionary, key:string) : any ->
	when x := some(i in (1 .. length(self.keyvals))|i mod 2 = 1 & self.keyvals[i] = key)
	in self.keyvals[x + 1] else PDF_NULL]

[get_attribute(self:any, path:list[string]) : any ->
	case self
		(pdf_indirect_reference
			get_attribute(self.rdoc.map[self.number, self.rev], path),
		pdf_name (if path nil else self.value),
		pdf_stream
			(if not(path) self
			else if (path[1] = "") //<sb> if the path with '//' we return a filtered stream
				(set_index(self.buf, 0),
				let p := blob!(self.buf)
				in case get_attribute(self.dictionary, "Filter")
					({"FlateDecode"} Zlib/deflater!(p),
					any p))
			else get_attribute(self.dictionary, path)),
		list
			(if not(path) self
			else if (path[1] = "*")
				(path << 1,
				list{y in list{get_attribute(x, copy(path)) | x in self} | y != nil & y != PDF_NULL})
			else
				let i := integer!(path[1])
				in (if (i < 1 | i > length(self)) nil
					else let e := self[integer!(path[1])]
							in (path << 1, get_attribute(e, path)))),
		pdf_dictionary
			(if not(path) self
			else let e := self[path[1]]
				in (path << 1, get_attribute(e, path))),
		any (if path nil else self))]

[get_attribute(self:any, path:string) : any ->
	let l := explode(path, "/")
	in (if (l & l[1] = "") l << 1,
		get_attribute(self, l))]

[get_attribute(self:pdf_read_document, path:string) : any ->
	let res:any := PDF_NULL
	in (for x in self.xrefs
			(res := get_attribute(x.trailer, path),
			if (res != PDF_NULL) break()),
		res)]


[get_list_attr(self:any, path:string) : list ->
	let res := get_attribute(self, path)
	in (if not(res % list)
			error("get_list_attr(~S) range error ~S does not belong list", path, res),
		res as list)]


[get_list_integer_attr(self:any, path:string) : list[integer] ->
	let res := get_attribute(self, path)
	in (if not(res % list[integer])
			error("get_list_integer_attr(~S) range error ~S does not belong list[integer]", path, res),
		res as list[integer])]

[get_port_attr(self:any, path:string) : port ->
	let res := get_attribute(self, path)
	in (if not(res % port)
			error("get_port_attr(~S) range error ~S does not belong port", path, res),
		res as port)]

[get_string_attr(self:any, path:string) : string ->
	let res := get_attribute(self, path)
	in (if not(res % string)
			error("get_string_attr(~S) range error ~S does not belong string", path, res),
		res as string)]

[get_integer_attr(self:any, path:string) : integer ->
	let res := get_attribute(self, path)
	in (if not(res % integer)
			error("get_integer_attr(~S) range error ~S does not belong integer", path, res),
		res as integer)]

[get_dict_attr(self:any, path:string) : pdf_dictionary ->
	let res := get_attribute(self, path)
	in (if not(res % pdf_dictionary)
			error("get_dict_attr(~S) range error ~S does not belong pdf_dictionary", path, res),
		res as pdf_dictionary)]


[get_object_id(self:pdf_read_document, x:any) : any ->
	case x
		(list
			let t := self.invmap[x]
			in (if (t[1] != 0) t
				else list{get_object_id(self, y) | y in x}),
		any self.invmap[x])]

[get_object_id(self:pdf_read_document, path:string) : any ->
	get_object_id(self, get_attribute(self, path))]

[fill_attachment_list(self:any, l:list<tuple(string,string,port)>) : void ->
	for x in get_attribute(self, "Kids/*")
		(case get_attribute(x, "Type")
			({"Pages"} fill_attachment_list(x, l),
			{"Page"}
				for a in list{a in get_list_attr(x, "Annots/*") | get_attribute(a, "Subtype") = "FileAttachment"}
					l :add tuple(get_string_attr(a, "FS/F"),
									get_string_attr(a, "FS/EF/F/Subtype"),
									get_port_attr(a, "FS/EF/F//"))))]
			
[get_attachment(self:pdf_read_document) : list[tuple(string,string,port)] ->
	let l := list<tuple(string, string, port)>()
	in (fill_attachment_list(get_attribute(self, "Root/Pages"), l),
		l)]


// *********************************************************************
// *   Part 6: signature verification                                  *
// *********************************************************************

invalid_signature <: exception()
	invalid_x509_rsa_sha1_signature <: invalid_signature()
	invalid_pkcs7_sha1_signature <: invalid_signature()

[verify_x509_rsa_sha1(self:pdf_read_document, sig:any, algo:Openssl/DIGEST_ALGORYTHMS) : boolean ->
	let byterange := get_list_integer_attr(sig, "ByteRange"),
		x509 := (let cert := get_attribute(sig, "Cert")
				in (case cert
						(list
							case cert[1]
								(string Openssl/d2i_X509(cert[1]),
								any error("bad Cert entry")),
						string Openssl/d2i_X509(cert),
						any error("bad Cert entry")) as Openssl/X509)),
		key := Openssl/get_pubkey(x509),
		digest := Openssl/d2i_octet_string(get_string_attr(sig, "Contents")),
		ctx := Openssl/digest_context!(algo),
		n := 0, p := self.original
	in (Openssl/verify_init(ctx),
		set_index(p, 0),
		for j in (1 .. length(byterange))
			let i := byterange[j] as integer
			in (if (j mod 2 = 1) n :+ length(fread(p, i - n)) //<sb> skip a i - n byte long hole before next range
				else
					let s := make_string(1024, ' ') //<sb> digests a i byte long range / 1024 block
					in (n :+ i,
						while (i > 0 & not(eof?(p)))
							(if (i >= 1024) i :- fread(p, s)
							else (s := fread(p, i), i := 0),
							Openssl/verify_update(ctx, s)))),
		Openssl/verify_final(ctx, digest, key))]


[verify_pkcs7_sha1(self:pdf_read_document, sig:any, algo:Openssl/DIGEST_ALGORYTHMS) : boolean ->
	let byterange := get_list_integer_attr(sig, "ByteRange"),
		p7 := Openssl/d2i_PKCS7(get_string_attr(sig, "Contents")),
		ctx := Openssl/digest_context!(algo),
		n := 0, p := self.original
	in (Openssl/digest_init(ctx),
		set_index(p, 0),
		for j in (1 .. length(byterange))
			let i := byterange[j] as integer
			in (if (j mod 2 = 1) n :+ length(fread(p, i - n)) //<sb> skip a i - n byte long hole before next range
				else
					let s := make_string(1024, ' ') //<sb> digests a i byte long range / 1024 block
					in (n :+ i,
						while (i > 0 & not(eof?(p)))
							(if (i >= 1024) i :- fread(p, s)
							else (s := fread(p, i), i := 0),
							Openssl/digest_update(ctx, s)))),
		Openssl/verify(p7, Openssl/digest_final(ctx)))]


[verify(self:pdf_read_document) : boolean ->
	for sigs in list{s in get_list_attr(self, "/Root/AcroForm/Fields/*")|get_attribute(s, "FT") = "Sig"}
		let sig := get_dict_attr(sigs, "V"),
			subfilter := get_string_attr(sig, "SubFilter")
		in (//[0] verify ~A signature // subfilter,
			case subfilter
				({"adbe.x509.rsa_sha1"}
					(if not(verify_x509_rsa_sha1(self, sig, "sha1"))
						invalid_x509_rsa_sha1_signature()),							
				{"adbe.pkcs7.sha1", "adbe.pkcs7.detached"}
					(if not(verify_pkcs7_sha1(self, sig, "sha1"))
						invalid_pkcs7_sha1_signature()),							
				any error("unsupported SubFilter ~S for Adobe.PPKLite signature", subfilter))),
	true]

		





