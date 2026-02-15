/**
    Harbor server main source file

    author: Xavier Péchoultres <x.pechoultres@expert-solutions.fr>
*/


MAX_CHILDREN:integer := 10 // not used yet
SERVER_PORT:integer := 9090 // default port
SERVER_SOCKET:string := ""  // default: no socket
SERVE?:boolean := false     // active server mode

/*
   Harbor server command line options
*/
option_respond(self:{"-listen-port"}, l:list) : void ->
	(if not(l) invalid_option_argument(),
	SERVER_PORT := integer!(l[1]),
	l << 1)

/*
   Harbor server command line options
*/
option_respond(self:{"-listen-socket"}, l:list) : void ->
	(if not(l) invalid_option_argument(),
	SERVER_SOCKET := l[1],
	l << 1)

/*
   Harbor server command line options
*/
[option_respond(self:{"-serve"},l: list) : void -> SERVE? := true]

/* @doc Server
   Start Harbor server
*/
[start_server()
->  let s := (if (length(SERVER_SOCKET) > 0)
					(if isfile?(SERVER_SOCKET)
						(//[0] == Unlink an existing UNIX socket file [~A] // SERVER_SOCKET,
						unlink(SERVER_SOCKET)),
					server!(SERVER_SOCKET))
				else server!(SERVER_PORT)),
        children := 0
    in (//[0] Harbor server started on port ~S or socket // SERVER_PORT, SERVER_SOCKET,
        while (true)
            (//[0] waiting for new connection...,
            let incoming := accept(s)
            in (echo("New connection incoming...\n"),
                if (forker?()) (
                    children :+ 1,
                    if (children >= MAX_CHILDREN)
                        (//[0] max children reached, waiting for one to terminate...,
                        /*let pid := wait()
                        in (children :- 1,
                            //[0] child process ~S terminated // pid
                        )*/
                        none
                        ),
                    //[0] child process started
                ) else (
                    //[0] connection accepted,
                    let hdl := Http/http_handler!(incoming),
                        input := (hdl.Http/is_server? := true,
                                Http/parse_input(hdl)),
                        old_cout := use_as_output(hdl),
                        api_params := list<any>(hdl,lower(hdl.Http/http_method))
                    in (//[0] New connection accepted (pid ~S) // getpid(),
                        //[0] Traitement de ~S // hdl.Http/http_status_in,
                        let  url_parts := explode(hdl.Http/http_url, "?"),
                            url := url_parts[1],
                            paths := explode(url,"/") 
                        in (paths := paths << 1,
                            for p in paths  api_params :add p,
                            Http/header(hdl, "Content-Type: application/json"),
                            //[0] call the API with the parameters ~S // api_params,
                            try apply(api,api_params)
                            catch any
                                (printf("**** HARBOR API error:\n~S\n", exception!()),
                                Http/send_http_response(hdl,500))),
                        use_as_output(old_cout),
                        Http/terminate_http_response(hdl),
                        fclose(hdl),
                        exit(0))))))]


/*
   Harbor server request processing
*/
[option_parsed() : void ->
	if SERVE?
		try start_server()
		catch any
			(printf("**** HARBOR failure:\n~S\n", exception!()),
			exit(1))]

