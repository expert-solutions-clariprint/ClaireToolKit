//*********************************************************************
//* Postgresql                                        Sylvain Benilan *
//* Copyright (C) 2005 xl. All Rights Reserved                        *
//*********************************************************************

// @presentation
// The Postgresql module is a driver module for the Db interface. It relies the
// popular PostgreSQL library.
// @presentation

// @cat Connecting a PostgreSQL database
// The Postgresql module is a driver module for the Db interface. It relies the
// popular libpq library and provide a database connector for PostgreSQL.
// @cat


PGconn* <: import()
PGresult* <: import()

(c_interface(PGconn*,"PGconn*"))
(c_interface(PGresult*,"PGresult*"))


PgDatabase <: Database(pgHandle:PGconn*,
						pgDbName:string = "",
						pgAddress:string = "",
						pgUser:string = "",
						pgPassword:string = "")


pg_blob <: blob(
			db:PgDatabase,
			mRes:PGresult*,
			mRow:integer,
			escape?:boolean = false)

[write_port(self:pg_blob, in_buf:char*, len:integer) : integer ->
	(if self.escape?
		(externC("char buf[256];
				char* travel = buf;"),
		for i in (0 .. len - 1)
			let n := externC("(travel - buf)", integer)
			in (externC("char c = in_buf[i]"),
				if externC("(n >= 250 ? CTRUE : CFALSE)", boolean)
					(write_port@blob(self, externC("buf", char*), n),
					externC("travel = buf")),
				if externC("(c == '\\\\' || c == 0 || c == '\\'' ? CTRUE : CFALSE)", boolean)					
					(externC("{*travel++ = '\\\\';
							*travel++ = '\\\\';
							switch(c) {
								case 0: *travel++ = '0'; *travel++ = '0'; *travel++ = '0'; break;
								case 39: *travel++ = '0'; *travel++ = '4'; *travel++ = '7'; break;
								case 92: *travel++ = '1'; *travel++ = '3'; *travel++ = '4'; break;
							}}"), none)
				else externC("*travel++ = c")),
		let n := externC("(travel - buf)", integer)
		in (if (n > 0)
				write_port@blob(self, externC("buf", char*), n),
			n))
	else write_port@blob(self, in_buf, len))]

[dbPort!(self:PgDatabase) : pg_blob ->
	let buf := externC("((char*)malloc(512))", char*)
	in (if externC("(buf == NULL ? CTRUE : CFALSE)", boolean)
			error("failed to allocate external memory"),
		pg_blob(db = self,
				Core/data = buf,
				Core/alloc_length = 512))]

[dbPrintQuery(self:pg_blob) : void ->
	let l := length(self)
	in freadwrite(self, cout(), l - 1), //<sb> minus the null
	set_index(self, 0)]

[dbFetch(self:PgDatabase, Q:Query) : boolean ->
	let p := Q.dbPort as pg_blob
	in (if (p.mRow + 1 >= externC("PQntuples(p->mRes)", integer)) false
		else (p.mRow :+ 1,
			for ifield in (0 .. Q.colCount - 1)
				(if externC("(PQgetisnull(p->mRes, p->mRow, ifield) ? CTRUE : CFALSE)", boolean)
					Q.rs add unknown
				else
					(externC("char *val = PQgetvalue(p->mRes, p->mRow, ifield);
								int len = PQgetlength(p->mRes, p->mRow, ifield)"),
					if externC("(PQftype(p->mRes, ifield) == 17 ? CTRUE : CFALSE)", boolean)
						 let b := blob!()
						 in (if externC("(PQfformat(p->mRes, ifield) == 0 ? CTRUE : CFALSE)", boolean)
						 		externC("PQunescapeBytea_mem(b, (unsigned char*)val, len)")
						 	else write_port(b, externC("val", char*), externC("len", integer)),
						 	Q.rs add b)
					else Q.rs add copy(externC("val", string), externC("len", integer)))),
			true))]

[dbExecute(self:PgDatabase, Q:Query) : void ->
	let p := Q.dbPort as pg_blob
	in (putc('\0', p),
		p.mRes := externC("PQexec(self->pgHandle, p->data)", PGresult*),
		if externC("(PQresultStatus(p->mRes) == PGRES_TUPLES_OK ? CTRUE : CFALSE)", boolean)
			(//<sb> something to fetch
			Q.rowCount := -1,
			Q.colCount := externC("PQnfields(p->mRes)", integer),
			p.mRow := -1,
			for col in (0 .. Q.colCount - 1)
				Q.cols :add
					tuple(lower(copy(externC("PQfname(p->mRes, col)", string))),
							col + 1))
		else if externC("(PQresultStatus(p->mRes) == PGRES_COMMAND_OK ? CTRUE : CFALSE)", boolean)
			(//<sb> nothing to fetch
			p.mRow := 0,
			Q.rowCount := externC("atoi(PQcmdTuples(p->mRes))", integer),
			Q.colCount := -1)
		else 
			(externC("PQclear(p->mRes)"),
			dbError!(self, copy(externC("PQerrorMessage(self->pgHandle)", string)))))]



[dbFree(self:PgDatabase, Q:Query) : void -> fclose(Q.dbPort)]

[dbOpenCursor(self:PgDatabase, Q:Query) : void -> none]
[dbCloseCursor(self:PgDatabase, Q:Query) : void ->
	let p := Q.dbPort as pg_blob
	in (set_length(p, 0),
		externC("PQclear(p->mRes)"))]

[dbDisconnect(self:PgDatabase) : void ->
	externC("if (self->pgHandle) PQfinish(self->pgHandle)")]

[Db/getDbName(self:PgDatabase) : string -> self.pgDbName]
[Db/getDbFileExt(self:PgDatabase) : string -> ".psql"]

[dbConnect(self:PgDatabase, dbName:string, address:string, user:string, password:string) : PgDatabase ->
	let conninfo := "dbname = " /+ dbName /+
					(if (length(address) > 0) " host = " /+ address else "") /+ 
					(if (length(user) > 0) " user = " /+ user else "") /+
					(if (length(password) > 0) " password = " /+ password else "") /+
					" connect_timeout = 2"
	in (self.pgHandle := externC("PQconnectdb(conninfo)", PGconn*),
		appendDriverInfo(self, dbName),
		appendDriverInfo(self, " - Native - PostgreSQL"),
		if externC("(PQstatus(self->pgHandle) != CONNECTION_OK ? CTRUE : CFALSE)", boolean)
			dbError!(self, copy(externC("PQerrorMessage(self->pgHandle)", string))),
		self)]


[dbTables(self:PgDatabase, lc:list[string]) : list[string] ->
	if (execute(self, "SELECT tablename AS relname, schemaname AS nspname, tableowner AS relowner
					FROM pg_catalog.pg_tables 
					WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
					ORDER BY schemaname, tablename") != -1)
 		dbError!(self, "Unable to retreview tables"),
 	while fetch(self)
 		lc :add field(self,"relname") as string,
 	lc]
 	
[dbColumns(self:PgDatabase, t_:string, lc:list[Column]) : list[Column]
->	if (execute(self,
"SELECT
	a.attname as attnam,
	pg_catalog.format_type(a.atttypid, a.atttypmod) as type, 
	a.atttypmod,
	a.attnotnull as annull,
	a.atthasdef,
	adef.adsrc as sqlDefaultValue,
	a.attstattarget, a.attstorage, t.typstorage,
	(
		SELECT 1 FROM pg_catalog.pg_depend pd, pg_catalog.pg_class pc
		WHERE pd.objid=pc.oid 
		AND pd.classid=pc.tableoid 
		AND pd.refclassid=pc.tableoid
		AND pd.refobjid=a.attrelid
		AND pd.refobjsubid=a.attnum
		AND pd.deptype='i'
		AND pc.relkind='S'
	) IS NOT NULL AS attisserial,
	pg_catalog.col_description(a.attrelid, a.attnum) AS comment 

FROM
	pg_catalog.pg_attribute a LEFT JOIN pg_catalog.pg_attrdef adef
	ON a.attrelid=adef.adrelid
	AND a.attnum=adef.adnum
	LEFT JOIN pg_catalog.pg_type t ON a.atttypid=t.oid
WHERE 
	a.attrelid = (SELECT oid FROM pg_catalog.pg_class WHERE relname='" /+ lower(t_) /+ "'
		AND relnamespace = (SELECT oid FROM pg_catalog.pg_namespace WHERE
		nspname = 'public'))
	AND a.attnum > 0 AND NOT a.attisdropped
ORDER BY a.attnum") != -1)
 		dbError!(self, "Unable to retreview " /+ t_ /+ "'s columns"),
 	while fetch(self)
 		let c :=  Column(tableName = t_,
 						name = field(self,"attnam"),
 						nullable? = (field(self,"annull") = "YES"), 
 						sqlTypeName = field(self,"type"),
 						primary? = false),
 			ctn := lower(c.sqlTypeName)
 		in (lc :add c,
			when dfval := field(self,"sqlDefaultValue") in ( c.sqlDefaultValue := dfval, c.sqlAutoIncrement := true),
 			if (find(ctn,"character varying") > 0)
 				c.sqlDataType := SQL_VARCHAR
 			else if (find(ctn,"timestamp") > 0)
 				c.sqlDataType := SQL_TIMESTAMP
 			else if (find(ctn,"double") > 0)
 				c.sqlDataType := SQL_DOUBLE
 			else if (find(ctn,"char") > 0)
 				c.sqlDataType := SQL_CHAR
 			else case ctn
 				({"bytea"} c.sqlDataType := SQL_BLOB,
 				{"integer"} c.sqlDataType := SQL_INTEGER,
 				{"time"} c.sqlDataType := SQL_TIME,
 				{"date"} c.sqlDataType := SQL_DATE,
 				{"serial"} c.sqlDataType := SQL_AUTOINCREMENT)), lc]

[close(self:PgDatabase) : PgDatabase ->
	self.driverType := PGSQL,
	self]

// @doc Connecting a PostgreSQL database
// Db/pg!(dbName, address, user, password) return a new Database instance
// connected to a remote PostgreSQL database.
[Db/pg!(dbName:string, address:string, user:string, password:string) : Database ->
	initFirstQuery(dbConnect(PgDatabase(driverType = PGSQL,
											pgDbName = dbName,
											pgAddress = address,
											pgUser = user,
											pgPassword = password), dbName, address, user, password))]

// @doc Connecting a PostgreSQL database
// equivalent to pg!(dbName,"","","").
[pg!(dbName:string) : Database -> pg!(dbName,"","","")]
// @doc Connecting a PostgreSQL database
// equivalent to pg!(dbName,address,"","").
[pg!(dbName:string, address:string) : Database -> pg!(dbName,address,"","")]
// @doc Connecting a PostgreSQL database
// equivalent to pg!(dbName,address,user,"").
[pg!(dbName:string, address:string, user:string) : Database -> pg!(dbName,address,user,"")]

[dbDuplicate(self:PgDatabase) : Database ->
	pg!(self.pgDbName, self.pgAddress, self.pgUser, self.pgPassword)]


[dbBeginEscape(self:PgDatabase, Q:Query) : void -> (Q.dbPort as pg_blob).escape? := true]
[dbEndEscape(self:PgDatabase, Q:Query) : void -> (Q.dbPort as pg_blob).escape? := false]

[dbBeginTransaction(self:PgDatabase) : void -> execute(self, "BEGIN;")]
[dbCommitTransaction(self:PgDatabase) : void -> execute(self, "COMMIT;")]
[dbRollbackTransaction(self:PgDatabase) : void -> execute(self, "ROLLBACK;")]


[get_character_set_name(self:PgDatabase) : integer ->
	externC("PQclientEncoding(self->pgHandle)", integer)]

set_character_set_name(self:PgDatabase, cs:string) : void ->
	(if (externC("PQsetClientEncoding(self->pgHandle, cs)", integer) != 0)
		error("set_character_set_name(~S, ~S) failed", self, cs))






private/PGSQL_CHARACTER_SET :: {
								"SQL_ASCII", //	ASCII
								"EUC_JP",	 //	Japanese EUC
								"EUC_CN",	 //	Chinese EUC
								"EUC_KR", 	//	Korean EUC
								"JOHAB",	//	Korean EUC (Hangle base)
								"EUC_TW",	//	Taiwan EUC
								"UNICODE",	//	Unicode (UTF-8)
								"MULE_INTERNAL", //	Mule internal code
								"LATIN1",	//	 8859-1/ECMA 94 (Latin alphabet no.1)
								"LATIN2",	//	ISO 8859-2/ECMA 94 (Latin alphabet no.2)
								"LATIN3",	//	ISO 8859-3/ECMA 94 (Latin alphabet no.3)
								"LATIN4",	//	ISO 8859-4/ECMA 94 (Latin alphabet no.4)
								"LATIN5",	//	ISO 8859-9/ECMA 128 (Latin alphabet no.5)
								"LATIN6",	//	ISO 8859-10/ECMA 144 (Latin alphabet no.6)
								"LATIN7",	//	ISO 8859-13 (Latin alphabet no.7)
								"LATIN8",	//	ISO 8859-14 (Latin alphabet no.8)
								"LATIN9",	//	ISO 8859-15 (Latin alphabet no.9)
								"LATIN10",	//	ISO 8859-16/ASRO SR 14111 (Latin alphabet no.10)
								"ISO_8859_5",	//	ISO 8859-5/ECMA 113 (Latin/Cyrillic)
								"ISO_8859_6",	//	ISO 8859-6/ECMA 114 (Latin/Arabic)
								"ISO_8859_7",	//	ISO 8859-7/ECMA 118 (Latin/Greek)
								"ISO_8859_8",	//	ISO 8859-8/ECMA 121 (Latin/Hebrew)
								"KOI8",		//	KOI8-R(U)
								"WIN",		//	Windows CP1251
								"ALT",		//	Windows CP866
								"WIN1256",	//	Windows CP1256 (Arabic)
								"TCVN",		//	TCVN-5712/Windows CP1258 (Vietnamese)
								"WIN874"}	//	Windows CP874 (Thai)
								

[Db/createDatabase(kind:{"postgresql"},host:string,dbname:string,adminlogin:string,adminpwd:string,encoding:string,dbowner:string)
-> Postgresql/dbCreateDatabase(host,dbname,adminlogin,adminpwd,encoding,dbowner)]
								
//<xp> création de base de données	
[dbCreateDatabase(host:string,dbname:string,adminlogin:string,adminpwd:string,encoding:PGSQL_CHARACTER_SET,dbowner:string) : boolean
->	try (let db := pg!("template1",host,adminlogin,adminpwd)
		in (printInQuery(db),
			printf("CREATE DATABASE ~A WITH ~I ENCODING = '~A';",
									dbname,
												(if (owner != "") printf("OWNER = ~A",owner)),
															encoding),
			endOfQuery(db),
			disconnect(db),
			//[2] pgsql database ~A created sucessfully, 
			true)) catch any (//[2] an error as occured during pgsql database ~S creation : ~S // dbname, exception!(),
								false)]
			
			
//<xp> création de base de données	
[dbCreateDatabase(host:string,dbname:string) : boolean
-> Postgresql/dbCreateDatabase(host,dbname,"postgres","","LATIN9","")]


//<xp>
[Db/dump_file_header(self:Database,driver:{PgDatabase},p:port) : void
->	//[0] dump_file_header(~S,~S,~S) // self,driver,p,
	printf(p,"BEGIN;\n"),
	printf(p,"SET CONSTRAINTS ALL DEFERRED;\n")]

[Db/dump_file_footer(self:Database,driver:{PgDatabase},p:port) : void
->	//[0] dump_file_footer(~S,~S,~S) // self,driver,p,
	print_update_sequences(self,driver,p),
	printf(p,"COMMIT;\n")]


[update_sequences(self:PgDatabase) : void
->	let tables := list<string>()		
	in (for t in dbTables(self,tables)
			let columns := list<Column>() in
				when c := some( cc in dbColumns(self,t,columns) | cc.sqlAutoIncrement)
				in (let seqname := explode(c.sqlDefaultValue,"'")[2]
					in (Db/printInQuery(self),
					printf("SELECT setval('~A',(select max(~A) from ~A));", seqname, c.name, t),
						Db/endOfQuery(self))))]

[print_update_sequences(self:Database,driver:class,p:port) : void -> none]

[print_update_sequences(self:Database,driver:{PgDatabase},p:port) : void
->	//[0] print_update_sequences(~S,~S,~S) // self,driver,p,
	let tables := list<string>()		
	in (for t in dbTables(self,tables)
			let columns := list<Column>() in
				when c := some( cc in dbColumns(self,t,columns) | cc.sqlAutoIncrement)
				in (let seqname := dbget_sequence_name(self,c)
					in (printf(p,"SELECT setval('~A',(select max(~A) from ~A));\n", seqname, c.name, t))))]

[dbget_sequence_name(self:PgDatabase,c:Column) : string
->	explode(c.sqlDefaultValue,"'")[2]]

[dbget_sequence_name(self:Database,c:Column) : string
->	lower(c.tableName) /+ "_" /+ lower(c.name) /+ "_seq"]


