
//
//	printing slot value in an SQL query
//

dbPrint :: property()
(abstract(dbPrint))



// for an object get its id
[dbPrint(db:Database, self:object) : void => 
	if (self % class) dbPrint(db, dbName(self))
	else when id := getDbId(self)
		in printf("~S", id) 
		else princ("NULL")]

// for string we use quote strings
[dbPrint(db:Database, self:subtype[class]) : void => printf("'~S'", self)]

[dbPrintBag(db:Database, self:bag,sep:char) : void ->
	print_in_string(),
	let f := true
	in (for i  in self (
			if f f := false else princ(sep),
			princ(i)),
		dbPrint(db,end_of_string()))]


[dbPrint(db:Database, self:list[string]) : void => dbPrintBag(db, self,STRING_BAG_SEP)]

[dbPrint(db:Database, self:set[string]) : void => dbPrintBag(db, self,STRING_BAG_SEP)]

[dbPrint(db:Database, self:set[float]) : void ->
	let f := true,
		sep := ";"
	in (princ("'"),
		for i  in self (
			if f f := false else princ(sep),
			princ(i)),
		princ("'"))]

[dbPrint(db:Database, self:list[float]) : void ->
	let f := true,
		sep := ";"
	in (princ("'"),
		for i  in self (
			if f f := false else princ(sep),
			princ(i)),
		princ("'"))]

[dbPrint(db:Database, self:list[integer]) : void ->
	let f := true,
		sep := ";"
	in (princ("'"),
		for i  in self (
			if f f := false else princ(sep),
			princ(i)),
		princ("'"))]

[dbPrint(db:Database, self:set[integer]) : void ->
	let f := true,
		sep := ";"
	in (princ("'"),
		for i  in self (
			if f f := false else princ(sep),
			princ(i)),
		princ("'"))]

// for string we use quote strings
[dbPrint(db:Database, self:string) : void -> 	
	if (db.driverType = MYSQL)
		printf("'~I'",
			(dbBeginEscape(db, db.currentQuery),
			princ(self),
			dbEndEscape(db, db.currentQuery)))
	else let rep1 := Db/SQL_TYPES[Db/SQL_QUOTEREPLACEMENT, db.driverType],
			rep2 := Db/SQL_TYPES[Db/SQL_ANTISLASHREPLACEMENT, db.driverType]
		in (princ("'"),
			externC("char *tmp = self; while(*self) {"),	
			externC("if(*self == '\\'') {princ_string(string_v(rep1))"),
			externC("} else if(*self == '\\\\') {princ_string(string_v(rep2))"),
			externC("} else ClEnv->cout->put(*self)"),
			externC("self++; }"),
			princ("'"))]

	
// for string we use quote strings
[dbPrint(db:Database, self:integer) : void => printf("~S", self)]

// for string we use quote strings
[dbPrint(db:Database, self:float) : void -> 
	if (self != self)
		(//[-100] WARNING find a NaN in dbPrint@float !,
		princ("NULL"))
	else printf("~S", self)]

// for string we use quote strings
[dbPrint(db:Database, self:boolean) : void => printf("~A", (if self "1" else "0"))]

// for string we use quote strings
//xp rm [dbPrint(self:TimeStamp) : void => printf("'~A'", date(self, "%Y-%m-%d %H:%M:%S"))]

// a redefinable date print 
[dbPrintDate(db:Database,p:dbProperty,self:float) : void
->	if (p.dbSqlType = SQL_DATE)
		princ(strftime(SQL_TYPES[p.dbSqlType + 1, db.driverType], self as float))
	else let old := tzset("UTC")
		in (princ(strftime(SQL_TYPES[p.dbSqlType + 1, db.driverType], self as float)),
			tzset(old))]
(abstract(dbPrintDate))

// The API to use, take care of the password? status of dbProperty
// then call the simple dbPrint
[dbPrintValue(db:Database, self:any, p:dbProperty) : void ->
	if unknown?(self) princ("NULL")
	else if p.password? printf("~A(~I)",SQL_TYPES[SQL_PASSWORD, db.driverType], dbPrint(db, self))
	else if (known?(dbSqlType, p) & p.dbSqlType % SQL_DATE_TYPE)
		dbPrintDate(db,p,self)
//		princ(strftime(SQL_TYPES[p.dbSqlType + 1, db.driverType], self as float)) //bbn +1 to have the formating string
	else dbPrint(db, self)]

