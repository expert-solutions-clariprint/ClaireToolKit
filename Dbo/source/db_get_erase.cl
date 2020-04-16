

[dbGetId(db:Db/Database, prop:property, self:object) : (integer U {unknown})
->	if unknown?(getIdProperty(self), self)
		error("dbGetId(~S, ~S) error, ~S's id is unknown", prop, self, self),
	if not(db_1-1?(prop, self)) 
		error("dbGetId(~S, ~S) error, ~S's range is not a  db-stored class", prop, self, prop),	
	idOf1-1(db, self, prop)]

[dbGet(db:Db/Database, prop:property, self:object) : any
 -> //[DBOJECTS] dbGet(prop = ~S, object = ~S) // prop, self,
	if unknown?(getIdProperty(self), self)
		error("dbGet(~S, ~S) error, ~S's id is unknown", prop, self, self),	
	let res := 
		(if db_N-1?(prop)
			(//[DBOJECTS] dbGet(~S,~S) @ db_N-1? // prop, self,
			erase(prop, self),
			for rng in getRangesN-1(prop, self)
				dbLoad(db, rng, list(tuple(prop.inverse, self))),
			get(prop, self))

		else if db_1-1?(prop, self)
			(//[DBOJECTS] dbGet(~S,~S) @ db_1-1? // prop, self,
			erase(prop, self),
			when id := idOf1-1(db, self, prop)
			in (//[DBOJECTS] dbGet(~S,~S) @ db_1-1?, idOf returned ~S // prop, self,id,
				when obj := dbLoad(db, getRange1-1(prop, self), id)
				in (write(prop, self, obj), obj)
				else (erase(prop, self), get(prop, self)))
			else (//[DBOJECTS] dbGet(~S,~S) @ db_1-1?, idOf returned unknown // prop, self,
				erase(prop, self), get(prop, self)))
							
		else if db_1-N?(prop)
			(//[DBOJECTS] dbGet(~S,~S) @ db_1-N? // prop, self,
			erase(prop, self),
			when id := idOf1-1(db, self, prop)
			in (//[DBOJECTS] dbGet(~S,~S) @ db_1-N?, idOf returned  ~S // prop, self,id,
				when obj := dbLoad(db, getRange1-1(prop, self), id) //some(o in {dbLoad(db, rng, id)|rng in getRanges1-N(prop, self)}|o != unknown)
				in (write(prop, self, obj), obj)
				else (erase(prop, self), get(prop, self)))
			else (//[DBOJECTS] dbGet(~S,~S) @ db_1-N?, idOf returned unknown // prop, self,
				erase(prop, self), get(prop, self)))
							
		else if db_1-1?(prop) 
			(//[DBOJECTS] dbGet(~S,~S) @ db_1-1? // prop, self,
			erase(prop, self),
			when id := idOf(db, self, prop)
			in (let obj := (when rng := getRange(prop, self)
							in (when o := dbLoad(db, rng, id)
							    in o
							    else (erase(prop, self), get(prop, self), unknown))
							else (erase(prop, self), get(prop, self), unknown))
				in (if unknown?(obj) (erase(prop, self), obj := get(prop, self)), 
					obj))
			else (erase(prop, self), get(prop, self)))
			
		else if (prop % dbProperty) (dbLoad(db,self,list(prop as dbProperty)), get(prop, self))
		
		else get(prop, self))
	in (//[DBOJECTS] dbGet(~S,~S) => ~S // prop, self, res,
		res)]
		
//
[dbErase(db:Db/Database, prop:property, self:object) : any
 -> //[DBOJECTS] dbErase(prop = ~S, object = ~S) // prop, self,
	if known?(getIdProperty(self), self)		
		(let rng := range(@(prop, owner(self)))
			in (case rng
					(BASIC_TYPES
							(if not(prop % dbProperty)
								error("dbErase ~S @ ~S (on ~S) of range ~S, ~S is not a dbProperty", prop, owner(self), self, rng, prop),
							erase(prop, self),
							dbUpdate(db, self, list(prop))),

					subtype[bag] 
						(if not(mClaire/t1(rng) % class) 
							error("dbErase ~S @ ~S (on ~S) of range ~S is not a bag of class", prop, owner(self), self, rng),
						for i in dbGet(db, prop, self) dbDelete(db, i)),

					class (when obj := dbGet(db, prop, self)
							in dbDelete(db, obj))))), erase(prop, self)]