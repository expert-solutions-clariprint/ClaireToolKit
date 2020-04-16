/***** CLAIRE Compilation of file source/error.cl 
         [version 3.7.0 / safety 3] *****/

#include <claire.h>
#include <Kernel.h>
#include <Core.h>
#include <Serialize.h>
#include <Language.h>
#include <Reader.h>
#include <Db.h>
#include <clSax.h>
#include <clIconv.h>
#include <Xmlo.h>
#include <clZlib.h>

#if defined(CLPC) && !defined(CLPCNODLL)
  #undef CL_EXPORT
  #define CL_EXPORT __declspec(dllexport)
#endif
#include <Dbo.h>

#if defined(CLPC) && !defined(CLPCNODLL)
  #undef CL_EXPORT
  #define CL_EXPORT __declspec(dllimport)
#endif

#if defined(CLPC) && !defined(CLPCNODLL)
  #undef CL_EXPORT
  #define CL_EXPORT __declspec(dllexport)
#endif


/***** CLAIRE Compilation of file source/model.cl 
         [version 3.7.0 / safety 3] *****/


//
// verbosity indexes
//
// The c++ function for: dbStore?(self:any) []
CL_EXPORT ClaireBoolean * Dbo_dbStore_ask_any1_Dbo(OID self) { 
  POP_SIGNAL; return (CFALSE);}
  


// The c++ function for: dbReference?(self:any) []
CL_EXPORT ClaireBoolean * Dbo_dbReference_ask_any1_Dbo(OID self) { 
    POP_SIGNAL; return (CFALSE);}
  


//
//	Defining the database property class
//
// instanciate your slot's properties from dbProperty
// to interface them with a database
//
//	Defining the IdGenerator class (table id inheritence)
//
// The current database driver in use
//DB_DRIVER:Db/SQL_DRIVERS := Db/ACCESS
// How to setup driver
// [dbSelectDriver(driver:Db/SQL_DRIVERS) : void => DB_DRIVER := driver]
//private/DB_ID_MAP[objectClass:class, objectId:integer] : (object U {unknown}) := unknown
// list(maclasse,list(1,o,2,k)...)
// The c++ function for: nth=(self:db_id_map,c:class,oid:integer,obj:(object U {unknown})) []
CL_EXPORT void  claire_nth_equal_db_id_map1(Dbo_db_id_map *self,ClaireClass *c,CL_INT oid,OID obj) { 
    
    GC_BIND;
    { CL_INT  i = 1;
      list * l = GC_OBJECT(list,self->map);
      CL_INT  len = l->length;
      { ClaireBoolean * g0038I;
        { OID  g0039UU;
          { int loop_handle = ClEnv->cHandle;
            g0039UU= _oid_(CFALSE);
            while (((CL_INT)i < (CL_INT)len))
            { if ((*(l))[i] == _oid_(c))
               { list * ol = OBJECT(list,(*(l))[((CL_INT)i+(CL_INT)1)]);
                CL_INT  olen = ol->length;
                CL_INT  o = 1;
                { ClaireBoolean * g0040I;
                  { OID  g0041UU;
                    { int loop_handle = ClEnv->cHandle;
                      g0041UU= _oid_(CFALSE);
                      while (((CL_INT)o < (CL_INT)olen))
                      { if ((*(ol))[o] == ((OID)oid))
                         { ((*(ol))[((CL_INT)o+(CL_INT)1)]=obj);
                          { g0041UU = Kernel.ctrue;
                            ClEnv->cHandle = loop_handle;break;}
                          }
                        o= (CL_INT)(((CL_INT)o+(CL_INT)2));
                        POP_SIGNAL;}
                      }
                    g0040I = not_any(g0041UU);
                    }
                  
                  if (g0040I == CTRUE) { add_list(ol,((OID)oid));
                      add_list(ol,obj);
                      }
                    }
                { g0039UU = Kernel.ctrue;
                  ClEnv->cHandle = loop_handle;break;}
                }
              else i= (CL_INT)(((CL_INT)i+(CL_INT)2));
                POP_SIGNAL;}
            }
          g0038I = not_any(g0039UU);
          }
        
        if (g0038I == CTRUE) { add_list(l,_oid_(c));
            add_list(l,_oid_(list::alloc(Kernel._any,2,((OID)oid),obj)));
            }
          }
      }
    GC_UNBIND; POP_SIGNAL;}
  


// The c++ function for: nth(self:db_id_map,c:class,oid:integer) []
CL_EXPORT OID  claire_nth_db_id_map1(Dbo_db_id_map *self,ClaireClass *c,CL_INT oid) { 
    { OID Result = 0;
      { CL_INT  i = 1;
        list * l = self->map;
        CL_INT  len = l->length;
        OID  res = CNULL;
        { int loop_handle = ClEnv->cHandle;
          while (((res == CNULL) && 
              ((CL_INT)i < (CL_INT)len)))
          { if ((*(l))[i] == _oid_(c))
             { list * ol = OBJECT(list,(*(l))[((CL_INT)i+(CL_INT)1)]);
              CL_INT  olen = ol->length;
              CL_INT  o = 1;
              { int loop_handle = ClEnv->cHandle;
                while (((CL_INT)o < (CL_INT)olen))
                { if ((*(ol))[o] == ((OID)oid))
                   { res= ((*(ol))[((CL_INT)o+(CL_INT)1)]);
                    { ;ClEnv->cHandle = loop_handle; break;}
                    }
                  o= (CL_INT)(((CL_INT)o+(CL_INT)2));
                  POP_SIGNAL;}
                }
              { ;ClEnv->cHandle = loop_handle; break;}
              }
            i= (CL_INT)(((CL_INT)i+(CL_INT)2));
            POP_SIGNAL;}
          }
        Result = res;
        }
      POP_SIGNAL; return (Result);}
    }
  



/***** CLAIRE Compilation of file source/dbprint.cl 
         [version 3.7.0 / safety 3] *****/


//
//	printing slot value in an SQL query
//
// for an object get its id
// The c++ function for: dbPrint(db:Db/Database,self:object) []
CL_EXPORT void  Dbo_dbPrint_Database1_Dbo(Db_Database *db,ClaireObject *self) { 
    
    GC_BIND;
    if (INHERIT(NOTNULL(Kernel.isa,self->isa),Kernel._class))
     (*Dbo.dbPrint)(_oid_(db),
      GC_OID((*Dbo.dbName)(_oid_(self))));
    else { OID  idtest = GC_OID(get_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
         (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
         (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self));
        if (idtest != CNULL)
         { CL_INT  id = ((CL_INT)idtest);
          print_any(((OID)id));
          }
        else princ_string(((char*)"NULL"));
          }
      GC_UNBIND; POP_SIGNAL;}
  


// for string we use quote strings
// The c++ function for: dbPrint(db:Db/Database,self:subtype[class]) []
CL_EXPORT void  Dbo_dbPrint_Database2_Dbo(Db_Database *db,ClaireType *self) { 
    princ_string(((char*)"'"));
    print_any(_oid_(self));
    princ_string(((char*)"'"));
    POP_SIGNAL;}
  


// The c++ function for: dbPrintBag(db:Db/Database,self:bag,sep:char) []
CL_EXPORT void  Dbo_dbPrintBag_Database1(Db_Database *db,bag *self,ClaireChar *sep) { 
    
    GC_BIND;
    print_in_string_void();
    { ClaireBoolean * f = CTRUE;
      { int loop_handle = ClEnv->cHandle;
        ITERATE(i);
        for (START(self); NEXT(i);)
        { if (f == CTRUE)
           f= (CFALSE);
          else princ_char(sep);
            (*Kernel.princ)(i);
          }
        }
      (*Dbo.dbPrint)(_oid_(db),
        GC_OID(_string_(end_of_string_void())));
      }
    GC_UNBIND; POP_SIGNAL;}
  


// The c++ function for: dbPrint(db:Db/Database,self:list[string]) []
CL_EXPORT void  Dbo_dbPrint_Database3_Dbo(Db_Database *db,list *self) { 
    Dbo_dbPrintBag_Database1(db,self,OBJECT(ClaireChar,Dbo.STRING_BAG_SEP->value));
    POP_SIGNAL;}
  


// The c++ function for: dbPrint(db:Db/Database,self:set[string]) []
CL_EXPORT void  Dbo_dbPrint_Database4_Dbo(Db_Database *db,set *self) { 
    Dbo_dbPrintBag_Database1(db,self,OBJECT(ClaireChar,Dbo.STRING_BAG_SEP->value));
    POP_SIGNAL;}
  


// The c++ function for: dbPrint(db:Db/Database,self:set[float]) []
CL_EXPORT void  Dbo_dbPrint_Database5_Dbo(Db_Database *db,set *self) { 
    { ClaireBoolean * f = CTRUE;
      char * sep = ((char*)";");
      princ_string(((char*)"'"));
      { int loop_handle = ClEnv->cHandle;
        ITERATE(i);
        for (START(self); NEXT(i);)
        { if (f == CTRUE)
           f= (CFALSE);
          else princ_string(sep);
            princ_float(float_v(i));
          }
        }
      princ_string(((char*)"'"));
      }
    POP_SIGNAL;}
  


// The c++ function for: dbPrint(db:Db/Database,self:list[float]) []
CL_EXPORT void  Dbo_dbPrint_Database6_Dbo(Db_Database *db,list *self) { 
    { ClaireBoolean * f = CTRUE;
      char * sep = ((char*)";");
      princ_string(((char*)"'"));
      { int loop_handle = ClEnv->cHandle;
        ITERATE(i);
        for (START(self); NEXT(i);)
        { if (f == CTRUE)
           f= (CFALSE);
          else princ_string(sep);
            princ_float(float_v(i));
          }
        }
      princ_string(((char*)"'"));
      }
    POP_SIGNAL;}
  


// The c++ function for: dbPrint(db:Db/Database,self:list[integer]) []
CL_EXPORT void  Dbo_dbPrint_Database7_Dbo(Db_Database *db,list *self) { 
    { ClaireBoolean * f = CTRUE;
      char * sep = ((char*)";");
      princ_string(((char*)"'"));
      { int loop_handle = ClEnv->cHandle;
        ITERATE(i);
        for (START(self); NEXT(i);)
        { if (f == CTRUE)
           f= (CFALSE);
          else princ_string(sep);
            princ_integer(i);
          }
        }
      princ_string(((char*)"'"));
      }
    POP_SIGNAL;}
  


// The c++ function for: dbPrint(db:Db/Database,self:set[integer]) []
CL_EXPORT void  Dbo_dbPrint_Database8_Dbo(Db_Database *db,set *self) { 
    { ClaireBoolean * f = CTRUE;
      char * sep = ((char*)";");
      princ_string(((char*)"'"));
      { int loop_handle = ClEnv->cHandle;
        ITERATE(i);
        for (START(self); NEXT(i);)
        { if (f == CTRUE)
           f= (CFALSE);
          else princ_string(sep);
            princ_integer(i);
          }
        }
      princ_string(((char*)"'"));
      }
    POP_SIGNAL;}
  


// for string we use quote strings
// The c++ function for: dbPrint(db:Db/Database,self:string) []
CL_EXPORT void  Dbo_dbPrint_Database9_Dbo(Db_Database *db,char *self) { 
    
    GC_BIND;
    if (((OID)db->driverType) == (OID)(3))
     { princ_string(((char*)"'"));
      (*Db.dbBeginEscape)(_oid_(db),
        GC_OID(_oid_(NOTNULL(Db.currentQuery,db->currentQuery))));
      princ_string(self);
      (*Db.dbEndEscape)(_oid_(db),
        GC_OID(_oid_(NOTNULL(Db.currentQuery,db->currentQuery))));
      princ_string(((char*)"'"));
      }
    else { OID  rep1 = nth_table2(Db.SQL_TYPES,(OID)(14),((OID)db->driverType));
        OID  rep2 = nth_table2(Db.SQL_TYPES,(OID)(15),((OID)db->driverType));
        princ_string(((char*)"'"));
        char *tmp = self; while(*self) {;
        if(*self == '\'') {princ_string(string_v(rep1));
        } else if(*self == '\\') {princ_string(string_v(rep2));
        } else ClEnv->cout->put(*self);
        self++; };
        princ_string(((char*)"'"));
        }
      GC_UNBIND; POP_SIGNAL;}
  


// for string we use quote strings
// The c++ function for: dbPrint(db:Db/Database,self:integer) []
CL_EXPORT void  Dbo_dbPrint_Database10_Dbo(Db_Database *db,CL_INT self) { 
    print_any(((OID)self));
    POP_SIGNAL;}
  


// for string we use quote strings
// The c++ function for: dbPrint(g0042:Db/Database,g0043:any) []
CL_EXPORT void  Dbo_dbPrint_Database11_Dbo_(Db_Database *g0042,OID g0043) { 
    Dbo_dbPrint_Database11_Dbo(g0042,float_v(g0043));
}


// The c++ function for: dbPrint(db:Db/Database,self:float) []
CL_EXPORT void  Dbo_dbPrint_Database11_Dbo(Db_Database *db,double self) { 
      
    GC_BIND;
    if (self != self)
     { if (should_trace_ask_module1(Dbo.it,-100) == CTRUE)
       mtformat_module1(Dbo.it,((char*)"WARNING find a NaN in dbPrint@float !\n"),-100,list::empty());
      else ;princ_string(((char*)"NULL"));
      }
    else print_any(GC_OID(_float_(self)));
      GC_UNBIND; POP_SIGNAL;}
  


// for string we use quote strings
// The c++ function for: dbPrint(db:Db/Database,self:boolean) []
CL_EXPORT void  Dbo_dbPrint_Database12_Dbo(Db_Database *db,ClaireBoolean *self) { 
    princ_string(((self == CTRUE) ?
      ((char*)"1") :
      ((char*)"0") ));
    POP_SIGNAL;}
  


// for string we use quote strings
//xp rm [dbPrint(self:TimeStamp) : void => printf("'~A'", date(self, "%Y-%m-%d %H:%M:%S"))]
// a redefinable date print 
// The c++ function for: dbPrintDate(g0044:Db/Database,g0045:dbProperty,g0046:any) []
CL_EXPORT void  Dbo_dbPrintDate_Database1_Dbo_(Db_Database *g0044,Dbo_dbProperty *g0045,OID g0046) { 
    Dbo_dbPrintDate_Database1_Dbo(g0044,g0045,float_v(g0046));
}


// The c++ function for: dbPrintDate(db:Db/Database,p:dbProperty,self:float) []
CL_EXPORT void  Dbo_dbPrintDate_Database1_Dbo(Db_Database *db,Dbo_dbProperty *p,double self) { 
      if (((OID)p->dbSqlType) == (OID)(22))
     princ_string(strftime_string(string_v(nth_table2(Db.SQL_TYPES,((OID)((CL_INT)p->dbSqlType+(CL_INT)1)),((OID)db->driverType))),self));
    else { char * old = tzset_string(((char*)"UTC"));
        princ_string(strftime_string(string_v(nth_table2(Db.SQL_TYPES,((OID)((CL_INT)p->dbSqlType+(CL_INT)1)),((OID)db->driverType))),self));
        tzset_string(old);
        }
      POP_SIGNAL;}
  


// The API to use, take care of the password? status of dbProperty
// then call the simple dbPrint
// The c++ function for: dbPrintValue(db:Db/Database,self:any,p:dbProperty) []
CL_EXPORT void  Dbo_dbPrintValue_Database1(Db_Database *db,OID self,Dbo_dbProperty *p) { 
    if (self == CNULL)
     princ_string(((char*)"NULL"));
    else if (p->password_ask == CTRUE)
     { princ_string(string_v(nth_table2(Db.SQL_TYPES,(OID)(50),((OID)db->driverType))));
      princ_string(((char*)"("));
      (*Dbo.dbPrint)(_oid_(db),
        self);
      princ_string(((char*)")"));
      }
    else if ((((p->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE) && 
        (contain_ask_set(OBJECT(set,Db.SQL_DATE_TYPE->value),((OID)p->dbSqlType)) == CTRUE))
     (*Dbo.dbPrintDate)(_oid_(db),
      _oid_(p),
      self);
    else (*Dbo.dbPrint)(_oid_(db),
        self);
      POP_SIGNAL;}
  


// The c++ function for: dbPrint(db:Db/Database,self:any,p:dbProperty) []
CL_EXPORT void  Dbo_dbPrint_Database13_Dbo(Db_Database *db,OID self,Dbo_dbProperty *p) { 
    
    GC_BIND;
    Dbo_dbPrintValue_Database1(db,GC_OID((*Kernel.get)(_oid_(p),
      self)),p);
    GC_UNBIND; POP_SIGNAL;}
  


// The c++ function for: dbPrint(db:Db/Database,self:dbProperty,obj:object,p:port) []
CL_EXPORT void  Dbo_dbPrint_Database14_Dbo(Db_Database *db,Dbo_dbProperty *self,ClaireObject *obj,PortObject *p) { 
    
    GC_BIND;
    if (_equaltype_ask_any(GC_OBJECT(ClaireType,OBJECT(ClaireType,(*Kernel.range)(GC_OID(_oid_(_at_property1(self,OWNER(_oid_(obj)))))))),GC_OBJECT(ClaireType,nth_class1(Kernel._list,Kernel._string))) == CTRUE)
     (*Dbo.print_string_list)(GC_OID(get_property(self,obj)),
      _oid_(p));
    else if (self->dbSqlBlobFile_ask == CTRUE)
     { if (known_ask_property(self,obj) == CTRUE)
       fwrite_string2(((char*)"F"),p);
      }
    else if (value_string(((char*)"Zlib")) != CNULL)
     { fwrite_string2(((char*)"Z"),p);
      { buffer * z = GC_OBJECT(buffer,((buffer *) close_target_I_filter1(OBJECT(filter,(*Core.buffer_I)(GC_OID((*Core.apply)(GC_OID((*Core.get_value)(value_string(((char*)"Zlib")),
              _string_(((char*)"gziper!")))),
            _oid_(list::alloc(1,_oid_(p))))),
          ((OID)512))))));
        (*Xmlo.xml_I)(GC_OID(get_property(self,obj)),
          _oid_(z));
        fclose_port1(z);
        }
      }
    else (*Xmlo.xml_I)(GC_OID(get_property(self,obj)),
        _oid_(p));
      GC_UNBIND; POP_SIGNAL;}
  


// The c++ function for: filePath(db:Db/Database,self:dbProperty,obj:object) []
CL_EXPORT char * Dbo_filePath_Database1(Db_Database *db,Dbo_dbProperty *self,ClaireObject *obj) { 
    
    GC_BIND;
    { char *Result ;
      { char * dbfolder = GC_STRING(_7_string(GC_STRING(getenv_string(((char*)"DBO_FILE_STORE"))),GC_STRING(string_v((*Db.getDbName)(_oid_(db))))));
        char * tableFolder = GC_STRING(_7_string(dbfolder,GC_STRING(Dbo_dbName_class1(NOTNULL(Kernel.isa,obj->isa)))));
        char * propFolder = GC_STRING(_7_string(tableFolder,GC_STRING(Dbo_dbName_dbProperty1(self))));
        OID  objId = GC_OID(get_property(OBJECT(property,_oid_((INHERIT(obj->isa,Kernel._class) ?
         (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(obj))) : 
         (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) obj)))),obj));
        char * subfold = GC_STRING(_7_string(propFolder,GC_STRING(string_I_integer (((CL_INT)(*Core._sup_sup)(objId,
          ((OID)10)))))));
        char * filename = GC_STRING(append_string(GC_STRING(_7_string(subfold,GC_STRING(string_v((*Kernel.string_I)(objId))))),((char*)".gz")));
        if (isdir_ask_string(dbfolder) != CTRUE)
         mkdir_string2(dbfolder);
        else if (should_trace_ask_module1(Dbo.it,1) == CTRUE)
         mtformat_module1(Dbo.it,((char*)"dbfolder ~S ok \n"),1,list::alloc(1,_string_(dbfolder)));
        else ;if (isdir_ask_string(tableFolder) != CTRUE)
         mkdir_string2(tableFolder);
        else if (should_trace_ask_module1(Dbo.it,1) == CTRUE)
         mtformat_module1(Dbo.it,((char*)"tableFolder ~S ok \n"),1,list::alloc(1,_string_(tableFolder)));
        else ;if (isdir_ask_string(propFolder) != CTRUE)
         mkdir_string2(propFolder);
        else if (should_trace_ask_module1(Dbo.it,1) == CTRUE)
         mtformat_module1(Dbo.it,((char*)"propFolder ~S ok \n"),1,list::alloc(1,_string_(propFolder)));
        else ;if (isdir_ask_string(subfold) != CTRUE)
         mkdir_string2(subfold);
        else if (should_trace_ask_module1(Dbo.it,1) == CTRUE)
         mtformat_module1(Dbo.it,((char*)"subfold ~S ok \n"),1,list::alloc(1,_string_(subfold)));
        else ;Result = filename;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbPrintInFile(db:Db/Database,self:dbProperty,obj:object) []
CL_EXPORT void  Dbo_dbPrintInFile_Database1(Db_Database *db,Dbo_dbProperty *self,ClaireObject *obj) { 
    
    GC_BIND;
    if (isenv_ask_string(((char*)"DBO_FILE_STORE")) == CTRUE)
     { char * filename = GC_STRING(Dbo_filePath_Database1(db,self,obj));
      OID  v = GC_OID(get_property(self,obj));
      if (v != CNULL)
       { buffer * fout = GC_OBJECT(buffer,fopen_string1(filename,((char*)"w")));
        buffer * z = GC_OBJECT(buffer,((buffer *) close_target_I_filter1(buffer_I_port1(GC_OBJECT(clZlib_gziper,close_target_I_filter1(Zlib_gziper_I_port1(close_target_I_filter1(fout)))),512))));
        islocked_ask_port1(fout);
        (*Xmlo.xml_I)(GC_OID(get_property(self,obj)),
          _oid_(z));
        fclose_port1(z);
        ;}
      else if (isfile_ask_string(filename) == CTRUE)
       unlink_string(filename);
      }
    else close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"DBO_FILE_STORE is not set")),
        _oid_(Kernel.nil))));
      GC_UNBIND; POP_SIGNAL;}
  


