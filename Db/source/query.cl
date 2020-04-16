//*********************************************************************
//* Db                                                Sylvain Benilan *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*********************************************************************

fetch :: property()
field :: property()
fields :: property()
row :: property()

//////////////////////////////////////////////////////////////////////////////////////////
// cursor managment


// open a cursor for the given query
// then clean the query (result set and flags)
// note: if a SQL cursor is already opened we first close it
[private/openCursor(self:Query) : void
 -> closeCursor(self),	
	dbOpenCursor(self.database, self),
	erase(cols,self),
	erase(rs,self),
	self.executed? := false,
	self.cursorOpened? := true]
	
// close an opened SQL cursor
// and update query's flags
[private/closeCursor(self:Query) : void
 -> if self.cursorOpened? dbCloseCursor(self.database, self),
 	self.pending? := false,
 	self.cursorOpened? := false] 

//////////////////////////////////////////////////////////////////////////////////////////
// direct execution of queries


[private/echoQuery(self:Query) : string -> 
	print_in_string(),
	dbPrintQuery(self.dbPort),
	end_of_string()]
	
// @chapter 2
// execute the given query usualy after
// if an old port exists, we restore the output to that port
// returned value:
// 		-1 means that a result set is available (SELECT...)
// 		a positive integer that represents the affected rows (INSERT, UPDATE...)
[private/execute(self:Query) : integer
 -> //[2] execute(Query = ~S) // self,
 	for t in self.portParams fclose(t[2]),
 	//if known?(currentParam, self) fclose(self.currentParam),
 	if known?(oldPort, self)
		use_as_output(self.oldPort),
 	if not(self.cursorOpened?)
 		dbError!(self.database, "The query can't be excuted since its cursor is closed"),
 	self.pending? := true,
 	let t := timer!()
	in (try
			(dbExecute(self.database, self),
			mtformat(Db, "== Query successfully executed in ~A :\nSQL[~S]\n", DB_QUERY,
							list((print_in_string(),uptime(t),end_of_string()),
								echoQuery(self))))
		catch any
			(mtformat(Db, "== Exception raised during query execution : \nSQL[~S]\n", DB_QUERY,
							list(echoQuery(self))),
			close(exception!()))),
	self.executed? := true,
 	if (self.rowCount != -1)
 		(self.pending? := false,
 		closeCursor(self)),
 	self.rowCount]
 	
// @chapter 2
// execute the given query with the given SQL statement
// returned value:
// 		-1 means that a result set is available (SELECT...)
// 		a positive integer that represents the affected rows (INSERT, UPDATE...)
[execute(self:Query, sql:string) : integer
 -> let oldp:port := use_as_output(self.dbPort)
	in (openCursor(self),
		princ(sql),
		use_as_output(oldp),
		self.pending? := true,
	 	let t := timer!()
		in (try
				(dbExecute(self.database, self),
				mtformat(Db, "== Query successfully executed in ~A :\nSQL[~S]\n", DB_QUERY,
								list((print_in_string(),uptime(t),end_of_string()),
									echoQuery(self))))
			catch any
				(mtformat(Db, "== Exception raised during query execution : \nSQL[~S]\n", DB_QUERY,
								list(echoQuery(self))),
				close(exception!()))),
		self.executed? := true,
		if (self.rowCount != -1) 
			(self.pending? := false,
			closeCursor(self)),
		self.rowCount)]

[prepare(self:Query, sql:string) : void ->
	let oldp:port := use_as_output(self.dbPort)
	in (openCursor(self),
		princ(sql),
		use_as_output(oldp),
		self.prepared? := true,
		self.pending? := true,
		dbPrepare(self.database, self))]

[private/prepare(self:Query) : void
 -> //[5] prepare(Query = ~S) // self,
 	if known?(oldPort, self)
		use_as_output(self.oldPort),
 	if not(self.cursorOpened?)
 		dbError!(self.database, "The query can't be excuted since its cursor is closed"),
 	self.pending? := true,
 	self.prepared? := true,
	dbPrepare(self.database, self)]

