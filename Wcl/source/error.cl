//*********************************************************************
//* CLAIRE                                            Sylvain Benilan *
//* error.cl                                                          *
//* Copyright (C) 2000 - 2004 xl. All Rights Reserved                 *
//*********************************************************************


//<sb> This file contains the code for error handling and debug in the
// web claire environment. The wcl debugger appends a report to the
// generated HTML page when an issue occur. the report is made of :
//		- trace lines where ~S/~A are converted in a link to a little
//			inspector (values are taken at the time of the trace)
//		- for errors the backtrace is reported and for each frame
//			a little file dump (around the frame location) is joined
//		- collect childs reports and insert them after the trace line
//			the of fork (recursive)

// note that in case of issue the content-type is forced to HTML and the
// binary content of the response (if not HTML) is dump in the head of
// the page with necessary HTML special char conversion and the report
// appended

// *********************************************************************
// *   Part 4: debug tools                                             *
// *********************************************************************

/*[load_wcl(self:{"/wcl_edit.wcl"}) : void ->
	if isenv?("WCL_DEBUG")
		let cmd := getenv("WCL_EDITOR")
		in (cmd := replace(cmd, "$(LINE)", $["line"]),
			cmd := replace(cmd, "$(FILE)", $["file"]),
			?><html>
				<body>
					<script language=javascript>
						window.close()
					</script>
				</body>
			</html><?
			//[-100] == WCL start of edit command ~S // cmd,
			let p := popen(cmd, "r")
			in (freadwrite(p, ctrace()),
				fclose(p)),
			//[-100] == WCL end of edit command ~S // cmd
			)
	else ?><html>
			<body>
				Sorry, you are not in debug mode
			</body>
			</html><? ]*/

wcl_breakpoint <: exception(data:integer)

BACKTRACE_NUM:integer := 0

//<sb> @doc Misceleanous
// backtrace appends the backtrace of the current execution context to
// report (would create a report if none exists) and continue.
claire/backtrace() : void -> claire/backtrace(true)
//<sb> @doc Misceleanous
// like backtrace() for each self that evals to a true expression (conditional).
claire/backtrace(self:any) : void -> 
	(if self
		(BACKTRACE_NUM :+ 1, 
		try wcl_breakpoint(data = BACKTRACE_NUM)
		catch any wcl_error()))

[self_print(self:wcl_breakpoint) : void ->
	printf("User breakpoint ~S - dump stack", self.data)]

(for m in backtrace.restrictions Reader/NO_DEBUG_METHOD add m)

SELF_HTML_FUNC :: (self_html @ any).functional //<sb> function cache

[claire/see(self:any) : void ->
	printf("<table width=\"100%\"><tr><td align=center><b>~I</b></table><br><table>~I</table>",
		funcall(SELF_HTML_FUNC, any, self, void),
		(case self
			(bag
				for i in self
					printf("<tr><td colspan=2>~I", funcall(SELF_HTML_FUNC, any, i, void)),
			object
				for rel in owner(self).slots
					let val := get(rel, self)
					in	(if (rel.selector = Core/data & self % blob)
							printf("<tr><td>~I</td><td>&lt;char*(~I)&gt;",
								funcall(SELF_HTML_FUNC, any, rel.selector, void),
								funcall(SELF_HTML_FUNC, any, string!(val, get(Core/write_index, self)), void))
						else
							printf("<tr><td>~I<td>~I",
								funcall(SELF_HTML_FUNC, any, rel.selector, void),
								funcall(SELF_HTML_FUNC, any, val, void))),
			any printf("<tr><td colspan=2>~I", funcall(SELF_HTML_FUNC, any, self, void)))))]


(Reader/NO_DEBUG_METHOD add (see @ any))


// *********************************************************************
// *   Part 4: report port                                             *
// *********************************************************************

report_indenter <: trace_indenter()
claire/report_indenter!(self:port) : report_indenter ->
	let lb := filter!(report_indenter(), self)
	in (lb.pending := blob!(),
		lb)

flush_port(self:report_indenter) : void ->
	let pend:blob := self.pending,
		len := remain_to_read(pend)
	in (if (len > 0)
			(//<sb> for the report just insert unbreakable space
			for i in (1 .. Core/current_frame.Core/num)
				fwrite("&nbsp;", self.target),
			write_port(self.target, externC("pend->data", char*), remain_to_read(pend)),
			pend.Core/read_index := 0,
			pend.Core/write_index := 0))


javacript_escaper <: filter()

javacript_escaper!(self:port) : javacript_escaper ->
	filter!(javacript_escaper(), self)

