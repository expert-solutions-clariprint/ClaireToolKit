
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * pkcs7.cl                                                          *
// * Copyright (C) 2004-2005 xl. All Rights Reserved                   *
// *********************************************************************

// @cat PKCS#7
// In this section we'll create a signed and encryted PKCS#7 and verify
// it. For that purpose we need a CA trusted certificate, a singer certificate
// and a least one recipient certificate. The creation of certificate is described
// in the X509 section and we'll assume that it exists a file ca.pem that
// contain a single PEM CA certificate. We also assume that we have two
// files containing DER encoded PKCS#12 (cert1.p12, cert2.p12) of user
// certificates issued by our CA :
// \code
// cas :: Openssl/load_X509_pem("ca.pem") // the list of CA
//
// load_p12(filename:string, pass:string) : tuple(Openssl/X509, Openssl/key) ->
// 	let f := fopen(filename,"r"),
// 		p12 := fread(f),
// 	in (fclose(f),
// 		Openssl/d2i_PKCS12(p12, pass))
//
// // load (cert, private key) pairs
// signer :: load_p12("cert1.p12", "cert1_password")
// recipient :: load_p12("cert2.p12", "cert2_password")
// \/code
// We should verify certificates validity :
// \code
// (assert(Openssl/verify(signer[1], cas, nil) &
// 		Openssl/verify(recipient[1], cas, nil)))
// \/code
// We now create a message signed by our signer and encrytped for our recipient :
// \code
// p7 :: Openssl/sign&encrypt(signer[1], signer[2], nil,
// 			list(recipient[1]),
// 			blob!("some message"))
// \/code
// This PKCS#7 can now be decrypted by our recipient :
// \code
// b :: blob!()
// (if Openssl/decrypt&verify(p7, recipient[1], recipient[2], cas, nil, b)
// 	printf("PKCS#7 decrypted and verifyed\n")
// else error("Couldn't verify PKCS#7 : ~A", p7.Openssl/verify_message))
//
// (assert(fread(b) = "some message"))
// \/code
// @cat


// *********************************************************************
// *   Part 1: model                                                   *
// *********************************************************************


BIO* <: import()
(c_interface(BIO*,"BIO*"))
PKCS7* <: import()
(c_interface(PKCS7*,"PKCS7*"))


PKCS7 <: freeable_object(pkcs7*:PKCS7*,
						p7bio:BIO*,
						verify_message:string,
						valid?:boolean = false)

[free!(self:PKCS7) : void ->
	externC("PKCS7_free(self->pkcs7_star)"),
	externC("if (self->p7bio) BIO_free(self->p7bio)")]

// *********************************************************************
// *   Part 2: PKCS#7 DER encoding                                     *
// *********************************************************************

// @cat PKCS#7
// i2d(self) generates a DER encoded version of the given PKCS#7.
[i2d(self:PKCS7) : string ->
	externC("ClEnv->bufferStart()"),
	externC("ClEnv->pushAttempt(20000)"),
	externC("unsigned char* buf = (unsigned char*)ClEnv->buffer"),
	let len := externC("i2d_PKCS7(self->pkcs7_star, &buf)", integer)
	in copy(externC("ClEnv->buffer", string), len)]


// @cat PKCS#7
// d2i_PKCS7(self) returns a DER decoded PKCS#7.
[d2i_PKCS7(self:string) : PKCS7 ->
	let p7* := externC("PKCS7_new()", PKCS7*),
		p7 := PKCS7(pkcs7* = p7*),
		len := length(self)
	in (externC("p7->p7bio = NULL"),
		if (externC("d2i_PKCS7(&p7_star, (const unsigned char**)&self, len)", integer) = 0)
			openssl_error!(),
		p7)]

// *********************************************************************
// *   Part 3: PKCS#7 PEM encoding                                     *
// *********************************************************************


// @cat PKCS#7
// PKCS72pem(self) generates a PEM encoded version of the given PKCS#7.
[PKCS72pem(self:PKCS7) : string ->
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	externC("PEM_write_bio_PKCS7(bp, self->pkcs7_star)"),
	let len := externC("BIO_ctrl_pending(bp)", integer)
	in (externC("ClEnv->bufferStart();ClEnv->pushAttempt(len)"),
		externC("len = BIO_read(bp, ClEnv->buffer, len)"),
		externC("BIO_free(bp)"),
		copy(externC("ClEnv->buffer", string), len))]

