
//
//	How to convert a string (returned in a result row) into a CLAIRE type
//		may be overwriten
//
value! :: property()
(abstract(value!))

[value!(db:Db/Database, p:dbProperty, obj:object, self:port) : any -> 
	if (range(@(p, owner(obj))) =type? list[string])
		extract_string_list(self)
	else if (p.dbSqlBlobFile? & (case self (blob (length(self) > 0 & self[1] = 'F'), any false)))
		dbReadFromFile(db,p,obj)
	else if (known?(get_value("Zlib")) & (case self (blob (length(self) > 0 & self[1] = 'Z'))))
	 	(getc(self), //<sb> rm 1st 'Z'
	 	let z := close_target!(buffer!(apply(get_value(get_value("Zlib"),"gziper!"), list(self)), 512)),
	 		x := Xmlo/unXml!(z)
	 	in (fclose(z), x))
	else Xmlo/unXml!(self)]


[value!(db:Db/Database, self:string, rg:subtype[class]) : (object U {unknown}) -> 
	//[DBTOOLS_VALUE] value!(string = ~S, rg = ~S) // self, rg,
	getObjectFromId(db, rg, integer!(self))]
	
[value!(db:Db/Database, self:string, rg:subtype[object]) : (object U {unknown}) -> 
	//[DBTOOLS_VALUE] value!(string = ~S, rg = ~S) // self, rg,
	getObjectFromId(db, rg, integer!(self))]

[value!(db:Db/Database, self:string, rg:{string}) : string -> 
	//[DBTOOLS_VALUE] value!(string = ~S, rg = ~S) // self, rg,
	self]
[value!(db:Db/Database, self:string, rg:{char}) : char -> 
	//[DBTOOLS_VALUE] value!(string = ~S, rg = ~S) // self, rg,
	self[1]]
[value!(db:Db/Database, self:string, rg:{integer}) : integer -> 
	//[DBTOOLS_VALUE] value!(string = ~S, rg = ~S) // self, rg,
	integer!(self)]
[value!(db:Db/Database, self:string, rg:{float}) : float -> 
	//[DBTOOLS_VALUE] value!(string = ~S, rg = ~S) // self, rg,
	float!(self)]
[value!(db:Db/Database, self:string, rg:{boolean}) : boolean -> 
	//[DBTOOLS_VALUE] value!(string = ~S, rg = ~S) // self, rg,
	integer!(self) = 1]

[set_value!(db:Db/Database, self:string, rg:any) : (set U {unknown}) -> 
	//[DBTOOLS_VALUE] value!(string = ~S, rg = ~S) // self, rg,
	set!(explode(self,string!(STRING_BAG_SEP)))]

[list_value!(db:Db/Database, self:string, rg:any) : (bag U {unknown}) -> 
	//[DBTOOLS_VALUE] value!(string = ~S, rg = ~S) // self, rg,
	explode(self,string!(STRING_BAG_SEP))]
	

[dbReadFromFile(db:Database, self:dbProperty, obj:object) : any ->
	let filename := filePath(db,self,obj)
	in (//[1] dbReadFromFile ~S // filename,
		if isfile?(filename)
			let fin := fopen(filename,"r"),
				z := (islocked?(fin), close_target!(buffer!(close_target!(Zlib/gziper!(close_target!(fin))),512))),
				x := Xmlo/unXml!(z)
			in (fclose(z),
				x)
		else unknown)]

[make_utc_date(self:string) : float
->	let old := tzset("UTC"),
		res := make_date(self)
	in (tzset(old), res)]

//
//	How to create a new object from a result row
//

