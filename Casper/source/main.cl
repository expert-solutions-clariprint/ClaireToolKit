//*********************************************************************
//* CLAIRE                                            Sylvain Benilan *
//* main.cl                                                           *
//* Copyright (C) 2000 - 2004 xl. All Rights Reserved                 *
//*********************************************************************


/*********************************************************************/
/** global                                                           */
/*********************************************************************/

CASPER?:boolean := false

ALLOWED:string := "*"           //<sb> subset of acceptable connection address
LISTEN_PORT:integer := 10000    //<sb> the port on which the parent server listen
UNIX_SOCKET:string := ""		//<sb> the UNIX domain socket to use for the listener
TIMEOUT:integer := 30000        //<sb> parent kills a child that exceed this delay
MAX_CHILD:integer := 0          //<sb> max allowed children at a time
LOG_FILE:string := ""           //<sb> a file where to write logging info
PID_FILE:string := ""           //<sb> a file where to store parent pid - let admin know our pid
HAVE_PID_FILE?:boolean := false //<sb> a file where to store parent pid - let admin know our pid
NCHILD:integer := 0             //<sb> amount of running children
DEBUG_MODE?:boolean := false    //<sb> debug mode means no fork and single child
Child :: tuple(integer, float)  //<sb> child struct (pid, start time)
TIMEOUTED_CHILDREN:list[Child] := list<Child>() //<sb> a list filled with children that have reach timeout


/*********************************************************************/
/** login                                                            */
/*********************************************************************/

passwd <: import()
(c_interface(passwd, "struct passwd *"))
[getpwnam(username:string) : passwd -> function!(getpwnam)]

[init_user(username:string) : void ->
	//[-100] == Change privilege for user ~A // username,
	let pw := getpwnam(username)
	in (if externC("(pw == NULL ? CTRUE : CFALSE)", boolean)
			externC("Cerrorno(74,_string_(\"getpwnam\"),0)"),
		if externC("(setgid(pw->pw_gid) ? CTRUE : CFALSE)", boolean)
			externC("Cerrorno(74,_string_(\"setgid\"),0)"),
		if externC("(setuid(pw->pw_uid) ? CTRUE : CFALSE)", boolean)
			externC("Cerrorno(74,_string_(\"setuid\"),0)"))]
		

/*********************************************************************/
/** signals handlers                                                 */
/*********************************************************************/

SIGINT?:boolean := false
[sigint_handler() : void ->
	signal(SIGINT, SIG_IGN),
	SIGINT? := true]

SIGHUP?:boolean := false
[sighup_handler() : void ->
	signal(SIGHUP, SIG_IGN),
	SIGHUP? := true]


/*********************************************************************/
/** server initialization                                            */
/*********************************************************************/

option_usage(self:{"-casper"}) : tuple(string,string,string) ->
	tuple("Start casper", "-casper", "Runs a casper server loop.")

option_usage(self:{"-su"}) : tuple(string,string,string) ->
	tuple("Set User", "-su <u:user>",
			"Run under specified user privilege.")

option_usage(self:{"-allow-ip"}) : tuple(string,string,string) ->
	tuple("Firewall", "-allow-ip <mask:wildcard>",
			"Filter connection based on an ip <mask>.")

option_usage(self:{"-listen"}) : tuple(string,string,string) ->
	tuple("Port", "-listen <port:integer>",
			"Sets the listnening port (default 10000).")

option_usage(self:{"-unix-socket"}) : tuple(string,string,string) ->
	tuple("Port", "-unix-socket <file:path>",
			"Sets the file for the UNIX domain socket to use for the listener.")

option_usage(self:{"-maxchild"}) : tuple(string,string,string) ->
	tuple("Request", "-maxchild <n:integer>",
			"Number of simultaneous children. When 0 the " /+
			"request is handled by the parent (debug mode).")

option_usage(self:{"-timeout"}) : tuple(string,string,string) ->
	tuple("Timeout", "-timeout <ms:integer>",
			"Sets the maximun execution duration for a request to " /+
			"<ms> milliseconds (default 30000).")


option_usage(self:{"-log-file"}) : tuple(string,string,string) ->
	tuple("Log file", "-log-file <file:path>",
			"Redirect log lines to <file> (default is standard output).")

option_usage(self:{"-pid-file"}) : tuple(string,string,string) ->
	tuple("pid file", "-log-file <file:path>",
			"Produce a pid file.")

[option_respond(self:{"-casper"},l: list) : void -> CASPER? := true]

option_respond(self:{"-su"},l: list) : void ->
	(if not(l) invalid_option_argument(),
	init_user(l[1]),
	l << 1)

option_respond(self:{"-allow-ip"}, l:list) : void ->
	(if not(l) invalid_option_argument(),
	ALLOWED := l[1],
	l << 1)

