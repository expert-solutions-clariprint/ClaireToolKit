
SYSLOG_KERN :: 0 //	kern	kernel messages
SYSLOG_USER :: 1 //	user	user-level messages
SYSLOG_MAIL :: 2 //	mail	mail system
SYSLOG_DEAMON :: 3 //	daemon	system daemons
SYSLOG_AUTH :: 4 //	auth	security/authorization messages
SYSLOG_SYSLOG :: 5 //	syslog	messages generated internally by syslogd
SYSLOG_LPR :: 6 //	lpr	line printer subsystem
SYSLOG_NEWS :: 7 //	news	network news subsystem
SYSLOG_UUCP :: 8 //	uucp	UUCP subsystem
SYSLOG_CLOCK :: 9 // clock daemon
SYSLOG_AUTH :: 10 // authpriv	security/authorization messages
SYSLOG_FTP :: 11 // ftp	FTP daemon
SYSLOG_NTP :: 12 // NTP subsystem
SYSLOG_AUSIT :: 13 // log audit
SYSLOG_ALERT :: 14 // log alert
SYSLOG_CRON :: 15 // cron	clock daemon
SYSLOG_LOCAL0 :: 16 //	local0	local use 0 (local0)
SYSLOG_LOCAL1 :: 17 //	local1	local use 1 (local1)
SYSLOG_LOCAL2 :: 18 //	local2	local use 2 (local2)
SYSLOG_LOCAL3 :: 19 //	local3	local use 3 (local3)
SYSLOG_LOCAL4 :: 20 //	local4	local use 4 (local4)
SYSLOG_LOCAL5 :: 21 //	local5	local use 5 (local5)
SYSLOG_LOCAL6 :: 22 //	local6	local use 6 (local6)
SYSLOG_LOCAL7 :: 23 //	local7	local use 7 (local7)

SYSLOG_EMERGENCY :: 0 //	Emergency emerg (panic) Système inutilisable.
SYSLOG_ALERT :: 1	// Alert alert Une intervention immédiate est nécessaire.
SYSLOG_CRITICAL :: 2	// Critical	crit	Erreur critique pour le système.
SYSLOG_ERROR :: 3	// Error	err (error)	Erreur de fonctionnement.
SYSLOG_WARNING :: 4	// Warning	warn (warning)	Avertissement (une erreur peut intervenir si aucune action n'est prise).
SYSLOG_NOTICE :: 5	// Notice	notice	Événement normal méritant d'être signalé.
SYSLOG_INFORMATIONAL :: 6 //	Informational	info	Pour information.
SYSLOG_DEBUGGING :: 7 // Debugging	debug	Message de mise au point.

syslogport <: device(
		logname:string = "",
		option:integer = 0,
		facility:integer = SYSLOG_USER,
		level:integer = SYSLOG_NOTICE,
		isopen?:boolean = false )

[use_syslog() : void -> let p := syslogport() in ctrace() := line_buffer!(p)]

[eof_port?(self:syslogport) : boolean -> true]

[flush_port(self:syslogport) : void -> none]

[read_port(self:syslogport, buf:char*, len:integer) : integer -> 0]

[write_port(self:syslogport, buf:char*, len:integer) : integer ->
	if not(self.isopen?) (
		externC("openlog(self->logname,self->option,self->facility)"),
		self.isopen? := true,
		//[4] openlog(name:~S,option:~A,facility:~A) / level:~A // self.logname, self.option, self.facility, self.level
		),
	if (len > 0) (
		externC("char* m = (char*)malloc(len + 1);"),
		externC("strncpy(m, buf, len);"),
		externC("m[len] = '\\0';"),
		externC("syslog(0,\"%s\",m);")),
	len]

[close_port(self:syslogport) : void -> externC("closelog()")]

[claire/option_respond(self:{"-syslog"}, l:list) : void -> 
	let p := syslogport() in (
		while (l & check_option(l[1],p)) (l << 1),
		ctrace() := line_buffer!(p))]

