
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * key.cl                                                            *
// * Copyright (C) 2004-2005 xl. All Rights Reserved                   *
// *********************************************************************

// *********************************************************************
// *   Part 1: DSA key                                                 *
// *   Part 2: RSA key                                                 *
// *   Part 3: EVP key                                                 *
// *   Part 4: key PEM encoding                                        *
// *   Part 5: key DER encoding                                        *
// *   Part 6: message digest                                          *
// *   Part 7: signing                                                 *
// *   Part 8: verfying                                                *
// *   Part 9: encrypt                                                 *
// *   Part 10: decrypt                                                *
// *   Part 11: RSA public/private encryption                          *
// *********************************************************************

// *********************************************************************
// *   Part 1: DSA key                                                 *
// *********************************************************************

// @cat Key pair
// This section describes methods that are used to create key pairs.
// A key pair is made of a public key known to everyone and a private or
// secret key known only to the recipient of a message. When someone wants
// to send a secure message to someone else, he uses recipient's public
// key to encrypt the message. The recipient then uses its private key to
// decrypt the message.\br
// An important element to the public key system is that the public and
// private keys are related in such a way that only the public key can be
// used to encrypt messages and only the corresponding private key can be
// used to decrypt them. Moreover, it is virtually impossible to deduce
// the private key if you know the public key.\br
// The Openssl CLAIRE module supports two kinds of key pairs :
// \ul
// \li RSA : Rivest-Shamir-Adleman, the name of its inventors
// \li DSA : Digital Signature Standard
// \/ul
// Such key pairs are the base of a Public Key Infrastructure : PKI.
// @cat


DSA* <: import()
(c_interface(DSA*,"DSA*"))

DSA <: freeable_object(dsa*:DSA*)

[free!(self:DSA) : void -> externC("DSA_free(self->dsa_star)")]

[DSA!(self:DSA*) : DSA => DSA(dsa* = self)]

[dsa_generate_key(self:DSA*) : DSA* ->
	if (externC("DSA_generate_key(self)", integer) != 1)
		openssl_error!(),
	self]

[dsa_generate_parameters(nbits:(1 .. 1024)) : DSA* ->
	externC("DSA_generate_parameters(nbits,NULL,0,NULL,NULL,NULL,NULL)",DSA*)]

[dsa_generate_key(nbits:(1 .. 1024)) : DSA ->
	DSA!(dsa_generate_key(dsa_generate_parameters(nbits)))]


[dsa_size(self:DSA) : integer -> externC("DSA_size(self->dsa_star)",integer)]


// *********************************************************************
// *   Part 2: RSA key                                                 *
// *********************************************************************

RSA* <: import()
(c_interface(RSA*,"RSA*"))

RSA <: freeable_object(rsa*:RSA*)

[free!(self:RSA) : void -> externC("RSA_free(self->rsa_star)")]

[RSA!(self:RSA*) : RSA => RSA(rsa* = self)]



[rsa_generate_key(nbits:integer) : RSA ->
	RSA!(externC("RSA_generate_key(nbits,RSA_F4,NULL,NULL)", RSA*))]


[rsa_size(self:RSA) : integer -> externC("RSA_size(self->rsa_star)",integer)]

[rsa_check_key?(self:RSA) : boolean -> externC("RSA_check_key(self->rsa_star)",integer) = 1]

// *********************************************************************
// *   Part 3: EVP key                                                 *
// *********************************************************************

EVP_PKEY* <: import()
(c_interface(EVP_PKEY*, "EVP_PKEY*"))


key <: freeable_object(evp_key:EVP_PKEY*, src_rsa:RSA, src_dsa:DSA)

[key!() : key -> key(evp_key = externC("EVP_PKEY_new()", EVP_PKEY*))]


[key!(rsa:RSA) : key ->
	let k := key!()
	in (k.src_rsa := rsa,
		if (externC("EVP_PKEY_assign_RSA(k->evp_key, rsa->rsa_star)", integer) = 0)
			openssl_error!(),
		k)]


