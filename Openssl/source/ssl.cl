
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * ssl.cl                                                            *
// * Copyright (C) 2004-2005 xl. All Rights Reserved                   *
// *********************************************************************


// *********************************************************************
// *   Part 1: model                                                   *
// *********************************************************************

SSL* <: import()
(c_interface(SSL*, "SSL*"))

SSL_CTX* <: import()
(c_interface(SSL_CTX*, "SSL_CTX*"))


ssl_socket <: socket(ssl*:SSL*, ssl_ctx*:SSL_CTX*)

INIT_SSL:boolean := false

init_ssl_lib() : void ->
	(if not(INIT_SSL) externC("SSL_load_error_strings(); SSL_library_init();"),
	INIT_SSL := true)




check_peer_certificate_against_host(self:ssl_socket) : void ->
	(if externC("(SSL_get_verify_result(self->ssl_star) != X509_V_OK ? CTRUE : CFALSE)", boolean)
		error("Peer certificate of ~S doesn't verify", self),
	// Check the common name
	externC("X509 *peer = SSL_get_peer_certificate(self->ssl_star)"),
	externC("char peer_CN[256]"),
	externC("X509_NAME_get_text_by_NID(X509_get_subject_name(peer), NID_commonName, peer_CN, 256)"),
	//if externC("(strcasecmp(peer_CN, self->address) ? CTRUE : CFALSE)", boolean)
	if (lower(externC("peer_CN",string)) != lower(self.Core/address))
		error("Common name doesn't match host name on ~S", self))

