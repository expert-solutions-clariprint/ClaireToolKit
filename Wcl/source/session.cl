// *********************************************************************
// *   Part 3: session vars                                            *
// *********************************************************************

// @cat Session
// Due to the architecture of client/server application we need a way to
// store server-side temporary datas between two client requests.
// These temporary datas are called session datas and are saved in a server
// side file between requests.
// A client is identified by a session ID that is transmited between the
// server and the client in each request. 
// Wcl comes with two strategies for the ID transmition :
// \ul
// \li In an HTTP cookie by session_cookie().
// \li Directly on the URL by session_url().
// \/ul
// session_cookie() or session_url() would either load an existing session
// or, if none exists at the time of the call, create a new session with a new
// session ID. Using cookie require that the client browser supports and allows
// cookies. URL sessions are smarter since they don't need configuration of the
// client broswer at all.
// Notice that a session should be started before actualy sending data an error would
// be raised othewise.\br
// Once a session is started we may add new entries in the session. Entries are
// identified by a variable name (string) and may hold any object, the register
// register method would insert a new entry in the session, for instance :
// \code
// register("counter", 0)
// \/code
// Once a variable has been registered it comes accessible through the $ table :
// \code
// (assert($["counter"] = 0))
// \/code
// When the executed script ends the session (all registered objects) is automaticaly
// saved in the session file. This operation relies on the serialize facility. 
// Sometimes we need to register an object and also the relations of that object that
// are themself objects (i.e. not primitive or bag), we call that recursive registering
// and we would use rregister. For instance let's consider the following script that
// manage a simple fruit's basket :
// \code
// item <: ephemeral_object(name:string, quantity:integer)
// basket <: ephemeral_object(items:list[item])
//
// (if ($["add_item"] & $["basket"])
// 	$["basket"].items add
// 		item(name = $["name"],
// 			quantity = integer!($["quantity"])))
//
// (session_url()) // starts a session
//
// (if not($["basket"]) // register a new basket
// 	rregister("basket", basket()))
//
// ?>Your basket :
// <table><?
// 	for i in $["basket"].items
// 		( ?><tr><td><?== i.quantity ?> <?== i.name)
// ?></table><?
//
// ?>Add item to your basket :
// <form>
// 	<select name='name'>
// 		<option value='banana'>banana
// 		<option value='orange'>orange
// 	</select>
// 	<input type=text name='quantity'>
// 	<input type=submit name='add_item'>
// </form><?
// \/code
// If we had use a simple register, the items added to the basket would not have been
// inserted in the session whereas the use of rregister tells to recurse the item objects.\br
// At the time a session is saved the session file is locked to avoid multiple write
// access so that, for instance, a page that defines multiple frames for a single session
// does not alter the session file.
// @cat

claire/$SESSION[vname:string] : any := false

[claire/session_file() : string => getenv("WCL_SESSION_PATH") / getenv("WCL_SESSION_NAME") /+ "-" /+ getenv("WCL_SESSION") /+ ".session"]

[claire/session_exists?() : boolean -> isfile?(session_file())]

[claire/session_started?() : boolean -> wcl_handler_instance.session_started?]


[rnew_session_id() : string
->	if not(isfile?("/dev/random")) new_session_id()
	else let v := make_string(26), rest := 26, cur := 1, rf := fopen("/dev/random","r"), sr := fread(rf,26), sri := 1
		in (while (cur <= 26) (
				let p := string!(integer!(sr[sri]))
				in (sri :+ 1,
					for i in (1 .. length(p))
						(v[cur] := p[i],
						cur :+ 1,
						if (cur > 26) break()))),
			fclose(rf),
			v)]



[new_session_id() : string
->  random!(now() * float!(getpid())),
	(let v := make_string(26), pi := string!(getpid()), pl := length(pi) in (
		for i in (1 .. pl) v[i] := pi[i],
		pl :+ 1,
		for i in (pl .. 26) v[i] := char!(integer!('0') + random(10)), v))]


