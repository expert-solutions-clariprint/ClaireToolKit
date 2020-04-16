
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * x509.cl                                                           *
// * Copyright (C) 2004-2005 xl. All Rights Reserved                   *
// *********************************************************************

// *********************************************************************
// *   Part 1: model                                                   *
// *   Part 2: X509 DER encoding                                       *
// *   Part 3: creating X509                                           *
// *   Part 4: adding X509 v3 extension                                *
// *   Part 5: inspecting X509                                         *
// *   Part 6: PEM encoding                                            *
// *   Part 7: signing certificate                                     *
// *   Part 8: verifying a certificate chain                           *
// *********************************************************************


// @cat X509
// X509 certificates use Public Key Infrastructure (PKI) to support certificate creation and verification.
// In PKI, key pairs are generated where one key is kept private (private key) and one key is given away
// freely (public key). Data encrypted with a private key can only be decrypted with the matching public
// key and data encrypted with the public key can only be decrypted with the matching private key.\br
// In this section we'll create a sample Certification Authority by hand.
// As a first step we need a key pair and a CA certificate :
// \code
// ca_key :: Openssl/rsa!(512)
// ca :: Openssl/X509!(ca_key)
// \/code
// Then we'll add to the CA certificate a subject entry :
// \code
// (Openssl/add_subject_entry(ca, "CN","CARoot"))
// (Openssl/add_subject_entry(ca, "O","claire-language"))
// (Openssl/add_subject_entry(ca, "C","FR"))
// \/code
// Our CA certificate is a root certificate (self signed) :
// \code
// (Openssl/set_issuer(ca,ca)) // self issued
// \/code
// We now update its serial number and validity period :
// \code
// (Openssl/set_serial(ca,0))
// (Openssl/set_not_before(ca, -1))
// (Openssl/set_not_after(ca, 3000))
// \/code
// Then we set some X509 v3 extensions :
// \code
// (Openssl/set_basic_constraints(ca, "critical,CA:true,pathlen:1"))
// (Openssl/set_subject_key_identifier(ca, "hash"))
// (Openssl/set_authority_key_identifier(ca, "keyid:always,issuer:always"))
// (Openssl/set_key_usage(ca, "critical,keyCertSign,cRLSign"))
// \/code
// And as a last step we (self) sign the certificate and save it
// in the PEM format to the file ca.pem :
// \code
// (Openssl/sign(ca, ca_key))
// (Openssl/save_X509_pem(ca, "ca.pem"))
// \/code
// Since we now have a CA certificate we can create a user certificate following
// the same steps as above. Note that the user certificate is issued and signed with
// the above certificate :
// \code
// cert_key :: Openssl/rsa!(512)
// cert :: Openssl/X509!(cert_key)
// 
// (Openssl/add_subject_entry(cert, "CN","some_user"))
// (Openssl/add_subject_entry(cert, "O","claire-language"))
// (Openssl/add_subject_entry(cert, "C","FR"))
// (Openssl/set_issuer(cert, ca)) // issued by our CA
// (Openssl/set_serial(cert, 1))
// (Openssl/set_not_before(cert, -1))
// (Openssl/set_not_after(cert, 30)) // 30 days validity period
// 
// (Openssl/set_key_usage(cert, "critical,digitalSignature,nonRepudiation,keyEncipherment"))
// (Openssl/set_subject_key_identifier(cert, "hash"))
// (Openssl/set_authority_key_identifier(cert, "keyid:always,issuer:always"))
// 
// (Openssl/sign(cert, ca_key))
// (Openssl/save_X509_pem(cert, "cert.pem"))
// \/code
// Last we may verify that our user certificate is valid :
// \code
// cert :: Openssl/load_X509_pem("cert.pem")[1]
// (if verify(cert, Openssl/load_X509_pem("ca.pem"), nil)
// 		printf("~S is valid\n", cert)
// else printf("~S is not valid (~A)\n", cert, cert.Openssl/verify_message))
// \/code
// @cat


// *********************************************************************
// *   Part 1: model                                                   *
// *********************************************************************

X509* <: import()
(c_interface(X509*,"X509*"))

X509 <: freeable_object
X509 <: freeable_object(
			x509*:X509*,
			associated_key:key,
			issuer_cert:X509,
			valid?:boolean = false,
			verify_message:string)


