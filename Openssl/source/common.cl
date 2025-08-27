
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * common.cl                                                         *
// * Copyright (C) 2004-2005 xl. All Rights Reserved                   *
// *********************************************************************

// @presentation
// The module Openssl is a wrapper for the popular openssl library.
// It provides the infrastructure for handling Public Key Infrastructure
// (PKI) including key pair generation, X509, digests and digital signature,
// cyphers and other Public Key Cryptographic Standars (PKCS).
// @presentation

// *********************************************************************
// *   Part 1: predef                                                  *
// *   Part 2: errors                                                  *
// *   Part 3: digest ans cypher algo                                  *
// *   Part 4: NID to text conversion                                  *
// *   Part 5: hex strings                                             *
// *   Part 6: DER octet string                                        *
// *********************************************************************


// *********************************************************************
// *   Part 1: predef                                                  *
// *********************************************************************


key <: freeable_object

(#if compiler.loading?
	let r := uid(), d := now()
	in (externC("OpenSSL_add_all_algorithms()"),
		externC("ERR_load_crypto_strings()"),
		externC("RAND_add(r,26,d)")))

// *********************************************************************
// *   Part 2: errors                                                  *
// *********************************************************************

openssl_error <: exception(errs:list[string])

[openssl_error!() : void ->
	let l := list<string>()
	in (externC("unsigned long code"),
		externC("SSL_load_error_strings()"),
		while (externC("((code = ERR_get_error()) != 0)", integer) = 1)
			(print_in_string(),
			printf("[~A]:[~A]:[~A]",
				externC("(char*)(ERR_lib_error_string(code)?ERR_lib_error_string(code):\"unknown\")", string),
				externC("(char*)(ERR_func_error_string(code)?ERR_func_error_string(code):\"unknown\")", string),
				externC("(char*)(ERR_reason_error_string(code)?ERR_reason_error_string(code):\"unknown\")", string)),
			l :add end_of_string()),
		openssl_error(errs = l))]


[openssl_error!(err:string) : void =>
	openssl_error(errs = list(err))]

[self_print(self:openssl_error) : void ->
	printf("**** ~A error~I",
		externC("(char*)SSLeay_version(SSLEAY_VERSION)", string),
		(for e in self.errs printf("\n~A", e)))]
		

// *********************************************************************
// *   Part 3: digest ans cypher algo                                  *
// *********************************************************************


// @doc Algorithms
// DIGEST_ALGORYTHMS contains the names of valid algorithms used for digest and
// digital signature calculations.
DIGEST_ALGORYTHMS :: {"null", "md2", "md5", "sha", "sha1", "dss", "dss1", "mdc2", "ripemd160"}

// @doc Algorithms
// CYPHERS contains the names of valid algorithms used for encryption.
CYPHERS :: {

       "des-cbc", "des-ecb", "des-cfb", "des-ofb",
           // DES in CBC, ECB, CFB and OFB modes respectively.

       "des-ede-cbc", "des-ede", "des-ede-ofb", "des-ede-cfb",
           // Two key triple DES in CBC, ECB, CFB and OFB modes respectively.

       "des-ede3-cbc", "des-ede3", "des-ede3-ofb", "des-ede3-cfb",
           // Three key triple DES in CBC, ECB, CFB and OFB modes respectively.

       "desx-cbc",
           // DESX algorithm in CBC mode.

       "rc4",
           // RC4 stream cipher. This is a variable key length cipher with
           // default key length 128 bits.

       "rc4-40",
           // RC4 stream cipher with 40 bit key length. This is obsolete and new
           // code should use rc4() and the CIPHER_CTX_set_key_length()
           // function.

       "idea-cbc", "idea-ecb", "idea-cfb",
       "idea-ofb", "idea-cbc",
           // IDEA encryption algorithm in CBC, ECB, CFB and OFB modes respec-
           // tively.

       "rc2-cbc", "rc2-ecb", "rc2-cfb", "rc2-ofb",
           // RC2 encryption algorithm in CBC, ECB, CFB and OFB modes respec-
           // tively. This is a variable key length cipher with an additional
           // parameter called "effective key bits" or "effective key length".
           // By default both are set to 128 bits.

       "rc2-40-cbc", "rc2-64-cbc",
           // RC2 algorithm in CBC mode with a default key length and effective
           // key length of 40 and 64 bits.  These are obsolete and new code
           // should use EVP_rc2_cbc(), EVP_CIPHER_CTX_set_key_length() and
           // EVP_CIPHER_CTX_ctrl() to set the key length and effective key
           // length.

       "bf-cbc", "bf-ecb", "bf-cfb", "bf-ofb",
           // Blowfish encryption algorithm in CBC, ECB, CFB and OFB modes
           // respectively. This is a variable key length cipher.

       "cast5-cbc", "cast5-ecb", "cast5-cfb", "cast5-ofb",
           // CAST encryption algorithm in CBC, ECB, CFB and OFB modes respec-
           // tively. This is a variable key length cipher.

       "rc5-32-12-16-cbc", "rc5-32-12-16-ecb",
       "rc5-32-12-16-cfb", "rc5-32-12-16-ofb"
           // RC5 encryption algorithm in CBC, ECB, CFB and OFB modes respec-
           // tively. This is a variable key length cipher with an additional
           // "number of rounds" parameter. By default the key length is set to
           // 128 bits and 12 rounds.
		}