//<sb> @doc SSL
// sclient!(addr, p) creates an SSL socket connected to the server with address addr on the
// port p.
claire/sclient!(addr:string, p:integer) : ssl_socket ->
	let s := ssl_socket(
				Core/address = addr,
				Core/fd = Core/connect(addr, p),
				Core/tcpport = p)
	in (
		// OpenAI refuse parfois les clients en non-blocking mode avec SSL_connect
		externC("fcntl(s->fd, F_SETFL, fcntl(s->fd, F_GETFL) & ~O_NONBLOCK);"),

		init_ssl_lib(),

		// Création du contexte TLS
		externC("const SSL_METHOD *meth = TLS_method();"),
		if externC("(meth == NULL ? CTRUE : CFALSE)", boolean)
			error("Couldn't create SSL method for ~A:~S", addr, p),

		externC("s->ssl_ctx_star = SSL_CTX_new(meth);"),
		if externC("(s->ssl_ctx_star == NULL ? CTRUE : CFALSE)", boolean)
			error("Couldn't create SSL context for ~A:~S", addr, p),

		// Callback pour debug SSL
	//	externC("SSL_CTX_set_info_callback(s->ssl_ctx_star, &SSL_info_callback);"),

		// Forçage TLSv1.2 minimum
		externC("SSL_CTX_set_min_proto_version(s->ssl_ctx_star, TLS1_2_VERSION);"),
		externC("SSL_CTX_set_options(s->ssl_ctx_star, SSL_OP_NO_SSLv2 | SSL_OP_NO_SSLv3);"),

		// Création de l'objet SSL
		externC("s->ssl_star = SSL_new(s->ssl_ctx_star);"),

		// Configuration du nom SNI
		externC("SSL_set_tlsext_host_name(s->ssl_star, s->address);"),

		// Configuration ALPN côté client : HTTP/1.1 uniquement
		externC(
"unsigned char alpn_protos[] = { 8, 'h','t','t','p','/','1','.','1' };
int r = SSL_CTX_set_alpn_protos(s->ssl_ctx_star, alpn_protos, sizeof(alpn_protos));
if (r != 0) printf(\"ALPN setup failed\\n\");"
		),

		// Association du socket à l'objet SSL
		externC("BIO* sbio = BIO_new_socket(s->fd, BIO_NOCLOSE);"),
		externC("SSL_set_bio(s->ssl_star, sbio, sbio);"),

		// Vérification du certificat (optionnel : peut être désactivé en dev)
		externC("SSL_CTX_set_verify(s->ssl_ctx_star, SSL_VERIFY_PEER, NULL);"),


		// Chargement des CA root 
		externC("SSL_CTX_set_default_verify_paths(s->ssl_ctx_star)"),
		externC("SSL_set1_host(s->ssl_star, s->address)"),


		// Connexion SSL/TLS
		if (externC("SSL_connect(s->ssl_star)", integer) <= 0)
			openssl_error!(),

		// Affiche version TLS
		externC("printf(\"TLS version negotiated: %s\\n\", SSL_get_version(s->ssl_star));"),

		// TODO: vérif certificat ici si nécessaire
		s)

/*
claire/sclient!(addr:string, p:integer) : ssl_socket ->
	let s := ssl_socket(
				Core/address = addr,
				Core/fd = Core/connect(addr, p),
				Core/tcpport = p)
	in (init_ssl_lib(),
		externC("const SSL_METHOD *meth=TLS_method()"),
		if externC("(meth==NULL ? CTRUE : CFALSE)",boolean)
			error("Couldn't create SSL method for ~A:~S", addr, p),
		externC("s->ssl_ctx_star = SSL_CTX_new(meth)"),
		if externC("(s->ssl_ctx_star==NULL ? CTRUE : CFALSE)",boolean)
			error("Couldn't create SSL context for ~A:~S", addr, p),
		externC("SSL_CTX_set_min_proto_version(s->ssl_ctx_star, TLS1_2_VERSION)"),
		externC("SSL_CTX_set_options(s->ssl_ctx_star, SSL_OP_NO_SSLv2 | SSL_OP_NO_SSLv3)"),
		externC(
"unsigned char protos[] = { 8, 'h', 't', 't', 'p', '/', '1', '.', '1' };
 int r = SSL_CTX_set_alpn_protos(s->ssl_ctx_star, protos, sizeof(protos));
 if (r != 0) { printf(\"ALPN setup failed\\n\"); }"
		),

		externC("s->ssl_star = SSL_new(s->ssl_ctx_star)"),
		externC("printf(\"TLS version negotiated: %s\\n\", SSL_get_version(s->ssl_star))"),
		externC("BIO* sbio=BIO_new_socket(s->fd,BIO_NOCLOSE)"),
		externC("SSL_set_bio(s->ssl_star,sbio,sbio)"),
		externC("SSL_set_tlsext_host_name(s->ssl_star, s->Core/address)"),
		externC("SSL_CTX_set_verify(s->ssl_ctx_star, SSL_VERIFY_PEER, NULL)"),
		externC("const unsigned char alpn_protos[] = { 8, 'h','t','t','p','/','1','.','1' };"),
		externC("SSL_CTX_set_alpn_protos(s->ssl_ctx_star, alpn_protos, sizeof(alpn_protos))"),

		externC("SSL_CTX_set_default_verify_paths(s->ssl_ctx_star)"),
		externC("SSL_set1_host(s->ssl_star, s->Core/address)"),

		if (externC("SSL_connect(s->ssl_star)", integer) <= 0)
			openssl_error!(),
		//check_peer_certificate_against_host(s),
		s)
*/


read_port(self:ssl_socket, buf:char*, len:integer) : integer ->
	let r := 0
	in (while (r < len)
			let n := externC("SSL_read(self->ssl_star, buf + r, len - r)", integer)
			in (if (n = 0)
					(self.Core/eof_reached? := true,
					break())
				else if (n = -1 & externC("(errno != EINTR ? CTRUE : CFALSE)", boolean))
					externC("Cerrorno(97, _string_(\"read\"), _oid_(self))")
				else r :+ n),
		r)

write_port(self:ssl_socket, buf:char*, len:integer) : integer ->
	let r := 0
	in (while (r < len)
			let n := externC("SSL_write(self->ssl_star, buf + r, len - r)", integer)
			in (if (n = -1 & externC("(errno != EINTR ? CTRUE : CFALSE)", boolean))
					externC("Cerrorno(97, _string_(\"write\"), _oid_(self))")
				else r :+ n),
		r)


close_port(self:ssl_socket) : void ->
	(externC("SSL_CTX_free(self->ssl_ctx_star)"),
	externC("SSL_free(self->ssl_star)"))





