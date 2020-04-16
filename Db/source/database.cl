//*********************************************************************
//* Db                                                Sylvain Benilan *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*********************************************************************


popQuery :: property()

[private/printInDatabase(self:Database, qry:Query) : port
 -> //[5] printInDatabase(DataBase = ~S, query = ~S) // self, qry,
 	if (known?(currentQuery, self) &
 			self.currentQuery != qry) qry.previousQuery := self.currentQuery,
	self.currentQuery := qry,
	qry.oldPort := use_as_output(qry.dbPort),
	openCursor(qry), 
	qry.pending? := true,
	qry.oldPort]
	
[private/printInQuery!(self:Database) : port =>
	//[5] printInQuery!(DataBase = ~S) // self,
 	printInDatabase(self, query!(self))]

[private/executeQuery!(self:Database, sql:string) : integer
 -> printInDatabase(self, query!(self)), princ(sql), execute(self.currentQuery)]

// ones should call initFirstQuery to initialize
// the Database query chain
[private/initFirstQuery(self:Database) : Database
 -> //[5] initFirstQuery(DataBase = ~S) // self,
 	self.firstQuery := query!(self), self.currentQuery := self.firstQuery, self]

// creates a query seperated from the the database chain
[query!(self:Database) : Query -> Query(database = self)]

// clean the current query and set
// the current query to its previous chained query
[popQuery(self:Database) : void
 -> //[5] popQuery(DataBase = ~S) // self,
 	if unknown?(currentQuery, self)
 		dbError!(self, "PopQuery failed, the database doesn't own any pending query "),
 	if self.currentQuery.cursorOpened? closeCursor(self.currentQuery),
 	free(self.currentQuery),
 	if not(self.queries)
 		initFirstQuery(self)]


//////////////////////////////////////////////////////////////////////////////////////////
// catalog methods

// @cat Catalog methods
// Db provides two special methods to get informations about the database structure.
// The first one (tables @ Database) retrieves the list of table names :
// \code
// show_db_tables(self:Db/Database) : void ->
// 	printf("~S tables :\n~I",
// 			self,
// 			for t in Db/tables(self)
// 				printf("~A\n", t))
// \/code
// The second one (columns) is use to retrieve columns of a given table :
// \code
// show_table_columns(self:Db/Database, tab:string) : void ->
// 	printf("~S, columns of table ~A :\n~I",
// 			self,
// 			tab,
// 			for c in Db/columns(tab)
// 				printf("column ~A: nullable: ~S, SQL type: ~A\n",
// 					c.name, c.Db/nullable?, c.Db/sqlTypeName))
// \/code
// @cat

// @doc Catalog methods
// tables(self) returns the list of table names for the given database.
[tables(self:Database) : list[string] -> dbTables(self,list<string>()) as list[string]]

// @doc Catalog methods
// columns(self) returns a list of column objects for a given table of the given database.
[columns(self:Database, t_:string) : list[Column] -> dbColumns(self, t_, list<Column>()) as list[Column]]


//@doc Catalog methods
// index?(self:Database,table:string,column:string) check if an index was defined for a given column in a given table on the given database
[index?(self:Database,_t:string,_col:string) : boolean -> dbIndexExists?(self,_t,_col) as boolean]

//@doc Catalog methods
// info(self:Database,table:string,key:string) return table info for key
[info(self:Database,_t:string,key:string) : string
-> dbTableInfo(self,_t,key) as string]

// abstract callback
[dbTableInfo(self:Database,_t:string,key:string) : string -> ""]

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// executing queries