[private/session_start() : void ->
	if not(wcl_handler_instance.session_started?)
		(if wcl_handler_instance.Http/headers_out_sent?
			error("Attemp to start a session whereas HTTP header already sent")
		else
			(wcl_handler_instance.session_started? := true,
			let sid := getenv("WCL_SESSION"),
				load? := false
			in (if (length(sid) = 26 & digit?(sid))
					(
					/*
					if not(session_exists?())
						fclose(fopen(session_file(), "w"))
					else load? := true,
					*/
					load? := session_exists?(),
					//[-100] == Starting a session with id [~A] // getenv("WCL_SESSION")
					)
				else if (length(sid) != 26 | not(digit?(sid)))
					(
					setenv("WCL_SESSION=" /+ new_session_id()),
//					fclose(fopen(session_file(), "w")),
					//[-100] == Starting a new session with id [~A] // getenv("WCL_SESSION")
					),
				if load?
					try let f := fopen(session_file(), "r")
						in (if islocked?(f)
								//[-100] == Wait for session lock to be released [~A] // getenv("WCL_SESSION"),
							flock(f), //<sb> query exclusive access on the file
							try (let (regtreeobj, regobj) := unserialize(f)
								in (for x in regobj
										(wcl_handler_instance.registered_object :add x[1] as string,
										$SESSION[x[1]] := x[2],
										$[x[1]] := x[2]),
									for x in regtreeobj
										(wcl_handler_instance.registered_tree_object :add x[1] as string,
										$SESSION[x[1]] := x[2],
										$[x[1]] := x[2])))
							catch any
								(//[-100] == Session unserialization error \n~S // exception!(),
								wcl_handler_instance.session_started? := false),
							fclose(f))
					catch any wcl_error(wcl_handler_instance, true)),
			//[-100] == Session started [~A] [~A] // wcl_handler_instance.registered_object, wcl_handler_instance.registered_tree_object
			))
		else //[-100] == Warning: Attemp to restart a session // 
		]

[session_load(fsession:string) : void ->
	try let f := fopen(fsession, "r")
		in (if islocked?(f)
				//[-100] == Wait for session lock to be released [~A] // fsession,
			flock(f), //<sb> query exclusive access on the file
			try (let (regtreeobj, regobj) := unserialize(f)
				in (for x in regobj
						($[x[1]] := x[2], $SESSION[x[1]] := x[2]),
					for x in regtreeobj
						($[x[1]] := x[2], $SESSION[x[1]] := x[2])))
			catch any
				(//[-100] == Session unserialization [~A] error \n~S // fsession, exception!(),
				wcl_handler_instance.session_started? := false),
			fclose(f))
	catch any wcl_error(wcl_handler_instance, true)]

[claire/session_lock() : void ->
	if (wcl_handler_instance.session_started? & not(wcl_handler_instance.session_locked?))
		(wcl_handler_instance.session_locked_file := fopen(session_file(), "a"),
		if islocked?(wcl_handler_instance.session_locked_file)
			//[-100] == Wait for session lock to be released [~A] // getenv("WCL_SESSION"),
		flock(wcl_handler_instance.session_locked_file),
		wcl_handler_instance.session_locked? := true,
		//[-100] == Session locked [~A] // getenv("WCL_SESSION")
		)]


// @doc Session
// session_url() starts a client session. Unlike session-cookie(), session_url()
// transmit the session ID (which identifies the client) on the URL. It is a more
// portable way than session_cookie since it does not require that the client
// allows cookies. If a session with a matching ID already exists then its data
// are loaded in memory.
[claire/session_url() : void ->
	if wcl_handler_instance.session_url? session_start()
	else
		(session_start(),
		wcl_handler_instance.session_url? := true)]


// @doc Session
// session_cookie() starts a session. The ID of the session is transmitted in
// a cookie. The client should support and allow cookies. If a session with a
// matching ID already exists then its data are loaded in memory.
[claire/session_cookie() : void => session_start()]

[session_cookie(pth:string) : void =>
	wcl_handler_instance.cookie_path := pth,
	session_start()]
[session_cookie(nday:integer) : void ->
	wcl_handler_instance.cookie_date := date_add(now(), 'd', nday),
	session_start()]
[session_cookie(pth:string, nday:integer) : void ->
	wcl_handler_instance.cookie_date := date_add(now(), 'd', nday),
	wcl_handler_instance.cookie_path := pth,
	session_start()]
[session_cookie(d:float) : void =>
	wcl_handler_instance.cookie_date := d,
	session_start()]
[session_cookie(pth:string, d:float) : void =>
	wcl_handler_instance.cookie_date := d,
	wcl_handler_instance.cookie_path := pth,
	session_start()]

[session_auto_save(auto_save?:boolean) : void => wcl_handler_instance.session_started? := auto_save?]

//<sb> @doc Session
// session_destroy() detroys an existing session. If the associated file that
// contain session datas then it is unlinked.
[claire/session_destroy() : void -> 
	if known?(trace_file, wcl_handler_instance)
		//[-100] == Session destroy [~A] // getenv("WCL_SESSION"),
	try (if isfile?(session_file())
			(unlink(session_file()),
			//[-100] == Session file removed [~A] // session_file()
			)
		else //[-100] == No session file to remove
		)
	catch any
		//[-100] == Failed to remove session file [~A] :\n~S // session_file(), exception!(),
	setenv("WCL_SESSION="), //<sb> erase session id
	erase($SESSION),
	wcl_handler_instance.session_started? := false,
	wcl_handler_instance.registered_tree_object := set<string>(),
	wcl_handler_instance.registered_object := set<string>()]


	