[free!(self:X509) : void -> externC("X509_free(self->x509_star)")]


[X509!(self:X509*) : X509 => X509(x509* = self)]


self_print(self:X509) : void ->
	(if unknown?(x509*, self) printf("<X509/corrupted!?>")
	else printf("<X509~A>", get_subject(self)))

//<sb> princ produce a readable form of the X509 as
// with the -text option of the openssl tool
[princ(self:X509) : void ->
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	externC("X509_print_ex(bp, self->x509_star,0,0)"),
	let len := externC("BIO_ctrl_pending(bp)", integer)
	in (externC("ClEnv->bufferStart();ClEnv->pushAttempt(len)"),
		externC("len = BIO_read(bp, ClEnv->buffer, len)"),
		externC("princ_string1(ClEnv->buffer, 1, len)"),
		externC("BIO_free(bp)"))]
	

// *********************************************************************
// *   Part 2: X509 DER encoding                                       *
// *********************************************************************


//<sb> @doc X509
// i2d(self) creates a DER encoded version of the given certificate.
[i2d(self:X509) : string ->
	externC("ClEnv->bufferStart();ClEnv->pushAttempt(20000)"),
	externC("unsigned char* buf = (unsigned char*)ClEnv->buffer"),
	let len := externC("i2d_X509(self->x509_star, &buf)", integer)
	in copy(externC("ClEnv->buffer", string), len)]


//<sb> @doc X509
// d2i_X509(self) decodes a DER encoded certificate.
[d2i_X509(self:string) : X509 ->
	let buf := self,
		len := length(self),
		x := X509()
	in (if (externC("((x->x509_star = d2i_X509(NULL,(const unsigned char**)&buf,len)) == NULL)",integer) = 1)
			openssl_error!(),
		x)]


// *********************************************************************
// *   Part 3: creating X509                                           *
// *********************************************************************

//<sb> @doc X509
// X509!(k) construct a new X509 v3 certificate associated to the given public key.
[X509!(k:key) : X509 ->
	let x := externC("X509_new()", X509*),
		serial := 0
	in (externC("X509_set_pubkey(x, k->evp_key)"),
		if (externC("X509_set_version(x,2)", integer) = 0) //<sb> X509 v3
			(externC("X509_free(x)"),
			openssl_error!()),
		let res := X509!(x)
		in (res.associated_key := k,
			res))]

//<sb> @doc X509
// set_serial(self, serial) sets the serial number attribute of the given certificate.
[set_serial(self:X509, serial:integer) : void ->
	externC("ASN1_INTEGER_set(X509_get_serialNumber(self->x509_star), (long)serial)")]

//<sb> @doc X509
// set_version(self, ver) sets the version of the given certificate (v1 is 0, v2 1 and v3 2).
[set_version(self:X509, ver:{0,1,2}) : void ->
	externC("X509_set_version(self->x509_star, ver)")]


//<sb> @doc X509
// set_not_before(self, days) sets the given certificate's starting validity date
// as a number a days from now (days can be negative)
[set_not_before(self:X509, days:integer) : void ->
		externC("X509_gmtime_adj(X509_get_notBefore(self->x509_star),(long)60*60*24*days)")]
	
//<sb> @doc X509
// set_not_after(self, days) sets the given certificate's expiration date
// as a number a days from now
[set_not_after(self:X509, days:integer) : void ->
		externC("X509_gmtime_adj(X509_get_notAfter(self->x509_star),(long)60*60*24*days)")]


//<sb> @doc X509
// add_issuer_entry(self, field, val) adds an entry in the issuer distinguish name (DN)
// of the given certificate, for instance :
// \ul
// \li "CN" common name
// \li "C" country name
// \li "L" locality name
// \li "ST" state or province name
// \li "O" organization name
// \li "OU" organizational unit name
// \li "emailAddress" email address
// \li ...
// \/ul
[add_issuer_entry(self:X509, field:string, val:string) : void ->
	externC("X509_NAME *name"),
	if (externC("(name = X509_get_issuer_name(self->x509_star))", integer) = 0)
			openssl_error!(),
	if (externC("X509_NAME_add_entry_by_txt(name, field, MBSTRING_ASC, (unsigned char*)val, -1, -1, 0)",integer) = 0)
		openssl_error!()]