// @cat Executing queries
// The execute method allow submition of direct SQL queries in a simple way, for instance :
// \code
// Db/execute(DB, "SELECT * FORM my_table")
// Db/execute(DB, "INSERT ...")
// \/code
// Oftenly we need to build the SQL statement dynamicaly. Db comes with an SQL redirection
// facility, the current output can be localy redirected to the statement of a query as in :
// \code
// (Db/printInQuery(DB), // starts a new redirected query
// printf("UPDATE ~A ...", ...) // print the SQL statement dynamicaly
// let affected_rows := Db/endOfQuery(DB)  // ends redirection and execute query
// in ...)
//
// (Db/printInQuery(DB), // starts a new redirected query
// printf("SELECT ~A ...", ...) // print the SQL statement dynamicaly
// assert(Db/endOfQuery(DB) = -1) // ends redirection and execute query
// \/code
// endOfQuery returns the same status code than execute which would be -1 for a SELECT statement
// and the amount of affected rows otherwise. In the case of a SELECT statement we may omit the call
// to endOfQuery, indeed we would always use fetch for SELECT statement in order to retrieve a
// row of the result set. The first fetch call would automaticaly ends the rediretion and execute
// the query if it hasn't be done with endOfQuery, so we could write :
// \code
// (Db/printInQuery(DB),
// printf("SELECT ~A ...", ...)
// while Db/fetch(DB) // the first fetch ends redirection and executes the query
// 		... )
// \/code
// @cat





// @doc Executing queries
// execute(self, sql) execute a new query with the given sql statement (direct execution) and return
// an integer status whith the following meaning :
// \ul
// \li -1 means that a result set is available (SELECT statements). You'll have to use fetch, field and row
// API to explore te result set.
// \li a positive integer that represents the number affected rows (othe statements : INSERT, UPDATE, DELETE ...).
// \/ul
[execute(self:Database, sql:string) : integer
 -> if (unknown?(currentQuery, self) | self.currentQuery.pending?) executeQuery!(self, sql)
 	else (let res := execute(self.currentQuery, sql)
 			in (if not(self.currentQuery.pending?)
 					popQuery(self), res))]

[execute(self:Database) : void -> 
	dbExecute(self, self.currentQuery),
	self.currentQuery.executed? := true,
	self.currentQuery.prepared? := false]
	
[prepare(self:Database, sql:string) : void ->
	if (unknown?(currentQuery, self) | self.currentQuery.pending?)
		let qry := query!(self)
		in	(self.currentQuery := qry,
			qry.pending? := true),
 	prepare(self.currentQuery, sql)]

[prepare(self:Database) : void -> prepare(self.currentQuery)]

[bindParam(self:Database, param:integer) : port ->
	if unknown?(currentQuery, self) error("bindParam error"),
 	bindParam(self.currentQuery, param)]

[execute(self:Database, l:list) : void ->
	for i in l
		(if not(i % integer) error("invalid argument ~S for bindParams (expected fields indexes)", i),
		bindParam(self, i as integer)),
	execute(self)]

[execute(self:Database, sql:string, l:list) : void ->
	prepare(self, sql),
	for i in l
		(if not(i % integer) error("invalid argument ~S for bindParams (expected field's index)", i),
		self.currentQuery.portParams :add tuple(i, bindParam(self, i as integer))),
	execute(self)]

[nextParam(self:Database) : tuple(integer, port) ->
	if known?(currentParam, self.currentQuery) fclose(self.currentQuery.currentParam),
	let f := dbSetParam(self, self.currentQuery),
		p := some(p in self.currentQuery.portParams|p[1] = f),
		t := tuple(f as integer, p[2] as port)
	in (self.currentQuery.currentParam := t[2],
		t)]


// @doc Executing queries
// printInQuery(self) redirect the current output port to new SQL query. Any printing
// operation will then be redirected to the query (an SQL statement is expected) until
// a call to endOfQuery(self) appends.
[printInQuery(self:Database) : port
 -> //[5] printInQuery(DataBase = ~S) // self,
 	if (unknown?(currentQuery, self) | self.currentQuery.pending?) printInQuery!(self)
	else printInDatabase(self, self.currentQuery)]
//		(self.currentQuery.oldPort := use_as_output(self.currentQuery.dbPort),
	//	openCursor(self.currentQuery), self.currentQuery.oldPort)]
		