// *********************************************************************
// *   Part 4: NID to text conversion                                  *
// *********************************************************************


//<sb> NID are registered ID with a particular meaning
// conversion can be done between NID integers and a 
// pair of name

//<sb> convert a name (short, long) in a NID
[txt2nid(self:string) : integer ->
	let nid := externC("OBJ_txt2nid(self)", integer)
	in (if (nid = externC("NID_undef",integer))
			error("~A cannot be converted to a valid NID", self),
		nid)]

//<sb> convert a NID to a short (and long) name
[nid2txt(self:integer) : tuple(string,string) ->
	let sn := externC("(char*)OBJ_nid2sn(self)", string),
		ln := externC("(char*)OBJ_nid2ln(self)", string)
	in (if (externC("(sn == NULL || ln == NULL)", integer) != 0)
			openssl_error!(),
		tuple(copy(sn),copy(ln)))]

// *********************************************************************
// *   Part 5: hex strings                                             *
// *********************************************************************


[hex2string(self:string) : string ->
	let len := length(self),
		olen := len / 2
	in (if (len mod 2 != 0) (self :/+ "0", len :+ 1),
		self := lower(self),
		externC("ClEnv->bufferStart()"),
		externC("ClEnv->pushAttempt(olen + 1)"),
		externC("int i = 0; unsigned char *p = (unsigned char *)ClEnv->buffer"),
		externC("for(;i < len;i += 2, p++) {"),
			externC("unsigned char c1 = self[i], c2 = self[i + 1]"),
			externC("int h = (c1 >= 'a' ? 10 + c1 - 'a' : c1 - '0') * 16"),
			externC("h += (c2 >= 'a' ? 10 + c2 - 'a' : c2 - '0')"),
			externC("*p = h;}"),
		copy(externC("ClEnv->buffer", string), olen))]

[string2hex(self:string) : string ->
	let len := length(self),
		olen := len * 2
	in (externC("ClEnv->bufferStart()"),
		externC("ClEnv->pushAttempt(olen)"),
		externC("int i = 0; char *p = ClEnv->buffer"),
		externC("for(;i < len;i++, p += 2) {"),
			externC("sprintf(p,\"%.2lx\", (unsigned)((unsigned char*)self)[i]); }"),
		copy(externC("ClEnv->buffer", string), olen))]


// *********************************************************************
// *   Part 6: DER octet string                                        *
// *********************************************************************


[i2d_octet_string(self:string) : string ->
	let len := length(self),
		olen := len + 50
	in (externC("ASN1_OCTET_STRING* asn1 = ASN1_OCTET_STRING_new()"),
		externC("ASN1_OCTET_STRING_set(asn1, (unsigned char*)self, len)"),
		externC("ClEnv->bufferStart()"),
		externC("ClEnv->pushAttempt(olen)"),
		externC("unsigned char *buf = (unsigned char *)ClEnv->buffer"),
		externC("i2d_ASN1_OCTET_STRING(asn1, &buf)"),
		externC("ASN1_OCTET_STRING_free(asn1)"),
		copy(externC("ClEnv->buffer", string), externC("(buf - (unsigned char *)ClEnv->buffer)", integer)))]


[d2i_octet_string(self:string) : string ->
	let len := length(self)
	in (externC("ASN1_OCTET_STRING* asn1 = ASN1_OCTET_STRING_new()"),
		externC("const unsigned char *buf = (unsigned char*)self"),
		externC("d2i_ASN1_OCTET_STRING(&asn1, &buf, len)"),
		let res := copy(externC("(char*)asn1->data", string), externC("asn1->length", integer))
		in (externC("ASN1_OCTET_STRING_free(asn1)"),
			res))]
