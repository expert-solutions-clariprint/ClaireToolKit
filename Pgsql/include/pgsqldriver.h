
#ifndef __PGSQL_DRIVER_H__
#define __PGSQL_DRIVER_H__

#ifdef CLPC
#include <winsock.h>
#include <libpq-fe.h>
#else
#include <pgsql/libpq-fe.h>
#endif


class Db_Query;
class Pgsql_PgSqlDatabase;
class Pgsql_QueryPort;


QueryPort* pgSqlPort(Pgsql_PgSqlDatabase* self);
void pgSqlExecute(Pgsql_PgSqlDatabase* db, Db_Query* self);
ClaireBoolean* pgSqlFetch(Pgsql_PgSqlDatabase* db, Db_Query* self);
void pgSqlFree(Pgsql_PgSqlDatabase* db, Db_Query* self);
void pgSqlOpenCursor(Pgsql_PgSqlDatabase* db, Db_Query* self);
void pgSqlCloseCursor(Pgsql_PgSqlDatabase* db, Db_Query* self);
char* pgSqlField(Pgsql_PgSqlDatabase* db, Db_Query* self, int fieldIndex);
Pgsql_PgSqlDatabase* pgSqlConnect(Pgsql_PgSqlDatabase* self, char* dbName, char* host, char* user, char* password);
void pgSqlDisconnect(Pgsql_PgSqlDatabase* self);
list* pgSqlTables(Pgsql_PgSqlDatabase* self, list* tables);

#endif
