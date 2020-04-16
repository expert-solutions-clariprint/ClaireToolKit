//*********************************************************************
//* CLAIRE                                            Sylvain Benilan *
//* main.cl                                                           *
//* Copyright (C) 2000 - 2004 xl. All Rights Reserved                 *
//*********************************************************************


/*********************************************************************/
/** global                                                           */
/*********************************************************************/

CASPER?:boolean := false
LAUNCHD?:boolean := false //<xp> falg for -launchd option

LISTEN_PORT:integer := 10000    //<sb> the port on which the parent server listen
PREFORK:integer := 5          //<sb> preforked children
UNIX_SOCKET:string := ""		//<sb> the UNIX domain socket to use for the listener

/*********************************************************************/
/** login                                                            */
/*********************************************************************/

passwd <: import()
(c_interface(passwd, "struct passwd *"))
[getpwnam(username:string) : passwd -> function!(getpwnam)]

[init_user(username:string) : void ->
	//[-100] == Change privilege for user ~A // username,
	let pw:passwd := getpwnam(username)
	in (if externC("(pw == NULL ? CTRUE : CFALSE)", boolean)
			externC("Cerrorno(74,_string_(\"getpwnam\"),0)"),
		if externC("(setgid(pw->pw_gid) ? CTRUE : CFALSE)", boolean)
			externC("Cerrorno(74,_string_(\"setgid\"),0)"),
		if externC("(setuid(pw->pw_uid) ? CTRUE : CFALSE)", boolean)
			externC("Cerrorno(74,_string_(\"setuid\"),0)"))]


/*********************************************************************/
/** server initialization                                            */
/*********************************************************************/

option_usage(self:{"-casper"}) : tuple(string,string,string) ->
	tuple("Start casper", "-casper", "Runs a casper server loop.")

option_usage(self:{"-su"}) : tuple(string,string,string) ->
	tuple("Set User", "-su <u:user>",
			"Run under specified user privilege.")


option_usage(self:{"-listen"}) : tuple(string,string,string) ->
	tuple("Port", "-listen <port:integer>",
			"Sets the listnening port (default 10000).")


option_usage(self:{"-prefork"}) : tuple(string,string,string) ->
	tuple("Request", "-prefork <n:integer>",
			"Number of preforked children. When 0 the " /+
			"request is handled by the parent (debug mode).")

option_usage(self:{"-unix-socket"}) : tuple(string,string,string) ->
	tuple("Port", "-unix-socket <file:path>",
			"Sets the file for the UNIX domain socket to use for the listener.")

option_usage(self:{"-show-limits"}) : tuple(string,string,string) ->
	tuple("", "-show-limits",
			"Trace system limits for the process (verbose 0)")


[option_respond(self:{"-casper"},l: list) : void -> CASPER? := true]

option_respond(self:{"-su"},l: list) : void ->
	(if not(l) invalid_option_argument(),
	init_user(l[1]),
	l << 1)


option_respond(self:{"-listen"}, l:list) : void ->
	(if not(l) invalid_option_argument(),
	LISTEN_PORT := integer!(l[1]),
	l << 1)


option_respond(self:{"-prefork"}, l:list) : void ->
	(if not(l) invalid_option_argument(),
	PREFORK := integer!(l[1]),
	PREFORK :max 1,
	l << 1)

option_respond(self:{"-unix-socket"}, l:list) : void ->
	(if not(l) invalid_option_argument(),
	UNIX_SOCKET := l[1],
	l << 1)

option_respond(self:{"-show-limits"}, l:list) : void -> (showlimits, l << 1)


// <xp>
[option_respond(self:{"-launchd"}, l:list) : void -> LAUNCHD? := true]

// <xp>
option_usage(self:{"-launchd"}) : tuple(string,string,string) ->
	tuple("Start casper as launchd daemon", "-launchd", "Runs a casper server loop in a launched controlled environement (Mac OSX)")


/*********************************************************************/
/** logging                                                          */
/*********************************************************************/



NULL_CHAR :: make_string(1,'\0')

//<sb> read a casper env header that contains
// some vardef terminated by a double '\0'
// e.g: varname1=value1\0 ... varnameN=valueN\0\0
[read_environment(c:port) : void ->
	while not(eof?(c))
		let vdef := freadline(c, NULL_CHAR)
		in (if (length(vdef) = 0) break(),
			if match_wildcard?(vdef, "*=*")
				setenv(vdef))]


