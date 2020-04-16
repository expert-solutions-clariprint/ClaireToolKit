
//
//	how to drop database table of a class
//

[dbDrop(db:Db/Database, self:class) : void ->
	//[DBOJECTS] dbDrop(self = ~S) // self,
	Db/printInQuery(db),
	printf("DROP TABLE ~A", dbName(self)),
	Db/endOfQuery(db),
	Db/popQuery(db)]
	

//
//	how to create database tables from a class
//

[dbCreateTable(db:Db/Database, self:class, drop?:boolean) : void ->
	//[DBOJECTS] dbCreateTable(self = ~S, drop? = ~S) // self, drop?,
	if drop? try dbDrop(db, self) catch any none,
	Db/printInQuery(db),
	printf("CREATE TABLE ~A (\n~I)", dbName(self), printFieldDefinitions(db, self, dbAllProperties(self))),
	Db/endOfQuery(db),
	Db/popQuery(db),
	if (length(Db/SQL_TYPES[Db/SQL_SEQUENCE, db.driverType]) = 0)
		(Db/printInQuery(db),
		printf("CREATE SEQUENCE ~A_seq INCREMENT 1 START 1", dbName(self)),
		Db/endOfQuery(db),
		Db/popQuery(db))]
		

[dbCreateIndex(db:Db/Database,self:class,prop:dbProperty) : void
->	Db/printInQuery(db),
	printf("CREATE INDEX dboindex_~A_~A on ~A (~A);",
								dbName(self),
									dbName(prop),
											dbName(self),
												dbName(prop)),
	Db/endOfQuery(db)]

[dbCreateIndex(db:Db/Database,self:class,props:list[dbProperty]) : void
->	Db/printInQuery(db),
	printf("CREATE INDEX dboindex_~A~I on ~A (~I);",
								dbName(self),
									(for prop in props printf("_~A",dbName(prop))),
											dbName(self),
												printList(props)),
	Db/endOfQuery(db)]