[option_usage(self:{"-syslog"}) : tuple(string, string, string) ->
	tuple("use syslogd as trace",
		"-dynload <options>",
		"options : usual syslog options, if unreconize, use as log name. ex : -syslog daemon alert pid nowait mydaemon")]

[syslogport!(opts:string) : port -> line_buffer!(check_options(opts,syslogport()))]

[check_options(self:syslogport,opts:string) : syslogport -> check_options(self,explode(opts," "))]
[check_options(self:syslogport,opts:list[string]) : syslogport -> for opt in opts check_option(opt,self),self]

[check_option(opt:string,self:syslogport) : boolean
->	if not(match_wildcard?(opt,"-*"))
		(case lower(opt) (
			{"kern"} self.facility := 0, //	kern	kernel messages
			{"user"} self.facility := 1, //	user	user-level messages
			{"mail"} self.facility := 2, //	mail	mail system
			{"deamon"} self.facility := 3, //	daemon	system daemons
			{"auth"} self.facility := 4, //	auth	security/authorization messages
			{"syslog"} self.facility := 5, //	syslog	messages generated internally by syslogd
			{"lpr"} self.facility := 6, //	lpr	line printer subsystem
			{"news"} self.facility := 7, //	news	network news subsystem
			{"uucp"} self.facility := 8, //	uucp	UUCP subsystem
			{"clock"} self.facility := 9, //		clock daemon
			{"auth"} self.facility := 10, //	authpriv	security/authorization messages
			{"ftp"} self.facility := 11, //	ftp	FTP daemon
			{"ntp"} self.facility := 12, //	-	NTP subsystem
			{"ausit"} self.facility := 13, //	-	log audit
			{"alert"} self.facility := 14, //	-	log alert
			{"cron"} self.facility := 15, //	cron	clock daemon
			{"local0"} self.facility := 16, //	local0	local use 0 (local0)
			{"local1"} self.facility := 17, //	local1	local use 1 (local1)
			{"local2"} self.facility := 18, //	local2	local use 2 (local2)
			{"local3"} self.facility := 19, //	local3	local use 3 (local3)
			{"local4"} self.facility := 20, //	local4	local use 4 (local4)
			{"local5"} self.facility := 21, //	local5	local use 5 (local5)
			{"local6"} self.facility := 22, //	local6	local use 6 (local6)
			{"local7"} self.facility := 23, //	local7	local use 7 (local7)
			{"emergency"} self.level := 0, //	Emergency	emerg (panic)	Système inutilisable.
			{"alert"} self.level := 1,	// Alert	alert	Une intervention immédiate est nécessaire.
			{"critical"} self.level := 2,	// Critical	crit	Erreur critique pour le système.
			{"error"} self.level := 3,	// Error	err (error)	Erreur de fonctionnement.
			{"warning"} self.level := 4,	// Warning	warn (warning)	Avertissement (une erreur peut intervenir si aucune action n'est prise).
			{"notice"} self.level := 5,	// Notice	notice	Événement normal méritant d'être signalé.
			{"informational"} self.level := 6, //	Informational	info	Pour information.
			{"debugging"} self.level := 7, // Debugging	debug	Message de mise au point.
			{"cons"} externC("self->option |= LOG_CONS"), // Write directly to system console if there is an error while sending to system logger.
			{"ndelay"} externC("self->option |= LOG_NDELAY"), // Open the connection immediately (normally, the connection is opened when the first message is logged).
			{"nowait"} externC("self->option |= LOG_NOWAIT"), // Don't wait for child processes that may have been created while logging the message. (The GNU C library does not create a child process, so this option has no effect on Linux.)

			{"odelay"}	externC("self->option |= LOG_ODELAY"), // The converse of LOG_NDELAY; opening of the connection is delayed until syslog() is called. (This is the default, and need not be specified.)

			{"perror"} externC("self->option |= LOG_PERROR"), // (Not in POSIX.1-2001 or POSIX.1-2008.) Print to stderr as well. 
			{"pid"} externC("self->option |= LOG_PID"), // Include PID with each message.
			
			any self.logname := opt), true)
	else false]