[dbPrint(db:Database, self:any, p:dbProperty) : void =>
	dbPrintValue(db, get(p, self), p)]



[dbPrint(db:Database, self:dbProperty, obj:object, p:port) : void ->
	if (range(@(self, owner(obj))) =type? list[string])
		print_string_list(get(self, obj), p)
	else if (self.dbSqlBlobFile?) (if known?(self,obj) fwrite("F",p))
	else if known?(get_value("Zlib"))
	 	(fwrite("Z",p),
	 	let z := close_target!(buffer!(apply(get_value(get_value("Zlib"),"gziper!"), list(p)), 512))
	 	in (Xmlo/xml!(get(self, obj), z),
	 		fclose(z)))
	 else Xmlo/xml!(get(self, obj), p)]

[filePath(db:Database, self:dbProperty, obj:object) : string
-> let 	dbfolder := getenv("DBO_FILE_STORE") / Db/getDbName(db),
		tableFolder := dbfolder / Dbo/dbName(isa(obj)),
		propFolder := tableFolder / Dbo/dbName(self),
		objId := getDbId(obj),
		subfold := propFolder / string!(objId >> 10),
		filename := subfold / string!(objId) /+ ".gz"
	in (if not(isdir?(dbfolder)) mkdir(dbfolder)
		else //[1] dbfolder ~S ok // dbfolder,
		if not(isdir?(tableFolder)) mkdir(tableFolder)
		else //[1] tableFolder ~S ok // tableFolder,
		if not(isdir?(propFolder)) mkdir(propFolder)
		else //[1] propFolder ~S ok // propFolder,
		if not(isdir?(subfold)) mkdir(subfold)
		else //[1] subfold ~S ok // subfold,
		filename)]


[dbPrintInFile(db:Database, self:dbProperty, obj:object) : void ->
	if isenv?("DBO_FILE_STORE")
		(let filename := filePath(db,self,obj)
		in (when v := get(self, obj)
			in (let fout := fopen(filename,"w"),
					z := close_target!(buffer!(close_target!(Zlib/gziper!(close_target!(fout))), 512))
				in (islocked?(fout),
					Xmlo/xml!(get(self, obj), z),
					fclose(z),
					none))
			else (if isfile?(filename) unlink(filename))))
	else error("DBO_FILE_STORE is not set")]
	
//
//	printing SQL lists of dbProperties
//  	how to simply construct complex but readable SQL query
//

//bbn check whether the property has type BLOB
[isBlob?(self:dbProperty) : boolean => known?(dbSqlType,self) & self.dbSqlType = Db/SQL_BLOB]


// prints "prop1, ... propN"
[printList(lp:list[dbProperty]) : void ->
	let first? := true
	in (for p in lp
			(if first? first? := false else princ(", "), 
			princ(dbName(p))))]

// prints "prop1, ... propN"
[printList(lp:list[string]) : void ->
	let first? := true
	in (for p in lp
			(if first? first? := false else princ(", "), 
			princ(p)))]


// prints "value1, ... valueN"
[printValues(db:Database, self:object, lp:list[dbProperty]) : void ->
	let first? := true
	in (for p in lp
			(if first? first? := false else princ(", "),
			if isBlob?(p)
				(if known?(p, self)
					(if (db.driverType = MYSQL | db.driverType = PGSQL)
						printf("'~I'",
								(dbBeginEscape(db, db.currentQuery),
								dbPrint(db, p, self, db.currentQuery.dbPort),
								dbEndEscape(db, db.currentQuery)))
					else princ("?"))
				else princ("NULL"))
			else dbPrint(db, self, p)))]

// prints "prop1 = value1, ... propN = valueN"
[printAffects(db:Database, self:object, lp:list[dbProperty]) : void ->
	let first? := true
	in (for p in lp
			(if first? first? := false else princ(", "), 
			printf("~A = ~I", dbName(p), 
					(if isBlob?(p)
						(if known?(p, self)
							(if (db.driverType = MYSQL | db.driverType = PGSQL)
								printf("'~I'",
									(dbBeginEscape(db, db.currentQuery),
									dbPrint(db, p, self, db.currentQuery.dbPort),
									dbEndEscape(db, db.currentQuery)))
							else princ("?"))
						else princ("NULL"))
					else 
						dbPrint(db, self, p)))))]

