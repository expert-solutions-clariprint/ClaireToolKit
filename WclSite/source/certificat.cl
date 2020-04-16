
// *********************************************************************
// * WclSite                                           Sylvain Benilan *
// * certificat.cl                                                     *
// * Copyright (C) 2005 xl. All Rights Reserved                        *
// *********************************************************************

// *********************************************************************
// *   Part 1: model                                                   *
// *********************************************************************

cX509 :: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_BLOB)
cUsage :: Dbo/dbProperty()
cPrivateKey :: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_BLOB)
cOrganization :: Dbo/dbProperty()
cUser :: Dbo/dbProperty()

ROOT_CERTIFICATE :: 0
	HTTPS_CERTIFICATE :: 5
	APPLICATION_CERTIFICATE :: 1
		ORGANIZATION_CERTIFICATE :: 2
			USER_CERTIFICATE :: 3
TRUSTED_CERTIFICATE :: 4

WebCertificate <: ephemeral_object(
	dbId:integer,
	cX509:Openssl/X509,			//<sb> the certificate
	cPrivateKey:blob,			//<sb> the PKCS#8 encrypted private key
	cUsage:integer,				//<sb> ethier CLARIPRINT_CERTIFICATE, USER_CERTIFICATE or ORGANIZATION_CERTIFICATE
	cOrganization:WebOrganization,
	cUser:WebUser)

CERTIFICATE_CACHE:set[WebCertificate] := set<WebCertificate>()

[Dbo/dbStore?(c:{WebCertificate}) : boolean -> true]

[getInfo(self:WebCertificate) : string ->
	(print_in_string(),
	print(self.cX509),
	end_of_string())]

[Dbo/dbPrint(db:Db/Database, self:{cX509}, obj:WebCertificate, p:port) : void ->
	fwrite(Openssl/i2d(get(self, obj)), p)]

[Dbo/value!(db:Db/Database, self:{cX509}, obj:WebCertificate, p:port) : Openssl/X509 ->
	//[3] Dbo/value!(db:Db/Database, self:{cX509}, obj:WebCertificate, p:port),
	Openssl/d2i_X509(string!(p))]

[Dbo/dbPrint(db:Db/Database, self:{cPrivateKey}, obj:WebCertificate, p:port) : void ->
	set_index(obj.cPrivateKey, 0),
	freadwrite(obj.cPrivateKey, p)]

[Dbo/value!(db:Db/Database, self:{cPrivateKey}, obj:WebCertificate, p:port) : port ->
	//[3] Dbo/value!(db:Db/Database, self:{cPrivateKey}, obj:WebCertificate, p:port),
	let new_p := blob!()
	in (freadwrite(p, new_p),
		new_p)]

// *********************************************************************
// *   Part 2: load                                                    *
// *********************************************************************

//<sb> cache of loaded certs
TRUSTED_CERTS:set[WebCertificate] := set<WebCertificate>()

ROOT_CERT:(WebCertificate U {unknown}) := unknown
APP_CERT:(WebCertificate U {unknown}) := unknown
ORG_CERT:(WebCertificate U {unknown}) := unknown
USER_CERT:(WebCertificate U {unknown}) := unknown
HTTPS_CERT:(WebCertificate U {unknown}) := unknown

[load_certificates() : void ->
	let db := get_admin_database()
	in (//[-100] load_certificates() from ~S // db,
		for x in Dbo/dbLoadWhere(db, WebCertificate, list(tuple(cUsage, ROOT_CERTIFICATE)))
			ROOT_CERT := x,
		for x in Dbo/dbLoadWhere(db, WebCertificate, list(tuple(cUsage, HTTPS_CERTIFICATE)))
			(HTTPS_CERT := x,
			CERTIFICATE_CACHE add x),
		for x in Dbo/dbLoadWhere(db, WebCertificate, list(tuple(cUsage, APPLICATION_CERTIFICATE)))
			(APP_CERT := x,
			CERTIFICATE_CACHE add x),
		for x in Dbo/dbLoadWhere(db, WebCertificate, list(tuple(cUsage, TRUSTED_CERTIFICATE)))
			(TRUSTED_CERTS add x,
			CERTIFICATE_CACHE add x))]

[load_certificates(self:WebOrganization) : void ->
	load_certificates(),
	let db := get_admin_database()
	in for x in Dbo/dbLoadWhere(db, WebCertificate, list(tuple(cOrganization, self)))
		(ORG_CERT := x,
		CERTIFICATE_CACHE add x)]

[load_certificates(self:WebUser) : void ->
	load_certificates(self.usrOrganization),
	let db := get_admin_database()
	in for x in Dbo/dbLoadWhere(db, WebCertificate, list(tuple(cUser, self)))
		(USER_CERT := x,
		CERTIFICATE_CACHE add x)]