option_respond(self:{"-listen"}, l:list) : void ->
	(if not(l) invalid_option_argument(),
	LISTEN_PORT := integer!(l[1]),
	l << 1)

option_respond(self:{"-unix-socket"}, l:list) : void ->
	(if not(l) invalid_option_argument(),
	UNIX_SOCKET := l[1],
	l << 1)

option_respond(self:{"-timeout"}, l:list) : void ->
	(if not(l) invalid_option_argument(),
	TIMEOUT := integer!(l[1]),
	l << 1)

option_respond(self:{"-maxchild"}, l:list) : void ->
	(if not(l) invalid_option_argument(),
	MAX_CHILD := integer!(l[1]),
	l << 1)

option_respond(self:{"-log-file"}, l:list) : void ->
	(if not(l) invalid_option_argument(),
	LOG_FILE := l[1],
	l << 1)

option_respond(self:{"-pid-file"}, l:list) : void ->
	(if not(l) invalid_option_argument(),
	PID_FILE := l[1],
	HAVE_PID_FILE? := true,
	l << 1)


[create_pid_file() : void ->
	if HAVE_PID_FILE?
		(if isfile?(PID_FILE)
			//[-100] == CASPER was unproperly terminated,
		//[-100] == Create pid file ~A for pid ~S // PID_FILE, getpid(),
		let pidfile := fopen(PID_FILE, "w")
		in (printf(pidfile, "~S", getpid()),
			fclose(pidfile),
			signal(SIGHUP, sighup_handler)))]


/*********************************************************************/
/** logging                                                          */
/*********************************************************************/


//<sb> add a new line in the log file
[add_log(self:string, l:list) : void ->
	try 
		let old := use_as_output(fopen(LOG_FILE,"a"))
		in (printf("[~S/~S] ", NCHILD, MAX_CHILD),
			format(self, l),
			printf(" [~A]\n", strftime("%d/%b/%Y:%X", now())),
			fclose(use_as_output(old)))
	catch any
		(printf(stderr, "[~S/~S] ", NCHILD, MAX_CHILD),
		let p := use_as_output(stderr)
		in (format(self, l),
			use_as_output(p)),
		printf(stderr, " [~A]\n", strftime("%d/%b/%Y:%X", now())))]


/*********************************************************************/
/** server loop                                                      */
/*********************************************************************/


//<sb> check for a new connection that is allowed
// reject other
[some_connection(s:listener) : (port U {unknown}) ->
	read!(s),
	if (select?(10) & readable?(s))
		let c := accept(s)
		in (if not(match_wildcard?(c.Core/address, ALLOWED))
				(add_log("Unallowed connection attempted from ~S", list(c)),
				fclose(c),
				unknown)
			else c)
	else unknown]



//<sb> check if any of our child has exited
// and if any remove it from the children list
// then test whether some child has reached a timeout
// and kill them brutaly
[check_children(children:list[Child]) : void ->
	//<sb> check for terminated children
	try while true
		let (exit_status, child, x) := waitpid(-1, false)
		in (if (exit_status != WRUNNING)
				(when c := some(c in children|c[1] = child)
				in (children :delete c,
					NCHILD :- 1),
				add_log("Child with pid ~S terminated [~S, ~S]", list(child, exit_status, x)))
			else break())
	catch any none,
	//<sb> check for timeouted children
	for i in (1 .. length(children))
		(if (elapsed(children[i][2]) > TIMEOUT)
			(try kill(children[i][1]) //<sb> kill perform waitpid
			catch any none,
			NCHILD :- 1,
			add_log("Child with pid ~S reached timeout [~S > ~S]",
						list(children[i][1], elapsed(children[i][2]), TIMEOUT)), 
			TIMEOUTED_CHILDREN :add children[i])),
	for k in TIMEOUTED_CHILDREN children :delete k,
	shrink(TIMEOUTED_CHILDREN, 0)]


NULL_CHAR :: make_string(1,'\0')

//<sb> read a casper env header that contains
// some vardef terminated by a double '\0'
// e.g: varname1=value1\0 ... varnameN=valueN\0\0
[read_environment(c:port) : void ->
	//[-100] == Read CASPER environment,
	while not(eof?(c))
		let vdef := freadline(c, NULL_CHAR)
		in (if (length(vdef) = 0) break(),
			if match_wildcard?(vdef, "*=*")
				(//[-100] ~A // vdef,
				setenv(vdef))),
	//[-100] == Environment read
	]

