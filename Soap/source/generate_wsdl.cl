





[private/wsdlMethod!(ctx:Xmlo/context,serviceName:string, m:method) : void ->
	//[-100] wsdlMethod!(~S , ~S ) // serviceName, m,
	let mi_class := m.domain[1],
		mo_class :=  m.domain[2],
		mi_name := Xmlo/xmlName(mi_class),
		mo_name := Xmlo/xmlName(mo_class),
		m_name := mi_name
	in printf("
<!--    Start   ~A declaration          -->
		<message name=~S>
~I	</message>
	<message name=~S>		
~I	</message>
	<portType name=~S>
		<operation name=~S>
			<input message=~S /> 
			<output message=~S /> 
		</operation>
	</portType>
	<binding name=~S type=~S>
		<soap:binding style=\"rpc\" transport=\"http://schemas.xmlsoap.org/soap/http\" /> 
		<operation name=~S>
			<soap:operation soapAction=~S /> 
			<input>
				<soap:body use=\"encoded\" namespace=~S encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\" /> 
			</input>
			<output>
				<soap:body use=\"encoded\" namespace=~S encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\" /> 
			</output>
		</operation>
	</binding>
<!--    End   ~A declaration          -->
	
	\n",
		m_name, // declaration
		mi_name, // message in name
		/* message in parts */
		(for i in (mi_class.slots but (name @ thing) but (isa @ object))
			(//[-1000] slot : ~S  range : ~S // i, range(i),
			if (Xmlo/xmlized?(i.selector, mi_class))
				printf("<part name=~S type=\"~I\" />\n",
					Xmlo/xmlName(i.selector),
					(let r := range(i)
					in case r
						({string} princ("claire:string"),
						{integer} princ("claire:integer"),
						{boolean} princ("claire:boolean"),
						{float} princ("claire:double"),
						subtype princ("claire:bag"),
						any printf("~A:~A",string!(name(module!(name(r)))), string!(name(r)))))))),
		mo_name, // message out name

		/* message out parts */
		(for i in (mo_class.slots but (name @ thing) but (isa @ object))
			(//[-1000] slot : ~S  range : ~S // i, range(i),
			if (Xmlo/xmlized?(i.selector, mo_class))
			printf("		<part name=\"~A\" type=\"~I\" />\n", Xmlo/xmlName(i.selector),
					(let r := range(i) in case r
						({string} princ("claire:string"),
						{integer} princ("claire:integer"),
						{boolean} princ("claire:boolean"),
						{float} princ("claire:double"),
						subtype princ("claire:bag"),
						any printf("~A:~A",string!(name(module!(name(r)))), string!(name(r)))))))),
		/* declaration du port */
		m_name, // nom du port
		m_name,	// operation
		mi_name, // input message
		mo_name, // output message
		
		// bindings
		m_name, // nom du binding
		m_name,	// type du binding
		m_name, // nom operation
		m_name,	// soapAction // url
		string!(name(module!(name(mi_class)))), // namespace ??
		string!(name(module!(name(mi_class)))), // namespace !!
		string!(name(module!(name(mo_class)))),  // namespace
		m_name // commentaire fin de declaration
		)]


[private/wsdlPort!(wclUrl:string, m:method) : void ->
	let m_name := Xmlo/xmlName(m.domain[1])
	in printf("<port name=~S binding=~S>
			<soap:address location=~S />
		</port>\n",
			m_name,
			m_name,
			wclUrl)]


SERVICE_NAME:string := ""

[set_service_name(n:string) : void -> SERVICE_NAME := n]



[service_url() : string -> 
	let uri := getenv("REQUEST_URI"),
		path := left(uri,rfind(uri,"/"))
	in ("http://" /+ getenv("HTTP_HOST") / path)]
	
[service_name() : string -> if isenv?("APP_NAME") getenv("APP_NAME") 
	else if (SERVICE_NAME != "") SERVICE_NAME
	else string!(name(module!()))]
	


/*
<definitions targetNameSpace="http://acme.com/supplier/definitions"...>
	<types>
		<xsd:schema targetNamespace="http://acme.com/supplier/types" ...>
			<xsd:import namespace="http://acme.com/supplier/types" schemaLocation="http://acme.com/supplier/types.xsd"/>
		</xsd:schema>
	</types>
</definitions>
*/

[importSchemas() : void
-> printf("
	<types>
		<xsd:schema targetNamespace=~S>
			<xsd:import namespace=~S schemaLocation=~S/>
		</xsd>
	</type>",
		Xmlo/nsurl!(Xmlo/context(),module!()),
		Xmlo/nsurl!(Xmlo/context(),module!()),
		getenv()
		
	
		)]
[wsdl!() : void -> wsdl!(Xmlo/context())]

[wsdl!(ctx:Xmlo/context) : void ->
	printf("<?xml version=\"1.0\" ?> 
<definitions name=~S
			url=~S
			xmlns:tns=~S
			targetNamespace=~S
			xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"
			xmlns:soap=\"http://schemas.xmlsoap.org/wsdl/soap/\"
			xmlns=\"http://schemas.xmlsoap.org/wsdl/\">
~I
	<service name=~S>
		<documentation></documentation> 
~I
	</service>
</definitions>", 
		service_name(),
		service_url(),
		Xmlo/nsurl!(ctx,module!()),
		Xmlo/nsurl!(ctx,module!()),
		(for m in soap_api.restrictions
			wsdlMethod!(ctx,service_name(), m)),
		service_name(),
		(for m in soap_api.restrictions
			wsdlPort!(service_url(), m)))]


[claire/load_wcl(arg:{"*/services.wsdl"}) : void ->
	//[-100] claire/load_wcl(*/services.wsdl),
	setenv("WCL_HIDE_MENU=1"),
	setenv("WCL_AVOID_GZIP=1"),
	header("Content-Type: text/xml"),
	wsdl!()]


[claire/load_wcl(arg:{"*/types.xsd"}) : void ->
	//[-100] claire/load_wcl(*/types.xsd),
	setenv("WCL_HIDE_MENU=1"),
	setenv("WCL_AVOID_GZIP=1"),
	header("Content-Type: text/xml"),
	schema!()]

[claire/load_wcl(arg:{"*/services.wsdl.gz"}) : void ->
	//[-100] claire/load_wcl(*/services.wsdl),
	setenv("WCL_HIDE_MENU=1"),
	header("Content-Type: text/xml"),
	wsdl!()]


[claire/load_wcl(arg:{"*/types.xsd.gz"}) : void ->
	//[-100] claire/load_wcl(*/types.xsd),
	setenv("WCL_HIDE_MENU=1"),
	header("Content-Type: text/xml"),
	schema!()]


[schema!() : void -> Xmlo/schema!((let x := Xmlo/schema() in (for c in class (if Xmlo/xmlized?(c) x.Xmlo/tostore :add c), x)))]

