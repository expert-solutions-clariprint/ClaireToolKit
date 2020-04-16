//*********************************************************************
//* Db                                                Sylvain Benilan *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*********************************************************************

#include <claire.h>
#include <Kernel.h>
#include <Core.h>
#include <Db.h>
#include "queryport.h"

int QueryPort::mCursorId = 0;

int QueryPort::SqlLength()
{ 
	return index; 
};

void QueryPort::puts(char* s) {
    	int len = strlen(s);
        while(index+len+1 >= size) increaseBuffer();
        strncpy(mSqlQuery+index,s,len+1);
        index += len; };

int QueryPort::puts(void* data, int ssize)
    	{ while(index+ssize+1 >= size) increaseBuffer();
        memcpy(mSqlQuery+index,data,ssize);
        index += ssize;
        mSqlQuery[index] = 0;
        return ssize; }


void QueryPort::increaseBuffer() {
  if(chunck == -1) { // first alllcation
  	chunck = 8192;
  	size = 8192;
  	index = 0;
  	mSqlQuery = (char*)malloc(chunck*sizeof(char)); }
  else {
  	mSqlQuery = (char*)realloc(mSqlQuery, size + chunck*sizeof(char));
  	size += chunck; }
  if(chunck < 524288) chunck *= 4; // maximum chunck size
  if (mSqlQuery == NULL) 
	  { //delete this;
	   list *l = Kernel._freeable_object->instances;
 		int i, len = l->length;
		 for (i = 4;i <= len;i++)
    	{OID n = (*l)[i];
    	if (INHERIT(OWNER(n),Kernel._port)) //<sb> mark all ports for the moment...
		{
			 PortObject *po = OBJECT(PortObject, n);
			 ClairePort *p = po->pimported;
			 if (p) {
			 	printf("fclose not called on ");
			 	p->debugSee();
			 }
		}
		}

	  Cerror(36,_string_("query port (buffer allocation failed)"),0);
	  } }

void QueryPort::resetQueryBuffer()
{ 
	index = 0;
};


QueryPort::QueryPort()
{   mSqlQuery = 0;
	chunck = -1;
	increaseBuffer();
	newCursorName();
	resetQueryBuffer();
};

char* QueryPort::newCursorName()
{
	char buf[10];
	strcpy(mSqlCursorName,"cursor");
#ifdef CLPC
	strcat(mSqlCursorName, _itoa(mCursorId++, buf, 10));
#else
	sprintf(buf,"%d",mCursorId++);
	strcat(mSqlCursorName, buf);
#endif
	return mSqlCursorName;
}


char *getSqlData(Db_Query *self) {
	QueryPort* p = (QueryPort*)self->dbPort->imported();
	return copy_string1(p->mSqlQuery, p->SqlLength());
}

