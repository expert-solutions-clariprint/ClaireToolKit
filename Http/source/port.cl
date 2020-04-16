
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * model.cl                                                          *
// * Copyright (C) 2005 xl. All Rights Reserved                        *
// *********************************************************************

// ***************************************************************************
// * part 1: chunker                                                         *
// ***************************************************************************

// @cat Chunked transfer coding
// @section Http filters
// chunker implement the RFC2616 (sec 3.6.1) "Chunked transfer coding"
// used to define the body-length of a message. Unlike content-length,
// chunked coding allow stream oriented message generation (i.e. a message
// which has an undefined length at the time it is generated).
// @cat

chunker <: filter(pendingr:blob,
				pendingw:blob,
				add_empty_chunk?:boolean = false,
				eof_reached?:boolean = false)

//<sb> @doc Chunked transfer coding
// chunker!(self) creates a read/write filter that handle chunked encoded
// datas.
chunker!(self:port) : chunker ->
	filter!(chunker(pendingr = blob!(),
					pendingw = blob!()), self)

flush_port(self:chunker) : void ->
	let pend := self.pendingw,
		len := length(pend)
	in (if (len > 0)
			(self.add_empty_chunk? := true,
			externC("char tmp[8]; sprintf(tmp,\"%x\\r\\n\", len)"),
			write_port(self.target, externC("tmp",char*), externC("strlen(tmp)", integer)),
			write_port(self.target, pend.Core/data, len),
			write_port(self.target, externC("\"\\r\\n\"", char*), 2),
			set_length(pend, 0)))

write_port(self:chunker, buf:char*, len:integer) : integer ->
	let pend := self.pendingw
	in (write_port(pend, buf, len),
		if (length(pend) > 1024)
			flush_port(self),
		len)

close_port(self:chunker) : void ->
	(if self.add_empty_chunk?
		write_port(self.target, externC("\"0\\r\\n\\r\\n\"", char*), 5),
	fclose(self.pendingr),
	fclose(self.pendingw))

eof_port?(self:chunker) : boolean -> self.eof_reached?

read_port(self:chunker, buf:char*, len:integer) : integer ->
	let n := 0,
		pend := self.pendingr
	in (while (not(self.eof_reached?) & len > 0)
			(if eof_port?(pend)
				(if eof_port?(self.target)
					error("Premature end of file on ~S", self),
				let s := freadline(self.target, "\r\n"),
					chunk_length := 0
				in (if (length(s) = 0) s := freadline(self.target, "\r\n"),
					externC("sscanf(s, \"%x\", &chunk_length)"),
					set_length(pend, 0),
					if (chunk_length = 0)
						(freadline(self.target, "\r\n"),
						self.eof_reached? := true,
						break()),
					Core/write_attempt(pend, chunk_length),
					pend.Core/write_index := read_port(self.target, pend.Core/data, chunk_length))),
			let m := read_port(pend, buf, len)
			in (n :+ m,
				len :- m,
				buf :+ m)), n)


// ***************************************************************************
// * part 2: content_length_spy                                              *
// ***************************************************************************

// @cat Content length spy
// @section Http filters
// @cat


content_length_spy <: filter(content_length:integer)

//<sb> @doc Content length spy
// content_length_spy!(self) is equivalent to
// content_length_spy!(self, integer!(getenv("CONTENT_LENGTH"))).
// The CONTENT_LENGTH environment variable is usualy sets in a CGI
// environment.
[content_length_spy!(self:port) : content_length_spy ->
	let p := filter!(content_length_spy(), self)
	in (p.content_length := integer!(getenv("CONTENT_LENGTH")),
		p)]

//<sb> @doc Content length spy
// The content length spy is used to force an EOF
// condition after content_length bytes which prevent
// blocking read to occur past the message body.
[content_length_spy!(self:port, n:integer) : content_length_spy ->
	let p := filter!(content_length_spy(), self)
	in (p.content_length := n,
		p)]

eof_port?(self:content_length_spy) : boolean -> (self.content_length <= 0)

read_port(self:content_length_spy, buf:char*, len:integer) : integer ->
	let disp := len min self.content_length,
		n := read_port(self.target, buf, disp)
	in (self.content_length :- n,
		n)


// ***************************************************************************
// * part 3: boundary_reader                                                 *
// ***************************************************************************

// @cat Boundary reader
// @section Http filters
// @cat


boundary_reader <: filter(
						pending:blob,
						boundary:string,
						last_boundary:string,
						at_boundary?:boolean = false,
						eof_reached?:boolean = false,
						pendingCRLF?:boolean = false)

//<sb> @doc Boundary reader
// boundary_reader implements a subset of RFC2046.
[boundary_reader!(self:port, bound:string) : boundary_reader ->
	let p := filter!(boundary_reader(), self)
	in (p.boundary := bound,
		p.last_boundary := bound /+ "--",
		p.pending := blob!(),
		p)]

[eof_port?(self:boundary_reader) : boolean ->
	remain_to_read(self.pending) = 0 &
		(self.at_boundary? | self.eof_reached?)]

[read_port(self:boundary_reader, buf:char*, len:integer) : integer ->
	if (self.at_boundary? | self.eof_reached?) 0
	else let n := 0
		in (while (len > 0)
				let m := read_port(self.pending, buf, len)
				in (len :- m,
					n :+ m,
					buf :+ m,
					if eof_port?(self.pending)
						(set_length(self.pending, 0),
						let l := freadline(self.target,"\r\n"),
							tl := trim(l)
						in (if (tl = self.boundary)
								(self.at_boundary? := true,
								self.pendingCRLF? := false,
								break())
							else if (tl = self.last_boundary)
								(self.eof_reached? := true,
								self.pendingCRLF? := false,
								break())
							else (if self.pendingCRLF?
									fwrite("\r\n", self.pending),
								fwrite(l, self.pending),
								self.pendingCRLF? := true)))),
			n)]


