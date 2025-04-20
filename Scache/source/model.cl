
CACHE_SERVER:port := port!()


[connect(sockt:string) : bool -> true]

[connect() : bool -> CACHE_SERVER := client!("localhost",6379)]



[get_value(key:string) : string -> 
	fwrite("GET " /+ key,CACHE_SERVER /+ "\n"),
	fread(CACHE_SERVER))

let server = connect() in]
	let value = server!get(key) in
	server!close();
