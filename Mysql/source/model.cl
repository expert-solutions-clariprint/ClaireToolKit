//*********************************************************************
//* Mysql                                             Sylvain Benilan *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*********************************************************************

// win32: www.mysql.com -> install mysql/win32
// os X: already installed!
// unix: install mysql

// @presentation
// The Mysql module is a driver module for the Db interface. It relies the
// popular mysqlclient library.
// @presentation

// @cat Connecting a mySQL database
// The Mysql module is a driver module for the Db interface. It relies the
// popular mysqlclient library and provide a database connector for mySQL.
// @cat


MySqlHandle <: import()
MYSQL_RES* <: import()
MYSQL_ROW <: import()

(c_interface(MySqlHandle,"MYSQL* "))
(c_interface(MYSQL_RES*,"MYSQL_RES* "))
(c_interface(MYSQL_ROW,"MYSQL_ROW "))

MySqlDatabase <: Database(mySqlHandle:MySqlHandle,
							mySqlDbName:string = "",
							mySqlAddress:string = "",
							mySqlUser:string = "",
							mySqlPassword:string = "",
							mySqlCharset:string = "latin1")

mysql_error!(self:MySqlDatabase) : void ->
	dbErrorWithQuery!(self,
		copy(externC("((char*)mysql_error(self->mySqlHandle))", string)))

mysql_blob <: blob(
			db:MySqlDatabase,
			mRes:MYSQL_RES*,
			mRow:MYSQL_ROW,
			escape?:boolean = false)

[dbPrintQuery(self:mysql_blob) : void ->
	freadwrite(self, cout()),
	set_index(self, 0)]