// update a list of slot's values from a row
// if NULL -> unknown
// if dbSqlType is set in a dbProperty convertion is simple
// if not set try an auto convertion, one may override "value!"
// to implement his own convertion routine
[updateValuesFromRow(db:Db/Database, self:object, idProp:dbProperty, lp:list[dbProperty]) : void ->
	//[DBTOOLS_VALUE] updateValuesFromRow(object = ~S, lp = ~A) // self, lp,
	let selfOwner := owner(self)
	in (for prop in lp
			(when val := Db/field(db, dbName(prop))
			in (when clval := 
					(//[DBOJECTS] update property ~S with ~S // prop, val,
					if (val % port) 
						(try value!(db, prop, self, val)
						catch any (//[-100] !!! error catch in updateValuesFromRow(object = ~S, lp = ~A) : ~S // self, lp,exception!(),
										unknown))
									
					else if (known?(dbSqlType,prop) & prop.dbSqlType % SQL_DATE_TYPE)
//						(if (prop.dbSqlType = SQL_DATE) make_date(val) else make_utc_date(val))
						make_date(val)
					else if (range(@(prop, selfOwner)) <= list[string]) explode(val,string!(STRING_BAG_SEP))
					else if (range(@(prop, selfOwner)) <= set[string]) set!(explode(val,string!(STRING_BAG_SEP)))
					else if (range(@(prop, selfOwner)) <= list[integer]) list{integer!(x) | x in explode(val,";")}
					else if (range(@(prop, selfOwner)) <= set[integer]) {integer!(x) | x in explode(val,";")}
					else if (range(@(prop, selfOwner)) <= list[float]) list{float!(x) | x in explode(val,";")}
					else if (range(@(prop, selfOwner)) <= set[float]) {float!(x) | x in explode(val,";")}
					else (try value!(db, val, range(@(prop, selfOwner))) 
							catch any (//[-100] !!! error catch in updateValuesFromRow(object = ~S, lp = ~A) : ~S // self, lp,exception!(),
										unknown)
							))
				in write(prop, self, clval) 
				else erase(prop, self))
			else erase(prop, self)), // mapping NULL -> unknown
		when id := get(idProp, self)
		in (/*if unknown?(DB_ID_MAP[selfOwner, id])*/ DB_ID_MAP[selfOwner, id] := self // test for duplication
			/*else if (DB_ID_MAP[selfOwner, id] != self)
				(Db/popQuery(db), error("Duplicate id ~S while loading object of class ~S", id, selfOwner))*/ ))]
			
// construct a list 
[loadObjectListFromRows(db:Db/Database, self:class, idProp:dbProperty, lp:list[dbProperty]) : type[list[member(self)]]
 -> //[DBTOOLS_VALUE] loadObjectListFromRows(class = ~S, lp = ~A) // self, lp,
	let resultList := cast!(list(),self)
	in (while Db/fetch(db) 
			(let obj := unknown
			in (when id := Db/field(db, dbName(idProp))
				in (when tmpobj := lookForObjectWithId(self, integer!(id))
					in obj := tmpobj else obj := new(self))
				else error("unknown id field while loading a list of object"),
				updateValuesFromRow(db, obj, idProp, lp),
				resultList :add obj)), resultList)]


//
//	dbLoad - load a single object from an id
//


// load from an id all dbProperties of an object
[dbLoad(db:Db/Database, self:object, id:integer, lp:list[dbProperty]) : boolean ->
	//[DBOJECTS] dbLoad(object = ~S, id = ~S, lp = (~A)) // self, id, lp,
	let lpCopy:list[dbProperty] := cast!(copy(lp),dbProperty),
		idProp := getIdProperty(self)
	in (if not(idProp % lpCopy) lpCopy :add idProp, // add the id property if not present the property list
		Db/printInQuery(db),
		if (db.driverType = Db/MYSQL | db.driverType = Db/PGSQL)
			printf("SELECT ~I FROM ~A WHERE ~A=~S LIMIT 1;", printList(lpCopy), dbName(self), dbName(idProp), id)
		else
			printf("SELECT TOP 1 ~I FROM ~A WHERE ~A=~S;", printList(lpCopy), dbName(self), dbName(idProp), id),
		if Db/fetch(db) (updateValuesFromRow(db, self, idProp, lpCopy), Db/popQuery(db), true)
		else false)]
		
[dbLoad(db:Db/Database, self:object, id:string, lp:list[dbProperty]) : boolean ->
	//[DBOJECTS] dbLoad(object = ~S, id = ~S, lp = (~A)) // self, id, lp,
	dbLoad(db, self, integer!(id), lp) as boolean]

