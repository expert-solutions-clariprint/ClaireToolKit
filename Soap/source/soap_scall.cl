

//<sb> this is a smime-like protocol that performs a SOAP call
// with double-encryption.
[soap_scall(url:string,
			sender:Openssl/X509,
			sender_pkey:Openssl/key,
			recipient:Openssl/X509,
			chain:list[Openssl/X509],
			i:SoapIn) : SoapOut ->
	//[-100] == Soap scall(~S, ~S) from: ~S, to: ~S // url, i, sender, recipient,
	let http := Http/initialize_http_post(url)
	in (header(http, "Content-Type: application/xml.p7m"),
		header(http, "SOAPAction: \"" /+
						(print_in_string(),
						Xmlo/xmlPrint(owner(i)),
						end_of_string()) /+ "\""),
		let b := blob!(),
			old := use_as_output(b)
		in (soapXml!(i),
			use_as_output(old),
			let p7 := Openssl/sign&encrypt(sender, sender_pkey, chain, list(recipient), b)
			in (fwrite(Openssl/i2d(p7), http),
				//[0] == Soap recipients : ~S // Openssl/get_recipients(p7, list(sender))
				),
			Http/terminate_http_post(http),
			let response := Http/parse_input(http),
				ct := Http/get_http_header_in(http, "Content-Type"),
				result := unknown
			in (case ct
					({"Content-Type: text/xml"}
						//<sb> the server may return a no-encrypted response...
						result := parseClientResponse(response),
					{"Content-Type: application/xml.p7m"}
						//<sb> or an encrypted response that have to be decrypted
						let p7 := Openssl/d2i_PKCS7(fread(response)),
							b := blob!()
						in (if not(Openssl/decrypt&verify(p7, sender, sender_pkey, chain, list(recipient), b))
								error("soap_scall error"),
							result := parseClientResponse(b)),
					any error("Don't know how to handle SOAP response (on ~S) with content type ~A", http, ct)),
				//[-100] == Response parsed -> ~S // result,
				fclose(http),
				result as SoapOut)))]