// @cat PKCS#7
// pem2PKCS7(pem) returns a PEM decoded PKCS#7.
[pem2PKCS7(pem:string) : PKCS7 ->
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	let len := length(pem),
		x := new(PKCS7)
	in (externC("x->p7bio = NULL"),
		externC("BIO_write(bp, pem, len)"),	
		externC("PEM_read_bio_PKCS7(bp, &x->pkcs7_star, NULL,NULL)"),
		externC("BIO_free(bp)"),
		x)]

// *********************************************************************
// *   Part 3: creating PKCS#7                                         *
// *********************************************************************

[PKCS7!(x509:X509, k:key) : PKCS7 ->
	externC("PKCS7 *p7 = PKCS7_new()"),
	externC("PKCS7_set_type(p7,NID_pkcs7_signed)"),
	externC("PKCS7_SIGNER_INFO *si = PKCS7_add_signature(p7, x509->x509_star, k->evp_key, EVP_sha1())"),
	/* If you do this then you get signing time automatically added */
	externC("PKCS7_add_signed_attribute(si, NID_pkcs9_contentType, V_ASN1_OBJECT, OBJ_nid2obj(NID_pkcs7_data))"),
	/* we may want to add more certs */
	externC("PKCS7_add_certificate(p7, x509->x509_star)"),
	/* Set the content of the signed to 'data' */
	externC("PKCS7_content_new(p7, NID_pkcs7_data)"),
	PKCS7(pkcs7* = externC("p7", PKCS7*), p7bio = externC("NULL", BIO*))]

[add_certificate(self:PKCS7, cert:X509) : void ->
	if (externC("PKCS7_add_certificate(self->pkcs7_star, cert->x509_star)", integer) = 0)
		openssl_error!()]

[add_recipient(self:PKCS7, cert:X509) : void ->
	if (externC("PKCS7_add_recipient(self->pkcs7_star, cert->x509_star)", integer) = 0)
		openssl_error!()]


[set_detached(self:PKCS7, detached?:boolean) : void ->
	externC("PKCS7_set_detached(self->pkcs7_star, (detached_ask == CTRUE))")]

[detached?(self:PKCS7) : boolean ->
	externC("(PKCS7_is_detached(self->pkcs7_star) ? CTRUE : CFALSE)", boolean)]

[encrypted?(self:PKCS7) : boolean ->
	externC("(PKCS7_type_is_encrypted(self->pkcs7_star) ? CTRUE : CFALSE)", boolean)]

[enveloped?(self:PKCS7) : boolean ->
	externC("(PKCS7_type_is_enveloped(self->pkcs7_star) ? CTRUE : CFALSE)", boolean)]


/* <sb> obsolete -> use sign THEN encrypt...
[signed_and_enveloped?(self:PKCS7) : boolean ->
	externC("(PKCS7_type_is_signedAndEnveloped(self->pkcs7_star) ? CTRUE : CFALSE)", boolean)]
*/

[sign_init(self:PKCS7) : void ->
	externC("if (self->p7bio) BIO_free(self->p7bio)"),
	self.p7bio := externC("PKCS7_dataInit(self->pkcs7_star, NULL)", BIO*),
	if externC("(self->p7bio == NULL ? CTRUE : CFALSE)", boolean)
		openssl_error!()]

[sign_update(self:PKCS7, msg:string) : void ->
	let len := length(msg)
	in (externC("BIO_write(self->p7bio,(unsigned char*)msg,len)"))]

[sign_final(self:PKCS7) : void ->
	externC("BIO_flush(self->p7bio)"),
	if (externC("PKCS7_dataFinal(self->pkcs7_star, self->p7bio)", integer) = 0)
		openssl_error!()]

[sign(self:PKCS7, msg:string) : void ->
	sign_init(self),
	sign_update(self, msg),
	sign_final(self)]


[verify(self:PKCS7, digest:string) : boolean ->
	let valid? := true,
		p7 := self.pkcs7*
	in (externC("BIO *indata = BIO_new(BIO_s_mem())"),
		externC("BIO_write(indata, (unsigned char*)digest, length_string(digest))"),
		externC("valid_ask = PKCS7_verify(p7, NULL, NULL, indata, NULL, PKCS7_NOVERIFY) == 1 ? CTRUE : CFALSE"),
		externC("BIO_free(indata)"),
		valid?)]


