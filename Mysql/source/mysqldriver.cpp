//*********************************************************************
//* Mysql                                             Sylvain Benilan *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*********************************************************************


#include <claire.h>
#include <Kernel.h>
#include <Core.h>
#include <Db.h>
#include <Mysql.h>
#include <queryport.h> 
#include <mysqldriver.h>


//////////////////////////////////////////////////////////////////
// MySQL error handling
//////////////////////////////////////////////////////////////////

void mySqlError(Mysql_MySqlDatabase* self) 
{
	Db_dbError_I_Database1(self, copy_string((char*)mysql_error(self->mySqlHandle)));
}

void mySqlError(Mysql_MySqlDatabase* self, char* err) 
{
	Db_dbError_I_Database1(self, copy_string(err));
}

void mySqlErrorWithDb_Query(Mysql_MySqlDatabase* self)
{
	char* err = copy_string((char*)mysql_error(self->mySqlHandle));
	//Db_popQuery_Database1(self);
	Db_dbErrorWithQuery_I_Database1(self, err);
}

//////////////////////////////////////////////////////////////////
// MySQL database
//////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////
// MySQL query port
//////////////////////////////////////////////////////////////////

class Mysql_QueryPort : public QueryPort
{
public:	

	Mysql_MySqlDatabase* mDatabase;
	MYSQL_RES* mRes;
	MYSQL_ROW mRow;
	int escape;
	
	Mysql_QueryPort(Mysql_MySqlDatabase* db);
	~Mysql_QueryPort();
	
	virtual void put(char c) {
		if(escape && (c == '\\' || c == 0 || c == 26 /* ^Z */ ||
						c == '\'' || c == '"' || c == '\n' || c == '\r')) {
			QueryPort::put('\\');
			switch(c) {
				case 0: QueryPort::put('0'); break;
				case '\r': QueryPort::put('r'); break;
				case '\n': QueryPort::put('n'); break;
				case 26: QueryPort::put('Z'); break;
				default: QueryPort::put(c); } }
		else QueryPort::put(c);
	}
	
	virtual void puts(char* s) {
		while(*s) put(*s++);
	}
	
	virtual int puts(void* data, int ssize) {
		int i = 0;
		for(;i < ssize;i++) put(((char*)data)[i]);
		return ssize;
	}
	
	void execute(Db_Query* q);
	void closeCursor();
	void openCursor(Db_Query* self);
	ClaireBoolean* fetch();	
	
	virtual void pclose() {
		freeQuery();
		delete this; }
};

 //////////////////////////////////////////////////////////////////

Mysql_QueryPort::Mysql_QueryPort(Mysql_MySqlDatabase* self)
{
	mDatabase = self;
	mRes = NULL;
	escape = 0;
}

Mysql_QueryPort::~Mysql_QueryPort()
{
}

void Mysql_QueryPort::execute(Db_Query* self)
{
	GC_BIND;
	if(mysql_real_query(mDatabase->mySqlHandle, mSqlQuery, SqlLength()))
		mySqlErrorWithDb_Query(mDatabase);
	
	mRes = mysql_store_result(mDatabase->mySqlHandle);

	if(mRes)
	{
		// something to fetch
		self->rowCount = -1;
		self->colCount = mysql_num_fields(mRes);
		for(unsigned col = 0; col < self->colCount; col++)
		{
		    MYSQL_FIELD *field = mysql_fetch_field_direct(mRes, col);
		    Db_addField_Query1(self, GC_STRING(copy_string(field->name)), col+1);
		}
	}
	else
	{
		// nothing to fetch
		self->colCount = -1;
		if(mysql_errno(mDatabase->mySqlHandle))
			mySqlError(mDatabase);
		else self->rowCount = mysql_affected_rows(mDatabase->mySqlHandle);
	}
	GC_UNBIND;
}

void Mysql_QueryPort::openCursor(Db_Query* self) 
{
}

void Mysql_QueryPort::closeCursor()
{
	resetQueryBuffer();
	if(mRes) mysql_free_result(mRes);
}

ClaireBoolean* Mysql_QueryPort::fetch()
{
	mRow = mysql_fetch_row(mRes);
	return mRow ? CTRUE : CFALSE;
}


//////////////////////////////////////////////////////////////////
// MySQL externals
//////////////////////////////////////////////////////////////////



PortObject* mySqlPort(Mysql_MySqlDatabase* self)
{
	PortObject *p = make_port(Kernel._port, 0);
	Mysql_QueryPort* mp = new Mysql_QueryPort(self);
	if(mp == 0) Cerror(61,_string_("mySqlPort"),0);
	p->pimported = mp;
	return p;
}

void mySqlExecute(Mysql_MySqlDatabase* db, Db_Query* self)
{
	((Mysql_QueryPort*)self->dbPort->imported())->execute(self);
}

void mySqlBeginEscape(Mysql_MySqlDatabase* db, Db_Query* self) {
	((Mysql_QueryPort*)self->dbPort->imported())->escape = 1;
}

void mySqlEndEscape(Mysql_MySqlDatabase* db, Db_Query* self) {
	((Mysql_QueryPort*)self->dbPort->imported())->escape = 0;
}

char* mySqlRealEscape(Mysql_MySqlDatabase* db, char* data) {
	int len = length_string(data);
	char* z = new char[len * 2];
	if(z == 0) Cerror(61,_string_("mySqlRealEscape"),0);
	int olen = mysql_real_escape_string(db->mySqlHandle, z, data, len);
	char* res = copy_string1(z, olen);
	delete [] z;
	return res;
}

