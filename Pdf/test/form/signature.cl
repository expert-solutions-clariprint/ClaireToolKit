(print_in_html(d))

(begin(Openssl))

// create an authority

ca_key :: rsa!(1024)
ca :: X509!(ca_key)

(add_subject_entry(ca, "CN","XLCA"))
(add_subject_entry(ca, "O","eXpert soLutions Certificate Authority"))
(add_subject_entry(ca, "C","FR"))
(set_issuer(ca, ca)) // self issued
(set_serial(ca, 0))
(set_not_before(ca, -1))
(set_not_after(ca, 30))
(sign(ca, ca_key))

// create an end user cert

cert_key :: rsa!(1024)
cert :: X509!(cert_key)

(add_subject_entry(cert, "CN", "Sylvain"))
(add_subject_entry(cert, "O", "eXpert soLutions"))
(add_subject_entry(cert, "C", "FR"))
(add_subject_entry(cert, "emailAddress", "s.benilan@claire-language.com"))
(set_issuer(cert, ca))
(set_serial(cert, 1))
(set_not_before(cert, -1))
(set_not_after(cert, 30))
(sign(cert, ca_key))

(begin(Pdf))

// add a signature to the document

( ?><signature certificate=<?oid Openssl/cert ?>
				key=<?oid Openssl/cert_key ?>
				chain=<?oid list<Openssl/X509>(Openssl/ca) ?>
				reason="I'm the author"
				location=Cenon
				contact-info=0102030405>
		<normal>normal</normal>
		<rollover><img src=test/image/webclaire.png></rollover>
	</signature>
<? )

(end_of_html(d))