//
//	printing SQL lists of dbProperties
//  	how to simply construct complex but readable SQL query
//
//bbn check whether the property has type BLOB
// The c++ function for: isBlob?(self:dbProperty) []
CL_EXPORT ClaireBoolean * Dbo_isBlob_ask_dbProperty1(Dbo_dbProperty *self) { 
    POP_SIGNAL; return (((((self->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE) ? ((((OID)self->dbSqlType) == (OID)(11)) ? CTRUE: CFALSE): CFALSE));}
  


// prints "prop1, ... propN"
// The c++ function for: printList(lp:list[dbProperty]) []
CL_EXPORT void  Dbo_printList_list1(list *lp) { 
    { ClaireBoolean * first_ask = CTRUE;
      { int loop_handle = ClEnv->cHandle;
        ITERATE(p);
        for (START(lp); NEXT(p);)
        { if (first_ask == CTRUE)
           first_ask= (CFALSE);
          else princ_string(((char*)", "));
            princ_string(Dbo_dbName_dbProperty1(OBJECT(Dbo_dbProperty,p)));
          }
        }
      }
    POP_SIGNAL;}
  


// prints "prop1, ... propN"
// The c++ function for: printList(lp:list[string]) []
CL_EXPORT void  Dbo_printList_list2(list *lp) { 
    { ClaireBoolean * first_ask = CTRUE;
      { int loop_handle = ClEnv->cHandle;
        ITERATE(p);
        for (START(lp); NEXT(p);)
        { if (first_ask == CTRUE)
           first_ask= (CFALSE);
          else princ_string(((char*)", "));
            princ_string(string_v(p));
          }
        }
      }
    POP_SIGNAL;}
  


// prints "value1, ... valueN"
// The c++ function for: Db/printValues(db:Db/Database,self:object,lp:list[dbProperty]) []
CL_EXPORT void  Db_printValues_Database3(Db_Database *db,ClaireObject *self,list *lp) { 
    
    GC_BIND;
    { ClaireBoolean * first_ask = CTRUE;
      { int loop_handle = ClEnv->cHandle;
        OID gc_local;
        ITERATE(p);
        for (START(lp); NEXT(p);)
        { GC_LOOP;
          { if (first_ask == CTRUE)
             first_ask= (CFALSE);
            else princ_string(((char*)", "));
              if ((((OBJECT(Dbo_dbProperty,p)->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE) && 
                (((OID)OBJECT(Dbo_dbProperty,p)->dbSqlType) == (OID)(11)))
             { if (known_ask_property(OBJECT(property,p),self) == CTRUE)
               { if ((((OID)db->driverType) == (OID)(3)) || 
                    (((OID)db->driverType) == (OID)(5)))
                 { princ_string(((char*)"'"));
                  (*Db.dbBeginEscape)(_oid_(db),
                    GC_OID(_oid_(NOTNULL(Db.currentQuery,db->currentQuery))));
                  (*Dbo.dbPrint)(_oid_(db),
                    p,
                    _oid_(self),
                    GC_OID(_oid_(NOTNULL(Db.dbPort,NOTNULL(Db.currentQuery,db->currentQuery)->dbPort))));
                  (*Db.dbEndEscape)(_oid_(db),
                    GC_OID(_oid_(NOTNULL(Db.currentQuery,db->currentQuery))));
                  princ_string(((char*)"'"));
                  }
                else princ_string(((char*)"?"));
                  }
              else princ_string(((char*)"NULL"));
                }
            else (*Dbo.dbPrint)(_oid_(db),
                _oid_(self),
                p);
              }
          GC_UNLOOP; POP_SIGNAL;}
        }
      }
    GC_UNBIND; POP_SIGNAL;}
  


// prints "prop1 = value1, ... propN = valueN"
// The c++ function for: printAffects(db:Db/Database,self:object,lp:list[dbProperty]) []
CL_EXPORT void  Dbo_printAffects_Database1(Db_Database *db,ClaireObject *self,list *lp) { 
    
    GC_BIND;
    { ClaireBoolean * first_ask = CTRUE;
      { int loop_handle = ClEnv->cHandle;
        OID gc_local;
        ITERATE(p);
        for (START(lp); NEXT(p);)
        { GC_LOOP;
          { if (first_ask == CTRUE)
             first_ask= (CFALSE);
            else princ_string(((char*)", "));
              princ_string(Dbo_dbName_dbProperty1(OBJECT(Dbo_dbProperty,p)));
            princ_string(((char*)" = "));
            if ((((OBJECT(Dbo_dbProperty,p)->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE) && 
                (((OID)OBJECT(Dbo_dbProperty,p)->dbSqlType) == (OID)(11)))
             { if (known_ask_property(OBJECT(property,p),self) == CTRUE)
               { if ((((OID)db->driverType) == (OID)(3)) || 
                    (((OID)db->driverType) == (OID)(5)))
                 { princ_string(((char*)"'"));
                  (*Db.dbBeginEscape)(_oid_(db),
                    GC_OID(_oid_(NOTNULL(Db.currentQuery,db->currentQuery))));
                  (*Dbo.dbPrint)(_oid_(db),
                    p,
                    _oid_(self),
                    GC_OID(_oid_(NOTNULL(Db.dbPort,NOTNULL(Db.currentQuery,db->currentQuery)->dbPort))));
                  (*Db.dbEndEscape)(_oid_(db),
                    GC_OID(_oid_(NOTNULL(Db.currentQuery,db->currentQuery))));
                  princ_string(((char*)"'"));
                  }
                else princ_string(((char*)"?"));
                  }
              else princ_string(((char*)"NULL"));
                }
            else (*Dbo.dbPrint)(_oid_(db),
                _oid_(self),
                p);
              }
          GC_UNLOOP; POP_SIGNAL;}
        }
      }
    GC_UNBIND; POP_SIGNAL;}
  


// The c++ function for: printAffects(db:Db/Database,lp:list[tuple(dbProperty, any)]) []
CL_EXPORT void  Dbo_printAffects_Database2(Db_Database *db,list *lp) { 
    
    GC_BIND;
    { ClaireBoolean * first_ask = CTRUE;
      { int loop_handle = ClEnv->cHandle;
        OID gc_local;
        ITERATE(p);
        for (START(lp); NEXT(p);)
        { GC_LOOP;
          { if (first_ask == CTRUE)
             first_ask= (CFALSE);
            else princ_string(((char*)", "));
              princ_string(Dbo_dbName_dbProperty1(OBJECT(Dbo_dbProperty,(*(OBJECT(bag,p)))[1])));
            princ_string(((char*)" = "));
            if ((((OBJECT(Dbo_dbProperty,(*(OBJECT(bag,p)))[1])->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE) && 
                (((OID)OBJECT(Dbo_dbProperty,(*(OBJECT(bag,p)))[1])->dbSqlType) == (OID)(11)))
             { if ((*(OBJECT(bag,p)))[2] != CNULL)
               { if ((((OID)db->driverType) == (OID)(3)) || 
                    (((OID)db->driverType) == (OID)(5)))
                 { princ_string(((char*)"'"));
                  (*Db.dbBeginEscape)(_oid_(db),
                    GC_OID(_oid_(NOTNULL(Db.currentQuery,db->currentQuery))));
                  (*Dbo.dbPrint)(_oid_(db),
                    (*(OBJECT(bag,p)))[1],
                    (*(OBJECT(bag,p)))[2],
                    GC_OID(_oid_(NOTNULL(Db.dbPort,NOTNULL(Db.currentQuery,db->currentQuery)->dbPort))));
                  (*Db.dbEndEscape)(_oid_(db),
                    GC_OID(_oid_(NOTNULL(Db.currentQuery,db->currentQuery))));
                  princ_string(((char*)"'"));
                  }
                else princ_string(((char*)"?"));
                  }
              else princ_string(((char*)"NULL"));
                }
            else if ((*(OBJECT(bag,p)))[2] == CNULL)
             princ_string(((char*)"NULL"));
            else Dbo_dbPrintValue_Database1(db,(*(OBJECT(bag,p)))[2],OBJECT(Dbo_dbProperty,(*(OBJECT(bag,p)))[1]));
              }
          GC_UNLOOP; POP_SIGNAL;}
        }
      }
    GC_UNBIND; POP_SIGNAL;}
  


// The c++ function for: printWhereAnd(db:Db/Database,lp:list[tuple(dbProperty, any)]) []
CL_EXPORT void  Dbo_printWhereAnd_Database1(Db_Database *db,list *lp) { 
    
    GC_BIND;
    { ClaireBoolean * first_ask = CTRUE;
      if (lp->length != 0)
       princ_string(((char*)" WHERE"));
      { int loop_handle = ClEnv->cHandle;
        OID gc_local;
        ITERATE(p);
        for (START(lp); NEXT(p);)
        { GC_LOOP;
          { if (first_ask == CTRUE)
             first_ask= (CFALSE);
            else princ_string(((char*)" AND"));
              if ((((OBJECT(Dbo_dbProperty,(*(OBJECT(bag,p)))[1])->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE) && 
                (((OID)OBJECT(Dbo_dbProperty,(*(OBJECT(bag,p)))[1])->dbSqlType) == (OID)(11)))
             { if ((*(OBJECT(bag,p)))[2] != CNULL)
               { if ((((OID)db->driverType) == (OID)(3)) || 
                    (((OID)db->driverType) == (OID)(5)))
                 { princ_string(((char*)"'"));
                  (*Db.dbBeginEscape)(_oid_(db),
                    GC_OID(_oid_(NOTNULL(Db.currentQuery,db->currentQuery))));
                  (*Dbo.dbPrint)(_oid_(db),
                    (*(OBJECT(bag,p)))[1],
                    (*(OBJECT(bag,p)))[2],
                    GC_OID(_oid_(NOTNULL(Db.dbPort,NOTNULL(Db.currentQuery,db->currentQuery)->dbPort))));
                  (*Db.dbEndEscape)(_oid_(db),
                    GC_OID(_oid_(NOTNULL(Db.currentQuery,db->currentQuery))));
                  princ_string(((char*)"'"));
                  }
                else princ_string(((char*)"?"));
                  }
              else princ_string(((char*)"NULL"));
                }
            else if (INHERIT(OWNER((*(OBJECT(bag,p)))[2]),Kernel._tuple))
             { princ_string(((char*)" "));
              princ_string(Dbo_dbName_dbProperty1(OBJECT(Dbo_dbProperty,(*(OBJECT(bag,p)))[1])));
              princ_string(((char*)" "));
              (*Kernel.princ)(GC_OID((*Kernel.nth)((*(OBJECT(bag,p)))[2],
                ((OID)1))));
              princ_string(((char*)" "));
              Dbo_dbPrintValue_Database1(db,GC_OID((*Kernel.nth)((*(OBJECT(bag,p)))[2],
                ((OID)2))),OBJECT(Dbo_dbProperty,(*(OBJECT(bag,p)))[1]));
              }
            else if ((INHERIT(OWNER((*(OBJECT(bag,p)))[2]),Kernel._bag)) && 
                ((CL_INT)((CL_INT)(*Kernel.length)((*(OBJECT(bag,p)))[2])) > (CL_INT)0))
             { princ_string(((char*)" "));
              princ_string(Dbo_dbName_dbProperty1(OBJECT(Dbo_dbProperty,(*(OBJECT(bag,p)))[1])));
              princ_string(((char*)" IN ("));
              { ClaireBoolean * f_ask = CTRUE;
                { int loop_handle = ClEnv->cHandle;
                  ITERATE(x);
                  bag *x_support;
                  x_support = GC_OBJECT(bag,enumerate_any((*(OBJECT(bag,p)))[2]));
                  for (START(x_support); NEXT(x);)
                  { if (f_ask == CTRUE)
                     f_ask= (CFALSE);
                    else princ_string(((char*)", "));
                      Dbo_dbPrintValue_Database1(db,x,OBJECT(Dbo_dbProperty,(*(OBJECT(bag,p)))[1]));
                    }
                  }
                }
              princ_string(((char*)")"));
              }
            else if (INHERIT(OWNER((*(OBJECT(bag,p)))[2]),Kernel._bag))
             princ_string(((char*)" 0 = 1 "));
            else if ((*(OBJECT(bag,p)))[2] == CNULL)
             { princ_string(((char*)" "));
              princ_string(Dbo_dbName_dbProperty1(OBJECT(Dbo_dbProperty,(*(OBJECT(bag,p)))[1])));
              princ_string(((char*)" IS NULL"));
              }
            else { princ_string(((char*)" "));
                princ_string(Dbo_dbName_dbProperty1(OBJECT(Dbo_dbProperty,(*(OBJECT(bag,p)))[1])));
                princ_string(((char*)" = "));
                Dbo_dbPrintValue_Database1(db,(*(OBJECT(bag,p)))[2],OBJECT(Dbo_dbProperty,(*(OBJECT(bag,p)))[1]));
                }
              }
          GC_UNLOOP; POP_SIGNAL;}
        }
      }
    GC_UNBIND; POP_SIGNAL;}
  


//
//	printing SQL lists of dbProperties definition (creating table)
//  	how to simple construct complex but readable SQL query
//
// The c++ function for: printType(db:Db/Database,self:{string}) []
CL_EXPORT void  Dbo_printType_Database1(Db_Database *db,ClaireClass *self) { 
    princ_string(Db_sqlType_integer1(12,db->driverType,200,0));
    POP_SIGNAL;}
  


// The c++ function for: printType(db:Db/Database,self:{integer}) []
CL_EXPORT void  Dbo_printType_Database2(Db_Database *db,ClaireClass *self) { 
    princ_string(((char*)"INTEGER"));
    POP_SIGNAL;}
  


//xp rm [printType(self:{TimeStamp}) : void -> princ(Db/sqlType(Db/SQL_TIMESTAMP, db.driverType, 200, 0))]
// The c++ function for: printType(db:Db/Database,self:{boolean}) []
CL_EXPORT void  Dbo_printType_Database3(Db_Database *db,ClaireClass *self) { 
    princ_string(((char*)"INTEGER"));
    POP_SIGNAL;}
  


// The c++ function for: printType(db:Db/Database,self:{float}) []
CL_EXPORT void  Dbo_printType_Database4(Db_Database *db,ClaireClass *self) { 
    princ_string(Db_sqlType_integer1(8,db->driverType,30,0));
    POP_SIGNAL;}
  


// The c++ function for: printType(db:Db/Database,self:subtype[object]) []
CL_EXPORT void  Dbo_printType_Database5(Db_Database *db,ClaireType *self) { 
    princ_string(((char*)"INTEGER"));
    POP_SIGNAL;}
  


// The c++ function for: printType(db:Db/Database,self:subtype[class]) []
CL_EXPORT void  Dbo_printType_Database6(Db_Database *db,ClaireType *self) { 
    princ_string(Db_sqlType_integer1(12,db->driverType,200,0));
    POP_SIGNAL;}
  


// The c++ function for: printType(db:Db/Database,self:subtype[Union]) []
CL_EXPORT void  Dbo_printType_Database7(Db_Database *db,ClaireType *self) { 
    princ_string(((char*)"INTEGER"));
    POP_SIGNAL;}
  


// The c++ function for: printType(db:Db/Database,self:subtype[list[((((integer U float) U char) U string) U boolean)]]) []
CL_EXPORT void  Dbo_printType_Database8(Db_Database *db,ClaireType *self) { 
    princ_string(Db_sqlType_integer1(11,db->driverType,200,0));
    POP_SIGNAL;}
  


// The c++ function for: printType(db:Db/Database,self:subtype[set[((((integer U float) U char) U string) U boolean)]]) []
CL_EXPORT void  Dbo_printType_Database9(Db_Database *db,ClaireType *self) { 
    princ_string(Db_sqlType_integer1(11,db->driverType,200,0));
    POP_SIGNAL;}
  


// The c++ function for: printFieldDefinitions(db:Db/Database,self:class,lp:list[dbProperty]) []
CL_EXPORT void  Dbo_printFieldDefinitions_Database1(Db_Database *db,ClaireClass *self,list *lp) { 
    
    GC_BIND;
    { ClaireBoolean * first_ask = CTRUE;
      { int loop_handle = ClEnv->cHandle;
        OID gc_local;
        ITERATE(p);
        for (START(lp); NEXT(p);)
        { GC_LOOP;
          { if (first_ask == CTRUE)
             first_ask= (CFALSE);
            else princ_string(((char*)",\n"));
              princ_string(((char*)"\t"));
            princ_string(Dbo_dbName_dbProperty1(OBJECT(Dbo_dbProperty,p)));
            princ_string(((char*)" "));
            if (((OBJECT(Dbo_dbProperty,p)->id_ask == CTRUE) ? CTRUE : ((OBJECT(Dbo_dbProperty,p)->autoIncrement_ask == CTRUE) ? CTRUE : CFALSE)) != CTRUE)
             { if (((OBJECT(Dbo_dbProperty,p)->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE)
               princ_string(string_v((*Db.sqlType)(((OID)OBJECT(Dbo_dbProperty,p)->dbSqlType),
                ((OID)db->driverType),
                ((OID)OBJECT(Dbo_dbProperty,p)->dbSqlPrecision),
                ((OID)OBJECT(Dbo_dbProperty,p)->dbSqlDigit))));
              else (*Dbo.printType)(_oid_(db),
                  GC_OID((*Kernel.range)(GC_OID(_oid_(_at_property1(OBJECT(property,p),self))))));
                }
            if ((get_property(Dbo.generatorId,OBJECT(ClaireObject,p)) == CNULL) && 
                ((OBJECT(Dbo_dbProperty,p)->id_ask == CTRUE) || 
                    (OBJECT(Dbo_dbProperty,p)->autoIncrement_ask == CTRUE)))
             { princ_string(((char*)" "));
              princ_string(string_v(nth_table2(Db.SQL_TYPES,(OID)(13),((OID)db->driverType))));
              princ_string(((char*)" NOT NULL"));
              }
            else if (OBJECT(Dbo_dbProperty,p)->null_ask != CTRUE)
             princ_string(((char*)" NOT NULL"));
            else ;}
          GC_UNLOOP; POP_SIGNAL;}
        }
      }
    GC_UNBIND; POP_SIGNAL;}
  



/***** CLAIRE Compilation of file source/create.cl 
         [version 3.7.0 / safety 3] *****/


//
// The c++ function for: dbCreateSimple(db:Db/Database,self:object,updateIdMap?:boolean,dbSimpleProps:list[dbProperty]) []
CL_EXPORT ClaireBoolean * Dbo_dbCreateSimple_Database1(Db_Database *db,ClaireObject *self,ClaireBoolean *updateIdMap_ask,list *dbSimpleProps) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbCreateSimple(self = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(1,_oid_(self)));
    else ;if ((db->autoStartTransaction_ask == CTRUE) && 
        (db->onTransaction_ask != CTRUE))
     Db_beginTransaction_Database1(db);
    { ClaireBoolean *Result ;
      { OID  idProp = _oid_((INHERIT(self->isa,Kernel._class) ?
         (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
         (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)));
        OID  dbAutoIncrementProperties = GC_OID(_oid_((INHERIT(self->isa,Kernel._class) ?
         (ClaireObject *) Dbo_getAutoIncrementProperties_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
         (ClaireObject *)  Dbo_getAutoIncrementProperties_object1((ClaireObject *) self))));
        CL_INT  lastId = 0;
        CL_INT  nParam = 1;
        list * Params = list::empty(Kernel._any);
        ClaireBoolean * prepare_ask;
        { ClaireBoolean *v_and;
          { v_and = db->shouldPrepare_ask;
            if (v_and == CFALSE) prepare_ask =CFALSE; 
            else { { OID  g0049UU;
                { int loop_handle = ClEnv->cHandle;
                  ITERATE(i);
                  g0049UU= Kernel.cfalse;
                  for (START(dbSimpleProps); NEXT(i);)
                  if ((((OBJECT(Dbo_dbProperty,i)->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE) && 
                      ((((OID)OBJECT(Dbo_dbProperty,i)->dbSqlType) == (OID)(11)) && 
                        (known_ask_property(OBJECT(property,i),self) == CTRUE)))
                   { g0049UU = Kernel.ctrue;
                    ClEnv->cHandle = loop_handle;break;}
                  }
                v_and = boolean_I_any(g0049UU);
                }
              if (v_and == CFALSE) prepare_ask =CFALSE; 
              else prepare_ask = CTRUE;}
            }
          }
        ClaireBoolean * sequence_ask = ((LENGTH_STRING(string_v(nth_table2(Db.SQL_TYPES,(OID)(-1),((OID)db->driverType)))) == 0) ? CTRUE : CFALSE);
        OID  seqId = CNULL;
        if (sequence_ask == CTRUE)
         { Db_printInQuery_Database1(db);
          princ_string(((char*)"SELECT "));
          princ_string(string_v((*Dbo.dbName)(_oid_(self))));
          princ_string(((char*)"_seq.nextval()"));
          if (Db_fetch_Database1(db) == CTRUE)
           { OID  val = GC_OID(Db_field_Database2(db,1));
            if (val != CNULL)
             { Db_popQuery_Database1(db);
              seqId= ((*Kernel.integer_I)(val));
              }
            else close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"Could not create an id from sequence")),
                _oid_(Kernel.nil))));
              }
          }
        Db_printInQuery_Database1(db);
        princ_string(((char*)"INSERT INTO "));
        princ_string(string_v((*Dbo.dbName)(_oid_(self))));
        if (dbSimpleProps->length != 0)
         { princ_string(((char*)" ("));
          if (sequence_ask == CTRUE)
           { (*Dbo.dbPrint)(_oid_(db),
              idProp);
            princ_string(((char*)","));
            }
          Dbo_printList_list1(dbSimpleProps);
          princ_string(((char*)") VALUES ("));
          if (sequence_ask == CTRUE)
           { print_any(seqId);
            princ_string(((char*)","));
            }
          Db_printValues_Database3(db,self,dbSimpleProps);
          princ_string(((char*)")"));
          }
        else ;if (prepare_ask == CTRUE)
         { Db_prepare_Database2(db);
          if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
           { list * g0050UU;
            { OID v_bag;
              GC_ANY(g0050UU= list::empty(Kernel.emptySet));
              { CL_INT  V_CL0051;{ list * g0052UU;
                  { bag * i_in = dbSimpleProps;
                    list * i_out = ((list *) empty_bag(i_in));
                    { int loop_handle = ClEnv->cHandle;
                      ITERATE(i);
                      for (START(i_in); NEXT(i);)
                      if ((((OBJECT(Dbo_dbProperty,i)->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE) && 
                          ((((OID)OBJECT(Dbo_dbProperty,i)->dbSqlType) == (OID)(11)) && 
                            (known_ask_property(OBJECT(property,i),self) == CTRUE)))
                       i_out->addFast((OID)i);
                      }
                    g0052UU = GC_OBJECT(list,i_out);
                    }
                  V_CL0051 = g0052UU->length;
                  }
                
                v_bag=((OID)V_CL0051);}
              ((list *) g0050UU)->addFast((OID)v_bag);}
            mtformat_module1(Dbo.it,((char*)"bind params(~S) \n"),((CL_INT)(OID)(1)),g0050UU);
            }
          else ;{ CL_INT  i = 1;
            CL_INT  g0047 = dbSimpleProps->length;
            { int loop_handle = ClEnv->cHandle;
              OID gc_local;
              while (((CL_INT)i <= (CL_INT)g0047))
              { GC_LOOP;
                if ((((OBJECT(Dbo_dbProperty,(*(dbSimpleProps))[i])->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE) && 
                    ((((OID)OBJECT(Dbo_dbProperty,(*(dbSimpleProps))[i])->dbSqlType) == (OID)(11)) && 
                      (known_ask_property(OBJECT(property,(*(dbSimpleProps))[i]),self) == CTRUE)))
                 { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                   mtformat_module1(Dbo.it,((char*)"bind params(~S, ~S) \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(2,(*(dbSimpleProps))[i],((OID)nParam))));
                  else ;Db_bindParam_Database1(db,nParam);
                  Params= (Params->addFast((OID)_oid_(tuple::alloc(2,((OID)nParam),(*(dbSimpleProps))[i]))));
                  ++nParam;
                  }
                ++i;
                GC_UNLOOP;POP_SIGNAL;}
              }
            }
          claire_execute_Database2(db);
          }
        if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
         mtformat_module1(Dbo.it,((char*)"fill params(~S) \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(1,((OID)((CL_INT)nParam-(CL_INT)1)))));
        else ;{ CL_INT  i = 1;
          CL_INT  g0048 = ((CL_INT)nParam-(CL_INT)1);
          { int loop_handle = ClEnv->cHandle;
            OID gc_local;
            while (((CL_INT)i <= (CL_INT)g0048))
            { GC_LOOP;
              { tuple * t = GC_OBJECT(tuple,Db_nextParam_Database1(db)->copyIfNeeded());
                OID  t1;
                { { OID  t1_some = CNULL;
                    { int loop_handle = ClEnv->cHandle;
                      OID gc_local;
                      ITERATE(t1);
                      for (START(Params); NEXT(t1);)
                      { GC_LOOP;
                        if ((*Kernel.nth)(t1,
                          ((OID)1)) == (*(t))[1])
                         { t1_some= (t1);
                          GC_UNLOOP;ClEnv->cHandle = loop_handle; break;}
                        GC_UNLOOP; POP_SIGNAL;}
                      }
                    t1 = t1_some;
                    }
                  GC_OID(t1);}
                if (t1 != CNULL)
                 (*Dbo.dbPrint)(_oid_(db),
                  GC_OID((*Kernel.nth)(t1,
                    ((OID)2))),
                  _oid_(self),
                  (*(t))[2]);
                else ;}
              ++i;
              GC_UNLOOP;POP_SIGNAL;}
            }
          }
        if (Db_endOfQuery_Database1(db) != 1)
         { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
           mtformat_module1(Dbo.it,((char*)"dbCreateSimple error (0 row affected)\n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::empty()));
          else ;Result = CFALSE;
          }
        else { lastId= (CL_INT)(((sequence_ask == CTRUE) ?
              ((CL_INT)seqId) :
              ((CL_INT)(*Dbo.getLastId)(_oid_(db),
                _oid_(self))) ));
            write_property(OBJECT(property,idProp),self,((OID)lastId));
            if (updateIdMap_ask == CTRUE)
             claire_nth_equal_db_id_map1(OBJECT(Dbo_db_id_map,Dbo.DB_ID_MAP->value),OWNER(_oid_(self)),lastId,_oid_(self));
            { int loop_handle = ClEnv->cHandle;
              OID gc_local;
              ITERATE(autoIncrementProp);
              for (START(OBJECT(bag,dbAutoIncrementProperties)); NEXT(autoIncrementProp);)
              { GC_LOOP;
                write_property(OBJECT(property,autoIncrementProp),self,GC_OID((*Dbo.getLastAutoIncrementedField)(_oid_(db),
                  _oid_(self),
                  autoIncrementProp)));
                GC_UNLOOP; POP_SIGNAL;}
              }
            Dbo_storeBlobFiles_Database1(db,self,dbSimpleProps);
            if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
             mtformat_module1(Dbo.it,((char*)"dbCreateSimple ok (1 row affected) -> id = ~S \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(1,GC_OID(get_property(OBJECT(property,idProp),self)))));
            else ;Result = CTRUE;
            }
          }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// ok!
// The c++ function for: storeBlobFiles(db:Db/Database,self:object,dbSimpleProps:list[dbProperty]) []
CL_EXPORT void  Dbo_storeBlobFiles_Database1(Db_Database *db,ClaireObject *self,list *dbSimpleProps) { 
    { int loop_handle = ClEnv->cHandle;
      ITERATE(prop);
      for (START(dbSimpleProps); NEXT(prop);)
      if (OBJECT(Dbo_dbProperty,prop)->dbSqlBlobFile_ask == CTRUE)
       Dbo_dbPrintInFile_Database1(db,OBJECT(Dbo_dbProperty,prop),self);
      }
    POP_SIGNAL;}
  


// The c++ function for: dbCreateWithGenerator(db:Db/Database,self:object,dbProps:list[dbProperty]) []
CL_EXPORT ClaireBoolean * Dbo_dbCreateWithGenerator_Database1(Db_Database *db,ClaireObject *self,list *dbProps) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbCreateWithGenerator(self = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(1,_oid_(self)));
    else ;if ((db->autoStartTransaction_ask == CTRUE) && 
        (db->onTransaction_ask != CTRUE))
     Db_beginTransaction_Database1(db);
    { ClaireBoolean *Result ;
      { OID  idProp = _oid_((INHERIT(self->isa,Kernel._class) ?
         (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
         (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)));
        OID  dbAutoIncrementProperties = GC_OID(_oid_((INHERIT(self->isa,Kernel._class) ?
         (ClaireObject *) Dbo_getAutoIncrementProperties_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
         (ClaireObject *)  Dbo_getAutoIncrementProperties_object1((ClaireObject *) self))));
        OID  tmpGen = GC_OID((*Core.NEW)(GC_OID(_oid_(NOTNULL(Dbo.idGenerator,OBJECT(Dbo_dbProperty,idProp)->idGenerator)))));
        CL_INT  lastId = 0;
        CL_INT  nParam = 1;
        list * Params = list::empty(Kernel._any);
        ClaireBoolean * prepare_ask;
        { ClaireBoolean *v_and;
          { v_and = db->shouldPrepare_ask;
            if (v_and == CFALSE) prepare_ask =CFALSE; 
            else { { OID  g0055UU;
                { int loop_handle = ClEnv->cHandle;
                  ITERATE(i);
                  g0055UU= Kernel.cfalse;
                  for (START(dbProps); NEXT(i);)
                  if ((((OBJECT(Dbo_dbProperty,i)->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE) && 
                      ((((OID)OBJECT(Dbo_dbProperty,i)->dbSqlType) == (OID)(11)) && 
                        (known_ask_property(OBJECT(property,i),self) == CTRUE)))
                   { g0055UU = Kernel.ctrue;
                    ClEnv->cHandle = loop_handle;break;}
                  }
                v_and = boolean_I_any(g0055UU);
                }
              if (v_and == CFALSE) prepare_ask =CFALSE; 
              else prepare_ask = CTRUE;}
            }
          }
        write_property(Dbo.generatorClass,OBJECT(ClaireObject,tmpGen),_oid_(OWNER(_oid_(self))));
        if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
         mtformat_module1(Dbo.it,((char*)"dbCreateWithGenerator for class ~S \n"),((CL_INT)(OID)(1)),list::alloc(1,GC_OID((*Dbo.generatorClass)(tmpGen))));
        else ;if (Dbo_dbCreateSimple_Database1(db,OBJECT(ClaireObject,tmpGen),CFALSE,GC_OBJECT(list,OBJECT(list,_oid_((INHERIT(OWNER(tmpGen),Kernel._class) ?
         (ClaireObject *) Dbo_getSimpleProperties_class1((ClaireClass *) OBJECT(ClaireClass,tmpGen)) : 
         (ClaireObject *)  Dbo_getSimpleProperties_object1((ClaireObject *) OBJECT(ClaireObject,tmpGen))))))) != CTRUE)
         { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
           mtformat_module1(Dbo.it,((char*)"dbCreateWithGenerator error, can't create a row for ~S \n"),((CL_INT)(OID)(1)),list::alloc(1,GC_OID(_oid_(_at_property1(Dbo.idGenerator,OWNER(_oid_(self)))))));
          else ;Result = CFALSE;
          }
        else { lastId= (CL_INT)(((CL_INT)get_property(Dbo.generatorId,OBJECT(ClaireObject,tmpGen))));
            write_property(OBJECT(property,idProp),self,((OID)lastId));
            Db_printInQuery_Database1(db);
            princ_string(((char*)"INSERT INTO "));
            princ_string(string_v((*Dbo.dbName)(_oid_(self))));
            if (dbProps->length != 0)
             { princ_string(((char*)" ("));
              Dbo_printList_list1(dbProps);
              princ_string(((char*)") VALUES ("));
              Db_printValues_Database3(db,self,dbProps);
              princ_string(((char*)")"));
              }
            else ;if (prepare_ask == CTRUE)
             { Db_prepare_Database2(db);
              if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
               { list * g0056UU;
                { OID v_bag;
                  GC_ANY(g0056UU= list::empty(Kernel.emptySet));
                  { CL_INT  V_CL0057;{ list * g0058UU;
                      { bag * i_in = dbProps;
                        list * i_out = ((list *) empty_bag(i_in));
                        { int loop_handle = ClEnv->cHandle;
                          ITERATE(i);
                          for (START(i_in); NEXT(i);)
                          if ((((OID)OBJECT(Dbo_dbProperty,i)->dbSqlType) == (OID)(11)) && 
                              (known_ask_property(OBJECT(property,i),self) == CTRUE))
                           i_out->addFast((OID)i);
                          }
                        g0058UU = GC_OBJECT(list,i_out);
                        }
                      V_CL0057 = g0058UU->length;
                      }
                    
                    v_bag=((OID)V_CL0057);}
                  ((list *) g0056UU)->addFast((OID)v_bag);}
                mtformat_module1(Dbo.it,((char*)"bind params(~S) \n"),((CL_INT)(OID)(1)),g0056UU);
                }
              else ;{ CL_INT  i = 1;
                CL_INT  g0053 = dbProps->length;
                { int loop_handle = ClEnv->cHandle;
                  OID gc_local;
                  while (((CL_INT)i <= (CL_INT)g0053))
                  { GC_LOOP;
                    if ((((OID)OBJECT(Dbo_dbProperty,(*(dbProps))[i])->dbSqlType) == (OID)(11)) && 
                        (known_ask_property(OBJECT(property,(*(dbProps))[i]),self) == CTRUE))
                     { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                       mtformat_module1(Dbo.it,((char*)"bind params(~S, ~S) \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(2,(*(dbProps))[i],((OID)nParam))));
                      else ;Db_bindParam_Database1(db,nParam);
                      Params= (Params->addFast((OID)_oid_(tuple::alloc(2,((OID)nParam),(*(dbProps))[i]))));
                      ++nParam;
                      }
                    ++i;
                    GC_UNLOOP;POP_SIGNAL;}
                  }
                }
              claire_execute_Database2(db);
              }
            if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
             mtformat_module1(Dbo.it,((char*)"fill params(~S) \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(1,((OID)((CL_INT)nParam-(CL_INT)1)))));
            else ;{ CL_INT  i = 1;
              CL_INT  g0054 = ((CL_INT)nParam-(CL_INT)1);
              { int loop_handle = ClEnv->cHandle;
                OID gc_local;
                while (((CL_INT)i <= (CL_INT)g0054))
                { GC_LOOP;
                  { tuple * t = GC_OBJECT(tuple,Db_nextParam_Database1(db)->copyIfNeeded());
                    OID  t1;
                    { { OID  t1_some = CNULL;
                        { int loop_handle = ClEnv->cHandle;
                          OID gc_local;
                          ITERATE(t1);
                          for (START(Params); NEXT(t1);)
                          { GC_LOOP;
                            if ((*Kernel.nth)(t1,
                              ((OID)1)) == (*(t))[1])
                             { t1_some= (t1);
                              GC_UNLOOP;ClEnv->cHandle = loop_handle; break;}
                            GC_UNLOOP; POP_SIGNAL;}
                          }
                        t1 = t1_some;
                        }
                      GC_OID(t1);}
                    if (t1 != CNULL)
                     (*Dbo.dbPrint)(_oid_(db),
                      GC_OID((*Kernel.nth)(t1,
                        ((OID)2))),
                      _oid_(self),
                      (*(t))[2]);
                    else ;}
                  ++i;
                  GC_UNLOOP;POP_SIGNAL;}
                }
              }
            if (Db_endOfQuery_Database1(db) != 1)
             { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
               mtformat_module1(Dbo.it,((char*)"dbCreateWithGenerator error (0 row affected)\n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::empty()));
              else ;Result = CFALSE;
              }
            else { claire_nth_equal_db_id_map1(OBJECT(Dbo_db_id_map,Dbo.DB_ID_MAP->value),OWNER(_oid_(self)),lastId,_oid_(self));
                { int loop_handle = ClEnv->cHandle;
                  OID gc_local;
                  ITERATE(autoIncrementProp);
                  for (START(OBJECT(bag,dbAutoIncrementProperties)); NEXT(autoIncrementProp);)
                  { GC_LOOP;
                    write_property(OBJECT(property,autoIncrementProp),self,GC_OID((*Dbo.getLastAutoIncrementedField)(_oid_(db),
                      _oid_(self),
                      autoIncrementProp)));
                    GC_UNLOOP; POP_SIGNAL;}
                  }
                if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                 mtformat_module1(Dbo.it,((char*)"dbCreateWithGenerator ok (1 row affected) -> id = ~S \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(1,GC_OID(get_property(OBJECT(property,idProp),self)))));
                else ;Dbo_storeBlobFiles_Database1(db,self,dbProps);
                Result = CTRUE;
                }
              }
          }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// ok!
// How to create a row in database from an object
// The c++ function for: dbCreate(db:Db/Database,self:object,props:list[dbProperty]) []
CL_EXPORT ClaireBoolean * Dbo_dbCreate_Database1(Db_Database *db,ClaireObject *self,list *props) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbCreate(self = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(1,_oid_(self)));
    else ;if (INHERIT(NOTNULL(Kernel.isa,self->isa),Kernel._class))
     close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"Can't create object ~S in database")),
      _oid_(list::alloc(1,_oid_(self))))));
    { ClaireBoolean *Result ;
      { OID  idProp = _oid_((INHERIT(self->isa,Kernel._class) ?
         (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
         (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)));
        if (known_ask_property(OBJECT(property,idProp),self) == CTRUE)
         close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"Try to create in database an object (~S) of class ~S that already has a known id (~S)")),
          _oid_(list::alloc(3,_oid_(self),
            _oid_(OWNER(_oid_(self))),
            GC_OID(get_property(OBJECT(property,idProp),self)))))));
        Result = ((OBJECT(Dbo_dbProperty,idProp)->idGenerator == (NULL)) ?
          Dbo_dbCreateSimple_Database1(db,self,CTRUE,props) :
          Dbo_dbCreateWithGenerator_Database1(db,self,GC_OBJECT(list,add_list(props,idProp))) );
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbCreate(db:Db/Database,self:object) []
CL_EXPORT ClaireBoolean * Dbo_dbCreate_Database2(Db_Database *db,ClaireObject *self) { 
    
    GC_BIND;
    { ClaireBoolean *Result ;
      Result = Dbo_dbCreate_Database1(db,self,GC_OBJECT(list,OBJECT(list,_oid_((INHERIT(self->isa,Kernel._class) ?
       (ClaireObject *) Dbo_getSimpleProperties_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
       (ClaireObject *)  Dbo_getSimpleProperties_object1((ClaireObject *) self))))));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  



/***** CLAIRE Compilation of file source/delete.cl 
         [version 3.7.0 / safety 3] *****/


// delete an id from a table
// The c++ function for: dbDelete(db:Db/Database,self:class,id:integer) []
CL_EXPORT ClaireBoolean * Dbo_dbDelete_Database1(Db_Database *db,ClaireClass *self,CL_INT id) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbDelete(class = ~S, id = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),((OID)id)));
    else ;{ ClaireBoolean *Result ;
      { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(self);
        Db_printInQuery_Database1(db);
        princ_string(((char*)"DELETE FROM "));
        princ_string(Dbo_dbName_class1(self));
        princ_string(((char*)" WHERE "));
        princ_string(Dbo_dbName_dbProperty1(idProp));
        princ_string(((char*)"="));
        princ_integer(id);
        if (Db_endOfQuery_Database1(db) == 1)
         { if (((idProp->idGenerator == (NULL)) ? CTRUE : CFALSE) != CTRUE)
           { Db_printInQuery_Database1(db);
            princ_string(((char*)"DELETE FROM "));
            princ_string(string_v((*Dbo.dbName)(GC_OID(_oid_(NOTNULL(Dbo.idGenerator,idProp->idGenerator))))));
            princ_string(((char*)" WHERE "));
            princ_string(Dbo_dbName_dbProperty1(Dbo.generatorId));
            princ_string(((char*)"="));
            princ_integer(id);
            Db_endOfQuery_Database1(db);
            }
          { OID  objtest = GC_OID(claire_nth_db_id_map1(OBJECT(Dbo_db_id_map,Dbo.DB_ID_MAP->value),self,id));
            if (objtest != CNULL)
             { ClaireObject * obj = OBJECT(ClaireObject,objtest);
              erase_property(Dbo_getIdProperty_class1(self),obj);
              claire_nth_equal_db_id_map1(OBJECT(Dbo_db_id_map,Dbo.DB_ID_MAP->value),self,id,CNULL);
              Result = CTRUE;
              }
            else Result = CFALSE;
              }
          }
        else Result = CFALSE;
          }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbDelete(db:Db/Database,self:class,id:string) []
CL_EXPORT ClaireBoolean * Dbo_dbDelete_Database2(Db_Database *db,ClaireClass *self,char *id) { 
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbDelete(self = ~S, id = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_string_(id)));
    else ;POP_SIGNAL; return (Dbo_dbDelete_Database1(db,self,integer_I_string(id)));}
  


// delete an object from its table in the given database
// The c++ function for: dbDelete(db:Db/Database,self:object) []
CL_EXPORT ClaireBoolean * Dbo_dbDelete_Database3(Db_Database *db,ClaireObject *self) { 
    
    GC_BIND;
    { ClaireBoolean *Result ;
      { ClaireObject *V_CC ;
        { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
           mtformat_module1(Dbo.it,((char*)"dbDelete(self = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(1,_oid_(self)));
          else ;{ OID  idtest = GC_OID(get_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
             (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
             (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self));
            if (idtest != CNULL)
             { CL_INT  id = ((CL_INT)idtest);
              V_CC = Dbo_dbDelete_Database1(db,OWNER(_oid_(self)),id);
              }
            else close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"Can't delete object ~S of class ~S since its id is unknown!")),
                _oid_(list::alloc(2,_oid_(self),_oid_(OWNER(_oid_(self))))))));
              }
          }
        Result= (ClaireBoolean *) V_CC;}
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// delete from a table where ...
// The c++ function for: dbDelete(db:Db/Database,self:class,wheres:list[tuple(dbProperty, any)]) []
CL_EXPORT CL_INT  Dbo_dbDelete_Database4(Db_Database *db,ClaireClass *self,list *wheres) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbDelete(class = ~S, wheres = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_oid_(wheres)));
    else ;{ CL_INT Result = 0;
      { CL_INT  count = 0;
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          ITERATE(c);
          for (START(self->descendents); NEXT(c);)
          { GC_LOOP;
            if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(c))) == CTRUE)
             { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(OBJECT(ClaireClass,c));
              Db_printInQuery_Database1(db);
              princ_string(((char*)"SELECT "));
              princ_string(Dbo_dbName_dbProperty1(idProp));
              princ_string(((char*)" FROM "));
              princ_string(Dbo_dbName_class1(OBJECT(ClaireClass,c)));
              princ_string(((char*)" "));
              Dbo_printWhereAnd_Database1(db,wheres);
              { int loop_handle = ClEnv->cHandle;
                OID gc_local;
                while ((Db_fetch_Database1(db) == CTRUE))
                { GC_LOOP;
                  { OID  id = GC_OID(Db_field_Database1(db,GC_STRING(Dbo_dbName_dbProperty1(idProp))));
                    if (id != CNULL)
                     { Dbo_dbDelete_Database1(db,OBJECT(ClaireClass,c),((CL_INT)(*Kernel.integer_I)(id)));
                      ++count;
                      }
                    else ;}
                  GC_UNLOOP;POP_SIGNAL;}
                }
              }
            GC_UNLOOP; POP_SIGNAL;}
          }
        Result = count;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// delete from a table where ...
// The c++ function for: dbCount(db:Db/Database,self:class) []
CL_EXPORT CL_INT  Dbo_dbCount_Database1(Db_Database *db,ClaireClass *self) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbCount(class = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(1,_oid_(self)));
    else ;{ CL_INT Result = 0;
      { CL_INT  count = 0;
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          ITERATE(c);
          for (START(self->descendents); NEXT(c);)
          { GC_LOOP;
            if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(c))) == CTRUE)
             { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(OBJECT(ClaireClass,c));
              Db_printInQuery_Database1(db);
              princ_string(((char*)"SELECT COUNT("));
              princ_string(Dbo_dbName_dbProperty1(idProp));
              princ_string(((char*)") FROM "));
              princ_string(Dbo_dbName_class1(OBJECT(ClaireClass,c)));
              if (Db_fetch_Database1(db) == CTRUE)
               { { OID  x = GC_OID(Db_field_Database2(db,1));
                  if (x != CNULL)
                   count= (CL_INT)(((CL_INT)count+(CL_INT)(((CL_INT)(*Kernel.integer_I)(x)))));
                  else ;}
                Db_popQuery_Database1(db);
                }
              }
            GC_UNLOOP; POP_SIGNAL;}
          }
        Result = count;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// delete from a table where ...
// The c++ function for: dbCount(db:Db/Database,self:class,wheres:list[tuple(dbProperty, any)]) []
CL_EXPORT CL_INT  Dbo_dbCount_Database2(Db_Database *db,ClaireClass *self,list *wheres) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbCount(class = ~S, wheres = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_oid_(wheres)));
    else ;{ CL_INT Result = 0;
      { CL_INT  count = 0;
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          ITERATE(c);
          for (START(self->descendents); NEXT(c);)
          { GC_LOOP;
            if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(c))) == CTRUE)
             { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(OBJECT(ClaireClass,c));
              Db_printInQuery_Database1(db);
              princ_string(((char*)"SELECT COUNT("));
              princ_string(Dbo_dbName_dbProperty1(idProp));
              princ_string(((char*)") FROM "));
              princ_string(Dbo_dbName_class1(OBJECT(ClaireClass,c)));
              Dbo_printWhereAnd_Database1(db,wheres);
              if (Db_fetch_Database1(db) == CTRUE)
               { { OID  x = GC_OID(Db_field_Database2(db,1));
                  if (x != CNULL)
                   count= (CL_INT)(((CL_INT)count+(CL_INT)(((CL_INT)(*Kernel.integer_I)(x)))));
                  else ;}
                Db_popQuery_Database1(db);
                }
              }
            GC_UNLOOP; POP_SIGNAL;}
          }
        Result = count;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


//
// database LOAD[_TREE] class [WHERE property == 12 [ORDER_BY toto]]
//
// database CREATE object
//
// database UPDATE object
// database UPDATE class WHERE property == 12 VALUES pol == 78
//Where <: object(clauses:list[tuple(dbProperty,any)])
//LOAD(self:Database, whereClause:Where) : any

/***** CLAIRE Compilation of file source/dbrelationships.cl 
         [version 3.7.0 / safety 3] *****/


// The c++ function for: db_0?(self:property) []
CL_EXPORT ClaireBoolean * Dbo_db_0_ask_property1(property *self) { 
    POP_SIGNAL; return (((self->inverse == (NULL)) ? CTRUE : CFALSE));}
  


// The c++ function for: db_1-1?(self:property) []
CL_EXPORT ClaireBoolean * Dbo_db_1_dash1_ask_property1(property *self) { 
    POP_SIGNAL; return (((((self->inverse == (NULL)) ? CTRUE : CFALSE) != CTRUE) ? ((inherit_ask_class(NOTNULL(Kernel.isa,self->isa),Dbo._dbProperty) != CTRUE) ? ((INHERIT(NOTNULL(Kernel.isa,NOTNULL(Kernel.inverse,self->inverse)->isa),Dbo._dbProperty)) ? ((boolean_I_any(_oid_(self->multivalued_ask)) != CTRUE) ? ((boolean_I_any(_oid_(NOTNULL(Kernel.inverse,self->inverse)->multivalued_ask)) != CTRUE) ? CTRUE: CFALSE): CFALSE): CFALSE): CFALSE): CFALSE));}
  


// The c++ function for: db_1-1?(self:dbProperty,o:object) []
CL_EXPORT ClaireBoolean * Dbo_db_1_dash1_ask_dbProperty1(Dbo_dbProperty *self,ClaireObject *o) { 
    
    GC_BIND;
    { ClaireBoolean *Result ;
      Result = ((self->inverse == (NULL)) ? ((boolean_I_any(_oid_(self->multivalued_ask)) != CTRUE) ? ((((self->dbSqlType == (((CL_INT)(OID)(11)))) ? CTRUE : CFALSE) != CTRUE) ? ((INHERIT(owner_any((*Kernel.range)(GC_OID(_oid_(_at_property1(self,OWNER(_oid_(o))))))),Kernel._class)) ? CTRUE: CFALSE): CFALSE): CFALSE): CFALSE);
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: db_1-1?(self:property,o:object) []
CL_EXPORT ClaireBoolean * Dbo_db_1_dash1_ask_property2(property *self,ClaireObject *o) { 
    POP_SIGNAL; return (CFALSE);}
  


// The c++ function for: db_N-1?(self:property) []
CL_EXPORT ClaireBoolean * Dbo_db_N_dash1_ask_property1(property *self) { 
    POP_SIGNAL; return (((((self->inverse == (NULL)) ? CTRUE : CFALSE) != CTRUE) ? ((INHERIT(NOTNULL(Kernel.isa,NOTNULL(Kernel.inverse,self->inverse)->isa),Dbo._dbProperty)) ? ((inherit_ask_class(NOTNULL(Kernel.isa,self->isa),Dbo._dbProperty) != CTRUE) ? ((boolean_I_any(_oid_(self->multivalued_ask)) == CTRUE) ? ((boolean_I_any(_oid_(NOTNULL(Kernel.inverse,self->inverse)->multivalued_ask)) != CTRUE) ? CTRUE: CFALSE): CFALSE): CFALSE): CFALSE): CFALSE));}
  


// The c++ function for: db_1-N?(self:property) []
CL_EXPORT ClaireBoolean * Dbo_db_1_dashN_ask_property1(property *self) { 
    POP_SIGNAL; return (((((self->inverse == (NULL)) ? CTRUE : CFALSE) != CTRUE) ? ((inherit_ask_class(NOTNULL(Kernel.isa,NOTNULL(Kernel.inverse,self->inverse)->isa),Dbo._dbProperty) != CTRUE) ? ((INHERIT(NOTNULL(Kernel.isa,self->isa),Dbo._dbProperty)) ? ((boolean_I_any(_oid_(self->multivalued_ask)) != CTRUE) ? ((boolean_I_any(_oid_(NOTNULL(Kernel.inverse,self->inverse)->multivalued_ask)) == CTRUE) ? CTRUE: CFALSE): CFALSE): CFALSE): CFALSE): CFALSE));}
  


//

/***** CLAIRE Compilation of file source/update.cl 
         [version 3.7.0 / safety 3] *****/


//
// The c++ function for: dbUpdate(db:Db/Database,self:object,lp:list[dbProperty]) []
CL_EXPORT ClaireBoolean * Dbo_dbUpdate_Database1(Db_Database *db,ClaireObject *self,list *lp) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbUpdate(object = ~S, lp = (~A)) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_oid_(lp)));
    else ;if ((db->autoStartTransaction_ask == CTRUE) && 
        (db->onTransaction_ask != CTRUE))
     Db_beginTransaction_Database1(db);
    { ClaireBoolean *Result ;
      { OID  idProp = _oid_((INHERIT(self->isa,Kernel._class) ?
         (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
         (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)));
        CL_INT  nParam = 1;
        list * Params = list::empty(Kernel._any);
        ClaireBoolean * prepare_ask;
        { ClaireBoolean *v_and;
          { v_and = db->shouldPrepare_ask;
            if (v_and == CFALSE) prepare_ask =CFALSE; 
            else { { OID  g0064UU;
                { int loop_handle = ClEnv->cHandle;
                  ITERATE(i);
                  g0064UU= Kernel.cfalse;
                  for (START(lp); NEXT(i);)
                  if ((((OBJECT(Dbo_dbProperty,i)->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE) && 
                      ((((OID)OBJECT(Dbo_dbProperty,i)->dbSqlType) == (OID)(11)) && 
                        (known_ask_property(OBJECT(property,i),self) == CTRUE)))
                   { g0064UU = Kernel.ctrue;
                    ClEnv->cHandle = loop_handle;break;}
                  }
                v_and = boolean_I_any(g0064UU);
                }
              if (v_and == CFALSE) prepare_ask =CFALSE; 
              else prepare_ask = CTRUE;}
            }
          }
        { OID  idtest = GC_OID(get_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
           (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
           (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self));
          if (idtest != CNULL)
           { CL_INT  id = ((CL_INT)idtest);
            Db_printInQuery_Database1(db);
            princ_string(((char*)"UPDATE "));
            princ_string(string_v((*Dbo.dbName)(_oid_(self))));
            princ_string(((char*)" SET "));
            (*Dbo.printAffects)(_oid_(db),
              _oid_(self),
              GC_OID(_oid_(but_any(_oid_(lp),idProp))));
            princ_string(((char*)" WHERE "));
            princ_string(Dbo_dbName_dbProperty1(OBJECT(Dbo_dbProperty,idProp)));
            princ_string(((char*)"="));
            print_any(((OID)id));
            princ_string(((char*)";"));
            claire_nth_equal_db_id_map1(OBJECT(Dbo_db_id_map,Dbo.DB_ID_MAP->value),OWNER(_oid_(self)),id,_oid_(self));
            }
          else { Db_popQuery_Database1(db);
              close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"Can't update object ~S since its id is unknown")),
                _oid_(list::alloc(1,_oid_(self))))));
              }
            }
        if (prepare_ask == CTRUE)
         { Db_prepare_Database2(db);
          if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
           { list * g0065UU;
            { OID v_bag;
              GC_ANY(g0065UU= list::empty(Kernel.emptySet));
              { CL_INT  V_CL0066;{ list * g0067UU;
                  { bag * i_in = lp;
                    list * i_out = ((list *) empty_bag(i_in));
                    { int loop_handle = ClEnv->cHandle;
                      ITERATE(i);
                      for (START(i_in); NEXT(i);)
                      if ((((OBJECT(Dbo_dbProperty,i)->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE) && 
                          ((((OID)OBJECT(Dbo_dbProperty,i)->dbSqlType) == (OID)(11)) && 
                            (known_ask_property(OBJECT(property,i),self) == CTRUE)))
                       i_out->addFast((OID)i);
                      }
                    g0067UU = GC_OBJECT(list,i_out);
                    }
                  V_CL0066 = g0067UU->length;
                  }
                
                v_bag=((OID)V_CL0066);}
              ((list *) g0065UU)->addFast((OID)v_bag);}
            mtformat_module1(Dbo.it,((char*)"bind params(~S) \n"),((CL_INT)(OID)(1)),g0065UU);
            }
          else ;{ CL_INT  i = 1;
            CL_INT  g0062 = lp->length;
            { int loop_handle = ClEnv->cHandle;
              OID gc_local;
              while (((CL_INT)i <= (CL_INT)g0062))
              { GC_LOOP;
                if ((((OBJECT(Dbo_dbProperty,(*(lp))[i])->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE) && 
                    ((((OID)OBJECT(Dbo_dbProperty,(*(lp))[i])->dbSqlType) == (OID)(11)) && 
                      (known_ask_property(OBJECT(property,(*(lp))[i]),self) == CTRUE)))
                 { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                   mtformat_module1(Dbo.it,((char*)"bind params(~S, ~S) \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(2,(*(lp))[i],((OID)nParam))));
                  else ;Db_bindParam_Database1(db,nParam);
                  Params= (Params->addFast((OID)_oid_(tuple::alloc(2,((OID)nParam),(*(lp))[i]))));
                  ++nParam;
                  }
                ++i;
                GC_UNLOOP;POP_SIGNAL;}
              }
            }
          claire_execute_Database2(db);
          }
        if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
         mtformat_module1(Dbo.it,((char*)"fill params(~S) \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(1,((OID)((CL_INT)nParam-(CL_INT)1)))));
        else ;{ CL_INT  i = 1;
          CL_INT  g0063 = ((CL_INT)nParam-(CL_INT)1);
          { int loop_handle = ClEnv->cHandle;
            OID gc_local;
            while (((CL_INT)i <= (CL_INT)g0063))
            { GC_LOOP;
              { tuple * t = GC_OBJECT(tuple,Db_nextParam_Database1(db)->copyIfNeeded());
                OID  t1;
                { { OID  t1_some = CNULL;
                    { int loop_handle = ClEnv->cHandle;
                      OID gc_local;
                      ITERATE(t1);
                      for (START(Params); NEXT(t1);)
                      { GC_LOOP;
                        if ((*Kernel.nth)(t1,
                          ((OID)1)) == (*(t))[1])
                         { t1_some= (t1);
                          GC_UNLOOP;ClEnv->cHandle = loop_handle; break;}
                        GC_UNLOOP; POP_SIGNAL;}
                      }
                    t1 = t1_some;
                    }
                  GC_OID(t1);}
                if (t1 != CNULL)
                 (*Dbo.dbPrint)(_oid_(db),
                  GC_OID((*Kernel.nth)(t1,
                    ((OID)2))),
                  _oid_(self),
                  (*(t))[2]);
                else ;}
              ++i;
              GC_UNLOOP;POP_SIGNAL;}
            }
          }
        Dbo_storeBlobFiles_Database1(db,self,lp);
        Result = ((Db_endOfQuery_Database1(db) == 1) ? CTRUE : CFALSE);
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


//
// The c++ function for: dbUpdate(db:Db/Database,self:object) []
CL_EXPORT ClaireBoolean * Dbo_dbUpdate_Database2(Db_Database *db,ClaireObject *self) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbUpdate(object = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(1,_oid_(self)));
    else ;{ ClaireBoolean *Result ;
      Result = Dbo_dbUpdate_Database1(db,self,GC_OBJECT(list,OBJECT(list,_oid_((INHERIT(self->isa,Kernel._class) ?
       (ClaireObject *) Dbo_dbProperties_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
       (ClaireObject *)  Dbo_dbProperties_object1((ClaireObject *) self))))));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


//
// The c++ function for: dbUpdate(db:Db/Database,cl:class,values:list[tuple(dbProperty, any)],wheres:list[tuple(dbProperty, any)]) []
CL_EXPORT CL_INT  Dbo_dbUpdate_Database3(Db_Database *db,ClaireClass *cl,list *values,list *wheres) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbUpdate(self = ~S,values = (~A), wheres = (~A)) \n"),((CL_INT)(OID)(1)),list::alloc(3,_oid_(cl),
      _oid_(values),
      _oid_(wheres)));
    else ;if ((db->autoStartTransaction_ask == CTRUE) && 
        (db->onTransaction_ask != CTRUE))
     Db_beginTransaction_Database1(db);
    { CL_INT Result = 0;
      { ClaireBoolean * tmp = CFALSE;
        CL_INT  n = 0;
        CL_INT  nParam = 1;
        list * Params = list::empty(Kernel._any);
        list * lp = GC_OBJECT(list,append_list(values,wheres));
        ClaireBoolean * prepare_ask;
        { ClaireBoolean *v_and;
          { v_and = db->shouldPrepare_ask;
            if (v_and == CFALSE) prepare_ask =CFALSE; 
            else { { OID  g0071UU;
                { int loop_handle = ClEnv->cHandle;
                  ITERATE(i);
                  g0071UU= Kernel.cfalse;
                  for (START(lp); NEXT(i);)
                  if ((get_property(Dbo.dbSqlType,OBJECT(ClaireObject,i)) != CNULL) && 
                      ((((OID)OBJECT(Dbo_dbProperty,(*(OBJECT(bag,i)))[1])->dbSqlType) == (OID)(11)) && 
                        ((*(OBJECT(bag,i)))[2] != CNULL)))
                   { g0071UU = Kernel.ctrue;
                    ClEnv->cHandle = loop_handle;break;}
                  }
                v_and = boolean_I_any(g0071UU);
                }
              if (v_and == CFALSE) prepare_ask =CFALSE; 
              else prepare_ask = CTRUE;}
            }
          }
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          ITERATE(c);
          for (START(cl->descendents); NEXT(c);)
          { GC_LOOP;
            if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(c))) == CTRUE)
             { Db_printInQuery_Database1(db);
              princ_string(((char*)"UPDATE "));
              princ_string(Dbo_dbName_class1(OBJECT(ClaireClass,c)));
              princ_string(((char*)" SET "));
              Dbo_printAffects_Database2(db,values);
              Dbo_printWhereAnd_Database1(db,wheres);
              princ_string(((char*)";"));
              if (prepare_ask == CTRUE)
               { Db_prepare_Database2(db);
                if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                 { list * g0072UU;
                  { { OID v_bag;
                      GC_ANY(g0072UU= list::empty(Kernel.emptySet));
                      { CL_INT  V_CL0073;{ list * g0074UU;
                          { bag * i_in = lp;
                            list * i_out = ((list *) empty_bag(i_in));
                            { int loop_handle = ClEnv->cHandle;
                              ITERATE(i);
                              for (START(i_in); NEXT(i);)
                              if ((get_property(Dbo.dbSqlType,OBJECT(ClaireObject,i)) != CNULL) && 
                                  ((((OID)OBJECT(Dbo_dbProperty,(*(OBJECT(bag,i)))[1])->dbSqlType) == (OID)(11)) && 
                                    ((*(OBJECT(bag,i)))[2] != CNULL)))
                               i_out->addFast((OID)i);
                              }
                            g0074UU = GC_OBJECT(list,i_out);
                            }
                          V_CL0073 = g0074UU->length;
                          }
                        
                        v_bag=((OID)V_CL0073);}
                      ((list *) g0072UU)->addFast((OID)v_bag);}
                    GC_OBJECT(list,g0072UU);}
                  mtformat_module1(Dbo.it,((char*)"bind params(~S) \n"),((CL_INT)(OID)(1)),g0072UU);
                  }
                else ;{ CL_INT  i = 1;
                  CL_INT  g0069 = lp->length;
                  { int loop_handle = ClEnv->cHandle;
                    OID gc_local;
                    while (((CL_INT)i <= (CL_INT)g0069))
                    { GC_LOOP;
                      if ((((OBJECT(Dbo_dbProperty,(*(OBJECT(bag,(*(lp))[i])))[1])->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE) && 
                          ((((OID)OBJECT(Dbo_dbProperty,(*(OBJECT(bag,(*(lp))[i])))[1])->dbSqlType) == (OID)(11)) && 
                            ((*(OBJECT(bag,(*(lp))[i])))[2] != CNULL)))
                       { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                         mtformat_module1(Dbo.it,((char*)"bind params(~S, ~S) \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(2,(*(OBJECT(bag,(*(lp))[i])))[1],((OID)nParam))));
                        else ;Db_bindParam_Database1(db,nParam);
                        Params= (Params->addFast((OID)_oid_(tuple::alloc(2,((OID)nParam),(*(OBJECT(bag,(*(lp))[i])))[2]))));
                        ++nParam;
                        }
                      ++i;
                      GC_UNLOOP;POP_SIGNAL;}
                    }
                  }
                claire_execute_Database2(db);
                }
              if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
               mtformat_module1(Dbo.it,((char*)"fill params(~S) \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(1,((OID)((CL_INT)nParam-(CL_INT)1)))));
              else ;{ CL_INT  i = 1;
                CL_INT  g0070 = ((CL_INT)nParam-(CL_INT)1);
                { int loop_handle = ClEnv->cHandle;
                  OID gc_local;
                  while (((CL_INT)i <= (CL_INT)g0070))
                  { GC_LOOP;
                    { tuple * t = GC_OBJECT(tuple,Db_nextParam_Database1(db)->copyIfNeeded());
                      OID  t1;
                      { { OID  t1_some = CNULL;
                          { int loop_handle = ClEnv->cHandle;
                            OID gc_local;
                            ITERATE(t1);
                            for (START(Params); NEXT(t1);)
                            { GC_LOOP;
                              if ((*Kernel.nth)(t1,
                                ((OID)1)) == (*(t))[1])
                               { t1_some= (t1);
                                GC_UNLOOP;ClEnv->cHandle = loop_handle; break;}
                              GC_UNLOOP; POP_SIGNAL;}
                            }
                          t1 = t1_some;
                          }
                        GC_OID(t1);}
                      if (t1 != CNULL)
                       (*Xmlo.xml_I)(GC_OID((*Kernel.nth)(t1,
                          ((OID)2))),
                        (*(t))[2]);
                      else ;}
                    ++i;
                    GC_UNLOOP;POP_SIGNAL;}
                  }
                }
              n= (CL_INT)(((CL_INT)n+(CL_INT)Db_endOfQuery_Database1(db)));
              }
            GC_UNLOOP; POP_SIGNAL;}
          }
        Result = n;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  



/***** CLAIRE Compilation of file source/load.cl 
         [version 3.7.0 / safety 3] *****/


//
//	How to convert a string (returned in a result row) into a CLAIRE type
//		may be overwriten
//
// The c++ function for: value!(db:Db/Database,p:dbProperty,obj:object,self:port) []
CL_EXPORT OID  Dbo_value_I_Database1_Dbo(Db_Database *db,Dbo_dbProperty *p,ClaireObject *obj,PortObject *self) { 
    
    GC_BIND;
    { OID Result = 0;
      if (_equaltype_ask_any(GC_OBJECT(ClaireType,OBJECT(ClaireType,(*Kernel.range)(GC_OID(_oid_(_at_property1(p,OWNER(_oid_(obj)))))))),GC_OBJECT(ClaireType,nth_class1(Kernel._list,Kernel._string))) == CTRUE)
       Result = _oid_(Dbo_extract_string_list_port1(self));
      else if ((p->dbSqlBlobFile_ask == CTRUE) && 
          ((INHERIT(NOTNULL(Kernel.isa,self->isa),Core._blob)) && (((CL_INT)length_blob1(((blob *) self)) > (CL_INT)0) && 
              (((unsigned char) nth_blob1(((blob *) self),1)->ascii) == ((unsigned char)'F')))))
       Result = Dbo_dbReadFromFile_Database1(db,p,obj);
      else if ((value_string(((char*)"Zlib")) != CNULL) && 
          ((INHERIT(NOTNULL(Kernel.isa,self->isa),Core._blob)) && (((CL_INT)length_blob1(((blob *) self)) > (CL_INT)0) && 
              (((unsigned char) nth_blob1(((blob *) self),1)->ascii) == ((unsigned char)'Z')))))
       { getc_port1(self);
        { buffer * z = GC_OBJECT(buffer,((buffer *) close_target_I_filter1(OBJECT(filter,(*Core.buffer_I)(GC_OID((*Core.apply)(GC_OID((*Core.get_value)(value_string(((char*)"Zlib")),
                _string_(((char*)"gziper!")))),
              _oid_(list::alloc(1,_oid_(self))))),
            ((OID)512))))));
          OID  x = GC_OID(Xmlo_unXml_I_port1(z));
          fclose_port1(z);
          Result = x;
          }
        }
      else Result = Xmlo_unXml_I_port1(self);
        GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: value!(db:Db/Database,self:string,rg:subtype[class]) []
CL_EXPORT OID  Dbo_value_I_Database2_Dbo(Db_Database *db,char *self,ClaireType *rg) { 
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(3))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"value!(string = ~S, rg = ~S) \n"),((CL_INT)(OID)(3)),list::alloc(2,_string_(self),_oid_(rg)));
    else ;POP_SIGNAL; return ((*Dbo.getObjectFromId)(_oid_(db),
      _oid_(rg),
      ((OID)integer_I_string(self))));}
  


// The c++ function for: value!(db:Db/Database,self:string,rg:subtype[object]) []
CL_EXPORT OID  Dbo_value_I_Database3_Dbo(Db_Database *db,char *self,ClaireType *rg) { 
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(3))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"value!(string = ~S, rg = ~S) \n"),((CL_INT)(OID)(3)),list::alloc(2,_string_(self),_oid_(rg)));
    else ;POP_SIGNAL; return ((*Dbo.getObjectFromId)(_oid_(db),
      _oid_(rg),
      ((OID)integer_I_string(self))));}
  


// The c++ function for: value!(db:Db/Database,self:string,rg:{string}) []
CL_EXPORT char * Dbo_value_I_Database4_Dbo(Db_Database *db,char *self,ClaireClass *rg) { 
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(3))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"value!(string = ~S, rg = ~S) \n"),((CL_INT)(OID)(3)),list::alloc(2,_string_(self),_oid_(rg)));
    else ;POP_SIGNAL; return (self);}
  


// The c++ function for: value!(db:Db/Database,self:string,rg:{char}) []
CL_EXPORT ClaireChar * Dbo_value_I_Database5_Dbo(Db_Database *db,char *self,ClaireClass *rg) { 
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(3))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"value!(string = ~S, rg = ~S) \n"),((CL_INT)(OID)(3)),list::alloc(2,_string_(self),_oid_(rg)));
    else ;POP_SIGNAL; return (_char_(self[1 - 1]));}
  


// The c++ function for: value!(db:Db/Database,self:string,rg:{integer}) []
CL_EXPORT CL_INT  Dbo_value_I_Database6_Dbo(Db_Database *db,char *self,ClaireClass *rg) { 
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(3))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"value!(string = ~S, rg = ~S) \n"),((CL_INT)(OID)(3)),list::alloc(2,_string_(self),_oid_(rg)));
    else ;POP_SIGNAL; return (integer_I_string(self));}
  


// The c++ function for: value!(g0075:Db/Database,g0076:string,g0077:{float}) []
CL_EXPORT OID  Dbo_value_I_Database7_Dbo_(Db_Database *g0075,char *g0076,ClaireClass *g0077) { 
    return _float_(Dbo_value_I_Database7_Dbo(g0075,g0076,g0077));
}


// The c++ function for: value!(db:Db/Database,self:string,rg:{float}) []
CL_EXPORT double  Dbo_value_I_Database7_Dbo(Db_Database *db,char *self,ClaireClass *rg) { 
      if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(3))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"value!(string = ~S, rg = ~S) \n"),((CL_INT)(OID)(3)),list::alloc(2,_string_(self),_oid_(rg)));
    else ;POP_SIGNAL; return (float_I_string(self));}
  


// The c++ function for: value!(db:Db/Database,self:string,rg:{boolean}) []
CL_EXPORT ClaireBoolean * Dbo_value_I_Database8_Dbo(Db_Database *db,char *self,ClaireClass *rg) { 
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(3))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"value!(string = ~S, rg = ~S) \n"),((CL_INT)(OID)(3)),list::alloc(2,_string_(self),_oid_(rg)));
    else ;POP_SIGNAL; return (equal(((OID)integer_I_string(self)),((OID)1)));}
  


// The c++ function for: set_value!(db:Db/Database,self:string,rg:any) []
CL_EXPORT OID  Dbo_set_value_I_Database1(Db_Database *db,char *self,OID rg) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(3))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"value!(string = ~S, rg = ~S) \n"),((CL_INT)(OID)(3)),list::alloc(2,_string_(self),rg));
    else ;{ OID Result = 0;
      Result = _oid_(set_I_bag(GC_OBJECT(list,explode_string(self,GC_STRING(string_I_char1(OBJECT(ClaireChar,Dbo.STRING_BAG_SEP->value)))))));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: list_value!(db:Db/Database,self:string,rg:any) []
CL_EXPORT OID  Dbo_list_value_I_Database1(Db_Database *db,char *self,OID rg) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(3))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"value!(string = ~S, rg = ~S) \n"),((CL_INT)(OID)(3)),list::alloc(2,_string_(self),rg));
    else ;{ OID Result = 0;
      Result = _oid_(explode_string(self,GC_STRING(string_I_char1(OBJECT(ClaireChar,Dbo.STRING_BAG_SEP->value)))));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbReadFromFile(db:Db/Database,self:dbProperty,obj:object) []
CL_EXPORT OID  Dbo_dbReadFromFile_Database1(Db_Database *db,Dbo_dbProperty *self,ClaireObject *obj) { 
    
    GC_BIND;
    { OID Result = 0;
      { char * filename = GC_STRING(Dbo_filePath_Database1(db,self,obj));
        if (should_trace_ask_module1(Dbo.it,1) == CTRUE)
         mtformat_module1(Dbo.it,((char*)"dbReadFromFile ~S \n"),1,list::alloc(1,_string_(filename)));
        else ;if (isfile_ask_string(filename) == CTRUE)
         { buffer * fin = GC_OBJECT(buffer,fopen_string1(filename,((char*)"r")));
          buffer * z;
          { { filter *V_CC ;
              { islocked_ask_port1(fin);
                V_CC = (buffer *)close_target_I_filter1(buffer_I_port1(GC_OBJECT(clZlib_gziper,close_target_I_filter1(Zlib_gziper_I_port1(close_target_I_filter1(fin)))),512));
                }
              z= (buffer *) V_CC;}
            GC_OBJECT(buffer,z);}
          OID  x = GC_OID(Xmlo_unXml_I_port1(z));
          fclose_port1(z);
          Result = x;
          }
        else Result = CNULL;
          }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: make_utc_date(g0078:string) []
CL_EXPORT OID  Dbo_make_utc_date_string1_(char *g0078) { 
    return _float_(Dbo_make_utc_date_string1(g0078));
}


// The c++ function for: make_utc_date(self:string) []
CL_EXPORT double  Dbo_make_utc_date_string1(char *self) { 
      { double Result =0.0;
      { char * old = tzset_string(((char*)"UTC"));
        double  res = make_date_string(self);
        tzset_string(old);
        Result = res;
        }
      POP_SIGNAL; return (Result);}
    }
  


//
//	How to create a new object from a result row
//
// update a list of slot's values from a row
// if NULL -> unknown
// if dbSqlType is set in a dbProperty convertion is simple
// if not set try an auto convertion, one may override "value!"
// to implement his own convertion routine
// The c++ function for: updateValuesFromRow(db:Db/Database,self:object,idProp:dbProperty,lp:list[dbProperty]) []
CL_EXPORT void  Dbo_updateValuesFromRow_Database1(Db_Database *db,ClaireObject *self,Dbo_dbProperty *idProp,list *lp) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(3))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"updateValuesFromRow(object = ~S, lp = ~A) \n"),((CL_INT)(OID)(3)),list::alloc(2,_oid_(self),_oid_(lp)));
    else ;{ ClaireClass * selfOwner = OWNER(_oid_(self));
      { int loop_handle = ClEnv->cHandle;
        OID gc_local;
        ITERATE(prop);
        for (START(lp); NEXT(prop);)
        { GC_LOOP;
          { OID  val = GC_OID(Db_field_Database1(db,GC_STRING(Dbo_dbName_dbProperty1(OBJECT(Dbo_dbProperty,prop)))));
            if (val != CNULL)
             { OID  clval;
              { { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                   mtformat_module1(Dbo.it,((char*)"update property ~S with ~S \n"),((CL_INT)(OID)(1)),list::alloc(2,prop,val));
                  else ;if (INHERIT(OWNER(val),Kernel._port))
                   clval = (*Dbo.value_I)(_oid_(db),
                    prop,
                    _oid_(self),
                    val);
                  else if ((((OBJECT(Dbo_dbProperty,prop)->dbSqlType == (((CL_INT)CNULL))) ? CTRUE : CFALSE) != CTRUE) && 
                      (contain_ask_set(OBJECT(set,Db.SQL_DATE_TYPE->value),((OID)OBJECT(Dbo_dbProperty,prop)->dbSqlType)) == CTRUE))
                   { if (((OID)OBJECT(Dbo_dbProperty,prop)->dbSqlType) == (OID)(22))
                     clval = (*Kernel.make_date)(val);
                    else clval = (*Dbo.make_utc_date)(val);
                      }
                  else if (_inf_equal_type(GC_OBJECT(ClaireType,OBJECT(ClaireType,(*Kernel.range)(GC_OID(_oid_(_at_property1(OBJECT(property,prop),selfOwner)))))),GC_OBJECT(ClaireType,nth_class1(Kernel._list,Kernel._string))) == CTRUE)
                   clval = (*Kernel.explode)(val,
                    GC_OID(_string_(string_I_char1(OBJECT(ClaireChar,Dbo.STRING_BAG_SEP->value)))));
                  else if (_inf_equal_type(GC_OBJECT(ClaireType,OBJECT(ClaireType,(*Kernel.range)(GC_OID(_oid_(_at_property1(OBJECT(property,prop),selfOwner)))))),GC_OBJECT(ClaireType,nth_class1(Kernel._set,Kernel._string))) == CTRUE)
                   clval = _oid_(set_I_bag(GC_OBJECT(list,OBJECT(list,(*Kernel.explode)(val,
                    GC_OID(_string_(string_I_char1(OBJECT(ClaireChar,Dbo.STRING_BAG_SEP->value)))))))));
                  else if (_inf_equal_type(GC_OBJECT(ClaireType,OBJECT(ClaireType,(*Kernel.range)(GC_OID(_oid_(_at_property1(OBJECT(property,prop),selfOwner)))))),GC_OBJECT(ClaireType,nth_class1(Kernel._list,Kernel._integer))) == CTRUE)
                   { list * V_CL0079;{ list * x_bag = list::empty(Kernel.emptySet);
                      { int loop_handle = ClEnv->cHandle;
                        ITERATE(x);
                        bag *x_support;
                        x_support = GC_OBJECT(list,OBJECT(bag,(*Kernel.explode)(val,
                          _string_(((char*)";")))));
                        for (START(x_support); NEXT(x);)
                        x_bag->addFast((OID)((OID)integer_I_string(string_v(x))));
                        }
                      V_CL0079 = GC_OBJECT(list,x_bag);
                      }
                    
                    clval=_oid_(V_CL0079);}
                  else if (_inf_equal_type(GC_OBJECT(ClaireType,OBJECT(ClaireType,(*Kernel.range)(GC_OID(_oid_(_at_property1(OBJECT(property,prop),selfOwner)))))),GC_OBJECT(ClaireType,nth_class1(Kernel._set,Kernel._integer))) == CTRUE)
                   { set * V_CL0080;{ set * x_bag = set::empty(Kernel.emptySet);
                      { int loop_handle = ClEnv->cHandle;
                        ITERATE(x);
                        bag *x_support;
                        x_support = GC_OBJECT(list,OBJECT(bag,(*Kernel.explode)(val,
                          _string_(((char*)";")))));
                        for (START(x_support); NEXT(x);)
                        x_bag->addFast((OID)((OID)integer_I_string(string_v(x))));
                        }
                      V_CL0080 = GC_OBJECT(set,x_bag);
                      }
                    
                    clval=_oid_(V_CL0080);}
                  else if (_inf_equal_type(GC_OBJECT(ClaireType,OBJECT(ClaireType,(*Kernel.range)(GC_OID(_oid_(_at_property1(OBJECT(property,prop),selfOwner)))))),GC_OBJECT(ClaireType,nth_class1(Kernel._list,Kernel._float))) == CTRUE)
                   { list * V_CL0081;{ list * x_bag = list::empty(Kernel.emptySet);
                      { int loop_handle = ClEnv->cHandle;
                        OID gc_local;
                        ITERATE(x);
                        bag *x_support;
                        x_support = GC_OBJECT(list,OBJECT(bag,(*Kernel.explode)(val,
                          _string_(((char*)";")))));
                        for (START(x_support); NEXT(x);)
                        { GC_LOOP;
                          x_bag->addFast((OID)GC_OID(_float_(float_I_string(string_v(x)))));
                          GC_UNLOOP; POP_SIGNAL;}
                        }
                      V_CL0081 = GC_OBJECT(list,x_bag);
                      }
                    
                    clval=_oid_(V_CL0081);}
                  else if (_inf_equal_type(GC_OBJECT(ClaireType,OBJECT(ClaireType,(*Kernel.range)(GC_OID(_oid_(_at_property1(OBJECT(property,prop),selfOwner)))))),GC_OBJECT(ClaireType,nth_class1(Kernel._set,Kernel._float))) == CTRUE)
                   { set * V_CL0082;{ set * x_bag = set::empty(Kernel.emptySet);
                      { int loop_handle = ClEnv->cHandle;
                        OID gc_local;
                        ITERATE(x);
                        bag *x_support;
                        x_support = GC_OBJECT(list,OBJECT(bag,(*Kernel.explode)(val,
                          _string_(((char*)";")))));
                        for (START(x_support); NEXT(x);)
                        { GC_LOOP;
                          x_bag->addFast((OID)GC_OID(_float_(float_I_string(string_v(x)))));
                          GC_UNLOOP; POP_SIGNAL;}
                        }
                      V_CL0082 = GC_OBJECT(set,x_bag);
                      }
                    
                    clval=_oid_(V_CL0082);}
                  else clval = (*Dbo.value_I)(_oid_(db),
                      val,
                      GC_OID((*Kernel.range)(GC_OID(_oid_(_at_property1(OBJECT(property,prop),selfOwner))))));
                    }
                GC_OID(clval);}
              if (clval != CNULL)
               write_property(OBJECT(property,prop),self,clval);
              else erase_property(OBJECT(property,prop),self);
                }
            else erase_property(OBJECT(property,prop),self);
              }
          GC_UNLOOP; POP_SIGNAL;}
        }
      { OID  id = GC_OID(get_property(idProp,self));
        if (id != CNULL)
         (*Kernel.nth_equal)(Dbo.DB_ID_MAP->value,
          _oid_(selfOwner),
          id,
          _oid_(self));
        else ;}
      }
    GC_UNBIND; POP_SIGNAL;}
  


// construct a list 
// The c++ function for: loadObjectListFromRows(db:Db/Database,self:class,idProp:dbProperty,lp:list[dbProperty]) []
CL_EXPORT list * Dbo_loadObjectListFromRows_Database1(Db_Database *db,ClaireClass *self,Dbo_dbProperty *idProp,list *lp) { 
    
    GC_RESERVE(3);  // v3.3.39 optim !
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(3))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"loadObjectListFromRows(class = ~S, lp = ~A) \n"),((CL_INT)(OID)(3)),list::alloc(2,_oid_(self),_oid_(lp)));
    else ;{ list *Result ;
      { list * resultList = cast_I_list1(list::empty(),self);
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          while ((Db_fetch_Database1(db) == CTRUE))
          { GC_LOOP;
            { OID  obj = CNULL;
              { OID  id = GC_OID(Db_field_Database1(db,GC_STRING(Dbo_dbName_dbProperty1(idProp))));
                if (id != CNULL)
                 { OID  tmpobjtest = GC_OID(Dbo_lookForObjectWithId_class1(self,((CL_INT)(*Kernel.integer_I)(id))));
                  if (tmpobjtest != CNULL)
                   { ClaireObject * tmpobj = OBJECT(ClaireObject,tmpobjtest);
                    GC__OID(obj = _oid_(tmpobj), 1);
                    }
                  else GC__OID(obj = _oid_(new_class1(self)), 2);
                    }
                else close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"unknown id field while loading a list of object")),
                    _oid_(Kernel.nil))));
                  }
              (*Dbo.updateValuesFromRow)(_oid_(db),
                obj,
                _oid_(idProp),
                _oid_(lp));
              GC__ANY(resultList = add_list(resultList,obj), 3);
              }
            GC_UNLOOP;POP_SIGNAL;}
          }
        Result = resultList;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: Dbo_loadObjectListFromRows_Database1_type
CL_EXPORT ClaireType * Dbo_loadObjectListFromRows_Database1_type(ClaireType *db,ClaireType *self,ClaireType *idProp,ClaireType *lp) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


//
//	dbLoad - load a single object from an id
//
// load from an id all dbProperties of an object
// The c++ function for: dbLoad(db:Db/Database,self:object,id:integer,lp:list[dbProperty]) []
CL_EXPORT ClaireBoolean * Dbo_dbLoad_Database1(Db_Database *db,ClaireObject *self,CL_INT id,list *lp) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(object = ~S, id = ~S, lp = (~A)) \n"),((CL_INT)(OID)(1)),list::alloc(3,_oid_(self),
      ((OID)id),
      _oid_(lp)));
    else ;{ ClaireBoolean *Result ;
      { list * lpCopy = cast_I_list1(((list *) copy_bag(lp)),Dbo._dbProperty);
        OID  idProp = _oid_((INHERIT(self->isa,Kernel._class) ?
         (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
         (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)));
        if (lpCopy->memq(idProp) != CTRUE)
         lpCopy= (GC_OBJECT(list,add_list(lpCopy,idProp)));
        Db_printInQuery_Database1(db);
        if ((((OID)db->driverType) == (OID)(3)) || 
            (((OID)db->driverType) == (OID)(5)))
         { princ_string(((char*)"SELECT "));
          Dbo_printList_list1(lpCopy);
          princ_string(((char*)" FROM "));
          princ_string(string_v((*Dbo.dbName)(_oid_(self))));
          princ_string(((char*)" WHERE "));
          princ_string(Dbo_dbName_dbProperty1(OBJECT(Dbo_dbProperty,idProp)));
          princ_string(((char*)"="));
          print_any(((OID)id));
          princ_string(((char*)" LIMIT 1;"));
          }
        else { princ_string(((char*)"SELECT TOP 1 "));
            Dbo_printList_list1(lpCopy);
            princ_string(((char*)" FROM "));
            princ_string(string_v((*Dbo.dbName)(_oid_(self))));
            princ_string(((char*)" WHERE "));
            princ_string(Dbo_dbName_dbProperty1(OBJECT(Dbo_dbProperty,idProp)));
            princ_string(((char*)"="));
            print_any(((OID)id));
            princ_string(((char*)";"));
            }
          if (Db_fetch_Database1(db) == CTRUE)
         { Dbo_updateValuesFromRow_Database1(db,self,OBJECT(Dbo_dbProperty,idProp),lpCopy);
          Db_popQuery_Database1(db);
          Result = CTRUE;
          }
        else Result = CFALSE;
          }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbLoad(db:Db/Database,self:object,id:string,lp:list[dbProperty]) []
CL_EXPORT ClaireBoolean * Dbo_dbLoad_Database2(Db_Database *db,ClaireObject *self,char *id,list *lp) { 
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(object = ~S, id = ~S, lp = (~A)) \n"),((CL_INT)(OID)(1)),list::alloc(3,_oid_(self),
      _string_(id),
      _oid_(lp)));
    else ;POP_SIGNAL; return (OBJECT(ClaireBoolean,(*Dbo.dbLoad)(_oid_(db),
      _oid_(self),
      ((OID)integer_I_string(id)),
      _oid_(lp))));}
  


