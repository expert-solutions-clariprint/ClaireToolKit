
security_context <: ephemeral_object(
		sender:Openssl/X509,
		recipient:Openssl/X509,
		untrusted:list[Openssl/X509],
		trusted:list[Openssl/X509],
		recipient_pkey:Openssl/key)

SoapIn <: object(secure_context:security_context)
SoapOut <: object()

(Xmlo/xmlizeDescendents(SoapIn))
(Xmlo/xmlizeDescendents(SoapOut))
(Xmlo/XML_PROPERTIES?[secure_context] := false)

soap_api :: property(open = 3)

/*
[Xmlo/objectToEnterTag(ctx:Xmlo/context,self:(SoapIn U SoapOut)) : boolean ->
	printf("m:~I xmlns:m=\"claire\"", Xmlo/xmlPrint(owner(self))),
	false]

[Xmlo/objectToLeaveTag(ctx:Xmlo/context,self:(SoapIn U SoapOut)) : void ->
	printf("m:~I", Xmlo/xmlPrint(owner(self)))]


[Xmlo/tagToClass(parser:Sax/sax_parser, tag:{"m"}, c:string) : class ->
	//[0] tagToClass(tag:{\"m\"}, ~S) // c,
	flush(ctrace()),
	when x := some(x in SoapIn.descendents|Xmlo/xmlName(x) = c)
	in x
	else when x := some(x in SoapOut.descendents|Xmlo/xmlName(x) = c)
	in x
	else (error("tagToClass(tag:{\"m\"}, ~S) convertion failed", c),
			any)]

*/
soap_fault <: exception(src:string)

[self_print(self:soap_fault) : void ->
	printf("**** a soap fault has occured\n~A", self.src)]