//<sb> javascript_escaper is used to write a javascript
// function argument (without '\n' or '"' ...)
// Note: the amp is converted in &amp; such we can pass an HTML
// string to a javascript call :
// 			&quot; => &amp;quot;
//  which is converted back by the HTML parser of the browser in &quot;
write_port(self:javacript_escaper, buf:char*, len:integer) : integer ->
	(externC("{char out[256]; char *travel = out;
		CL_INT i = 0;
		for(;i < len;i++) {
			switch (buf[i]) {
				case '\\n': {*travel++ = '\\\\'; *travel++ = 'n';break;}
				case '\\'': {*travel++ = '\\\\'; *travel++ = '\\'';break;}
				case '&': {*travel++ = '&'; *travel++ = 'a'; *travel++ = 'm'; *travel++ = 'p'; *travel++ = ';';break;}
				case '\\\"': {*travel++ = '\\\\'; *travel++ = '\"';break;}
				default : *travel++ = buf[i];
			}
			if (travel - out > 250) {
				Core.write_port->fcall((CL_INT)self->target, (CL_INT)out, (CL_INT)(travel - out));
				travel = out;
			}
		}
		if (travel - out > 0)
			Core.write_port->fcall((CL_INT)self->target, (CL_INT)out, (CL_INT)(travel - out));}"),
	len)

//<sb> do not use debug on the javascript escaper this would make
// the debug code slower
(Reader/NO_DEBUG_METHOD add (write_port @ javacript_escaper))


// *********************************************************************
// *   Part 4: reporting of objects (with embeded HTML inspector)      *
// *********************************************************************

start_end(self:bag) : tuple(string, string) ->
	let o := of(self)
	in (case self
			(tuple tuple("tuple(", ")"),
			list
				(if (o = {}) tuple("(", ")")
				else
					(print_in_string(),
					princ("list&lt;"),
					funcall(SELF_HTML_FUNC, any, o, void),
					princ("&gt;("),
					tuple(end_of_string(),")"))),
			any
				(if (o = {}) tuple("{", "}")
				else
					(print_in_string(),
					princ("set&lt;"),
					funcall(SELF_HTML_FUNC, any, o, void),
					princ("&gt;("),
					tuple(end_of_string(),")")))))

bag_link(self:bag, print?:boolean) : void ->
	(let (s,e) := (if print? start_end(self)
					else tuple("",""))
	in let first := true
	in (if print? princ(s),
		for x in self
			(if first first := false
			else princ(", "),
			val_link(x)),
		if print? princ(e)))

		
//<sb> prints an HTML link of a tuple var/val that opens a popup
// window with an inspector for the variable

[var_link(val:any, self:Variable) : void ->
	?><?== self ?>&#160;=&#160;<?
	case val
		({unknown} princ("unknown"),
		{nil} princ("nil"),
		{{}} princ("{}"),
		{Core/undefined_debug} princ("<i>undefined</i>"),
		float print(val),
		boolean print(val),
		integer princ(val),
		char funcall(SELF_HTML_FUNC, any, val, void),
		string funcall(SELF_HTML_FUNC, any, val, void),
		class funcall(SELF_HTML_FUNC, any, val, void),
		method funcall(SELF_HTML_FUNC, any, val, void),
//		property funcall(SELF_HTML_FUNC, any, val, void),
		bag bag_link(val, true),
		any let b := close_target!(javacript_escaper!(blob!())),
			p := use_as_output(b)
		in ( ?><title><?== self ?></title><?
			see(val),
			use_as_output(p),
			?><a onclick='javascript:pop_info("<? freadwrite(b, cout()) ?>", "<?oid val ?>")'><?==
				self ?> = <? funcall(SELF_HTML_FUNC, any, val, void)
			?></a><?
			fclose(b)))]

[val_link_princ(val:any) : void ->
	case val
		({unknown} princ("unknown"),
		{nil} princ("nil"),
		{{}} princ("{}"),
		{Core/undefined_debug} princ("<i>undefined</i>"),
		float print(val),
		integer princ(val),
		char ?><?== val,
		boolean ?><?== val,
		string ?><?== val,
		class ?><?== val,
		method ?><?== val,
//		property ?><?== val,
		bag bag_link(val, false),
		any let b := close_target!(javacript_escaper!(blob!())),
			p := use_as_output(b)
		in (see(val),
			use_as_output(p),
			?><a onclick='javascript:pop_info("<? freadwrite(b, cout()) ?>", "<?oid val ?>")'><?
				princ(val),
			?></a><?
			fclose(b)))]