//<sb> @doc Session
// session_clean_but(l) removes all datas from a session execpt those
// specified in l.
[claire/session_clean_but(l:bag) : any ->
	if known?(trace_file, wcl_handler_instance)
		//[-100] == Session clean but [~A] // l,
	wcl_handler_instance.session_started? := true,
	for s in list{s in copy(wcl_handler_instance.registered_object)|not(s % l)}
		($[s] := false,
		$SESSION[s] := false,
		wcl_handler_instance.registered_object :delete s),
	for s in list{s in copy(wcl_handler_instance.registered_tree_object)|not(s % l)}
		($[s] := false,
		$SESSION[s] := false,
		wcl_handler_instance.registered_tree_object :delete s)]

//<sb> @doc Session
// session_clean_but(i) removes all datas from a session execpt i.
[claire/session_clean_but(i:string) : any -> session_clean_but(list(i))]

SESSION_SIGTERM?:boolean := false
[session_sigterm_handler() : void -> SESSION_SIGTERM? := true]

[claire/session_save() : void -> 
	if wcl_handler_instance.session_started?
		(try (let p := signal(SIGTERM, session_sigterm_handler),
					f := fopen(session_file(),"w")
			in (if not(wcl_handler_instance.session_locked?) //<sb> ensure that we have not already locked our session
					// WARNING: works only if the lock is advisory since the file is already open and locked
					(if islocked?(f)
						//[-100] == Wait for session lock to be released [~A] // getenv("WCL_SESSION"),
					flock(f)), //<sb> query exclusive access on the file
				serialize(f,
					list{tuple(s,$[s])|s in wcl_handler_instance.registered_object},
					list{tuple(s,$[s])|s in wcl_handler_instance.registered_tree_object}),
				fclose(f),
				//[-100] == Session saved [~A] [~A] // wcl_handler_instance.registered_object, wcl_handler_instance.registered_tree_object,
				signal(SIGTERM, p)))
		catch any //[-100] == Session save error \n~S // exception!(),
		if wcl_handler_instance.session_locked?
			(fclose(wcl_handler_instance.session_locked_file), //<sb> release our lock
			wcl_handler_instance.session_locked? := false),
		if SESSION_SIGTERM?
			(//[-100] == SIGTERM raised and catched during session_save,
			SESSION_SIGTERM? := false,
			raise(SIGTERM)))]


// @doc Session
// register(varname, val) adds a new entry in the current session. After this call
// we have $[varname] = val.
[claire/register(varname:string, val:any) : any -> 
	if not(wcl_handler_instance.session_started?)
		try error("Missing started session for register(~S, ~S)", varname, val)
		catch any wcl_error(wcl_handler_instance, true),
	when x := some(t in wcl_handler_instance.registered_object|t = varname)
	in //[-100] == Warning: register(~S,~S) overwrite its previous value ~S // varname, val, $[x]
	else wcl_handler_instance.registered_object :add varname,
	$SESSION[varname] := val,
	$[varname] := val,
	val]

// @doc Session
// rregister(varname, val) adds a new entry in the current session. After this call
// we have $[varname] = val. rregister stands for 'recursive register' which means
// that the related objects are also registered (see serialize).
[claire/rregister(varname:string, val:any) : any -> 
	if not(wcl_handler_instance.session_started?)
		try error("Missing started session for rregister(~S, ~S)", varname, val)
		catch any wcl_error(wcl_handler_instance, true),
	when x := some(t in wcl_handler_instance.registered_tree_object|t = varname)
	in //[-100] == Warning: rregister(~S,~S) overwrite its previous value ~S // varname, val, $[x]
	else wcl_handler_instance.registered_tree_object :add varname,
	$SESSION[varname] := val,
	$[varname] := val,
	val]


// @doc Session
// unregister(self) remove the entry self from the current session.
[claire/unregister(self:string) : void -> 
	if not(wcl_handler_instance.session_started?)
		try error("Missing started session for unregister(~S)", self)
		catch any wcl_error(wcl_handler_instance, true),
	when x := some(x in wcl_handler_instance.registered_object|x = self)
	in (wcl_handler_instance.registered_object :delete x,
		$SESSION[self] := false,
		$[self] := false)
	else when x := some(x in wcl_handler_instance.registered_tree_object|x = self)
	in (wcl_handler_instance.registered_tree_object :delete x,
		$SESSION[self] := false,
		$[self] := false)
	else //[-100] == Warning: unregister(~S), the variable ~S doesn't exists // self, self
	]


