// interface definition for module Zlib
#ifndef CLAIREH_clZlib
#define CLAIREH_clZlib
#include <zlib.h>

  
class CL_EXPORT clZlib_z_stream_star;
class CL_EXPORT clZlib_unsigned_long_star;
class CL_EXPORT clZlib_deflater;
class CL_EXPORT clZlib_gziper;
class CL_EXPORT clZlib_zlib_error;

class CL_EXPORT clZlib_z_stream_star: public ClaireImport{ 
    public:}
  ;

class CL_EXPORT clZlib_unsigned_long_star: public ClaireImport{ 
    public:}
  ;

class CL_EXPORT clZlib_deflater: public filter{ 
    public:
       CL_INT ratio;
       ClaireBoolean *eof_reached_ask;
       char*data;
       CL_INT datalen;
       ClaireBoolean *aborted_ask;
       unsigned long*crc;
       ClaireBoolean *skip_crc_ask;
       z_stream*zin;
       ClaireBoolean *in_init_ask;
       z_stream*zout;
       ClaireBoolean *out_init_ask;
       ClaireBoolean *data_written_ask;}
  ;

class CL_EXPORT clZlib_gziper: public clZlib_deflater{ 
    public:
       ClaireBoolean *read_gzip_header_ask;
       ClaireBoolean *write_gzip_header_ask;}
  ;

class CL_EXPORT clZlib_zlib_error: public ClaireError{ 
    public:
       clZlib_deflater *src;
       char *msg;
       char *from;}
  ;
extern CL_EXPORT char * Zlib_zlibversion_void1();
extern CL_EXPORT void  Zlib_zlib_error_I_deflater1(clZlib_deflater *p,char *f,char *m);
extern CL_EXPORT void  claire_self_print_zlib_error1_Zlib(clZlib_zlib_error *self);
extern CL_EXPORT void  Zlib_check_zlib_rc_deflater1(clZlib_deflater *p,CL_INT rc,char *from);
extern CL_EXPORT clZlib_deflater * Zlib_init_z_port_port1(PortObject *self,clZlib_deflater *z,ClaireBoolean *gzip_ask,CL_INT level);
extern CL_EXPORT ClaireType * Zlib_init_z_port_port1_type(ClaireType *self,ClaireType *z,ClaireType *gzip_ask,ClaireType *level);
extern CL_EXPORT void  claire_close_port_deflater1_Zlib(clZlib_deflater *self);
extern CL_EXPORT void  Zlib_add_footer_gziper1(clZlib_gziper *self);
extern CL_EXPORT clZlib_deflater * Zlib_deflater_I_port1(PortObject *self);
extern CL_EXPORT clZlib_deflater * Zlib_deflater_I_port2(PortObject *self,CL_INT compression_level);
extern CL_EXPORT ClaireBoolean * claire_eof_port_ask_deflater1_Zlib(clZlib_deflater *self);
extern CL_EXPORT CL_INT  claire_read_port_deflater1_Zlib(clZlib_deflater *self,char*buf,CL_INT len);
extern CL_EXPORT CL_INT  claire_write_port_deflater1_Zlib(clZlib_deflater *self,char*buf,CL_INT len);
extern CL_EXPORT void  Zlib_full_flush_deflater1(clZlib_deflater *self);
extern CL_EXPORT void  Zlib_finish_deflater1(clZlib_deflater *self);
extern CL_EXPORT clZlib_gziper * Zlib_gziper_I_port1(PortObject *self);
extern CL_EXPORT clZlib_gziper * Zlib_gziper_I_port2(PortObject *self,CL_INT compression_level);

// namespace class for Zlib 
class CL_EXPORT clZlibClass: public NameSpace {
public:

  ClaireClass * _z_stream_star;
  ClaireClass * _unsigned_long_star;
  ClaireClass * _deflater;
  ClaireClass * _gziper;
  ClaireClass * _zlib_error;
property * zlibversion;// Zlib/"zlibversion"
property * ratio;// Zlib/"ratio"
property * eof_reached_ask;// Zlib/"eof_reached?"
property * data;// Zlib/"data"
property * datalen;// Zlib/"datalen"
property * aborted_ask;// Zlib/"aborted?"
property * crc;// Zlib/"crc"
property * skip_crc_ask;// Zlib/"skip_crc?"
property * zin;// Zlib/"zin"
property * in_init_ask;// Zlib/"in_init?"
property * zout;// Zlib/"zout"
property * out_init_ask;// Zlib/"out_init?"
property * data_written_ask;// Zlib/"data_written?"
property * read_gzip_header_ask;// Zlib/"read_gzip_header?"
property * write_gzip_header_ask;// Zlib/"write_gzip_header?"
property * src;// Zlib/"src"
property * msg;// Zlib/"msg"
property * from;// Zlib/"from"
property * zlib_error_I;// Zlib/"zlib_error!"
property * check_zlib_rc;// Zlib/"check_zlib_rc"
property * init_z_port;// Zlib/"init_z_port"
property * finish;// Zlib/"finish"
property * add_footer;// Zlib/"add_footer"
property * deflater_I;// Zlib/"deflater!"
property * full_flush;// Zlib/"full_flush"
property * gziper_I;// Zlib/"gziper!"

// module definition 
 void metaLoad();};

extern CL_EXPORT clZlibClass clZlib;

#endif

