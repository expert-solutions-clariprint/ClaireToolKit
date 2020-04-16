//*********************************************************************
//* Db                                                Sylvain Benilan *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*********************************************************************

[private/printColumns(cs:list[Column], driver:class) : void
 -> let first? := true,
 		trgt := new(driver)
 	in (for c in cs
 			(if first? first? := false else princ(",\n\t"),
 			printf("~A ~A~I~I", c.name, sqlType(c, trgt.driverType), 
 					(if not(c.nullable?) princ(" NOT NULL")),
 				none)))] ;	(if c.primary? printf(" CONSTRAINT prim_~A_~A PRIMARY KEY", c.tableName, c.name)))))]

[private/printFields(cs:list[Column]) : void
 -> let first? := true
 	in (for c in cs
 			(if first? first? := false else princ(", "),
 			princ(c.name)))]
/*
[private/printValues(self:Database,cs:list[Column]) : void
 -> let first? := true
 	in (for c in cs
 			(if first? first? := false else princ(", "),
 			when x := field(self, c.name)
 			in (if quote?(c) printf("'~A'", replace(x,"'","\'"))
 				else printf("~A", x))
	 		else princ("NULL")))]*/

[printEscaped(trgt:Database, xx:any) : void ->
	let p := printInQuery(trgt)
	in (trgt.currentQuery.pending? := false,
		trgt.currentQuery.cursorOpened? := false,
		trgt.currentQuery.executed? := true,
		trgt.currentQuery.prepared? := false,
		dbBeginEscape(trgt, trgt.currentQuery),
		case xx
			(port
				freadwrite(xx,cout()),
			any princ(xx)),
		dbEndEscape(trgt, trgt.currentQuery),
		use_as_output(p),
		dbPrintQuery(trgt.currentQuery.dbPort),
		//princ(getSql(trgt.currentQuery)),
		popQuery(trgt),
		use_as_output(p))]

[private/printValues(self:Database,driver:class, cs:list[Column]) : void
 -> let first? := true,
 		trgt := initFirstQuery(new(driver))
 	in (for c in cs
 			(if first? first? := false else princ(", "),
 			when xx := field(self, c.name)
 			in (if quote?(c)
		 			(if (trgt.driverType = MYSQL)
						printf("'~I'", printEscaped(trgt, xx))
					else let rep1 := SQL_TYPES[SQL_QUOTEREPLACEMENT, trgt.driverType] as string,
							rep2 := SQL_TYPES[SQL_ANTISLASHREPLACEMENT, trgt.driverType] as string,
							xxx := xx as string
						in (princ("'"),
							externC("char *tmp = xxx; while(*xxx) {"),	
							externC("if(*xxx == '\\'') {princ_string(rep1)"),
							externC("} else if(*xxx == '\\\\') {princ_string(rep2)"),
							externC("} else ClEnv->cout->put(*xxx)"),
							externC("xxx++; }"),
							princ("'")))
				else if (c.sqlDataType % SQL_DATE_TYPE)
					let d := make_date(xx)
					in (princ(strftime(SQL_TYPES[c.sqlDataType + 1, trgt.driverType], d)))
				else if (xx % port) // blob
					(if (trgt.driverType = MYSQL | trgt.driverType = PGSQL)
						printf("'~I'", printEscaped(trgt, xx))
					else princ("?"))
				else printf("~A", xx))
	 		else princ("NULL")),
	 	while trgt.queries
	 		free(last(trgt.queries)))]

 [private/printValues(self:Database, trgt:Database, cs:list[Column]) : void
 -> let first? := true
 	in (for c in cs
 			(if first? first? := false else princ(", "),
 			when xx := field(self, c.name)
 			in (//[2] field(~S,~S) -> ~S // self, c.name, xx,
 				if quote?(c)
		 			(if (trgt.driverType = MYSQL)
						printf("'~I'",
							(dbBeginEscape(trgt, trgt.currentQuery),
							princ(xx),
							dbEndEscape(trgt, trgt.currentQuery)))
					else let rep1 := SQL_TYPES[SQL_QUOTEREPLACEMENT, trgt.driverType] as string,
							rep2 := SQL_TYPES[SQL_ANTISLASHREPLACEMENT, trgt.driverType] as string,
							xxx := xx as string
						in (princ("'"),
							externC("char *tmp = xxx; while(*xxx) {"),	
							externC("if(*xxx == '\\'') {princ_string(rep1)"),
							externC("} else if(*xxx == '\\\\') {princ_string(rep2)"),
							externC("} else ClEnv->cout->put(*xxx)"),
							externC("xxx++; }"),
							princ("'")))
				else if (c.sqlDataType % SQL_DATE_TYPE)
					let d := make_date(xx)
					in princ(strftime(SQL_TYPES[c.sqlDataType + 1, trgt.driverType], d))
				else if (xx % port) // blob
					(if (trgt.driverType = MYSQL | trgt.driverType = PGSQL)
						printf("'~I'",
								(dbBeginEscape(trgt, trgt.currentQuery),
								while not(eof?(xx))
									fwrite(fread(xx,1024), cout()),
								dbEndEscape(trgt, trgt.currentQuery)))
					else princ("?"))
				else printf("~A", xx))
	 		else princ("NULL")))]


