
RETAIN_TIME:float := 60.0

redis_client <: ephemeral_object(
		iosock:port,
		tcp_port:integer = 6379,
		tcp_host:string = "localhost")

/* connect a redis server */
[connect(self:redis_client) : boolean
->	self.iosock := client!(self.tcp_host, self.tcp_port),
	true]

/* coonnect a redis server */
[disconnect(self:redis_client) : boolean
->	close(self.iosock),
	erase(iosock,self),
	true]

/* use single instance mosrt common usage */
DEFAULT_SERVER:redis_client := unknown

[connect() : boolean -> 
	DEFAULT_SERVER := redis_client(),
	connect(DEFAULT_SERVER)]

[disconnect() : boolean -> 
	if (unknown?(DEFAULT_SERVER)) DEFAULT_SERVER := redis_client(),
	connect(DEFAULT_SERVER)]


[print_redis(self:string) : void
-> for i in (1 .. length(self))
	let ch := self[i]
	in (case ch 
		({'"'} (fwrite("\\\"", cout())),
		{'\r'} (fwrite("\\r", cout()), 
				none),
		{'\n'} (fwrite("\\n", cout()),
				none),
		any (putc(ch, cout()))))]


redis_string_filter <: filter()

redis_write(self:redis_client, p:port) : void ->
	(while (not(eof_port?(p)))
		let ch := getc(p)
		in case ch
			({'"'} fwrite("\\\"", self.iosock),
			{'\r'} (fwrite("\\r", self.iosock), 
				none),
			{'\n'} (fwrite("\\n", self.iosock),
				none),
			any (putc(ch, self.iosock))))

/*
write_port(self:redis_string_filter, buf:char*, len:integer) : integer ->
	(//[0] write_port,
		for i in (1 .. len)
		let ch := buf[i]
		in case ch
			({'"'} fwrite("\\\"", self.target),
		{'\r'} (//[0] escape \\r .., 
				fwrite("\\r", self.target), 
				none),
		{'\n'} (//[0] escape \\n .., 
				fwrite("\\n", self.target),
				none),
			any (putc(ch, self.target))),
		len)
*/

[strdecode(encoding:string,val:string) : string -> val]

(open(strdecode))

/* parse a reply */
[parse(self:redis_client) : any
-> if (not(eof_port?(self.iosock)))
	let ctr := getc(self.iosock)
	in (//[2] getc(~S) // ctr,
		case (ctr) (

		{'+'} freadline(self.iosock),
		{'%'} freadline(self.iosock),
		{'#'} (freadline(self.iosock) = "t"), // bool
		{',','('} float!(freadline(self.iosock)),
		{'`'} freadline(self.iosock), //Attributes
		{'~'} freadline(self.iosock), // sets
		{'>'} freadline(self.iosock), // push ??
		{'-'} (let x := freadline(self.iosock) in (error(x),false)),
		{'$'} (//[2] read string,
				let len := integer!(freadline(self.iosock)), 
					__tem := (//[2] len : ~S // len,
							len),
					str := (if (len > 0) fread(self.iosock,len) else "")
				in (if (len >= 0) (fread(self.iosock,2), str) else unknown)),
		{'='} (let len := integer!(freadline(self.iosock)), 
					encoding := (fread(self.iosock,2),fread(self.iosock,3)),
					str := (fread(self.iosock,1), if (len > 0) fread(self.iosock,len) else "")
				in (fread(self.iosock,2), strdecode(encoding,str))),
		{':'} (let x := freadline(self.iosock) in integer!(x)),
		{'*'} (let x := list<any>(),
					len := integer!(freadline(self.iosock))
				in (while (len > 0) (x :add parse(self), len :- 1),
					x)),
		any unknown)) else unknown]

/* send a command */
[query(self:redis_client,cmd:string) : any
-> fwrite(cmd, self.iosock),
	fwrite("\r\n", self.iosock),
	parse(self)]

[query(cmd:string) : any -> query(DEFAULT_SERVER,cmd)]



[get(self:redis_client,key:string) : any
->	fwrite("GET \"" /+ key /+ "\"\r\n", self.iosock),
	parse(self)]

[get(key:string) : any -> get(DEFAULT_SERVER,key)]

/* string */
[retain(self:redis_client, key:string, val:(string U float U integer U boolean), time:integer) : any
-> let oldp := use_as_output(self.iosock)
	in (printf("SET ~A ~S EX ~A\r\n", key, val, time),
		use_as_output(oldp),
		parse(self))]

[retain(self:redis_client, key:string, val:(float U integer U boolean)) : any
-> let oldp := use_as_output(self.iosock)
	in (printf("SET ~A ~S\r\n", key, val),
		use_as_output(oldp),
		parse(self))]

[retain(self:redis_client, key:string, val:(string)) : any
-> let oldp := use_as_output(self.iosock)
	in (printf("SET ~A \"~I\"\r\n", key, print_redis(val)),
		use_as_output(oldp),
		parse(self))]

[retain(key:string, val:(string U float U integer U boolean)) : any 
-> retain(DEFAULT_SERVER, key, val)]

[retain(key:string, val:(string U float U integer U boolean), time:integer) : any
-> retain(DEFAULT_SERVER, key, val, time)]




/* string */
/*
[retain(self:redis_client, key:string, val:boolean, time:float) : any
-> let oldp := use_as_output(self.iosock)
	in (printf("SET ~A ~S EX ~A\r\n", key, val, time),
		use_as_output(oldp),
		parse(self))]

[retain(self:redis_client, key:string, val:boolean) : any
-> let oldp := use_as_output(self.iosock)
	in (printf("SET ~A ~S\r\n", key, val),
		use_as_output(oldp),
		parse(self))]

[retain(key:string, val:boolean) : any 
-> retain(DEFAULT_SERVER, key, val)]

[retain(key:string, val:boolean, time:float) : any
-> retain(DEFAULT_SERVER, key, val, time)]
*/
[retain(self:redis_client, key:string, val:port) : any
-> let oldp := use_as_output(self.iosock)
	in (printf("SET ~A \"", key),
		redis_write(self,val),
		// freadwrite(filter!(redis_string_filter(),val),cout()),
		printf("\"\r\n"),
		use_as_output(oldp),
		parse(self))]
[retain(key:string, val:port) : any -> retain(DEFAULT_SERVER, key, val)]



[forgot(self:redis_client, key:string) : any
-> let oldp := use_as_output(self.iosock)
	in (printf("DEL ~A \r\n", key),
		use_as_output(oldp),
		parse(self))]

[forgot(key:string) : any
-> remove(DEFAULT_SERVER, key)]


[forgot(self:redis_client, keys:list[string]) : any
-> let oldp := use_as_output(self.iosock)
	in (printf("DEL ~I \r\n", for k in keys printf("~A ", k)),
		use_as_output(oldp),
		parse(self))]

[forgot(keys:list[string]) : any
-> remove(DEFAULT_SERVER, keys)]



[auth(self:redis_client, login:string,pass:string) : any
-> let oldp := use_as_output(self.iosock)
	in (printf("AUTH ~S ~S \r\n", login, pass),
		use_as_output(oldp),
		parse(self))]
[auth(login:string,pass:string) : any -> auth(DEFAULT_SERVER,login,pass)]



