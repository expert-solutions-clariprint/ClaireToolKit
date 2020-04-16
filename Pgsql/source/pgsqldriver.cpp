

#include <claire.h>
#include <Kernel.h>
#include <Core.h>
#include <Db.h>
#include <Pgsql.h>
#include <queryport.h> 
#include <pgsqldriver.h>


//////////////////////////////////////////////////////////////////
// MySQL error handling
//////////////////////////////////////////////////////////////////

void pgSqlError(Pgsql_PgSqlDatabase* self) 
{
	Db_dbError_I_Database(self, copy_string(PQerrorMessage(self->pgSqlHandle)));
}

void pgSqlError(Pgsql_PgSqlDatabase* self, char* err) 
{
	Db_dbError_I_Database(self, copy_string(err));
}

void pgSqlErrorWithDb_Query(Pgsql_PgSqlDatabase* self, char* query) 
{
	char* err = copy_string(PQerrorMessage(self->pgSqlHandle));
	char* qry = copy_string(query);
	Db_popQuery_Database(self);
	Db_dbErrorWithQuery_I_Database(self, err, qry);
}

//////////////////////////////////////////////////////////////////
// PgSQL database
//////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////
// PgSQL query port
//////////////////////////////////////////////////////////////////

class Pgsql_QueryPort : public QueryPort
{
public:	

	Pgsql_PgSqlDatabase* mDatabase;
	PGresult* mRes;
	int mRows;
	int mRow;
//	MYSQL_ROW mRow;
	
	Pgsql_QueryPort(Pgsql_PgSqlDatabase* db);
	~Pgsql_QueryPort();
	
	void execute(Db_Query* q);
	void closeCursor();
	void openCursor(Db_Query* self);
	ClaireBoolean* fetch();
};

 //////////////////////////////////////////////////////////////////

Pgsql_QueryPort::Pgsql_QueryPort(Pgsql_PgSqlDatabase* self)
{
	mDatabase = self;
	mRes = NULL;
}

Pgsql_QueryPort::~Pgsql_QueryPort()
{
}

void Pgsql_QueryPort::execute(Db_Query* self)
{
	GC_BIND;

	mRows = 0;
	mRow = -1;
	
	mRes = PQexec(mDatabase->pgSqlHandle, mSqlQuery);
	if (!mRes || !(PQresultStatus(mRes) == PGRES_COMMAND_OK || PQresultStatus(mRes) == PGRES_TUPLES_OK))
    {
		pgSqlErrorWithDb_Query(mDatabase, mSqlQuery);
	}
	
//	mRes = mysql_store_result(mDatabase->pgSqlHandle);

	if(mRes &&  PQresultStatus(mRes) == PGRES_TUPLES_OK)
	{
		// something to fetch
		self->rowCount = -1;
		mRows = PQntuples(mRes);
		self->colCount = PQnfields(mRes);
		for(unsigned col = 0; col < self->colCount; col++)
		{
		    Db_addField_Query(self, copy_string(PQfname(mRes, col)), col+1);
		}
	}
	else
	{
		// nothing to fetch
		self->colCount = -1;
//		if(mysql_errno(mDatabase->pgSqlHandle))
//			pgSqlError(mDatabase);
//		else 
		self->rowCount = integer_I_string(PQcmdTuples(mRes));
	}
	GC_UNBIND;
}

void Pgsql_QueryPort::openCursor(Db_Query* self) 
{
}

// ok pgsql
void Pgsql_QueryPort::closeCursor()
{
	resetQueryBuffer();
	if(mRes) PQclear(mRes);
}

// ok pgsql
ClaireBoolean* Pgsql_QueryPort::fetch()
{
	return (++mRow < mRows) ? CTRUE : CFALSE;
}


//////////////////////////////////////////////////////////////////
// PgSQL externals
//////////////////////////////////////////////////////////////////

// ok pgsql
QueryPort* pgSqlPort(Pgsql_PgSqlDatabase* self)
{
	GC_BIND;
	Pgsql_QueryPort* Result = new Pgsql_QueryPort(self);
	GC_UNBIND;
	return Result;
}

// ok pgsql
void pgSqlExecute(Pgsql_PgSqlDatabase* db, Db_Query* self)
{
	GC_BIND;
	((Pgsql_QueryPort*)self->dbPort)->execute(self);
	GC_UNBIND;
}


// ok pgsql
ClaireBoolean* pgSqlFetch(Pgsql_PgSqlDatabase* db, Db_Query* self)
{
	GC_BIND;
	Pgsql_QueryPort* qp = (Pgsql_QueryPort*)self->dbPort;
	ClaireBoolean* Result = qp->fetch();
	if(Result == CTRUE && self->colCount > 0)
	{
		int ifield = 0;
		//printf("ici %d\n",self->colCount);
		for(;ifield < self->colCount;ifield++)
			self->rs = GC_OBJECT(list,
								self->rs->addFast(PQgetisnull(qp->mRes,qp->mRow,ifield) ? 
										CNULL
										: _string_(copy_string(PQgetvalue(qp->mRes,qp->mRow,ifield)))));
	}
	GC_UNBIND;
	return Result;
}

// ok pgsql
void pgSqlFree(Pgsql_PgSqlDatabase* db, Db_Query* self)
{
	delete (Pgsql_QueryPort*)self->dbPort;
} 

void pgSqlOpenCursor(Pgsql_PgSqlDatabase* db, Db_Query* self)
{
	((Pgsql_QueryPort*)self->dbPort)->openCursor(self);
}

void pgSqlCloseCursor(Pgsql_PgSqlDatabase* db, Db_Query* self)
{
	((Pgsql_QueryPort*)self->dbPort)->closeCursor();
}


Pgsql_PgSqlDatabase* pgSqlConnect(Pgsql_PgSqlDatabase* self, char* dbName, char* host, char* user, char* password)
{
	GC_BIND;
	self->pgSqlHandle = NULL;
	self->pgSqlHandle = PQsetdbLogin(host, "5432",NULL, NULL,dbName, user, password);

    if (PQstatus(self->pgSqlHandle) == CONNECTION_BAD)
    {
		
        //pgSqlError(self, PQerrorMessage(conn));
        pgSqlError(self, "Connection to database failed.");
//        exit_nicely(conn);
    }


	{
		return self;
	}
	Db_appendDriverInfo_Database(self, dbName);
	Db_appendDriverInfo_Database(self, copy_string(" - Native - PgSQL"));

	GC_UNBIND;
	return self;
}

void pgSqlDisconnect(Pgsql_PgSqlDatabase* self)
{
	if(self->pgSqlHandle) PQfinish(self->pgSqlHandle);
}

list* pgSqlTables(Pgsql_PgSqlDatabase* self, list* tables)
{
	GC_BIND;
/*	MYSQL_FIELD* fd;
	MYSQL_ROW row;
	MYSQL_RES* res = mysql_list_tables(self->pgSqlHandle, "%" );	
	    
    if(res == NULL)
    	pgSqlError(self);
    	
	while(row = mysql_fetch_row(res)) 
	{
		if(row[0]!=NULL && strlen(row[0]))
			tables = add_list(tables, _string_(copy_string(row[0]))); 
	}
	mysql_free_result(res); */
	GC_UNBIND;
	return tables;
}
