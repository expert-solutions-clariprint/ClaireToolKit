#ifndef CLMD5_H
#define CLMD5_H

struct CLMD5Context {
        unsigned buf[4];
        unsigned bits[2];
        unsigned char in[64];
};

void MD5Init(struct CLMD5Context *context);
void MD5Update(struct CLMD5Context *context, unsigned char const *buf,
               unsigned len);
void MD5Final(unsigned char digest[16], struct CLMD5Context *context);

/*
 * This is needed to make RSAREF happy on some MS-DOS compilers.
 */
typedef struct CLMD5Context CLMD5_CTX;

#endif
