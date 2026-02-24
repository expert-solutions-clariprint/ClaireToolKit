
// @doc
// AES encryption and decryption functions using OpenSSL EVP API
// This implementation uses AES-256 in GCM mode, which provides both confidentiality and integrity.
// The encryption function generates a random 16-byte IV for each encryption operation and prepends it to the output.
// The decryption function reads the IV from the beginning of the input and uses it for decryption. The GCM authentication tag is also handled appropriately.
[aes_encrypt(input:port, out:port, key:string) : port
-> let // out := port!()
        dummy_out := true
    in (
    externC("
    EVP_CIPHER_CTX *ctx = NULL;
    int len = 0, ciphertext_len = 0;
    ctx = EVP_CIPHER_CTX_new();
    unsigned char iv[16] ;
    if (RAND_bytes(iv, sizeof(iv)) != 1) {
        Cerror(71, _string_(\"Error generating random IV\"),0);
    }
    out->puts((char*)iv, 16); // write IV at the beginning of the output

    /* Initialise the encryption operation. */
    if(1 != EVP_EncryptInit_ex(ctx, EVP_aes_256_gcm(), NULL, NULL, NULL))
        Cerror(71, _string_(\"Error initializing encryption operation\"),0);

    /* Set IV length if default 12 bytes (96 bits) is not appropriate */
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, 16, NULL);
    // if(1 != EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, 12, NULL))
    //    handleErrors();

    /* Initialise key and IV */
    if (1 != EVP_EncryptInit_ex(ctx, NULL, NULL, (const unsigned char *)key, (const unsigned char *)iv))
        Cerror(71, _string_(\"Error initializing key and IV\"),0);

    "),

    let buff := ""
    in (while (not(eof?(input))) (
        let str := fread(input,128),
            str_len := length(str)
        in (//[1] read ~S bytes from input ~S // str_len, str,
            externC("
            char* buff[256];
            int bufflen;
            EVP_EncryptUpdate(ctx, (unsigned char *)buff, &bufflen, (const unsigned char*)str, str_len);
            // printf(\"Encrypted %d bytes\\n\", bufflen);
            out->puts(buff, bufflen);
            ")))),
    /* Finalise the encryption. Normally ciphertext bytes may be written at
     * this stage, but this does not occur in GCM mode
     */
      externC("
            char* buff[256];
            int bufflen;
            EVP_EncryptFinal_ex(ctx, (unsigned char *)buff, &bufflen);
            // printf(\"EVP_EncryptFinal_ex %d bytes\\n\", bufflen);
            out->puts(buff, bufflen);
            "),


    /* Add the tag */
    externC("
            unsigned char tag[16];
            if(1 != EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_GET_TAG, 16, tag))
                Cerror(71, _string_(\"Error getting GCM tag\"),0);
            out->puts(tag, 16);
            "),
    /* Clean up */
    externC("EVP_CIPHER_CTX_free(ctx);"),
    out)]

// @doc
// AES decryption function corresponding to the above encryption function.
// It reads the IV from the beginning of the input, uses it for decryption, and handles the GCM authentication tag appropriately.
[aes_decrypt(input:port,out:port, key:string) : port
-> let 
        iv:string := fread(input, 16) // read IV from the beginning of the input
    in (
    externC("
    EVP_CIPHER_CTX *ctx = NULL;
    int len = 0, ciphertext_len = 0;
    ctx = EVP_CIPHER_CTX_new();

    /* Initialise the decryption operation. */
    if(1 != EVP_DecryptInit_ex(ctx, EVP_aes_256_gcm(), NULL, NULL, NULL))       
        Cerror(71, _string_(\"Error initializing decryption operation\"),0);

    /* Set IV length if default 12 bytes (96 bits) is not appropriate */
    if(1 != EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, 16, NULL))
        Cerror(71, _string_(\"Error setting IV length\"),0);

    /* Initialise key and IV */
    if (1 != EVP_DecryptInit_ex(ctx, NULL, NULL, (const unsigned char *)key, (const unsigned char *)iv))
        Cerror(71, _string_(\"Error initializing key and IV\"),0);
    "),

    let buff := ""
    in (while (not(eof?(input))) (
        let str := fread(input,128),
            str_len := length(str),
            tag := ""
        in (//[1] read ~S bytes from input ~S // str_len, str,
            if (eof?(input)) (
                //[2] read tag from input ~S // str,
                tag := substring(str, str_len - 16, str_len),
                str_len :- 16),
            externC("
            char* buff[256];
            int len;
            EVP_DecryptUpdate(ctx, (unsigned char *)buff, &len, (const unsigned char*)str, str_len);
            out->puts(buff, len);
            "),
            if (tag != "") externC("
            if(1 != EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_TAG, 16, (void*)tag))
                Cerror(71, _string_(\"Error setting GCM tag\"),0);")
            ))),
      externC("
            char* buff[256];
            int bufflen;
            EVP_DecryptFinal_ex(ctx, (unsigned char *)buff, &bufflen);
            out->puts(buff, bufflen);
            "),

    externC("EVP_CIPHER_CTX_free(ctx);"),
    out)]