//<sb> @doc X509
// add_issuer_entry(self, field, val) adds an entry in the subject distinguish name (DN)
// of the given certificate, for instance :
// \ul
// \li "CN" common name
// \li "C" country name
// \li "L" locality name
// \li "ST" state or province name
// \li "O" organization name
// \li "OU" organizational unit name
// \li "emailAddress" email address
// \li ...
// \/ul
[add_subject_entry(self:X509, field:string, val:string) : void ->
	externC("X509_NAME *name"),
	if (externC("(name = X509_get_subject_name(self->x509_star))", integer) = 0)
			openssl_error!(),
	if (externC("X509_NAME_add_entry_by_txt(name, field, MBSTRING_ASC, (unsigned char*)val, -1, -1, 0)",integer) = 0)
		openssl_error!()]

//<sb> @doc X509
// set_issuer(self, issuer) sets the issuer certificate for a new one.
// The issuer DN is updated with the subject DN of the issuer
// you need to call it before adding v3 extension
// in order to create a root CA you will call set_issuer with issuer = self.
[set_issuer(self:X509, issuer:X509) : void ->
	(externC("X509_NAME *name, *namedup"),
	if (externC("(name = X509_get_subject_name(issuer->x509_star))", integer) = 0)
		openssl_error!(),
	if (externC("(namedup = X509_NAME_dup(name))", integer) = 0)
		openssl_error!(),
	if (externC("X509_set_issuer_name(self->x509_star, namedup)", integer) = 0)
		openssl_error!(),
	self.issuer_cert := issuer)]



// *********************************************************************
// *   Part 4: adding X509 v3 extension                                *
// *********************************************************************

//<sb> most of comments, in this part, come from openssl web site at
// http://www.openssl.org/docs/apps/x509v3_config.html
// and RFC 2459 that describes X509 v3 extension


//<sb> @doc X509
// add_extension(self, nid, value) is a general tools to add a v3 extension to an X509
// by a NID value.
[add_extension(self:X509, nid:integer, value:string) : void ->
	if unknown?(issuer_cert, self)
		//<sb> set_issuer shoul be called before
		error("unknown issuer of ~S, can't add X509 v3 extension ~A=~A", self, nid2txt(nid)[2], value),
	externC("X509_EXTENSION* ext"),
	externC("X509V3_CTX ctx"),
	externC("X509V3_set_ctx_nodb(&ctx)"),
	externC("X509V3_set_ctx(&ctx, self->issuer_cert->x509_star, self->x509_star, NULL, NULL, 0)"),
	if (externC("(ext = X509V3_EXT_conf_nid(NULL, &ctx, nid, value))", integer) = 0)
		openssl_error!(),
	externC("X509_add_ext(self->x509_star, ext, -1)"),
	externC("X509_EXTENSION_free(ext)")]

//<sb> @doc X509
// add_extension(self, txt, value) is a general tools to add a v3 extension to an X509
// by a NID name.
[add_extension(self:X509, txt:string, value:string) : void =>
	add_extension(self, txt2nid(txt), value)]


//<sb> Basic Constraints.
// @doc X509
// This is a multi valued extension which indicates whether a certificate
// is a CA certificate. The first (mandatory) name is CA followed by TRUE
// or FALSE. If CA is TRUE then an optional pathlen name followed by an
// non-negative value can be included.
//
// Example:
// \ul
//	\li basicConstraints=CA:TRUE
//	\li basicConstraints=CA:FALSE
//	\li basicConstraints=critical,CA:TRUE, pathlen:0
// \/ul
// A CA certificate must include the basicConstraints value with the CA field
// set to TRUE. An end user certificate must either set CA to FALSE or exclude
// the extension entirely. Some software may require the inclusion of basicConstraints
// with CA set to FALSE for end entity certificates.\br
//
// The pathlen parameter indicates the maximum number of CAs that can appear below this
// one in a chain. So if you have a CA with a pathlen of zero it can only be used to sign
// end user certificates and not further CAs.
[set_basic_constraints(self:X509, basic_constraints:string) : void ->
	add_extension(self, externC("_integer_(NID_basic_constraints)", integer), basic_constraints)]