[load_all_certificates() : void ->
	let db := get_admin_database()
	in for x in Dbo/dbLoad(db, WclSite/WebCertificate)
		(if (x.cUsage = ROOT_CERTIFICATE)
			ROOT_CERT := x
		else if (x.cUsage = TRUSTED_CERTIFICATE)
			TRUSTED_CERTS add x
		else CERTIFICATE_CACHE add x)]

[get_private_key(self:WebCertificate, pass:string) : Openssl/key ->
	Openssl/d2i_PKCS8(string!(self.cPrivateKey), pass)]

[change_key_password(self:WebCertificate, old_pass:string, new_pass:string) : void ->
	let db := get_admin_database(),
		key := Openssl/d2i_PKCS8(string!(self.cPrivateKey), old_pass)
	in (self.cPrivateKey := blob!(Openssl/i2d(key, new_pass)),
		Dbo/dbUpdate(db, self))]


// *********************************************************************
// *   Part 3: create                                                  *
// *********************************************************************

[create_certificate(usage:integer, keysz:integer, CN:string, O:string, C:string, email:string, pass:string, ndays:integer) : WebCertificate ->
	let db := get_admin_database(),
		cert := WebCertificate(cUsage = usage),
		key := Openssl/rsa!(keysz),
		x509 := Openssl/X509!(key)
	in (Openssl/set_version(x509, 2),
		Openssl/add_subject_entry(x509, "CN", CN),
		Openssl/add_subject_entry(x509, "O", O),
		Openssl/add_subject_entry(x509, "C", C),
		if (length(email) > 0)
			Openssl/add_subject_entry(x509, "emailAddress", email),
		Openssl/set_not_before(x509, -1),
		Openssl/set_not_after(x509, ndays),
		cert.cX509 := x509,
		cert.cPrivateKey := blob!(Openssl/i2d(key, pass)),
		cert)]
		
[sign_and_save_certificate(self:WebCertificate, signer:WebCertificate, pathlen:integer, pass:string) : void ->
	let db := get_admin_database(),
		pkey := get_private_key(signer, pass),
		x509 := self.cX509
	in (Dbo/dbCreate(db, self), //<sb> pour avoir l'id en base utilisé pour le n° serie du certificat
		Openssl/set_serial(x509, self.dbId),
		Openssl/set_issuer(x509, signer.cX509),
		if (self.cUsage % {USER_CERTIFICATE, HTTPS_CERTIFICATE})
			(Openssl/set_basic_constraints(x509, "critical,CA:false"),
			Openssl/set_key_usage(x509, "critical,digitalSignature"),
			Openssl/set_subject_key_identifier(x509, "hash"),
			Openssl/set_authority_key_identifier(x509, "keyid:always,issuer:always"))
		else
			(if (pathlen >= 0)
				Openssl/set_basic_constraints(x509, "critical,CA:true,pathlen:" /+ string!(pathlen))
			else Openssl/set_basic_constraints(x509, "critical,CA:true"),
			Openssl/set_subject_key_identifier(x509, "hash"),
			Openssl/set_authority_key_identifier(x509, "keyid:always,issuer:always"),
			Openssl/set_key_usage(x509, "critical,keyCertSign")),
		Openssl/sign(x509, pkey), //<sb> self signed
		Dbo/dbUpdate(db, self))]

[renewal_certificate(self:WebCertificate, signer:WebCertificate, ndays:integer, pass:string) : void ->
	let db := get_admin_database(),
		pkey := get_private_key(signer, pass),
		x509 := self.cX509
	in (Openssl/set_not_after(x509, ndays),
		Openssl/sign(x509, pkey),
		Dbo/dbUpdate(db, self))]


// *********************************************************************
// *   Part 4: verify                                                  *
// *********************************************************************

[verify_certificate(cert:WebCertificate) : boolean ->
	let trusted := list<Openssl/X509>(),
		untrusted := list<Openssl/X509>{c.cX509|c in CERTIFICATE_CACHE}
	in (if known?(ROOT_CERT)
			trusted add ROOT_CERT.cX509,
		for x in TRUSTED_CERTS
			trusted add x.cX509,
		Openssl/verify(cert.cX509, trusted, untrusted))]

// *********************************************************************
// *   Part 5: update                                                  *
// *********************************************************************

[replace_certificate(self:WebCertificate, p12:string, pass:string) : void ->
	let db := get_admin_database(),
		(x509, key) := Openssl/d2i_PKCS12(p12, pass)
	in (self.cX509 := x509,
		self.cPrivateKey := blob!(Openssl/i2d(key, pass)),
		Dbo/dbUpdate(db, self))]

[import_certificate(usage:integer, p12:string, pass:string) : WebCertificate ->
	let db := get_admin_database(),
		cert := WebCertificate(cUsage = usage),
		(x509, key) := Openssl/d2i_PKCS12(p12, pass)
	in (cert.cX509 := x509,
		cert.cPrivateKey := blob!(Openssl/i2d(key, pass)),
		Dbo/dbCreate(db, cert),
		cert)]

