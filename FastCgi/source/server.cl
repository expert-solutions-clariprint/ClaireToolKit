


SIGINT?:boolean := false
[sigint_handler() : void ->
	signal(SIGINT, SIG_IGN),
	SIGINT? := true]

SIGHUP?:boolean := false
[sighup_handler() : void ->
	signal(SIGHUP, SIG_IGN),
	SIGHUP? := true]


[create_server() : listener
->	if (CGI_HOST != "" & CGI_PORT > 0) server!(CGI_HOST, CGI_PORT, 10)
	else if (CGI_PORT > 0) server!(CGI_PORT)
	else if (CGI_SOCKET != "") server!(CGI_SOCKET)
	else (
		CGI_SOCKET := "/tmp/" /+ last(explode(getenv("_"),"/")) /+ ".sock",
		if isfile?(CGI_SOCKET) unlink(CGI_SOCKET),
		//[0] use socket ~S // CGI_SOCKET,
		server!(CGI_SOCKET))]


prefork:integer := 5

/* Server */
[serve() : void
->	//[0] server pid: ~S // getpid(),
	let s := create_server(),
		n_childs := 0,
		children := list<integer>()
	in (while true (
			if (forker?())
				(n_childs :+ 1,
				if (n_childs >= prefork) (
					//[0] enough children wait ...,
					if (waitpid(-1)) (n_childs :- 1)))
			else (
				let c := accept(s),
					ctx := record_port!(c)
				in (//[0] accept,
					decode_records(ctx),
					for h in sort(sort_cgi_handler @ cgi_handler,cgi_handlers)
						try (
							apply(h.callback, list(ctx,h.callback_ctx))
						) catch any (
							//[0] error in callback ~S // exception!()
						),
					// send_reponse(ctx),
					//[0] end process,
					fclose(ctx),
					flush(ctx),
					//[0] exit,
					exit(0)))))]

[script() : void
-> let //c := client!(getnev(client!()
		ctx := record_port!(stdin)
	in (decode_records(ctx),
		for h in sort(sort_cgi_handler @ cgi_handler,cgi_handlers)
			try (
				apply(h.callback, list(ctx,h.callback_ctx))
			) catch any (
				//[0] error in callback ~S // exception!()
			),
			// send_reponse(ctx),
			//[0] end process,
			fclose(ctx),
		flush(ctx),
		//[0] exit,
		exit(0))]