//<sb> Subject Key Identifier.
// @doc X509
// This is really a string extension and can take two possible values. Either
// the word hash which will automatically follow the guidelines in RFC3280 or
// a hex string giving the extension value to include. The use of the hex string
// is strongly discouraged.
//
// Example:
// \ul
//	\li subjectKeyIdentifier=hash
// \/ul
[set_subject_key_identifier(self:X509, subject_key_identifier:string) : void ->
	add_extension(self, externC("_integer_(NID_subject_key_identifier)", integer), subject_key_identifier)]


//<sb> Authority Key Identifier.
// @doc X509
// The authority key identifier extension permits two options. keyid and
// issuer: both can take the optional value ``always''.\br
//
// If the keyid option is present an attempt is made to copy the subject key
// identifier from the parent certificate. If the value ``always'' is present
// then an error is returned if the option fails.\br
//
// The issuer option copies the issuer and serial number from the issuer
// certificate. This will only be done if the keyid option fails or is not
// included unless the ``always'' flag will always include the value.
//
// Example:
// \ul
//	\li authorityKeyIdentifier=keyid,issuer
// \/ul
[set_authority_key_identifier(self:X509, authority_key_identifier:string) : void ->
	add_extension(self, externC("_integer_(NID_authority_key_identifier)", integer), authority_key_identifier)]


//<sb> Netscape Certificate Type (deprecated)
//
// This is a multi-valued extensions which consists of a list of flags to be
// included. It was used to indicate the purposes for which a certificate could
// be used. The basicConstraints, keyUsage and extended key usage extensions are now used instead.
//
// Acceptable values for nsCertType are:
//	client, server, email, objsign, reserved, sslCA, emailCA, objCA.
[set_netscape_cert_type(self:X509, cert_type:string) : void ->
	add_extension(self, externC("_integer_(NID_netscape_cert_type)", integer), cert_type)]


//<sb> Key Usage.
// @doc X509
// Key usage is a multi valued extension consisting of a list of names of
// the permitted key usages.\br
//
// The supporte names are: digitalSignature, nonRepudiation, keyEncipherment,
// dataEncipherment, keyAgreement, keyCertSign, cRLSign, encipherOnly and decipherOnly.
//
// Examples:
// \ul
//	\li keyUsage=digitalSignature, nonRepudiation
//	\li keyUsage=critical, keyCertSign
// \/ul
//
// From RFC 2459 :
//	The key usage extension defines the purpose (e.g., encipherment,
//	signature, certificate signing) of the key contained in the
//	certificate.  The usage restriction might be employed when a key that
//	could be used for more than one operation is to be restricted.  For
//	example, when an RSA key should be used only for signing, the
//	digitalSignature and/or nonRepudiation bits would be asserted.
//	Likewise, when an RSA key should be used only for key management, the
//	keyEncipherment bit would be asserted. When used, this extension
//	SHOULD be marked critical.
// \ul
// \li digitalSignature :
//	The digitalSignature bit is asserted when the subject public key
//	is used with a digital signature mechanism to support security
//	services other than non-repudiation (bit 1), certificate signing
//	(bit 5), or revocation information signing (bit 6). Digital
//	signature mechanisms are often used for entity authentication and
//	data origin authentication with integrity.
//	
// \li nonRepudiation :
//	The nonRepudiation bit is asserted when the subject public key is
//	used to verify digital signatures used to provide a non-
//	repudiation service which protects against the signing entity
//	falsely denying some action, excluding certificate or CRL signing.
//	
// \li keyEncipherment :
//	The keyEncipherment bit is asserted when the subject public key is
//	used for key transport.  For example, when an RSA key is to be
//	used for key management, then this bit shall asserted.
//	
// \li dataEncipherment :
//	The dataEncipherment bit is asserted when the subject public key
//	is used for enciphering user data, other than cryptographic keys.
//	
// \li keyAgreement :
//	The keyAgreement bit is asserted when the subject public key is
//	used for key agreement.  For example, when a Diffie-Hellman key is
//	to be used for key management, then this bit shall asserted.
//	
// \li keyCertSign :
//	The keyCertSign bit is asserted when the subject public key is
//	used for verifying a signature on certificates.  This bit may only
//	be asserted in CA certificates.
//	
// \li cRLSign :
//	The cRLSign bit is asserted when the subject public key is used
//	for verifying a signature on revocation information (e.g., a CRL).
//	
// \li encipherOnly :
//	The meaning of the encipherOnly bit is undefined in the absence of
//	the keyAgreement bit.  When the encipherOnly bit is asserted and
//	the keyAgreement bit is also set, the subject public key may be
//	used only for enciphering data while performing key agreement.
//
// \li decipherOnly	:
//	The meaning of the decipherOnly bit is undefined in the absence of
//	the keyAgreement bit.  When the decipherOnly bit is asserted and
//	the keyAgreement bit is also set, the subject public key may be
//	used only for deciphering data while performing key agreement.
// \/ul
[set_key_usage(self:X509, key_usage:string) : void ->
	add_extension(self, externC("_integer_(NID_key_usage)", integer), key_usage)]


