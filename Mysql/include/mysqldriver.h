//*********************************************************************
//* Mysql                                             Sylvain Benilan *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*********************************************************************

#ifndef __MYSQL_DRIVER_H__
#define __MYSQL_DRIVER_H__

#ifdef CLPC
#include <winsock.h>
#include <include/mysql.h>
#else
#include <mysql/mysql.h>
#endif

class Db_Query;
class Mysql_MySqlDatabase;
class Mysql_QueryPort;

PortObject* mySqlPort(Mysql_MySqlDatabase* self);
void mySqlExecute(Mysql_MySqlDatabase* db, Db_Query* self);
ClaireBoolean* mySqlFetch(Mysql_MySqlDatabase* db, Db_Query* self);
void mySqlFree(Mysql_MySqlDatabase* db, Db_Query* self);
void mySqlOpenCursor(Mysql_MySqlDatabase* db, Db_Query* self);
void mySqlCloseCursor(Mysql_MySqlDatabase* db, Db_Query* self);
char* mySqlField(Mysql_MySqlDatabase* db, Db_Query* self, int fieldIndex);
Mysql_MySqlDatabase* mySqlConnect(Mysql_MySqlDatabase* self, char* dbName, char* host, char* user, char* password);
Mysql_MySqlDatabase* mySqlConnect2(Mysql_MySqlDatabase* self, char* dbName, char* user, char* password, char* sock);
void mySqlDisconnect(Mysql_MySqlDatabase* self);
list* mySqlTables(Mysql_MySqlDatabase* self, list* tables);
char* mySqlRealEscape(Mysql_MySqlDatabase* db, char* data);
void mySqlBeginEscape(Mysql_MySqlDatabase* db, Db_Query* self);
void mySqlEndEscape(Mysql_MySqlDatabase* db, Db_Query* self);


#endif
