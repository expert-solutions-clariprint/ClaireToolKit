//*********************************************************************
//* Db                                                Sylvain Benilan *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*********************************************************************

// the xlDb's errors class
DbError <: exception(msg:string, fromDb:Database, haveQuery?:boolean = false)

[dbError!(self:Database, srcError:string) : void
 -> DbError(fromDb = self, msg = srcError)]

[dbErrorWithQuery!(self:Database, srcError:string) : void
 -> DbError(fromDb = self, msg = srcError, haveQuery? = true)]

[self_print(self:DbError) : void
 -> if known?(fromDb,self)
		printf("**** Database error ~S\n~A", self.fromDb, self.msg)
	else
		printf("**** Database error ~A\n", self.msg),
 	if self.haveQuery?
 		printf("\n++++ failed in SQL query:\nSQL[~S]", echoQuery(self.fromDb.currentQuery))]