// @chapter 5
// dump a table into a file
// the driver should be something like ACCESS - MYSQL - ODBC - ORACLE
[dump(self:Database, t_:string, fname:string, driver:class, createTable?:boolean, dropTable?:boolean, deleteAll?:boolean) : void
 -> let f := fopen(fname, "a"),
 		i:integer := 0
	in (use_as_output(f),
		let cs := columns(self, t_)
		in	(if dropTable? printf("DROP TABLE ~A;\n\n", t_),
			if deleteAll? printf("DELETE FROM ~A;\n\n", t_),
			if createTable? printf("CREATE TABLE ~A \n\t(~I);\n\n\n", t_, printColumns(cs, driver)),					
			execute(self, "select * from " /+ t_),
			while fetch(self)
				(i :+ 1,
				printf("INSERT INTO ~A (~I) \n\tVALUES (~I);\n", t_, printFields(cs), printValues(self, driver, cs))),
			princ("\n")), 
			//[0] table ~A dumped (~S rows) // t_, i,
			fclose(f))]
		
// @chapter 5
// dump a database into a file
// the driver should be something like ACCESS - MYSQL - ODBC - ORACLE
// the driver should be something like ACCESS - MYSQL - ODBC - ORACLE
/*[dump(self:Database, fname:string, driver:integer, createTable?:boolean, dropTable?:boolean, deleteAll?:boolean) : void
 -> try (let f := fopen(fname, "w") in fclose(f))
 	catch any error("the file ~A cannot be erased", fname),
 	for t_ in tables(self)
 		dump(self, t_, fname, driver, createTable?, dropTable?, deleteAll?)]

[dumpTable(self:Database, t_:string, driver:integer, createTable?:boolean, dropTable?:boolean, deleteAll?:boolean) : void => 
	dump(self, t_, t_ /+ ".sql", driver, createTable?, dropTable?, deleteAll?)]*/

[dump(self:Database, fname:string, driver:class, createTable?:boolean, dropTable?:boolean, deleteAll?:boolean,file_write_mode:{"w","a"}) : void
 -> try (let f := fopen(fname, file_write_mode) in (
// 			fwrite("SET CONSTRAINTS ALL DEFERRED;\n\n",f),
			dump_file_header(self, driver,f),
 			fclose(f)))
 	catch any error("the file ~A cannot be erased", fname),
 	for t_ in tables(self)
 		dump(self, t_, fname, driver, createTable?, dropTable?, deleteAll?),
	try (let f := fopen(fname, "a") in (dump_file_footer(self, driver,f),fclose(f)))
	catch any error("the file ~A cannot be erased", fname)]

[dump(self:Database, fname:string, driver:class, createTable?:boolean, dropTable?:boolean, deleteAll?:boolean) : void
-> dump(self,fname,driver,createTable?,dropTable?,deleteAll?,"w")]

[dumpTable(self:Database, t_:string, driver:class, createTable?:boolean, dropTable?:boolean, deleteAll?:boolean) : void => 
	dump(self, t_, t_ /+ ".sql", driver, createTable?, dropTable?, deleteAll?)]


////////////////////////////////////////////////
// databse copy :


[copyTable(src:Database, trgt:Database, t_:string, createTable?:boolean) : void ->
	let cs := columns(src, t_),
 		nrows:integer := 0
	in (//[0] ==== copy table ~S ==== // src, trgt, t_,
		if createTable?
			(//[0]   -- Create table ~S:~A // trgt, t_,
			printInQuery(trgt),
			printf("CREATE TABLE ~A (~I)", t_, printColumns(cs, owner(trgt))),
			endOfQuery(trgt)),
		//[0]   -- Select * from ~S:~A // src, t_,
		execute(src, "SELECT * FROM " /+ t_),
		//[0]   -- Copy * to ~S:~A // trgt, t_,
		while fetch(src)
			(nrows :+ 1,
			printInQuery(trgt),
			printf("INSERT INTO ~A (~I) \n\tVALUES (~I)", t_, printFields(cs), printValues(src,trgt,cs)),
			endOfQuery(trgt)),
		//[0]   => ~S row(s) copied in ~S:~A\n // nrows, trgt, t_
		)]
		


[copyDb(src:Database, trgt:Database, createTable?:boolean) : void ->
	for t_ in tables(src) copyTable(src, trgt, t_, createTable?)]
		

[dump_file_header(self:Database, driver:class,p:port) : void -> none]
(abstract(dump_file_header))

[dump_file_footer(self:Database, driver:class,p:port) : void -> none]
(abstract(dump_file_footer))




// SELECT tablename, relname FROM pg_tables, pg_class where pg_class.relkind = 'S' AND position(pg_tables.tablename in pg_class.relname) = 1  ;