// load from an id all dbProperties of an object
// The c++ function for: dbLoad(db:Db/Database,self:object,id:integer) []
CL_EXPORT ClaireBoolean * Dbo_dbLoad_Database3(Db_Database *db,ClaireObject *self,CL_INT id) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(object = ~S, id = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),((OID)id)));
    else ;{ ClaireBoolean *Result ;
      Result = OBJECT(ClaireBoolean,(*Dbo.dbLoad)(_oid_(db),
        _oid_(self),
        ((OID)id),
        GC_OID(_oid_((INHERIT(self->isa,Kernel._class) ?
         (ClaireObject *) Dbo_dbProperties_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
         (ClaireObject *)  Dbo_dbProperties_object1((ClaireObject *) self))))));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbLoad(db:Db/Database,self:object,id:string) []
CL_EXPORT ClaireBoolean * Dbo_dbLoad_Database4(Db_Database *db,ClaireObject *self,char *id) { 
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(object = ~S, id = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_string_(id)));
    else ;POP_SIGNAL; return (OBJECT(ClaireBoolean,(*Dbo.dbLoad)(_oid_(db),
      _oid_(self),
      ((OID)integer_I_string(id)))));}
  


// load properties of object assuming its id set
// The c++ function for: dbLoad(db:Db/Database,self:object,lp:list[dbProperty]) []
CL_EXPORT ClaireBoolean * Dbo_dbLoad_Database5(Db_Database *db,ClaireObject *self,list *lp) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(object = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(1,_oid_(self)));
    else ;{ ClaireBoolean *Result ;
      { OID  idProp = _oid_((INHERIT(self->isa,Kernel._class) ?
         (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
         (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)));
        if (unknown_ask_property(OBJECT(property,idProp),self) == CTRUE)
         close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"Try to load an object with unknown id")),
          _oid_(Kernel.nil))));
        Result = OBJECT(ClaireBoolean,(*Dbo.dbLoad)(_oid_(db),
          _oid_(self),
          GC_OID(get_property(OBJECT(property,idProp),self)),
          _oid_(lp)));
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// load all dbProperties of an assuming its id set
// The c++ function for: dbLoad(db:Db/Database,self:object) []
CL_EXPORT ClaireBoolean * Dbo_dbLoad_Database6(Db_Database *db,ClaireObject *self) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(object = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(1,_oid_(self)));
    else ;{ ClaireBoolean *Result ;
      Result = OBJECT(ClaireBoolean,(*Dbo.dbLoad)(_oid_(db),
        _oid_(self),
        GC_OID(_oid_((INHERIT(self->isa,Kernel._class) ?
         (ClaireObject *) Dbo_dbProperties_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
         (ClaireObject *)  Dbo_dbProperties_object1((ClaireObject *) self))))));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


//
//	dbLoad - load a single object of a class from an id
//
// load from a class and an id a list of dbProperty values
// The c++ function for: dbLoad(db:Db/Database,self:class,id:integer,lp:list[dbProperty]) []
CL_EXPORT OID  Dbo_dbLoad_Database7(Db_Database *db,ClaireClass *self,CL_INT id,list *lp) { 
    
    GC_RESERVE(1);  // v3.3.39 optim !
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(class = ~S, id = ~S, lp = (~A)) \n"),((CL_INT)(OID)(1)),list::alloc(3,_oid_(self),
      ((OID)id),
      _oid_(lp)));
    else ;{ OID Result = 0;
      { OID  objtest = GC_OID(Dbo_lookForObjectWithId_class1(self,id));
        if (objtest != CNULL)
         { ClaireObject * obj = OBJECT(ClaireObject,objtest);
          (*Dbo.dbLoad)(_oid_(db),
            _oid_(obj),
            ((OID)id),
            _oid_(lp));
          Result = _oid_(obj);
          }
        else { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(self);
            list * lpCopy = cast_I_list1(((list *) copy_bag(lp)),Dbo._dbProperty);
            OID  obj = CNULL;
            if (lpCopy->memq(_oid_(idProp)) != CTRUE)
             lpCopy= (GC_OBJECT(list,add_list(lpCopy,_oid_(idProp))));
            if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
             { list * g0085UU;
              { OID v_bag;
                GC_ANY(g0085UU= list::empty(Kernel.emptySet));
                { list * V_CL0086;{ list * g0083_out = list::empty(Kernel.emptySet);
                    { int loop_handle = ClEnv->cHandle;
                      ITERATE(g0083);
                      for (START(self->descendents); NEXT(g0083);)
                      if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(g0083))) == CTRUE)
                       g0083_out->addFast((OID)g0083);
                      }
                    V_CL0086 = GC_OBJECT(list,g0083_out);
                    }
                  
                  v_bag=_oid_(V_CL0086);}
                ((list *) g0085UU)->addFast((OID)v_bag);}
              mtformat_module1(Dbo.it,((char*)"getDbDescendents -> ~A \n"),((CL_INT)(OID)(1)),g0085UU);
              }
            else ;{ int loop_handle = ClEnv->cHandle;
              OID gc_local;
              ITERATE(c);
              for (START(self->descendents); NEXT(c);)
              { GC_LOOP;
                if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(c))) == CTRUE)
                 { Db_printInQuery_Database1(db);
                  if ((((OID)db->driverType) == (OID)(3)) || 
                      (((OID)db->driverType) == (OID)(5)))
                   { princ_string(((char*)"SELECT "));
                    Dbo_printList_list1(lpCopy);
                    princ_string(((char*)" FROM "));
                    princ_string(Dbo_dbName_class1(OBJECT(ClaireClass,c)));
                    princ_string(((char*)" WHERE "));
                    princ_string(Dbo_dbName_dbProperty1(idProp));
                    princ_string(((char*)"="));
                    print_any(((OID)id));
                    princ_string(((char*)" LIMIT 1;"));
                    }
                  else { princ_string(((char*)"SELECT TOP 1 "));
                      Dbo_printList_list1(lpCopy);
                      princ_string(((char*)" FROM "));
                      princ_string(Dbo_dbName_class1(OBJECT(ClaireClass,c)));
                      princ_string(((char*)" WHERE "));
                      princ_string(Dbo_dbName_dbProperty1(idProp));
                      princ_string(((char*)"="));
                      print_any(((OID)id));
                      princ_string(((char*)";"));
                      }
                    if (Db_fetch_Database1(db) == CTRUE)
                   { GC__OID(obj = _oid_(new_class1(OBJECT(ClaireClass,c))), 1);
                    (*Dbo.updateValuesFromRow)(_oid_(db),
                      obj,
                      _oid_(idProp),
                      _oid_(lpCopy));
                    Db_popQuery_Database1(db);
                    { ;GC_UNLOOP;ClEnv->cHandle = loop_handle; break;}
                    }
                  }
                GC_UNLOOP; POP_SIGNAL;}
              }
            Result = obj;
            }
          }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: Dbo_dbLoad_Database7_type
