
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * pkcs12.cl                                                         *
// * Copyright (C) 2004-2005 xl. All Rights Reserved                   *
// *********************************************************************


// *********************************************************************
// *   Part 1: PKCS#12 DER encoding                                    *
// *********************************************************************

// @cat PKCS#12
// This standard specifies a portable format for storing or transporting
// a user's private key and certificate. 
// @cat


//<sb> @doc PKCS#12
// i2d(self, pkey, name, pass) generate a DER encoded PKCS#12. PKCS#12 are
// used to store an X509 public certificate and its associated private key.
// The generated PKCS12 is encrypted with the given password pass.
[i2d(self:X509, pkey:key, name:string, pass:string) : string ->
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	externC("PKCS12 *p12 = PKCS12_create(pass, name, pkey->evp_key, self->x509_star, NULL, 0, 0, 0, 0, 0)"),
	if (externC("i2d_PKCS12_bio(bp, p12)", integer) = 0)
		openssl_error!(),
	let len := externC("BIO_ctrl_pending(bp)", integer)
	in (externC("ClEnv->bufferStart()"),
		externC("ClEnv->pushAttempt(len)"),
		externC("unsigned char* buf = (unsigned char*)ClEnv->buffer"),
		externC("len = BIO_read(bp, buf, len)"),
		externC("BIO_free(bp)"),
		copy(externC("ClEnv->buffer", string), len))]


//<sb> @doc PKCS#12
// d2i_PKCS12(self, pass) decode a PKCS#12 that have been encrypted with
// a password. The returnes value is a tuple containing an X509 public certificate
// and its associated private key.
[d2i_PKCS12(self:string, pass:string) : tuple(X509, key) ->
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	externC("BIO_write(bp, self, LENGTH_STRING(self))"),
	externC("PKCS12 *p12 = d2i_PKCS12_bio(bp, NULL)"),
	if externC("(p12 == NULL ? CTRUE : CFALSE)", boolean)
		openssl_error!(),
	externC("X509* x509 = X509_new()"),
	if externC("(x509 == NULL ? CTRUE : CFALSE)", boolean)
		openssl_error!(),
	externC("EVP_PKEY* pkey = EVP_PKEY_new()"),
	if externC("(pkey == NULL ? CTRUE : CFALSE)", boolean)
		openssl_error!(),
	if externC("(PKCS12_parse(p12, pass, &pkey, &x509, NULL) == 0 ? CTRUE : CFALSE)", boolean)
		openssl_error!(),
	tuple(X509(x509* = externC("x509", X509*)),
		key(evp_key = externC("pkey", EVP_PKEY*)))]
	




