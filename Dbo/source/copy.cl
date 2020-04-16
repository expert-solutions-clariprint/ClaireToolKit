

[dbCopy(db:Db/Database, self:object) : object -> dbCopy(db, self, true)]

[dbCopy(db:Db/Database, self:object, use_dbGet?:boolean) : object
 -> //[DBOJECTS] **** dbCopy(object = ~S, use_dbGet? = ~S) // self, use_dbGet?,
 	if use_dbGet?
		for prop in {p.selector|p in owner(self).slots} // load dependencies
			(if (db_N-1?(prop) | dbReference?(range(@(prop, owner(self)))) |
					// (db_1-1?(prop, self) & not(db_1-1?(prop))) |
					(not(db_1-1?(prop, self)) & db_1-1?(prop))) // | db_1-N?(prop))
				(erase(prop, self),
				dbGet(db, prop, self))),
 	when i := getDbId(self)
 	in DB_ID_MAP[owner(self), i] := unknown,
 	erase(getIdProperty(self), self), // erase object id
 	if dbCreate(db, self) // create new object in database and get its id
 		(//[DBOJECTS] **** dbCopy: ~S as new id -> ~S // self, getDbId(self),
 		for prop in {p in {p.selector|p in owner(self).slots}|not(range(@(p, owner(self))) % BASIC_TYPES)}
 			(if db_N-1?(prop)              // N-1
 				(//[DBOJECTS] **** dbCopy: update N-1 relationship (~S -> ~S) // prop, prop.inverse,
 				for val in get(prop, self)
 					(dbCopy(db, val, use_dbGet?),
 					//[DBOJECTS] **** dbCopy: update N-1 relationship (~S -> ~S) on ~S with ~S // prop, prop.inverse, self, val
 					))
	 		else if db_1-1?(prop, self)		// 1-1
	 			(//[DBOJECTS] **** dbCopy: update 1-1 relationship (~S -> ~S) // prop, range(@(prop, owner(self))),
	 			when obj := get(prop, self) ;dbGet(db, prop, self)
	 			in (if (not(dbReference?(owner(obj))) & dbStore?(owner(obj)))
	 					dbCopy(db, obj, use_dbGet?),
	 				write(prop, self, obj),
	 				dbUpdate(db, self, list<dbProperty>(prop as dbProperty)),
	 				//[DBOJECTS] **** dbCopy: update 1-1 relationship (~S -> ~S) on ~S with ~S // prop, range(@(prop, owner(self))), self, obj
	 				))
	 		
	 		else if (db_1-1?(prop) & dbStore?(owner(get(prop,self))))				// 1-1
	 			(//[DBOJECTS] **** dbCopy: update 1-1 relationship (~S -> ~S) // prop, prop.inverse,
	 			when obj := get(prop, self) ;dbGet(db, prop, self)
	 			 in (dbCopy(db, obj, use_dbGet?),
	 			 	 write(prop.inverse, obj, self),
	 				dbUpdate(db, obj, list<dbProperty>(prop.inverse as dbProperty)),
	 				//[DBOJECTS] **** dbCopy: update 1-1 relationship (~S -> ~S) on ~S with ~S // prop, prop.inverse, self, obj
	 				)))),
	 //[DBOJECTS] **** dbCopy => ~S // self,
	 self]

(abstract(dbCopy))