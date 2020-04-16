

[private/soapXml!(c:SoapIn) : void ->
	printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\" SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/1999/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/1999/XMLSchema\">
  <SOAP-ENV:Body>
    ~I
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>",
		Xmlo/xml!(c, cout()))]


[soap_call(url:string, i:SoapIn) : SoapOut ->
	//[-100] == Before Soap_call -> ~S // cout(),
	//[-100] == Soap call(~S, ~S) // url, i,
	let http := Http/initialize_http_post(url),
		old := use_as_output(http)
	in (header(http, "Content-Type: text/xml"),
		header(http, "SOAPAction: \"" /+
						(print_in_string(),
						Xmlo/xmlPrint(owner(i)),
						end_of_string()) /+ "\""),
		soapXml!(i),
		Http/terminate_http_post(http),
		use_as_output(old),
		let result := parseClientResponse(Http/parse_input(http))
		in (//[-100] == Response parsed -> ~S // result,
			fclose(http),
			use_as_output(old),
			//[-100] == After Soap_call -> ~S // cout(),
			result as SoapOut))]
