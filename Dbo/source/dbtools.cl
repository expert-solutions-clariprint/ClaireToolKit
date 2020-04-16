
//
//	Mapping CLAIRE symbols to DB names
//


// construct a field name from a dbProperty
// if the dbProperty has id? set to true returns "id"
// else if the dbProperty has a known fieldName returns uts value
// otherwise dbName(myBooleanSlot?) -> "myBooleanSlot_ask"
[dbName(self:dbProperty) : string -> 	
	if known?(fieldName, self) self.fieldName
	else if known?(idGenerator, self) "gid"
	else if self.id? "id"
	else (print_in_string(),
	printf("~I_~I", c_princ(dbName(self.name.module!)), c_princ(string!(self.name))),
	end_of_string())]

[dbName(self:dbProperty,cl:class) : string -> dbName(cl) /+ "." /+ dbName(self)]


DB_CLASS_NAME[self:class] : (string U {unknown}) := unknown

// construct the a table name from a class
// ex:
//      dbName(myModule/MyClass?) -> "t_myModule_MyClass_ask"
[dbName(self:class) : string -> 
	when clDbName := DB_CLASS_NAME[self] in clDbName
	else (print_in_string(),
		printf("t_~I_~I", c_princ(dbName(self.name.module!)), c_princ(string!(self.name))),
		let clDbName := end_of_string()
		in (DB_CLASS_NAME[self] := clDbName,
			clDbName))]

// returns the table name of the object's class
[dbName(self:object) : string => dbName(owner(self))]

[dbName(self:module) : string -> string!(self.name)]

//
//	get the list of dbProperties from a class/object
//

// including passwod -> create table
[dbAllProperties(self:class) : list[dbProperty] -> 
	list{p.selector|p in list{p in self.slots|p.selector % dbProperty}} as list[dbProperty]]

[dbAllProperties(self:object) : list[dbProperty] -> dbProperties(owner(self))]


[dbProperties(self:class) : list[dbProperty] ->
	list{p.selector|p in list{p in self.slots|p.selector % dbProperty & not(p.selector.password?)}} as list[dbProperty]]

[dbProperties(self:object) : list[dbProperty] -> dbProperties(owner(self))]

[dbPropertiesButId(self:class) : list[dbProperty] -> 
	list{p.selector|p in list{p in self.slots|p.selector % dbProperty & not(p.selector.id?) & not(p.selector.password?)}} as list[dbProperty]]

[dbPropertiesButId(self:object) : list[dbProperty] => dbPropertiesButId(owner(self))]

[dbPasswordProperty(self:class) : dbProperty -> 
	let l := list{p.selector|p in list{p in self.slots|p.selector % dbProperty & p.selector.password?}}
	in (if not(l) error("The class ~S doesn't have any password dbProperty", self),
		l[1] as dbProperty)]

[dbPasswordProperty(self:object) : dbProperty -> dbPasswordProperty(owner(self))]

//
//	Using ids
//


// return the class's slot that represent an id
[getIdProperty(self:class) : dbProperty ->
	let id:property := isa
	in (for p in self.slots
			let sel := p.selector
			in (case sel
					(dbProperty
						(if (not(sel.password?) & (sel.id? | known?(idGenerator, sel)))
							(id := sel,
							break())))),
		if (id = isa)
			error("The class ~S doesn't have a dbProperty that is an id", self),
		id as dbProperty)]

//	when idProp := some(p in dbProperties(self)|p.id? | known?(idGenerator, p))
//	in idProp
//	else error("The class ~S doesn't have a dbProperty that is an id", self)]
	
// return the object's class slot that represent an id
[getIdProperty(self:object) : dbProperty => getIdProperty(owner(self))]

// return the object's class slot that represent an id
[getAutoIncrementProperties(self:class) : list[dbProperty]
 => list<dbProperty>{p in dbProperties(self)|p.autoIncrement? & not(p.id?) & unknown?(idGenerator, p)}]
