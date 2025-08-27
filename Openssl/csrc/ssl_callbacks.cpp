// ssl_callbacks.h

#include <openssl/ssl.h>
#include <stdio.h>

void SSL_info_callback(const SSL *ssl, int where, int ret) {
    const char *state = SSL_state_string_long(ssl);
    const char *where_str = NULL;

    if (where & SSL_ST_CONNECT) where_str = "SSL_connect";
    else if (where & SSL_ST_ACCEPT) where_str = "SSL_accept";
    else where_str = "undefined";

    printf("[INFO] SSL state: %s | phase: %s | ret: %d\n", state, where_str, ret);
}