// load from an id all dbProperties of an object
[dbLoad(db:Db/Database, self:object, id:integer) : boolean ->
	//[DBOJECTS] dbLoad(object = ~S, id = ~S) // self, id,
	dbLoad(db, self, id, dbProperties(self)) as boolean]
[dbLoad(db:Db/Database, self:object, id:string) : boolean ->
	//[DBOJECTS] dbLoad(object = ~S, id = ~S) // self, id,
	dbLoad(db, self, integer!(id)) as boolean]

// load properties of object assuming its id set
[dbLoad(db:Db/Database, self:object, lp:list[dbProperty]) : boolean ->
	//[DBOJECTS] dbLoad(object = ~S) // self,
	let idProp := getIdProperty(self)
	in (if unknown?(idProp, self) error("Try to load an object with unknown id"),
		dbLoad(db, self, get(idProp, self) as integer, lp) as boolean)]

// load all dbProperties of an assuming its id set
[dbLoad(db:Db/Database, self:object) : boolean ->
	//[DBOJECTS] dbLoad(object = ~S) // self,
	dbLoad(db, self, dbProperties(self)) as boolean]

//
//	dbLoad - load a single object of a class from an id
//


// load from a class and an id a list of dbProperty values
[dbLoad(db:Db/Database, self:class, id:integer, lp:list[dbProperty]) : type[member(self)] -> 
	//[DBOJECTS] dbLoad(class = ~S, id = ~S, lp = (~A)) // self, id, lp,
	when obj := lookForObjectWithId(self, id)
	in (dbLoad(db, obj, id, lp), obj)
	else (let idProp := getIdProperty(self),
				lpCopy:list[dbProperty] := cast!(copy(lp),dbProperty),
				obj := unknown
			in (if not(idProp % lpCopy) lpCopy :add idProp, // add the id property if not present the property list
				//[DBOJECTS] getDbDescendents -> ~A // getDbDescendents(self),
				for c in getDbDescendents(self)
					(Db/printInQuery(db),
					if (db.driverType = Db/MYSQL | db.driverType = Db/PGSQL)
						printf("SELECT ~I FROM ~A WHERE ~A=~S LIMIT 1;", printList(lpCopy), dbName(c), dbName(idProp), id)
					else
						printf("SELECT TOP 1 ~I FROM ~A WHERE ~A=~S;", printList(lpCopy), dbName(c), dbName(idProp), id),
					if Db/fetch(db)
						(obj := new(c),
						updateValuesFromRow(db, obj, idProp, lpCopy),
						Db/popQuery(db),
						break())),
				obj))]

[dbLoad(db:Db/Database, self:class, id:string, lp:list[dbProperty]) : type[member(self)] -> 
	//[DBOJECTS] dbLoad(class = ~S, id = ~S, lp = (~A)) // self, id, lp,
	dbLoad(db, self, integer!(id), lp)]

// load from an id all dbProperties of a class
[dbLoad(db:Db/Database, self:class, id:integer) : type[member(self)] ->
	//[DBOJECTS] dbLoad(class = ~S, id = ~S) // self, id,
	dbLoad(db, self, id, dbProperties(self))]
[dbLoad(db:Db/Database, self:class, id:string) : type[member(self)] -> 
	//[DBOJECTS] dbLoad(class = ~S, id = ~S) // self, id,
	dbLoad(db, self, integer!(id))]


//
//	dbLoad - load multiple object from a class (optionnaly sort them according to a dbProperty)
//


