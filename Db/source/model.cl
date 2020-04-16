//*********************************************************************
//* Db                                                Sylvain Benilan *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*********************************************************************


// @presentation
// The Db module is a general purpose module dedicated to databases
// connection. It provides the API to submit SQL query to a database
// and loading datas from a database. It also provide transaction
// support. In order to actualy connect a database, a driver module
// that implement the Db interface should be used (For instance the
// Mysql driver module).
// @presentation

// callbacks

dbPort! :: property()		// construct a db port instance
dbFetch :: property()		// fetch the result set of 1 row
dbExecute :: property()		// execute a query
dbPrepare :: property()		// execute a query
dbBindParam :: property()	// execute a query
dbSetParam :: property()	// execute a query
dbFree :: property()		// free the query
dbDisconnect :: property()	// disconnect the database
dbTables :: property()		// returns the list of table names
dbCloseCursor :: property()	// close an opened SQL cursor
dbOpenCursor :: property()	// open a new SQL cursor
dbColumns :: property()		// returns a list describing columns of a given table name (nullablity, type...)
dbConnect :: property()
dbBeginEscape :: property()
dbEndEscape :: property()
dbDuplicate :: property()
dbPrintQuery :: property()  //<sb> new port

dbBeginTransaction :: property()
dbCommitTransaction :: property()
dbRollbackTransaction :: property()

dbIndexExists? :: property()
dbTableInfo :: property()

(abstract(dbPort!))
(abstract(dbFetch))
(abstract(dbExecute))
(abstract(dbPrepare))
(abstract(dbSetParam))
(abstract(dbBindParam))
(abstract(dbFree))
(abstract(dbDisconnect))
(abstract(dbTables))
(abstract(dbOpenCursor))
(abstract(dbCloseCursor))
(abstract(dbColumns))
(abstract(dbConnect))
(abstract(dbBeginEscape))
(abstract(dbEndEscape))
(abstract(dbDuplicate))
(abstract(dbPrintQuery))
(abstract(dbBeginTransaction))
(abstract(dbCommitTransaction))
(abstract(dbRollbackTransaction))

(abstract(dbIndexExists?))
(abstract(dbTableInfo))


//dbOpenCursor

// DB verbosity index

DB_QUERY:integer := 1


// @cat Connection, driver module
// The module Db implements a general purpose Database engine for CLAIRE.
// It defines a set of API that should be implemented by a database driver
// module like Mysql. It is up to the driver to provide a connection method
// that creates an instance of the Database class used by all method of the
// Db module. For instance Mysql provides the following constructor :
// \code
// DB :: Mysql/mySql!("database name", "host address", "user", "password")
// \/code
// @cat

// classes

Query <: ephemeral_object
Database <: ephemeral_object
Column <: ephemeral_object

// the query class
Query <: ephemeral_object(
				private/dbPort:port,	// the query port
				private/oldPort:port,	// the previous port in use
				private/database:Database,	// the dadtabase that own the query
				private/fetched?:boolean = false,	// is the query in fetch mode?
				private/executed?:boolean = false,	// is the query executed?
				private/prepared?:boolean = false,	// is the query executed?
				private/portParams:list[tuple(integer,port)],
				private/currentParam:port,
				private/pending?:boolean = false,	// is the query own pending results?
				private/cursorOpened?:boolean = false,	// is the query owns an opened cursor?
				private/rowCount:integer = -1,	// store the affected row count
				private/colCount:integer = -1,	// store the result row size
				private/cols:list[tuple(string, integer)],	// query's result map between fied identifiers and their index in the row
				private/rs:list[(string U port U {unknown})], // the query's result set
				private/previousQuery:Query) // the previous query if exists

// the database class
// this is a final class
Database <: ephemeral_object(
				driverType:integer = 0,
				private/shouldPrepare?:boolean = false, // ODBC will have this field to true
				private/dbInfo:string = "",	// an information string about the current connection
				private/queries:list[Query],	// owned query's with this connection
				private/firstQuery:Query,	// chained queries start here
				private/currentQuery:Query,	// the current working query
				private/autoCommit?:boolean,
				onTransaction?:boolean = false,
				autoStartTransaction?:boolean = false)

(inverse(queries) := database)
(final(Database))

// the column class
Column <: ephemeral_object(name:string,
							tableName:string,
							nullable?:boolean,
							primary?:boolean = false,
							sqlTypeName:string,
							sqlDataType:integer,
							sqlPrecision:integer,
							sqlDigits:integer,
							sqlAutoIncrement:boolean = false,
							sqlDefaultValue:string,
							foreignKeys:list[tuple(string,string)])

// how to print a column :
// starts with a star if it is a primary key
// <["*" | "?" ]{field name} {"null?" | "null" | "not null"} 
//		{SQL data type}/{SQL type name}({field precision},{field digits})>
[self_print(self:Column) : void
 -> printf("<~A~A~A ~S/~A(~S,~S)>", 
 			(if unknown?(primary?, self) "?"
 			 else (if self.primary? "*" else "")), 
 			self.name,
 			(if unknown?(nullable?, self) "null?"
 			 else (if self.nullable? " null" else " not null")),
 			 (if known?(sqlDataType,self) self.sqlDataType else "?"),
 			 (if known?(sqlTypeName,self) self.sqlTypeName else "?"),
 			 (if known?(sqlPrecision,self) self.sqlPrecision else "?"),
 			 (if known?(sqlDigits,self) self.sqlDigits else "?"))]

// how to print a Database
[self_print(self:Database) : void
 -> printf("<~A>", (if (length(self.dbInfo) > 0)
						self.dbInfo else "Database"))]

// constructor

query! :: property()

// query constructor
[close(self:Query) : Query
 -> write(dbPort, self, dbPort!(self.database)), self]


dbBeginEscape(db:Database) : void => dbBeginEscape(db, db.currentQuery)
dbEndEscape(db:Database) : void => dbEndEscape(db, db.currentQuery)

[getDbName(db:Database) : string -> ""]
(abstract(getDbName))

[getDbFileExt(self:Database) : string -> ".sql"]
(abstract(getDbFileExt))


