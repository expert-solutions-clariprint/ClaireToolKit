
/*
typedef struct {
            unsigned char version;
            unsigned char type;
            unsigned char requestIdB1;
            unsigned char requestIdB0;
            unsigned char contentLengthB1;
            unsigned char contentLengthB0;
            unsigned char paddingLength;
            unsigned char reserved;
            unsigned char contentData[];
            unsigned char paddingData[];
        } FCGI_Record;
*/
typedef struct {
            unsigned char version;
            unsigned char type;
            unsigned char requestIdB1;
            unsigned char requestIdB0;
            unsigned char contentLengthB1;
            unsigned char contentLengthB0;
            unsigned char paddingLength;
            unsigned char reserved;
} FCGI_Record_Header;
  
 typedef struct {
            unsigned char appStatusB3;
            unsigned char appStatusB2;
            unsigned char appStatusB1;
            unsigned char appStatusB0;
            unsigned char protocolStatus;
            unsigned char reserved[3];
 } FCGI_EndRequestBody;
