
//
[private/dbCreateSimple(db:Db/Database, self:object, updateIdMap?:boolean, dbSimpleProps:list[dbProperty]) : boolean
 -> //[DBOJECTS] dbCreateSimple(self = ~S) // self,
	if (db.Db/autoStartTransaction? & not(db.Db/onTransaction?)) Db/beginTransaction(db),
	let idProp := getIdProperty(self), // just id
		dbAutoIncrementProperties := getAutoIncrementProperties(self), // no id, just autoincrement
		lastId := 0, nParam := 1, Params := list<any>(),
		prepare? := (db.shouldPrepare? &
						exists(i in dbSimpleProps | known?(dbSqlType,i) & i.dbSqlType = Db/SQL_BLOB & known?(i,self))),
		sequence? := (length(Db/SQL_TYPES[Db/SQL_SEQUENCE, db.driverType]) = 0),
		seqId := unknown
	in (if sequence?
			(Db/printInQuery(db),
			printf("SELECT ~A_seq.nextval()", dbName(self)),
			if Db/fetch(db)
				(when val := Db/field(db,1) in (Db/popQuery(db), seqId := integer!(val))
				else error("Could not create an id from sequence"))),
		Db/printInQuery(db),
		printf("INSERT INTO ~A~I", dbName(self), // first deal with simple properties
					(if dbSimpleProps printf(" (~I~I) VALUES (~I~I)", 
							(if sequence? printf("~I,", dbPrint(db, idProp))),
							printList(dbSimpleProps), 
							(if sequence? printf("~S,", seqId)),
							printValues(db, self, dbSimpleProps)))),
		if prepare?
			(Db/prepare(db),
			//[DBOJECTS] bind params(~S) // length(list{i in dbSimpleProps| known?(dbSqlType,i) & i.dbSqlType = Db/SQL_BLOB & known?(i,self)}),
			for i in (1 .. length(dbSimpleProps))
				(if (known?(dbSqlType,dbSimpleProps[i]) & dbSimpleProps[i].dbSqlType = Db/SQL_BLOB & known?(dbSimpleProps[i],self))
					(//[DBOJECTS] bind params(~S, ~S) // dbSimpleProps[i], nParam,
					Db/bindParam(db, nParam),
					Params :add tuple(nParam, dbSimpleProps[i]),
					nParam :+ 1)),
			execute(db)),
		//[DBOJECTS] fill params(~S) // nParam - 1,
		for i in (1 .. nParam - 1)
			let t := Db/nextParam(db)
			in when t1 := some(t1 in Params|t1[1] = t[1])
				in dbPrint(db, t1[2], self, t[2]),
		if (Db/endOfQuery(db) != 1) // INSERT should return 1 if ok
			(//[DBOJECTS] dbCreateSimple error (0 row affected),
			false) // bad result
		else (lastId := (if sequence? seqId else getLastId(db, self)) as integer,							// update object id
				write(idProp, self, lastId),
				if updateIdMap? DB_ID_MAP[owner(self), lastId] := self,	// and the id map if queried
				for autoIncrementProp in dbAutoIncrementProperties		// and its auto increment properties
					write(autoIncrementProp, self, getLastAutoIncrementedField(db, self, autoIncrementProp)),
				storeBlobFiles(db,self,dbSimpleProps),
				//[DBOJECTS] dbCreateSimple ok (1 row affected) -> id = ~S // get(idProp, self),
				true))] // ok!

[private/storeBlobFiles(db:Db/Database, self:object, dbSimpleProps:list[dbProperty])
->	for prop  in {p in dbSimpleProps | p.dbSqlBlobFile?} (
		dbPrintInFile(db, prop, self))]

[private/dbCreateWithGenerator(db:Db/Database, self:object, dbProps:list[dbProperty]) : boolean
 -> //[DBOJECTS] dbCreateWithGenerator(self = ~S) // self,
	if (db.Db/autoStartTransaction? & not(db.Db/onTransaction?)) Db/beginTransaction(db),
	let idProp := getIdProperty(self), // just id
		dbAutoIncrementProperties := getAutoIncrementProperties(self), // no id, just autoincrement
		tmpGen := new(idProp.idGenerator), // need a temporary instance of the generator		
		lastId := 0, nParam := 1, Params := list<any>(),
		prepare? := (db.shouldPrepare? &
							exists(i in dbProps|known?(dbSqlType,i) & i.dbSqlType = Db/SQL_BLOB & known?(i,self)))
	in (tmpGen.generatorClass := owner(self),	// contain the name of the child table
		//[DBOJECTS] dbCreateWithGenerator for class ~S // tmpGen.generatorClass,
		if not(dbCreateSimple(db, tmpGen, false, getSimpleProperties(tmpGen))) 		// create the generator row in the database
			(//[DBOJECTS] dbCreateWithGenerator error, can't create a row for ~S // @(idGenerator, owner(self)),
			false)
		else (lastId := get(generatorId, tmpGen) as integer,
				write(idProp, self, lastId), // let's update it in our object
				Db/printInQuery(db), // we now have a generated id, let's create object's row
				printf("INSERT INTO ~A~I", dbName(self),
						(if dbProps printf(" (~I) VALUES (~I)", 
												printList(dbProps), printValues(db, self, dbProps)))),
				if prepare?
					(Db/prepare(db),
					//[DBOJECTS] bind params(~S) // length(list{i in dbProps|i.dbSqlType = Db/SQL_BLOB & known?(i,self)}),
					for i in (1 .. length(dbProps))
						(if (dbProps[i].dbSqlType = Db/SQL_BLOB & known?(dbProps[i],self))
							(//[DBOJECTS] bind params(~S, ~S) // dbProps[i], nParam,
							Db/bindParam(db, nParam),
							Params :add tuple(nParam, dbProps[i]),
							nParam :+ 1)),
					Db/execute(db)),
				//[DBOJECTS] fill params(~S) // nParam - 1,
				for i in (1 .. nParam - 1)
					let t := Db/nextParam(db)
					in when t1 := some(t1 in Params|t1[1] = t[1])
						in dbPrint(db, t1[2], self, t[2]),
				if (Db/endOfQuery(db) != 1) // INSERT should return 1 if ok
					(//[DBOJECTS] dbCreateWithGenerator error (0 row affected),
					false) // bad result
				else (DB_ID_MAP[owner(self), lastId] := self,				// and the id map
						for autoIncrementProp in dbAutoIncrementProperties	// and its auto increment properties
						write(autoIncrementProp, self, getLastAutoIncrementedField(db, self, autoIncrementProp)),
						//[DBOJECTS] dbCreateWithGenerator ok (1 row affected) -> id = ~S // get(idProp, self),
						storeBlobFiles(db,self,dbProps),
						true)))] // ok!


// How to create a row in database from an object
[dbCreate(db:Db/Database, self:object, props:list[dbProperty]) : boolean
 -> //[DBOJECTS] dbCreate(self = ~S) // self,
	if (self % class) error("Can't create object ~S in database", self),
	let idProp := getIdProperty(self)
	in (if known?(idProp, self) error("Try to create in database an object (~S) of class ~S that already has a known id (~S)", self, owner(self), get(idProp, self)),
		if unknown?(idGenerator, idProp) dbCreateSimple(db, self, true, props)
		else dbCreateWithGenerator(db, self, props add idProp))]

[dbCreate(db:Db/Database, self:object) : boolean
->	dbCreate(db,self,getSimpleProperties(self))]