[val_link(self:any) : void ->
	case self
		({unknown} princ("unknown"),
		{nil} princ("nil"),
		{{}} princ("{}"),
		{Core/undefined_debug} princ("<i>undefined</i>"),
		bag bag_link(self, true),
		float print(self),
		boolean print(self),
		integer princ(self),
		char funcall(SELF_HTML_FUNC, any, self, void),
		string funcall(SELF_HTML_FUNC, any, self, void),
		class funcall(SELF_HTML_FUNC, any, self, void),
		method funcall(SELF_HTML_FUNC, any, self, void),
//		property funcall(SELF_HTML_FUNC, any, self, void),
		filter
			(if unknown?(Core/dev, self)
				printf("&lt;unconnected&nbsp;~S&gt;", owner(self))
			else printf("&lt;~I~I&gt;",
					let b := close_target!(javacript_escaper!(blob!())),
						p := use_as_output(b)
					in (see(self.Core/dev),
						use_as_output(p),
						?><a style='border-bottom: dotted 1px grey;cursor:pointer' onclick='javascript:pop_info("<? freadwrite(b, cout()) ?>", "<?oid self.Core/dev ?>")'><?
								funcall(SELF_HTML_FUNC, any, owner(self.Core/dev), void)
						?></a><?
						fclose(b)),		
					(for f in self.Core/dev.Core/filters
						(if (f = self) princ("/*")
						else printf("/"),
						let b := close_target!(javacript_escaper!(blob!())),
							p := use_as_output(b)
						in (see(f),
							use_as_output(p),
							?><a style='border-bottom: dotted 1px grey;cursor:pointer' onclick='javascript:pop_info("<? freadwrite(b, cout()) ?>", "<?oid f ?>")'><?
									funcall(SELF_HTML_FUNC, any, owner(f), void)
							?></a><?
							fclose(b)),							
						if (f = self) princ("*"))))),
		device
			printf("&lt;*~I*~I&gt;",
				let b := close_target!(javacript_escaper!(blob!())),
					p := use_as_output(b)
				in (see(self),
					use_as_output(p),
					?><a style='border-bottom: dotted 1px grey;cursor:pointer' onclick='javascript:pop_info("<? freadwrite(b, cout()) ?>", "<?oid self ?>")'><?
							funcall(SELF_HTML_FUNC, any, owner(self), void)
					?></a><?
					fclose(b)),		
				(for f in self.Core/filters
					(princ("/"),
					let b := close_target!(javacript_escaper!(blob!())),
						p := use_as_output(b)
					in (see(f),
						use_as_output(p),
						?><a style='border-bottom: dotted 1px grey;cursor:pointer' onclick='javascript:pop_info("<? freadwrite(b, cout()) ?>", "<?oid f ?>")'><?
								funcall(SELF_HTML_FUNC, any, owner(f), void)
						?></a><?
						fclose(b))))),
		any
			let b := close_target!(javacript_escaper!(blob!())),
				p := use_as_output(b)
			in (see(self),
				use_as_output(p),
				?><a style='border-bottom: dotted 1px grey;cursor:pointer' onclick='javascript:pop_info("<? freadwrite(b, cout()) ?>", "<?oid self ?>")'><?
					((case self (exception ?><font color=red><? )),
					funcall(SELF_HTML_FUNC, any, self, void),
					(case self (exception ?></font><? )))
				?></a><?
				fclose(b)))]

(Reader/NO_DEBUG_METHOD add (bag_link @ bag))
(Reader/NO_DEBUG_METHOD add (start_end @ bag))
(Reader/NO_DEBUG_METHOD add (val_link @ bag))
(Reader/NO_DEBUG_METHOD add (var_link @ bag))
(Reader/NO_DEBUG_METHOD add (val_link_princ @ bag))

// *********************************************************************
// *   Part 4: reporting of debug frame                                *
// *********************************************************************


[show_source_lines_html(self:Core/dbg_frame, n:integer) : void ->
	?><div style='white-space:pre;font-family: Monaco,Courier,fixed;font-size: 10pt'><?
		try
			let src := self.Core/source,
				l := self.Core/line,
				c := self.Core/column,
				len := self.Core/length,
				f := fopen(src, "r"),
				i := 0
			in (princ("\n"),
				while not(eof?(f))
					(i :+ 1,
					if (i = l)
						(Core/edit_link(src, i, string!(i)) ?>: <?
						?><?== fread(f, c - 1)
						?><b style='color: red; background-color: rgb(250,200,200)'><?== fread(f, len)
						?></b><?== freadline(f, "\n") , princ("\n"))
					else if (i > l + n)
							break()
					else let line := freadline(f,"\n")
						in (if (i >= l - n)
								(Core/edit_link(src, i, string!(i)) ?>: <?
								?><?== line, princ("\n"),
								(if eof?(f) ?><font color=blue>&lt;EOF&gt;</font><? princ("\n"))
								))), princ("\n"),
				fclose(f))
		catch any
			(princ("\n"), (let c := color(2) in (print(exception!()), color(c))) , princ("\n"))
	?><div><? ]