[getAutoIncrementProperties(self:object) : list[dbProperty]
 -> getAutoIncrementProperties(owner(self))]

[getSimpleProperties(self:class) : list[dbProperty]
 => list<dbProperty>{p in dbProperties(self)|not(p.autoIncrement?) & not(p.id?) & not(p.password?) & unknown?(idGenerator, p)}]
[getSimpleProperties(self:object) : list[dbProperty]
	-> getSimpleProperties(owner(self))]

// return the object's id assuming a dbProperty with id? = true exists
[getDbId(self:object) : (integer U {unknown}) => get(getIdProperty(self), self) as (integer U {unknown})]

// return the object's id assuming a dbProperty with id? = true exists
[lookForObjectWithId(self:class, id:integer) : (object U {unknown}) -> 
	when obj := DB_ID_MAP[self, id]   // l'objet est mappŽ => OK
	in (//[DBOJECTS] lookForObjectWithId(~S, ~S) => ~S (was mapped) // self, id, obj,
		obj)
	else (let idProp := getIdProperty(self)
		in when obj := some(o in self|get(idProp, o) = id)   // on rechrche un object avec le bon ID, et on le mappe
		in (//[DBOJECTS] lookForObjectWithId(~S, ~S) => ~S (map it!) // self, id, obj,
			DB_ID_MAP[self, id] := obj,
			obj as object)
		else unknown)]

// return the object's id assuming a dbProperty with id? = true exists
[getObjectFromId(db:Db/Database, self:class, id:integer) : (object U {unknown}) -> 
	when obj := lookForObjectWithId(self,id)   // l'objet est mappŽ => OK
	in (//[DBOJECTS] getObjectFromId(~S, ~S) => ~S (was mapped) // self, id, obj,
		obj)
	else let idProp := getIdProperty(self),
			genClass:any := self
		in (when gen := get(idGenerator, idProp)  // il a un generator => je cherche la classe
			in (printInQuery(db),
				printf("SELECT ~A FROM ~A WHERE ~A = ~S",
								dbName(generatorClass), dbName(gen), dbName(generatorId), id),
				if not(fetch(db)) error("getObjectFromId(~S, ~S), failed to fetch the generator class",self,id),
				let clDbName := row(db)[1],
					t := explode(clDbName,"/")
				in (if (length(t) = 2)		// compatibilite ascendante : ta table de genrator contient soit la classe soit le nom de la table
						when m := get_value(t[1])
						in genClass := get_value(m,t[2])
						else genClass := unknown
					else genClass := some(c in class|dbStore?(c) & dbName(c) = clDbName)),
				
				if not(genClass % class) error("in getObjectFromId(~S,~S), the string ~S is not a class", self, id, row(db)[1]),
				//[DBOJECTS] getObjectFromId, id ~S point to an object of class ~S // id, genClass,
				popQuery(db)),
			let o := new(genClass as class) 
			in (write(idProp,o,id),
				//[DBOJECTS] getObjectFromId(~S, ~S) => ~S (create new object of class ~S) // self, id, o, genClass,
				DB_ID_MAP[genClass, id] := o,
				o))]

/*
			let o := new(self) 
			in (write(getIdProperty(self),o,id),
				//[DBOJECTS] getObjectFromId(~S, ~S) => ~S (create new object of class ~S) // self, id, o, self,
				DB_ID_MAP[self, id] := o,
				o)))]
*/


// return the last created autoincrement value
// use it after an SQL INSERT
[getLastAutoIncrementedField(db:Db/Database, self:class, prop:dbProperty) : (integer U {unknown}) ->
	let dbPropName := dbName(prop), idProp := getIdProperty(self)
	in (Db/printInQuery(db),
		if (db.driverType = Db/MYSQL)
			printf("SELECT LAST_INSERT_ID()")
		else if (db.driverType = Db/MSSQL)
			printf("SELECT @@IDENTITY")
		else if (db.driverType = Db/PGSQL)
			printf("SELECT currval('~A_~A_seq')", lower(dbName(self)), lower(dbPropName))
		else
			printf("SELECT TOP 1 ~A FROM ~A ORDER BY ~A DESC", dbPropName, dbName(self), dbName(idProp)),
		if Db/fetch(db)
			(when val := Db/field(db,1) in (Db/popQuery(db), integer!(val))
			else unknown)
		else unknown)]
