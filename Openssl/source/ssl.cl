
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
	(if not(INIT_SSL) externC("SSL_library_init();"),
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
	in (init_ssl_lib(),
		externC("const SSL_METHOD *meth=DTLS_method()"),
		if externC("(meth==NULL ? CTRUE : CFALSE)",boolean)
			error("Couldn't create SSL method for ~A:~S", addr, p),
		externC("s->ssl_ctx_star = SSL_CTX_new(meth)"),
		if externC("(s->ssl_ctx_star==NULL ? CTRUE : CFALSE)",boolean)
			error("Couldn't create SSL context for ~A:~S", addr, p),
		externC("s->ssl_star = SSL_new(s->ssl_ctx_star)"),
		externC("BIO* sbio=BIO_new_socket(s->fd,BIO_NOCLOSE)"),
		externC("SSL_set_bio(s->ssl_star,sbio,sbio)"),
		if (externC("SSL_connect(s->ssl_star)", integer) <= 0)
			openssl_error!(),
		//check_peer_certificate_against_host(s),
		s)



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





