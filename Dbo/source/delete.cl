

// delete an id from a table
[dbDelete(db:Db/Database, self:class, id:integer) : boolean -> 
	//[DBOJECTS] dbDelete(class = ~S, id = ~S) // self, id,	
	let idProp := getIdProperty(self)
	in (Db/printInQuery(db),
		printf("DELETE FROM ~A WHERE ~A=~A", dbName(self), dbName(idProp), id),	
		if (Db/endOfQuery(db) = 1)	
			(if known?(idGenerator, idProp)
				(Db/printInQuery(db),
				printf("DELETE FROM ~A WHERE ~A=~A", dbName(idProp.idGenerator), dbName(generatorId), id),	
				Db/endOfQuery(db)),
			when obj := DB_ID_MAP[self, id] // cleanup id map
			in (erase(getIdProperty(self), obj), DB_ID_MAP[self, id] := unknown, true)
			else false))]			
[dbDelete(db:Db/Database, self:class, id:string) : boolean ->
	//[DBOJECTS] dbDelete(self = ~S, id = ~S) // self, id,
	dbDelete(db, self, integer!(id))]

// delete an object from its table in the given database
[dbDelete(db:Db/Database, self:object) : boolean -> 
	//[DBOJECTS] dbDelete(self = ~S) // self,	
	when id := getDbId(self) 
	in dbDelete(db, owner(self), id)
	else error("Can't delete object ~S of class ~S since its id is unknown!", self, owner(self))]

// delete from a table where ...
[dbDelete(db:Db/Database, self:class, wheres:list[tuple(dbProperty,any)]) : integer -> 
	//[DBOJECTS] dbDelete(class = ~S, wheres = ~S) // self, wheres,	
	let count := 0
	in (for c in getDbDescendents(self)
			let idProp := getIdProperty(c)
			in (Db/printInQuery(db),
				printf("SELECT ~A FROM ~A ~I",
							dbName(idProp),
							dbName(c),
							printWhereAnd(db,wheres)),
				while Db/fetch(db)
					when id := Db/field(db, dbName(idProp))
					in (dbDelete(db, c, integer!(id)), count :+ 1)), count)]



// delete from a table where ...
[dbCount(db:Db/Database, self:class) : integer -> 
	//[DBOJECTS] dbCount(class = ~S) // self,	
	let count := 0
	in (for c in getDbDescendents(self)
			let idProp := getIdProperty(c)
			in (Db/printInQuery(db),
				printf("SELECT COUNT(~A) FROM ~A",
							dbName(idProp),
							dbName(c)),
				if Db/fetch(db)
					(when x := Db/field(db,1)
					in count :+ integer!(x),
					Db/popQuery(db))), count)]
					
// delete from a table where ...
[dbCount(db:Db/Database, self:class, wheres:list[tuple(dbProperty,any)]) : integer -> 
	//[DBOJECTS] dbCount(class = ~S, wheres = ~S) // self, wheres,	
	let count := 0
	in (for c in getDbDescendents(self)
			let idProp := getIdProperty(c)
			in (Db/printInQuery(db),
				printf("SELECT COUNT(~A) FROM ~A~I",
							dbName(idProp),
							dbName(c),
							printWhereAnd(db,wheres)),
				if Db/fetch(db)
					(when x := Db/field(db,1)
					in count :+ integer!(x),
					Db/popQuery(db))), count)]

//
// database LOAD[_TREE] class [WHERE property == 12 [ORDER_BY toto]]
//
// database CREATE object
//
// database UPDATE object
// database UPDATE class WHERE property == 12 VALUES pol == 78


//Where <: object(clauses:list[tuple(dbProperty,any)])

//LOAD(self:Database, whereClause:Where) : any
	