//<sb> Subject Alternative Name
// @doc X509
// The subject alternative name extension allows various literal values to
// be included in the configuration file. These include email (an email address)
// URI a uniform resource indicator, DNS (a DNS domain name),
// RID (a registered ID: OBJECT IDENTIFIER), IP (an IP address),
// dirName (a distinguished name) and otherName.\br
//
// The email option include a special 'copy' value. This will automatically include
// and email addresses contained in the certificate subject name in the extension.\br
//
// The IP address used in the IP options can be in either IPv4 or IPv6 format.\br
//
// The value of dirName should point to a section containing the distinguished name
// to use as a set of name value pairs. Multi values AVAs can be formed by preceeding
// the name with a + character.\br
//
// otherName can include arbitrary data associated with an OID: the value should be
// the OID followed by a semicolon and the content in standard ASN1_generate_nconf()
// format.
//
// Example:
// \ul
//	\li subjectAltName = email:copy,email:my@other.address,URI:http://my.url.here/
//	\li subjectAltName = IP:192.168.7.1
//	\li subjectAltName = IP:13::17
//	\li subjectAltName = email:my@other.address,RID:1.2.3.4
//	\li subjectAltName = otherName:1.2.3.4;UTF8:some other identifier
//	\li subjectAltName = dirName:dir_sect
// \/ul
//
//	[dir_sect]
// \ul
//	\li C=UK
//	\li O=My Organization
//	\li OU=My Unit
//	\li CN=My Name
// \/ul
[set_subject_alt_name(self:X509, subject_alt_name:string) : void ->
	add_extension(self, externC("_integer_(NID_subject_alt_name)", integer), subject_alt_name)]


//<sb> Issuer Alternative Name.
// @doc X509
// The issuer alternative name option supports all the literal options of subject
// alternative name. It does not support the email:copy option because that would
// not make sense. It does support an additional issuer:copy option that will copy
// all the subject alternative name values from the issuer certificate (if possible).
//
// Example:
// \ul
//	\li issuserAltName = issuer:copy
// \/ul
[set_issuer_alt_name(self:X509, issuer_alt_name:string) : void ->
	add_extension(self, externC("_integer_(NID_issuer_alt_name)", integer), issuer_alt_name)]


//<sb> Authority Info Access.
// @doc X509
// The authority information access extension gives details about how to access
// certain information relating to the CA. Its syntax is accessOID;location where
// location has the same syntax as subject alternative name (except that email:copy
// is not supported). accessOID can be any valid OID but only certain values are
// meaningful, for example OCSP and caIssuers.
//
// Example:
// \ul
//	\li authorityInfoAccess = OCSP;URI:http://ocsp.my.host/
//	\li authorityInfoAccess = caIssuers;URI:http://my.ca/ca.html 
// \/ul
[set_authority_info_access(self:X509, authority_info_access:string) : void ->
	add_extension(self, externC("_integer_(NID_info_access)", integer), authority_info_access)]


//<sb> CRL distribution points.
// @doc X509
// This is a multi-valued extension that supports all the literal options of subject
// alternative name. Of the few software packages that currently interpret this
// extension most only interpret the URI option.\br
//
// Currently each option will set a new DistributionPoint with the fullName field set
// to the given value.\br
//
// Other fields like cRLissuer and reasons cannot currently be set or displayed: at this
// time no examples were available that used these fields.
//
// Examples:
// \ul
//	\li crlDistributionPoints = URI:http://myhost.com/myca.crl 
//	\li crlDistributionPoints = URI:http://my.com/my.crl,URI:http://oth.com/my.crl 
// \/ul
[set_crl_distribution_points(self:X509, clr_distribution_points:string) : void ->
	add_extension(self, externC("_integer_(NID_crl_distribution_points)", integer), clr_distribution_points)]