// generic: load objects from a class with the following options
// 	   - topCount : max number of object in the return list
//     - sortProp : when known, specify a sort order according to the property field and order direction (asc?)
[dbLoad(db:Db/Database, self:class, lp:list[dbProperty], topCount:integer, sortProp:(dbProperty U {unknown}), asc?:boolean) : type[list[member(self)]] ->
	//[DBOJECTS] dbLoad(class = ~S, lp = (~A), sortProp = ~S, asc? = ~S) // self, lp, sortProp, asc?,
	let idProp := getIdProperty(self),
		lpCopy:list[dbProperty] := cast!(copy(lp),dbProperty),
		res := cast!(list(),self)
	in (if (length(lpCopy) = 0) lpCopy := dbProperties(self),
		if not(idProp % lpCopy) lpCopy :add idProp, // add the id property if not present in the property list
		for c in getDbDescendents(self)
			(Db/printInQuery(db),
			printf("SELECT ~I~I FROM ~A~I ~I;", 
					(if (topCount > 0 & db.driverType != Db/MYSQL & db.driverType != Db/PGSQL)
						printf("TOP ~S ", topCount)),
					printList(lpCopy),
					dbName(c),				
					(when prop := sortProp in printf(" ORDER BY ~A ~A", dbName(prop), (if asc? "ASC" else "DESC"))),
					(if (topCount > 0 & (db.driverType = Db/MYSQL | db.driverType = Db/PGSQL))
						printf("LIMIT ~S ", topCount))),
			for i in loadObjectListFromRows(db, c, idProp, lpCopy) res :add i),
		res)]


// generic: load objects from a class with the following options
// 	   - topCount : max number of object in the return list
//     - sortProp : when known, specify a sort order according to the property field and order direction (asc?)
[dbLoad(db:Db/Database, self:class, lp:list[dbProperty], topCount:integer, sortProp:(dbProperty U {unknown}), asc?:boolean,wheres:list[tuple(dbProperty,any)]) : type[list[member(self)]] =>
	dbLoadWhere(db, self, lp, topCount, sortProp, asc?,wheres)]

[dbLoadWhere(db:Db/Database, self:class, lp:list[dbProperty], topCount:integer, sortProp:(dbProperty U {unknown}), asc?:boolean,wheres:list) : type[list[member(self)]] ->
	//[DBOJECTS] dbLoad(class = ~S, lp = (~A), sortProp = ~S, asc? = ~S) // self, lp, sortProp, asc?,
	let idProp := getIdProperty(self),
		lpCopy:list[dbProperty] := cast!(copy(lp),dbProperty),
		res := cast!(list(),self)
	in (if (length(lpCopy) = 0) lpCopy := dbProperties(self),
		if not(idProp % lpCopy) lpCopy :add idProp, // add the id property if not present in the property list
		for c in getDbDescendents(self)
			(Db/printInQuery(db),
			printf("SELECT ~I~I FROM ~A ~I ~I ~I;", 
					(if (topCount > 0 & db.driverType != Db/MYSQL & db.driverType != Db/PGSQL)
						printf("TOP ~S ", topCount)),
					printList(lpCopy),
					dbName(c),
					printWhereAnd(db, wheres),
					(when prop := sortProp in printf(" ORDER BY ~A ~A", dbName(prop), (if asc? "ASC" else "DESC"))),
					(if (topCount > 0 & (db.driverType = Db/MYSQL | db.driverType = Db/PGSQL))
						printf("LIMIT ~S ", topCount))					
					),
			for i in loadObjectListFromRows(db, c, idProp, lpCopy) res :add i),
		res)]

	//
	//	dbLoad - loading all dbProperties of a class
	//
		
[dbLoad(db:Db/Database, self:class) : type[list[member(self)]] =>
	//[DBOJECTS] dbLoad(class = ~S) // self,
	let res := cast!(list(),self) //eval(List(of = self))		
	in (for c in getDbDescendents(self)
			(let idProp := getIdProperty(self),
					lp := dbProperties(c)
			in (if not(idProp % lp) lp :add idProp, // add the id property if not present in the property list		
				Db/printInQuery(db),
				printf("SELECT ~I FROM ~A;", printList(lp), dbName(c)),
				for i in loadObjectListFromRows(db, c, idProp, lp) res :add i)),
		//[DBOJECTS] dbLoad(class = ~S) -> ~A // self,res,
		res)]
		
	//dbLoad(db, self, dbProperties(self), 0, unknown, true)]

[dbLoad(db:Db/Database, self:class, sortProp:dbProperty, asc?:boolean) : type[list[member(self)]] =>
	//[DBOJECTS] dbLoad(class = ~S, sortProp = ~S, asc? = ~S) // self, sortProp, asc?,
	dbLoad(db, self, dbProperties(self), 0, sortProp, asc?)]

	//
	//	dbLoad - loading some dbProperties of a class
	//