[printAffects(db:Database, lp:list[tuple(dbProperty,any)]) : void ->
	let first? := true
	in (for p in lp
			(if first? first? := false else princ(", "), 
			printf("~A = ~I", dbName(p[1]),
						(if isBlob?(p[1])
							(if known?(p[2])
								(if (db.driverType = MYSQL | db.driverType = PGSQL)
									printf("'~I'",
										(dbBeginEscape(db, db.currentQuery),
										dbPrint(db, p[1], p[2], db.currentQuery.dbPort),
										//dbPrintValue(db, p[2], p[1]),
										dbEndEscape(db, db.currentQuery)))
								else princ("?"))
							else princ("NULL"))
						else if unknown?(p[2]) princ("NULL")
						else dbPrintValue(db, p[2], p[1])))))]

[printWhereAnd(db:Database, lp:list[tuple(dbProperty,any)]) : void ->
	let first? := true
	in (if lp printf(" WHERE"),
		for p in lp
			(if first? first? := false else princ(" AND"),								
			if isBlob?(p[1])
					(if known?(p[2])
						(if (db.driverType = MYSQL | db.driverType = PGSQL)
							printf("'~I'",
								(dbBeginEscape(db, db.currentQuery),
								dbPrint(db, p[1], p[2], db.currentQuery.dbPort),
								dbEndEscape(db, db.currentQuery)))
						else princ("?"))
					else princ("NULL"))
			else if (p[2] % tuple)
				printf(" ~A ~A ~I", dbName(p[1]), p[2][1], dbPrintValue(db, p[2][2], p[1]))
			
			else if (p[2] % bag & length(p[2]) > 0) 
				printf(" ~A IN (~I)", dbName(p[1]), 
							(let f? := true
							in (for x in p[2] 
									(if f? f? := false else princ(", "),
									dbPrintValue(db, x, p[1])))))
			
			else if (p[2] % bag) princ(" 0 = 1 ")
			
			else if (p[2] = unknown) //  & db.driverType = Db/ACCESS) 
				printf(" ~A IS NULL", dbName(p[1]))
			
			else printf(" ~A = ~I", dbName(p[1]), dbPrintValue(db, p[2], p[1]))))]

//
//	printing SQL lists of dbProperties definition (creating table)
//  	how to simple construct complex but readable SQL query
//

[printType(db:Database, self:{string}) : void -> princ(Db/sqlType(Db/SQL_VARCHAR, db.driverType, 200, 0))]
[printType(db:Database, self:{integer}) : void -> princ("INTEGER")]
//xp rm [printType(self:{TimeStamp}) : void -> princ(Db/sqlType(Db/SQL_TIMESTAMP, db.driverType, 200, 0))]
[printType(db:Database, self:{boolean}) : void -> princ("INTEGER")]
[printType(db:Database, self:{float}) : void -> princ(Db/sqlType(Db/SQL_DOUBLE, db.driverType, 30, 0))]
[printType(db:Database, self:subtype[object]) : void -> princ("INTEGER")]
[printType(db:Database, self:subtype[class]) : void -> princ(Db/sqlType(Db/SQL_VARCHAR, db.driverType, 200, 0))]
[printType(db:Database, self:subtype[Union]) : void -> princ("INTEGER")]
[printType(db:Database, self:subtype[list[integer U float U char U string U boolean]]) : void -> princ(Db/sqlType(Db/SQL_BLOB, db.driverType, 200, 0))]
[printType(db:Database, self:subtype[set[integer U float U char U string U boolean]]) : void -> princ(Db/sqlType(Db/SQL_BLOB, db.driverType, 200, 0))]

[private/printFieldDefinitions(db:Database, self:class, lp:list[dbProperty]) : void ->
	let first? := true
	in (for p in lp
			(if first? first? := false else princ(",\n"),
			printf("\t~A ~I~I", dbName(p), 
				(if not(p.id? | p.autoIncrement?)
					(if known?(dbSqlType, p)
						princ(Db/sqlType(p.dbSqlType, db.driverType, p.dbSqlPrecision,p.dbSqlDigit))
					else printType(db, range(@(p, self))))),
				(if (unknown?(generatorId, p) & (p.id? | p.autoIncrement?)) 
					printf(" ~A NOT NULL", Db/SQL_TYPES[Db/SQL_AUTOINCREMENT, db.driverType])
				else if not(p.null?) princ(" NOT NULL")))))]