[getLastAutoIncrementedField(db:Db/Database, self:object, prop:dbProperty) : (integer U {unknown}) ->
	getLastAutoIncrementedField(db, owner(self), prop)]

// return the last created
// use it after an SQL INSERT
[getLastId(db:Db/Database, self:class) : (integer U {unknown})
 -> getLastAutoIncrementedField(db, self, getIdProperty(self))]
[getLastId(db:Db/Database, self:object) : (integer U {unknown}) => getLastId(db, owner(self))]

[getRangesN-1(p:property, o:object) : set => 
	{r in descendents(mClaire/t1(range(@(p, owner(o)))))|dbStore?(r)}]
[getRanges1-1Or1-N(p:property, o:object) : set => 
	{r in descendents(range(@(p, owner(o))))|dbStore?(r)}]


[getRange1-1(p:dbProperty, o:object) : class => range(@(p, owner(o))) as class]

[getRange(p:property, o:object) : (class U {unknown}) => 
	some(r in descendents(range(@(p, owner(o))))|dbStore?(r))]
[getDbDescendents(self:class) : type[subtype[self]] =>
	list{c in descendents(self) | dbStore?(c)}]

// returns the id an object that is pointed by a class's slot
[idOf(db:Db/Database, self:object, prop:property) : (integer U {unknown})
 -> //[DBOJECTS] idOf@property(object = ~S, prop = ~S) // self, prop,
 	if unknown?(inverse, prop)
		error("idOf@property ~S @ ~S (on ~S) as an unknown inverse", prop, owner(self), self),
	when childRange := getRange(prop, self)
	in (let idProp := getIdProperty(childRange),
			res := (Db/printInQuery(db),
				if (db.driverType = Db/MYSQL | db.driverType = Db/PGSQL)
					printf("SELECT ~A FROM ~A WHERE ~A=~S LIMIT 1", dbName(idProp), 
									dbName(childRange), dbName(prop.inverse), getDbId(self))
				else
					printf("SELECT TOP 1 ~A FROM ~A WHERE ~A=~S", dbName(idProp), 
									dbName(childRange), dbName(prop.inverse), getDbId(self)),
				if Db/fetch(db) (when id := Db/field(db, dbName(idProp)) in (Db/popQuery(db), integer!(id)) 
								else unknown)
				else unknown)
		in (//[DBOJECTS] idOf@property => ~S // res,
			res)) else unknown]

// returns the id an object pointed by self.prop
[idOf1-1(db:Db/Database, self:object, prop:dbProperty) : (integer U {unknown})
 -> //[DBOJECTS] idOf1-1@dbProperty(object = ~S, prop = ~S) // self, prop,
	let idProp := getIdProperty(owner(self)),
			res := (Db/printInQuery(db),
				if (db.driverType = Db/MYSQL | db.driverType = Db/PGSQL)
					printf("SELECT ~A FROM ~A WHERE ~A=~S LIMIT 1", dbName(prop), 
									dbName(owner(self)), dbName(idProp), getDbId(self))
				else
					printf("SELECT TOP 1 ~A FROM ~A WHERE ~A=~S", dbName(prop), 
									dbName(owner(self)), dbName(idProp), getDbId(self)),
				if Db/fetch(db) (when id := Db/field(db, dbName(prop)) in (Db/popQuery(db), integer!(id)) 
								else unknown)
				else unknown)
		in (//[DBOJECTS] idOf1-1@dbProperty => ~S // res,
			res)]