//<sb> @doc Boundary reader
// last_boundary?(self) checks the last end of file condition also
// correspond to the last boundary i.e. all bounded block have been
// read.
[last_boundary?(self:boundary_reader) : boolean -> self.eof_reached?]

//<sb> @doc Boundary reader
// reach_boundary(self) reset the end of file condition such we are ready
// to read a new bounded block.
[reach_boundary(self:boundary_reader) : void ->
	if not(self.eof_reached?)
		(set_length(self.pending, 0),
		self.pendingCRLF? := false,
		if self.at_boundary? self.at_boundary? := false
		else if not(self.eof_reached?)
			while true
				let l := freadline(self.target, "\n"),
					lt := trim(l)
				in (if (lt = self.boundary)
						(self.at_boundary? := false,
						break())
					else if (lt = self.last_boundary)
						(self.eof_reached? := true,
						break()),
					if eof?(self.target)
						error("Premature end of file for ~S", self)))]


// ***************************************************************************
// * part 4: html_special_char_converter                                     *
// ***************************************************************************
 

// @cat HTML special char convertion
// @section Http filters
// @cat

html_special_char_converter <: filter(do_slash_n_and_space?:boolean = true)

// @doc HTML special char convertion
// html_special_char_converter!(self) is equivalent to html_special_char_converter!(self, true).
html_special_char_converter!(self:port) : html_special_char_converter ->
	filter!(html_special_char_converter(), self)

// @doc HTML special char convertion
// html_special_char_converter!(self, convert_slash_n_and_space?) creates a new converter.
// A convertion is applied on each following chars :
// \ul
// \li "<" is concerted to "&lt;"
// \li ">" is concerted to "&gt;"
// \li "&" is concerted to "&amp;"
// \/ul
// When convert_slash_n_and_space? is true spaces and line feeds are also converted as follow :
// \ul
// \li " " is concerted to "&nbsp;"
// \li "%%\n" is concerted to "<br>%%\n"
// \/ul
// Notice that in the later case the %%\n is kept, this makes HTML outputs much more readable.
html_special_char_converter!(self:port, convert_slash_n_and_space?:boolean) : html_special_char_converter ->
	filter!(html_special_char_converter(do_slash_n_and_space? = convert_slash_n_and_space?),
			self)

write_port(self:html_special_char_converter, buf:char*, len:integer) : integer ->
	(for i in (1 .. len)
		let ch := buf[i]
		in case ch
			({'<'} fwrite("&lt;", self.target),
			{'>'} fwrite("&gt;", self.target),
			{'&'} fwrite("&amp;", self.target),
			any (if (do_slash_n_and_space? & ch = ' ')
					fwrite("&nbsp;", self.target)
				else if (do_slash_n_and_space? & ch = '\n')
					fwrite("<br>\n", self.target)
				else putc(ch, self.target))),
		len)



// ***************************************************************************
// * part 5: html_handler IO watcher                                         *
// ***************************************************************************

//<sb> html_watcher is used to save on disk both input and output
// message that goes through the HTTP handler - intended for debug
// purpose

html_watcher <: filter(watch_file:port)

html_watcher!(p:port, filename:string) : html_watcher ->
	filter!(html_watcher(watch_file = Core/disk_file!(filename,"a")), p)

close_port(self:html_watcher) : void ->
	(printf(self.watch_file, "==========================================================\n"),
	printf(self.watch_file, "  End of message on ~S\n", self.target),
	printf(self.watch_file, "==========================================================\n"),
	fclose(self.watch_file))


read_port(self:html_watcher, buf:char*, len:integer) : integer ->
	let n := read_port(self.target, buf, len)
	in (write_port(self.watch_file, buf, n),
		n)

write_port(self:html_watcher, buf:char*, len:integer) : integer ->
	(write_port(self.watch_file, buf, len),
	write_port(self.target, buf, len))


// ***************************************************************************
// * part 6: html_handler IO watcher                                         *
// ***************************************************************************

//<sb> html_watcher is used to save on disk both input and output
// message that goes through the HTTP handler - intended for debug
// purpose

freadline_bounder <: device(src:port, max_bytes:integer, index:integer = 0)

freadline_bounder!(p:port, m:integer) : freadline_bounder =>
	freadline_bounder(src = p, max_bytes = m)

eof_port?(self:freadline_bounder) : boolean ->
	eof_port?(self.src)

read_port(self:freadline_bounder, buf:char*, len:integer) : integer ->
	(if (self.index + len > self.max_bytes)
		error("freadline_max read more than ~S bytes on ~S", self.max_bytes, self.src),
	let n := read_port(self.src, buf, len)
	in (self.index :+ n,
		n))

freadline_max(self:port, m:integer) : string =>
	freadline(freadline_bounder!(self, m), "\r\n")


// ***************************************************************************
// * part 7: (de)encode64 on strings                                         *
// ***************************************************************************

encode64(s:string) : string ->
	let b := blob!(s)
	in (print_in_string(),
		encode64(b, cout(), 80),
		fclose(b),
		end_of_string())

decode64(s:string) : string ->
	let b := blob!(s)
	in (print_in_string(),
		decode64(b, cout()),
		fclose(b),
		end_of_string())