[frame_onclick(self:Core/dbg_frame, wcl:wcl_handler) : void ->
	?>javascript: changeMode(document.getElementById("frame<?=
			self.Core/num
			?><?= wcl.script_error_count
			?><?= wcl.pid_path ?>"));<? ]

//<sb> this is an HTML version of the claire where (meta/toplevel.cl)
// call arguments are linked to a popup window with an litle inspector
// for the given argument
[html_frame_info(self:Core/dbg_frame, wcl:wcl_handler) : void ->
	?><tr><td style="cursor: pointer;border-top: solid 1px black;vertical-align: top"
				onclick='<? frame_onclick(self,wcl) ?>'><font color=green><b><?== self.Core/num ?>&gt;</b>&nbsp;</font><?
		?><td align=center style="cursor: pointer;border-top: solid 1px black;vertical-align: top"
				onclick='<? frame_onclick(self,wcl) ?>'><?==
								(when s := get(Core/frame_source, self)
								in (case s
										(method s.module!,
										tuple s[1],
										any module!()))
								else module!())
		?>&nbsp;&nbsp;&nbsp;<td align=right
				style="cursor: pointer;border-top: solid 1px black;vertical-align: top;font-family: Monaco,Courier,fixed;font-size: 10pt"
				onclick='<? frame_onclick(self,wcl) ?>'><?
						(if self.Core/catch? ( ?><font color=red><? )) //<sb> it is a handler frame
						?><?== (when s := get(Core/frame_source, self)
								in (case s
										(method s.selector,
										tuple s[2],
										any s))
								else "???")
						?><?
						(if self.Core/catch? ( ?></font><? ))
		?><td style="border-top: solid 1px black;vertical-align: top;font-family: Monaco,Courier,fixed;font-size: 10pt">(<?
			let i := 1,
				l := self.Core/vars,
				len := 2 * self.Core/dimension, // 2* because vars contains var,val pairs
				f? := true
			in while (i < len)
				let vn := l[i],
					vval := l[i + 1]
				in (i :+ 2,
					if f? f? := false else princ(",&nbsp;")
					?><font color=green><?== vn ?>&nbsp;=&nbsp;</font><?
					val_link(vval))
		?>)<?
	?><tr id="frame<?= self.Core/num ?><?= wcl.script_error_count ?><?= wcl.pid_path ?>" name="frame<?= self.Core/num ?><?= wcl.script_error_count ?><?= wcl.pid_path ?>" style="display: none;">
		<td colspan=4 style="border:none;background-color:#FFD"><?
			when src := get(Core/source, self)
			in ( ?><font color=green>File: </font><?== src ?><font color=blue></font><br><?
				show_source_lines_html(self, 5)),
			let i := 2 * self.Core/dimension + 1, // 2* because vars contains var,val pairs,
				l := self.Core/vars,
				len := length(l),
				f? := true
			in while (i < len)
				let vn := l[i],
					vval := l[i + 1]
				in (i :+ 2,
					if f? f? := false else princ("<br>")
					?><font color=green><?== vn ?>&nbsp;=&nbsp;</font><?
					val_link(vval))]

// *********************************************************************
// *   Part 4: reporting trace lines                                   *
// *********************************************************************

//<sb> each time a trace is issued Core calls restrictions
// of on_trace (warning: with no domain check)
[on_trace(m:module, self:string, i:integer, larg:list) : any ->
	if (wcl_handler_instance.wcl_main_called? &
				known?(report, wcl_handler_instance) &
				isenv?("WCL_DEBUG"))
		let p := use_as_output(wcl_handler_instance.report), 
			c := color(2),
			s := self, //replace(self, " ", "&nbsp;"),
			n := find(s, "~"),
			nl := 1,
			idx := 1,
			len := length(s),
			col:integer := externC("current_color",integer),
			bold:integer := externC("current_bold",integer),
			ccol:integer := col,
			cbold:integer := bold
		 in (while (0 < n & n < len)
			  let m := s[n + 1] in
				(if (n > 1) (color_princ(s, idx, n - 1),
							externC("{ccol = current_color; cbold = current_bold;}")),
				 if ('A' = m)
				 	(set_color(30,0),
				 	color(0),
				 	?><i><?
					val_link_princ(larg[nl]),
					?></i><?
					color(2),
					set_color(ccol, cbold))
				 else if ('S' = m)
				 	(set_color(30,0),
				 	color(0),
					?><i><?
					val_link(larg[nl]),
					?></i><?
					color(2),
					set_color(ccol,cbold))
				 else if ('I' = m) error("[143] ~I not allowed in report_trace", unknown),
				 if (m != '%') nl :+ 1,
				 idx := n + 2,
				 n := find(s, "~", idx)),
			if (idx <= len) color_princ(s,idx,len),
			set_color(col,bold),
			color(c),
			use_as_output(p))]

(Reader/NO_DEBUG_METHOD add last(on_trace.restrictions) as method)

// *********************************************************************
// *   Part 4: error handling                                          *
// *********************************************************************

[sigterm_handler() : void -> on_sigterm(wcl_handler_instance)]

(signal(SIGTERM, sigterm_handler))

[on_sigterm(self:wcl_handler) : void ->
	use_as_output(self),
	Http/ensure_http_headers_sent(self),
	if known?(trace_file, self)
		(//[-100] == SIGTERM received,
		close_trace_file(self)),
	Http/terminate_http_response(self),
	exit(1)]

soap_fatal_error :: property(open = 3)

//<sb> fatal errors are raised when an error is issued
// during the initialization of the wcl handler (not during
// script handling). For instance when a trace file is queried
// but cannot be opened for write.
[wcl_fatal_error(self:wcl_handler) : void ->
	self.script_error_count :+ 1,
	self.Http/force-content-type-html? := true,
	if not(self.Http/headers_out_sent?)
		(printf(self.Http/low_output, "Content-Type: text/html\r\n\r\n"),
		self.Http/output := self.Http/low_output,
		self.Http/headers_out_sent? := true,
		use_as_output(self.Http/low_output))
	else use_as_output(self),	
	if (self.soap_request?)
		soap_fatal_error(self)
	else if not(isenv?("WCL_HIDE_ERROR"))
		(complete_html(),
		printf("<b><font color=red>
					[WCL fatal error - abort:</font></b><br>
					~I<b><font color=red>~I]</font></b><br>",
						let c := color(2) in
							(print(exception!()), color(c)),
						let e := exception!()
						in case e
							(requested_file_not_found
								printf(" ~I", Core/edit_link(e.src, 1, e.src))))),
	if known?(trace_file, self)
		(printf(self.trace_file,
					"============ Script fatal error ~S ============\n",
					self.script_error_count),
		for f in self.file_stack
			printf(self.trace_file, "  last eval at ~I\n", Core/print_source_location(f)),
		printf(self.trace_file, "~S\n", exception!()),
		close_trace_file(self)),
	Http/terminate_http_response(self),
	exit(1)]



//<sb> this is the wcl error handler
// when an unhandled exception is raised and WCL_DEBUG exists
// in the environment of the process the wcl engine
// build a report concerning the error.
// a backtrace of the stack is performed at the point
// where the exception has been raised.
// it also force the underlying HTTP handler with a content
// type HTML such the report can be seen in place of the 
// queried content-type
[wcl_error() : void -> wcl_error(wcl_handler_instance, true)]
[wcl_error(self:wcl_handler, eval?:boolean) : void ->
	let last_exception := get(exception!, system),
		old_ctx := Reader/save_context(false),
		d? := Language/DEBUG?
	in (//<sb> recall the stack where exception has been raised
		let fr := (if isenv?("WCL_DEBUG") Core/current_frame)
		in (;Language/DEBUG? := false,
			//<sb> force the content-type of the returned page
			// to HTML such the error is human-readable
			if isenv?("WCL_DEBUG")
				self.Http/force-content-type-html? := true,
			Http/ensure_http_headers_sent(self),
			self.script_error_count :+ 1,
			if known?(trace_file, self)
				(trace_error(self, last_exception),
				if (eval? & isenv?("WCL_DEBUG") & not(last_exception %  Reader/syntax_error))
					(use_as_output(self.trace_file),
					princ("================== Backtrace ==================\n"),
					let f := fr
					in (while (f.Core/num > 0)
							(Reader/show_frame_info(f),
							f := f.Core/prev)),
					princ("===============================================\n"))),
			if (eval? & isenv?("WCL_DEBUG") & not(last_exception %  Reader/syntax_error))
				(//<sb> add the error report the the handler report
				// when in debug modes
				report_error(self, last_exception),
				flush(self.report),
				use_as_output(self.report.target),
				?><table cellspacing=0 cellpadding=0><tr><td><?
					for i in (1 .. Core/current_frame.Core/num) princ("&nbsp;"),
				?><td><?
				?><table style="border: solid black 1px;border-top:none;background-color: #FCC"
							cellspacing=0 cellpadding=0><?
				let f := fr
				in (while (f.Core/num > 0)
						(html_frame_info(f, self),
						f := f.Core/prev)),
				?></table></table><? ),
			use_as_output(self),
			//<sb> last, if not a Soap service, print
			// the error on the page, if the error is a syntax error
			// there is no stack dump
			if not(self.soap_request?)
				(if (isenv?("WCL_DEBUG") & last_exception % wcl_breakpoint)
					printf(">'>\"></script></textarea></input><div ~I><a href='#error~S~S' style='white-space: pre;color: red'>[Jump to breakpoint <b>~S</b>]</a></div>",
								debug_style("jump to error"),
								getpid(),
								self.script_error_count,
								last_exception.data)
				else if (eval? & isenv?("WCL_DEBUG") & not(last_exception %  Reader/syntax_error))
					printf(">'>\"></script></textarea></input><div ~I><a href='#error~S~S' style='white-space: pre;color: red'>[Jump to error <b>~S</b>]</a></div>",
								debug_style("jump to error"),
								getpid(),
								self.script_error_count,
								self.script_error_count)
				else if (isenv?("WCL_DEBUG") & (not(eval?) | last_exception %  Reader/syntax_error))
					printf(">'>\"></script></textarea></input><div ~I>[Reader error <b>~S</b> at <b>~I</b>:<br><font color=black>~I</font>]</div>",
								debug_style("jump to error"),
								self.script_error_count,
								print_location(last(self.file_stack), true),
								let c := color(2)
								in (print(last_exception),
									color(c)))
				else if not(isenv?("WCL_HIDE_ERROR"))
					printf(">'>\"></script></textarea></input><div ~I>[Error <b>~S</b>: <font color=black>~I</font>]</div>",
								debug_style("jump to error"),
								self.script_error_count,
								let c := color(2)
								in (print(last_exception),
									color(c))))),
		//<sb> before returning to the user code, retore the
		// execution context (at the time the error was catched)
		Language/DEBUG? := d?,
		Reader/restore_context(old_ctx),
		if (last_exception %  Reader/syntax_error)
			(//[-100] == Abort due to syntax error,
			Http/terminate_http_response(wcl_handler_instance),
			terminate_wcl_response(wcl_handler_instance),
			exit(1)))]


//<sb> prevent error handlers to be instrumented for debug
// it would modify the stack and make backtrace impossible
(Reader/NO_DEBUG_METHOD add (wcl_fatal_error @ wcl_handler))
(for r in wcl_error.restrictions
	Reader/NO_DEBUG_METHOD add r as method)


// *********************************************************************
// *   Part 6: reporting of errors                                     *
// *********************************************************************

//<sb> prints a link to an editable source file.
// one may define a WCL_EDITOR environment variable
// that should contain a shell command function of
// variables $(FILE) and $(LINE)
// for instance, (Mac OS X / TextWrangler.app):
//		edit +$(LINE) '$(FILE)'
[print_location(self:port, html?:boolean) : void ->
	(if (html? & isenv?("WCL_EDITOR"))
		let (f, l) := Core/get_location(self)
		in printf("<a href='claire://source-edit?file=~A&line=~S&editor=~A'>",
					url_encode(pwd() / last(explode(f, *fs*))),
					l,
					url_encode(getenv("WCL_EDITOR"))),
	Core/print_source_location(self),
	if (html? & isenv?("WCL_EDITOR"))
		princ("</a>"))]


[report_error(self:wcl_handler, last_exception:exception) : void ->
	let p := use_as_output(self.report),
		c := (printf("<a name='error~S~S'>", getpid(), self.script_error_count),
				color(2))
	in (if (last_exception % wcl_breakpoint)
			printf("``RED============== Breakpoint ~S ==============",
						last_exception.data)
		else printf("``RED============== Error ~S ==============",
						self.script_error_count),
		color(0),
		printf("</a><br>\n"),
		if self.file_stack
			printf("stop reading at ~I<br>\n", print_location(last(self.file_stack), true)),
		color(2),
		printf("~S", last_exception),
		color(c),
		use_as_output(p))]


// *********************************************************************
// *   Part 6: report dump                                             *
// *********************************************************************


//<sb> defines the javascript function used to show the
// content of an object in a popup window
[dump_javascripts() : void ->
?><!--

    -------------------------------------------------------------------
    -                    Debugger javascript tools                    -
    -------------------------------------------------------------------

--><script>
function pop_info(txt, id) {
	win = window.open('', id, 'menubar=0,width=300px,height=400px,resizable=yes');
	win.document.write(txt);
	win.document.close();
	win.focus();
}
function check_internet_explorer() {
	if (navigator.appName.search("Explorer") != -1)
		return true;
	return false;
}
function check_internet_explorer_mac() {
	if (check_internet_explorer())
		return (navigator.platform.search("Mac") != -1);
	return false;
}
function check_safari_mac() {
	return (navigator.userAgent.search("Safari") != -1);
}
function changeMode(obj) {
	var val = 'table-row';
	if (check_internet_explorer())
		val = 'block';
	if (obj.style.display != 'none' ) {
		obj.style.display = 'none';
	} else {
		obj.style.display = val;
	}
}
var httpObj;
var httpRecever;
function getHttpRequestObject() {
	var browser = navigator.appName;
	if(browser == "Microsoft Internet Explorer") {
		return new ActiveXObject("Microsoft.XMLHTTP");
	} else {
		return new XMLHttpRequest();
	}
}
function getRessourceDataTxt(id,obj,url) {
	httpRecever = obj;
	httpObj = getHttpRequestObject();
	httpObj.open('get', url + '?id=' + id);
	httpObj.onreadystatechange = parseInfo;
	httpObj.send('');
	return false;
}	
function parseInfo() {
	if(httpObj.readyState == 1){
		httpRecever.value =  'Loading...';
	}
	if(httpObj.readyState == 4){
		var answer = httpObj.responseText;
		httpRecever.value = answer;
	}
}
</script>
<? ]


/*
<script>
var div = document.createElement('div');
div.innerHTML = "<h1 style='background-color:red;border:solid lightgrey 1px'>You have errors</h1>";
var b = document.body;
if (b.childNodes) {
	b.insertBefore(div, b.childNodes[0]);
} else {
	b.appendChild(div);
}

</script>
*/

//<sb> make a basic html completion - attempt to
// reach a toplevel html element by adding closing
// elements, it also ensure that a pending attribute
// is closed
[complete_html() : void ->
?>>'>"></script></textarea></input>
</p></li></ul></table>
</li></ul></table>
<!--





*******************************************************************************
*                     Report attached by the Wcl debugger                     *
*******************************************************************************


-->
<div <? ?>>
<? ]


[debug_style(scope:{"jump to error"}) : void ->
	printf("style='font-size: 10pt;
	font-family: Monaco, Courier, fixed;
	text-align: left;
	vertical-align: center;
	border: none;
	background-color: none;
	color: red;'")]

[debug_style(scope:{"error intro"}) : void ->
	printf("style='font-size: 14pt;
	font-family: Monaco, Courier, fixed;
	font-weight: bold;
	text-align: left;
	vertical-align: center;
	border: none;
	background-color: none;
	color: red;'")]


//<sb> in debug we also have an environment dump
[dump_environment(self:wcl_handler) : void ->
	?><!--

    -------------------------------------------------------------------
    -                        Environment dump                         -
    -------------------------------------------------------------------

--><table class=WCL_DEBUG bgcolor="CCCCFF" cellspacing=0 cellpadding=2>
		<tr style="cursor: pointer;" onclick="javascript: changeMode(document.getElementById('env<?= self.pid_path ?>'));">
			<td>&nbsp;&nbsp;<b>+</b> <b>Environment</b>
		<tr id="env<?= self.pid_path ?>" name="env<?= self.pid_path ?>" style="display: none;">
			<td style="border-style: solid;border-color: black;border-width: 1px"> 
				<table cellspacing=0 cellpadding=2><?
					for i in (1 .. maxenv())
						let e := environ(i),
							pos= := find(e, "=")
						in ( ?><tr><td><?== substring(e, 1, pos= - 1)
								?><td><? if (pos= < length(e))
											( ?><?== substring(e, pos= + 1, length(e)))
										else ?><font color=red>empty</font><? )
				?></table>
	</table><? ]


//<sb> and a dump of $ family table (form vars)
[dump_$(self:wcl_handler) : void ->
	?><!--

    -------------------------------------------------------------------
    -                              $ dump                             -
    -------------------------------------------------------------------

--><table class=WCL_DEBUG bgcolor="CCFFCC" cellspacing=0 cellpadding=2>
		<tr style="cursor: pointer;" onclick="javascript: changeMode(document.getElementById('dollar<?= self.pid_path ?>'));">
			<td align=left>&nbsp;&nbsp;<b>+</b> <b>$ table</b>
		<tr id="dollar<?= self.pid_path ?>" name="dollar<?= self.pid_path ?>" style="display: none;">
			<td style="border-style: solid;border-color: black;border-width: 1px">
				<table cellspacing=0 cellpadding=1>
					<tr><?
					for i in (1 .. length($.mClaire/graph))
						(if (i mod 2 = 1 & known?($.mClaire/graph[i]))
							let v := $.mClaire/graph[i],
								val := $.mClaire/graph[i + 1]
							in ( ?><tr><td><font color=green><?== v
									?></font><td><? val_link(val)))
				?></table>
		<tr style="cursor: pointer;" onclick="javascript: changeMode(document.getElementById('dollar_keys<?= self.pid_path ?>'));">
			<td align=left>&nbsp;&nbsp;<b>+</b> <b>$keys table</b>
		<tr id="dollar_keys<?= self.pid_path ?>" name="dollar_keys<?= self.pid_path ?>" style="display: none;">
			<td style="border-style: solid;border-color: black;border-width: 1px">
				<table cellspacing=0 cellpadding=1>
					<tr><?
					for i in (1 .. length($keys.mClaire/graph))
						(if (i mod 2 = 1 & known?($keys.mClaire/graph[i]))
							let v := $keys.mClaire/graph[i],
								val := $keys.mClaire/graph[i + 1]
							in ( ?><tr><td><font color=green><?== v
									?></font><td><? val_link(val)))
				?></table>
		<tr style="cursor: pointer;" onclick="javascript: changeMode(document.getElementById('dollar_values<?= self.pid_path ?>'));">
			<td align=left>&nbsp;&nbsp;<b>+</b> <b>$values table</b>
		<tr id="dollar_values<?= self.pid_path ?>" name="dollar_values<?= self.pid_path ?>" style="display: none;">
			<td style="border-style: solid;border-color: black;border-width: 1px">
				<table cellspacing=0 cellpadding=1>
					<tr><?
					for i in (1 .. length($value.mClaire/graph))
						(if (i mod 2 = 1 & known?($value.mClaire/graph[i]))
							let v := $value.mClaire/graph[i],
								val := $value.mClaire/graph[i + 1]
							in ( ?><tr><td><font color=green><?== v
									?></font><td><? val_link(val)))
				?></table>
	</table><? ]
	
		
//<sb> print back the report to the end of the HTML
// page


[new_parent_report(self:wcl_handler) : void ->
	let b := blob!()
	in (self.reports :add wcl_parent_report_item(report = b),
		self.report := report_indenter!(b))]

[add_child_report(self:wcl_handler, sock:socket) : void ->
	self.reports :add wcl_child_report_item(child_socket = sock),
	new_parent_report(self)]


[parent_and_children_ok?(self:wcl_handler) : boolean ->
	if not(isenv?("WCL_DEBUG"))
		self.script_error_count = 0
	else
		(for c in self.reports
			case c
				(wcl_child_report_item
					(if unknown?(childok?, c)
						c.childok? := (getc(c.child_socket) != 'E'))),
		self.script_error_count = 0 &
			forall(r in self.reports |
						(case r (wcl_child_report_item r.childok?, any true))))]


[dump_reports(self:wcl_handler) : void ->
	dump_environment(self),
	dump_$(self),
	?><!--

    -------------------------------------------------------------------
    -                           Report dump                           -
    -------------------------------------------------------------------

--><?
	for r in self.reports
		case r
			(wcl_child_report_item
				(if not(r.childok?)
					( ?><table>
						<tr><td><?
							for i in (1 .. Core/current_frame.Core/num)
								fwrite("&nbsp;", cout())
						?><td><?
							freadwrite(r.child_socket, cout()),
					?></table><? ),
				fclose(r.child_socket)),
			wcl_parent_report_item
				(freadwrite(r.report, cout()),
				fclose(r.report))),
	shrink(self.reports, 0),
	put(report, self, unknown)]


[dump_parent_report(self:wcl_handler) : void ->
	use_as_output(self),
	complete_html(),
	dump_javascripts()
	?><hr><hr>
	<table bgcolor="white" cellspacing=0 cellpadding=0>
		<tr><td><p <? debug_style("error intro") ?>>
						The script issued
							<?= self.script_error_count ?>
									unhandled exception(s) :&nbsp;&nbsp;</p>
			<tr>
				<td><? 
					dump_reports(self)
			?></table>
	</table><? ]


[dump_soap_report(self:wcl_handler) : void ->
	?><table bgcolor="#CCCCCC" cellspacing=0 cellpadding=0>
		<tr style="cursor: pointer;" onclick="javascript: changeMode(document.getElementById('script<?= self.pid_path ?>'));">
			<td><p <? debug_style("error intro") ?>>
				&nbsp;&nbsp;+ The SOAP server-side script issued
					<?= self.script_error_count ?> 
						unhandled exception(s) :&nbsp;&nbsp;</p>
			<tr id="script<?= self.pid_path ?>" name="script<?= self.pid_path ?>" style="display: none;">
				<td><? 
					dump_reports(self)
			?></table><? ]

[dump_child_report(self:wcl_handler) : void ->
	let p := use_as_output(self.parent_socket)
	in ( ?>E<table bgcolor="#CCCC99" cellspacing=0 cellpadding=0>
			<tr style="cursor: pointer;" onclick="javascript: changeMode(document.getElementById('script<?= self.pid_path ?>'));">
				<td><p <? debug_style("error intro") ?>>
					&nbsp;&nbsp;+ The <? (if self.soap_request?
								?>SOAP server-side<? ) ?>
						child script <?= self.pid_path ?> issued
							<?= self.script_error_count ?>
								unhandled exception(s) :&nbsp;&nbsp;</p>
			<tr id="script<?= self.pid_path ?>" name="script<?= self.pid_path ?>" style="display: none;">
				<td><?
					dump_reports(self)
			?></table><?
		fclose(self.parent_socket),
		use_as_output(p))]



[dump_report(self:wcl_handler) : void ->
	if isenv?("WCL_DEBUG")
		let ok? := parent_and_children_ok?(self)
		in (if self.child?
				(if ok?
					(putc('N', self.parent_socket),
					fclose(self.parent_socket))
				else dump_child_report(self))
			else if not(ok?)
				(if self.soap_request? dump_soap_report(self)
				else dump_parent_report(self)))]