// @doc Executing queries
// endOfQuery(self) executes the SQL query started by printInQuery(self) the
// return integer status has the same meaning as execute(self, sql)
[endOfQuery(self:Database) : integer
 -> //[5] endOfQuery(DataBase = ~S) // self,
	if unknown?(currentQuery, self)
 		dbError!(self, "Execute failed, the database doesn't own any pending query "),
 	if known?(currentParam, self.currentQuery) fclose(self.currentQuery.currentParam),
 	let res := execute(self.currentQuery)
 	in (if not(self.currentQuery.pending?)
 			popQuery(self), res)]

[query(self:Database) : string ->
	(print_in_string(),
	dbPrintQuery(self.currentQuery.dbPort),
	end_of_string())]
 	

//////////////////////////////////////////////////////////////////////////////////////////
// managing the result set

// @cat Reading result sets
// When a SELECT statement is executed a result set can be iterated. A result set is made
// of row results and each row is made of fields. Rows are loaded one at a time with a call
// to fetch. fetch should be called repeatedly until false is returned which would mean that
// the result set has been loaded entirely and that the query has been deleted. For instance
// the following method prints the content of a table :
// \code
// show_table_content(self:Db/Database, tab:string) : void ->
// 	(Db/printInQuery(self),
// 	printf("SELECT * FROM ~A", tab),
// 	while Db/fetch(self) // iterate the result set
// 		printf("~A\n", Db/row(self))) // and print each rows
// \/code
// Where row(self) return the list of field values of the current fetched row. It is sometimes
// necessary to have a field access by its name, for instance when we use database procedures :
// \code
// (Db/execute(DB, "SELECT Count(*) AS my_field FROM my_table"),
// while Db/fetch(DB)
// 	let count := Db/field(DB, "my_field")
// 	in ...
// \/code
// Here we use the SQL AS keyword that binds the count field to a specify name. The use of the AS
// keyword is a good practice since it makes database code more portable from a database to another.
// @cat


// @doc Reading result sets
// fetch(self) loads a new row (if any) from the result set of the current executed query.
// fetch must be used after the execution of a SELECT statement (for which execute or endOfQuery
// returns -1). fetch returns true if a row could actuly be loaded, othewise false is returned
// and the current query is deleted.
[fetch(self:Database) : boolean
 -> //[5] fetch(DataBase = ~S) // self,
 	if unknown?(currentQuery, self) 
		dbError!(self, "Fetch failed, the database doesn't own any pending query "),
 	if fetch(self.currentQuery) true else (popQuery(self), false)]
 			
// @doc Reading result sets
// row(self) returns the list of values associated with the current fetched row. The order
// of the list depends on how the query was written and may be system dependent.
// The returned list may contain :
// \ul
// \li the unknown value when the corresponding value is NULL in the database
// \li a blob device when the corresponding value is a BLOB or LONGBINARY object in the database
// \li else a string is returned, it up to the user code to apply integer! or float! conversions
// \/ul
[row(self:Database) : list[(string U port U {unknown})]
 -> if unknown?(currentQuery, self) 
		dbError!(self, "Row failed, the database doesn't own any pending query "),
	row(self.currentQuery)]
	
// @doc Reading result sets
// field(self, fieldName) returns from the current fetched row the value associated with the field
// with named fieldName in the SQL query.
[field(self:Database, fieldName:string) : (string U port U {unknown})
 -> if unknown?(currentQuery, self) 
		dbError!(self, "Field failed, the database doesn't own any pending query "),
	field(self.currentQuery, fieldName)]
	
// @doc Reading result sets
// field(self, f) returns from the current fetched row the value associated with the field
// with index f in the SQL query.
[field(self:Database, f:integer) : (string U port U {unknown})
 -> if unknown?(currentQuery, self) 
		dbError!(self, "Field failed, the database doesn't own any pending query "),
	field(self.currentQuery, f)]
	
// @doc Reading result sets
// fields(self) return the list of names associated with the current query in the same
// way to row(self) that returns their corresponding value in the current fetched row.
[fields(self:Database) : list[string]
 -> if unknown?(currentQuery, self) 
		dbError!(self, "Fields failed, the database doesn't own any pending query "),
	fields(self.currentQuery)]