[dbLoad(db:Db/Database, self:class, lp:list[dbProperty]) : type[list[member(self)]] => 
	//[DBOJECTS] dbLoad(class = ~S, lp = (~A)) // self, lp,
	dbLoad(db, self, lp, 0, unknown, true)]

[dbLoad(db:Db/Database, self:class, lp:list[dbProperty], sortProp:dbProperty, asc?:boolean) : type[list[member(self)]] =>
	//[DBOJECTS] dbLoad(class = ~S, lp = (~A), sortProp = ~S, asc? = ~S) // self, lp, sortProp, asc?,
	dbLoad(db, self, lp, 0, sortProp, asc?)]

[dbLoad(db:Db/Database, self:class, sortProp:(dbProperty U {unknown}), asc?:boolean, wheres:list[tuple(dbProperty,any)]) : type[list[member(self)]] =>
	dbLoadWhere(db, self, sortProp, asc?, wheres)]

[dbLoadWhere(db:Db/Database, self:class, sortProp:(dbProperty U {unknown}), asc?:boolean, wheres:list) : type[list[member(self)]] ->
	//[DBOJECTS] dbLoad(class = ~S, sortProp = ~S, asc? = ~S, where = (~A)) // self, sortProp, asc?, wheres,
	let res := cast!(list(),self)
	in (for c in getDbDescendents(self)
			let idProp := getIdProperty(c), 
				lpCopy := dbProperties(c)
			in (if not(idProp % lpCopy) lpCopy :add idProp, // add the id property if not present the property list
				Db/printInQuery(db),
				printf("SELECT ~I FROM ~A ~I~I;",
						printList(lpCopy),
						dbName(c),
						printWhereAnd(db, wheres),
						(when prop := sortProp in printf(" ORDER BY ~A ~A", dbName(prop), (if asc? "ASC" else "DESC")))),
				for i in loadObjectListFromRows(db, c, idProp, lpCopy) res :add i),
		res)]

[dbLoad(db:Db/Database, self:class, wheres:list[tuple(dbProperty,any)]) : type[list[member(self)]] => dbLoadWhere(db, self, wheres)]

[dbLoadWhere(db:Db/Database, self:class, wheres:list) : type[list[member(self)]] ->
	//[DBOJECTS] dbLoad(class = ~S, where = (~A)) // self, wheres,
	let res := cast!(list(),self)
	in (for c in getDbDescendents(self)
			let idProp := getIdProperty(c), 
				lp := dbProperties(c)
			in (Db/printInQuery(db),
				printf("SELECT ~I FROM ~A ~I;",
						printList(lp),
						dbName(c),
						printWhereAnd(db, wheres)),
				for i in loadObjectListFromRows(db, c, idProp, lp) res :add i),
		res)]

[dbLoad(db:Db/Database, self:class, lp:list[dbProperty], wheres:list[tuple(dbProperty,any)]) : type[list[member(self)]] =>
	dbLoadWhere(db, self, lp, wheres)]

[dbLoadWhere(db:Db/Database, self:class, lp:list[dbProperty], wheres:list) : type[list[member(self)]] ->
	//[DBOJECTS] dbLoad(class = ~S, where = (~A)) // self, wheres,
	let res := cast!(list(),self),
		lpCopy:list[dbProperty] := cast!(copy(lp),dbProperty)
	in (for c in getDbDescendents(self)
			let idProp := getIdProperty(c)
			in (if not(idProp % lpCopy) lpCopy :add idProp,
				Db/printInQuery(db),
				printf("SELECT ~I FROM ~A ~I;",
						printList(lpCopy),
						dbName(c),
						printWhereAnd(db, wheres)),
				for i in loadObjectListFromRows(db, c, idProp, lpCopy) res :add i),
		res)]

[dbLoad(db:Db/Database, self:class, lp:list[dbProperty], wheres:list[tuple(dbProperty,any)], sortProp:dbProperty, asc?:boolean) : type[list[member(self)]] =>
	dbLoadWhere(db, self, lp, wheres, sortProp, asc?)]

