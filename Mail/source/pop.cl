/*	File : pop.cl Pop3 protocol
	Module : Mail general mail purpose
	expert-solutions SARL
	Xavier Pechoultres
	
	1. Model
	2. Connection management
	3. General Information
	4. Mail management
	5. Error handling
	6. Utilities
*/

//-------------------------------------------------------------------------
// 		1.	Model
//-------------------------------------------------------------------------

// class representin a pop sever
pop_server <: ephemeral_object(
				_login:string,
				_password:string,
				_hostname:string,
				_port:integer = 110,
				_sock:port,
				_messages_count:integer)

// global pop error
pop_error <: exception(comment:string = "unknown error")

[self_print(self:pop_error) : void
-> printf("POP: ~S",self.comment)]

POP :: 0
//-------------------------------------------------------------------------
// 		2.	Connection management
//-------------------------------------------------------------------------

			
[pop_connect(host:string,login:string,password:string) : pop_server
->	let s := pop_server(_hostname = host,
						_login = login,
						_password = password)
	in pop_connect(s)]

[pop_connect(s:pop_server) : pop_server
->	s._sock := client!(s._hostname,s._port),
	checkError(s._sock,"unknwon error"),
	pop_command(s,"USER ",s._login,"unknown user"),	
	pop_command(s,"PASS ",s._password,"unknown password"),	
	s]

[pop_disconnect(s:pop_server) : void
->	pop_command(s,"QUIT ","","unable to disconnect server"),
	fclose(s._sock)]

[private/pop_command(s:pop_server, command:string, data:string, onerror:string) : string
->	//[POP] pop_command ~S ~S // command, data,
	fwrite(command,s._sock),
	fwrite(data,s._sock),
	fwrite("\r\n",s._sock),
	if (onerror != "")
		checkError(s._sock,onerror)
	else get_line(s._sock)]

//-------------------------------------------------------------------------
// 		3.	 General Information
//-------------------------------------------------------------------------

// return a tuple with number of message and size of mailbox
[pop_stat(s:pop_server) : tuple(integer,integer)
-> 	let tmp := pop_command(s,"STAT ","","cannot stat"),
		res := explode(tmp," ")
	in (//[POP] stat : ~S -> ~S // tmp, res, 
		tuple(integer!(res[2]), integer!(res[3])))]

//-------------------------------------------------------------------------
// 		4.	Gettings email
//-------------------------------------------------------------------------

// get all messages from serveur
[pop_messages(s:pop_server) : list[email_base]
->	let n := pop_stat(s)[1],
		res := list<email_base>()
	in (//[0] getting ~A messages from server // n,
		for m in (1 .. n)
			res :add pop_message(s,m),
		res)]


// get n(th) message from serveur
[pop_message(s:pop_server,n:integer) : email_base
->	let	msg_size := 0,
		msg := email_base(_id = n)
	in	(let info := pop_command(s,"RETR ",string!(n),"message not found")
		in (msg._size := integer!(explode(info," ")[2]),
			pop_read_message(msg,s._sock), // attention il faut bien lire le ".\r\n" à la fin
			msg))]

// read a message from a port
[private/pop_read_message(msg:email_base,p:port) : boolean
->	//[POP] pop_read_message(msg,port) -> size = ~S // msg._size,
	let 	buff := port!()
	in (
		//for i in (1 .. msg._size) print(getc(p)), 
		fread(p,buff,msg._size ),
		read_to_dot(p,buff),
		//[POP] pop_read_message => length(buff) = ~S //  length(buff) ,
//		fread(buff,fopen("out" /+  string!(msg._id) /+ ".eml","w"),msg._size),
		read_email(msg,buff),
		//[POP] pop_read_message => fclose(buff) = ~S ,
		fclose(buff),
		true)]

[read_to_dot(from:port,to:port) : void
->	let tmp := ""
	in (while ((tmp := freadline(from)) != ".\r\n")
	 		fwrite(tmp,to))]

// 
[pop_delete_message(s:pop_server,msg:email_base) : void
-> pop_delete_message(s,msg._id)]

[pop_delete_message(s:pop_server,msg_id:integer) : void
->	pop_command(s, "DELE ", string!(msg_id), "unable to delete message " /+ string!(msg_id))]


//-------------------------------------------------------------------------
// 		5.	Error handling
//-------------------------------------------------------------------------

[private/checkError(p:port,err:string) : string
-> let f := get_line(p)
	in (//[POP] checkError ~S // f,
		if (find(f,"-ERR") > 0) pop_error( comment = err),
		f)]