[key!(dsa:DSA) : key ->
	let k := key!()
	in (k.src_dsa := dsa,
		if (externC("EVP_PKEY_assign_DSA(k->evp_key, dsa->dsa_star)", integer) = 0)
			openssl_error!(),
		k)]

// @doc Key pair
// rsa!(nbits) generates an RSA key pair (private and public keys) of the given size
// nbits. nbits should be a 2 exponent.
[rsa!(nbits:integer) : key -> key!(rsa_generate_key(nbits))]

// @doc Key pair
// rsa!(nbits) generates an DSA key pair (private and public keys) of the given size
// nbits. nbits should be a 2 exponent.
[dsa!(nbits:(1 .. 1024)) : key -> key!(dsa_generate_key(nbits))]

// @doc Key pair
// key_size(self:key) returns the size of the given key.
[key_size(self:key) : integer -> externC("EVP_PKEY_size(self->evp_key)", integer)]
[key_bits(self:key) : integer -> externC("EVP_PKEY_bits(self->evp_key)", integer)]

// @doc Key pair
// key_type(self:key) returns the type of the given key which either "RSA", "DSA" or "DH",
// otherwise "<UNKNOWN KEY TYPE>" is returned.
[key_type(self:key) : string ->
	externC("int t = self->evp_key ? EVP_PKEY_base_id(self->evp_key) : 0"),
	if externC("(t == EVP_PKEY_RSA ? CTRUE : CFALSE)", boolean)
		"RSA"
	else if externC("(t == EVP_PKEY_DSA ? CTRUE : CFALSE)", boolean)
		"DSA"
	else if externC("(t == EVP_PKEY_DH ? CTRUE : CFALSE)", boolean)
		"DH"
	else "<UNKNOWN KEY TYPE>"]

self_print(self:key) : void ->
	printf("<~A key ~Sbits>", key_type(self), key_bits(self))


// *********************************************************************
// *   Part 4: key PEM encoding                                        *
// *********************************************************************


// @doc Key pair
// private2pem(self, algo, pass) returns a string containing a PEM password
// encoded version of the private key of the given key pair.
[private2pem(self:key, algo:CYPHERS, pass:string) : string ->
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	if (externC("(PEM_write_bio_PrivateKey(bp, self->evp_key, EVP_get_cipherbyname(algo),NULL,0,0,pass) == 0)", integer) = 1)
		openssl_error!(),
	let len := externC("BIO_ctrl_pending(bp)", integer)
	in (externC("ClEnv->bufferStart()"),
		externC("ClEnv->pushAttempt(len)"),
		externC("len = BIO_read(bp, ClEnv->buffer, len)"),
		externC("BIO_free(bp)"),
		copy(externC("ClEnv->buffer", string), len))]

// @doc Key pair
// private2pem(self, algo, pass) returns a string containing a PEM
// encoded version of the private key of the given key pair.
[private2pem(self:key) : string ->
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	if (externC("(PEM_write_bio_PrivateKey(bp, self->evp_key, NULL,NULL,0,0,NULL) == 0)", integer) = 1)
		openssl_error!(),
	let len := externC("BIO_ctrl_pending(bp)", integer)
	in (externC("ClEnv->bufferStart()"),
		externC("ClEnv->pushAttempt(len)"),
		externC("len = BIO_read(bp, ClEnv->buffer, len)"),
		externC("BIO_free(bp)"),
		copy(externC("ClEnv->buffer", string), len))]

// @doc Key pair
// pem2private(pem) decodes a PEM encoded private key.
[pem2private(pem:string) : key -> pem2private(pem,"")]

// @doc Key pair
// pem2private(pem) decodes a PEM pasword encoded private key.
[pem2private(pem:string,pass:string) : key ->
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	let len := length(pem),
		plen := length(pass),
		k := key!()
	in (externC("BIO_write(bp, pem, len)"),	
		if (externC("(PEM_read_bio_PrivateKey(bp, &k->evp_key, NULL,plen?(void*)pass:NULL) == 0)", integer) = 1)
			openssl_error!(),
		externC("BIO_free(bp)"),
		k)]