// *********************************************************************
// *   Part 5: inspecting X509                                         *
// *********************************************************************


//<sb> @doc X509
// get_version(self) returns the X509 version of the given certificate
// the version should be in (0 .. 2) i.e. (v1 .. v3).
[get_version(self:X509) : integer ->
	externC("X509_get_version(self->x509_star)", integer)]

//<sb> @doc X509
// get_serial(self) returns the serial number of the given certificate.
[get_serial(self:X509) : integer ->
	externC("_integer_(ASN1_INTEGER_get(X509_get_serialNumber(self->x509_star)))", integer)]

//<sb> @doc X509
// get_pubkey(self) returns the public key of a the given certificate.
[get_pubkey(self:X509) : key ->
	let k := key!()
	in (externC("k->evp_key = X509_get_pubkey(self->x509_star)"),
		k)]

//<sb> @doc X509
// get_issuer_entry_count(self) return the amount of entry in the issuer distinguished name (DN) of
// the given certificate.
[get_issuer_entry_count(self:X509) : integer ->
	externC("X509_NAME *name"),
	if (externC("(name = X509_get_issuer_name(self->x509_star))", integer) = 0)
			openssl_error!(),
	externC("X509_NAME_entry_count(name)", integer)]

//<sb> @doc X509
// get_subject_entry_count(self) returns the amount of entry the subject distinguished name (DN) of
// the given certificate.
[get_subject_entry_count(self:X509) : integer ->
	externC("X509_NAME *name"),
	if (externC("(name = X509_get_subject_name(self->x509_star))", integer) = 0)
			openssl_error!(),
	externC("X509_NAME_entry_count(name)", integer)]

//<sb> @doc X509
// get_subject_entry(self, field) returns the subject's DN entry value for the given field name.
[get_subject_entry(self:X509, field:string) : string ->
	let nid := txt2nid(field)
	in (externC("X509_NAME *name"),
		if (externC("(name = X509_get_subject_name(self->x509_star))", integer) = 0)
			openssl_error!(),
		externC("ClEnv->bufferStart();ClEnv->pushAttempt(4096)"),
		if (externC("X509_NAME_get_text_by_NID(name, nid, ClEnv->buffer, 4096)", integer) = -1)
			openssl_error!(),
		copy(externC("ClEnv->buffer", string)))]

//<sb> @doc X509
// get_issuer_entry(self, field) returns the issuer's DN entry value for the given field name.
[get_issuer_entry(self:X509, field:string) : string ->
	let nid := txt2nid(field)
	in (externC("X509_NAME *name"),
		if (externC("(name = X509_get_issuer_name(self->x509_star))", integer) = 0)
			openssl_error!(),
		externC("ClEnv->bufferStart();ClEnv->pushAttempt(4096)"),
		if (externC("X509_NAME_get_text_by_NID(name, nid, ClEnv->buffer, 4096)", integer) = -1)
			openssl_error!(),
		copy(externC("ClEnv->buffer", string)))]

//<sb> @doc X509
// get_issuer(self) return the an issuer's DN in the form "/CN=val/field=val...".
[get_issuer(self:X509) : string ->
	externC("X509_NAME *name"),
	if (externC("(name = X509_get_issuer_name(self->x509_star))", integer) = 0)
		openssl_error!(),
	externC("ClEnv->bufferStart();ClEnv->pushAttempt(4096)"),
	externC("X509_NAME_oneline(name, ClEnv->buffer, 4096)"),
	copy(externC("ClEnv->buffer", string))]


//<sb> @doc X509
// get_subject(self) return the an subject's DN in the form "/CN=val/field=val...".
[get_subject(self:X509) : string ->
	externC("X509_NAME *name"),
	if (externC("(name = X509_get_subject_name(self->x509_star))", integer) = 0)
		openssl_error!(),
	externC("ClEnv->bufferStart();ClEnv->pushAttempt(4096)"),
	externC("X509_NAME_oneline(name, ClEnv->buffer, 4096)"),
	copy(externC("ClEnv->buffer", string))]


