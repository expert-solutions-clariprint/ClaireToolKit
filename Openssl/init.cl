
// init file for module Openssl
// created Mon May 10 14:01:39 2004 by claire v3.3.33

WIN32_CONTRIB :: (realpath(getenv("_")) /- "" /- "" /- "" /- "contrib")

// ==== external libraries needed at link time ====
(if (compiler.env = "ntv")
	compiler.libraries :add 
//		WIN32_CONTRIB / "lib" / "libeay32.lib" /+ " " /+
//		WIN32_CONTRIB / "lib" / "ssleay32.lib advapi32.lib"
		WIN32_CONTRIB / "lib" / "libssl.lib libcrypto.lib"

else
	compiler.libraries :add " -L/opt/local/lib -lssl -lssl -lcrypto")

// ==== C++ compiler options ====
(if (compiler.env = "ntv")
	(compiler.options[1] :/+ " /I" /+ WIN32_CONTRIB, // Optimize mode (-O)
	compiler.options[2] :/+ " /I" /+ WIN32_CONTRIB, // Debug mode (-D)
	compiler.options[3] :/+ " /I" /+ WIN32_CONTRIB)) // Release mode

Openssl :: module(
	uses = list(Core),
	made_of = list(
		"../csrc/ssl_callbacks.cpp",
		"common.cl",
		"key.cl",
		"x509.cl",
		"pkcs7.cl",
		"pkcs8.cl",
		"pkcs12.cl",
		"ssl.cl",
		"<openssl/asn1.h>",
		"<openssl/rand.h>",
		"<openssl/ssl.h>",
		"<openssl/rsa.h>",
		"<openssl/dsa.h>",
		"<openssl/err.h>",
		"<openssl/x509v3.h>",
		"<openssl/x509_vfy.h>",
		"<openssl/evp.h>",
		"<openssl/pkcs12.h>"),
	source = "source",
	version = "v1.0.0") // put your version here


(load(Openssl))