ClaireBoolean* mySqlFetch(Mysql_MySqlDatabase* db, Db_Query* self)
{
	GC_BIND;
	Mysql_QueryPort* qp = (Mysql_QueryPort*)self->dbPort->imported();
	ClaireBoolean* Result = qp->fetch();
	if(Result == CTRUE && self->colCount > 0)
	{
		int ifield = 0;
		unsigned long *lens = mysql_fetch_lengths(qp->mRes);
		MYSQL_FIELD *fields = mysql_fetch_fields(qp->mRes);
		for(;ifield < self->colCount;ifield++) {
			if(qp->mRow[ifield]) {
				//MYSQL_FIELD *field = &qp->mRes->fields[ifield];
				//printf("----ici mres=%d->fields[%d] -> %d\n",&qp->mRes,ifield,field);
//				printf("++ %s\n",fields[ifield].name);
//				printf("%d\n",fields[ifield].type);
//				printf("flag = %s\n",bin_I_integer(fields[ifield].flags));
//				printf("bf     %s\n",bin_I_integer(BINARY_FLAG));
//				printf("tb     %s\n",bin_I_integer(FIELD_TYPE_BLOB));
//				printf("ts     %s\n",bin_I_integer(FIELD_TYPE_STRING));
//				if(fields[ifield].flags & BINARY_FLAG) { // for blob return a buffer port
//				if(fields[ifield].flags & BINARY_FLAG && fields[ifield].type == FIELD_TYPE_BLOB) { // for blob return a buffer port
				if(fields[ifield].type == FIELD_TYPE_BLOB) { // for blob return a buffer port
					BufferObject* p = port_I_void();
					p->imported()->puts(qp->mRow[ifield], lens[ifield]);
					self->rs = GC_OBJECT(list,self->rs->addFast(GC_OID(_oid_(p))));
				} else self->rs = GC_OBJECT(list,self->rs->addFast(_string_(copy_string(qp->mRow[ifield]))));
			} else self->rs = GC_OBJECT(list,self->rs->addFast(CNULL));
		}
	}
	GC_UNBIND;
	return Result;
}

void mySqlFree(Mysql_MySqlDatabase* db, Db_Query* self)
{
	fclose_port(self->dbPort);
} 

void mySqlOpenCursor(Mysql_MySqlDatabase* db, Db_Query* self)
{
	((Mysql_QueryPort*)self->dbPort->imported())->openCursor(self);
}

void mySqlCloseCursor(Mysql_MySqlDatabase* db, Db_Query* self)
{
	((Mysql_QueryPort*)self->dbPort->imported())->closeCursor();
}


Mysql_MySqlDatabase* mySqlConnect(Mysql_MySqlDatabase* self, char* dbName, char* host, char* user, char* password)
{
	GC_BIND;
	self->mySqlHandle = NULL;
	self->mySqlHandle = mysql_init(self->mySqlHandle);
	if(self->mySqlHandle == NULL)  {
		mySqlError(self, "Not enought memory to allocate a mySQL handle");
		return self;
	}

	Db_appendDriverInfo_Database1(self, dbName);
	Db_appendDriverInfo_Database1(self, GC_STRING(copy_string(" - Native - MySQL")));

	int attempt = 5;
	while(1) {
		uint timeout = 5;
		mysql_options(self->mySqlHandle, MYSQL_OPT_CONNECT_TIMEOUT, (char*)&timeout);
		if(attempt && mysql_real_connect(self->mySqlHandle, host, user, password, dbName, 0, NULL, 0))
			break; //<sb> conn ok
		attempt--;
		if(attempt == 0) {
			Ctracef("Mysql connection on %s at %s still failed after 5 attemps...\n",
						dbName, host, 5 - attempt);
			mySqlError(self);
		}
		Ctracef("Mysql connection on %s at %s failed (attempt %d)\n",
						dbName, host, 5 - attempt);
		
	}
	GC_UNBIND;
	return self;
}


Mysql_MySqlDatabase* mySqlConnect2(Mysql_MySqlDatabase* self, char* dbName, char* user, char* password, char* sock)
{
	GC_BIND;
	self->mySqlHandle = NULL;
	self->mySqlHandle = mysql_init(self->mySqlHandle);
	if(self->mySqlHandle == NULL) 
	{
		mySqlError(self, "Not enought memory to allocate a mySQL handle");
		return self;
	}
	//mysql_options(self->mySqlHandle, MYSQL_SET_CHARSET_DIR, "/sw/share/mysql/charsets");
	//mysql_options(self->mySqlHandle, MYSQL_SET_CHARSET_NAME, "latin1");
	Db_appendDriverInfo_Database1(self, dbName);
	Db_appendDriverInfo_Database1(self, GC_STRING(copy_string(" - Native - MySQL")));
	if(!mysql_real_connect(self->mySqlHandle, NULL, user, password, dbName, 0, sock, 0))
		mySqlError(self);
	GC_UNBIND;
	return self;
}



void mySqlDisconnect(Mysql_MySqlDatabase* self)
{
	if(self->mySqlHandle) mysql_close(self->mySqlHandle);
}

list* mySqlTables(Mysql_MySqlDatabase* self, list* tables)
{
	GC_BIND;
	MYSQL_FIELD* fd;
	MYSQL_ROW row;
	MYSQL_RES* res = mysql_list_tables(self->mySqlHandle, "%" );	
	    
    if(res == NULL)
    	mySqlError(self);
    	
	while(row = mysql_fetch_row(res)) 
	{
		if(row[0]!=NULL && strlen(row[0]))
			tables = add_list(tables, _string_(copy_string(row[0]))); 
	}
	mysql_free_result(res); 
	GC_UNBIND;
	return tables;
}



