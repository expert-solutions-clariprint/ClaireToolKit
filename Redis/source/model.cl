/**
 * Copyright (c) 2025, expert-solutions sarl
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation and/or
 * other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors
 * may be used to endorse or promote products derived from this software without
 * specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 */


redis_client <: ephemeral_object(
		iosock:port,
		tcp_port:integer = 6379,
		tcp_host:string = "localhost")

// @doc 
// connect a redis server
[connect(self:redis_client) : boolean
->	self.iosock := client!(self.tcp_host, self.tcp_port),
	true]

// @doc
// disconnect a redis server
[disconnect(self:redis_client) : boolean
->	close(self.iosock),
	erase(iosock,self),
	true]

// @doc
// use single instance most common usage 
DEFAULT_SERVER:redis_client := unknown

// @doc
// connect to the default redis server
[connect() : boolean -> 
	DEFAULT_SERVER := redis_client(),
	connect(DEFAULT_SERVER)]

// @doc
// disconnect from the default redis server
[disconnect() : boolean -> 
	if (unknown?(DEFAULT_SERVER)) DEFAULT_SERVER := redis_client(),
	connect(DEFAULT_SERVER)]


// @doc API
// print a string with redis escaping rules (for debug purpose)
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


// @doc API
// print a string with redis escaping rules (for debug purpose)
redis_string_filter <: filter()

// @doc API
// a filter to print a string with redis escaping rules (for debug purpose)
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

// @doc API
// a filter to print a string with redis escaping rules (for debug purpose)
[strdecode(encoding:string,val:string) : string -> val]

(open(strdecode))

// @doc 
// parse a reply from the redis server
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

// @doc
// send a command
[query(self:redis_client,cmd:string) : any
-> fwrite(cmd, self.iosock),
	fwrite("\r\n", self.iosock),
	parse(self)]

// @doc
// send a command to default server
[query(cmd:string) : any -> query(DEFAULT_SERVER,cmd)]


// @doc
// get a value from the redis server
[get(self:redis_client,key:string) : any
->	fwrite("GET \"" /+ key /+ "\"\r\n", self.iosock),
	parse(self)]

// @doc
// get a value from the default redis server
[get(key:string) : any -> get(DEFAULT_SERVER,key)]



// @doc
// set a value on the redis server
[retain(self:redis_client, key:string, val:(string U port), time:integer) : any
->	//[2] retain @ string U port,
	let oldp := use_as_output(self.iosock)
	in (resp(list("SET", key, val, "EX", string!(time))), // printf("SET ~A ~S EX ~A\r\n", key, val, time),
		use_as_output(oldp),
		parse(self))]

// @doc
// set a value on the redis server
[retain(self:redis_client, key:string, val:(float U integer ), time:integer) : any
->	//[2] retain @ float U integer,
	let oldp := use_as_output(self.iosock)
	in (resp(list("SET",key, string!(val), "EX",string!(time))), // printf("SET ~A ~S EX ~A\r\n", key, val, time),
		use_as_output(oldp),
		parse(self))]


// @doc
// set a value on the redis server
[retain(self:redis_client, key:string, val:boolean, time:integer) : any
-> let oldp := use_as_output(self.iosock)
	in (resp(list("SET",key, (if val "true" else "false"), "EX",string!(time))), // printf("SET ~A ~S EX ~A\r\n", key, val, time),
		use_as_output(oldp),
		parse(self))]

[resp(arr:bag) : void
->	printf("*~A\r\n", length(arr)),
	for i in arr resp(i)]

[resp(val:string) : void
->	//[2] resp(string) size(~S:~S) // length(val),val,
	printf("$~A\r\n~A\r\n", length(val), val)]

[resp(val:port) : void
->	//[2] resp(port) size : ~S // length(val),
	printf("$~A\r\n~I\r\n", length(val), freadwrite(val,cout(),length(val)))]

[resp(val:integer ) : void
->	printf(":~A\r\n", val)]

[resp(val:float ) : void
-> 	printf(",~A\r\n", val)]

[resp(val:boolean ) : void
->	if (val) printf("#t\r\n") else printf("#f\r\n")]


// @doc
// set a value on the redis server
[retain(self:redis_client, key:string, val:(float U integer)) : any
->	let oldp := use_as_output(self.iosock)
	in (resp(list("SET",key, string!(val))), // printf("SET ~A ~S\r\n", key, val),
		use_as_output(oldp),
		parse(self))]