CL_EXPORT ClaireType * Dbo_dbLoad_Database7_type(ClaireType *db,ClaireType *self,ClaireType *id,ClaireType *lp) { 
    POP_SIGNAL; return (member_type(self));}
  


// The c++ function for: dbLoad(db:Db/Database,self:class,id:string,lp:list[dbProperty]) []
CL_EXPORT OID  Dbo_dbLoad_Database8(Db_Database *db,ClaireClass *self,char *id,list *lp) { 
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(class = ~S, id = ~S, lp = (~A)) \n"),((CL_INT)(OID)(1)),list::alloc(3,_oid_(self),
      _string_(id),
      _oid_(lp)));
    else ;POP_SIGNAL; return (Dbo_dbLoad_Database7(db,self,integer_I_string(id),lp));}
  


// The c++ function for: Dbo_dbLoad_Database8_type
CL_EXPORT ClaireType * Dbo_dbLoad_Database8_type(ClaireType *db,ClaireType *self,ClaireType *id,ClaireType *lp) { 
    POP_SIGNAL; return (member_type(self));}
  


// load from an id all dbProperties of a class
// The c++ function for: dbLoad(db:Db/Database,self:class,id:integer) []
CL_EXPORT OID  Dbo_dbLoad_Database9(Db_Database *db,ClaireClass *self,CL_INT id) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(class = ~S, id = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),((OID)id)));
    else ;{ OID Result = 0;
      Result = Dbo_dbLoad_Database7(db,self,id,GC_OBJECT(list,Dbo_dbProperties_class1(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: Dbo_dbLoad_Database9_type
CL_EXPORT ClaireType * Dbo_dbLoad_Database9_type(ClaireType *db,ClaireType *self,ClaireType *id) { 
    POP_SIGNAL; return (member_type(self));}
  


// The c++ function for: dbLoad(db:Db/Database,self:class,id:string) []
CL_EXPORT OID  Dbo_dbLoad_Database10(Db_Database *db,ClaireClass *self,char *id) { 
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(class = ~S, id = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_string_(id)));
    else ;POP_SIGNAL; return (Dbo_dbLoad_Database9(db,self,integer_I_string(id)));}
  


// The c++ function for: Dbo_dbLoad_Database10_type
CL_EXPORT ClaireType * Dbo_dbLoad_Database10_type(ClaireType *db,ClaireType *self,ClaireType *id) { 
    POP_SIGNAL; return (member_type(self));}
  


//
//	dbLoad - load multiple object from a class (optionnaly sort them according to a dbProperty)
//
// generic: load objects from a class with the following options
// 	   - topCount : max number of object in the return list
//     - sortProp : when known, specify a sort order according to the property field and order direction (asc?)
// The c++ function for: dbLoad(db:Db/Database,self:class,lp:list[dbProperty],topCount:integer,sortProp:(dbProperty U {unknown}),asc?:boolean) []
CL_EXPORT list * Dbo_dbLoad_Database11(Db_Database *db,ClaireClass *self,list *lp,CL_INT topCount,OID sortProp,ClaireBoolean *asc_ask) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(class = ~S, lp = (~A), sortProp = ~S, asc? = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(4,_oid_(self),
      _oid_(lp),
      sortProp,
      _oid_(asc_ask)));
    else ;{ list *Result ;
      { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(self);
        list * lpCopy = cast_I_list1(((list *) copy_bag(lp)),Dbo._dbProperty);
        list * res = cast_I_list1(list::empty(),self);
        if (lpCopy->length == 0)
         lpCopy= (GC_OBJECT(list,Dbo_dbProperties_class1(self)));
        if (lpCopy->memq(_oid_(idProp)) != CTRUE)
         lpCopy= (GC_OBJECT(list,add_list(lpCopy,_oid_(idProp))));
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          ITERATE(c);
          for (START(self->descendents); NEXT(c);)
          { GC_LOOP;
            if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(c))) == CTRUE)
             { Db_printInQuery_Database1(db);
              princ_string(((char*)"SELECT "));
              if (((CL_INT)topCount > (CL_INT)0) && 
                  ((((OID)db->driverType) != (OID)(3)) && 
                    (((OID)db->driverType) != (OID)(5))))
               { princ_string(((char*)"TOP "));
                print_any(((OID)topCount));
                princ_string(((char*)" "));
                }
              Dbo_printList_list1(lpCopy);
              princ_string(((char*)" FROM "));
              princ_string(Dbo_dbName_class1(OBJECT(ClaireClass,c)));
              { OID  proptest = sortProp;
                if (proptest != CNULL)
                 { Dbo_dbProperty * prop = OBJECT(Dbo_dbProperty,proptest);
                  princ_string(((char*)" ORDER BY "));
                  princ_string(Dbo_dbName_dbProperty1(prop));
                  princ_string(((char*)" "));
                  princ_string(((asc_ask == CTRUE) ?
                    ((char*)"ASC") :
                    ((char*)"DESC") ));
                  }
                else ;}
              princ_string(((char*)" "));
              if (((CL_INT)topCount > (CL_INT)0) && 
                  ((((OID)db->driverType) == (OID)(3)) || 
                      (((OID)db->driverType) == (OID)(5))))
               { princ_string(((char*)"LIMIT "));
                print_any(((OID)topCount));
                princ_string(((char*)" "));
                }
              princ_string(((char*)";"));
              { int loop_handle = ClEnv->cHandle;
                ITERATE(i);
                bag *i_support;
                i_support = GC_OBJECT(list,Dbo_loadObjectListFromRows_Database1(db,OBJECT(ClaireClass,c),idProp,lpCopy));
                for (START(i_support); NEXT(i);)
                res= (add_list(res,i));
                }
              }
            GC_UNLOOP; POP_SIGNAL;}
          }
        Result = res;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: Dbo_dbLoad_Database11_type
CL_EXPORT ClaireType * Dbo_dbLoad_Database11_type(ClaireType *db,ClaireType *self,ClaireType *lp,ClaireType *topCount,ClaireType *sortProp,ClaireType *asc_ask) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// generic: load objects from a class with the following options
// 	   - topCount : max number of object in the return list
//     - sortProp : when known, specify a sort order according to the property field and order direction (asc?)
// The c++ function for: dbLoad(db:Db/Database,self:class,lp:list[dbProperty],topCount:integer,sortProp:(dbProperty U {unknown}),asc?:boolean,wheres:list[tuple(dbProperty, any)]) []
CL_EXPORT list * Dbo_dbLoad_Database12(Db_Database *db,ClaireClass *self,list *lp,CL_INT topCount,OID sortProp,ClaireBoolean *asc_ask,list *wheres) { 
    POP_SIGNAL; return (Dbo_dbLoadWhere_Database1(db,
      self,
      lp,
      topCount,
      sortProp,
      asc_ask,
      wheres));}
  


// The c++ function for: Dbo_dbLoad_Database12_type
CL_EXPORT ClaireType * Dbo_dbLoad_Database12_type(ClaireType *db,ClaireType *self,ClaireType *lp,ClaireType *topCount,ClaireType *sortProp,ClaireType *asc_ask,ClaireType *wheres) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbLoadWhere(db:Db/Database,self:class,lp:list[dbProperty],topCount:integer,sortProp:(dbProperty U {unknown}),asc?:boolean,wheres:list) []
CL_EXPORT list * Dbo_dbLoadWhere_Database1(Db_Database *db,ClaireClass *self,list *lp,CL_INT topCount,OID sortProp,ClaireBoolean *asc_ask,list *wheres) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(class = ~S, lp = (~A), sortProp = ~S, asc? = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(4,_oid_(self),
      _oid_(lp),
      sortProp,
      _oid_(asc_ask)));
    else ;{ list *Result ;
      { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(self);
        list * lpCopy = cast_I_list1(((list *) copy_bag(lp)),Dbo._dbProperty);
        list * res = cast_I_list1(list::empty(),self);
        if (lpCopy->length == 0)
         lpCopy= (GC_OBJECT(list,Dbo_dbProperties_class1(self)));
        if (lpCopy->memq(_oid_(idProp)) != CTRUE)
         lpCopy= (GC_OBJECT(list,add_list(lpCopy,_oid_(idProp))));
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          ITERATE(c);
          for (START(self->descendents); NEXT(c);)
          { GC_LOOP;
            if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(c))) == CTRUE)
             { Db_printInQuery_Database1(db);
              princ_string(((char*)"SELECT "));
              if (((CL_INT)topCount > (CL_INT)0) && 
                  ((((OID)db->driverType) != (OID)(3)) && 
                    (((OID)db->driverType) != (OID)(5))))
               { princ_string(((char*)"TOP "));
                print_any(((OID)topCount));
                princ_string(((char*)" "));
                }
              Dbo_printList_list1(lpCopy);
              princ_string(((char*)" FROM "));
              princ_string(Dbo_dbName_class1(OBJECT(ClaireClass,c)));
              princ_string(((char*)" "));
              (*Dbo.printWhereAnd)(_oid_(db),
                _oid_(wheres));
              princ_string(((char*)" "));
              { OID  proptest = sortProp;
                if (proptest != CNULL)
                 { Dbo_dbProperty * prop = OBJECT(Dbo_dbProperty,proptest);
                  princ_string(((char*)" ORDER BY "));
                  princ_string(Dbo_dbName_dbProperty1(prop));
                  princ_string(((char*)" "));
                  princ_string(((asc_ask == CTRUE) ?
                    ((char*)"ASC") :
                    ((char*)"DESC") ));
                  }
                else ;}
              princ_string(((char*)" "));
              if (((CL_INT)topCount > (CL_INT)0) && 
                  ((((OID)db->driverType) == (OID)(3)) || 
                      (((OID)db->driverType) == (OID)(5))))
               { princ_string(((char*)"LIMIT "));
                print_any(((OID)topCount));
                princ_string(((char*)" "));
                }
              princ_string(((char*)";"));
              { int loop_handle = ClEnv->cHandle;
                ITERATE(i);
                bag *i_support;
                i_support = GC_OBJECT(list,Dbo_loadObjectListFromRows_Database1(db,OBJECT(ClaireClass,c),idProp,lpCopy));
                for (START(i_support); NEXT(i);)
                res= (add_list(res,i));
                }
              }
            GC_UNLOOP; POP_SIGNAL;}
          }
        Result = res;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: Dbo_dbLoadWhere_Database1_type
CL_EXPORT ClaireType * Dbo_dbLoadWhere_Database1_type(ClaireType *db,ClaireType *self,ClaireType *lp,ClaireType *topCount,ClaireType *sortProp,ClaireType *asc_ask,ClaireType *wheres) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


//
//	dbLoad - loading all dbProperties of a class
//
// The c++ function for: dbLoad(db:Db/Database,self:class) []
CL_EXPORT list * Dbo_dbLoad_Database13(Db_Database *db,ClaireClass *self) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(class = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(1,_oid_(self)));
    else ;{ list *Result ;
      { list * res = cast_I_list1(list::empty(),self);
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          ITERATE(c);
          for (START(self->descendents); NEXT(c);)
          { GC_LOOP;
            if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(c))) == CTRUE)
             { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(self);
              list * lp = GC_OBJECT(list,Dbo_dbProperties_class1(OBJECT(ClaireClass,c)));
              if (lp->memq(_oid_(idProp)) != CTRUE)
               lp= (add_list(lp,_oid_(idProp)));
              Db_printInQuery_Database1(db);
              princ_string(((char*)"SELECT "));
              Dbo_printList_list1(lp);
              princ_string(((char*)" FROM "));
              princ_string(Dbo_dbName_class1(OBJECT(ClaireClass,c)));
              princ_string(((char*)";"));
              { int loop_handle = ClEnv->cHandle;
                ITERATE(i);
                bag *i_support;
                i_support = GC_OBJECT(list,Dbo_loadObjectListFromRows_Database1(db,OBJECT(ClaireClass,c),idProp,lp));
                for (START(i_support); NEXT(i);)
                res= (add_list(res,i));
                }
              }
            GC_UNLOOP; POP_SIGNAL;}
          }
        if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
         mtformat_module1(Dbo.it,((char*)"dbLoad(class = ~S) -> ~A \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(2,_oid_(self),_oid_(res))));
        else ;Result = res;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: Dbo_dbLoad_Database13_type
CL_EXPORT ClaireType * Dbo_dbLoad_Database13_type(ClaireType *db,ClaireType *self) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


//dbLoad(db, self, dbProperties(self), 0, unknown, true)]
// The c++ function for: dbLoad(db:Db/Database,self:class,sortProp:dbProperty,asc?:boolean) []
CL_EXPORT list * Dbo_dbLoad_Database14(Db_Database *db,ClaireClass *self,Dbo_dbProperty *sortProp,ClaireBoolean *asc_ask) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(class = ~S, sortProp = ~S, asc? = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(3,_oid_(self),
      _oid_(sortProp),
      _oid_(asc_ask)));
    else ;{ list *Result ;
      Result = (list *)Dbo_dbLoad_Database11(db,
        self,
        GC_OBJECT(list,Dbo_dbProperties_class1(self)),
        0,
        _oid_(sortProp),
        asc_ask);
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: Dbo_dbLoad_Database14_type
CL_EXPORT ClaireType * Dbo_dbLoad_Database14_type(ClaireType *db,ClaireType *self,ClaireType *sortProp,ClaireType *asc_ask) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


//
//	dbLoad - loading some dbProperties of a class
//
// The c++ function for: dbLoad(db:Db/Database,self:class,lp:list[dbProperty]) []
CL_EXPORT list * Dbo_dbLoad_Database15(Db_Database *db,ClaireClass *self,list *lp) { 
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(class = ~S, lp = (~A)) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_oid_(lp)));
    else ;POP_SIGNAL; return (Dbo_dbLoad_Database11(db,
      self,
      lp,
      0,
      CNULL,
      CTRUE));}
  


// The c++ function for: Dbo_dbLoad_Database15_type
CL_EXPORT ClaireType * Dbo_dbLoad_Database15_type(ClaireType *db,ClaireType *self,ClaireType *lp) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbLoad(db:Db/Database,self:class,lp:list[dbProperty],sortProp:dbProperty,asc?:boolean) []
CL_EXPORT list * Dbo_dbLoad_Database16(Db_Database *db,ClaireClass *self,list *lp,Dbo_dbProperty *sortProp,ClaireBoolean *asc_ask) { 
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(class = ~S, lp = (~A), sortProp = ~S, asc? = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(4,_oid_(self),
      _oid_(lp),
      _oid_(sortProp),
      _oid_(asc_ask)));
    else ;POP_SIGNAL; return (Dbo_dbLoad_Database11(db,
      self,
      lp,
      0,
      _oid_(sortProp),
      asc_ask));}
  


// The c++ function for: Dbo_dbLoad_Database16_type
CL_EXPORT ClaireType * Dbo_dbLoad_Database16_type(ClaireType *db,ClaireType *self,ClaireType *lp,ClaireType *sortProp,ClaireType *asc_ask) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbLoad(db:Db/Database,self:class,sortProp:(dbProperty U {unknown}),asc?:boolean,wheres:list[tuple(dbProperty, any)]) []
CL_EXPORT list * Dbo_dbLoad_Database17(Db_Database *db,ClaireClass *self,OID sortProp,ClaireBoolean *asc_ask,list *wheres) { 
    POP_SIGNAL; return (Dbo_dbLoadWhere_Database2(db,
      self,
      sortProp,
      asc_ask,
      wheres));}
  


// The c++ function for: Dbo_dbLoad_Database17_type
CL_EXPORT ClaireType * Dbo_dbLoad_Database17_type(ClaireType *db,ClaireType *self,ClaireType *sortProp,ClaireType *asc_ask,ClaireType *wheres) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbLoadWhere(db:Db/Database,self:class,sortProp:(dbProperty U {unknown}),asc?:boolean,wheres:list) []
CL_EXPORT list * Dbo_dbLoadWhere_Database2(Db_Database *db,ClaireClass *self,OID sortProp,ClaireBoolean *asc_ask,list *wheres) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(class = ~S, sortProp = ~S, asc? = ~S, where = (~A)) \n"),((CL_INT)(OID)(1)),list::alloc(4,_oid_(self),
      sortProp,
      _oid_(asc_ask),
      _oid_(wheres)));
    else ;{ list *Result ;
      { list * res = cast_I_list1(list::empty(),self);
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          ITERATE(c);
          for (START(self->descendents); NEXT(c);)
          { GC_LOOP;
            if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(c))) == CTRUE)
             { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(OBJECT(ClaireClass,c));
              list * lpCopy = GC_OBJECT(list,Dbo_dbProperties_class1(OBJECT(ClaireClass,c)));
              if (lpCopy->memq(_oid_(idProp)) != CTRUE)
               lpCopy= (add_list(lpCopy,_oid_(idProp)));
              Db_printInQuery_Database1(db);
              princ_string(((char*)"SELECT "));
              Dbo_printList_list1(lpCopy);
              princ_string(((char*)" FROM "));
              princ_string(Dbo_dbName_class1(OBJECT(ClaireClass,c)));
              princ_string(((char*)" "));
              (*Dbo.printWhereAnd)(_oid_(db),
                _oid_(wheres));
              { OID  proptest = sortProp;
                if (proptest != CNULL)
                 { Dbo_dbProperty * prop = OBJECT(Dbo_dbProperty,proptest);
                  princ_string(((char*)" ORDER BY "));
                  princ_string(Dbo_dbName_dbProperty1(prop));
                  princ_string(((char*)" "));
                  princ_string(((asc_ask == CTRUE) ?
                    ((char*)"ASC") :
                    ((char*)"DESC") ));
                  }
                else ;}
              princ_string(((char*)";"));
              { int loop_handle = ClEnv->cHandle;
                ITERATE(i);
                bag *i_support;
                i_support = GC_OBJECT(list,Dbo_loadObjectListFromRows_Database1(db,OBJECT(ClaireClass,c),idProp,lpCopy));
                for (START(i_support); NEXT(i);)
                res= (add_list(res,i));
                }
              }
            GC_UNLOOP; POP_SIGNAL;}
          }
        Result = res;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: Dbo_dbLoadWhere_Database2_type
CL_EXPORT ClaireType * Dbo_dbLoadWhere_Database2_type(ClaireType *db,ClaireType *self,ClaireType *sortProp,ClaireType *asc_ask,ClaireType *wheres) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbLoad(db:Db/Database,self:class,wheres:list[tuple(dbProperty, any)]) []
CL_EXPORT list * Dbo_dbLoad_Database18(Db_Database *db,ClaireClass *self,list *wheres) { 
    POP_SIGNAL; return (Dbo_dbLoadWhere_Database3(db,self,wheres));}
  


// The c++ function for: Dbo_dbLoad_Database18_type
CL_EXPORT ClaireType * Dbo_dbLoad_Database18_type(ClaireType *db,ClaireType *self,ClaireType *wheres) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbLoadWhere(db:Db/Database,self:class,wheres:list) []
CL_EXPORT list * Dbo_dbLoadWhere_Database3(Db_Database *db,ClaireClass *self,list *wheres) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(class = ~S, where = (~A)) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_oid_(wheres)));
    else ;{ list *Result ;
      { list * res = cast_I_list1(list::empty(),self);
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          ITERATE(c);
          for (START(self->descendents); NEXT(c);)
          { GC_LOOP;
            if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(c))) == CTRUE)
             { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(OBJECT(ClaireClass,c));
              list * lp = GC_OBJECT(list,Dbo_dbProperties_class1(OBJECT(ClaireClass,c)));
              Db_printInQuery_Database1(db);
              princ_string(((char*)"SELECT "));
              Dbo_printList_list1(lp);
              princ_string(((char*)" FROM "));
              princ_string(Dbo_dbName_class1(OBJECT(ClaireClass,c)));
              princ_string(((char*)" "));
              (*Dbo.printWhereAnd)(_oid_(db),
                _oid_(wheres));
              princ_string(((char*)";"));
              { int loop_handle = ClEnv->cHandle;
                ITERATE(i);
                bag *i_support;
                i_support = GC_OBJECT(list,Dbo_loadObjectListFromRows_Database1(db,OBJECT(ClaireClass,c),idProp,lp));
                for (START(i_support); NEXT(i);)
                res= (add_list(res,i));
                }
              }
            GC_UNLOOP; POP_SIGNAL;}
          }
        Result = res;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: Dbo_dbLoadWhere_Database3_type
CL_EXPORT ClaireType * Dbo_dbLoadWhere_Database3_type(ClaireType *db,ClaireType *self,ClaireType *wheres) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbLoad(db:Db/Database,self:class,lp:list[dbProperty],wheres:list[tuple(dbProperty, any)]) []
CL_EXPORT list * Dbo_dbLoad_Database19(Db_Database *db,ClaireClass *self,list *lp,list *wheres) { 
    POP_SIGNAL; return (Dbo_dbLoadWhere_Database4(db,self,lp,wheres));}
  


// The c++ function for: Dbo_dbLoad_Database19_type
CL_EXPORT ClaireType * Dbo_dbLoad_Database19_type(ClaireType *db,ClaireType *self,ClaireType *lp,ClaireType *wheres) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbLoadWhere(db:Db/Database,self:class,lp:list[dbProperty],wheres:list) []
CL_EXPORT list * Dbo_dbLoadWhere_Database4(Db_Database *db,ClaireClass *self,list *lp,list *wheres) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(class = ~S, where = (~A)) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_oid_(wheres)));
    else ;{ list *Result ;
      { list * res = cast_I_list1(list::empty(),self);
        list * lpCopy = cast_I_list1(((list *) copy_bag(lp)),Dbo._dbProperty);
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          ITERATE(c);
          for (START(self->descendents); NEXT(c);)
          { GC_LOOP;
            if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(c))) == CTRUE)
             { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(OBJECT(ClaireClass,c));
              if (lpCopy->memq(_oid_(idProp)) != CTRUE)
               lpCopy= (add_list(lpCopy,_oid_(idProp)));
              Db_printInQuery_Database1(db);
              princ_string(((char*)"SELECT "));
              Dbo_printList_list1(lpCopy);
              princ_string(((char*)" FROM "));
              princ_string(Dbo_dbName_class1(OBJECT(ClaireClass,c)));
              princ_string(((char*)" "));
              (*Dbo.printWhereAnd)(_oid_(db),
                _oid_(wheres));
              princ_string(((char*)";"));
              { int loop_handle = ClEnv->cHandle;
                ITERATE(i);
                bag *i_support;
                i_support = GC_OBJECT(list,Dbo_loadObjectListFromRows_Database1(db,OBJECT(ClaireClass,c),idProp,lpCopy));
                for (START(i_support); NEXT(i);)
                res= (add_list(res,i));
                }
              }
            GC_UNLOOP; POP_SIGNAL;}
          }
        Result = res;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: Dbo_dbLoadWhere_Database4_type
CL_EXPORT ClaireType * Dbo_dbLoadWhere_Database4_type(ClaireType *db,ClaireType *self,ClaireType *lp,ClaireType *wheres) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbLoad(db:Db/Database,self:class,lp:list[dbProperty],wheres:list[tuple(dbProperty, any)],sortProp:dbProperty,asc?:boolean) []
CL_EXPORT list * Dbo_dbLoad_Database20(Db_Database *db,ClaireClass *self,list *lp,list *wheres,Dbo_dbProperty *sortProp,ClaireBoolean *asc_ask) { 
    POP_SIGNAL; return (Dbo_dbLoadWhere_Database5(db,
      self,
      lp,
      wheres,
      sortProp,
      asc_ask));}
  


// The c++ function for: Dbo_dbLoad_Database20_type
CL_EXPORT ClaireType * Dbo_dbLoad_Database20_type(ClaireType *db,ClaireType *self,ClaireType *lp,ClaireType *wheres,ClaireType *sortProp,ClaireType *asc_ask) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbLoadWhere(db:Db/Database,self:class,lp:list[dbProperty],wheres:list,sortProp:dbProperty,asc?:boolean) []
CL_EXPORT list * Dbo_dbLoadWhere_Database5(Db_Database *db,ClaireClass *self,list *lp,list *wheres,Dbo_dbProperty *sortProp,ClaireBoolean *asc_ask) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbLoad(class = ~S, where = (~A)) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_oid_(wheres)));
    else ;{ list *Result ;
      { list * res = cast_I_list1(list::empty(),self);
        list * lpCopy = cast_I_list1(((list *) copy_bag(lp)),Dbo._dbProperty);
        if (lpCopy->length == 0)
         lpCopy= (GC_OBJECT(list,Dbo_dbProperties_class1(self)));
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          ITERATE(c);
          for (START(self->descendents); NEXT(c);)
          { GC_LOOP;
            if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(c))) == CTRUE)
             { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(OBJECT(ClaireClass,c));
              if (lpCopy->memq(_oid_(idProp)) != CTRUE)
               lpCopy= (add_list(lpCopy,_oid_(idProp)));
              Db_printInQuery_Database1(db);
              princ_string(((char*)"SELECT "));
              Dbo_printList_list1(lpCopy);
              princ_string(((char*)" FROM "));
              princ_string(Dbo_dbName_class1(OBJECT(ClaireClass,c)));
              princ_string(((char*)" "));
              (*Dbo.printWhereAnd)(_oid_(db),
                _oid_(wheres));
              { OID  proptest = _oid_(sortProp);
                if (proptest != CNULL)
                 { Dbo_dbProperty * prop = OBJECT(Dbo_dbProperty,proptest);
                  princ_string(((char*)" ORDER BY "));
                  princ_string(Dbo_dbName_dbProperty1(prop));
                  princ_string(((char*)" "));
                  princ_string(((asc_ask == CTRUE) ?
                    ((char*)"ASC") :
                    ((char*)"DESC") ));
                  }
                else ;}
              princ_string(((char*)";"));
              { int loop_handle = ClEnv->cHandle;
                ITERATE(i);
                bag *i_support;
                i_support = GC_OBJECT(list,Dbo_loadObjectListFromRows_Database1(db,OBJECT(ClaireClass,c),idProp,lpCopy));
                for (START(i_support); NEXT(i);)
                res= (add_list(res,i));
                }
              }
            GC_UNLOOP; POP_SIGNAL;}
          }
        Result = res;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: Dbo_dbLoadWhere_Database5_type
CL_EXPORT ClaireType * Dbo_dbLoadWhere_Database5_type(ClaireType *db,ClaireType *self,ClaireType *lp,ClaireType *wheres,ClaireType *sortProp,ClaireType *asc_ask) { 
    
    GC_BIND;
    { ClaireType *Result ;
      Result = nth_class1(Kernel._list,GC_OBJECT(ClaireType,member_type(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbValidPassword?(db:Db/Database,c:class,i:integer,pass:string) []
CL_EXPORT ClaireBoolean * Dbo_dbValidPassword_ask_Database1(Db_Database *db,ClaireClass *c,CL_INT i,char *pass) { 
    { ClaireBoolean *Result ;
      { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(c);
        Dbo_dbProperty * passProp = Dbo_dbPasswordProperty_class1(c);
        Db_printInQuery_Database1(db);
        princ_string(((char*)"SELECT "));
        princ_string(Dbo_dbName_dbProperty1(idProp));
        princ_string(((char*)" FROM "));
        princ_string(Dbo_dbName_class1(c));
        princ_string(((char*)" WHERE "));
        princ_string(Dbo_dbName_dbProperty1(idProp));
        princ_string(((char*)"="));
        print_any(((OID)i));
        princ_string(((char*)" AND "));
        princ_string(Dbo_dbName_dbProperty1(passProp));
        princ_string(((char*)"="));
        Dbo_dbPrintValue_Database1(db,_string_(pass),passProp);
        princ_string(((char*)";"));
        { ClaireBoolean * valid_ask = Db_fetch_Database1(db);
          if (valid_ask == CTRUE)
           { int loop_handle = ClEnv->cHandle;
            while ((Db_fetch_Database1(db) == CTRUE))
            { ;POP_SIGNAL;}
            }
          Result = valid_ask;
          }
        }
      POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbValidPassword?(db:Db/Database,c:any,pass:string) []
CL_EXPORT ClaireBoolean * Dbo_dbValidPassword_ask_Database2(Db_Database *db,OID c,char *pass) { 
    
    GC_BIND;
    { ClaireBoolean *Result ;
      Result = OBJECT(ClaireBoolean,(*Dbo.dbValidPassword_ask)(_oid_(db),
        _oid_(OWNER(c)),
        GC_OID((*Dbo.getDbId)(c)),
        _string_(pass)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbValidPassword?(db:Db/Database,c:class,loginprop:dbProperty,loginval:string,pass:string) []
CL_EXPORT ClaireBoolean * Dbo_dbValidPassword_ask_Database3(Db_Database *db,ClaireClass *c,Dbo_dbProperty *loginprop,char *loginval,char *pass) { 
    { ClaireBoolean *Result ;
      { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(c);
        Dbo_dbProperty * passProp = Dbo_dbPasswordProperty_class1(c);
        Db_printInQuery_Database1(db);
        princ_string(((char*)"SELECT "));
        princ_string(Dbo_dbName_dbProperty1(idProp));
        princ_string(((char*)" FROM "));
        princ_string(Dbo_dbName_class1(c));
        princ_string(((char*)" WHERE "));
        princ_string(Dbo_dbName_dbProperty1(loginprop));
        princ_string(((char*)"="));
        Dbo_dbPrintValue_Database1(db,_string_(loginval),loginprop);
        princ_string(((char*)" AND "));
        princ_string(Dbo_dbName_dbProperty1(passProp));
        princ_string(((char*)"="));
        Dbo_dbPrintValue_Database1(db,_string_(pass),passProp);
        princ_string(((char*)";"));
        { ClaireBoolean * valid_ask = Db_fetch_Database1(db);
          if (valid_ask == CTRUE)
           { int loop_handle = ClEnv->cHandle;
            while ((Db_fetch_Database1(db) == CTRUE))
            { ;POP_SIGNAL;}
            }
          Result = valid_ask;
          }
        }
      POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbUpdatePassword(db:Db/Database,c:class,i:integer,pass:string) []
CL_EXPORT void  Dbo_dbUpdatePassword_Database1(Db_Database *db,ClaireClass *c,CL_INT i,char *pass) { 
    { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(c);
      Dbo_dbProperty * passProp = Dbo_dbPasswordProperty_class1(c);
      Db_printInQuery_Database1(db);
      princ_string(((char*)"UPDATE "));
      princ_string(Dbo_dbName_class1(c));
      princ_string(((char*)" SET "));
      (*Dbo.printAffects)(_oid_(db),
        _oid_(list::alloc(1,_oid_(tuple::alloc(2,_oid_(passProp),_string_(pass))))));
      princ_string(((char*)" WHERE "));
      princ_string(Dbo_dbName_dbProperty1(idProp));
      princ_string(((char*)"="));
      print_any(((OID)i));
      princ_string(((char*)";"));
      Db_endOfQuery_Database1(db);
      }
    POP_SIGNAL;}
  


// The c++ function for: dbUpdatePassword(db:Db/Database,o:any,pass:string) []
CL_EXPORT void  Dbo_dbUpdatePassword_Database2(Db_Database *db,OID o,char *pass) { 
    
    GC_BIND;
    (*Dbo.dbUpdatePassword)(_oid_(db),
      _oid_(OWNER(o)),
      GC_OID((*Dbo.getDbId)(o)),
      _string_(pass));
    GC_UNBIND; POP_SIGNAL;}
  


// The c++ function for: print_int(aint:integer) []
CL_EXPORT void  Dbo_print_int_integer1(CL_INT aint) { 
    unsigned int self = (unsigned int)aint;
    int v = 0; for(;v < sizeof(int);v++) {;
    int offset = v << 3;
    unsigned char c = (unsigned char)((self & (0xFF << offset)) >> offset);
    ClEnv->cout->put((char)c);};
    POP_SIGNAL;}
  


// The c++ function for: print_string_list(self:list[string],p:port) []
CL_EXPORT void  Dbo_print_string_list_list1(list *self,PortObject *p) { 
    fwrite_string2(((char*)"SL"),p);
    { PortObject * op = use_as_output_port(p);
      Dbo_print_int_integer1(self->length);
      { int loop_handle = ClEnv->cHandle;
        ITERATE(s);
        for (START(self); NEXT(s);)
        { Dbo_print_int_integer1(LENGTH_STRING(string_v(s)));
          princ_string(string_v(s));
          }
        }
      use_as_output_port(op);
      }
    POP_SIGNAL;}
  


// The c++ function for: extract_int(p:port) []
CL_EXPORT CL_INT  Dbo_extract_int_port1(PortObject *p) { 
    { CL_INT Result = 0;
      { CL_INT  i = 0;
        int v = 0; for(;v < sizeof(int);v++) {;
        unsigned char c = p->get();
        i |= (int)((int)c << (v << 3));};
        Result = i;
        }
      POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: extract_string_list(p:port) []
CL_EXPORT list * Dbo_extract_string_list_port1(PortObject *p) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(3))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"extract_string_list(~S) \n"),((CL_INT)(OID)(3)),list::alloc(1,_oid_(p)));
    else ;{ list *Result ;
      { char * h = GC_STRING(fread_port4(p,2));
        CL_INT  len = Dbo_extract_int_port1(p);
        list * l = GC_OBJECT(list,make_list_integer2(len,Kernel._string,_string_(((char*)""))));
        if (equal_string(h,((char*)"SL")) != CTRUE)
         close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"Cannot extract a list[string] from ~S")),
          _oid_(list::alloc(1,_oid_(p))))));
        { CL_INT  i = 1;
          CL_INT  g0094 = len;
          { int loop_handle = ClEnv->cHandle;
            OID gc_local;
            while (((CL_INT)i <= (CL_INT)g0094))
            { GC_LOOP;
              { CL_INT  lens = Dbo_extract_int_port1(p);
                ((*(l))[i]=GC_OID(_string_(fread_port4(p,lens))));
                }
              ++i;
              GC_UNLOOP;POP_SIGNAL;}
            }
          }
        Result = l;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  



/***** CLAIRE Compilation of file source/db_get_erase.cl 
         [version 3.7.0 / safety 3] *****/


// The c++ function for: dbGetId(db:Db/Database,prop:property,self:object) []
CL_EXPORT OID  Dbo_dbGetId_Database1(Db_Database *db,property *prop,ClaireObject *self) { 
    if (unknown_ask_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
     (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
     (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self) == CTRUE)
     close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"dbGetId(~S, ~S) error, ~S's id is unknown")),
      _oid_(list::alloc(3,_oid_(prop),
        _oid_(self),
        _oid_(self))))));
    if (_oid_((INHERIT(prop->isa,Dbo._dbProperty) ?
     (ClaireObject *) Dbo_db_1_dash1_ask_dbProperty1((Dbo_dbProperty *) OBJECT(Dbo_dbProperty,_oid_(prop)),self) : 
     (ClaireObject *)  Dbo_db_1_dash1_ask_property2((property *) OBJECT(property,_oid_(prop)),self))) != Kernel.ctrue)
     close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"dbGetId(~S, ~S) error, ~S's range is not a  db-stored class")),
      _oid_(list::alloc(3,_oid_(prop),
        _oid_(self),
        _oid_(prop))))));
    POP_SIGNAL; return ((*Dbo.idOf1_dash1)(_oid_(db),
      _oid_(self),
      _oid_(prop)));}
  