[dbLoadWhere(db:Db/Database, self:class, lp:list[dbProperty], wheres:list, sortProp:dbProperty, asc?:boolean) : type[list[member(self)]] ->
	//[DBOJECTS] dbLoad(class = ~S, where = (~A)) // self, wheres,
	let res := cast!(list(),self),
		lpCopy:list[dbProperty] := cast!(copy(lp),dbProperty)
	in (if (length(lpCopy) = 0) lpCopy := dbProperties(self),
		for c in getDbDescendents(self)
			let idProp := getIdProperty(c)
			in (if not(idProp % lpCopy) lpCopy :add idProp,
				Db/printInQuery(db),
				printf("SELECT ~I FROM ~A ~I~I;",
						printList(lpCopy),
						dbName(c),
						printWhereAnd(db, wheres),
						(when prop := sortProp in printf(" ORDER BY ~A ~A", dbName(prop), (if asc? "ASC" else "DESC")))),
				for i in loadObjectListFromRows(db, c, idProp, lpCopy) res :add i),
		res)]


[dbValidPassword?(db:Db/Database, c:class, i:integer, pass:string) : boolean ->
	let idProp := getIdProperty(c), passProp := dbPasswordProperty(c)
	in (Db/printInQuery(db),
		printf("SELECT ~A FROM ~A WHERE ~A=~S AND ~A=~I;",
						dbName(idProp),
							dbName(c),
										dbName(idProp),
											i,
												dbName(passProp),
												dbPrintValue(db, pass, passProp)),
		let valid? := fetch(db)
		in (if valid? while fetch(db) none,
			valid?))]

[dbValidPassword?(db:Db/Database, c:any, pass:string) : boolean
->	dbValidPassword?(db, owner(c), Dbo/getDbId(c), pass)]


[dbValidPassword?(db:Db/Database, c:class, loginprop:dbProperty, loginval:string, pass:string) : boolean ->
	let idProp := getIdProperty(c), passProp := dbPasswordProperty(c)
	in (Db/printInQuery(db),
		printf("SELECT ~A FROM ~A WHERE ~A=~I AND ~A=~I;",
						dbName(idProp),
								dbName(c),
										dbName(loginprop),
											dbPrintValue(db, loginval, loginprop),
												dbName(passProp),
													dbPrintValue(db, pass, passProp)),
		let valid? := fetch(db)
		in (if valid? while fetch(db) none,
			valid?))]


[dbUpdatePassword(db:Db/Database, c:class, i:integer, pass:string) : void ->
	let idProp := getIdProperty(c), passProp := dbPasswordProperty(c)
	in (Db/printInQuery(db),
		printf("UPDATE ~A SET ~I WHERE ~A=~S;",
						dbName(c),
						printAffects(db, list(tuple(passProp, pass))),
						dbName(idProp),
						i),
		endOfQuery(db))]

[dbUpdatePassword(db:Db/Database, o:any, pass:string) : void ->
	dbUpdatePassword(db, owner(o),getDbId(o), pass)]




[print_int(aint:integer) : void ->
	externC("unsigned int self = (unsigned int)aint"),
	externC("int v = 0; for(;v < sizeof(int);v++) {"),
	externC("int offset = v << 3"),
	externC("unsigned char c = (unsigned char)((self & (0xFF << offset)) >> offset)"),
	externC("ClEnv->cout->put((char)c);}")]
	

[print_string_list(self:list[string], p:port) : void ->
	fwrite("SL", p),
	let op := use_as_output(p)
	in (print_int(length(self)),
		for s in self
			(print_int(length(s)),
			princ(s)),
		use_as_output(op))]

[extract_int(p:port) : integer ->
	let i := 0
	in (externC("int v = 0; for(;v < sizeof(int);v++) {"),
		externC("unsigned char c = p->get()"),
		externC("i |= (int)((int)c << (v << 3));}"),
		i)]

[extract_string_list(p:port) : list[string] -> 
	//[DBTOOLS_VALUE] extract_string_list(~S) // p,
	let h := fread(p, 2),
		len := extract_int(p),
		l := make_list(len, string, "")
	in (if (h != "SL")
			error("Cannot extract a list[string] from ~S", p),
		for i in (1 .. len)
			let lens := extract_int(p)
			in l[i] := fread(p, lens),
		l)]














