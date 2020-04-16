

XMLPORT:port := unknown
RESPONSE_VALUE:any := unknown
FAULTSTRING:string := ""
FAULTREPORT?:boolean := false

Fault <: object()
(Xmlo/xmlizeDescendents(Fault))

clientResponseTagEnter :: property()
clientResponseTagLeave :: property()

[fault_enter(parser:Sax/sax_parser, ctx:Xmlo/context, t:string, a:table) : void -> none]
[fault_enter(parser:Sax/sax_parser, t:string, a:table) : void -> none]

[fault_leave(parser:Sax/sax_parser, ctx:Xmlo/context, t:string, cdata:string) : void -> fault_leave(parser, t, cdata)]

[fault_leave(parser:Sax/sax_parser, t:string, cdata:string) : void ->
	//[-100] fault_leave(..,t:~S, cdata:~S ) // t, cdata,
	if (lower(t) = "faultstring")
		(//[-100] == Found a SOAP fault string : ~S // cdata,
		FAULTSTRING := cdata)
	else if (lower(t) = "faultreport")
		(//[-100] == Found an attached SOAP fault report,
		FAULTREPORT? := true),
	Sax/set_handler(parser,clientResponseTagEnter, clientResponseTagLeave)]

[Xmlo/tagToClass(parser:Sax/sax_parser, ns:{"soap","Soap","SOAP"}, t:{"Fault","fault","FAULT"}) : class ->
	//[-100] tagToClass ns:~S t:~S // ns, t,
	Sax/set_handler(parser,fault_enter,fault_leave),
	Fault]

[clientResponseTagEnter(parser:Sax/sax_parser, ctx:Xmlo/context, s:string, attrs:table) : void ->
	//[-100] clientResponseTagEnter ,
	if (right(lower(s), 5) = ":body")
		RESPONSE_VALUE := Xmlo/unXml!(XMLPORT,parser)]

[clientResponseTagEnter(parser:Sax/sax_parser, s:string, attrs:table) : void ->
	if (right(lower(s), 5) = ":body")
		RESPONSE_VALUE := Xmlo/unXml!(XMLPORT,parser)]


[clientResponseTagLeave(parser:Sax/sax_parser, ctx:any, s:string, cdata:string) : void ->
	if (RESPONSE_VALUE % Fault & not(FAULTREPORT?))
		soap_fault(src = url_decode(FAULTSTRING))]

[clientResponseTagLeave(parser:Sax/sax_parser, s:string, cdata:string) : void ->
	if (RESPONSE_VALUE % Fault & not(FAULTREPORT?))
		soap_fault(src = url_decode(FAULTSTRING))]
	

[parseClientResponse(xml:port) : any ->
	//[-100] == Parse client response on ~S // xml,
	RESPONSE_VALUE := unknown,
	FAULTSTRING := "",
	FAULTREPORT? := false,
	XMLPORT := xml,
	Sax/sax(xml, clientResponseTagEnter, clientResponseTagLeave),
	if FAULTREPORT?
		let p := use_as_output(Wcl/wcl_handler_instance.Wcl/report.target)
		in (//<sb> the server-side script attached a report concerning
			// an unhandled exception, we insert this report in the
			// current page report and update the error counter :
			?><table>
				<tr><td><?
					for i in (1 .. system.trace!) princ("\240")
				?><td><?
				freadwrite(xml, cout())
			?></table><?
			use_as_output(p),
			soap_fault(src = "see attached report")),
	RESPONSE_VALUE]

