
// *********************************************************************
// *   Part 6: line indenter                                           *
// *********************************************************************


trace_indenter <: filter(pending:blob) //<sb> a pending line


claire/trace_indenter!(self:port) : trace_indenter ->
	let lb := filter!(trace_indenter(), self)
	in (lb.pending := blob!(),
		lb)


flush_port(self:trace_indenter) : void ->
	let pend := self.pending,
		len := remain_to_read(pend)
	in (if (len > 0)
			(//<sb> the trace file may be shared by multiple processes
			// so build the indentation in the buffer before sending
			// the whole line in a single sys call
			if (len > 1 & wcl_handler_instance.soap_request?)
				unget(pend, "[SOAP]"),
			for i in (wcl_handler_instance.main_trace! .. system.trace!)
				unget(pend, ' '),
			write_port(self.target, externC("pend->data", char*), remain_to_read(pend)),
			pend.Core/read_index := 0,
			pend.Core/write_index := 0))

close_port(self:trace_indenter) : void -> fclose(self.pending)


write_port(self:trace_indenter, buf:char*, len:integer) : integer ->
	let pend := self.pending,
		nl := false,
		n := 0
	in (while (n < len)
			let n0 := n
			in (externC("while (1) {if (buf[n] == '\\n') {nl = CTRUE; break;}
									if (n + 1 == len) break;
									n++;}"),
				write_port(pend, buf + n0, n - n0 + 1),
				if nl
					(flush_port(self),
					nl := false),
				n :+ 1),
		len)

(Reader/NO_DEBUG_METHOD add (write_port @ trace_indenter))

// *********************************************************************
// *   Part 6: trace file support                                      *
// *********************************************************************

		
[setup_trace_file_from_env(self:wcl_handler, out:port) : void ->
	let tr_file := getenv("WCL_TRACE_FILE")
	in (try
			(if (length(tr_file) = 0)
				(//<sb> disable file trace
				ctrace() := null!(),
				for m in module
					m.verbose := false)
			else
				(//<sb> open the file used for trace
				if isenv?("WCL_USE_SYSLOG")
					Sys/use_syslog()
				else if not(isenv?("WCL_DEBUG"))
					self.trace_file :=
						close_target!(line_buffer!(
								Core/disk_file!(tr_file, "a")))
				else //<sb> in debug use smart indentation according
					// to the current stack depth
					self.trace_file :=
								close_target!(trace_indenter!(
									Core/disk_file!(tr_file, "a"))),
				ctrace() := self.trace_file,
				//[-100] == ~A ~A request (pid ~S) =========================================================== // (if self.soap_request? "SOAP" else "WCL"), getenv("WCL_SESSION_NAME"), getpid(),
				//[-100] ~A ~A ~A // getenv("REQUEST_METHOD"), getenv("PATH_INFO"), getenv("SERVER_PROTOCOL"),
				//[-100] Program : ~A // params()[1],
				//[-100] Args : ~A // list{i in params()| params()[1] != i}, 
				if isenv?("WCL_DEBUG")
					//[-100] Debug mode,
				//[-100] ~A // strftime("%c", now()),
				//[-100] Verbose ~S // verbose(),
				//[-100] Starting working directory [~A] // pwd(),
				//[-100] Path translated ~A // getenv("PATH_TRANSLATED"),
				if (length(self.session_id) > 0)
					//[-100] ~A session id : ~A // (if self.session_url? "Url" else "Cookie"), self.session_id
				else //[-100] No session id found ~S // getenv("WCL_SESSION"),
				//[-100] =============================================================================================
			))
		catch any
			error("Cannot open trace file :\n ~S", exception!()))]


[close_trace_file(self:wcl_handler) : void -> 
	let t := (try time_get() catch any 0)
	in (if self.child?
			(//[-100] == Child script execution caused ~S GC // externC("ClAlloc->numGC", integer),
			//[-100] == Child script executed in ~Sms (real time) ~Sms (process time) // elapsed(self.request_real_time), t,
			if (self.script_error_count > 0)
				//[-100] == ~S error(s) occured\n\n\n // self.script_error_count
			else //[-100] == Child script ok\n\n\n
			)
		else
			(//[-100] == Script execution caused ~S GC // externC("ClAlloc->numGC", integer),
			//[-100] == Script executed in ~Sms (real time)  ~Sms (process time) // elapsed(self.request_real_time), t,
			if (self.script_error_count > 0)
				//[-100] == ~S error(s) occured\n\n\n // self.script_error_count
			else //[-100] == Script ok\n\n\n
			),
		if known?(trace_file, self)
			(fclose(self.trace_file),
			erase(trace_file, self),
			ctrace() := null!()))]





[trace_error(self:wcl_handler, last_exception:exception) : void ->
	if known?(trace_file, self)
		(ctrace() := self.trace_file,
		let p := use_as_output(self.trace_file)
		in (printf("============ Script error ~S ============\n",
						self.script_error_count),
			for f in self.file_stack
				printf("  stop reading at ~I\n", print_location(f, false)),
			printf("~S\n", last_exception),
			use_as_output(p)))]
