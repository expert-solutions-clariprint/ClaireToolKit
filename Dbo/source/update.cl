

//
[dbUpdate(db:Db/Database, self:object, lp:list[dbProperty]) : boolean ->
	//[DBOJECTS] dbUpdate(object = ~S, lp = (~A)) // self, lp,
	if (db.Db/autoStartTransaction? & not(db.Db/onTransaction?)) Db/beginTransaction(db),
	let idProp := getIdProperty(self), nParam := 1, Params := list<any>(),
		prepare? := (db.shouldPrepare? &
							exists(i in lp| known?(dbSqlType,i) & i.dbSqlType = Db/SQL_BLOB & known?(i,self)))
	in (when id := getDbId(self)
		in (Db/printInQuery(db),
			printf("UPDATE ~A SET ~I WHERE ~A=~S;", dbName(self), printAffects(db, self, lp but idProp), dbName(idProp), id),
			DB_ID_MAP[owner(self), id] := self)
		else (Db/popQuery(db), error("Can't update object ~S since its id is unknown", self)), 
		if prepare?
			(Db/prepare(db),
			//[DBOJECTS] bind params(~S) // length(list{i in lp| known?(dbSqlType,i) & i.dbSqlType = Db/SQL_BLOB & known?(i,self)}),
			for i in (1 .. length(lp))
				(if (known?(dbSqlType,lp[i]) & lp[i].dbSqlType = Db/SQL_BLOB & known?(lp[i],self))
					(//[DBOJECTS] bind params(~S, ~S) // lp[i], nParam,
					Db/bindParam(db, nParam),
					Params :add tuple(nParam, lp[i]),
					nParam :+ 1)),
			execute(db)),
		//[DBOJECTS] fill params(~S) // nParam - 1,		
		for i in (1 .. nParam - 1)
			let t := Db/nextParam(db)
			in when t1 := some(t1 in Params|t1[1] = t[1])
				in dbPrint(db, t1[2], self, t[2]),
		storeBlobFiles(db,self,lp),
		Db/endOfQuery(db) = 1)]

//
[dbUpdate(db:Db/Database, self:object) : boolean -> 
	//[DBOJECTS] dbUpdate(object = ~S) // self,
	dbUpdate(db, self, dbProperties(self))]

//
[dbUpdate(db:Db/Database,
			cl:class,
			values:list[tuple(dbProperty,any)],
			wheres:list[tuple(dbProperty,any)]) : integer
-> //[DBOJECTS] dbUpdate(self = ~S,values = (~A), wheres = (~A)) // cl,values,wheres,
	if (db.Db/autoStartTransaction? & not(db.Db/onTransaction?)) Db/beginTransaction(db),
	let tmp:boolean := false,
		n := 0, nParam := 1, Params := list<any>(),
		lp := (values /+ wheres),
		prepare? := (db.shouldPrepare? &
							exists(i in lp| known?(dbSqlType,i) & i[1].dbSqlType = Db/SQL_BLOB & known?(i[2])))
	in (for c in getDbDescendents(cl)
			(Db/printInQuery(db),
			printf("UPDATE ~A SET ~I~I;",
					dbName(c),
					printAffects(db, values),
					printWhereAnd(db, wheres)),
			if prepare?
				(Db/prepare(db),
				//[DBOJECTS] bind params(~S) // length(list{i in lp| known?(dbSqlType,i) & i[1].dbSqlType = Db/SQL_BLOB & known?(i[2])}),
				for i in (1 .. length(lp))
					(if (known?(dbSqlType,lp[i][1]) & lp[i][1].dbSqlType = Db/SQL_BLOB & known?(lp[i][2]))
						(//[DBOJECTS] bind params(~S, ~S) // lp[i][1], nParam,
						Db/bindParam(db, nParam),
						Params :add tuple(nParam, lp[i][2]),
						nParam :+ 1)),
				Db/execute(db)),
			//[DBOJECTS] fill params(~S) // nParam - 1,		
			for i in (1 .. nParam - 1)
				let t := Db/nextParam(db)
				in when t1 := some(t1 in Params|t1[1] = t[1])
					in Xmlo/xml!(t1[2], t[2]),
			n :+ Db/endOfQuery(db)), n)]