[bindParam(self:Query, param:integer) : port ->
	let p:port := (dbBindParam(self.database, self, param) as port)
	in (self.portParams :add tuple(param,p), p)]

//////////////////////////////////////////////////////////////////////////////////////////
// redirected execution of Query


// @chapter 2
// redirect the output port to the given query
[printInQuery(self:Query) : port
 -> self.oldPort := use_as_output(self.dbPort),
	openCursor(self),
	self.pending? := true,
	self.oldPort]
	
// @chapter 2
// execute the query and ends the redirection
// returned value:
// 		-1 means that a result set is available (SELECT...)
// 		a positive integer that represents the affected rows (INSERT, UPDATE...)
[endOfQuery(self:Query) : integer => execute(self)]


//////////////////////////////////////////////////////////////////////////////////////////
// managing the result set


// @chapter 3
// fetch the given query
[fetch(self:Query) : boolean 
 -> //[5] fetch(~S) // self,
 	if not(self.cursorOpened?)
 		dbError!(self.database, "Can't fetch the query since its cursor is closed"),
	if not(self.executed?) execute(self),
    if not(self.pending?)
 		dbError!(self.database, "Fetch calls should be done after an SQL SELECT"),
 	for p:port in list{p in self.rs|p % port} fclose(p),
 	erase(rs, self),
 	if dbFetch(self.database, self) (self.fetched? := true, true)
    else (closeCursor(self), self.fetched? := false, self.pending? := false, false)]
    
// @chapter 3
// return a list of fields name for the current row
[fields(self:Query) : list[string]
 => if not(self.pending?) dbError!(self.database, "The query doesn't provide field informations"),
 	if not(self.fetched?) dbError!(self.database, "The query should be fetched at least once to call fields"),
 	if not(self.executed?) dbError!(self.database, "The query should be executed to access the fields informations"),
    list<string>{(s[1] as string)|s in self.cols}]
    
// @chapter 3
// return a field value given its name in the current row
[field(self:Query, fieldName:string) : (string U port U {unknown})
 => if not(self.pending?) dbError!(self.database, "The query doesn't provide field values"),
 	if not(self.fetched?) dbError!(self.database, "The query should be fetched at least once to call field"),
 	if not(self.executed?) dbError!(self.database, "The query should be executed to access the field informations"),
    self.rs[fieldIndex(self, fieldName)]]
    
// @chapter 3
// return a field value given its index in the current row
[field(self:Query, f:integer) : (string U port U {unknown})
 => if not(self.pending?) dbError!(self.database, "The query doesn't provide field values"),
 	if not(self.fetched?) dbError!(self.database, "The query should be fetched at least once to call field"),
 	if not(self.executed?) dbError!(self.database, "The query should be executed to access the field informations"),
    self.rs[f]]

// @chapter 3
// returns the row as a list of string
[row(self:Query) : list[(string U port U {unknown})]
 -> if not(self.pending?) dbError!(self.database, "The query doesn't provide row values"),
 	if not(self.fetched?) dbError!(self.database, "The query should be fetched at least once to call row"),
 	if not(self.executed?) dbError!(self.database, "The query should be executed to access the row informations"),
    self.rs]
    
// @chapter 6
// clean the query, deallocate memory
[free(self:Query) : void
 -> //[5] free(~S) // self,
 	if (self.cursorOpened? & not(self.executed?)) execute(self),
 	if (self.cursorOpened?) closeCursor(self),
 	//dbFree(self.database, self),
 	for x in self.rs
 		(case x
 			(port fclose(x))),
 	if known?(dbPort, self)
 		fclose(self.dbPort),
 	if known?(previousQuery, self)
		self.database.currentQuery := self.previousQuery
	else erase(currentQuery, self.database),
	self.database.queries :delete self]