// @doc Key pair
// public2pem(self) returns a string containing a PEM
// encoded version of the public key of the given key pair.
[public2pem(self:key) : string ->
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	externC("PEM_write_bio_PUBKEY(bp, self->evp_key)"),
	let len := externC("BIO_ctrl_pending(bp)", integer)
	in (externC("ClEnv->bufferStart()"),
		externC("ClEnv->pushAttempt(len)"),
		externC("len = BIO_read(bp, ClEnv->buffer, len)"),
		externC("BIO_free(bp)"),
		copy(externC("ClEnv->buffer", string), len))]

// @doc Key pair
// pem2public(pem) decodes a PEM encoded public key.
[pem2public(pem:string) : key ->
	externC("BIO* bp = BIO_new(BIO_s_mem())"),
	let len := length(pem),
		k := key!()
	in (externC("BIO_write(bp, pem, len)"),	
		externC("PEM_read_bio_PUBKEY(bp, &k->evp_key, NULL,NULL)"),
		externC("BIO_free(bp)"),
		k)]

// *********************************************************************
// *   Part 5: key DER encoding                                        *
// *********************************************************************

// @doc Key pair
// i2d_public(self) returns a string containing a DER
// encoded version of the public key of the given key pair.
[i2d_public(self:key) : string ->
	externC("ClEnv->bufferStart()"),
	externC("ClEnv->pushAttempt(4096)"),
	externC("unsigned char* buf = (unsigned char*)ClEnv->buffer"),
	let len := externC("i2d_PublicKey(self->evp_key, &buf)", integer)
	in (if (len = 0) openssl_error!(),
		copy(externC("ClEnv->buffer", string), len))]


// @doc Key pair
// i2d_private(self) returns a string containing a DER
// encoded version of the private key of the given key pair.
[i2d_private(self:key) : string ->
	externC("ClEnv->bufferStart()"),
	externC("ClEnv->pushAttempt(4096)"),
	externC("unsigned char* buf = (unsigned char*)ClEnv->buffer"),
	let len := externC("i2d_PrivateKey(self->evp_key, &buf)", integer)
	in (if (len = 0) openssl_error!(),
		copy(externC("ClEnv->buffer", string), len))]


// @doc Key pair
// d2i_public(self) decodes a DER encoded public key.
[d2i_public(self:string) : key ->
	let buf := self,
		len := length(self),
		x := key()
	in (if (externC("((x->evp_key = d2i_PublicKey(EVP_PKEY_RSA,NULL,(const unsigned char**)&buf,len)) == NULL)",integer) = 1)
			openssl_error!(),
		x)]

// @doc Key pair
// d2i_private(self) decodes a DER encoded private key.
[d2i_private(self:string) : key ->
	let buf := self,
		len := length(self),
		x := key()
	in (if (externC("((x->evp_key = d2i_PrivateKey(EVP_PKEY_RSA,NULL,(const unsigned char**)&buf,len)) == NULL)",integer) = 1)
			openssl_error!(),
		x)]


// *********************************************************************
// *   Part 6: message digest                                          *
// *********************************************************************

// @cat Message digest, signing, verifying
// A message digest is a representation of a text in the form of a single
// string of digits, created using a formula called a one-way hash function.
// Encrypting a message digest with a private key creates a digital signature,
// which is an electronic means of authentication.
// @cat

EVP_MD_CTX* <: import()
EVP_MD* <: import()

(c_interface(EVP_MD_CTX*, "EVP_MD_CTX*"))
(c_interface(EVP_MD*, "EVP_MD*"))