// *********************************************************************
// *   Part 6: PEM encoding                                            *
// *********************************************************************


//<sb> @doc X509
// X5092pem(self) returns a PEM encoded version of the given certificate.
[X5092pem(self:X509) : string ->
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	externC("PEM_write_bio_X509(bp, self->x509_star)"),
	let len := externC("BIO_ctrl_pending(bp)", integer)
	in (externC("ClEnv->bufferStart();ClEnv->pushAttempt(len)"),
		externC("len = BIO_read(bp, ClEnv->buffer, len)"),
		externC("BIO_free(bp)"),
		copy(externC("ClEnv->buffer", string), len))]

//<sb> @doc X509
// pem2X509(pem) creates a certificate from a PEM encoded version.
[pem2X509(pem:string) : X509 ->
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	let len := length(pem),
		x := new(X509)
	in (externC("BIO_write(bp, pem, len)"),	
		externC("PEM_read_bio_X509(bp, &x->x509_star, NULL,NULL)"),
		externC("BIO_free(bp)"),
		x)]


//<sb> @doc X509
// save_X509_pem(self, pem_file) saves a PEM encoded certificate in a file.
[save_X509_pem(self:X509, pem_file:string) : void ->
	let f := fopen(pem_file, "w"),
		pem := X5092pem(self)
	in (fwrite(pem, f),
		fclose(f))]

//<sb> @doc X509
// append_X509_pem(self, pem_file) appends a PEM encoded certificate to the given file.
[append_X509_pem(self:X509, pem_file:string) : void ->
	let f := fopen(pem_file, "a"),
		pem := X5092pem(self)
	in (fwrite(pem, f),
		fclose(f))]

//<sb> @doc X509
// load_X509_pem(pem_file) loads a list of certificate from a file of
// concatened PEM endoded X509 certificates.
[load_X509_pem(pem_file:string) : list[X509] ->
	let f := fopen(pem_file, "r"),
		s := make_string(256,' '),
		l := list<X509>()
	in (externC("BIO* bp = BIO_new(BIO_s_mem())"),
		while not(eof?(f))
			let n := fread(f, s)
			in externC("BIO_write(bp, s, n)"),	
		fclose(f),
		while true
			let x := new(X509),
				rc := externC("(PEM_read_bio_X509(bp, &x->x509_star, NULL,NULL))", integer)
			in (if (rc != 0) l :add x
				else break()),
		externC("BIO_free(bp)"),
		l)]
	

// *********************************************************************
// *   Part 7: signing certificate                                     *
// *********************************************************************



//<sb> @doc X509
// sign(self, k, algo) signs a certificate with a private key
// this should be the last operation made on the
// certificate, any other update on the data structure
// would invalidate the object's signature (i.e verify
// would failed).
sign(self:X509, k:key, algo:DIGEST_ALGORYTHMS) : void ->
	let a := (if (algo = "null") externC("(EVP_MD*)EVP_md_null()", EVP_MD*)
		else externC("(EVP_MD*)EVP_get_digestbyname(algo)", EVP_MD*))
	in externC("X509_sign(self->x509_star,k->evp_key,a)")

//<sb> @doc X509
// sign(self, k) is equivalent to sign(self, k, "sha1").
sign(self:X509, k:key) : void => sign(self, k, "sha1")

//<sb> @doc X509
// verify(self, k) verifies that the key k was the one that signed the certificate.
verify(self:X509, k:key) : boolean ->
	(externC("X509_verify(self->x509_star,k->evp_key)", integer) = 1)

// *********************************************************************
// *   Part 8: certification path validation                           *
// *********************************************************************


//<sb> @doc X509
// Purposes supported for the X509 certficate verification.
VERIFY_PURPOSE :: {"sslclient", "sslserver", "nssslserver", "smimesign", "smimeencrypt", "ocsphelper", "any"}

//<sb> @doc X509
// Flags supported for the X509 certficate verification.
VERIFY_FLAGS :: {"ignore_critical", "issuer_checks", "crl_check", "crl_check_all"}

X509_STORE_CTX* <: import()
(c_interface(X509_STORE_CTX*,"X509_STORE_CTX*"))

last_error_string:string := ""

