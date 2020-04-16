// interface definition for module Sax
#ifndef CLAIREH_clSax
#define CLAIREH_clSax

  
class CL_EXPORT clSax_sax_parser;

class CL_EXPORT clSax_sax_parser: public ephemeral_object{ 
    public:
       ClaireBoolean *applyToCallback;
       PortObject *input;
       table *nsmap;
       char *currentns;
       property *xml_begin_element_handler;
       property *xml_end_element_handler;
       property *xml_doctype_handler;
       property *xml_signature_handler;
       property *xml_declaration_handler;
       property *xml_cdata_handler;
       property *xml_comment_handler;
       char *core_charset;
       char *file_charset;
       OID xml_data;}
  ;
extern CL_EXPORT tuple * Sax_xml_read_upto_port1(PortObject *p,ClaireType *s);
extern CL_EXPORT tuple * Sax_xml_read_upto_port1_(PortObject *g0005,ClaireType *g0006);
extern CL_EXPORT char * Sax_xml_read_upto_port2(PortObject *p,char *s,ClaireBoolean *error_ask);
extern CL_EXPORT char * Sax_xml_read_upto_port3(PortObject *p,char *s);
extern CL_EXPORT char * Sax_parse_one_attr_sax_parser1(clSax_sax_parser *parser,PortObject *p,table *t);
extern CL_EXPORT list * Sax_build_larg4_any1(OID x,OID y,OID z,OID a);
extern CL_EXPORT list * Sax_build_larg3_any1(OID x,OID y,OID z);
extern CL_EXPORT list * Sax_build_larg2_any1(OID x,OID y);
extern CL_EXPORT list * Sax_build_larg1_any1(OID x);
extern CL_EXPORT OID  Sax_xml_handler_sax_parser1(clSax_sax_parser *parser,table *attrs);
extern CL_EXPORT OID  Sax_xml_handler_sax_parser2(clSax_sax_parser *parser,table *attrs,OID userdata);
extern CL_EXPORT OID  Sax_doctype_handler_sax_parser1(clSax_sax_parser *parser,table *attrs);
extern CL_EXPORT OID  Sax_doctype_handler_sax_parser2(clSax_sax_parser *parser,table *attrs,OID userdata);
extern CL_EXPORT property * Sax_set_xml_handler_property1(property *p);
extern CL_EXPORT property * Sax_set_doctype_handler_property1(property *p);
extern CL_EXPORT void  Sax_set_handler_property1(property *xml_begin_element,property *xml_end_element);
extern CL_EXPORT void  Sax_set_handler_sax_parser1(clSax_sax_parser *self,property *xml_begin_element,property *xml_end_element);
extern CL_EXPORT char * Sax_set_default_core_charset_string1(char *self);
extern CL_EXPORT char * Sax_set_default_file_charset_string1(char *self);
extern CL_EXPORT clSax_sax_parser * claire_close_sax_parser1(clSax_sax_parser *self);
extern CL_EXPORT OID  Sax_sax_port1(PortObject *self,property *xml_begin_element,property *xml_end_element);
extern CL_EXPORT OID  Sax_sax_port2(PortObject *p,property *xml_begin_element,property *xml_end_element,OID data);
extern CL_EXPORT OID  Sax_sax_sax_parser1(clSax_sax_parser *parser);
extern CL_EXPORT OID  Sax_debug_xml_handler_sax_parser1(clSax_sax_parser *parser,table *attrs);
extern CL_EXPORT OID  Sax_debug_doctype_handler_sax_parser1(clSax_sax_parser *parser,table *attrs);
extern CL_EXPORT void  Sax_debug_enter_sax_parser1(clSax_sax_parser *parser,char *s,table *attrs);
extern CL_EXPORT void  Sax_debug_leave_sax_parser1(clSax_sax_parser *parser,char *s,char *cdata);
extern CL_EXPORT void  Sax_sax_debug_port1(PortObject *p,char *wildcard);

// namespace class for Sax 
class CL_EXPORT clSaxClass: public NameSpace {
public:

  global_variable * DEBUG;
  ClaireClass * _sax_parser;
  global_variable * SEP1;
  global_variable * SEP2;
  global_variable * AFTER_TAG;
  global_variable * SEP4;
  global_variable * QTE;
  global_variable * larg4;
  global_variable * larg3;
  global_variable * larg2;
  global_variable * larg1;
  global_variable * HANDLER_SET_ask;
  global_variable * BEGIN_HANDLER;
  global_variable * END_HANDLER;
  global_variable * XML_HANDLER;
  global_variable * DOCTYPE_HANDLER;
  global_variable * DEFAULT_CORE_CHARSET;
  global_variable * DEFAULT_FILE_CHARSET;
  global_variable * DEBUG_WILDCARD;
property * xml_read_upto;// Sax/"xml_read_upto"
property * build_larg2;// Sax/"build_larg2"
property * debug_xml_handler;// Sax/"debug_xml_handler"
property * parse_one_attr;// Sax/"parse_one_attr"
property * nsmap;// Sax/"nsmap"
property * currentns;// Sax/"currentns"
property * build_larg4;// Sax/"build_larg4"
property * build_larg3;// Sax/"build_larg3"
property * build_larg1;// Sax/"build_larg1"
property * xml_handler;// Sax/"xml_handler"
property * doctype_handler;// Sax/"doctype_handler"
property * set_xml_handler;// Sax/"set_xml_handler"
property * set_doctype_handler;// Sax/"set_doctype_handler"
property * set_handler;// Sax/"set_handler"
property * xml_begin_element_handler;// Sax/"xml_begin_element_handler"
property * xml_end_element_handler;// Sax/"xml_end_element_handler"
property * set_default_core_charset;// Sax/"set_default_core_charset"
property * set_default_file_charset;// Sax/"set_default_file_charset"
property * applyToCallback;// Sax/"applyToCallback"
property * input;// Sax/"input"
property * xml_doctype_handler;// Sax/"xml_doctype_handler"
property * xml_signature_handler;// Sax/"xml_signature_handler"
property * xml_declaration_handler;// Sax/"xml_declaration_handler"
property * xml_cdata_handler;// Sax/"xml_cdata_handler"
property * xml_comment_handler;// Sax/"xml_comment_handler"
property * core_charset;// Sax/"core_charset"
property * file_charset;// Sax/"file_charset"
property * xml_data;// Sax/"xml_data"
property * sax;// Sax/"sax"
property * debug_doctype_handler;// Sax/"debug_doctype_handler"
property * debug_enter;// Sax/"debug_enter"
property * debug_leave;// Sax/"debug_leave"
property * sax_debug;// Sax/"sax_debug"

// module definition 
 void metaLoad();};

extern CL_EXPORT clSaxClass clSax;

#endif