[idOfForRange(db:Db/Database, self:object, prop:dbProperty, childRange:class) : (integer U {unknown})
 -> //[DBOJECTS] idOfForRange(object = ~S, prop = ~S, childRange = ~S) // self, prop, childRange,
 	let	childIdProp := getIdProperty(childRange),
	 	idProp := getIdProperty(self)
	in (Db/printInQuery(db),
		if (db.driverType = Db/MYSQL | db.driverType = Db/PGSQL)
			printf("SELECT ~A.~A FROM ~I WHERE ~A.~A=~S AND ~A.~A=~A.~A LIMIT 1", 
							dbName(childRange),
							dbName(childIdProp),
									(if (owner(self) = childRange) princ(dbName(childRange))
									else printf("~A,~A", 
											dbName(childRange), 
											dbName(self))), 
													dbName(self), 
													dbName(idProp), 
													getDbId(self),
																dbName(childRange), 
																dbName(childIdProp),
																dbName(self),
																dbName(prop))
		else
			printf("SELECT TOP 1 ~A.~A FROM ~I WHERE ~A.~A=~S AND ~A.~A=~A.~A", 
							dbName(childRange),
							dbName(childIdProp),
									(if (owner(self) = childRange) princ(dbName(childRange))
									else printf("~A,~A", 
											dbName(childRange), 
											dbName(self))), 
													dbName(self), 
													dbName(idProp), 
													getDbId(self),
																dbName(childRange), 
																dbName(childIdProp),
																dbName(self),
																dbName(prop)),
		if Db/fetch(db) (//[DBOJECTS] idOfForRange row(~A) // row(db),
						flush(stdout),
						when id := Db/field(db, dbName(childIdProp)) 
						in (Db/popQuery(db), integer!(id)) 
						else (Db/popQuery(db), unknown))
		else (//[DBOJECTS] idOfForRange empty row,
				unknown))]
					
[idOf(db:Db/Database, self:object, prop:dbProperty) : (integer U {unknown})
 -> //[DBOJECTS] idOf@dbProperty(object = ~S, prop = ~S) // self, prop,
 	some(i in {idOfForRange(db, self, prop, rng)|rng in 
 							getRanges1-1Or1-N(prop, self)}|i != unknown)]
 

// load a list of value 
[dbLoadValue(db:Db/Database, prop:dbProperty, from:class, wheres:list[tuple(dbProperty,any)],distinct?:boolean,asc?:(boolean U {unknown})) : list[string]
-> //[DBOJECTS] idOf@dbGetListValue(prop = ~S) // prop,
 	let result := list<string>()
 	in (Db/printInQuery(db),
 		printf("SELECT ~I ~A FROM ~A ~I ~I",
 				(if distinct? princ("DISTINCT")),
 				dbName(prop),
 				dbName(from),
 				printWhereAnd(db, wheres),
 				(when _asc? := asc? in printf(" ORDER BY ~A ~A", dbName(prop), (if _asc? "ASC" else "DESC")))
 		),
 		
 		while Db/fetch(db) when val := Db/row(db)[1] in result :add val as string,
 		result)]
 
 // load a list of value 
[dbGetMaxIntValue(db:Db/Database, prop:dbProperty, from:class, wheres:list[tuple(dbProperty,any)]) : integer
-> //[DBOJECTS] idOf@dbGetListValue(prop = ~S) // prop,
 	let result:integer := 0
 	in (Db/printInQuery(db),
 		printf("SELECT  MAX(~A) FROM ~A ~I",
 				dbName(prop),
 				dbName(from),
 				printWhereAnd(db, wheres)),
 		while Db/fetch(db) when val := Db/row(db)[1] in result := integer!(val),
 		result)]
 


get_dbUpdate_version(r:method) : integer ->
	let v := r.domain[3]
	in (case v (set v[1] as integer, any 0))
 
