
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * pkcs8.cl                                                          *
// * Copyright (C) 2004-2005 xl. All Rights Reserved                   *
// *********************************************************************


// *********************************************************************
// *   Part 1: PKCS#8 DER encoding                                     *
// *********************************************************************

// @cat PKCS#8
// This standard specifies a syntax for encrypted private keys.
// @cat

// @doc PKCS#8
// i2d(self, pass) is equivalent to i2d(self, "des-cbc", pass).
[i2d(self:key, pass:string) : string -> i2d(self, "des-cbc", pass)]


// @doc PKCS#8
// i2d(self, algo, pass) creates a password protected PKCS#8 DER encoded version
// of the given private key. algo specifies the algorithm used for the key
// encrytption.
[i2d(self:key, algo:CYPHERS, pass:string) : string ->
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	if (externC("i2d_PKCS8PrivateKey_bio(bp, self->evp_key, EVP_get_cipherbyname(algo), NULL, 0, NULL, pass)", integer) = 0)
		openssl_error!(),
	let len := externC("BIO_ctrl_pending(bp)", integer)
	in (externC("ClEnv->bufferStart()"),
		externC("ClEnv->pushAttempt(len)"),
		externC("unsigned char* buf = (unsigned char*)ClEnv->buffer"),
		externC("len = BIO_read(bp, buf, len)"),
		externC("BIO_free(bp)"),
		copy(externC("ClEnv->buffer", string), len))]


// @doc PKCS#8
// d2i_PKCS8(self, pass) decoded an encrypted DER encoded PKCS#8 with the given password.
[d2i_PKCS8(self:string, pass:string) : key ->
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	externC("BIO_write(bp, self, LENGTH_STRING(self))"),
	externC("EVP_PKEY* pkey = d2i_PKCS8PrivateKey_bio(bp, NULL, NULL, pass)"),
	if externC("(pkey == NULL ? CTRUE : CFALSE)", boolean)
		openssl_error!(),
	key(evp_key = externC("pkey", EVP_PKEY*))]
	