//<sb> fork as much as possible children (MAX_CHILD)
// and process the request from the child
[process_pending(s:listener, server_closed?:boolean, pending:list[port], children:list[Child]) : void ->
	while (pending & (MAX_CHILD = 0 | length(children) < MAX_CHILD))
		let c := pending[1]
		in (pending :delete c, //<sb> we found a slot for this child, remove from the pending list
			try
				(if (not(DEBUG_MODE?) & forker?())
					(fclose(c), //<sb> let the child deal with its socket
					NCHILD :+ 1,
					add_log("New child forked with pid ~S", list(forked())),
					children :add tuple(forked(), timer!())) //<sb> add this child to our running child list
				else
					(//<sb> childs should ignore SIGINT/SIGHUP
					if not(DEBUG_MODE?)
						(signal(SIGINT, SIG_IGN),
						signal(SIGHUP, SIG_IGN)),
					//<sb> we first close any parent socket we don't use
					if not(server_closed?) fclose(s),
					for o in pending fclose(o),
					//<sb> then we free parent pointers
					shrink(pending, 0),
					shrink(children, 0),
					//<sb> init client socket buffer for performance issue
					//set_send_size(c, 4096),
					try (read_environment(c), // extract environment
						if eof?(c) exit(1), // the connection has been closed ?!
						//[-100] == Call WCL main,
						Wcl/wcl_main(c, c))
					catch any
						(add_log("CASPER ERROR: ~S", list(exception!()))
						///[-100] == CASPER error: ~S // exception!()
						),
					try
						(//[-100] == CASPER close connection on ~S // c,
						linger(c))
					catch any none,
					//<sb> child can now exit
					exit(0)))
			catch any
				(add_log("Failed to fork process for connection ~S", list(c)),
				fclose(c)))]


/*********************************************************************/
/** server main                                                      */
/*********************************************************************/
	

[casper_loop() : void ->
	DEBUG_MODE? := (MAX_CHILD = 0),
	if (length(UNIX_SOCKET) > 0)
		//[-100] == Start CASPER server on UNIX domain socket ~A // UNIX_SOCKET
	else
		//[-100] == Start CASPER server on port ~S // LISTEN_PORT,
	let s := (if (length(UNIX_SOCKET) > 0)
					(if isfile?(UNIX_SOCKET)
						(//[-100] == Unlink an existing UNIX socket file [~A] // UNIX_SOCKET,
						unlink(UNIX_SOCKET)),
					server!(UNIX_SOCKET))
				else server!(LISTEN_PORT)),
		closed? := false,
		children := list<Child>(),
		pending := list<port>()
	in (signal(SIGINT, sigint_handler),
		
		if not(DEBUG_MODE?) create_pid_file()
		else if HAVE_PID_FILE?
			//[-100] == In debug mode no support for pid file,
		
		//<sb> enter server loop
		while (not(SIGINT?) & //<sb> SIGINT raised, abort
				not(SIGHUP? & closed? & not(pending) & not(children))) //<sb> SIGHUP raised, wait for all termination
			(if not(SIGHUP?)
				(when c := some_connection(s)
				in pending :add c)
			else if not(closed?)
				(//<sb> SIGHUP raised, do not accept any more connection and close server socket
				printf("**** SIGHUP raised\nWait for ~S pending and ~S children\n", length(pending), length(children)),
				fclose(s),
				closed? := true),
			if children check_children(children),
			if pending process_pending(s, closed?, pending, children)),
		
		//<sb> remove our pid file
		if (not(DEBUG_MODE?) & HAVE_PID_FILE?)
			(//[-100] == Remove pid file ~A // PID_FILE,
			unlink(PID_FILE)),
		
		//<sb> handle ^C termination
		if SIGINT?
			(printf("**** SIGINT raised\nKill ~S pending and ~S children\n", length(pending), length(children)),
			if children
				(add_log("Received SIGINT kill all children", list()),
				for c in children
					try kill(c[1]) //<sb> kill perform waitpid
					catch any none),
			for c in pending fclose(c),
			if not(closed?) fclose(s),
			exit(3)),
		
		//<sb> handle proper termination, unlink our pid file
		if SIGHUP?
			(fclose(s),
			unlink(PID_FILE),
			exit(0)))]


[option_parsed() : void ->
	if CASPER?
		try casper_loop()
		catch any
			(printf("**** CASPER failure:\n~S\n", exception!()),
			exit(1))]









N :: 50000

AAClass <: ephemeral_object()

l :: list<any>()

[load_wcl(self:{"*/bob.wcl"}) : void ->
	?>bob<?
	]


[load_wcl(self:{"*/list.wcl"}) : void ->
	(for i in (1 .. N)
		l add AAClass()) ?>OK<?
	]

$DIM :: 100

[load_wcl(self:{"*/bigtable.wcl"}) : void ->
	?><table><?

(for $r in (1 .. $DIM)
	(princ("<tr>"),
	let $col := ""
	in (for $c in (1 .. $DIM)
			$col :/+ "<td>" /+ string!($r) /+ "," /+ string!($c),
		princ($col))))


?></table><? ]

[load_wcl(self:{"*/bigtable-echo.wcl"}) : void ->
	?><table><?

(for $r in (1 .. $DIM)
	( ?><tr><?
	for $c in (1 .. $DIM)
		( ?><td><?= $r ?>,<?= $c)))


?></table><? ]