[dispatch_updates(self:Database, cat:string) : void ->
	//[DBUPDATE] dispatch_updates(~S,~S) // self,cat,
	//<sb> ensure that the version table exists
	if not("t_db_version" % tables(self))
		(//[DBUPDATE] creating t_db_version,
		execute(self, "CREATE TABLE t_db_version (version int, module varchar(255), last_update timestamp)")),
	//[DBUPDATE] <sb> propagate updates,
	for m in (module but Dbo)
		when dbUpdate := get_value(m, "db_update_model") //<sb> db_update_model should be re-defined in each module
		in let top_version := 0,
				current_version := -1,
				modname := (print_in_string(), c_princ(m.name.name), end_of_string()),
				date_value := strftime(SQL_TYPES[SQL_TIMESTAMP_FORMAT, self.driverType], now()),
				rs := list{r in dbUpdate.restrictions | //<sb> db_update_model restrictions
								length(r.domain) = 3 &  // that have a compatible domain
									r.module! = m &
									r.domain[1] <= Database &
									r.domain[2] % subtype[string] &
									cat % r.domain[2] &
									r.domain[3] % subtype[integer]}
			in (//[DBUPDATE] updating for module ~S // m,
				if rs
					(//<sb> get top version from defined restriction of dbUpdate
					//[DBUPDATE] ... found restrictions ... ,
					for r in rs
						top_version :max get_dbUpdate_version(r),
					//[DBUPDATE] top_version := ~A // top_version,
					//<sb> get the current version from the database
					execute(self, "SELECT version from t_db_version where module = '" /+ modname /+ "'"),
					while fetch(self)
						current_version := integer!(field(self,1)),
					//<sb> insert if not found
					if (current_version = -1)
						(current_version := 0,
						execute(self, "INSERT INTO t_db_version (version, module, last_update) values (" /+
										string!(current_version) /+ ", '" /+ modname /+ "', " /+ date_value /+ ")")),
					//<sb> perform sequential updates from current to top version
					if (current_version = top_version)
						//[-100] == db_update_model(~S) => module ~S up to date (version ~S) // self, m, current_version,
					for v in (current_version + 1 .. top_version)
						for r in rs
							let vr := get_dbUpdate_version(r)
							in (if (v = vr)
									(//[-100] == db_update_model(~S) => update module ~S to version ~S // self, m, v,
									apply(r, list(self, cat, v)),
									execute(self, "UPDATE t_db_version set " /+
												"version = " /+ string!(v) /+
												", last_update = " /+ date_value /+
												" where module = '" /+ modname /+ "'")))))]


// Verification de l'existance d'une table
[check_table_exists(db:Db/Database,t_name:string) : boolean
-> exists(i in Db/tables(db) | lower(i) = lower(t_name))]

// Verification de l'existance d'une table
[check_table_exists(db:Db/Database,t_class:class) : boolean
-> check_table_exists(db,dbName(t_class))]

// Verification de l'existance d'une colonne
[check_column_exists(db:Db/Database,t_name:string,c_name:string) : boolean
->	exists(i in Db/columns(db,t_name) | lower(i.Db/name) = lower(c_name))]

// Verification de l'existance d'une colonne
[check_column_exists(db:Db/Database,t_class:class,c_prop:Dbo/dbProperty) : boolean
->	check_column_exists(db,dbName(t_class),dbName(c_prop))]

//<xp> Check if an index exist on a column
[index?(self:Database,t_class:class,c_prop:Dbo/dbProperty) : boolean
-> Db/dbIndexExists?(self,dbName(t_class),dbName(c_prop))]

//<xp> Check if an index exist on a column
[index?(self:Database,t_class:class,index_name:string) : boolean
-> Db/dbIndexExists?(self,dbName(t_class),index_name)]

//<xp> Check if an index exist on a column
[index?(self:Database,t_class:string,index_name:string) : boolean
-> Db/dbIndexExists?(self,t_class,index_name)]