[write_port(self:mysql_blob, in_buf:char*, len:integer) : integer ->
	(if self.escape?
		(externC("char buf[256];
				char* travel = buf;"),
		for i in (0 .. len - 1)
			let n := externC("(travel - buf)", integer)
			in (externC("char c = in_buf[i]"),
				if externC("(n >= 250 ? CTRUE : CFALSE)", boolean)
					(write_port@blob(self, externC("buf", char*), n),
					externC("travel = buf")),
				if externC("(c == '\\\\' || c == 0 || c == 26 /* ^Z */ ||
						c == '\\'' || c == '\\\"' || c == '\\n' || c == '\\r' ? CTRUE : CFALSE)", boolean)					
					(externC("{*travel++ = '\\\\';
						switch(c) {
							case 0: *travel++ = '0'; break;
							case '\\r': *travel++ = 'r'; break;
							case '\\n': *travel++ = 'n'; break;
							case 26: *travel++ = 'Z'; break;
							default: *travel++ = c; }
							}"), none)
				else externC("*travel++ = c")),
		let n := externC("(travel - buf)", integer)
		in (if (n > 0)
				write_port@blob(self, externC("buf", char*), n),
			n))
	else write_port@blob(self, in_buf, len))]


[dbPort!(self:MySqlDatabase) : mysql_blob ->
	let buf := externC("((char*)malloc(512))", char*)
	in (if externC("(buf == NULL ? CTRUE : CFALSE)", boolean)
			error("failed to allocate external memory"),
		mysql_blob(db = self,
				Core/data = buf,
				Core/alloc_length = 512))]

[dbFetch(self:MySqlDatabase, Q:Query) : boolean ->
	let p := Q.dbPort as mysql_blob,
		row? := (externC("p->mRow = mysql_fetch_row(p->mRes)"),
					externC("(p->mRow ? CTRUE : CFALSE)", boolean))
	in (if (row? & Q.colCount > 0)
		(externC("
			{int ifield = 0;
			unsigned long *lens = mysql_fetch_lengths(p->mRes);
			MYSQL_FIELD *fields = mysql_fetch_fields(p->mRes);
			for(;ifield < Q->colCount;ifield++) {
				if(p->mRow[ifield]) {
					if(fields[ifield].type == FIELD_TYPE_BLOB) { // for blob return a buffer port
						blob* b = blob_I_void1();
						Q->rs->addFast(GC_OID(_oid_(b)));
						b->puts(p->mRow[ifield], lens[ifield]);
					} else Q->rs->addFast(_string_(copy_string(p->mRow[ifield])));
				} else Q->rs->addFast(CNULL);
			}}")), row?)]

[dbExecute(self:MySqlDatabase, Q:Query) : void ->
	let p := Q.dbPort as mysql_blob
	in (if externC("(mysql_real_query(self->mySqlHandle, p->data, p->write_index) ? CTRUE : CFALSE)", boolean)
			mysql_error!(self),
		externC("p->mRes = mysql_store_result(self->mySqlHandle)"),
		if externC("(p->mRes ? CTRUE : CFALSE)", boolean)
			(Q.rowCount := -1,
			Q.colCount := externC("mysql_num_fields(p->mRes)", integer),
			for col in (0 .. Q.colCount - 1)
				addField(Q, copy(externC("mysql_fetch_field_direct(p->mRes, col)->name", string)), col + 1))
		else
			(// nothing to fetch
			Q.colCount := -1,
			if externC("(mysql_errno(self->mySqlHandle) ? CTRUE : CFALSE)", boolean)
				mysql_error!(self),
			Q.rowCount := externC("mysql_affected_rows(self->mySqlHandle)", integer)))]



[dbFree(self:MySqlDatabase, Q:Query) : void -> fclose(Q.dbPort)]

[dbOpenCursor(self:MySqlDatabase, Q:Query) : void -> none]
[dbCloseCursor(self:MySqlDatabase, Q:Query) : void ->
	let p := Q.dbPort as mysql_blob
	in (set_length(p, 0),
		externC("if(p->mRes) mysql_free_result(p->mRes)"))]


[dbDisconnect(self:MySqlDatabase) : void ->
	externC("if(self->mySqlHandle) mysql_close(self->mySqlHandle)")]


[dbConnect(self:MySqlDatabase, dbName:string, address:string, user:string, password:string) : MySqlDatabase ->
	externC("
	self->mySqlHandle = mysql_init(self->mySqlHandle)"),
	if externC("(self->mySqlHandle == NULL ? CTRUE : CFALSE)", boolean) 
		dbError!(self, "Not enought memory to allocate a mySQL handle"),
	appendDriverInfo(self, dbName),
	appendDriverInfo(self, " - Native - MySQL"),
	externC("uint timeout = 5;
		mysql_options(self->mySqlHandle, MYSQL_OPT_CONNECT_TIMEOUT, (char*)&timeout)"),
	if externC("(!mysql_real_connect(self->mySqlHandle, address, user, password, dbName, 0, NULL, 0) ? CTRUE : CFALSE)", boolean)
		mysql_error!(self),
	externC("mysql_set_character_set(self->mySqlHandle, self->mySqlCharset);"),
	
	self.mySqlDbName := dbName,
	self.mySqlAddress := address,
	self.mySqlUser := user,
	self.mySqlPassword := password,
	self]

[dbTables(self:MySqlDatabase, lc:list[string]) : list[string] ->
	externC("MYSQL_FIELD* fd;
		MYSQL_ROW row;
		MYSQL_RES* res = mysql_list_tables(self->mySqlHandle, \"%\" )"),
    if externC("(res == NULL ? CTRUE : CFALSE)", boolean)
    	mysql_error!(self),
    externC("
			while(row = mysql_fetch_row(res)) 
			{
				if(row[0]!=NULL && strlen(row[0]))
					add_list(lc, _string_(copy_string(row[0]))); 
			}
		mysql_free_result(res)"), lc]

[private/ensure_string(self:string) : string -> self]
[private/ensure_string(self:blob) : string -> string!(self)]


[dbColumns(self:MySqlDatabase, t_:string, lc:list[Column]) : list[Column]
 -> if (execute(self, "show columns from " /+ t_) != -1)
 		dbError!(self, "Unable to retreview " /+ t_ /+ "'s columns"),
 	while fetch(self)
 		let c := Column(tableName = t_,
 						name = ensure_string(field(self,"Field")),
 						nullable? = (field(self,"Null") = "YES"), 
 						sqlTypeName = ensure_string(field(self, "Type")),
 						primary? = (field(self,"Key") = "PRI")),
 			ctn := lower(c.sqlTypeName)
 		in (if (find(ctn,"varchar") > 0)
 				c.sqlDataType := SQL_VARCHAR
 			else if (find(ctn,"int") > 0)
 				c.sqlDataType := SQL_INTEGER
 			else if (find(ctn,"char") > 0)
 				c.sqlDataType := SQL_CHAR
 			else case ctn
 				({"longblob","blob"} c.sqlDataType := SQL_BLOB,
 				{"datetime"} c.sqlDataType := SQL_TIMESTAMP,
 				{"time"} c.sqlDataType := SQL_TIME,
 				{"float","double"} c.sqlDataType := SQL_DOUBLE,
 				{"date"} c.sqlDataType := SQL_DATE),
 			lc :add c),
 	lc]

[close(self:MySqlDatabase) : MySqlDatabase ->
	self.driverType := MYSQL,
	self]

// @doc Connecting a mySQL database
// Db/mySql!(dbName, address, user, password) return a new Database instance
// connected to a remote mySQL database.
[Db/mySql!(dbName:string, address:string, user:string, password:string) : Database ->
	initFirstQuery(dbConnect(MySqlDatabase(driverType = MYSQL,
											mySqlDbName = dbName,
											mySqlAddress = address,
											mySqlUser = user,
											mySqlPassword = password), dbName, address, user, password))]

[Db/connect!(driver:{"Mysql"},host:string,dbname:string,login:string,pass:string) : Database
-> mySql!(dbname,host,login,pass)]

// @doc Connecting a mySQL database
// equivalent to mySql!(dbName,"","","").
// equivalent to mySql!(dbName,"","","").
[mySql!(dbName:string) : Database ->
let x := explode(dbName,":")
in (if (length(x) = 1) mySql!(dbName,"")
	else if (length(x) = 4) mySql!(x[4],x[3],x[1],x[2])
	else error("bad connection string ~S",dbName))]

// @doc Connecting a mySQL database
// equivalent to mySql!(dbName,address,"","").
[mySql!(dbName:string, address:string) : Database -> mySql!(dbName,address,"","")]
// @doc Connecting a mySQL database
// equivalent to mySql!(dbName,address,user,"").
[mySql!(dbName:string, address:string, user:string) : Database -> mySql!(dbName,address,user,"")]

[dbDuplicate(self:MySqlDatabase) : Database ->
	mySql!(self.mySqlDbName, self.mySqlAddress, self.mySqlUser, self.mySqlPassword)]


// [real_escape(db:MySqlDatabase, s:string) : string -> function!(mySqlRealEscape, NEW_ALLOC)]

[dbBeginEscape(self:MySqlDatabase, Q:Query) : void -> (Q.dbPort as mysql_blob).escape? := true]
[dbEndEscape(self:MySqlDatabase, Q:Query) : void -> (Q.dbPort as mysql_blob).escape? := false]

[dbBeginTransaction(self:MySqlDatabase) : void ->
	//[0] begin transaction on ~S // self,
	execute(self, "SET AUTOCOMMIT=0"),
	execute(self, "START TRANSACTION")]

[dbCommitTransaction(self:MySqlDatabase) : void ->
	//[0] commit transaction on ~S // self,
	execute(self, "COMMIT"),
	execute(self, "SET AUTOCOMMIT=1")]

[dbRollbackTransaction(self:MySqlDatabase) : void ->
	//[0] warning ! roolback transaction on ~S // self,
	execute(self, "ROLLBACK"),
	execute(self, "SET AUTOCOMMIT=1")]


get_character_set_name(self:MySqlDatabase) : string ->
	copy(externC("((char*)mysql_character_set_name(self->mySqlHandle))",string))

set_character_set_name(self:MySqlDatabase, cs:string) : void ->
	(if (externC("mysql_options(self->mySqlHandle, MYSQL_SET_CHARSET_NAME, cs)", integer) != 0)
		error("set_character_set_name(~S, ~S) failed", self, cs))

[Db/getDbName(self:MySqlDatabase) : string -> self.mySqlDbName]
[Db/getDbFileExt(self:MySqlDatabase) : string -> ".mysql"]


[Db/createDatabase(king:{"Mysql"},host:string,dbname:string,adminlogin:string,adminpwd:string,encoding:string,dbowner:string)
-> Mysql/dbCreateDatabase(host,dbname,adminlogin,adminpwd,encoding)]

[dbCreateDatabase(host:string,dbname:string,adminlogin:string,adminpwd:string) : boolean
-> Mysql/dbCreateDatabase(host,dbname,adminlogin,adminpwd,"")]

//<xp> création de base de données	
[dbCreateDatabase(host:string,dbname:string,adminlogin:string,adminpwd:string,encoding:string) : boolean
->	try (let db := mySql!("mysql",host,adminlogin,adminpwd)
		in (printInQuery(db),
			if (encoding != "") printf("CREATE DATABASE ~A CHARACTER SET ~A;",dbname,encoding)
			else printf("CREATE DATABASE ~A;",dbname),
			endOfQuery(db),
			disconnect(db),
			true)) catch any false]
			

//<xp> création de base de données	
[dbCreateDatabase(host:string,dbname:string) : boolean
-> dbCreateDatabase(host,dbname,"root","")]


[Db/dump_file_header(db:Database,driver:{MySqlDatabase},p:port) : void 
-> 	printf(p,"-- Mysql dump\n"),
	printf(p,"BEGIN TRANSACTION;\n"),
	printf(p,"SET FOREIGN_KEY_CHECKS=0;\n")]

[Db/dump_file_footer(db:Database,driver:class,p:port) : void
->	printf(p,"COMMIT TRANSACTION;\n")]

[Db/dbIndexExists?(db:MySqlDatabase,_t:string,_col:string) : boolean
->	printInQuery(db),
	printf("SHOW INDEX FROM ~A",_t),
	endOfQuery(db),
	let res := false 
	in (while Db/fetch(db) (if (Db/field(db,"column_name") = _col | Db/field(db,"Key_name") = _col) res := true),
		res)]
		
[Db/dbTableInfo(db:MySqlDatabase,_t:string,_col:string) : string
->	printInQuery(db),
	printf("SHOW TABLE STATUS LIKIE '~A'",_t),
	endOfQuery(db),
	if Db/fetch(db) Db/field(db,_col)
	else ""]