// @doc PKCS#7
// sign(signer, pkey, chain, data) generates a PKCS#7 object with a signed content made
// of what can be read on data. chain may contain a list of certificates that are needed
// for chain validation.
[sign(signer:X509, pkey:key, chain:list[X509], data:port) : PKCS7 ->
	externC("BIO *indata = BIO_new(BIO_s_mem())"),
	externC("unsigned char buf[512]"),
	while not(eof?(data))
		let len := read_port(data, externC("buf", char*), 512)
		in externC("BIO_write(indata, (unsigned char*)buf, len)"),
	externC("STACK_OF(X509)* stx509 = sk_X509_new_null()"),
	for co in chain
		let c := co as X509
		in externC("sk_X509_push(stx509, c->x509_star)"),
	externC("PKCS7 *p7 =  PKCS7_sign(signer->x509_star, pkey->evp_key, stx509, indata, 0)"),
	externC("BIO_free(indata)"),
	if externC("(p7 == NULL ? CTRUE : CFALSE)", boolean)
		openssl_error!(),
	PKCS7(pkcs7* = externC("p7", PKCS7*), p7bio = externC("NULL", BIO*))]


// @doc PKCS#7
// verify(self, trusted, untrusted, p) verifies the signature of a PKCS#7 object with a
// signed content. trusted contains a list of certificates that are trusted by the user
// of the method and untrusted a list of certificate needed for the whole chain validation.
// On return, p contains the data that have been signed. The return value is either true
// if the signer certificate could be verified or false otherwise. In the later case
// self.verify_message contain the reason why the verification failed.
[verify(self:PKCS7, trusted:list[X509], untrusted:list[X509], p:port) : boolean ->
	externC("X509_STORE *store"),
	externC("store = X509_STORE_new()"),
	externC("X509_STORE_set_verify_cb_func(store, (int (*)(int, X509_STORE_CTX *))Openssl_verify_cb_integer1)"),
	externC("X509_STORE_set_default_paths(store)"),
	for co in trusted
		let c := co as X509
		in externC("X509_STORE_add_cert(store, c->x509_star)"),
	externC("STACK_OF(X509)* stx509 = sk_X509_new_null()"),
	for co in untrusted
		let c := co as X509
		in externC("sk_X509_push(stx509, c->x509_star)"),
	externC("BIO *outdata = BIO_new(BIO_s_mem())"),
	if (externC("PKCS7_verify(self->pkcs7_star, stx509, store, NULL, outdata, 0)", integer) <= 0)
		(self.verify_message := last_error_string,
		self.valid? := false,
		externC("BIO_free(outdata)"),
		false)
	else
		(self.verify_message := "signature verified",
		self.valid? := true,
		let len := 0
		in (externC("char buf[512];
				while(1) {
					len = BIO_read(outdata, buf, 512);
					if (len <= 0) break;"),
					write_port(p, externC("buf", char*), len),
			externC("}"),
			externC("BIO_free(outdata)"),
			true))]

// @doc PKCS#7
// encrypt(recipients, indata) creates a PKCS#7 with an encrypted content for the
// given recipients public certificates. The content is made of what can be read
// on indata.
[encrypt(recipients:list[X509], indata:port) : PKCS7 ->
	externC("STACK_OF(X509)* stx509 = sk_X509_new_null()"),
	for co in recipients
		let c := co as X509
		in externC("sk_X509_push(stx509, c->x509_star)"),
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	externC("char buf[512]"),
	while not(eof?(indata))
		let len := read_port(indata, externC("buf", char*), 512)
		in externC("BIO_write(bp, buf, len)"),
	externC("PKCS7* p7 = PKCS7_encrypt(stx509, bp, EVP_des_ede3_cbc(), PKCS7_BINARY)"),
	externC("BIO_free(bp)"),
	if externC("(p7 == NULL ? CTRUE : CFALSE)", boolean)
		openssl_error!(),
	PKCS7(pkcs7* = externC("p7", PKCS7*), p7bio = externC("NULL", BIO*))]


// @doc PKCS#7
// decrypt(p7, recipient, pkey) extract the encrypted content of the given PKCS#7
// for the specified recipient public cetificate and associated private key pkey.
[decrypt(p7:PKCS7, recipient:X509, pkey:key) : blob ->
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	if (externC("PKCS7_decrypt(p7->pkcs7_star, pkey->evp_key, recipient->x509_star, bp, 0)", integer) <= 0)
		(externC("BIO_free(bp)"),
		openssl_error!()),
	let len := 0,
		b := blob!()
	in (externC("char buf[512];
				while(1) {
					len = BIO_read(bp, buf, 512);
					if (len <= 0) break;"),
					write_port(b, externC("buf", char*), len),
			externC("}"),
		externC("BIO_free(bp)"),
		b)]


// @doc PKCS#7
// sign&encrypt(signer, pkey, chain, recipients, data) generate a signed and encryted PKCS#7 as used
// by the smime proptocol. The purpose of this method is to generate an encrypted content which has
// an identified issuer and that can be read by only a set of recipients. The content is made of the
// data that can be read on the port data. chain represents a list of intermediate (CA) certificates
// used for verification at the time it is decrypted.
[sign&encrypt(signer:X509, pkey:key, chain:list[X509], recipients:list[X509], data:port) : PKCS7 ->
	let p7 := sign(signer, pkey, chain, data)
	in encrypt(recipients, blob!(i2d(p7)))]

//<sb> @doc PKCS#7
// decrypt&verify(p7, recipient, pkey, trusted, untrusted, out) fills the port out with the content of
// a signed and encrypted PKCS#7. This operation is performed for the given recipient that should be part
// of the recipients of the PKCS#7. In order to verify the the signer of the supplied PKCS#7 one should
// specify certificates of trusted CAs, and optionaly a list of untrusted certificates. The returned value
// is true is the verification process succeded, otherwise false is returned and p7.verify_message can be used
// to get the information why the verification failed.
[decrypt&verify(p7:PKCS7, recipient:X509, pkey:key, trusted:list[X509], untrusted:list[X509], out:port) : boolean ->
	let dec_p7 := d2i_PKCS7(string!(decrypt(p7, recipient, pkey)))
	in verify(dec_p7, trusted, untrusted, out)]

// @doc PKCS#7
// get_signers(self) extracts the list of signer certificates from the given PKCS#7.
[get_signers(self:PKCS7) : list[X509] ->
	externC("STACK_OF(X509)* stx509 = PKCS7_get0_signers(self->pkcs7_star, NULL, 0)"),
	if externC("(stx509 == NULL ? CTRUE : CFALSE)", boolean) nil
	else let l := list<X509>()
		in (externC("
			int i;
			for(i = 0; i < sk_X509_num(stx509);i++) {"),
				l add X509(x509* = externC("sk_X509_value(stx509,i)",X509*)),
			externC("}"), l)]


//<sb> @doc PKCS#7
// finds among possibles for a list of matching certificate that are
// recipient of the given (enveloped) PKCS#7
// get_recipients(self, possibles) return a sublist of the supplied list
// of possible recipients of the given PKCS#7.
[get_recipients(self:PKCS7, possibles:list[X509]) : list[X509] ->
	if externC("(self->pkcs7_star == NULL ? CTRUE : CFALSE)", boolean) nil
	else if not(enveloped?(self))
		(error("get_recipients: invalid PKCS7 content type, enveloped expected"),
		nil)
	else
		(externC("STACK_OF(PKCS7_RECIP_INFO) *ris = self->pkcs7_star->d.enveloped->recipientinfo"),
		if externC("(ris == NULL ? CTRUE : CFALSE)", boolean) nil
		else let l := list<X509>()
			in (externC("
				int i;
				for(i = 0; i < sk_PKCS7_RECIP_INFO_num(ris);i++) {"),
					externC("PKCS7_RECIP_INFO* pi = sk_PKCS7_RECIP_INFO_value(ris,i)"),
					externC("X509_NAME* xn1 = pi->issuer_and_serial->issuer"),
					externC("ASN1_INTEGER *ser1 = pi->issuer_and_serial->serial"),
					for x in possibles
						let cert := x
						in (externC("X509_NAME* xn2 = X509_get_issuer_name(cert->x509_star)"),
							externC("ASN1_INTEGER *ser2 = X509_get_serialNumber(cert->x509_star)"),
							externC("int ok = X509_name_cmp(xn1,xn2) == 0 &&
												ASN1_INTEGER_cmp(ser1,ser2) == 0"),
 							if externC("(ok ? CTRUE : CFALSE)", boolean)
								l add cert),
				externC("}"), l))]


