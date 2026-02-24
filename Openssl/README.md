# Openssl

`Openssl` is a Claire module that wraps OpenSSL APIs.
It is mainly used with the `Http` module to provide HTTPS client connectivity.

## Main functions

### `sclient!(addr:string, p:integer) : ssl_socket`
Creates an SSL/TLS client socket connected to host `addr` on port `p`.

### `aes_encrypt(input:port, out:port, key:string) : port`
Reads plaintext from `input`, writes encrypted data to `out`, and returns `out`.

### `aes_decrypt(input:port, out:port, key:string) : port`
Reads encrypted data from `input`, writes decrypted data to `out`, and returns `out`.

## Quick AES example

See `tests/aes.cl` for a complete round-trip encryption/decryption example.

From this module directory, run:

```sh
./Darwin-arm-g++16.0.0/Openssl -f tests/aes.cl -q
```

## Notes

- Source files are in `source/`.
- Generated C++ files are in `csrc/`.
- Additional generated API documentation is available in `doc/Openssl.html`.