// @doc
// set a value on the redis server
[retain(self:redis_client, key:string, val:(boolean)) : any
-> let oldp := use_as_output(self.iosock)
	in (resp(list("SET",key, (if val "true" else "false"))), // printf("SET ~A ~S\r\n", key, val),
		// printf("SET ~A ~S\r\n", key, val),
		use_as_output(oldp),
		parse(self))]


// @doc
// set a value on the redis server
[retain(self:redis_client, key:string, val:string) : any
-> let oldp := use_as_output(self.iosock)
	in (
		resp(list("SET", key, val)),
		use_as_output(oldp),
		parse(self))]

// @doc
// set a value on the redis server
[retain(key:string, val:(string U float U integer U boolean U port )) : any 
-> retain(DEFAULT_SERVER, key, val)]

// @doc
// set a value on the redis server
[retain(key:string, val:(string U float U integer U boolean U port), time:integer) : any
-> retain(DEFAULT_SERVER, key, val, time)]

// @doc
// set a value on the redis server
[retain(self:redis_client, key:string, val:port) : any
-> let oldp := use_as_output(self.iosock)
	in (resp(list("SET", key, val)),
		use_as_output(oldp),
		parse(self))]


// @doc
// delete a value from the redis server
[forgot(self:redis_client, key:string) : any
-> let oldp := use_as_output(self.iosock)
	in (printf("DEL ~A\r\n", key),
		use_as_output(oldp),
		parse(self))]

// @doc
// delete a value from the default redis server
[forgot(key:string) : any
-> remove(DEFAULT_SERVER, key)]


// @doc
// delete multiple values from the redis server
[forgot(self:redis_client, keys:list[string]) : any
-> let oldp := use_as_output(self.iosock)
	in (printf("DEL ~I\r\n", for k in keys printf("~A ", k)),
		use_as_output(oldp),
		parse(self))]

// @doc
// delete multiple values from the default redis server
[forgot(keys:list[string]) : any
-> remove(DEFAULT_SERVER, keys)]


// @doc
// authenticate to the redis server
[auth(self:redis_client, login:string,pass:string) : any
-> let oldp := use_as_output(self.iosock)
	in (printf("AUTH ~S ~S \r\n", login, pass),
		use_as_output(oldp),
		parse(self))]

// @doc
// authenticate to the default redis server
[auth(login:string,pass:string) : any -> auth(DEFAULT_SERVER,login,pass)]

// @doc
// a simple lock implementation using redis SET command with NX and EX options
LOCK_TIMEOUT_S:integer :=  60
LOCK_RETRY_MS:integer := 100

// @doc
// a simple lock implementation using redis SET command with NX and EX options
[lock(self:redis_client, key:string) : boolean
-> let oldp := use_as_output(self.iosock)
	in (// printf("SET ~A ~S NX EX ~A\r\n", key, getpid(),LOCK_TIMEOUT_S),
		resp(list("SET", key, string!(getpid()), "NX", "EX", string!(LOCK_TIMEOUT_S))),
		use_as_output(oldp),
		parse(self) = "OK")]

// @doc
// a simple lock implementation using redis SET command with NX and EX options
[unlock(self:redis_client, key:string) : boolean
-> let oldp := use_as_output(self.iosock)
	in (printf("DEL ~A \r\n", key),
		//resp(list("DEL", key)),
		use_as_output(oldp),
		parse(self) = "OK")]

// @doc
// a simple lock implementation using redis SET command with NX and EX options
[lock(key:string) : boolean -> lock(DEFAULT_SERVER, key)]


// @doc
// a simple lock implementation using redis SET command with NX and EX options
[unlock(key:string) : boolean -> unlock(DEFAULT_SERVER, key)]

// @doc
// a simple lock implementation
[lock!(self:redis_client, key:string, retry_ms:integer) : boolean
->	while not(lock(self,key)) sleep(retry_ms),
	true]

// @doc
// a simple lock implementation
[lock!(self:redis_client, key:string) : boolean -> lock!(DEFAULT_SERVER, key, LOCK_RETRY_MS)]

// @doc
// a simple lock implementation
[lock!(key:string) : boolean -> lock!(DEFAULT_SERVER, key, LOCK_RETRY_MS)]

// @doc
// a simple lock implementation
[lock!(key:string,retry_ms:integer) : boolean -> lock!(DEFAULT_SERVER, key, retry_ms)]