//<sb> the master loop start the listening socket
// and control that there is enought preforked children
[master_loop() : void ->
	let server := (if (length(UNIX_SOCKET) > 0)
					(if isfile?(UNIX_SOCKET) unlink(UNIX_SOCKET),
					server!(UNIX_SOCKET, -1, 20))
				else server!("", LISTEN_PORT, 20)),
		children := list<integer>()
	in (gc(), //<sb> sanity clenup of memory before forking...
		// //[0] master_loop: pgid=~S // pgid,
		while true
			(while (length(children) < PREFORK)
				try
					(if forker?() children add forked()
					else casper_loop(server))
				catch any none,
			let (exit_status, pid, x) := waitpid(-1)
			in (if (exit_status != WRUNNING)
					children delete pid)),
		exit(0))]

[casper_loop(server:listener) : void ->
	try
		let c := accept(server)
		in (fclose(server),
			read_environment(c), // extract remote environment (CGI like)
			Wcl/wcl_main(c, c),
			linger(c),
			externC("exit(0)"))
	catch any none,
	exit(0)]


[option_parsed() : void ->
	if LAUNCHD? lauchd_loop() // <xp> start lauchd_loop()
	else if CASPER?
		try master_loop()
		catch any
			(printf("**** CASPER failure:\n~S\n", exception!()),
			exit(1))]


/*------------------------------------------------------------
		launchd mode  (Mac OSX / Darwin) 
		replacing -capser on launchd environments
----------------------------------------------------------------*/

// <xp> pid of child running the master_loop()
LAUNCHD_CHILD:integer := 0
LAUNCHD_TIME_START:float := 0.0

// [raiseErrorno(val:string) : void ->	externC("Cerrorno(74,_string_(val),0);")]

[getpgrp() : integer ->  externC("getpgrp()",integer)]

[killpg(p:integer, sig:signal_handler) : void ->
	externC("\n#if defined(CLPC) || !defined(HAVE_KILL)
		Cerror(75,_string_(\"kill\"),0);
	#else
		if(killpg(p,sig->signo) == -1)
			Cerrorno(86,_integer_(p),_integer_(sig->signo));
	#endif
	")]

[setpgrp() : integer ->  externC("getpgrp()",integer)]
	
[setpgid(p:integer,c:integer) : integer
->	externC("setpgid(p,c)",integer)]

[getpgid(p:integer) : integer
->	externC("getpgid(p)",integer)]

[on_sighup() : void
->	//[0] on_sighup(),
	try (if (LAUNCHD_CHILD > 0) 
		let pgid := getpgid(LAUNCHD_CHILD)
		in killpg(pgid,SIGKILL),
		LAUNCHD_CHILD := 0)
	catch any //[0] error killing child(~S) : ~S // LAUNCHD_CHILD, exception!()
]

[on_sigterm() : void -> (on_sighup(), exit(0))]

[getrlimit(self:integer) : tuple(integer,integer)
->	externC("struct rlimit limit;"),
	externC("getrlimit(self, &limit)"),
	tuple(externC("limit.rlim_cur",integer),externC("limit.rlim_max",integer))]

[showlimits() : void
->
	//[0] RLIMIT_CPU     cpu time per process : ~S // getrlimit(0),
	//[0] RLIMIT_FSIZE   file size : ~S // getrlimit(1),
	//[0] RLIMIT_DATA    data segment size : ~S // getrlimit( 2),
	//[0] RLIMIT_STACK   stack size : ~S // getrlimit( 3),
	//[0] RLIMIT_CORE    core file size : ~S // getrlimit( 4),
	//[0] RLIMIT_AS      address space (resident set size) : ~S // getrlimit( 5),
	//[0] RLIMIT_MEMLOCK locked-in-memory address space : ~S // getrlimit( 6),
	//[0] RLIMIT_NPROC   number of processes : ~S // getrlimit( 7),
	//[0] RLIMIT_NOFILE  number of open files : ~S // getrlimit( 8),
	//[0] RLIM_NLIMITS   total number of resource limits : ~S // getrlimit(9)
]

[lauchd_loop() : void
->	signal(SIGTERM,on_sigterm),
	signal(SIGHUP,on_sighup),
	let start_time := now(),
		filename := getenv("_")
	in (while true
				(if (LAUNCHD_CHILD = 0)
						(if forker?() (
							LAUNCHD_CHILD := forked(),
							setpgid(LAUNCHD_CHILD,getpgrp()),
							none
							)
						else master_loop()),
				if (LAUNCHD_CHILD > 0)
					(try let status := waitpid(LAUNCHD_CHILD,false)
					in (none)
					catch any 
						(//[0] child error = ~S // exception!(),
						LAUNCHD_CHILD := 0)),

				if isfile?(filename) (if (fchanged(filename) > start_time) on_sighup())
				else //[0] Warning file ~S not found // filename,

				sleep(5000)))]