(#if compiler.loading? externC("OpenSSL_add_all_digests()"))


digest_context <: freeable_object(
		context:EVP_MD_CTX*,
		hashalgo:EVP_MD*)




// @doc Message digest, signing, verifying
// digest_context!(algo) returns a digest context for the given digest algorithm.
[digest_context!(algo:DIGEST_ALGORYTHMS) : digest_context ->
	let md := (if (algo = "null") externC("(EVP_MD*)EVP_md_null()", EVP_MD*)
				else externC("(EVP_MD*)EVP_get_digestbyname(algo)", EVP_MD*))
	in (if (externC("md", integer) = 0) error("hash function unvailable for ~A algo", algo),
		let ctx := externC("EVP_MD_CTX_create()", EVP_MD_CTX*)
		in (if (externC("ctx",integer) = 0) error("not enought memory for digest_context allocation"),
			digest_context(context = ctx, hashalgo = md)))]


free!(self:digest_context) : void ->
	externC("EVP_MD_CTX_destroy(self->context)")


// @doc Message digest, signing, verifying
// digest_init(self) initialise a digest context.
[digest_init(self:digest_context) : void ->
	if (externC("EVP_DigestInit(self->context, self->hashalgo)",integer) = 0)
		openssl_error!()]
	
// @doc Message digest, signing, verifying
// digest_update(self, msg) update the internal state of the digest context with
// the addition of the given message msg.
[digest_update(self:digest_context, msg:string) : void ->
	let len := length(msg)
	in (if (externC("EVP_DigestUpdate(self->context, (unsigned char*)msg, len)", integer) = 0)
		openssl_error!())]

// @doc Message digest, signing, verifying
// digest_final(self) finilize the internal state of the digest context and return
// the digest value.
[digest_final(self:digest_context) : string ->
	externC("ClEnv->bufferStart()"),
	externC("ClEnv->pushAttempt(EVP_MD_size(self->hashalgo))"),
	if (externC("EVP_DigestFinal(self->context, (unsigned char*)ClEnv->buffer, NULL)", integer) = 0)
		openssl_error!(),
	copy(externC("ClEnv->buffer", string),
		externC("EVP_MD_size(self->hashalgo)", integer))]


// @doc Message digest, signing, verifying
// Calculates a digest value for a given message msg. It is equivalent to :
// \code
// let ctx := Openssl/digest_context!(algo)
// in (Openssl/digest_init(ctx),
// 	Openssl/digest_update(ctx, msg),
// 	Openssl/digest_final(ctx))
// \/code
[digest(algo:DIGEST_ALGORYTHMS, msg:string) : string ->
	let ctx := digest_context!(algo)
	in (digest_init(ctx),
		digest_update(ctx, msg),
		digest_final(ctx))]


digest_filter <: filter(context:digest_context, digest:string)

// @doc Message digest, signing, verifying
// digest_filter!(self, algo) creates filter that internaly manage a digest context.
// Everything written through this filter is used to update the internal state of the
// digest. Once the returned filter is closed one can find the digest value in the
// digest field of the filter :
// \code
// let b := blob!(),
// 	digester := Openssl/digest_filter!(b, "sha")
// in (fwrite(digester, "some messages"),
// 		fclose(digester),
// 		let digest := digester.Openssl/digest
// 		in (...))
// \/code
digest_filter!(self:port, algo:DIGEST_ALGORYTHMS) : digest_filter ->
	let p := filter!(digest_filter(context = digest_context!(algo)), self)
	in (digest_init(p.context),
		p)

write_port(self:digest_filter, buf:char*, len:integer) : integer ->
	(if (externC("EVP_DigestUpdate(self->context->context, (unsigned char*)buf, len)", integer) = 0)
		openssl_error!(),
	write_port(self.target, buf, len))

close_port(self:digest_filter) : void ->
	(self.digest := digest_final(self.context))


// *********************************************************************
// *   Part 7: signing                                                 *
// *********************************************************************


// @doc Message digest, signing, verifying
// sign_init(self) initialise a digest context for digital signature purpose.
[sign_init(self:digest_context) : void ->
	externC("EVP_SignInit(self->context, self->hashalgo)")]

// @doc Message digest, signing, verifying
// sign_update(self, msg) update the internal state of the digest context initialized
// with sign_init with the addition of the given message msg.
[sign_update(self:digest_context, msg:string) : void ->
	let len := length(msg)
	in (if (externC("EVP_SignUpdate(self->context, msg, len)", integer) = 0)
			openssl_error!())]

// @doc Message digest, signing, verifying
// sign_final(self, k) finilize the internal state of the digest context initialized
// with sign_init and return the signature value which is encoded with the given private
// key k.
[sign_final(self:digest_context, k:key) : string ->
	let len := 0
	in (externC("ClEnv->bufferStart()"),
		externC("ClEnv->pushAttempt(EVP_PKEY_size(k->evp_key))"),
		if (externC("EVP_SignFinal(self->context, (unsigned char*)ClEnv->buffer, (unsigned int*)&len , k->evp_key)", integer) = 0)
			openssl_error!(),
		copy(externC("ClEnv->buffer", string), len))]


// @doc Message digest, signing, verifying
// Calculates a signature value for a given message msg. It is equivalent to :
// \code
// let ctx := Openssl/digest_context!(algo)
// in (Openssl/sign_init(ctx),
// 	Openssl/sign_update(ctx, msg),
// 	Openssl/sign_final(ctx, k))
// \/code
[sign(self:DIGEST_ALGORYTHMS, msg:string, k:key) : string ->
	let ctx := digest_context!(self)
	in (sign_init(ctx),
		sign_update(ctx, msg),
		sign_final(ctx, k))]


sign_filter <: filter(context:digest_context)

// @doc Message digest, signing, verifying
// sign_filter!(self, algo) creates filter that internaly manage a digest context intended
// for digital signature.
// Everything written through this filter is used to update the internal state of the
// digest. Once the returned filter is closed one can obtained a digital signature of the content
// with sign_final :
// \code
// let b := blob!(),
// 	signer := Openssl/sign_filter!(b, "sha")
// in (fwrite(signer, "some messages"),
// 		fclose(signer),
// 		let digest := sign_final(signer, k)
// 		in (...))
// \/code
// where k is a private key used to sign the digest value.
sign_filter!(self:port, algo:DIGEST_ALGORYTHMS) : sign_filter ->
	let p := filter!(sign_filter(context = digest_context!(algo)), self)
	in (sign_init(p.context),
		p)

write_port(self:sign_filter, buf:char*, len:integer) : integer ->
	(if (externC("EVP_SignUpdate(self->context->context, (unsigned char*)buf, len)", integer) = 0)
		openssl_error!(),
	write_port(self.target, buf, len))


// @doc Message digest, signing, verifying
// sign_final(self, k) returns a digital signature of the data that have been written
// through the filter self, the signature is encrytpted with the given private key k.
// sign_final should be used once the filter has been closed.
[sign_final(self:sign_filter, k:key) : string -> sign_final(self.context, k)]


// *********************************************************************
// *   Part 8: verfying                                                *
// *********************************************************************


// @doc Message digest, signing, verifying
// verify_init(self) initialise a digest context for digital signature verification purpose.
[verify_init(self:digest_context) : void ->
	externC("EVP_VerifyInit(self->context, self->hashalgo)")]

// @doc Message digest, signing, verifying
// verify_update(self, msg) update the internal state of the digest context initialized
// with verify_init with the addition of the given message msg.
[verify_update(self:digest_context, msg:string) : void ->
	let len := length(msg)
	in externC("EVP_VerifyUpdate(self->context, (unsigned char*)msg, len)")]

// @doc Message digest, signing, verifying
// verify_final(self, digest, k) finilize the internal state of the digest context initialized
// with verify_init an return true if the given digital signature digest verifies the internal
// calculated signature for the given public key k.
[verify_final(self:digest_context, digest:string, k:key) : boolean ->
	let len := length(digest)
	in case externC("EVP_VerifyFinal(self->context, (unsigned char*)digest, len , k->evp_key)", integer)
		({-1} (openssl_error!(), true),
		{0} false,
		any true)]


// @doc Message digest, signing, verifying
// Calculates a signature value for a given message msg and verifies that it matches
// the given digital signature for the given public key k.
// \code
// let ctx := Openssl/digest_context!(algo)
// in (Openssl/verify_init(ctx),
// 	Openssl/verify_update(ctx, msg),
// 	Openssl/verify_final(ctx, signature, k))
// \/code
[verify(self:DIGEST_ALGORYTHMS, msg:string, signature:string, k:key) : boolean ->
	let ctx := digest_context!(self)
	in (verify_init(ctx),
		verify_update(ctx, msg),
		verify_final(ctx, signature, k))]


verify_filter <: filter(context:digest_context, update_context?:boolean = true)

// @doc Message digest, signing, verifying
// verify_filter!(self, algo) creates filter that internaly manage a digest context intended
// for digital signature verification.
// Everything written through this filter is used to update the internal state of the
// digest. Once the returned filter is closed one can verify that the digest value is
// a valid digital signature with verify_final :
// \code
// let b := blob!(),
// 	signer := Openssl/verify_filter!(b, "sha")
// in (fwrite(signer, "some messages"),
// 	fclose(signer),
// 	if not(verify_final(signer, sig, k))
// 		error("Invalid signature"),
// 	...)
// \/code
// where k is a public key used to verify that the digest value matches the supplied digital
// signature sig.
verify_filter!(self:port, algo:DIGEST_ALGORYTHMS) : verify_filter ->
	let p := filter!(verify_filter(context = digest_context!(algo)), self)
	in (verify_init(p.context),
		p)

read_port(self:verify_filter, buf:char*, len:integer) : integer ->
	let n := read_port(self.target, buf, len)
	in (if self.update_context?
			(if (externC("EVP_VerifyUpdate(self->context->context, (unsigned char*)buf, n)", integer) = 0)
				openssl_error!()),
		n)

// @doc Message digest, signing, verifying
// verify_final(self, digest, k) verifies for the public key k whether the supplied signature
// sig matches the internal value of the digest calculated with the data that were written through
// the filter self. verify_final should be used only once the filter has been closed.
[verify_final(self:verify_filter, digest:string, k:key) : boolean ->
	verify_final(self.context, digest, k)]


// *********************************************************************
// *   Part 9: encrypt                                                 *
// *********************************************************************

EVP_CYPHER* <: import()
EVP_CIPHER_CTX* <: import()

(c_interface(EVP_CYPHER*, "EVP_CYPHER*"))
(c_interface(EVP_CIPHER_CTX*, "EVP_CIPHER_CTX*"))


crypt_context <: freeable_object(context:EVP_CIPHER_CTX*)

free!(self:crypt_context) : void ->
	externC("delete self->context")

[crypt_context!() : crypt_context ->
	let c := externC("EVP_CIPHER_CTX_new()", EVP_CIPHER_CTX*)
	in (if (externC("c",integer) = 0) error("not enought memory for crypt_context allocation"),
		externC("EVP_CIPHER_CTX_init(c)"),
		crypt_context(context = c))]


[encrypt_init(self:crypt_context, algo:CYPHERS, k:string) : void -> encrypt_init(self, algo, k,"")]
[encrypt_init(self:crypt_context, algo:CYPHERS, k:string, iv:string) : void ->
	if (externC("EVP_EncryptInit(self->context, EVP_get_cipherbyname(algo), NULL,NULL)", integer) = 0)
		openssl_error!(),
	let len := length(k)
	in externC("EVP_CIPHER_CTX_set_key_length(self->context, len)"),
	if (externC("EVP_EncryptInit(self->context, NULL, (unsigned char*)k, *iv?(unsigned char*)iv:NULL)", integer) = 0)
		openssl_error!()]



[encrypt_update(self:crypt_context, msg:string) : string ->
	let len := length(msg), maxlen := 16 * len
	in (externC("ClEnv->bufferStart()"),
		externC("ClEnv->pushAttempt(maxlen)"),
		externC("unsigned char *buf = (unsigned char *)ClEnv->buffer"),
		if (externC("EVP_EncryptUpdate(self->context, buf, (int*) &maxlen, (unsigned char*)msg, (int)len)", integer) = 0)
			openssl_error!(),
		copy(externC("ClEnv->buffer",string), maxlen))]

[encrypt_final(self:crypt_context) : string ->
	let maxlen := 4096
	in (externC("ClEnv->bufferStart()"),
		externC("ClEnv->pushAttempt(maxlen)"),
		if (externC("EVP_EncryptFinal(self->context, (unsigned char*)ClEnv->buffer, (int*)&maxlen)", integer) = 0)
			openssl_error!(),
		copy(externC("ClEnv->buffer", string), maxlen))]


[encrypt(msg:string, algo:CYPHERS, k:string, iv:string) : string ->
	let ctx := crypt_context!()
	in (encrypt_init(ctx,algo,k,iv),
		encrypt_update(ctx,msg) /+ encrypt_final(ctx))]

[encrypt(msg:string, algo:CYPHERS, k:string) : string ->
	encrypt(msg,algo,k,"")]


// *********************************************************************
// *   Part 10: decrypt                                                *
// *********************************************************************



[decrypt_init(self:crypt_context, algo:CYPHERS, k:string) : void -> decrypt_init(self, algo, k, "")]


[decrypt_init(self:crypt_context, algo:CYPHERS, k:string, iv:string) : void ->
	if (externC("EVP_DecryptInit(self->context, EVP_get_cipherbyname(algo), NULL,NULL)", integer) = 0)
		openssl_error!(),
	if (externC("EVP_DecryptInit(self->context, NULL, (unsigned char*)k, *iv?(unsigned char*)iv:NULL)", integer) = 0)
		openssl_error!()]
	
[decrypt_update(self:crypt_context, msg:string) : string ->
	let len := length(msg), outlen := 4 * len
	in (externC("ClEnv->bufferStart()"),
		externC("ClEnv->pushAttempt(outlen)"),
		externC("unsigned char *buf = (unsigned char *)ClEnv->buffer"),
		if (externC("EVP_DecryptUpdate(self->context, buf,(int*) &outlen, (unsigned char*)msg, (int)len)", integer) = 0)
			openssl_error!(),
		copy(externC("ClEnv->buffer",string), outlen))]

[decrypt_final(self:crypt_context) : string ->
	let outlen := 4096
	in (externC("ClEnv->bufferStart()"),
		externC("ClEnv->pushAttempt(outlen)"),
		externC("unsigned char *buf = (unsigned char *)ClEnv->buffer"),
		if (externC("EVP_DecryptFinal(self->context, (unsigned char*)ClEnv->buffer, (int*)&outlen)", integer) = 0)
			openssl_error!(),
		copy(externC("ClEnv->buffer", string), outlen))]


[decrypt(msg:string, algo:CYPHERS, k:string, iv:string) : string ->
	let ctx := crypt_context!()
	in (decrypt_init(ctx,algo,k,iv),
		decrypt_update(ctx,msg) /+ decrypt_final(ctx))]

[decrypt(msg:string, algo:CYPHERS, k:string) : string => decrypt(msg, algo, k, "")]


// *********************************************************************
// *   Part 11: RSA public/private encryption                          *
// *********************************************************************


RSA_public_cipher <: filter(rsa:key, key_len:integer, pending_r:blob, pending_w:blob)

RSA_public_cipher!(self:port, k:key) : RSA_public_cipher ->
	filter!(RSA_public_cipher(rsa = k, key_len = key_size(k)), self)


write_port(self:RSA_public_cipher, buf:char*, len:integer) : integer ->
	(if unknown?(pending_w, self)
		self.pending_w := blob!(self.key_len),
	let pend := self.pending_w,
		sz := (self.key_len - 11),
		rsa* := externC("EVP_PKEY_get1_RSA(self->rsa->evp_key)", RSA*),
		n := 0
	in (while (len > 0)
			let disp := len min sz,
				olen := externC("RSA_public_encrypt(disp, (unsigned char*)buf,
						(unsigned char*)pend->data, rsa_star, RSA_PKCS1_PADDING)", integer)
			in (if (olen = -1) openssl_error!(),
				write_port(self.target, pend.Core/data, olen),
				buf :+ disp,
				len :- disp,
				n :+ disp), n))

eof_port?(self:RSA_public_cipher) : boolean ->
	((known?(pending_r, self) & eof_port?(self.pending_r)) & eof_port?(self.target))

read_port(self:RSA_public_cipher, buf:char*, len:integer) : integer ->
	(if unknown?(pending_r, self)
		self.pending_r := blob!(self.key_len),
	let pend := self.pending_r,
		sz := self.key_len,
		rsa* := externC("EVP_PKEY_get1_RSA(self->rsa->evp_key)", RSA*),
		n := 0
	in (while (len > 0)
			let disp := remain_to_read(pend)
			in (disp :min len,
				if (disp > 0)
					(externC("memcpy(buf, pend->data + pend->read_index, disp)"),
					pend.Core/read_index :+ disp,
					len :- disp,
					n :+ disp,
					buf :+ disp),
				if (eof_port?(pend) & not(eof_port?(self.target)))
					(pend.Core/read_index := 0,
					pend.Core/write_index := read_port(self.target, pend.Core/data, sz),
					externC("ClEnv->bufferStart()"),
					externC("ClEnv->pushAttempt(sz)"),
					let olen := externC("RSA_private_decrypt(pend->write_index,
								(unsigned char*)pend->data, (unsigned char*)ClEnv->buffer,
								rsa_star, RSA_PKCS1_PADDING)", integer)
					in (if (olen = -1) openssl_error!(),
						pend.Core/write_index := olen),
					externC("memcpy(pend->data, ClEnv->buffer, pend->write_index)"))
				else break()), n))


RSA_private_cipher <: filter(rsa:key, key_len:integer, pending_r:blob, pending_w:blob)

RSA_private_cipher!(self:port, k:key) : RSA_private_cipher ->
	filter!(RSA_private_cipher(rsa = k, key_len = key_size(k)), self)


write_port(self:RSA_private_cipher, buf:char*, len:integer) : integer ->
	(if unknown?(pending_w, self)
		self.pending_w := blob!(self.key_len),
	let pend := self.pending_w,
		sz := (self.key_len - 11),
		rsa* := externC("EVP_PKEY_get1_RSA(self->rsa->evp_key)", RSA*),
		n := 0
	in (while (len > 0)
			let disp := len min sz,
				olen := externC("RSA_private_encrypt(disp, (unsigned char*)buf,
						(unsigned char*)pend->data, rsa_star, RSA_PKCS1_PADDING)", integer)
			in (if (olen = -1) openssl_error!(),
				write_port(self.target, pend.Core/data, olen),
				buf :+ disp,
				len :- disp,
				n :+ disp), n))

eof_port?(self:RSA_private_cipher) : boolean ->
	((known?(pending_r, self) & eof_port?(self.pending_r)) & eof_port?(self.target))

read_port(self:RSA_private_cipher, buf:char*, len:integer) : integer ->
	(if unknown?(pending_r, self)
		self.pending_r := blob!(self.key_len),
	let pend := self.pending_r,
		sz := self.key_len,
		rsa* := externC("EVP_PKEY_get1_RSA(self->rsa->evp_key)", RSA*),
		n := 0
	in (while (len > 0)
			let disp := remain_to_read(pend)
			in (disp :min len,
				if (disp > 0)
					(externC("memcpy(buf, pend->data + pend->read_index, disp)"),
					pend.Core/read_index :+ disp,
					len :- disp,
					n :+ disp,
					buf :+ disp),
				if (eof_port?(pend) & not(eof_port?(self.target)))
					(pend.Core/read_index := 0,
					pend.Core/write_index := read_port(self.target, pend.Core/data, sz),
					externC("ClEnv->bufferStart()"),
					externC("ClEnv->pushAttempt(sz)"),
					let olen := externC("RSA_public_decrypt(pend->write_index,
								(unsigned char*)pend->data, (unsigned char*)ClEnv->buffer,
								rsa_star, RSA_PKCS1_PADDING)", integer)
					in (if (olen = -1) openssl_error!(),
						pend.Core/write_index := olen),
					externC("memcpy(pend->data, ClEnv->buffer, pend->write_index)"))
				else break()), n))




		
	