


methodCall <: ephemeral_object(
	methodName:string,
	params:list[any])


[self_print(self:methodCall) : void -> printf("<methodCall:~A>",self.methodName)]

[printValue(self:methodCall)
->	printf("<methodCall><methodName>~A</methodName><params>~I</params></methodCall>",
			self.methodName,
			(for i in self.params printParam(self,i)))]
			

[private/printParam(self:methodCall,x:any) : void -> 
	printf("<param>~I</param>",printValue(self,x))]

[printValue(self:methodCall,x:integer) : void ->
	printf("<value><int>~A</int></value>",x)]

[printValue(self:methodCall,x:float) : void ->
	printf("<value><double>~A</double></value>",x)]

[printValue(self:methodCall,x:string) : void ->
	printf("<value><string>~A</string></value>",x)]

[printValue(self:methodCall,x:boolean) : void ->
	printf("<value><boolean>~S</boolean></value>",x)]

[printValue(self:methodCall,x:port) : void ->
	let p := port!()
	in (encode64(x,p,72),
		printf("<value><base64>~I</base64></value>",freadwrite(p,cout())))]

[printValue(self:methodCall,x:list) : void -> 
	printf("<value><array><data>~I</data></array></value>",
		(for i in x printValue(self,i)))]

[printValue(self:methodCall,x:table) : void -> 
	printf("<value><struct>~I</struct></value>",
		(let _graph := x.mClaire/graph in
			for i in (1 .. (length(_graph) / 2))
    		let key := _graph[2 * i - 1],
    			_value := _graph[2 * i] in
    		(if known?(_value) printf("<member><name>~A</name>~I</member>",key,printValue(self,_value)))))]


[callMethod(url:string, m:string, p:list[any]) : list[any] ->
	//[1] == callMethod(~S, ~S, ~S) // url, m, p,
	let x := methodCall(methodName = m, params = p)
	in callMethod(url,x)]

[callMethod(url:string, i:methodCall) : list[any] ->
	//[1] == Before callMethod -> ~S // cout(),
	//[1] == callMethod(~S, ~S) // url, i,
	let http := Http/initialize_http_post(url),
		old := use_as_output(http)
	in (Http/header(http,"Content-Type: text/xml"),
		Http/header(http,"Connection: close"),
		printValue(i),
		use_as_output(old),
		Http/terminate_http_post(http),
		try let ret := Http/parse_input(http),
				result:list[any] := nil
			in (//[2] ret ~S // ret,
				result := parseResponse(ret),
				//[1] == Response parsed -> ~S // result,
				fclose(http),
				//[1] == After callMethod -> ~S // cout(),
				result)
		catch any (
			//[1] call error ~S // exception!(),
			fclose(http),
			nil))]

private/RpcParser <: ephemeral_object(
	data:list[any],
	stack:list[any])

[private/rpcStartHandler(parser:Sax/sax_parser, self:RpcParser,tag:string,attrs:table) : any
->	//[3] rpcStartHandler(~S,~S,~S) // self, tag, attrs,
	self]



[private/rpcStartHandler(parser:Sax/sax_parser, self:RpcParser,tag:{"params","fault"},attrs:table) : any
->	//[3] rpcStartHandler(~S,~S,~S) // self, tag, attrs,
	self.stack :add list<any>(),
	self]

[private/rpcStartHandler(parser:Sax/sax_parser, self:RpcParser,tag:{"struct"},attrs:table) : any
->	//[3] rpcStartHandler(~S,~S,~S) // self, tag, attrs,
	self.stack :add make_table(string,any,unknown),
	self]

[private/rpcStartHandler(parser:Sax/sax_parser, self:RpcParser,tag:{"array"},attrs:table) : any
->	//[3] rpcStartHandler(~S,~S,~S) // self, tag, attrs,
	self.stack :add list<any>(),
	self]

[private/rpcEndHandler(parser:Sax/sax_parser, self:RpcParser,tag:{"array","struct"},cdata:string) : any
->	//[3] rpcEndHandler(~S,~S,~S) // self, tag, cdata,
	let x := last(self.stack)
	in (shrink(self.stack,length(self.stack) - 1),
		let y := last(self.stack) in y :add x),
	self]

[private/rpcStartHandler(parser:Sax/sax_parser, self:RpcParser,tag:{"member"},attrs:table) : any
->	//[3] rpcStartHandler(~S,~S,~S) // self, tag, attrs,
	self.stack :add list<any>(),
	//[3]  start stack ~S //  self.stack,
	self]

[private/rpcEndHandler(parser:Sax/sax_parser, self:RpcParser,tag:{"member"},cdata:string) : any
->	//[3]  end stack ~S //  self.stack,
	let x := last(self.stack),
		y := (shrink(self.stack,length(self.stack) - 1), last(self.stack))
	in (y[x[1]] := x[2],
		self)]


[private/rpcEndHandler(parser:Sax/sax_parser, self:RpcParser,tag:string,data:string) : any
->	//[3] default rpcEndHandler(~S,~S,~S) // self, tag, data,
	self]

[private/rpcEndHandler(parser:Sax/sax_parser, self:RpcParser,tag:{"methodResponse"},data:string) : any
->	//[3] rpcEndHandler(~S,~S,~S) // self, tag, data,
	self]
[private/rpcEndHandler(self:RpcParser,tag:{"string","name"},data:string) : any
->	//[3] rpcEndHandler(~S,~S,~S) // self, tag, data,
	let x := last(self.stack) in x :add trim(data),
	self]
[private/rpcEndHandler(parser:Sax/sax_parser, self:RpcParser,tag:{"double"},data:string) : any
->	//[3] rpcEndHandler(~S,~S,~S) // self, tag, data,
	let x := last(self.stack) in x :add float!(data),	
	self]

[private/rpcEndHandler(parser:Sax/sax_parser, self:RpcParser,tag:{"int","i4"},data:string) : any
->	//[3] rpcEndHandler(~S,~S,~S) // self, tag, data,
	let x := last(self.stack) in x :add integer!(data),
	self]

[private/rpcEndHandler(parser:Sax/sax_parser, self:RpcParser,tag:{"boolean"},data:string) : any
->	//[3] rpcEndHandler(~S,~S,~S) // self, tag, data,
	let x := last(self.stack) in x :add boolean!(data),
	self]

[private/rpcEndHandler(parser:Sax/sax_parser, self:RpcParser,tag:{"base64"},data:string) : any
->	//[3] rpcEndHandler(~S,~S,~S) // self, tag, data,
	let x := last(self.stack),
 		y := port!()
	in (decode64(data,y),
		x :add y),
	self]

[private/parseResponse(self:port) : list[any]
->	let x := RpcParser()
	in (Sax/sax(self, rpcStartHandler, rpcEndHandler,x),
		last(x.stack))]