//<sb> openssl give us a callback that traces info at different level
// of verify process. debug messages are redirected to the trace port.
// see 'man openssl verify' for information on available flags
[verify_cb(ok:integer, ctx:X509_STORE_CTX*) : integer ->
	last_error_string := externC("(char*)X509_verify_cert_error_string(X509_STORE_CTX_get_error(ctx))", string),
	externC("ok", integer)]

//<sb> @doc X509
// General verifying process that support flags and purpose.
// Trusted is typicaly filled with local trusted CA certificates whereas untrusted
// is a chain of externaly supplied certificates that di facto can't be trusted.
// true is returned if the verification succeded and false is returned otherwise.
// In the later case one can get the information why the verification failed in
// self.verify_message.
verify(self:X509, trusted:list[X509], untrusted:list[X509],
			flags:subtype[VERIFY_FLAGS], purpose:VERIFY_PURPOSE) : boolean ->
	(externC("X509_STORE *store;X509_STORE_CTX *ctx"),
	externC("store = X509_STORE_new()"),
	externC("ctx = X509_STORE_CTX_new()"),
	//<sb> install the verify callback for verbose >= 0
	externC("X509_STORE_set_verify_cb_func(store, (int (*)(int, X509_STORE_CTX *))Openssl_verify_cb_integer1)"),
	externC("X509_STORE_set_default_paths(store)"),
	//<sb> handle flags
	let vflags := 0
	in (for f in flags
			case f
				({"ignore_critical"} externC("vflags |= X509_V_FLAG_IGNORE_CRITICAL"),
				{"issuer_checks"} externC("vflags |= X509_V_FLAG_CB_ISSUER_CHECK"),
				{"crl_check"} externC("vflags |= X509_V_FLAG_CRL_CHECK"),
				{"crl_check_all"} externC("vflags |= X509_V_FLAG_CRL_CHECK|X509_V_FLAG_CRL_CHECK_ALL")),
		externC("X509_STORE_set_flags(store, vflags)")),
	externC("STACK_OF(X509)* unt = sk_X509_new_null()"),
	//<sb> fill untrusted stack
	for co in untrusted
		let c := co as X509
		in externC("sk_X509_push(unt, c->x509_star)"),
	//<sb> setup verification purpose
	externC("int i = X509_PURPOSE_get_by_sname(purpose)"),
	if (externC("i", integer) < 0)
		error("~A seems to be an unsuported purpose argument for openssl verify ???", purpose),
	externC("X509_PURPOSE *xptmp = X509_PURPOSE_get0(i)"),
	externC("X509_STORE_set_purpose(store, X509_PURPOSE_get_id(xptmp))"),
	//<sb> init the verification context
	if (externC("X509_STORE_CTX_init(ctx, store, self->x509_star, unt)", integer) = 0)
		openssl_error!(),
	for co in trusted
		let c := co as X509
		in externC("X509_STORE_add_cert(store, c->x509_star)"),
	//<sb> verify !
	let bad? := (externC("X509_verify_cert(ctx)", integer) = 0)
	in (externC("X509_STORE_free(store)"),
		externC("X509_STORE_CTX_free(ctx)"),
		if bad?
			(self.verify_message := last_error_string,
			self.valid? := false,
			false)
		else (self.verify_message := "certificate is valid",
				self.valid? := true,
				true)))

//<sb> @doc X509
// verify(self, trusted, untrusted) is equivalent to verify(self, trusted, untrusted, {}, "any").
verify(self:X509, trusted:list[X509], untrusted:list[X509]) : boolean =>
	verify(self, trusted, untrusted, {}, "any")


//<sb> verify helper (for command line and debug)
// self:	the certificate to be verified
// ca:		a single trusted root CA
// args:	a list of argument composed of optional
//          	- untrusted certificates as X509s
//				- restriction flags as strings
//          	- a verification pupose as string
verify(self:X509, ca:X509, args:listargs) : boolean ->
	let trusted := list<X509>(ca),
		untrusted := list<X509>(),
		flags := list<VERIFY_FLAGS>(),
		purpose := "any"
	in (for x in args
			case x
				(X509 untrusted :add x,
				VERIFY_FLAGS flags :add x,
				VERIFY_PURPOSE purpose := x,
				any error("~S is a wrong argument for verify", x)),
		verify(self, trusted, untrusted, flags, purpose))

