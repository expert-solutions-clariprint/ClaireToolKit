



// create a root CA /////////////////////////

ca_key :: rsa!(512)
ca :: X509!(ca_key)

(add_subject_entry(ca, "CN","CARoot"))
(add_subject_entry(ca, "O","expert-solutions"))
(add_subject_entry(ca, "C","FR"))
(set_issuer(ca,ca)) // self issued
(set_serial(ca,0))
(set_not_before(ca, -1))
(set_not_after(ca, 30))

(set_basic_constraints(ca, "critical,CA:true,pathlen:2"))
(set_subject_key_identifier(ca, "hash"))
(set_authority_key_identifier(ca, "keyid:always,issuer:always"))
(set_key_usage(ca, "critical,keyCertSign,cRLSign"))
//(set_crl_distribution_points(ca,"URI:http://myhost.com/myca.crl "))


(sign(ca, ca_key))

(save_X509_pem(ca, "ca.pem"))


// create a sub CA /////////////////////////


subca_key :: rsa!(512)
subca :: X509!(subca_key)

(add_subject_entry(subca, "CN","SUB-CA"))
(add_subject_entry(subca, "O","expert-solutions"))
(add_subject_entry(subca, "C","FR"))
(set_issuer(subca,ca)) // issued by ca
(set_serial(subca,1))
(set_not_before(subca, -1))
(set_not_after(subca, 30))

(set_key_usage(subca, "critical,keyCertSign"))
(set_basic_constraints(subca, "critical,CA:true,pathlen:0"))
(set_subject_key_identifier(subca, "hash"))
(set_authority_key_identifier(subca, "keyid:always,issuer:always"))
(set_issuer_alt_name(subca, "issuer:copy"))
//(set_crl_distribution_points(subca,"URI:http://myhost.com/mysubca.crl "))

(sign(subca, ca_key))

(append_X509_pem(subca, "ca.pem"))


// create a subsub CA /////////////////////////


subsubca_key :: rsa!(512)
subsubca :: X509!(subsubca_key)

(add_subject_entry(subsubca, "CN","SUBSUB-CA"))
(add_subject_entry(subsubca, "O","expert-solutions"))
(add_subject_entry(subsubca, "C","FR"))
(set_issuer(subsubca,subca)) // issued by subca
(set_serial(subsubca,4))
(set_not_before(subsubca, -1))
(set_not_after(subsubca, 30))

(set_basic_constraints(subsubca, "critical,CA:true"))
(set_key_usage(subsubca, "critical,keyCertSign"))
(set_subject_key_identifier(subsubca, "hash"))
(set_authority_key_identifier(subsubca, "keyid:always,issuer:always"))
(set_issuer_alt_name(subsubca, "issuer:copy"))
//(set_crl_distribution_points(subsubca,"URI:http://myhost.com/subsubca.crl "))
(set_authority_info_access(subsubca, "caIssuers;URI:http://ocsp.my.host/"))

(sign(subsubca, subca_key))

(append_X509_pem(subsubca, "ca.pem"))


// create an end user cert /////////////////////////

cert_key :: rsa!(512)
cert :: X509!(cert_key)

(add_subject_entry(cert, "CN","bob"))
(add_subject_entry(cert, "O","expert-solutions"))
(add_subject_entry(cert, "C","FR"))
(set_issuer(cert,subsubca)) // issued by subca
(set_serial(cert,2))
(set_not_before(cert, -1))
(set_not_after(cert, 1))

(set_key_usage(cert, "critical,digitalSignature,nonRepudiation,keyEncipherment"))
(set_subject_key_identifier(cert, "hash"))
(set_authority_key_identifier(cert, "keyid:always,issuer:always"))

(sign(cert, subsubca_key))


(save_X509_pem(cert, "cert.pem"))


cas :: load_X509_pem("ca.pem")
ca :: cas[1]
subca :: cas[2]
subsubca :: cas[3]
cert :: load_X509_pem("cert.pem")[1]


