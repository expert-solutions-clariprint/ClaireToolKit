
[mem_auto?() : boolean -> externC("(ClAlloc->mem_auto ? CTRUE : CFALSE)",boolean)]
[mem_maxlist() : integer ->
let n := 0
in (
	externC("CL_INT i = ClAlloc->maxList >> 18"),
	externC("while (i > 1) {n ++ ; i = i >> 1;} "),
	n)]
[mem_maxstack() : integer ->
let n := 0
in (externC("CL_INT i = ClAlloc->maxStack / 8000"),
	externC("while (i > 1) {n ++ ; i = i >> 1;}"),
	n)]


[option_respond(self:{"-systemd-install"}, l: list) : void 
-> 	//[0] install systemd script,
	let filename := "/etc/systemd" / last(explode(getenv("_"),"/")) /+ ".service"
	in (if (not(isfile?(filename)))
			(let f := fopen(filename,"w")
			in (
				fwrite("[Unit]\n",f),
				fwrite("Description=Claire FastCGI Service\n",f),
				fwrite("After=network-online.target\n",f),
				fwrite("[Service]\n",f),
				fwrite("Type=simple\n",f),
				fwrite("User=\n",f),
				fwrite("Group=\n",f),
				fwrite("UMask=007\n",f),
				fwrite("ExecStart=",f),
				fwrite(realpath(getenv("_")),f),
				if mem_auto?() fwrite(" -auto ",f),
				fwrite(" -auto ",f),

				fwrite("Restart=on-failure\n"),
				fwrite("TimeoutStopSec=300\n"),
				fwrite("[Install]\n"),
				fwrite("WantedBy=multi-user.target\n"),
				fclose("f")))
		else //[0] service file ~S already exists
		)]

	
[option_usage(opt:{"-install-systemd"}) : tuple(string, string, string) ->
	tuple("install-systemd",
			"-install-systemd",
			"The minimum number of seconds between the respawning of failed instances of this application. This delay prevents a broken application from soaking up too much of the system.
")]


[launchd_service_name() : string
-> "org.claire." /+ last(explode(getenv("_"),"/"))]



[option_respond(self:{"-launchd-install"}, l: list) : void 
-> 	let filename := "/Library/LaunchDaemons" / launchd_service_name() /+ ".plist"
	in (//[0] install launchd script ~S // filename,
		if (not(isfile?(filename)))
			(let f := fopen(filename,"w"),
				oldp := use_as_output(f)
			in ( princ("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"),
				?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string><?, princ(launchd_service_name()), ?></string>
    <key>ProgramArguments</key>
    <array>
        <string><?, princ(realpath(getenv("_"))), ?></string>
        <string>-s</string>
        <string><?, princ(mem_maxlist()), ?></string>
        <string><?, princ(mem_maxstack()), ?></string>
      	<? , if (mem_auto?()) ( ?>
        <string>-auto</string><? ), ?>
        <string>-cgi-user</string>
        <string>_www</string>
        <string>-fastcgi</string>
    </array>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist><?,
		use_as_output(oldp))))]

[option_usage(opt:{"-launchd-install"}) : tuple(string, string, string) ->
	tuple("launchd-install (MacOS)",
			"-launchd-install",
			"install launchd service ")]

[option_respond(self:{"-launchd-start"}, l: list) : void 
-> shell("launchctl load -w /Library/LaunchDaemons" / launchd_service_name() /+ ".plist")]

[option_usage(opt:{"-launchd-start"}) : tuple(string, string, string) ->
	tuple("launchd-start (MacOS)",
			"-launchd-start",
			"Start launchd service (launchctl load -w [service name])")]

[option_respond(self:{"-launchd-stop"}, l: list) : void 
-> shell("launchctl unload /Library/LaunchDaemons" / launchd_service_name() /+ ".plist")]

[option_usage(opt:{"-launchd-stop"}) : tuple(string, string, string) ->
	tuple("launchd-stop (MacOS)",
			"-launchd-stop",
			"stop launchd service")]

[option_usage(opt:{"-launchd-restart"}) : tuple(string, string, string) ->
	tuple("launchd-restart (MacOS)",
			"-launchd-restart",
			"restart launchd service")]

