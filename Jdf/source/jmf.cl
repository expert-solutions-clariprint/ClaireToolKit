
TAPI :: -100

private/DEBUG:boolean := false

[set_debug() : void -> DEBUG := true]

controller <: ephemeral_object(
	input:Dom3/Document,
	output:Dom3/Document)


jmf_server <: controller()

self_print(self:jmf_server) : void -> printf("[jmf_server]")

[controller!(p:port) : controller
->	let c := controller()
	in (c.input := Dom3/document!(p),
		c.output := setup_jmf_doc(),
		c)]

[jmf_server!(p:port) : jmf_server -> jmf_server!(p,true)]
[jmf_server!(p:port,sendresponse:boolean) : jmf_server
->	//[TAPI] jmf_server!(~S) // p,
	let jmfd := jmf_server()
	in (jmfd.input := Dom3/document!(p),
		jmfd.output := setup_jmf_doc(),
		process_request(jmfd),
		if (sendresponse) send_response(jmfd),
		jmfd)]



	
[setup_jmf_doc() : Dom3/Document
->	//[TAPI] setup_jmf_doc(),
	let doc := Dom3/Document(),
		jmf := Dom3/createElement(doc,"JMF")
	in (Dom3/appendChild(doc,jmf),
		Dom3/setAttribute(jmf,"xmlns","http://www.CIP4.org/JDFSchema_1_1"),
		Dom3/setAttribute(jmf,"SenderID","CLAIRE Jmf module version " /+ Jdf.version),
		Dom3/setAttribute(jmf,"TimeStamp",Dom3/timestamp!()),
		Dom3/setAttribute(jmf,"MaxVersion","1.3"),
		Dom3/setAttribute(jmf,"Version","1.3"),
		Dom3/setAttribute(jmf,"xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance"),
		doc)]

[setup_response_element(self:controller,req:Dom3/Element,rtype:string) : Dom3/Element
->	//[TAPI] setup_response_element(~S, ~S, ~S) // self,req,rtype,
	let resp := Dom3/createElement(self.output,"Response")
	in (Dom3/setAttribute(resp,"ReturnCode","0"),
		Dom3/setAttribute(resp,"Type",req["Type"]),
		Dom3/setAttribute(resp,"refID",req["ID"]),
		Dom3/setAttribute(resp,"ID","RESPONSE" /+ req["ID"]),
		resp)]

[handle_request(self:controller,req:Dom3/Element, rtype:string) : Dom3/Element
->	//[TAPI] handle_request(~S, ~S, ~S) // self,req,rtype,
	let resp := setup_response_element(self,req,rtype)
	in (Dom3/setAttribute(resp,"ReturnCode","5"),
		resp)]

(open(handle_request) := 3)

[error_response(self:controller,req:Dom3/Element,rtype:string) : Dom3/Element
->	let resp := setup_response_element(self,req,rtype)
	in (Dom3/setAttribute(resp,"ReturnCode","5"),
		resp)]


[process_request(self:controller) : void
->	//[TAPI] process_request(~S) // self,
	when reqs := get(input,self)
	in (//[TAPI] input ~S // reqs,
		//[TAPI] childnodes ~S // reqs.Dom3/documentElement.Dom3/childNodes,
		for req in reqs.Dom3/documentElement.Dom3/childNodes
			(if (req %  Dom3/Element)
				(when resp := handle_request(self,req,Dom3/getAttribute(req,"Type"))
				in (Dom3/appendChild(self.output.Dom3/documentElement,resp))
				else Dom3/appendChild(self.output.Dom3/documentElement,error_response(self,req,Dom3/getAttribute(req,"Type"))))))]

[send_response(self:controller) : void
->	//[TAPI] send_response(~S) // self,
	header("Content-Type: application/vnd.cip4-jmf+xml"),
	print(self.output)]


[jmf_call(url:string, input:Dom3/Document) : Dom3/Document ->
	let http := Http/initialize_http_post(url),
		old := use_as_output(http)
	in (header(http, "Content-Type: application/vnd.cip4-jmf+xml"),
		print(input),
		Http/terminate_http_post(http),
		use_as_output(old),
		let result := Dom3/document!(Http/parse_input(http))
//		let result := Http/parse_input(http)
		in (//[-100] == Response parsed -> ~S // result,
			fclose(http),
			use_as_output(old),
			result as Dom3/Document))]



[list_jmf_services(url:string) : Dom3/Document ->
	let req := setup_jmf_doc(),
		query := Dom3/createElement(req,"Query")
	in (Dom3/setAttribute(query,"ID",uid()),
		Dom3/setAttribute(query,"Type","KnownMessages"),
		Dom3/appendChild(req.Dom3/documentElement,query),
		jmf_call(url,req))]