[duplicate(self:Database) : Database => dbDuplicate(self) as Database]



// @cat Transaction
// Usualy, a user code that connects to a database make multiple queries. The major
// problem comes when the connected application reaches an undefined behavior while
// it has already submited queries that have modified the database integrity. To solve
// this kind of problem an application should perform queries inside a transaction that
// would commit all modification at one time or abort all queries of the transaction
// in case of undefined behavior :
// \code
// try
// 	(Db/beginTransaction(DB),
// 	... // some code that submit multiple queries
// 	Db/commitTransaction(DB)) // OK, commit all the queries of the transaction
// catch any
// 	Db/rollbackTransaction(DB) // ignore all queries that have been performed
// 							// during the transaction
// \/code
// @cat


// @doc Transaction
// beginTransaction(self) starts a new transaction with the database. All queries
// that are executed during the transaction are not actualy commited in the
// database. A transaction ends whe commitTreansaction(self) is called which would
// commit all queries in a definitive way whereas rollbackTransaction(self) would
// left the database unchanged in addition to end the transaction.
[beginTransaction(self:Database) : void -> 
	if (self.onTransaction?) commitTransaction(self),
	self.onTransaction? := true,
	dbBeginTransaction(self)]

// @doc Transaction
// commitTransaction(self) commits all queries that have been executed since
// the call to beginTransaction(self) and ends the current transaction.
[commitTransaction(self:Database) : void -> 
	if self.onTransaction?
		(self.onTransaction? := false,
		dbCommitTransaction(self))
	else //[1] warning : call dbCommitTransaction(~S) without starting transaction // self
]

// @doc Transaction
// rollbackTransaction(self) cancel all queries that have been executed since
// the call to beginTransaction(self) and ends the current transaction.
[rollbackTransaction(self:Database) : void -> 
	if self.onTransaction?
		(self.onTransaction? := false,
		dbRollbackTransaction(self))
	else //[1] warning : call dbCommitTransaction(~S) without starting transaction // self
]
		

// @cat Disconnection
// When we are done with the database we have to disconnect from it :
// \code
// Db/disconnect(DB)
// \/code
// @cat


// @doc Disconnection
// disconnect(self) disconnects the database and cleanup all pending queries.
[disconnect(self:Database) : void
 -> //[2] disconnect(DataBase = ~S) // self,
 	while self.queries free(self.queries[length(self.queries)]),
	if self.onTransaction? commitTransaction(self),
 	dbDisconnect(self)]

// @cat Connexion
// Open a connexion to a database :
// \code
// Db/connect!(driver:string,host:string,dbname:string,login:string,pass:string)
// \/code
// Open a database with a configuration string :
// [kind]:[host]:[database]:[login]:[pass]
// \code
// Db/connect(driver:string,host:string,dbname:string,login:string,pass:string)
// \/code
// @cat


// @doc Connexion
// connect!(driver,host,database,login,password) connect to a database.
[connect!(driver:string,host:string,dbname:string,login:string,pass:string) : Database
-> //[2] connect(driver = ~S, host = ~S, database = ~S , login = ~S, pass = ~S) // driver,host,dbname,login,pass,
	DbError(msg = ("connect!() : unknown driver " /+ driver)),
	Database()]

// @doc Connexion
// connect!(self) connect to a database with a config string
// [kind]:[host]:[database]:[login]:[pass]
[connect!(config:string) : Database
->	let x := (let y := explode(config,":") in (while (length(y) < 5) y :add "", y))
	in (connect!(x[1],x[2],x[3],x[4],x[5]))]

(open(connect!) := 3)


[createDatabase(kind:string,host:string,dbname:string,adminlogin:string,adminpwd:string,encoding:string,dbowner:string) : boolean
->	DbError(msg = ("createDatabase() : unknown driver " /+ kind)),
	false]

(open(createDatabase) := 3)

[config!(self:string) : list[string]
->	let c := list<string>("","","","","",""),
		r := explode(self,":")
	in (for i in (1 .. length(r)) c[i] := r[i],
		c)]
		