// The c++ function for: dbGet(db:Db/Database,prop:property,self:object) []
CL_EXPORT OID  Dbo_dbGet_Database1(Db_Database *db,property *prop,ClaireObject *self) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbGet(prop = ~S, object = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(prop),_oid_(self)));
    else ;if (unknown_ask_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
     (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
     (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self) == CTRUE)
     close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"dbGet(~S, ~S) error, ~S's id is unknown")),
      _oid_(list::alloc(3,_oid_(prop),
        _oid_(self),
        _oid_(self))))));
    { OID Result = 0;
      { OID  res;
        { if ((((prop->inverse == (NULL)) ? CTRUE : CFALSE) != CTRUE) && 
              ((INHERIT(NOTNULL(Kernel.isa,NOTNULL(Kernel.inverse,prop->inverse)->isa),Dbo._dbProperty)) && 
                ((inherit_ask_class(NOTNULL(Kernel.isa,prop->isa),Dbo._dbProperty) != CTRUE) && 
                  ((boolean_I_any(_oid_(prop->multivalued_ask)) == CTRUE) && 
                    (boolean_I_any(_oid_(NOTNULL(Kernel.inverse,prop->inverse)->multivalued_ask)) != CTRUE)))))
           { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
             mtformat_module1(Dbo.it,((char*)"dbGet(~S,~S) @ db_N-1? \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(prop),_oid_(self)));
            else ;erase_property(prop,self);
            { int loop_handle = ClEnv->cHandle;
              OID gc_local;
              ITERATE(rng);
              bag *rng_support;
              rng_support = GC_OBJECT(set,OBJECT(bag,(*Kernel.descendents)(GC_OID((*Core.t1)(GC_OID((*Kernel.range)(GC_OID(_oid_(_at_property1(prop,OWNER(_oid_(self))))))))))));
              for (START(rng_support); NEXT(rng);)
              { GC_LOOP;
                if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(rng))) == CTRUE)
                 (*Dbo.dbLoad)(_oid_(db),
                  rng,
                  GC_OID(_oid_(list::alloc(1,_oid_(tuple::alloc(2,_oid_(NOTNULL(Kernel.inverse,prop->inverse)),_oid_(self)))))));
                GC_UNLOOP; POP_SIGNAL;}
              }
            res = get_property(prop,self);
            }
          else if ((OBJECT(ClaireBoolean,_oid_((INHERIT(prop->isa,Dbo._dbProperty) ?
           (ClaireObject *) Dbo_db_1_dash1_ask_dbProperty1((Dbo_dbProperty *) OBJECT(Dbo_dbProperty,_oid_(prop)),self) : 
           (ClaireObject *)  Dbo_db_1_dash1_ask_property2((property *) OBJECT(property,_oid_(prop)),self))))) == CTRUE)
           { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
             mtformat_module1(Dbo.it,((char*)"dbGet(~S,~S) @ db_1-1? \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(2,_oid_(prop),_oid_(self))));
            else ;erase_property(prop,self);
            { OID  idtest = GC_OID((*Dbo.idOf1_dash1)(_oid_(db),
                _oid_(self),
                _oid_(prop)));
              if (idtest != CNULL)
               { CL_INT  id = ((CL_INT)idtest);
                if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                 mtformat_module1(Dbo.it,((char*)"dbGet(~S,~S) @ db_1-1?, idOf returned ~S \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(3,_oid_(prop),
                  _oid_(self),
                  ((OID)id))));
                else ;{ OID  obj = GC_OID(Dbo_dbLoad_Database9(db,OBJECT(ClaireClass,(*Dbo.getRange1_dash1)(_oid_(prop),
                    _oid_(self))),id));
                  if (obj != CNULL)
                   { write_property(prop,self,obj);
                    res = obj;
                    }
                  else { erase_property(prop,self);
                      res = get_property(prop,self);
                      }
                    }
                }
              else { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                   mtformat_module1(Dbo.it,((char*)"dbGet(~S,~S) @ db_1-1?, idOf returned unknown \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(2,_oid_(prop),_oid_(self))));
                  else ;erase_property(prop,self);
                  res = get_property(prop,self);
                  }
                }
            }
          else if ((((prop->inverse == (NULL)) ? CTRUE : CFALSE) != CTRUE) && 
              ((inherit_ask_class(NOTNULL(Kernel.isa,NOTNULL(Kernel.inverse,prop->inverse)->isa),Dbo._dbProperty) != CTRUE) && 
                ((INHERIT(NOTNULL(Kernel.isa,prop->isa),Dbo._dbProperty)) && 
                  ((boolean_I_any(_oid_(prop->multivalued_ask)) != CTRUE) && 
                    (boolean_I_any(_oid_(NOTNULL(Kernel.inverse,prop->inverse)->multivalued_ask)) == CTRUE)))))
           { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
             mtformat_module1(Dbo.it,((char*)"dbGet(~S,~S) @ db_1-N? \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(2,_oid_(prop),_oid_(self))));
            else ;erase_property(prop,self);
            { OID  idtest = GC_OID((*Dbo.idOf1_dash1)(_oid_(db),
                _oid_(self),
                _oid_(prop)));
              if (idtest != CNULL)
               { CL_INT  id = ((CL_INT)idtest);
                if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                 mtformat_module1(Dbo.it,((char*)"dbGet(~S,~S) @ db_1-N?, idOf returned  ~S \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(3,_oid_(prop),
                  _oid_(self),
                  ((OID)id))));
                else ;{ OID  obj = GC_OID(Dbo_dbLoad_Database9(db,OBJECT(ClaireClass,(*Dbo.getRange1_dash1)(_oid_(prop),
                    _oid_(self))),id));
                  if (obj != CNULL)
                   { write_property(prop,self,obj);
                    res = obj;
                    }
                  else { erase_property(prop,self);
                      res = get_property(prop,self);
                      }
                    }
                }
              else { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                   mtformat_module1(Dbo.it,((char*)"dbGet(~S,~S) @ db_1-N?, idOf returned unknown \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(2,_oid_(prop),_oid_(self))));
                  else ;erase_property(prop,self);
                  res = get_property(prop,self);
                  }
                }
            }
          else if ((((prop->inverse == (NULL)) ? CTRUE : CFALSE) != CTRUE) && 
              ((inherit_ask_class(NOTNULL(Kernel.isa,prop->isa),Dbo._dbProperty) != CTRUE) && 
                ((INHERIT(NOTNULL(Kernel.isa,NOTNULL(Kernel.inverse,prop->inverse)->isa),Dbo._dbProperty)) && 
                  ((boolean_I_any(_oid_(prop->multivalued_ask)) != CTRUE) && 
                    (boolean_I_any(_oid_(NOTNULL(Kernel.inverse,prop->inverse)->multivalued_ask)) != CTRUE)))))
           { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
             mtformat_module1(Dbo.it,((char*)"dbGet(~S,~S) @ db_1-1? \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(2,_oid_(prop),_oid_(self))));
            else ;erase_property(prop,self);
            { OID  idtest = GC_OID((*Dbo.idOf)(_oid_(db),
                _oid_(self),
                _oid_(prop)));
              if (idtest != CNULL)
               { CL_INT  id = ((CL_INT)idtest);
                OID  obj;
                { { OID  rngtest;
                    { { OID  g0096_some = CNULL;
                        { int loop_handle = ClEnv->cHandle;
                          OID gc_local;
                          ITERATE(g0096);
                          bag *g0096_support;
                          g0096_support = GC_OBJECT(set,OBJECT(bag,(*Kernel.descendents)(GC_OID((*Kernel.range)(GC_OID(_oid_(_at_property1(prop,OWNER(_oid_(self))))))))));
                          for (START(g0096_support); NEXT(g0096);)
                          { GC_LOOP;
                            if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(g0096))) == CTRUE)
                             { g0096_some= (g0096);
                              GC_UNLOOP;ClEnv->cHandle = loop_handle; break;}
                            GC_UNLOOP; POP_SIGNAL;}
                          }
                        rngtest = g0096_some;
                        }
                      GC_OID(rngtest);}
                    if (rngtest != CNULL)
                     { ClaireClass * rng = OBJECT(ClaireClass,rngtest);
                      OID  o = GC_OID(Dbo_dbLoad_Database9(db,rng,id));
                      if (o != CNULL)
                       obj = o;
                      else { erase_property(prop,self);
                          get_property(prop,self);
                          obj = CNULL;
                          }
                        }
                    else { erase_property(prop,self);
                        get_property(prop,self);
                        obj = CNULL;
                        }
                      }
                  GC_OID(obj);}
                if (obj == CNULL)
                 { erase_property(prop,self);
                  obj= (GC_OID(get_property(prop,self)));
                  }
                res = obj;
                }
              else { erase_property(prop,self);
                  res = get_property(prop,self);
                  }
                }
            }
          else if (INHERIT(NOTNULL(Kernel.isa,prop->isa),Dbo._dbProperty))
           { (*Dbo.dbLoad)(_oid_(db),
              _oid_(self),
              GC_OID(_oid_(list::alloc(1,_oid_(prop)))));
            res = get_property(prop,self);
            }
          else res = get_property(prop,self);
            GC_OID(res);}
        if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
         mtformat_module1(Dbo.it,((char*)"dbGet(~S,~S) => ~S \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(3,_oid_(prop),
          _oid_(self),
          res)));
        else ;Result = res;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


//
// The c++ function for: dbErase(db:Db/Database,prop:property,self:object) []
CL_EXPORT OID  Dbo_dbErase_Database1(Db_Database *db,property *prop,ClaireObject *self) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbErase(prop = ~S, object = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(prop),_oid_(self)));
    else ;if (known_ask_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
     (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
     (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self) == CTRUE)
     { ClaireType * rng = GC_OBJECT(ClaireType,OBJECT(ClaireType,(*Kernel.range)(GC_OID(_oid_(_at_property1(prop,OWNER(_oid_(self))))))));
      if (belong_to(_oid_(rng),_oid_(nth_class1(Kernel._type,GC_OBJECT(ClaireType,U_type(GC_OBJECT(ClaireType,U_type(GC_OBJECT(ClaireType,U_type(GC_OBJECT(ClaireType,U_type(Kernel._integer,Kernel._float)),Kernel._char)),Kernel._string)),Kernel._boolean))))) == CTRUE)
       { if (inherit_ask_class(NOTNULL(Kernel.isa,prop->isa),Dbo._dbProperty) != CTRUE)
         close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"dbErase ~S @ ~S (on ~S) of range ~S, ~S is not a dbProperty")),
          _oid_(list::alloc(5,_oid_(prop),
            _oid_(OWNER(_oid_(self))),
            _oid_(self),
            _oid_(rng),
            _oid_(prop))))));
        erase_property(prop,self);
        (*Dbo.dbUpdate)(_oid_(db),
          _oid_(self),
          _oid_(list::alloc(1,_oid_(prop))));
        }
      else if (belong_to(_oid_(rng),_oid_(nth_class1(Kernel._type,Kernel._bag))) == CTRUE)
       { if (inherit_ask_class(owner_any((*Core.t1)(_oid_(rng))),Kernel._class) != CTRUE)
         close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"dbErase ~S @ ~S (on ~S) of range ~S is not a bag of class")),
          _oid_(list::alloc(4,_oid_(prop),
            _oid_(OWNER(_oid_(self))),
            _oid_(self),
            _oid_(rng))))));
        { int loop_handle = ClEnv->cHandle;
          ITERATE(i);
          bag *i_support;
          i_support = GC_OBJECT(bag,enumerate_any(GC_OID(Dbo_dbGet_Database1(db,prop,self))));
          for (START(i_support); NEXT(i);)
          (*Dbo.dbDelete)(_oid_(db),
            i);
          }
        }
      else if (INHERIT(NOTNULL(Kernel.isa,rng->isa),Kernel._class))
       { OID  obj = GC_OID(Dbo_dbGet_Database1(db,prop,self));
        if (obj != CNULL)
         (*Dbo.dbDelete)(_oid_(db),
          obj);
        else ;}
      }
    { OID Result = 0;
      Result = erase_property(prop,self);
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  



/***** CLAIRE Compilation of file source/dbtables.cl 
         [version 3.7.0 / safety 3] *****/


//
//	how to drop database table of a class
//
// The c++ function for: dbDrop(db:Db/Database,self:class) []
CL_EXPORT void  Dbo_dbDrop_Database1(Db_Database *db,ClaireClass *self) { 
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbDrop(self = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(1,_oid_(self)));
    else ;Db_printInQuery_Database1(db);
    princ_string(((char*)"DROP TABLE "));
    princ_string(Dbo_dbName_class1(self));
    Db_endOfQuery_Database1(db);
    Db_popQuery_Database1(db);
    POP_SIGNAL;}
  


//
//	how to create database tables from a class
//
// The c++ function for: dbCreateTable(db:Db/Database,self:class,drop?:boolean) []
CL_EXPORT void  Dbo_dbCreateTable_Database1(Db_Database *db,ClaireClass *self,ClaireBoolean *drop_ask) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dbCreateTable(self = ~S, drop? = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_oid_(drop_ask)));
    else ;if (drop_ask == CTRUE)
     { ClaireHandler c_handle = ClaireHandler();
      if ERROR_IN 
      { Dbo_dbDrop_Database1(db,self);
        ERROR_FREE;}
      else if (belong_to(_oid_(ClEnv->exception_I),_oid_(Kernel._any)) == CTRUE)
      { c_handle.catchIt();;}
      else PREVIOUS_HANDLER;}
    Db_printInQuery_Database1(db);
    princ_string(((char*)"CREATE TABLE "));
    princ_string(Dbo_dbName_class1(self));
    princ_string(((char*)" (\n"));
    Dbo_printFieldDefinitions_Database1(db,self,GC_OBJECT(list,Dbo_dbAllProperties_class1(self)));
    princ_string(((char*)")"));
    Db_endOfQuery_Database1(db);
    Db_popQuery_Database1(db);
    if (LENGTH_STRING(string_v(nth_table2(Db.SQL_TYPES,(OID)(-1),((OID)db->driverType)))) == 0)
     { Db_printInQuery_Database1(db);
      princ_string(((char*)"CREATE SEQUENCE "));
      princ_string(Dbo_dbName_class1(self));
      princ_string(((char*)"_seq INCREMENT 1 START 1"));
      Db_endOfQuery_Database1(db);
      Db_popQuery_Database1(db);
      }
    GC_UNBIND; POP_SIGNAL;}
  


// The c++ function for: dbCreateIndex(db:Db/Database,self:class,prop:dbProperty) []
CL_EXPORT void  Dbo_dbCreateIndex_Database1(Db_Database *db,ClaireClass *self,Dbo_dbProperty *prop) { 
    Db_printInQuery_Database1(db);
    princ_string(((char*)"CREATE INDEX dboindex_"));
    princ_string(Dbo_dbName_class1(self));
    princ_string(((char*)"_"));
    princ_string(Dbo_dbName_dbProperty1(prop));
    princ_string(((char*)" on "));
    princ_string(Dbo_dbName_class1(self));
    princ_string(((char*)" ("));
    princ_string(Dbo_dbName_dbProperty1(prop));
    princ_string(((char*)");"));
    Db_endOfQuery_Database1(db);
    POP_SIGNAL;}
  


// The c++ function for: dbCreateIndex(db:Db/Database,self:class,props:list[dbProperty]) []
CL_EXPORT void  Dbo_dbCreateIndex_Database2(Db_Database *db,ClaireClass *self,list *props) { 
    Db_printInQuery_Database1(db);
    princ_string(((char*)"CREATE INDEX dboindex_"));
    princ_string(Dbo_dbName_class1(self));
    { int loop_handle = ClEnv->cHandle;
      ITERATE(prop);
      for (START(props); NEXT(prop);)
      { princ_string(((char*)"_"));
        princ_string(Dbo_dbName_dbProperty1(OBJECT(Dbo_dbProperty,prop)));
        }
      }
    princ_string(((char*)" on "));
    princ_string(Dbo_dbName_class1(self));
    princ_string(((char*)" ("));
    Dbo_printList_list1(props);
    princ_string(((char*)");"));
    Db_endOfQuery_Database1(db);
    POP_SIGNAL;}
  



/***** CLAIRE Compilation of file source/copy.cl 
         [version 3.7.0 / safety 3] *****/


// The c++ function for: dbCopy(db:Db/Database,self:object) []
CL_EXPORT ClaireObject * Dbo_dbCopy_Database1_Dbo(Db_Database *db,ClaireObject *self) { 
    POP_SIGNAL; return (OBJECT(ClaireObject,(*Dbo.dbCopy)(_oid_(db),
      _oid_(self),
      Kernel.ctrue)));}
  


