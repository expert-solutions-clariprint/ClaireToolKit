//*********************************************************************
//* Db                                                Sylvain Benilan *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*********************************************************************

#ifndef __QUERY_PORT_H__
#define __QUERY_PORT_H__


class Db_Query;

extern char *getSqlData(Db_Query *self);

extern double CLMAXFLOAT;
extern double CLMINFLOAT;

class QueryPort : public ClairePort 
{

public:
	
	static int mCursorId;
	int autoCommit;
	char sprintfbuf[1024];

	char *mSqlQuery;
	char mSqlCursorName[20];
	int chunck;
    int index;
    int size;
    	
	int SqlLength();
	void increaseBuffer();
	void freeQuery() {
		if(mSqlQuery) free(mSqlQuery);
		};
	virtual void put(char s) {
		QueryPort::puts(&s, 1);
	}
    virtual void puts(char* s);
    virtual int puts(void* data, int ssize);
	virtual void pclose() {
		freeQuery();
		delete this; }
    
    virtual void debugSee()
     { printf("QueryPort(%x)", mSqlQuery);
     };

    void resetQueryBuffer();
	QueryPort();
	char* newCursorName();
	
};

#endif