// The c++ function for: dbCopy(db:Db/Database,self:object,use_dbGet?:boolean) []
CL_EXPORT ClaireObject * Dbo_dbCopy_Database2_Dbo(Db_Database *db,ClaireObject *self,ClaireBoolean *use_dbGet_ask) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"**** dbCopy(object = ~S, use_dbGet? = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_oid_(use_dbGet_ask)));
    else ;if (use_dbGet_ask == CTRUE)
     { int loop_handle = ClEnv->cHandle;
      OID gc_local;
      ITERATE(prop);
      bag *prop_support;
      { set * p_bag = set::empty(Kernel.emptySet);
        { int loop_handle = ClEnv->cHandle;
          ITERATE(p);
          bag *p_support;
          p_support = OWNER(_oid_(self))->slots;
          for (START(p_support); NEXT(p);)
          p_bag->addFast((OID)_oid_(NOTNULL(Kernel.selector,OBJECT(restriction,p)->selector)));
          }
        prop_support = GC_OBJECT(set,p_bag);
        }
      for (START(prop_support); NEXT(prop);)
      { GC_LOOP;
        if (((((OBJECT(ClaireRelation,prop)->inverse == (NULL)) ? CTRUE : CFALSE) != CTRUE) && 
              ((INHERIT(NOTNULL(Kernel.isa,NOTNULL(Kernel.inverse,OBJECT(ClaireRelation,prop)->inverse)->isa),Dbo._dbProperty)) && 
                ((inherit_ask_class(NOTNULL(Kernel.isa,OBJECT(ClaireObject,prop)->isa),Dbo._dbProperty) != CTRUE) && 
                  ((boolean_I_any(_oid_(OBJECT(ClaireRelation,prop)->multivalued_ask)) == CTRUE) && 
                    (boolean_I_any(_oid_(NOTNULL(Kernel.inverse,OBJECT(ClaireRelation,prop)->inverse)->multivalued_ask)) != CTRUE))))) || 
            (((OBJECT(ClaireBoolean,(*Dbo.dbReference_ask)(GC_OID((*Kernel.range)(GC_OID(_oid_(_at_property1(OBJECT(property,prop),OWNER(_oid_(self)))))))))) == CTRUE) || 
              ((_oid_((INHERIT(OWNER(prop),Dbo._dbProperty) ?
                 (ClaireObject *) Dbo_db_1_dash1_ask_dbProperty1((Dbo_dbProperty *) OBJECT(Dbo_dbProperty,prop),self) : 
                 (ClaireObject *)  Dbo_db_1_dash1_ask_property2((property *) OBJECT(property,prop),self))) != Kernel.ctrue) && 
                  ((((OBJECT(ClaireRelation,prop)->inverse == (NULL)) ? CTRUE : CFALSE) != CTRUE) && 
                      ((inherit_ask_class(NOTNULL(Kernel.isa,OBJECT(ClaireObject,prop)->isa),Dbo._dbProperty) != CTRUE) && 
                        ((INHERIT(NOTNULL(Kernel.isa,NOTNULL(Kernel.inverse,OBJECT(ClaireRelation,prop)->inverse)->isa),Dbo._dbProperty)) && 
                          ((boolean_I_any(_oid_(OBJECT(ClaireRelation,prop)->multivalued_ask)) != CTRUE) && 
                            (boolean_I_any(_oid_(NOTNULL(Kernel.inverse,OBJECT(ClaireRelation,prop)->inverse)->multivalued_ask)) != CTRUE))))))))
         { erase_property(OBJECT(property,prop),self);
          Dbo_dbGet_Database1(db,OBJECT(property,prop),self);
          }
        GC_UNLOOP; POP_SIGNAL;}
      }
    { OID  itest = GC_OID(get_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
       (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
       (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self));
      if (itest != CNULL)
       { CL_INT  i = ((CL_INT)itest);
        claire_nth_equal_db_id_map1(OBJECT(Dbo_db_id_map,Dbo.DB_ID_MAP->value),OWNER(_oid_(self)),i,CNULL);
        }
      else ;}
    erase_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
     (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
     (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self);
    if (Dbo_dbCreate_Database2(db,self) == CTRUE)
     { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
       mtformat_module1(Dbo.it,((char*)"**** dbCopy: ~S as new id -> ~S \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(2,_oid_(self),GC_OID(get_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
       (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
       (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self)))));
      else ;{ int loop_handle = ClEnv->cHandle;
        OID gc_local;
        ITERATE(prop);
        bag *prop_support;
        { set * p_bag = set::empty(Kernel.emptySet);
          { int loop_handle = ClEnv->cHandle;
            ITERATE(p);
            bag *p_support;
            p_support = OWNER(_oid_(self))->slots;
            for (START(p_support); NEXT(p);)
            p_bag->addFast((OID)_oid_(NOTNULL(Kernel.selector,OBJECT(restriction,p)->selector)));
            }
          prop_support = GC_OBJECT(set,p_bag);
          }
        for (START(prop_support); NEXT(prop);)
        { GC_LOOP;
          if (belong_to((*Kernel.range)(GC_OID(_oid_(_at_property1(OBJECT(property,prop),OWNER(_oid_(self)))))),_oid_(nth_class1(Kernel._type,GC_OBJECT(ClaireType,U_type(GC_OBJECT(ClaireType,U_type(GC_OBJECT(ClaireType,U_type(GC_OBJECT(ClaireType,U_type(Kernel._integer,Kernel._float)),Kernel._char)),Kernel._string)),Kernel._boolean))))) != CTRUE)
           { if ((((OBJECT(ClaireRelation,prop)->inverse == (NULL)) ? CTRUE : CFALSE) != CTRUE) && 
                ((INHERIT(NOTNULL(Kernel.isa,NOTNULL(Kernel.inverse,OBJECT(ClaireRelation,prop)->inverse)->isa),Dbo._dbProperty)) && 
                  ((inherit_ask_class(NOTNULL(Kernel.isa,OBJECT(ClaireObject,prop)->isa),Dbo._dbProperty) != CTRUE) && 
                    ((boolean_I_any(_oid_(OBJECT(ClaireRelation,prop)->multivalued_ask)) == CTRUE) && 
                      (boolean_I_any(_oid_(NOTNULL(Kernel.inverse,OBJECT(ClaireRelation,prop)->inverse)->multivalued_ask)) != CTRUE)))))
             { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
               mtformat_module1(Dbo.it,((char*)"**** dbCopy: update N-1 relationship (~S -> ~S) \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(2,prop,_oid_(NOTNULL(Kernel.inverse,OBJECT(ClaireRelation,prop)->inverse)))));
              else ;{ int loop_handle = ClEnv->cHandle;
                OID gc_local;
                ITERATE(val);
                bag *val_support;
                val_support = GC_OBJECT(bag,enumerate_any(GC_OID(get_property(OBJECT(property,prop),self))));
                for (START(val_support); NEXT(val);)
                { GC_LOOP;
                  { (*Dbo.dbCopy)(_oid_(db),
                      val,
                      _oid_(use_dbGet_ask));
                    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                     mtformat_module1(Dbo.it,((char*)"**** dbCopy: update N-1 relationship (~S -> ~S) on ~S with ~S \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(4,prop,
                      _oid_(NOTNULL(Kernel.inverse,OBJECT(ClaireRelation,prop)->inverse)),
                      _oid_(self),
                      val)));
                    else ;}
                  GC_UNLOOP; POP_SIGNAL;}
                }
              }
            else if ((OBJECT(ClaireBoolean,_oid_((INHERIT(OWNER(prop),Dbo._dbProperty) ?
             (ClaireObject *) Dbo_db_1_dash1_ask_dbProperty1((Dbo_dbProperty *) OBJECT(Dbo_dbProperty,prop),self) : 
             (ClaireObject *)  Dbo_db_1_dash1_ask_property2((property *) OBJECT(property,prop),self))))) == CTRUE)
             { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
               mtformat_module1(Dbo.it,((char*)"**** dbCopy: update 1-1 relationship (~S -> ~S) \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(2,prop,GC_OID((*Kernel.range)(GC_OID(_oid_(_at_property1(OBJECT(property,prop),OWNER(_oid_(self))))))))));
              else ;{ OID  obj = GC_OID(get_property(OBJECT(property,prop),self));
                if (obj != CNULL)
                 { if (((*Dbo.dbReference_ask)(_oid_(OWNER(obj))) != Kernel.ctrue) && 
                      ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(_oid_(OWNER(obj))))) == CTRUE))
                   (*Dbo.dbCopy)(_oid_(db),
                    obj,
                    _oid_(use_dbGet_ask));
                  write_property(OBJECT(property,prop),self,obj);
                  Dbo_dbUpdate_Database1(db,self,GC_OBJECT(list,list::alloc(Dbo._dbProperty,1,prop)));
                  if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                   mtformat_module1(Dbo.it,((char*)"**** dbCopy: update 1-1 relationship (~S -> ~S) on ~S with ~S \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(4,prop,
                    GC_OID((*Kernel.range)(GC_OID(_oid_(_at_property1(OBJECT(property,prop),OWNER(_oid_(self))))))),
                    _oid_(self),
                    obj)));
                  else ;}
                else ;}
              }
            else if (((((OBJECT(ClaireRelation,prop)->inverse == (NULL)) ? CTRUE : CFALSE) != CTRUE) && 
                  ((inherit_ask_class(NOTNULL(Kernel.isa,OBJECT(ClaireObject,prop)->isa),Dbo._dbProperty) != CTRUE) && 
                    ((INHERIT(NOTNULL(Kernel.isa,NOTNULL(Kernel.inverse,OBJECT(ClaireRelation,prop)->inverse)->isa),Dbo._dbProperty)) && 
                      ((boolean_I_any(_oid_(OBJECT(ClaireRelation,prop)->multivalued_ask)) != CTRUE) && 
                        (boolean_I_any(_oid_(NOTNULL(Kernel.inverse,OBJECT(ClaireRelation,prop)->inverse)->multivalued_ask)) != CTRUE))))) && 
                ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(_oid_(owner_any(get_property(OBJECT(property,prop),self)))))) == CTRUE))
             { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
               mtformat_module1(Dbo.it,((char*)"**** dbCopy: update 1-1 relationship (~S -> ~S) \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(2,prop,_oid_(NOTNULL(Kernel.inverse,OBJECT(ClaireRelation,prop)->inverse)))));
              else ;{ OID  obj = GC_OID(get_property(OBJECT(property,prop),self));
                if (obj != CNULL)
                 { (*Dbo.dbCopy)(_oid_(db),
                    obj,
                    _oid_(use_dbGet_ask));
                  (*Core.write)(_oid_(NOTNULL(Kernel.inverse,OBJECT(ClaireRelation,prop)->inverse)),
                    obj,
                    _oid_(self));
                  (*Dbo.dbUpdate)(_oid_(db),
                    obj,
                    GC_OID(_oid_(list::alloc(Dbo._dbProperty,1,_oid_(NOTNULL(Kernel.inverse,OBJECT(ClaireRelation,prop)->inverse))))));
                  if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                   mtformat_module1(Dbo.it,((char*)"**** dbCopy: update 1-1 relationship (~S -> ~S) on ~S with ~S \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(4,prop,
                    _oid_(NOTNULL(Kernel.inverse,OBJECT(ClaireRelation,prop)->inverse)),
                    _oid_(self),
                    obj)));
                  else ;}
                else ;}
              }
            }
          GC_UNLOOP; POP_SIGNAL;}
        }
      }
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"**** dbCopy => ~S \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(1,_oid_(self))));
    else ;{ ClaireObject *Result ;
      Result = self;
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  



/***** CLAIRE Compilation of file source/dbtools.cl 
         [version 3.7.0 / safety 3] *****/


//
//	Mapping CLAIRE symbols to DB names
//
// construct a field name from a dbProperty
// if the dbProperty has id? set to true returns "id"
// else if the dbProperty has a known fieldName returns uts value
// otherwise dbName(myBooleanSlot?) -> "myBooleanSlot_ask"
// The c++ function for: dbName(self:dbProperty) []
CL_EXPORT char * Dbo_dbName_dbProperty1(Dbo_dbProperty *self) { 
    { char *Result ;
      if (((self->fieldName == (NULL)) ? CTRUE : CFALSE) != CTRUE)
       Result = NOTNULL(Dbo.fieldName,self->fieldName);
      else if (((self->idGenerator == (NULL)) ? CTRUE : CFALSE) != CTRUE)
       Result = ((char*)"gid");
      else if (self->id_ask == CTRUE)
       Result = ((char*)"id");
      else { print_in_string_void();
          c_princ_string(Dbo_dbName_module1(NOTNULL(Kernel.module_I,self->name->module_I)));
          princ_string(((char*)"_"));
          c_princ_string(string_I_symbol(self->name));
          Result = end_of_string_void();
          }
        POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbName(self:dbProperty,cl:class) []
CL_EXPORT char * Dbo_dbName_dbProperty2(Dbo_dbProperty *self,ClaireClass *cl) { 
    
    GC_BIND;
    { char *Result ;
      Result = append_string(GC_STRING(append_string(GC_STRING(Dbo_dbName_class1(cl)),((char*)"."))),GC_STRING(Dbo_dbName_dbProperty1(self)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// construct the a table name from a class
// ex:
//      dbName(myModule/MyClass?) -> "t_myModule_MyClass_ask"
// The c++ function for: dbName(self:class) []
CL_EXPORT char * Dbo_dbName_class1(ClaireClass *self) { 
    
    GC_BIND;
    { char *Result ;
      { OID  clDbNametest = nth_table1(Dbo.DB_CLASS_NAME,_oid_(self));
        if (clDbNametest != CNULL)
         { char * clDbName = string_v(clDbNametest);
          Result = clDbName;
          }
        else { print_in_string_void();
            princ_string(((char*)"t_"));
            c_princ_string(Dbo_dbName_module1(NOTNULL(Kernel.module_I,NOTNULL(Kernel.name,self->name)->module_I)));
            princ_string(((char*)"_"));
            c_princ_string(string_I_symbol(NOTNULL(Kernel.name,self->name)));
            { char * clDbName = GC_STRING(end_of_string_void());
              put_table(Dbo.DB_CLASS_NAME,_oid_(self),_string_(clDbName));
              Result = clDbName;
              }
            }
          }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// returns the table name of the object's class
// The c++ function for: dbName(self:object) []
CL_EXPORT char * Dbo_dbName_object1(ClaireObject *self) { 
    POP_SIGNAL; return (Dbo_dbName_class1(OWNER(_oid_(self))));}
  


// The c++ function for: dbName(self:module) []
CL_EXPORT char * Dbo_dbName_module1(module *self) { 
    POP_SIGNAL; return (string_I_symbol(self->name));}
  


//
//	get the list of dbProperties from a class/object
//
// including passwod -> create table
// The c++ function for: dbAllProperties(self:class) []
CL_EXPORT list * Dbo_dbAllProperties_class1(ClaireClass *self) { 
    
    GC_BIND;
    { list *Result ;
      { int loop_handle = ClEnv->cHandle;
        bag *v_list; OID v_val;
        OID p; CL_INT CLcount;
        { bag * p_in = self->slots;
          list * p_out = ((list *) empty_bag(p_in));
          { int loop_handle = ClEnv->cHandle;
            ITERATE(p);
            for (START(p_in); NEXT(p);)
            if (INHERIT(NOTNULL(Kernel.isa,NOTNULL(Kernel.selector,OBJECT(restriction,p)->selector)->isa),Dbo._dbProperty))
             p_out->addFast((OID)p);
            }
          v_list = GC_OBJECT(list,p_out);
          }
         Result = v_list->clone();
        for (CLcount= 1; CLcount <= v_list->length; CLcount++)
        { p = (*(v_list))[CLcount];
          v_val = _oid_(NOTNULL(Kernel.selector,OBJECT(restriction,p)->selector));
          
          (*((list *) Result))[CLcount] = v_val;}
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbAllProperties(self:object) []
CL_EXPORT list * Dbo_dbAllProperties_object1(ClaireObject *self) { 
    POP_SIGNAL; return (Dbo_dbProperties_class1(OWNER(_oid_(self))));}
  


// The c++ function for: dbProperties(self:class) []
CL_EXPORT list * Dbo_dbProperties_class1(ClaireClass *self) { 
    
    GC_BIND;
    { list *Result ;
      { int loop_handle = ClEnv->cHandle;
        bag *v_list; OID v_val;
        OID p; CL_INT CLcount;
        { bag * p_in = self->slots;
          list * p_out = ((list *) empty_bag(p_in));
          { int loop_handle = ClEnv->cHandle;
            ITERATE(p);
            for (START(p_in); NEXT(p);)
            if ((INHERIT(NOTNULL(Kernel.isa,NOTNULL(Kernel.selector,OBJECT(restriction,p)->selector)->isa),Dbo._dbProperty)) && 
                ((*Dbo.password_ask)(_oid_(NOTNULL(Kernel.selector,OBJECT(restriction,p)->selector))) != Kernel.ctrue))
             p_out->addFast((OID)p);
            }
          v_list = GC_OBJECT(list,p_out);
          }
         Result = v_list->clone();
        for (CLcount= 1; CLcount <= v_list->length; CLcount++)
        { p = (*(v_list))[CLcount];
          v_val = _oid_(NOTNULL(Kernel.selector,OBJECT(restriction,p)->selector));
          
          (*((list *) Result))[CLcount] = v_val;}
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbProperties(self:object) []
CL_EXPORT list * Dbo_dbProperties_object1(ClaireObject *self) { 
    POP_SIGNAL; return (Dbo_dbProperties_class1(OWNER(_oid_(self))));}
  


// The c++ function for: dbPropertiesButId(self:class) []
CL_EXPORT list * Dbo_dbPropertiesButId_class1(ClaireClass *self) { 
    
    GC_BIND;
    { list *Result ;
      { int loop_handle = ClEnv->cHandle;
        bag *v_list; OID v_val;
        OID p; CL_INT CLcount;
        { bag * p_in = self->slots;
          list * p_out = ((list *) empty_bag(p_in));
          { int loop_handle = ClEnv->cHandle;
            ITERATE(p);
            for (START(p_in); NEXT(p);)
            if ((INHERIT(NOTNULL(Kernel.isa,NOTNULL(Kernel.selector,OBJECT(restriction,p)->selector)->isa),Dbo._dbProperty)) && 
                (((*Dbo.id_ask)(_oid_(NOTNULL(Kernel.selector,OBJECT(restriction,p)->selector))) != Kernel.ctrue) && 
                  ((*Dbo.password_ask)(_oid_(NOTNULL(Kernel.selector,OBJECT(restriction,p)->selector))) != Kernel.ctrue)))
             p_out->addFast((OID)p);
            }
          v_list = GC_OBJECT(list,p_out);
          }
         Result = v_list->clone();
        for (CLcount= 1; CLcount <= v_list->length; CLcount++)
        { p = (*(v_list))[CLcount];
          v_val = _oid_(NOTNULL(Kernel.selector,OBJECT(restriction,p)->selector));
          
          (*((list *) Result))[CLcount] = v_val;}
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbPropertiesButId(self:object) []
CL_EXPORT list * Dbo_dbPropertiesButId_object1(ClaireObject *self) { 
    POP_SIGNAL; return (Dbo_dbPropertiesButId_class1(OWNER(_oid_(self))));}
  


// The c++ function for: dbPasswordProperty(self:class) []
CL_EXPORT Dbo_dbProperty * Dbo_dbPasswordProperty_class1(ClaireClass *self) { 
    
    GC_BIND;
    { Dbo_dbProperty *Result ;
      { list * l;
        { { int loop_handle = ClEnv->cHandle;
            bag *v_list; OID v_val;
            OID p; CL_INT CLcount;
            { bag * p_in = self->slots;
              list * p_out = ((list *) empty_bag(p_in));
              { int loop_handle = ClEnv->cHandle;
                ITERATE(p);
                for (START(p_in); NEXT(p);)
                if ((INHERIT(NOTNULL(Kernel.isa,NOTNULL(Kernel.selector,OBJECT(restriction,p)->selector)->isa),Dbo._dbProperty)) && 
                    ((OBJECT(ClaireBoolean,(*Dbo.password_ask)(_oid_(NOTNULL(Kernel.selector,OBJECT(restriction,p)->selector))))) == CTRUE))
                 p_out->addFast((OID)p);
                }
              v_list = GC_OBJECT(list,p_out);
              }
             l = v_list->clone();
            for (CLcount= 1; CLcount <= v_list->length; CLcount++)
            { p = (*(v_list))[CLcount];
              v_val = _oid_(NOTNULL(Kernel.selector,OBJECT(restriction,p)->selector));
              
              (*((list *) l))[CLcount] = v_val;}
            }
          GC_OBJECT(list,l);}
        if (boolean_I_any(_oid_(l)) != CTRUE)
         close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"The class ~S doesn't have any password dbProperty")),
          _oid_(list::alloc(1,_oid_(self))))));
        Result = OBJECT(Dbo_dbProperty,(*(l))[1]);
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dbPasswordProperty(self:object) []
CL_EXPORT Dbo_dbProperty * Dbo_dbPasswordProperty_object1(ClaireObject *self) { 
    POP_SIGNAL; return (Dbo_dbPasswordProperty_class1(OWNER(_oid_(self))));}
  


//
//	Using ids
//
// return the class's slot that represent an id
// The c++ function for: getIdProperty(self:class) []
CL_EXPORT Dbo_dbProperty * Dbo_getIdProperty_class1(ClaireClass *self) { 
    { Dbo_dbProperty *Result ;
      { property *V_CC ;
        { property * id = Kernel.isa;
          { int loop_handle = ClEnv->cHandle;
            ITERATE(p);
            for (START(self->slots); NEXT(p);)
            { property * sel = NOTNULL(Kernel.selector,OBJECT(restriction,p)->selector);
              if (INHERIT(NOTNULL(Kernel.isa,sel->isa),Dbo._dbProperty))
               { if ((CLREAD(Dbo_dbProperty,sel,password_ask) != CTRUE) && 
                    ((CLREAD(Dbo_dbProperty,sel,id_ask) == CTRUE) || 
                        (((CLREAD(Dbo_dbProperty,sel,idGenerator) == (NULL)) ? CTRUE : CFALSE) != CTRUE)))
                 { id= (sel);
                  { ;ClEnv->cHandle = loop_handle; break;}
                  }
                }
              }
            }
          if (id == Kernel.isa)
           close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"The class ~S doesn't have a dbProperty that is an id")),
            _oid_(list::alloc(1,_oid_(self))))));
          V_CC = id;
          }
        Result= (Dbo_dbProperty *) V_CC;}
      POP_SIGNAL; return (Result);}
    }
  


//	when idProp := some(p in dbProperties(self)|p.id? | known?(idGenerator, p))
//	in idProp
//	else error("The class ~S doesn't have a dbProperty that is an id", self)]
// return the object's class slot that represent an id
// The c++ function for: getIdProperty(self:object) []
CL_EXPORT Dbo_dbProperty * Dbo_getIdProperty_object1(ClaireObject *self) { 
    POP_SIGNAL; return (Dbo_getIdProperty_class1(OWNER(_oid_(self))));}
  


// return the object's class slot that represent an id
// The c++ function for: getAutoIncrementProperties(self:class) []
CL_EXPORT list * Dbo_getAutoIncrementProperties_class1(ClaireClass *self) { 
    
    GC_BIND;
    { list *Result ;
      { list * p_out = list::empty(Dbo._dbProperty);
        { int loop_handle = ClEnv->cHandle;
          ITERATE(p);
          bag *p_support;
          p_support = GC_OBJECT(list,Dbo_dbProperties_class1(self));
          for (START(p_support); NEXT(p);)
          if ((OBJECT(Dbo_dbProperty,p)->autoIncrement_ask == CTRUE) && 
              ((OBJECT(Dbo_dbProperty,p)->id_ask != CTRUE) && 
                (OBJECT(Dbo_dbProperty,p)->idGenerator == (NULL))))
           p_out->addFast((OID)p);
          }
        Result = GC_OBJECT(list,p_out);
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: getAutoIncrementProperties(self:object) []
CL_EXPORT list * Dbo_getAutoIncrementProperties_object1(ClaireObject *self) { 
    
    GC_BIND;
    { list *Result ;
      { list * g0097_out = list::empty(Dbo._dbProperty);
        { int loop_handle = ClEnv->cHandle;
          ITERATE(g0097);
          bag *g0097_support;
          g0097_support = GC_OBJECT(list,Dbo_dbProperties_class1(OWNER(_oid_(self))));
          for (START(g0097_support); NEXT(g0097);)
          if ((OBJECT(Dbo_dbProperty,g0097)->autoIncrement_ask == CTRUE) && 
              ((OBJECT(Dbo_dbProperty,g0097)->id_ask != CTRUE) && 
                (OBJECT(Dbo_dbProperty,g0097)->idGenerator == (NULL))))
           g0097_out->addFast((OID)g0097);
          }
        Result = GC_OBJECT(list,g0097_out);
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: getSimpleProperties(self:class) []
CL_EXPORT list * Dbo_getSimpleProperties_class1(ClaireClass *self) { 
    
    GC_BIND;
    { list *Result ;
      { list * p_out = list::empty(Dbo._dbProperty);
        { int loop_handle = ClEnv->cHandle;
          ITERATE(p);
          bag *p_support;
          p_support = GC_OBJECT(list,Dbo_dbProperties_class1(self));
          for (START(p_support); NEXT(p);)
          if ((OBJECT(Dbo_dbProperty,p)->autoIncrement_ask != CTRUE) && 
              ((OBJECT(Dbo_dbProperty,p)->id_ask != CTRUE) && 
                ((OBJECT(Dbo_dbProperty,p)->password_ask != CTRUE) && 
                  (OBJECT(Dbo_dbProperty,p)->idGenerator == (NULL)))))
           p_out->addFast((OID)p);
          }
        Result = GC_OBJECT(list,p_out);
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: getSimpleProperties(self:object) []
CL_EXPORT list * Dbo_getSimpleProperties_object1(ClaireObject *self) { 
    
    GC_BIND;
    { list *Result ;
      { list * g0098_out = list::empty(Dbo._dbProperty);
        { int loop_handle = ClEnv->cHandle;
          ITERATE(g0098);
          bag *g0098_support;
          g0098_support = GC_OBJECT(list,Dbo_dbProperties_class1(OWNER(_oid_(self))));
          for (START(g0098_support); NEXT(g0098);)
          if ((OBJECT(Dbo_dbProperty,g0098)->autoIncrement_ask != CTRUE) && 
              ((OBJECT(Dbo_dbProperty,g0098)->id_ask != CTRUE) && 
                ((OBJECT(Dbo_dbProperty,g0098)->password_ask != CTRUE) && 
                  (OBJECT(Dbo_dbProperty,g0098)->idGenerator == (NULL)))))
           g0098_out->addFast((OID)g0098);
          }
        Result = GC_OBJECT(list,g0098_out);
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// return the object's id assuming a dbProperty with id? = true exists
// The c++ function for: getDbId(self:object) []
CL_EXPORT OID  Dbo_getDbId_object1(ClaireObject *self) { 
    POP_SIGNAL; return (get_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
     (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
     (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self));}
  


// return the object's id assuming a dbProperty with id? = true exists
// The c++ function for: lookForObjectWithId(self:class,id:integer) []
CL_EXPORT OID  Dbo_lookForObjectWithId_class1(ClaireClass *self,CL_INT id) { 
    
    GC_BIND;
    { OID Result = 0;
      { OID  objtest = GC_OID(claire_nth_db_id_map1(OBJECT(Dbo_db_id_map,Dbo.DB_ID_MAP->value),self,id));
        if (objtest != CNULL)
         { ClaireObject * obj = OBJECT(ClaireObject,objtest);
          if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
           mtformat_module1(Dbo.it,((char*)"lookForObjectWithId(~S, ~S) => ~S (was mapped) \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(3,_oid_(self),
            ((OID)id),
            _oid_(obj))));
          else ;Result = _oid_(obj);
          }
        else { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(self);
            OID  obj;
            { { OID  o_some = CNULL;
                { int loop_handle = ClEnv->cHandle;
                  OID gc_local;
                  ITERATE(o);
                  bag *o_support;
                  o_support = GC_OBJECT(bag,enumerate_any(_oid_(self)));
                  for (START(o_support); NEXT(o);)
                  { GC_LOOP;
                    if ((*Kernel.get)(_oid_(idProp),
                      o) == ((OID)id))
                     { o_some= (o);
                      GC_UNLOOP;ClEnv->cHandle = loop_handle; break;}
                    GC_UNLOOP; POP_SIGNAL;}
                  }
                obj = o_some;
                }
              GC_OID(obj);}
            if (obj != CNULL)
             { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
               mtformat_module1(Dbo.it,((char*)"lookForObjectWithId(~S, ~S) => ~S (map it!) \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(3,_oid_(self),
                ((OID)id),
                obj)));
              else ;(*Kernel.nth_equal)(Dbo.DB_ID_MAP->value,
                _oid_(self),
                ((OID)id),
                obj);
              Result = obj;
              }
            else Result = CNULL;
              }
          }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// return the object's id assuming a dbProperty with id? = true exists
// The c++ function for: getObjectFromId(db:Db/Database,self:class,id:integer) []
CL_EXPORT OID  Dbo_getObjectFromId_Database1(Db_Database *db,ClaireClass *self,CL_INT id) { 
    
    GC_BIND;
    { OID Result = 0;
      { OID  objtest = GC_OID(Dbo_lookForObjectWithId_class1(self,id));
        if (objtest != CNULL)
         { ClaireObject * obj = OBJECT(ClaireObject,objtest);
          if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
           mtformat_module1(Dbo.it,((char*)"getObjectFromId(~S, ~S) => ~S (was mapped) \n"),((CL_INT)(OID)(1)),list::alloc(3,_oid_(self),
            ((OID)id),
            _oid_(obj)));
          else ;Result = _oid_(obj);
          }
        else { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(self);
            OID  genClass = _oid_(self);
            { ClaireType * gen = GC_OBJECT(ClaireType,idProp->idGenerator);
              if (gen == (NULL))
               ;else { Db_printInQuery_Database1(db);
                  princ_string(((char*)"SELECT "));
                  princ_string(Dbo_dbName_dbProperty1(Dbo.generatorClass));
                  princ_string(((char*)" FROM "));
                  princ_string(string_v((*Dbo.dbName)(_oid_(gen))));
                  princ_string(((char*)" WHERE "));
                  princ_string(Dbo_dbName_dbProperty1(Dbo.generatorId));
                  princ_string(((char*)" = "));
                  print_any(((OID)id));
                  if (Db_fetch_Database1(db) != CTRUE)
                   close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"getObjectFromId(~S, ~S), failed to fetch the generator class")),
                    _oid_(list::alloc(2,_oid_(self),((OID)id))))));
                  { OID  clDbName = GC_OID((*(Db_row_Database1(db)))[1]);
                    list * t = GC_OBJECT(list,OBJECT(list,(*Kernel.explode)(clDbName,
                      _string_(((char*)"/")))));
                    if (t->length == 2)
                     { OID  m = value_string(string_v((*(t))[1]));
                      if (m != CNULL)
                       genClass= (GC_OID((*Core.get_value)(m,
                        (*(t))[2])));
                      else genClass= (CNULL);
                        }
                    else { { OID  c_some = CNULL;
                          { int loop_handle = ClEnv->cHandle;
                            ITERATE(c);
                            bag *c_support;
                            c_support = Kernel._class->instances;
                            for (START(c_support); NEXT(c);)
                            if (((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(c))) == CTRUE) && 
                                (equal(_string_(Dbo_dbName_class1(OBJECT(ClaireClass,c))),clDbName) == CTRUE))
                             { c_some= (c);
                              ClEnv->cHandle = loop_handle; break;}
                            }
                          genClass = c_some;
                          }
                        GC_OID(genClass);}
                      }
                  if (inherit_ask_class(OWNER(genClass),Kernel._class) != CTRUE)
                   close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"in getObjectFromId(~S,~S), the string ~S is not a class")),
                    _oid_(list::alloc(3,_oid_(self),
                      ((OID)id),
                      GC_OID((*(Db_row_Database1(db)))[1]))))));
                  if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                   mtformat_module1(Dbo.it,((char*)"getObjectFromId, id ~S point to an object of class ~S \n"),((CL_INT)(OID)(1)),list::alloc(2,((OID)id),genClass));
                  else ;Db_popQuery_Database1(db);
                  }
                }
            { ClaireObject * o = GC_OBJECT(ClaireObject,new_class1(OBJECT(ClaireClass,genClass)));
              write_property(idProp,o,((OID)id));
              if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
               mtformat_module1(Dbo.it,((char*)"getObjectFromId(~S, ~S) => ~S (create new object of class ~S) \n"),((CL_INT)(OID)(1)),list::alloc(4,_oid_(self),
                ((OID)id),
                _oid_(o),
                genClass));
              else ;(*Kernel.nth_equal)(Dbo.DB_ID_MAP->value,
                genClass,
                ((OID)id),
                _oid_(o));
              Result = _oid_(o);
              }
            }
          }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


//
// return the last created autoincrement value
// use it after an SQL INSERT
// The c++ function for: getLastAutoIncrementedField(db:Db/Database,self:class,prop:dbProperty) []
CL_EXPORT OID  Dbo_getLastAutoIncrementedField_Database1(Db_Database *db,ClaireClass *self,Dbo_dbProperty *prop) { 
    
    GC_BIND;
    { OID Result = 0;
      { char * dbPropName = GC_STRING(Dbo_dbName_dbProperty1(prop));
        Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(self);
        Db_printInQuery_Database1(db);
        if (((OID)db->driverType) == (OID)(3))
         princ_string(((char*)"SELECT LAST_INSERT_ID()"));
        else if (((OID)db->driverType) == (OID)(4))
         princ_string(((char*)"SELECT @@IDENTITY"));
        else if (((OID)db->driverType) == (OID)(5))
         { princ_string(((char*)"SELECT currval('"));
          princ_string(lower_string(GC_STRING(Dbo_dbName_class1(self))));
          princ_string(((char*)"_"));
          princ_string(lower_string(dbPropName));
          princ_string(((char*)"_seq')"));
          }
        else { princ_string(((char*)"SELECT TOP 1 "));
            princ_string(dbPropName);
            princ_string(((char*)" FROM "));
            princ_string(Dbo_dbName_class1(self));
            princ_string(((char*)" ORDER BY "));
            princ_string(Dbo_dbName_dbProperty1(idProp));
            princ_string(((char*)" DESC"));
            }
          if (Db_fetch_Database1(db) == CTRUE)
         { OID  val = GC_OID(Db_field_Database2(db,1));
          if (val != CNULL)
           { Db_popQuery_Database1(db);
            Result = (*Kernel.integer_I)(val);
            }
          else Result = CNULL;
            }
        else Result = CNULL;
          }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: getLastAutoIncrementedField(db:Db/Database,self:object,prop:dbProperty) []
CL_EXPORT OID  Dbo_getLastAutoIncrementedField_Database2(Db_Database *db,ClaireObject *self,Dbo_dbProperty *prop) { 
    POP_SIGNAL; return (Dbo_getLastAutoIncrementedField_Database1(db,OWNER(_oid_(self)),prop));}
  


// return the last created
// use it after an SQL INSERT
// The c++ function for: getLastId(db:Db/Database,self:class) []
CL_EXPORT OID  Dbo_getLastId_Database1(Db_Database *db,ClaireClass *self) { 
    POP_SIGNAL; return (Dbo_getLastAutoIncrementedField_Database1(db,self,Dbo_getIdProperty_class1(self)));}
  


// The c++ function for: getLastId(db:Db/Database,self:object) []
CL_EXPORT OID  Dbo_getLastId_Database2(Db_Database *db,ClaireObject *self) { 
    POP_SIGNAL; return (Dbo_getLastId_Database1(db,OWNER(_oid_(self))));}
  


// The c++ function for: getRangesN-1(p:property,o:object) []
CL_EXPORT set * Dbo_getRangesN_dash1_property1(property *p,ClaireObject *o) { 
    
    GC_BIND;
    { set *Result ;
      { set * r_out = set::empty(Kernel.emptySet);
        { int loop_handle = ClEnv->cHandle;
          ITERATE(r);
          bag *r_support;
          r_support = GC_OBJECT(set,OBJECT(bag,(*Kernel.descendents)(GC_OID((*Core.t1)(GC_OID((*Kernel.range)(GC_OID(_oid_(_at_property1(p,OWNER(_oid_(o))))))))))));
          for (START(r_support); NEXT(r);)
          if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(r))) == CTRUE)
           r_out->addFast((OID)r);
          }
        Result = GC_OBJECT(set,r_out);
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: getRanges1-1Or1-N(p:property,o:object) []
CL_EXPORT set * Dbo_getRanges1_dash1Or1_dashN_property1(property *p,ClaireObject *o) { 
    
    GC_BIND;
    { set *Result ;
      { set * r_out = set::empty(Kernel.emptySet);
        { int loop_handle = ClEnv->cHandle;
          ITERATE(r);
          bag *r_support;
          r_support = GC_OBJECT(set,OBJECT(bag,(*Kernel.descendents)(GC_OID((*Kernel.range)(GC_OID(_oid_(_at_property1(p,OWNER(_oid_(o))))))))));
          for (START(r_support); NEXT(r);)
          if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(r))) == CTRUE)
           r_out->addFast((OID)r);
          }
        Result = GC_OBJECT(set,r_out);
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: getRange1-1(p:dbProperty,o:object) []
CL_EXPORT ClaireClass * Dbo_getRange1_dash1_dbProperty1(Dbo_dbProperty *p,ClaireObject *o) { 
    
    GC_BIND;
    { ClaireClass *Result ;
      Result = OBJECT(ClaireClass,(*Kernel.range)(GC_OID(_oid_(_at_property1(p,OWNER(_oid_(o)))))));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: getRange(p:property,o:object) []
CL_EXPORT OID  Dbo_getRange_property1(property *p,ClaireObject *o) { 
    
    GC_BIND;
    { OID Result = 0;
      { OID  r_some = CNULL;
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          ITERATE(r);
          bag *r_support;
          r_support = GC_OBJECT(set,OBJECT(bag,(*Kernel.descendents)(GC_OID((*Kernel.range)(GC_OID(_oid_(_at_property1(p,OWNER(_oid_(o))))))))));
          for (START(r_support); NEXT(r);)
          { GC_LOOP;
            if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(r))) == CTRUE)
             { r_some= (r);
              GC_UNLOOP;ClEnv->cHandle = loop_handle; break;}
            GC_UNLOOP; POP_SIGNAL;}
          }
        Result = r_some;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: getDbDescendents(self:class) []
CL_EXPORT ClaireType * Dbo_getDbDescendents_class1(ClaireClass *self) { 
    
    GC_BIND;
    { ClaireType *Result ;
      { list * c_out = list::empty(Kernel.emptySet);
        { int loop_handle = ClEnv->cHandle;
          ITERATE(c);
          for (START(self->descendents); NEXT(c);)
          if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(c))) == CTRUE)
           c_out->addFast((OID)c);
          }
        Result = GC_OBJECT(list,c_out);
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: Dbo_getDbDescendents_class1_type
CL_EXPORT ClaireType * Dbo_getDbDescendents_class1_type(ClaireType *self) { 
    POP_SIGNAL; return (nth_class1(Core._subtype,self));}
  


// returns the id an object that is pointed by a class's slot
// The c++ function for: idOf(db:Db/Database,self:object,prop:property) []
CL_EXPORT OID  Dbo_idOf_Database1(Db_Database *db,ClaireObject *self,property *prop) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"idOf@property(object = ~S, prop = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_oid_(prop)));
    else ;if (prop->inverse == (NULL))
     close_exception(((general_error *) (*Core._general_error)(_string_(((char*)"idOf@property ~S @ ~S (on ~S) as an unknown inverse")),
      _oid_(list::alloc(3,_oid_(prop),
        _oid_(OWNER(_oid_(self))),
        _oid_(self))))));
    { OID Result = 0;
      { OID  childRangetest;
        { { OID  g0099_some = CNULL;
            { int loop_handle = ClEnv->cHandle;
              OID gc_local;
              ITERATE(g0099);
              bag *g0099_support;
              g0099_support = GC_OBJECT(set,OBJECT(bag,(*Kernel.descendents)(GC_OID((*Kernel.range)(GC_OID(_oid_(_at_property1(prop,OWNER(_oid_(self))))))))));
              for (START(g0099_support); NEXT(g0099);)
              { GC_LOOP;
                if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(g0099))) == CTRUE)
                 { g0099_some= (g0099);
                  GC_UNLOOP;ClEnv->cHandle = loop_handle; break;}
                GC_UNLOOP; POP_SIGNAL;}
              }
            childRangetest = g0099_some;
            }
          GC_OID(childRangetest);}
        if (childRangetest != CNULL)
         { ClaireClass * childRange = OBJECT(ClaireClass,childRangetest);
          Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(childRange);
          OID  res;
          { { Db_printInQuery_Database1(db);
              if ((((OID)db->driverType) == (OID)(3)) || 
                  (((OID)db->driverType) == (OID)(5)))
               { princ_string(((char*)"SELECT "));
                princ_string(Dbo_dbName_dbProperty1(idProp));
                princ_string(((char*)" FROM "));
                princ_string(Dbo_dbName_class1(childRange));
                princ_string(((char*)" WHERE "));
                princ_string(string_v((*Dbo.dbName)(_oid_(NOTNULL(Kernel.inverse,prop->inverse)))));
                princ_string(((char*)"="));
                print_any(GC_OID(get_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
                 (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
                 (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self)));
                princ_string(((char*)" LIMIT 1"));
                }
              else { princ_string(((char*)"SELECT TOP 1 "));
                  princ_string(Dbo_dbName_dbProperty1(idProp));
                  princ_string(((char*)" FROM "));
                  princ_string(Dbo_dbName_class1(childRange));
                  princ_string(((char*)" WHERE "));
                  princ_string(string_v((*Dbo.dbName)(_oid_(NOTNULL(Kernel.inverse,prop->inverse)))));
                  princ_string(((char*)"="));
                  print_any(GC_OID(get_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
                   (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
                   (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self)));
                  }
                if (Db_fetch_Database1(db) == CTRUE)
               { OID  id = GC_OID(Db_field_Database1(db,GC_STRING(Dbo_dbName_dbProperty1(idProp))));
                if (id != CNULL)
                 { Db_popQuery_Database1(db);
                  res = (*Kernel.integer_I)(id);
                  }
                else res = CNULL;
                  }
              else res = CNULL;
                }
            GC_OID(res);}
          if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
           mtformat_module1(Dbo.it,((char*)"idOf@property => ~S \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(1,res)));
          else ;Result = res;
          }
        else Result = CNULL;
          }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// returns the id an object pointed by self.prop
// The c++ function for: idOf1-1(db:Db/Database,self:object,prop:dbProperty) []
CL_EXPORT OID  Dbo_idOf1_dash1_Database1(Db_Database *db,ClaireObject *self,Dbo_dbProperty *prop) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"idOf1-1@dbProperty(object = ~S, prop = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_oid_(prop)));
    else ;{ OID Result = 0;
      { Dbo_dbProperty * idProp = Dbo_getIdProperty_class1(OWNER(_oid_(self)));
        OID  res;
        { { Db_printInQuery_Database1(db);
            if ((((OID)db->driverType) == (OID)(3)) || 
                (((OID)db->driverType) == (OID)(5)))
             { princ_string(((char*)"SELECT "));
              princ_string(Dbo_dbName_dbProperty1(prop));
              princ_string(((char*)" FROM "));
              princ_string(Dbo_dbName_class1(OWNER(_oid_(self))));
              princ_string(((char*)" WHERE "));
              princ_string(Dbo_dbName_dbProperty1(idProp));
              princ_string(((char*)"="));
              print_any(GC_OID(get_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
               (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
               (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self)));
              princ_string(((char*)" LIMIT 1"));
              }
            else { princ_string(((char*)"SELECT TOP 1 "));
                princ_string(Dbo_dbName_dbProperty1(prop));
                princ_string(((char*)" FROM "));
                princ_string(Dbo_dbName_class1(OWNER(_oid_(self))));
                princ_string(((char*)" WHERE "));
                princ_string(Dbo_dbName_dbProperty1(idProp));
                princ_string(((char*)"="));
                print_any(GC_OID(get_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
                 (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
                 (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self)));
                }
              if (Db_fetch_Database1(db) == CTRUE)
             { OID  id = GC_OID(Db_field_Database1(db,GC_STRING(Dbo_dbName_dbProperty1(prop))));
              if (id != CNULL)
               { Db_popQuery_Database1(db);
                res = (*Kernel.integer_I)(id);
                }
              else res = CNULL;
                }
            else res = CNULL;
              }
          GC_OID(res);}
        if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
         mtformat_module1(Dbo.it,((char*)"idOf1-1@dbProperty => ~S \n"),((CL_INT)(OID)(1)),list::alloc(1,res));
        else ;Result = res;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: idOfForRange(db:Db/Database,self:object,prop:dbProperty,childRange:class) []
CL_EXPORT OID  Dbo_idOfForRange_Database1(Db_Database *db,ClaireObject *self,Dbo_dbProperty *prop,ClaireClass *childRange) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"idOfForRange(object = ~S, prop = ~S, childRange = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(3,_oid_(self),
      _oid_(prop),
      _oid_(childRange)));
    else ;{ OID Result = 0;
      { Dbo_dbProperty * childIdProp = Dbo_getIdProperty_class1(childRange);
        OID  idProp = _oid_((INHERIT(self->isa,Kernel._class) ?
         (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
         (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)));
        Db_printInQuery_Database1(db);
        if ((((OID)db->driverType) == (OID)(3)) || 
            (((OID)db->driverType) == (OID)(5)))
         { princ_string(((char*)"SELECT "));
          princ_string(Dbo_dbName_class1(childRange));
          princ_string(((char*)"."));
          princ_string(Dbo_dbName_dbProperty1(childIdProp));
          princ_string(((char*)" FROM "));
          if (OWNER(_oid_(self)) == childRange)
           princ_string(Dbo_dbName_class1(childRange));
          else { princ_string(Dbo_dbName_class1(childRange));
              princ_string(((char*)","));
              princ_string(string_v((*Dbo.dbName)(_oid_(self))));
              }
            princ_string(((char*)" WHERE "));
          princ_string(string_v((*Dbo.dbName)(_oid_(self))));
          princ_string(((char*)"."));
          princ_string(Dbo_dbName_dbProperty1(OBJECT(Dbo_dbProperty,idProp)));
          princ_string(((char*)"="));
          print_any(GC_OID(get_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
           (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
           (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self)));
          princ_string(((char*)" AND "));
          princ_string(Dbo_dbName_class1(childRange));
          princ_string(((char*)"."));
          princ_string(Dbo_dbName_dbProperty1(childIdProp));
          princ_string(((char*)"="));
          princ_string(string_v((*Dbo.dbName)(_oid_(self))));
          princ_string(((char*)"."));
          princ_string(Dbo_dbName_dbProperty1(prop));
          princ_string(((char*)" LIMIT 1"));
          }
        else { princ_string(((char*)"SELECT TOP 1 "));
            princ_string(Dbo_dbName_class1(childRange));
            princ_string(((char*)"."));
            princ_string(Dbo_dbName_dbProperty1(childIdProp));
            princ_string(((char*)" FROM "));
            if (OWNER(_oid_(self)) == childRange)
             princ_string(Dbo_dbName_class1(childRange));
            else { princ_string(Dbo_dbName_class1(childRange));
                princ_string(((char*)","));
                princ_string(string_v((*Dbo.dbName)(_oid_(self))));
                }
              princ_string(((char*)" WHERE "));
            princ_string(string_v((*Dbo.dbName)(_oid_(self))));
            princ_string(((char*)"."));
            princ_string(Dbo_dbName_dbProperty1(OBJECT(Dbo_dbProperty,idProp)));
            princ_string(((char*)"="));
            print_any(GC_OID(get_property(OBJECT(property,_oid_((INHERIT(self->isa,Kernel._class) ?
             (ClaireObject *) Dbo_getIdProperty_class1((ClaireClass *) OBJECT(ClaireClass,_oid_(self))) : 
             (ClaireObject *)  Dbo_getIdProperty_object1((ClaireObject *) self)))),self)));
            princ_string(((char*)" AND "));
            princ_string(Dbo_dbName_class1(childRange));
            princ_string(((char*)"."));
            princ_string(Dbo_dbName_dbProperty1(childIdProp));
            princ_string(((char*)"="));
            princ_string(string_v((*Dbo.dbName)(_oid_(self))));
            princ_string(((char*)"."));
            princ_string(Dbo_dbName_dbProperty1(prop));
            }
          if (Db_fetch_Database1(db) == CTRUE)
         { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
           mtformat_module1(Dbo.it,((char*)"idOfForRange row(~A) \n"),((CL_INT)(OID)(1)),list::alloc(1,GC_OID(_oid_(Db_row_Database1(db)))));
          else ;flush_port1(GC_OBJECT(PortObject,OBJECT(PortObject,Core.cl_stdout->value)));
          { OID  id = GC_OID(Db_field_Database1(db,GC_STRING(Dbo_dbName_dbProperty1(childIdProp))));
            if (id != CNULL)
             { Db_popQuery_Database1(db);
              Result = (*Kernel.integer_I)(id);
              }
            else { Db_popQuery_Database1(db);
                Result = CNULL;
                }
              }
          }
        else { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
             mtformat_module1(Dbo.it,((char*)"idOfForRange empty row\n"),((CL_INT)(OID)(1)),list::empty());
            else ;Result = CNULL;
            }
          }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: idOf(db:Db/Database,self:object,prop:dbProperty) []
CL_EXPORT OID  Dbo_idOf_Database2(Db_Database *db,ClaireObject *self,Dbo_dbProperty *prop) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"idOf@dbProperty(object = ~S, prop = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_oid_(prop)));
    else ;{ OID Result = 0;
      { OID  i_some = CNULL;
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          ITERATE(i);
          bag *i_support;
          { set * rng_bag = set::empty(Kernel.emptySet);
            { int loop_handle = ClEnv->cHandle;
              OID gc_local;
              ITERATE(rng);
              bag *rng_support;
              rng_support = GC_OBJECT(set,OBJECT(bag,(*Kernel.descendents)(GC_OID((*Kernel.range)(GC_OID(_oid_(_at_property1(prop,OWNER(_oid_(self))))))))));
              for (START(rng_support); NEXT(rng);)
              { GC_LOOP;
                if ((OBJECT(ClaireBoolean,(*Dbo.dbStore_ask)(rng))) == CTRUE)
                 rng_bag->addFast((OID)GC_OID((*Dbo.idOfForRange)(_oid_(db),
                  _oid_(self),
                  _oid_(prop),
                  rng)));
                GC_UNLOOP; POP_SIGNAL;}
              }
            i_support = GC_OBJECT(set,rng_bag);
            }
          for (START(i_support); NEXT(i);)
          { GC_LOOP;
            if (i != CNULL)
             { i_some= (i);
              GC_UNLOOP;ClEnv->cHandle = loop_handle; break;}
            GC_UNLOOP; POP_SIGNAL;}
          }
        Result = i_some;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// load a list of value 
// The c++ function for: dbLoadValue(db:Db/Database,prop:dbProperty,from:class,wheres:list[tuple(dbProperty, any)],distinct?:boolean,asc?:(boolean U {unknown})) []
CL_EXPORT list * Dbo_dbLoadValue_Database1(Db_Database *db,Dbo_dbProperty *prop,ClaireClass *from,list *wheres,ClaireBoolean *distinct_ask,OID asc_ask) { 
    
    GC_RESERVE(1);  // v3.3.39 optim !
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"idOf@dbGetListValue(prop = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(1,_oid_(prop)));
    else ;{ list *Result ;
      { list * result = list::empty(Kernel._string);
        Db_printInQuery_Database1(db);
        princ_string(((char*)"SELECT "));
        if (distinct_ask == CTRUE)
         princ_string(((char*)"DISTINCT"));
        princ_string(((char*)" "));
        princ_string(Dbo_dbName_dbProperty1(prop));
        princ_string(((char*)" FROM "));
        princ_string(Dbo_dbName_class1(from));
        princ_string(((char*)" "));
        Dbo_printWhereAnd_Database1(db,wheres);
        princ_string(((char*)" "));
        { OID  _asc_asktest = asc_ask;
          if (_asc_asktest != CNULL)
           { ClaireBoolean * _asc_ask = OBJECT(ClaireBoolean,_asc_asktest);
            princ_string(((char*)" ORDER BY "));
            princ_string(Dbo_dbName_dbProperty1(prop));
            princ_string(((char*)" "));
            princ_string(((_asc_ask == CTRUE) ?
              ((char*)"ASC") :
              ((char*)"DESC") ));
            }
          else ;}
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          while ((Db_fetch_Database1(db) == CTRUE))
          { GC_LOOP;
            { OID  val = GC_OID((*(Db_row_Database1(db)))[1]);
              if (val != CNULL)
               GC__ANY(result = result->addFast((OID)val), 1);
              else ;}
            GC_UNLOOP;POP_SIGNAL;}
          }
        Result = result;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// load a list of value 
// The c++ function for: dbGetMaxIntValue(db:Db/Database,prop:dbProperty,from:class,wheres:list[tuple(dbProperty, any)]) []
CL_EXPORT CL_INT  Dbo_dbGetMaxIntValue_Database1(Db_Database *db,Dbo_dbProperty *prop,ClaireClass *from,list *wheres) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"idOf@dbGetListValue(prop = ~S) \n"),((CL_INT)(OID)(1)),list::alloc(1,_oid_(prop)));
    else ;{ CL_INT Result = 0;
      { CL_INT  result = 0;
        Db_printInQuery_Database1(db);
        princ_string(((char*)"SELECT  MAX("));
        princ_string(Dbo_dbName_dbProperty1(prop));
        princ_string(((char*)") FROM "));
        princ_string(Dbo_dbName_class1(from));
        princ_string(((char*)" "));
        Dbo_printWhereAnd_Database1(db,wheres);
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          while ((Db_fetch_Database1(db) == CTRUE))
          { GC_LOOP;
            { OID  val = GC_OID((*(Db_row_Database1(db)))[1]);
              if (val != CNULL)
               result= (CL_INT)(((CL_INT)(*Kernel.integer_I)(val)));
              else ;}
            GC_UNLOOP;POP_SIGNAL;}
          }
        Result = result;
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: get_dbUpdate_version(r:method) []
CL_EXPORT CL_INT  Dbo_get_dbUpdate_version_method1(method *r) { 
    { CL_INT Result = 0;
      { OID  v = (*(r->domain))[3];
        Result = ((Kernel._set == NOTNULL(Kernel.isa,OBJECT(ClaireObject,v)->isa)) ?
          ((CL_INT)(*(OBJECT(bag,v)))[1]) :
          0 );
        }
      POP_SIGNAL; return (Result);}
    }
  


// The c++ function for: dispatch_updates(self:Db/Database,cat:string) []
CL_EXPORT void  Dbo_dispatch_updates_Database1(Db_Database *self,char *cat) { 
    
    GC_BIND;
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"dispatch_updates(~S,~S) \n"),((CL_INT)(OID)(1)),list::alloc(2,_oid_(self),_string_(cat)));
    else ;if (contain_ask_list(Db_tables_Database1(self),_string_(((char*)"t_db_version"))) != CTRUE)
     { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
       mtformat_module1(Dbo.it,((char*)"creating t_db_version\n"),((CL_INT)(OID)(1)),list::empty());
      else ;claire_execute_Database1(self,((char*)"CREATE TABLE t_db_version (version int, module varchar(255), last_update timestamp)"));
      }
    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
     mtformat_module1(Dbo.it,((char*)"<sb> propagate updates\n"),((CL_INT)(OID)(1)),list::empty());
    else ;{ int loop_handle = ClEnv->cHandle;
      OID gc_local;
      ITERATE(g0101);
      bag *g0101_support;
      g0101_support = Kernel._module->descendents;
      for (START(g0101_support); NEXT(g0101);)
      { GC_LOOP;
        { ClaireBoolean * g0102;
          { OID V_C;{ int loop_handle = ClEnv->cHandle;
              OID gc_local;
              ITERATE(m);
              V_C= Kernel.cfalse;
              for (START(OBJECT(ClaireClass,g0101)->instances); NEXT(m);)
              { GC_LOOP;
                if (m != _oid_(Dbo.it))
                 { OID  dbUpdate = value_module(OBJECT(module,m),((char*)"db_update_model"));
                  if (dbUpdate != CNULL)
                   { CL_INT  top_version = 0;
                    CL_INT  current_version = -1;
                    char * modname;
                    { { print_in_string_void();
                        c_princ_string(NOTNULL(Kernel.name,OBJECT(thing,m)->name->name));
                        modname = end_of_string_void();
                        }
                      GC_STRING(modname);}
                    char * date_value = GC_STRING(strftime_string(string_v(nth_table2(Db.SQL_TYPES,(OID)(21),((OID)self->driverType))),now_void()));
                    list * rs;
                    { { list * r_out = list::empty(Kernel.emptySet);
                        { int loop_handle = ClEnv->cHandle;
                          ITERATE(r);
                          bag *r_support;
                          r_support = GC_OBJECT(list,OBJECT(bag,(*Kernel.restrictions)(dbUpdate)));
                          for (START(r_support); NEXT(r);)
                          if ((OBJECT(restriction,r)->domain->length == 3) && 
                              ((_oid_(NOTNULL(Kernel.module_I,OBJECT(restriction,r)->module_I)) == m) && 
                                ((_inf_equal_type(OBJECT(ClaireType,(*(OBJECT(restriction,r)->domain))[1]),Db._Database) == CTRUE) && 
                                  ((belong_to((*(OBJECT(restriction,r)->domain))[2],_oid_(nth_class1(Kernel._type,Kernel._string))) == CTRUE) && 
                                    ((belong_to(_string_(cat),(*(OBJECT(restriction,r)->domain))[2]) == CTRUE) && 
                                      (belong_to((*(OBJECT(restriction,r)->domain))[3],_oid_(nth_class1(Kernel._type,Kernel._integer))) == CTRUE))))))
                           r_out->addFast((OID)r);
                          }
                        rs = GC_OBJECT(list,r_out);
                        }
                      GC_OBJECT(list,rs);}
                    if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                     mtformat_module1(Dbo.it,((char*)"updating for module ~S \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(1,m)));
                    else ;if (rs->length != 0)
                     { if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                       mtformat_module1(Dbo.it,((char*)"... found restrictions ... \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::empty()));
                      else ;{ int loop_handle = ClEnv->cHandle;
                        ITERATE(r);
                        for (START(rs); NEXT(r);)
                        top_version= (CL_INT)(max_integer1(top_version,((CL_INT)(*Dbo.get_dbUpdate_version)(r))));
                        }
                      if (should_trace_ask_module1(Dbo.it,((CL_INT)(OID)(1))) == CTRUE)
                       mtformat_module1(Dbo.it,((char*)"top_version := ~A \n"),((CL_INT)(OID)(1)),GC_OBJECT(list,list::alloc(1,((OID)top_version))));
                      else ;claire_execute_Database1(self,GC_STRING(append_string(GC_STRING(append_string(((char*)"SELECT version from t_db_version where module = '"),modname)),((char*)"'"))));
                      { int loop_handle = ClEnv->cHandle;
                        OID gc_local;
                        while ((Db_fetch_Database1(self) == CTRUE))
                        { GC_LOOP;
                          current_version= (CL_INT)(((CL_INT)(*Kernel.integer_I)(GC_OID(Db_field_Database2(self,1)))));
                          GC_UNLOOP;POP_SIGNAL;}
                        }
                      if (current_version == ((CL_INT)-1))
                       { current_version= (CL_INT)(0);
                        claire_execute_Database1(self,GC_STRING(append_string(GC_STRING(append_string(GC_STRING(append_string(GC_STRING(append_string(GC_STRING(append_string(GC_STRING(append_string(((char*)"INSERT INTO t_db_version (version, module, last_update) values ("),GC_STRING(string_I_integer (current_version)))),((char*)", '"))),modname)),((char*)"', "))),date_value)),((char*)")"))));
                        }
                      if (current_version == top_version)
                       { if (should_trace_ask_module1(Dbo.it,-100) == CTRUE)
                         mtformat_module1(Dbo.it,((char*)"== db_update_model(~S) => module ~S up to date (version ~S) \n"),-100,GC_OBJECT(list,list::alloc(3,_oid_(self),
                          m,
                          ((OID)current_version))));
                        else ;}
                      { CL_INT  v = ((CL_INT)current_version+(CL_INT)1);
                        CL_INT  g0103 = top_version;
                        { int loop_handle = ClEnv->cHandle;
                          OID gc_local;
                          while (((CL_INT)v <= (CL_INT)g0103))
                          { GC_LOOP;
                            { int loop_handle = ClEnv->cHandle;
                              OID gc_local;
                              ITERATE(r);
                              for (START(rs); NEXT(r);)
                              { GC_LOOP;
                                { CL_INT  vr = ((CL_INT)(*Dbo.get_dbUpdate_version)(r));
                                  if (v == vr)
                                   { if (should_trace_ask_module1(Dbo.it,-100) == CTRUE)
                                     mtformat_module1(Dbo.it,((char*)"== db_update_model(~S) => update module ~S to version ~S \n"),-100,GC_OBJECT(list,list::alloc(3,_oid_(self),
                                      m,
                                      ((OID)v))));
                                    else ;(*Core.apply)(r,
                                      GC_OID(_oid_(list::alloc(3,_oid_(self),
                                        _string_(cat),
                                        ((OID)v)))));
                                    claire_execute_Database1(self,GC_STRING(append_string(GC_STRING(append_string(GC_STRING(append_string(GC_STRING(append_string(GC_STRING(append_string(GC_STRING(append_string(GC_STRING(append_string(((char*)"UPDATE t_db_version set "),((char*)"version = "))),GC_STRING(string_I_integer (v)))),((char*)", last_update = "))),date_value)),((char*)" where module = '"))),modname)),((char*)"'"))));
                                    }
                                  }
                                GC_UNLOOP; POP_SIGNAL;}
                              }
                            ++v;
                            GC_UNLOOP;POP_SIGNAL;}
                          }
                        }
                      }
                    }
                  else ;}
                GC_UNLOOP; POP_SIGNAL;}
              }
            
            g0102=OBJECT(ClaireBoolean,V_C);}
          if (g0102 == CTRUE)
           { ;GC_UNLOOP;ClEnv->cHandle = loop_handle; break;}
          }
        GC_UNLOOP; POP_SIGNAL;}
      }
    GC_UNBIND; POP_SIGNAL;}
  


// Verification de l'existance d'une table
// The c++ function for: check_table_exists(db:Db/Database,t_name:string) []
CL_EXPORT ClaireBoolean * Dbo_check_table_exists_Database1(Db_Database *db,char *t_name) { 
    
    GC_BIND;
    { ClaireBoolean *Result ;
      { OID  g0104UU;
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          ITERATE(i);
          g0104UU= Kernel.cfalse;
          bag *i_support;
          i_support = GC_OBJECT(list,Db_tables_Database1(db));
          for (START(i_support); NEXT(i);)
          { GC_LOOP;
            if (equal(GC_OID(_string_(lower_string(string_v(i)))),GC_OID(_string_(lower_string(t_name)))) == CTRUE)
             { GC_UNLOOP;g0104UU = Kernel.ctrue;
              ClEnv->cHandle = loop_handle;break;}
            GC_UNLOOP; POP_SIGNAL;}
          }
        Result = boolean_I_any(g0104UU);
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// Verification de l'existance d'une table
// The c++ function for: check_table_exists(db:Db/Database,t_class:class) []
CL_EXPORT ClaireBoolean * Dbo_check_table_exists_Database2(Db_Database *db,ClaireClass *t_class) { 
    
    GC_BIND;
    { ClaireBoolean *Result ;
      Result = Dbo_check_table_exists_Database1(db,GC_STRING(Dbo_dbName_class1(t_class)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// Verification de l'existance d'une colonne
// The c++ function for: check_column_exists(db:Db/Database,t_name:string,c_name:string) []
CL_EXPORT ClaireBoolean * Dbo_check_column_exists_Database1(Db_Database *db,char *t_name,char *c_name) { 
    
    GC_BIND;
    { ClaireBoolean *Result ;
      { OID  g0105UU;
        { int loop_handle = ClEnv->cHandle;
          OID gc_local;
          ITERATE(i);
          g0105UU= Kernel.cfalse;
          bag *i_support;
          i_support = GC_OBJECT(list,Db_columns_Database1(db,t_name));
          for (START(i_support); NEXT(i);)
          { GC_LOOP;
            if (equal(GC_OID(_string_(lower_string(GC_STRING(NOTNULL(Kernel.name,OBJECT(Db_Column,i)->name))))),GC_OID(_string_(lower_string(c_name)))) == CTRUE)
             { GC_UNLOOP;g0105UU = Kernel.ctrue;
              ClEnv->cHandle = loop_handle;break;}
            GC_UNLOOP; POP_SIGNAL;}
          }
        Result = boolean_I_any(g0105UU);
        }
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


// Verification de l'existance d'une colonne
// The c++ function for: check_column_exists(db:Db/Database,t_class:class,c_prop:dbProperty) []
CL_EXPORT ClaireBoolean * Dbo_check_column_exists_Database2(Db_Database *db,ClaireClass *t_class,Dbo_dbProperty *c_prop) { 
    
    GC_BIND;
    { ClaireBoolean *Result ;
      Result = Dbo_check_column_exists_Database1(db,GC_STRING(Dbo_dbName_class1(t_class)),GC_STRING(Dbo_dbName_dbProperty1(c_prop)));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


//<xp> Check if an index exist on a column
// The c++ function for: Db/index?(self:Db/Database,t_class:class,c_prop:dbProperty) []
CL_EXPORT ClaireBoolean * Db_index_ask_Database2(Db_Database *self,ClaireClass *t_class,Dbo_dbProperty *c_prop) { 
    
    GC_BIND;
    { ClaireBoolean *Result ;
      Result = OBJECT(ClaireBoolean,check_in_any(GC_OID((*Db.dbIndexExists_ask)(_oid_(self),
        GC_OID(_string_(Dbo_dbName_class1(t_class))),
        GC_OID(_string_(Dbo_dbName_dbProperty1(c_prop))))),Kernel._boolean));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


//<xp> Check if an index exist on a column
// The c++ function for: Db/index?(self:Db/Database,t_class:class,index_name:string) []
CL_EXPORT ClaireBoolean * Db_index_ask_Database3(Db_Database *self,ClaireClass *t_class,char *index_name) { 
    
    GC_BIND;
    { ClaireBoolean *Result ;
      Result = OBJECT(ClaireBoolean,check_in_any(GC_OID((*Db.dbIndexExists_ask)(_oid_(self),
        GC_OID(_string_(Dbo_dbName_class1(t_class))),
        _string_(index_name))),Kernel._boolean));
      GC_UNBIND; POP_SIGNAL; return (Result);}
    }
  


//<xp> Check if an index exist on a column
// The c++ function for: Db/index?(self:Db/Database,t_class:string,index_name:string) []
CL_EXPORT ClaireBoolean * Db_index_ask_Database4(Db_Database *self,char *t_class,char *index_name) { 
    POP_SIGNAL; return (OBJECT(ClaireBoolean,check_in_any((*Db.dbIndexExists_ask)(_oid_(self),
      _string_(t_class),
      _string_(index_name)),Kernel._boolean)));}
  




  

extern "C" CL_EXPORT void dynLoadDbo() 
{ Dbo.initModule("Dbo",Db.it,list::alloc(Kernel._module,6,_oid_(Core.it),
      _oid_(Reader.it),
      _oid_(Db.it),
      _oid_(Serialize.it),
      _oid_(Xmlo.it),
      _oid_(clZlib.it)),
    "source",list::alloc(Kernel._string,12,_string_(((char*)"error")),
      _string_(((char*)"model")),
      _string_(((char*)"dbprint")),
      _string_(((char*)"create")),
      _string_(((char*)"delete")),
      _string_(((char*)"dbrelationships")),
      _string_(((char*)"update")),
      _string_(((char*)"load")),
      _string_(((char*)"db_get_erase")),
      _string_(((char*)"dbtables")),
      _string_(((char*)"copy")),
      _string_(((char*)"dbtools"))));
    Dbo.metaLoad();
    Dbo.it->version = "v1.0.0";
    }
  /***** CLAIRE Compilation of file Dbo.cl 
         [version 3.7.0 / safety 3] *****/



CL_EXPORT DboClass Dbo;

// definition of the meta-model for Dbo
  void DboClass::metaLoad() { 
    
    ClEnv->module_I = it;
// definition of the properties 
    
    Dbo.make_utc_date = property::make("make_utc_date",Dbo.it);
    Dbo.autoIncrement_ask = property::make("autoIncrement?",Dbo.it);
    Dbo.fieldName = property::make("fieldName",Dbo.it);
    Dbo.password_ask = property::make("password?",Dbo.it);
    Dbo.dbSqlType = property::make("dbSqlType",Dbo.it);
    Dbo.dbSqlBlobFile_ask = property::make("dbSqlBlobFile?",Dbo.it);
    Dbo.dbSqlPrecision = property::make("dbSqlPrecision",Dbo.it);
    Dbo.dbSqlDigit = property::make("dbSqlDigit",Dbo.it);
    Dbo.xssFilter = property::make("xssFilter",2,Dbo.it);
    Dbo.null_ask = property::make("null?",Dbo.it);
    Dbo.id_ask = property::make("id?",Dbo.it);
    Dbo.idGenerator = property::make("idGenerator",Dbo.it);
    Dbo.map = property::make("map",Dbo.it);
    Dbo.dbName = property::make("dbName",Dbo.it);
    Dbo.getDbId = property::make("getDbId",Dbo.it);
    Dbo.dbPrintBag = property::make("dbPrintBag",Dbo.it);
    Dbo.dbPrintDate = property::make("dbPrintDate",3,Dbo.it);
    Dbo.dbPrintValue = property::make("dbPrintValue",Dbo.it);
    Dbo.print_string_list = property::make("print_string_list",Dbo.it);
    Dbo.filePath = property::make("filePath",Dbo.it);
    Dbo.dbPrintInFile = property::make("dbPrintInFile",Dbo.it);
    Dbo.isBlob_ask = property::make("isBlob?",Dbo.it);
    Dbo.printList = property::make("printList",Dbo.it);
    Dbo.printAffects = property::make("printAffects",Dbo.it);
    Dbo.printWhereAnd = property::make("printWhereAnd",Dbo.it);
    Dbo.printType = property::make("printType",Dbo.it);
    Dbo.printFieldDefinitions = property::make("printFieldDefinitions",Dbo.it);
    Dbo.dbCreateSimple = property::make("dbCreateSimple",Dbo.it);
    Dbo.getIdProperty = property::make("getIdProperty",Dbo.it);
    Dbo.getAutoIncrementProperties = property::make("getAutoIncrementProperties",Dbo.it);
    Dbo.getLastId = property::make("getLastId",Dbo.it);
    Dbo.getLastAutoIncrementedField = property::make("getLastAutoIncrementedField",Dbo.it);
    Dbo.storeBlobFiles = property::make("storeBlobFiles",Dbo.it);
    Dbo.dbCreateWithGenerator = property::make("dbCreateWithGenerator",Dbo.it);
    Dbo.getSimpleProperties = property::make("getSimpleProperties",Dbo.it);
    Dbo.dbCreate = property::make("dbCreate",Dbo.it);
    Dbo.dbDelete = property::make("dbDelete",Dbo.it);
    Dbo.getDbDescendents = property::make("getDbDescendents",Dbo.it);
    Dbo.dbCount = property::make("dbCount",Dbo.it);
    Dbo.db_0_ask = property::make("db_0?",Dbo.it);
    Dbo.db_1_dash1_ask = property::make("db_1-1?",Dbo.it);
    Dbo.db_N_dash1_ask = property::make("db_N-1?",Dbo.it);
    Dbo.db_1_dashN_ask = property::make("db_1-N?",Dbo.it);
    Dbo.dbUpdate = property::make("dbUpdate",Dbo.it);
    Dbo.dbProperties = property::make("dbProperties",Dbo.it);
    Dbo.extract_string_list = property::make("extract_string_list",Dbo.it);
    Dbo.dbReadFromFile = property::make("dbReadFromFile",Dbo.it);
    Dbo.getObjectFromId = property::make("getObjectFromId",Dbo.it);
    Dbo.set_value_I = property::make("set_value!",Dbo.it);
    Dbo.list_value_I = property::make("list_value!",Dbo.it);
    Dbo.updateValuesFromRow = property::make("updateValuesFromRow",Dbo.it);
    Dbo.loadObjectListFromRows = property::make("loadObjectListFromRows",Dbo.it);
    Dbo.lookForObjectWithId = property::make("lookForObjectWithId",Dbo.it);
    Dbo.dbLoad = property::make("dbLoad",Dbo.it);
    Dbo.dbLoadWhere = property::make("dbLoadWhere",Dbo.it);
    Dbo.dbValidPassword_ask = property::make("dbValidPassword?",Dbo.it);
    Dbo.dbPasswordProperty = property::make("dbPasswordProperty",Dbo.it);
    Dbo.dbUpdatePassword = property::make("dbUpdatePassword",Dbo.it);
    Dbo.print_int = property::make("print_int",Dbo.it);
    Dbo.extract_int = property::make("extract_int",Dbo.it);
    Dbo.dbGetId = property::make("dbGetId",Dbo.it);
    Dbo.idOf1_dash1 = property::make("idOf1-1",Dbo.it);
    Dbo.dbGet = property::make("dbGet",Dbo.it);
    Dbo.getRangesN_dash1 = property::make("getRangesN-1",Dbo.it);
    Dbo.idOf = property::make("idOf",Dbo.it);
    Dbo.getRange1_dash1 = property::make("getRange1-1",Dbo.it);
    Dbo.getRange = property::make("getRange",Dbo.it);
    Dbo.dbErase = property::make("dbErase",Dbo.it);
    Dbo.dbDrop = property::make("dbDrop",Dbo.it);
    Dbo.dbCreateTable = property::make("dbCreateTable",Dbo.it);
    Dbo.dbAllProperties = property::make("dbAllProperties",Dbo.it);
    Dbo.dbCreateIndex = property::make("dbCreateIndex",Dbo.it);
    Dbo.dbCopy = property::make("dbCopy",3,Dbo.it);
    Dbo.dbPropertiesButId = property::make("dbPropertiesButId",Dbo.it);
    Dbo.getRanges1_dash1Or1_dashN = property::make("getRanges1-1Or1-N",Dbo.it);
    Dbo.idOfForRange = property::make("idOfForRange",Dbo.it);
    Dbo.dbLoadValue = property::make("dbLoadValue",Dbo.it);
    Dbo.dbGetMaxIntValue = property::make("dbGetMaxIntValue",Dbo.it);
    Dbo.get_dbUpdate_version = property::make("get_dbUpdate_version",Dbo.it);
    Dbo.dispatch_updates = property::make("dispatch_updates",Dbo.it);
    Dbo.check_table_exists = property::make("check_table_exists",Dbo.it);
    Dbo.check_column_exists = property::make("check_column_exists",Dbo.it);
    
    // instructions from module sources 
    
    { global_variable * _CL_obj = (Dbo.DBOJECTS = (global_variable *) Core._global_variable->instantiate("DBOJECTS",Dbo.it));
      _void_(_CL_obj->range = Kernel.emptySet);
      _void_(_CL_obj->value = ((OID)1));
      close_global_variable(_CL_obj);
      }
    
    { global_variable * _CL_obj = (Dbo.DBTOOLS = (global_variable *) Core._global_variable->instantiate("DBTOOLS",Dbo.it));
      _void_(_CL_obj->range = Kernel.emptySet);
      _void_(_CL_obj->value = ((OID)2));
      close_global_variable(_CL_obj);
      }
    
    { global_variable * _CL_obj = (Dbo.DBTOOLS_VALUE = (global_variable *) Core._global_variable->instantiate("DBTOOLS_VALUE",Dbo.it));
      _void_(_CL_obj->range = Kernel.emptySet);
      _void_(_CL_obj->value = ((OID)3));
      close_global_variable(_CL_obj);
      }
    
    { global_variable * _CL_obj = (Dbo.DBUPDATE = (global_variable *) Core._global_variable->instantiate("DBUPDATE",Dbo.it));
      _void_(_CL_obj->range = Kernel.emptySet);
      _void_(_CL_obj->value = ((OID)1));
      close_global_variable(_CL_obj);
      }
    
    { global_variable * _CL_obj = (Dbo.BASIC_TYPES = (global_variable *) Core._global_variable->instantiate("BASIC_TYPES",Dbo.it));
      _void_(_CL_obj->range = Kernel.emptySet);
      _void_(_CL_obj->value = _oid_(nth_class1(Core._subtype,U_type(U_type(U_type(U_type(Kernel._integer,Kernel._float),Kernel._char),Kernel._string),Kernel._boolean))));
      close_global_variable(_CL_obj);
      }
    
    { global_variable * _CL_obj = (Dbo.STRING_BAG_SEP = (global_variable *) Core._global_variable->instantiate("STRING_BAG_SEP",Dbo.it));
      _void_(_CL_obj->range = Kernel.emptySet);
      _void_(_CL_obj->value = _oid_(char_I_integer(28)));
      close_global_variable(_CL_obj);
      }
    
    GC_BIND;
(Dbo._IdGenerator = ClaireClass::make("IdGenerator",Core._ephemeral_object,Dbo.it));
    
    (Dbo._DataStorage = ClaireClass::make("DataStorage",Core._ephemeral_object,Dbo.it));
    
    { (Dbo.dbStore_ask = property::make("dbStore?",3,Dbo.it,Kernel._any,0));
      _void_(Dbo.dbStore_ask->open = 3);
      ;}
    
    { (Dbo.dbReference_ask = property::make("dbReference?",3,Dbo.it,Kernel._any,0));
      _void_(Dbo.dbReference_ask->open = 3);
      ;}
    
    Dbo.dbStore_ask->addMethod(list::domain(1,Kernel._any),Kernel._boolean,
    	0,_function_(Dbo_dbStore_ask_any1_Dbo,"Dbo_dbStore?_any1_Dbo"));
    
    Dbo.dbReference_ask->addMethod(list::domain(1,Kernel._any),Kernel._boolean,
    	0,_function_(Dbo_dbReference_ask_any1_Dbo,"Dbo_dbReference?_any1_Dbo"));
    
    GC_UNBIND;
{ global_variable * _CL_obj = (Dbo.FILE_STORAGE = (global_variable *) Core._global_variable->instantiate("FILE_STORAGE",Dbo.it));
      _void_(_CL_obj->range = Kernel._string);
      _void_(_CL_obj->value = _string_(((char*)"/tmp/dbo_files")));
      close_global_variable(_CL_obj);
      }
    
    GC_BIND;
{ (Dbo._dbProperty = ClaireClass::make("dbProperty",Kernel._property,Dbo.it));
      CL_ADD_SLOT(Dbo._dbProperty,Dbo_dbProperty,Dbo.autoIncrement_ask,autoIncrement_ask,Kernel._boolean,Kernel.cfalse);
      CL_ADD_SLOT(Dbo._dbProperty,Dbo_dbProperty,Dbo.fieldName,fieldName,Kernel._string,CNULL);
      CL_ADD_SLOT(Dbo._dbProperty,Dbo_dbProperty,Dbo.password_ask,password_ask,Kernel._boolean,Kernel.cfalse);
      CL_ADD_SLOT(Dbo._dbProperty,Dbo_dbProperty,Dbo.dbSqlType,dbSqlType,Kernel._integer,(OID)(4));
      CL_ADD_SLOT(Dbo._dbProperty,Dbo_dbProperty,Dbo.dbSqlBlobFile_ask,dbSqlBlobFile_ask,Kernel._boolean,Kernel.cfalse);
      CL_ADD_SLOT(Dbo._dbProperty,Dbo_dbProperty,Dbo.dbSqlPrecision,dbSqlPrecision,Kernel._integer,((OID)30));
      CL_ADD_SLOT(Dbo._dbProperty,Dbo_dbProperty,Dbo.dbSqlDigit,dbSqlDigit,Kernel._integer,((OID)0));
      CL_ADD_SLOT(Dbo._dbProperty,Dbo_dbProperty,Dbo.xssFilter,xssFilter,Kernel._boolean,Kernel.ctrue);
      CL_ADD_SLOT(Dbo._dbProperty,Dbo_dbProperty,Dbo.null_ask,null_ask,Kernel._boolean,Kernel.ctrue);
      CL_ADD_SLOT(Dbo._dbProperty,Dbo_dbProperty,Dbo.id_ask,id_ask,Kernel._boolean,Kernel.cfalse);
      CL_ADD_SLOT(Dbo._dbProperty,Dbo_dbProperty,Dbo.idGenerator,idGenerator,nth_class1(Core._subtype,Dbo._IdGenerator),CNULL);
      }
    
    { (Dbo.generatorId = (Dbo_dbProperty *) Dbo._dbProperty->instantiate("generatorId",Dbo.it));
      _void_(Dbo.generatorId->id_ask = CTRUE);
      ;}
    
    { (Dbo.generatorClass = (Dbo_dbProperty *) Dbo._dbProperty->instantiate("generatorClass",Dbo.it));
      ;}
    
    { (Dbo._IdGenerator = ClaireClass::make("IdGenerator",Core._ephemeral_object,Dbo.it));
      CL_ADD_SLOT(Dbo._IdGenerator,Dbo_IdGenerator,Dbo.generatorId,generatorId,Kernel._integer,CNULL);
      CL_ADD_SLOT(Dbo._IdGenerator,Dbo_IdGenerator,Dbo.generatorClass,generatorClass,Kernel._class,CNULL);
      }
    
    { (Dbo._db_id_map = ClaireClass::make("db_id_map",Core._ephemeral_object,Dbo.it));
      CL_ADD_SLOT(Dbo._db_id_map,Dbo_db_id_map,Dbo.map,map,nth_class1(Kernel._list,Kernel._any),CNULL);
      }
    
    GC_UNBIND;
{ global_variable * _CL_obj = (Dbo.DB_ID_MAP = (global_variable *) Core._global_variable->instantiate("DB_ID_MAP",Dbo.it));
      _void_(_CL_obj->range = Kernel.emptySet);
      { global_variable * g0106 = _CL_obj; 
        OID  g0107;
        { Dbo_db_id_map * _CL_obj = ((Dbo_db_id_map *) GC_OBJECT(Dbo_db_id_map,new_object_class(Dbo._db_id_map)));
          g0107 = _oid_(_CL_obj);
          }
        _void_(g0106->value = g0107);}
      close_global_variable(_CL_obj);
      }
    
    GC_BIND;
Kernel.nth_equal->addMethod(list::domain(4,Dbo._db_id_map,
      Kernel._class,
      Kernel._integer,
      GC_OBJECT(ClaireType,U_type(Kernel._object,set::alloc(Kernel.emptySet,1,CNULL)))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(claire_nth_equal_db_id_map1,"claire_nth=_db_id_map1"));
    
    Kernel.nth->addMethod(list::domain(3,Dbo._db_id_map,Kernel._class,Kernel._integer),U_type(Kernel._object,set::alloc(Kernel.emptySet,1,CNULL)),
    	0,_function_(claire_nth_db_id_map1,"claire_nth_db_id_map1"));
    
    { (Dbo.dbPrint = property::make("dbPrint",3,Dbo.it,Kernel._any,0));
      ;}
    
    abstract_property(Dbo.dbPrint);
    
    Dbo.dbPrint->addMethod(list::domain(2,Db._Database,Kernel._object),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbPrint_Database1_Dbo,"Dbo_dbPrint_Database1_Dbo"));
    
    Dbo.dbPrint->addMethod(list::domain(2,Db._Database,GC_OBJECT(ClaireType,nth_class1(Kernel._type,Kernel._class))),Kernel._void,
    	NEW_ALLOC,_function_(Dbo_dbPrint_Database2_Dbo,"Dbo_dbPrint_Database2_Dbo"));
    
    Dbo.dbPrintBag->addMethod(list::domain(3,Db._Database,Kernel._bag,Kernel._char),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbPrintBag_Database1,"Dbo_dbPrintBag_Database1"));
    
    Dbo.dbPrint->addMethod(list::domain(2,Db._Database,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Kernel._string))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbPrint_Database3_Dbo,"Dbo_dbPrint_Database3_Dbo"));
    
    Dbo.dbPrint->addMethod(list::domain(2,Db._Database,GC_OBJECT(ClaireType,nth_class1(Kernel._set,Kernel._string))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbPrint_Database4_Dbo,"Dbo_dbPrint_Database4_Dbo"));
    
    Dbo.dbPrint->addMethod(list::domain(2,Db._Database,GC_OBJECT(ClaireType,nth_class1(Kernel._set,Kernel._float))),Kernel._void,
    	0,_function_(Dbo_dbPrint_Database5_Dbo,"Dbo_dbPrint_Database5_Dbo"));
    
    Dbo.dbPrint->addMethod(list::domain(2,Db._Database,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Kernel._float))),Kernel._void,
    	0,_function_(Dbo_dbPrint_Database6_Dbo,"Dbo_dbPrint_Database6_Dbo"));
    
    Dbo.dbPrint->addMethod(list::domain(2,Db._Database,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Kernel._integer))),Kernel._void,
    	0,_function_(Dbo_dbPrint_Database7_Dbo,"Dbo_dbPrint_Database7_Dbo"));
    
    Dbo.dbPrint->addMethod(list::domain(2,Db._Database,GC_OBJECT(ClaireType,nth_class1(Kernel._set,Kernel._integer))),Kernel._void,
    	0,_function_(Dbo_dbPrint_Database8_Dbo,"Dbo_dbPrint_Database8_Dbo"));
    
    Dbo.dbPrint->addMethod(list::domain(2,Db._Database,Kernel._string),Kernel._void,
    	NEW_ALLOC,_function_(Dbo_dbPrint_Database9_Dbo,"Dbo_dbPrint_Database9_Dbo"));
    
    Dbo.dbPrint->addMethod(list::domain(2,Db._Database,Kernel._integer),Kernel._void,
    	NEW_ALLOC,_function_(Dbo_dbPrint_Database10_Dbo,"Dbo_dbPrint_Database10_Dbo"));
    
    Dbo.dbPrint->addFloatMethod(list::domain(2,Db._Database,Kernel._float),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbPrint_Database11_Dbo,"Dbo_dbPrint_Database11_Dbo"),
    _function_(Dbo_dbPrint_Database11_Dbo_,"Dbo_dbPrint_Database11_Dbo_"));
    
    Dbo.dbPrint->addMethod(list::domain(2,Db._Database,Kernel._boolean),Kernel._void,
    	0,_function_(Dbo_dbPrint_Database12_Dbo,"Dbo_dbPrint_Database12_Dbo"));
    
    Dbo.dbPrintDate->addFloatMethod(list::domain(3,Db._Database,Dbo._dbProperty,Kernel._float),Kernel._void,
    	NEW_ALLOC,_function_(Dbo_dbPrintDate_Database1_Dbo,"Dbo_dbPrintDate_Database1_Dbo"),
    _function_(Dbo_dbPrintDate_Database1_Dbo_,"Dbo_dbPrintDate_Database1_Dbo_"));
    
    abstract_property(Dbo.dbPrintDate);
    
    Dbo.dbPrintValue->addMethod(list::domain(3,Db._Database,Kernel._any,Dbo._dbProperty),Kernel._void,
    	NEW_ALLOC+RETURN_ARG,_function_(Dbo_dbPrintValue_Database1,"Dbo_dbPrintValue_Database1"));
    
    Dbo.dbPrint->addMethod(list::domain(3,Db._Database,Kernel._any,Dbo._dbProperty),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbPrint_Database13_Dbo,"Dbo_dbPrint_Database13_Dbo"));
    
    Dbo.dbPrint->addMethod(list::domain(4,Db._Database,
      Dbo._dbProperty,
      Kernel._object,
      Kernel._port),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbPrint_Database14_Dbo,"Dbo_dbPrint_Database14_Dbo"));
    
    Dbo.filePath->addMethod(list::domain(3,Db._Database,Dbo._dbProperty,Kernel._object),Kernel._string,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_filePath_Database1,"Dbo_filePath_Database1"));
    
    Dbo.dbPrintInFile->addMethod(list::domain(3,Db._Database,Dbo._dbProperty,Kernel._object),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbPrintInFile_Database1,"Dbo_dbPrintInFile_Database1"));
    
    Dbo.isBlob_ask->addMethod(list::domain(1,Dbo._dbProperty),Kernel._boolean,
    	0,_function_(Dbo_isBlob_ask_dbProperty1,"Dbo_isBlob?_dbProperty1"));
    
    Dbo.printList->addMethod(list::domain(1,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_printList_list1,"Dbo_printList_list1"));
    
    Dbo.printList->addMethod(list::domain(1,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Kernel._string))),Kernel._void,
    	0,_function_(Dbo_printList_list2,"Dbo_printList_list2"));
    
    Db.printValues->addMethod(list::domain(3,Db._Database,Kernel._object,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._void,
    	NEW_ALLOC+RETURN_ARG,_function_(Db_printValues_Database3,"Db_printValues_Database3"));
    
    Dbo.printAffects->addMethod(list::domain(3,Db._Database,Kernel._object,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_printAffects_Database1,"Dbo_printAffects_Database1"));
    
    Dbo.printAffects->addMethod(list::domain(2,Db._Database,GC_OBJECT(ClaireType,nth_class1(Kernel._list,tuple::alloc(2,_oid_(Dbo._dbProperty),_oid_(Kernel._any))))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_printAffects_Database2,"Dbo_printAffects_Database2"));
    
    Dbo.printWhereAnd->addMethod(list::domain(2,Db._Database,GC_OBJECT(ClaireType,nth_class1(Kernel._list,tuple::alloc(2,_oid_(Dbo._dbProperty),_oid_(Kernel._any))))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_printWhereAnd_Database1,"Dbo_printWhereAnd_Database1"));
    
    Dbo.printType->addMethod(list::domain(2,Db._Database,set::alloc(Kernel.emptySet,1,_oid_(Kernel._string))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_printType_Database1,"Dbo_printType_Database1"));
    
    Dbo.printType->addMethod(list::domain(2,Db._Database,set::alloc(Kernel.emptySet,1,_oid_(Kernel._integer))),Kernel._void,
    	0,_function_(Dbo_printType_Database2,"Dbo_printType_Database2"));
    
    Dbo.printType->addMethod(list::domain(2,Db._Database,set::alloc(Kernel.emptySet,1,_oid_(Kernel._boolean))),Kernel._void,
    	0,_function_(Dbo_printType_Database3,"Dbo_printType_Database3"));
    
    Dbo.printType->addMethod(list::domain(2,Db._Database,set::alloc(Kernel.emptySet,1,_oid_(Kernel._float))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_printType_Database4,"Dbo_printType_Database4"));
    
    Dbo.printType->addMethod(list::domain(2,Db._Database,GC_OBJECT(ClaireType,nth_class1(Kernel._type,Kernel._object))),Kernel._void,
    	0,_function_(Dbo_printType_Database5,"Dbo_printType_Database5"));
    
    Dbo.printType->addMethod(list::domain(2,Db._Database,GC_OBJECT(ClaireType,nth_class1(Kernel._type,Kernel._class))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_printType_Database6,"Dbo_printType_Database6"));
    
    Dbo.printType->addMethod(list::domain(2,Db._Database,GC_OBJECT(ClaireType,nth_class1(Kernel._type,Core._Union))),Kernel._void,
    	0,_function_(Dbo_printType_Database7,"Dbo_printType_Database7"));
    
    Dbo.printType->addMethod(list::domain(2,Db._Database,GC_OBJECT(ClaireType,nth_class1(Kernel._type,GC_OBJECT(ClaireType,nth_class1(Kernel._list,GC_OBJECT(ClaireType,U_type(GC_OBJECT(ClaireType,U_type(GC_OBJECT(ClaireType,U_type(GC_OBJECT(ClaireType,U_type(Kernel._integer,Kernel._float)),Kernel._char)),Kernel._string)),Kernel._boolean))))))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_printType_Database8,"Dbo_printType_Database8"));
    
    Dbo.printType->addMethod(list::domain(2,Db._Database,GC_OBJECT(ClaireType,nth_class1(Kernel._type,GC_OBJECT(ClaireType,nth_class1(Kernel._set,GC_OBJECT(ClaireType,U_type(GC_OBJECT(ClaireType,U_type(GC_OBJECT(ClaireType,U_type(GC_OBJECT(ClaireType,U_type(Kernel._integer,Kernel._float)),Kernel._char)),Kernel._string)),Kernel._boolean))))))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_printType_Database9,"Dbo_printType_Database9"));
    
    Dbo.printFieldDefinitions->addMethod(list::domain(3,Db._Database,Kernel._class,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_printFieldDefinitions_Database1,"Dbo_printFieldDefinitions_Database1"));
    
    Dbo.dbCreateSimple->addMethod(list::domain(4,Db._Database,
      Kernel._object,
      Kernel._boolean,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbCreateSimple_Database1,"Dbo_dbCreateSimple_Database1"));
    
    Dbo.storeBlobFiles->addMethod(list::domain(3,Db._Database,Kernel._object,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_storeBlobFiles_Database1,"Dbo_storeBlobFiles_Database1"));
    
    Dbo.dbCreateWithGenerator->addMethod(list::domain(3,Db._Database,Kernel._object,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbCreateWithGenerator_Database1,"Dbo_dbCreateWithGenerator_Database1"));
    
    Dbo.dbCreate->addMethod(list::domain(3,Db._Database,Kernel._object,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbCreate_Database1,"Dbo_dbCreate_Database1"));
    
    Dbo.dbCreate->addMethod(list::domain(2,Db._Database,Kernel._object),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbCreate_Database2,"Dbo_dbCreate_Database2"));
    
    Dbo.dbDelete->addMethod(list::domain(3,Db._Database,Kernel._class,Kernel._integer),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbDelete_Database1,"Dbo_dbDelete_Database1"));
    
    Dbo.dbDelete->addMethod(list::domain(3,Db._Database,Kernel._class,Kernel._string),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbDelete_Database2,"Dbo_dbDelete_Database2"));
    
    Dbo.dbDelete->addMethod(list::domain(2,Db._Database,Kernel._object),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbDelete_Database3,"Dbo_dbDelete_Database3"));
    
    Dbo.dbDelete->addMethod(list::domain(3,Db._Database,Kernel._class,GC_OBJECT(ClaireType,nth_class1(Kernel._list,tuple::alloc(2,_oid_(Dbo._dbProperty),_oid_(Kernel._any))))),Kernel._integer,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbDelete_Database4,"Dbo_dbDelete_Database4"));
    
    Dbo.dbCount->addMethod(list::domain(2,Db._Database,Kernel._class),Kernel._integer,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbCount_Database1,"Dbo_dbCount_Database1"));
    
    Dbo.dbCount->addMethod(list::domain(3,Db._Database,Kernel._class,GC_OBJECT(ClaireType,nth_class1(Kernel._list,tuple::alloc(2,_oid_(Dbo._dbProperty),_oid_(Kernel._any))))),Kernel._integer,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbCount_Database2,"Dbo_dbCount_Database2"));
    
    Dbo.db_0_ask->addMethod(list::domain(1,Kernel._property),Kernel._boolean,
    	0,_function_(Dbo_db_0_ask_property1,"Dbo_db_0?_property1"));
    
    Dbo.db_1_dash1_ask->addMethod(list::domain(1,Kernel._property),Kernel._boolean,
    	0,_function_(Dbo_db_1_dash1_ask_property1,"Dbo_db_1-1?_property1"));
    
    Dbo.db_1_dash1_ask->addMethod(list::domain(2,Dbo._dbProperty,Kernel._object),Kernel._boolean,
    	NEW_ALLOC,_function_(Dbo_db_1_dash1_ask_dbProperty1,"Dbo_db_1-1?_dbProperty1"));
    
    Dbo.db_1_dash1_ask->addMethod(list::domain(2,Kernel._property,Kernel._object),Kernel._boolean,
    	0,_function_(Dbo_db_1_dash1_ask_property2,"Dbo_db_1-1?_property2"));
    
    Dbo.db_N_dash1_ask->addMethod(list::domain(1,Kernel._property),Kernel._boolean,
    	0,_function_(Dbo_db_N_dash1_ask_property1,"Dbo_db_N-1?_property1"));
    
    Dbo.db_1_dashN_ask->addMethod(list::domain(1,Kernel._property),Kernel._boolean,
    	0,_function_(Dbo_db_1_dashN_ask_property1,"Dbo_db_1-N?_property1"));
    
    Dbo.dbUpdate->addMethod(list::domain(3,Db._Database,Kernel._object,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbUpdate_Database1,"Dbo_dbUpdate_Database1"));
    
    Dbo.dbUpdate->addMethod(list::domain(2,Db._Database,Kernel._object),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbUpdate_Database2,"Dbo_dbUpdate_Database2"));
    
    Dbo.dbUpdate->addMethod(list::domain(4,Db._Database,
      Kernel._class,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,tuple::alloc(2,_oid_(Dbo._dbProperty),_oid_(Kernel._any)))),
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,tuple::alloc(2,_oid_(Dbo._dbProperty),_oid_(Kernel._any))))),Kernel._integer,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbUpdate_Database3,"Dbo_dbUpdate_Database3"));
    
    { (Dbo.value_I = property::make("value!",3,Dbo.it,Kernel._any,0));
      ;}
    
    abstract_property(Dbo.value_I);
    
    Dbo.value_I->addMethod(list::domain(4,Db._Database,
      Dbo._dbProperty,
      Kernel._object,
      Kernel._port),Kernel._any,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_value_I_Database1_Dbo,"Dbo_value!_Database1_Dbo"));
    
    Dbo.value_I->addMethod(list::domain(3,Db._Database,Kernel._string,GC_OBJECT(ClaireType,nth_class1(Kernel._type,Kernel._class))),U_type(Kernel._object,set::alloc(Kernel.emptySet,1,CNULL)),
    	NEW_ALLOC+SLOT_UPDATE,_function_(Dbo_value_I_Database2_Dbo,"Dbo_value!_Database2_Dbo"));
    
    Dbo.value_I->addMethod(list::domain(3,Db._Database,Kernel._string,GC_OBJECT(ClaireType,nth_class1(Kernel._type,Kernel._object))),U_type(Kernel._object,set::alloc(Kernel.emptySet,1,CNULL)),
    	NEW_ALLOC+SLOT_UPDATE,_function_(Dbo_value_I_Database3_Dbo,"Dbo_value!_Database3_Dbo"));
    
    Dbo.value_I->addMethod(list::domain(3,Db._Database,Kernel._string,set::alloc(Kernel.emptySet,1,_oid_(Kernel._string))),Kernel._string,
    	NEW_ALLOC+RETURN_ARG,_function_(Dbo_value_I_Database4_Dbo,"Dbo_value!_Database4_Dbo"));
    
    Dbo.value_I->addMethod(list::domain(3,Db._Database,Kernel._string,set::alloc(Kernel.emptySet,1,_oid_(Kernel._char))),Kernel._char,
    	NEW_ALLOC+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_value_I_Database5_Dbo,"Dbo_value!_Database5_Dbo"));
    
    Dbo.value_I->addMethod(list::domain(3,Db._Database,Kernel._string,set::alloc(Kernel.emptySet,1,_oid_(Kernel._integer))),Kernel._integer,
    	NEW_ALLOC,_function_(Dbo_value_I_Database6_Dbo,"Dbo_value!_Database6_Dbo"));
    
    Dbo.value_I->addFloatMethod(list::domain(3,Db._Database,Kernel._string,set::alloc(Kernel.emptySet,1,_oid_(Kernel._float))),Kernel._float,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_value_I_Database7_Dbo,"Dbo_value!_Database7_Dbo"),
    _function_(Dbo_value_I_Database7_Dbo_,"Dbo_value!_Database7_Dbo_"));
    
    Dbo.value_I->addMethod(list::domain(3,Db._Database,Kernel._string,set::alloc(Kernel.emptySet,1,_oid_(Kernel._boolean))),Kernel._boolean,
    	NEW_ALLOC,_function_(Dbo_value_I_Database8_Dbo,"Dbo_value!_Database8_Dbo"));
    
    Dbo.set_value_I->addMethod(list::domain(3,Db._Database,Kernel._string,Kernel._any),U_type(Kernel._set,set::alloc(Kernel.emptySet,1,CNULL)),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_set_value_I_Database1,"Dbo_set_value!_Database1"));
    
    Dbo.list_value_I->addMethod(list::domain(3,Db._Database,Kernel._string,Kernel._any),U_type(Kernel._bag,set::alloc(Kernel.emptySet,1,CNULL)),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_list_value_I_Database1,"Dbo_list_value!_Database1"));
    
    Dbo.dbReadFromFile->addMethod(list::domain(3,Db._Database,Dbo._dbProperty,Kernel._object),Kernel._any,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbReadFromFile_Database1,"Dbo_dbReadFromFile_Database1"));
    
    Dbo.make_utc_date->addFloatMethod(list::domain(1,Kernel._string),Kernel._float,
    	NEW_ALLOC,_function_(Dbo_make_utc_date_string1,"Dbo_make_utc_date_string1"),
    _function_(Dbo_make_utc_date_string1_,"Dbo_make_utc_date_string1_"));
    
    Dbo.updateValuesFromRow->addMethod(list::domain(4,Db._Database,
      Kernel._object,
      Dbo._dbProperty,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_updateValuesFromRow_Database1,"Dbo_updateValuesFromRow_Database1"));
    
    _void_(Dbo.loadObjectListFromRows->addMethod(list::domain(4,Db._Database,
      Kernel._class,
      Dbo._dbProperty,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_loadObjectListFromRows_Database1,"Dbo_loadObjectListFromRows_Database1"))->typing = _oid_(_function_(Dbo_loadObjectListFromRows_Database1_type,"Dbo_loadObjectListFromRows_Database1_type")));
    
    Dbo.dbLoad->addMethod(list::domain(4,Db._Database,
      Kernel._object,
      Kernel._integer,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database1,"Dbo_dbLoad_Database1"));
    
    Dbo.dbLoad->addMethod(list::domain(4,Db._Database,
      Kernel._object,
      Kernel._string,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database2,"Dbo_dbLoad_Database2"));
    
    Dbo.dbLoad->addMethod(list::domain(3,Db._Database,Kernel._object,Kernel._integer),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database3,"Dbo_dbLoad_Database3"));
    
    Dbo.dbLoad->addMethod(list::domain(3,Db._Database,Kernel._object,Kernel._string),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database4,"Dbo_dbLoad_Database4"));
    
    Dbo.dbLoad->addMethod(list::domain(3,Db._Database,Kernel._object,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database5,"Dbo_dbLoad_Database5"));
    
    Dbo.dbLoad->addMethod(list::domain(2,Db._Database,Kernel._object),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database6,"Dbo_dbLoad_Database6"));
    
    _void_(Dbo.dbLoad->addMethod(list::domain(4,Db._Database,
      Kernel._class,
      Kernel._integer,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._any,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database7,"Dbo_dbLoad_Database7"))->typing = _oid_(_function_(Dbo_dbLoad_Database7_type,"Dbo_dbLoad_Database7_type")));
    
    _void_(Dbo.dbLoad->addMethod(list::domain(4,Db._Database,
      Kernel._class,
      Kernel._string,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._any,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database8,"Dbo_dbLoad_Database8"))->typing = _oid_(_function_(Dbo_dbLoad_Database8_type,"Dbo_dbLoad_Database8_type")));
    
    _void_(Dbo.dbLoad->addMethod(list::domain(3,Db._Database,Kernel._class,Kernel._integer),Kernel._any,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database9,"Dbo_dbLoad_Database9"))->typing = _oid_(_function_(Dbo_dbLoad_Database9_type,"Dbo_dbLoad_Database9_type")));
    
    _void_(Dbo.dbLoad->addMethod(list::domain(3,Db._Database,Kernel._class,Kernel._string),Kernel._any,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database10,"Dbo_dbLoad_Database10"))->typing = _oid_(_function_(Dbo_dbLoad_Database10_type,"Dbo_dbLoad_Database10_type")));
    
    _void_(Dbo.dbLoad->addMethod(list::domain(6,Db._Database,
      Kernel._class,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty)),
      Kernel._integer,
      GC_OBJECT(ClaireType,U_type(Dbo._dbProperty,GC_OBJECT(set,set::alloc(Kernel.emptySet,1,CNULL)))),
      Kernel._boolean),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database11,"Dbo_dbLoad_Database11"))->typing = _oid_(_function_(Dbo_dbLoad_Database11_type,"Dbo_dbLoad_Database11_type")));
    
    _void_(Dbo.dbLoad->addMethod(list::domain(7,Db._Database,
      Kernel._class,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty)),
      Kernel._integer,
      GC_OBJECT(ClaireType,U_type(Dbo._dbProperty,set::alloc(Kernel.emptySet,1,CNULL))),
      Kernel._boolean,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,tuple::alloc(2,_oid_(Dbo._dbProperty),_oid_(Kernel._any))))),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database12,"Dbo_dbLoad_Database12"))->typing = _oid_(_function_(Dbo_dbLoad_Database12_type,"Dbo_dbLoad_Database12_type")));
    
    _void_(Dbo.dbLoadWhere->addMethod(list::domain(7,Db._Database,
      Kernel._class,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty)),
      Kernel._integer,
      GC_OBJECT(ClaireType,U_type(Dbo._dbProperty,GC_OBJECT(set,set::alloc(Kernel.emptySet,1,CNULL)))),
      Kernel._boolean,
      Kernel._list),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoadWhere_Database1,"Dbo_dbLoadWhere_Database1"))->typing = _oid_(_function_(Dbo_dbLoadWhere_Database1_type,"Dbo_dbLoadWhere_Database1_type")));
    
    _void_(Dbo.dbLoad->addMethod(list::domain(2,Db._Database,Kernel._class),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database13,"Dbo_dbLoad_Database13"))->typing = _oid_(_function_(Dbo_dbLoad_Database13_type,"Dbo_dbLoad_Database13_type")));
    
    _void_(Dbo.dbLoad->addMethod(list::domain(4,Db._Database,
      Kernel._class,
      Dbo._dbProperty,
      Kernel._boolean),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database14,"Dbo_dbLoad_Database14"))->typing = _oid_(_function_(Dbo_dbLoad_Database14_type,"Dbo_dbLoad_Database14_type")));
    
    _void_(Dbo.dbLoad->addMethod(list::domain(3,Db._Database,Kernel._class,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database15,"Dbo_dbLoad_Database15"))->typing = _oid_(_function_(Dbo_dbLoad_Database15_type,"Dbo_dbLoad_Database15_type")));
    
    _void_(Dbo.dbLoad->addMethod(list::domain(5,Db._Database,
      Kernel._class,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty)),
      Dbo._dbProperty,
      Kernel._boolean),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database16,"Dbo_dbLoad_Database16"))->typing = _oid_(_function_(Dbo_dbLoad_Database16_type,"Dbo_dbLoad_Database16_type")));
    
    _void_(Dbo.dbLoad->addMethod(list::domain(5,Db._Database,
      Kernel._class,
      GC_OBJECT(ClaireType,U_type(Dbo._dbProperty,set::alloc(Kernel.emptySet,1,CNULL))),
      Kernel._boolean,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,tuple::alloc(2,_oid_(Dbo._dbProperty),_oid_(Kernel._any))))),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database17,"Dbo_dbLoad_Database17"))->typing = _oid_(_function_(Dbo_dbLoad_Database17_type,"Dbo_dbLoad_Database17_type")));
    
    _void_(Dbo.dbLoadWhere->addMethod(list::domain(5,Db._Database,
      Kernel._class,
      GC_OBJECT(ClaireType,U_type(Dbo._dbProperty,GC_OBJECT(set,set::alloc(Kernel.emptySet,1,CNULL)))),
      Kernel._boolean,
      Kernel._list),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoadWhere_Database2,"Dbo_dbLoadWhere_Database2"))->typing = _oid_(_function_(Dbo_dbLoadWhere_Database2_type,"Dbo_dbLoadWhere_Database2_type")));
    
    _void_(Dbo.dbLoad->addMethod(list::domain(3,Db._Database,Kernel._class,GC_OBJECT(ClaireType,nth_class1(Kernel._list,tuple::alloc(2,_oid_(Dbo._dbProperty),_oid_(Kernel._any))))),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database18,"Dbo_dbLoad_Database18"))->typing = _oid_(_function_(Dbo_dbLoad_Database18_type,"Dbo_dbLoad_Database18_type")));
    
    _void_(Dbo.dbLoadWhere->addMethod(list::domain(3,Db._Database,Kernel._class,Kernel._list),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoadWhere_Database3,"Dbo_dbLoadWhere_Database3"))->typing = _oid_(_function_(Dbo_dbLoadWhere_Database3_type,"Dbo_dbLoadWhere_Database3_type")));
    
    _void_(Dbo.dbLoad->addMethod(list::domain(4,Db._Database,
      Kernel._class,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty)),
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,tuple::alloc(2,_oid_(Dbo._dbProperty),_oid_(Kernel._any))))),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database19,"Dbo_dbLoad_Database19"))->typing = _oid_(_function_(Dbo_dbLoad_Database19_type,"Dbo_dbLoad_Database19_type")));
    
    _void_(Dbo.dbLoadWhere->addMethod(list::domain(4,Db._Database,
      Kernel._class,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty)),
      Kernel._list),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoadWhere_Database4,"Dbo_dbLoadWhere_Database4"))->typing = _oid_(_function_(Dbo_dbLoadWhere_Database4_type,"Dbo_dbLoadWhere_Database4_type")));
    
    _void_(Dbo.dbLoad->addMethod(list::domain(6,Db._Database,
      Kernel._class,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty)),
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,tuple::alloc(2,_oid_(Dbo._dbProperty),_oid_(Kernel._any)))),
      Dbo._dbProperty,
      Kernel._boolean),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoad_Database20,"Dbo_dbLoad_Database20"))->typing = _oid_(_function_(Dbo_dbLoad_Database20_type,"Dbo_dbLoad_Database20_type")));
    
    _void_(Dbo.dbLoadWhere->addMethod(list::domain(6,Db._Database,
      Kernel._class,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty)),
      Kernel._list,
      Dbo._dbProperty,
      Kernel._boolean),nth_class1(Kernel._list,Kernel._any),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoadWhere_Database5,"Dbo_dbLoadWhere_Database5"))->typing = _oid_(_function_(Dbo_dbLoadWhere_Database5_type,"Dbo_dbLoadWhere_Database5_type")));
    
    Dbo.dbValidPassword_ask->addMethod(list::domain(4,Db._Database,
      Kernel._class,
      Kernel._integer,
      Kernel._string),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbValidPassword_ask_Database1,"Dbo_dbValidPassword?_Database1"));
    
    Dbo.dbValidPassword_ask->addMethod(list::domain(3,Db._Database,Kernel._any,Kernel._string),Kernel._boolean,
    	NEW_ALLOC,_function_(Dbo_dbValidPassword_ask_Database2,"Dbo_dbValidPassword?_Database2"));
    
    Dbo.dbValidPassword_ask->addMethod(list::domain(5,Db._Database,
      Kernel._class,
      Dbo._dbProperty,
      Kernel._string,
      Kernel._string),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbValidPassword_ask_Database3,"Dbo_dbValidPassword?_Database3"));
    
    Dbo.dbUpdatePassword->addMethod(list::domain(4,Db._Database,
      Kernel._class,
      Kernel._integer,
      Kernel._string),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbUpdatePassword_Database1,"Dbo_dbUpdatePassword_Database1"));
    
    Dbo.dbUpdatePassword->addMethod(list::domain(3,Db._Database,Kernel._any,Kernel._string),Kernel._void,
    	NEW_ALLOC+RETURN_ARG,_function_(Dbo_dbUpdatePassword_Database2,"Dbo_dbUpdatePassword_Database2"));
    
    Dbo.print_int->addMethod(list::domain(1,Kernel._integer),Kernel._void,
    	0,_function_(Dbo_print_int_integer1,"Dbo_print_int_integer1"));
    
    Dbo.print_string_list->addMethod(list::domain(2,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Kernel._string)),Kernel._port),Kernel._void,
    	NEW_ALLOC,_function_(Dbo_print_string_list_list1,"Dbo_print_string_list_list1"));
    
    Dbo.extract_int->addMethod(list::domain(1,Kernel._port),Kernel._integer,
    	0,_function_(Dbo_extract_int_port1,"Dbo_extract_int_port1"));
    
    Dbo.extract_string_list->addMethod(list::domain(1,Kernel._port),nth_class1(Kernel._list,Kernel._string),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_extract_string_list_port1,"Dbo_extract_string_list_port1"));
    
    Dbo.dbGetId->addMethod(list::domain(3,Db._Database,Kernel._property,Kernel._object),U_type(Kernel._integer,set::alloc(Kernel.emptySet,1,CNULL)),
    	NEW_ALLOC,_function_(Dbo_dbGetId_Database1,"Dbo_dbGetId_Database1"));
    
    Dbo.dbGet->addMethod(list::domain(3,Db._Database,Kernel._property,Kernel._object),Kernel._any,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbGet_Database1,"Dbo_dbGet_Database1"));
    
    Dbo.dbErase->addMethod(list::domain(3,Db._Database,Kernel._property,Kernel._object),Kernel._any,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbErase_Database1,"Dbo_dbErase_Database1"));
    
    Dbo.dbDrop->addMethod(list::domain(2,Db._Database,Kernel._class),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbDrop_Database1,"Dbo_dbDrop_Database1"));
    
    Dbo.dbCreateTable->addMethod(list::domain(3,Db._Database,Kernel._class,Kernel._boolean),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbCreateTable_Database1,"Dbo_dbCreateTable_Database1"));
    
    Dbo.dbCreateIndex->addMethod(list::domain(3,Db._Database,Kernel._class,Dbo._dbProperty),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbCreateIndex_Database1,"Dbo_dbCreateIndex_Database1"));
    
    Dbo.dbCreateIndex->addMethod(list::domain(3,Db._Database,Kernel._class,GC_OBJECT(ClaireType,nth_class1(Kernel._list,Dbo._dbProperty))),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbCreateIndex_Database2,"Dbo_dbCreateIndex_Database2"));
    
    Dbo.dbCopy->addMethod(list::domain(2,Db._Database,Kernel._object),Kernel._object,
    	NEW_ALLOC+RETURN_ARG,_function_(Dbo_dbCopy_Database1_Dbo,"Dbo_dbCopy_Database1_Dbo"));
    
    Dbo.dbCopy->addMethod(list::domain(3,Db._Database,Kernel._object,Kernel._boolean),Kernel._object,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbCopy_Database2_Dbo,"Dbo_dbCopy_Database2_Dbo"));
    
    abstract_property(Dbo.dbCopy);
    
    Dbo.dbName->addMethod(list::domain(1,Dbo._dbProperty),Kernel._string,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbName_dbProperty1,"Dbo_dbName_dbProperty1"));
    
    Dbo.dbName->addMethod(list::domain(2,Dbo._dbProperty,Kernel._class),Kernel._string,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbName_dbProperty2,"Dbo_dbName_dbProperty2"));
    
    { (Dbo.DB_CLASS_NAME = (table *) Kernel._table->instantiate("DB_CLASS_NAME",Dbo.it));
      _void_(Dbo.DB_CLASS_NAME->range = U_type(Kernel._string,set::alloc(Kernel.emptySet,1,CNULL)));
      _void_(Dbo.DB_CLASS_NAME->params = _oid_(Kernel._any));
      _void_(Dbo.DB_CLASS_NAME->domain = Kernel._class);
      _void_(Dbo.DB_CLASS_NAME->graph = make_list_integer(29,CNULL));
      _void_(Dbo.DB_CLASS_NAME->DEFAULT = CNULL);
      }
    
    Dbo.dbName->addMethod(list::domain(1,Kernel._class),Kernel._string,
    	NEW_ALLOC+SLOT_UPDATE,_function_(Dbo_dbName_class1,"Dbo_dbName_class1"));
    
    Dbo.dbName->addMethod(list::domain(1,Kernel._object),Kernel._string,
    	NEW_ALLOC+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbName_object1,"Dbo_dbName_object1"));
    
    Dbo.dbName->addMethod(list::domain(1,Kernel._module),Kernel._string,
    	RETURN_ARG,_function_(Dbo_dbName_module1,"Dbo_dbName_module1"));
    
    Dbo.dbAllProperties->addMethod(list::domain(1,Kernel._class),nth_class1(Kernel._list,Dbo._dbProperty),
    	NEW_ALLOC,_function_(Dbo_dbAllProperties_class1,"Dbo_dbAllProperties_class1"));
    
    Dbo.dbAllProperties->addMethod(list::domain(1,Kernel._object),nth_class1(Kernel._list,Dbo._dbProperty),
    	NEW_ALLOC,_function_(Dbo_dbAllProperties_object1,"Dbo_dbAllProperties_object1"));
    
    Dbo.dbProperties->addMethod(list::domain(1,Kernel._class),nth_class1(Kernel._list,Dbo._dbProperty),
    	NEW_ALLOC,_function_(Dbo_dbProperties_class1,"Dbo_dbProperties_class1"));
    
    Dbo.dbProperties->addMethod(list::domain(1,Kernel._object),nth_class1(Kernel._list,Dbo._dbProperty),
    	NEW_ALLOC,_function_(Dbo_dbProperties_object1,"Dbo_dbProperties_object1"));
    
    Dbo.dbPropertiesButId->addMethod(list::domain(1,Kernel._class),nth_class1(Kernel._list,Dbo._dbProperty),
    	NEW_ALLOC,_function_(Dbo_dbPropertiesButId_class1,"Dbo_dbPropertiesButId_class1"));
    
    Dbo.dbPropertiesButId->addMethod(list::domain(1,Kernel._object),nth_class1(Kernel._list,Dbo._dbProperty),
    	NEW_ALLOC,_function_(Dbo_dbPropertiesButId_object1,"Dbo_dbPropertiesButId_object1"));
    
    Dbo.dbPasswordProperty->addMethod(list::domain(1,Kernel._class),Dbo._dbProperty,
    	NEW_ALLOC+RETURN_ARG,_function_(Dbo_dbPasswordProperty_class1,"Dbo_dbPasswordProperty_class1"));
    
    Dbo.dbPasswordProperty->addMethod(list::domain(1,Kernel._object),Dbo._dbProperty,
    	NEW_ALLOC+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dbPasswordProperty_object1,"Dbo_dbPasswordProperty_object1"));
    
    Dbo.getIdProperty->addMethod(list::domain(1,Kernel._class),Dbo._dbProperty,
    	SAFE_RESULT,_function_(Dbo_getIdProperty_class1,"Dbo_getIdProperty_class1"));
    
    Dbo.getIdProperty->addMethod(list::domain(1,Kernel._object),Dbo._dbProperty,
    	NEW_ALLOC,_function_(Dbo_getIdProperty_object1,"Dbo_getIdProperty_object1"));
    
    Dbo.getAutoIncrementProperties->addMethod(list::domain(1,Kernel._class),nth_class1(Kernel._list,Dbo._dbProperty),
    	NEW_ALLOC,_function_(Dbo_getAutoIncrementProperties_class1,"Dbo_getAutoIncrementProperties_class1"));
    
    Dbo.getAutoIncrementProperties->addMethod(list::domain(1,Kernel._object),nth_class1(Kernel._list,Dbo._dbProperty),
    	NEW_ALLOC,_function_(Dbo_getAutoIncrementProperties_object1,"Dbo_getAutoIncrementProperties_object1"));
    
    Dbo.getSimpleProperties->addMethod(list::domain(1,Kernel._class),nth_class1(Kernel._list,Dbo._dbProperty),
    	NEW_ALLOC,_function_(Dbo_getSimpleProperties_class1,"Dbo_getSimpleProperties_class1"));
    
    Dbo.getSimpleProperties->addMethod(list::domain(1,Kernel._object),nth_class1(Kernel._list,Dbo._dbProperty),
    	NEW_ALLOC,_function_(Dbo_getSimpleProperties_object1,"Dbo_getSimpleProperties_object1"));
    
    Dbo.getDbId->addMethod(list::domain(1,Kernel._object),U_type(Kernel._integer,set::alloc(Kernel.emptySet,1,CNULL)),
    	NEW_ALLOC+RETURN_ARG,_function_(Dbo_getDbId_object1,"Dbo_getDbId_object1"));
    
    Dbo.lookForObjectWithId->addMethod(list::domain(2,Kernel._class,Kernel._integer),U_type(Kernel._object,GC_OBJECT(set,set::alloc(Kernel.emptySet,1,CNULL))),
    	NEW_ALLOC+SLOT_UPDATE,_function_(Dbo_lookForObjectWithId_class1,"Dbo_lookForObjectWithId_class1"));
    
    Dbo.getObjectFromId->addMethod(list::domain(3,Db._Database,Kernel._class,Kernel._integer),U_type(Kernel._object,set::alloc(Kernel.emptySet,1,CNULL)),
    	NEW_ALLOC+SLOT_UPDATE,_function_(Dbo_getObjectFromId_Database1,"Dbo_getObjectFromId_Database1"));
    
    Dbo.getLastAutoIncrementedField->addMethod(list::domain(3,Db._Database,Kernel._class,Dbo._dbProperty),U_type(Kernel._integer,set::alloc(Kernel.emptySet,1,CNULL)),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_getLastAutoIncrementedField_Database1,"Dbo_getLastAutoIncrementedField_Database1"));
    
    Dbo.getLastAutoIncrementedField->addMethod(list::domain(3,Db._Database,Kernel._object,Dbo._dbProperty),U_type(Kernel._integer,set::alloc(Kernel.emptySet,1,CNULL)),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_getLastAutoIncrementedField_Database2,"Dbo_getLastAutoIncrementedField_Database2"));
    
    Dbo.getLastId->addMethod(list::domain(2,Db._Database,Kernel._class),U_type(Kernel._integer,set::alloc(Kernel.emptySet,1,CNULL)),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_getLastId_Database1,"Dbo_getLastId_Database1"));
    
    Dbo.getLastId->addMethod(list::domain(2,Db._Database,Kernel._object),U_type(Kernel._integer,set::alloc(Kernel.emptySet,1,CNULL)),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_getLastId_Database2,"Dbo_getLastId_Database2"));
    
    Dbo.getRangesN_dash1->addMethod(list::domain(2,Kernel._property,Kernel._object),Kernel._set,
    	NEW_ALLOC,_function_(Dbo_getRangesN_dash1_property1,"Dbo_getRangesN-1_property1"));
    
    Dbo.getRanges1_dash1Or1_dashN->addMethod(list::domain(2,Kernel._property,Kernel._object),Kernel._set,
    	NEW_ALLOC,_function_(Dbo_getRanges1_dash1Or1_dashN_property1,"Dbo_getRanges1-1Or1-N_property1"));
    
    Dbo.getRange1_dash1->addMethod(list::domain(2,Dbo._dbProperty,Kernel._object),Kernel._class,
    	NEW_ALLOC+RETURN_ARG,_function_(Dbo_getRange1_dash1_dbProperty1,"Dbo_getRange1-1_dbProperty1"));
    
    Dbo.getRange->addMethod(list::domain(2,Kernel._property,Kernel._object),U_type(Kernel._class,GC_OBJECT(set,set::alloc(Kernel.emptySet,1,CNULL))),
    	NEW_ALLOC,_function_(Dbo_getRange_property1,"Dbo_getRange_property1"));
    
    _void_(Dbo.getDbDescendents->addMethod(list::domain(1,Kernel._class),nth_class1(Kernel._type,Kernel._class),
    	NEW_ALLOC,_function_(Dbo_getDbDescendents_class1,"Dbo_getDbDescendents_class1"))->typing = _oid_(_function_(Dbo_getDbDescendents_class1_type,"Dbo_getDbDescendents_class1_type")));
    
    Dbo.idOf->addMethod(list::domain(3,Db._Database,Kernel._object,Kernel._property),U_type(Kernel._integer,GC_OBJECT(set,set::alloc(Kernel.emptySet,1,CNULL))),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_idOf_Database1,"Dbo_idOf_Database1"));
    
    Dbo.idOf1_dash1->addMethod(list::domain(3,Db._Database,Kernel._object,Dbo._dbProperty),U_type(Kernel._integer,set::alloc(Kernel.emptySet,1,CNULL)),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_idOf1_dash1_Database1,"Dbo_idOf1-1_Database1"));
    
    Dbo.idOfForRange->addMethod(list::domain(4,Db._Database,
      Kernel._object,
      Dbo._dbProperty,
      Kernel._class),U_type(Kernel._integer,set::alloc(Kernel.emptySet,1,CNULL)),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_idOfForRange_Database1,"Dbo_idOfForRange_Database1"));
    
    Dbo.idOf->addMethod(list::domain(3,Db._Database,Kernel._object,Dbo._dbProperty),U_type(Kernel._integer,GC_OBJECT(set,set::alloc(Kernel.emptySet,1,CNULL))),
    	NEW_ALLOC,_function_(Dbo_idOf_Database2,"Dbo_idOf_Database2"));
    
    Dbo.dbLoadValue->addMethod(list::domain(6,Db._Database,
      Dbo._dbProperty,
      Kernel._class,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,tuple::alloc(2,_oid_(Dbo._dbProperty),_oid_(Kernel._any)))),
      Kernel._boolean,
      GC_OBJECT(ClaireType,U_type(Kernel._boolean,GC_OBJECT(set,set::alloc(Kernel.emptySet,1,CNULL))))),nth_class1(Kernel._list,Kernel._string),
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_dbLoadValue_Database1,"Dbo_dbLoadValue_Database1"));
    
    Dbo.dbGetMaxIntValue->addMethod(list::domain(4,Db._Database,
      Dbo._dbProperty,
      Kernel._class,
      GC_OBJECT(ClaireType,nth_class1(Kernel._list,tuple::alloc(2,_oid_(Dbo._dbProperty),_oid_(Kernel._any))))),Kernel._integer,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+SAFE_RESULT,_function_(Dbo_dbGetMaxIntValue_Database1,"Dbo_dbGetMaxIntValue_Database1"));
    
    Dbo.get_dbUpdate_version->addMethod(list::domain(1,Kernel._method),Kernel._integer,
    	RETURN_ARG,_function_(Dbo_get_dbUpdate_version_method1,"Dbo_get_dbUpdate_version_method1"));
    
    Dbo.dispatch_updates->addMethod(list::domain(2,Db._Database,Kernel._string),Kernel._void,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE+RETURN_ARG,_function_(Dbo_dispatch_updates_Database1,"Dbo_dispatch_updates_Database1"));
    
    Dbo.check_table_exists->addMethod(list::domain(2,Db._Database,Kernel._string),Kernel._boolean,
    	NEW_ALLOC,_function_(Dbo_check_table_exists_Database1,"Dbo_check_table_exists_Database1"));
    
    Dbo.check_table_exists->addMethod(list::domain(2,Db._Database,Kernel._class),Kernel._boolean,
    	NEW_ALLOC+SLOT_UPDATE,_function_(Dbo_check_table_exists_Database2,"Dbo_check_table_exists_Database2"));
    
    Dbo.check_column_exists->addMethod(list::domain(3,Db._Database,Kernel._string,Kernel._string),Kernel._boolean,
    	NEW_ALLOC,_function_(Dbo_check_column_exists_Database1,"Dbo_check_column_exists_Database1"));
    
    Dbo.check_column_exists->addMethod(list::domain(3,Db._Database,Kernel._class,Dbo._dbProperty),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Dbo_check_column_exists_Database2,"Dbo_check_column_exists_Database2"));
    
    Db.index_ask->addMethod(list::domain(3,Db._Database,Kernel._class,Dbo._dbProperty),Kernel._boolean,
    	NEW_ALLOC+BAG_UPDATE+SLOT_UPDATE,_function_(Db_index_ask_Database2,"Db_index?_Database2"));
    
    Db.index_ask->addMethod(list::domain(3,Db._Database,Kernel._class,Kernel._string),Kernel._boolean,
    	NEW_ALLOC+SLOT_UPDATE,_function_(Db_index_ask_Database3,"Db_index?_Database3"));
    
    Db.index_ask->addMethod(list::domain(3,Db._Database,Kernel._string,Kernel._string),Kernel._boolean,
    	0,_function_(Db_index_ask_Database4,"Db_index?_Database4"));
    GC_UNBIND;

    }
  
  