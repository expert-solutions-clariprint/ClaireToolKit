
//
// verbosity indexes
//

DBOJECTS :: 1
DBTOOLS :: 2
DBTOOLS_VALUE :: 3
DBUPDATE :: 1


private/BASIC_TYPES :: subtype[integer U float U char U string U boolean]

STRING_BAG_SEP :: char!(28)


IdGenerator <: ephemeral_object

DataStorage <: ephemeral_object

dbStore? :: property(open = 3)
dbReference? :: property(open = 3)

[dbStore?(self:any) : boolean -> false]
[dbReference?(self:any) : boolean -> false]


//
//	Defining the database property class
//

FILE_STORAGE:string := "/tmp/dbo_files"

// instanciate your slot's properties from dbProperty
// to interface them with a database
dbProperty <: property(autoIncrement?:boolean = false,
						fieldName:string,
						password?:boolean = false,
						dbSqlType:integer = SQL_INTEGER,
						dbSqlBlobFile?:boolean = false,
						dbSqlPrecision:integer = 30,
						dbSqlDigit:integer = 0,
						xssFilter:boolean = true,
						null?:boolean = true,
						id?:boolean = false,
						idGenerator:subtype[IdGenerator])

//
//	Defining the IdGenerator class (table id inheritence)
//

generatorId :: dbProperty(id? = true)
generatorClass :: dbProperty()

IdGenerator <: ephemeral_object(generatorId:integer, generatorClass:class)


// The current database driver in use
//DB_DRIVER:Db/SQL_DRIVERS := Db/ACCESS

// How to setup driver
// [dbSelectDriver(driver:Db/SQL_DRIVERS) : void => DB_DRIVER := driver]

//private/DB_ID_MAP[objectClass:class, objectId:integer] : (object U {unknown}) := unknown

db_id_map <: ephemeral_object(map:list[any])

DB_ID_MAP :: db_id_map()

// list(maclasse,list(1,o,2,k)...)

[nth=(self:db_id_map, c:class, oid:integer, obj:(object U {unknown})) : void ->
	let i := 1, l := self.map, len := length(l)
	in (if not(while (i < len)
				(if (l[i] = c)
					let ol := l[i + 1] as list[any],
						olen := length(ol),
						o := 1
					in (if not(while (o < olen)
								(if (ol[o] = oid)
									(ol[o + 1] := obj, break(true)), o :+ 2))
							(ol add oid,
							ol add obj),
						break(true))
					else i :+ 2))
			(l add c,
			l add list<any>(oid, obj)))]


[nth(self:db_id_map, c:class, oid:integer) : (object U {unknown}) ->
	let i := 1, l := self.map, len := length(l), res := unknown
	in (while (unknown?(res) & i < len)
			(if (l[i] = c)
				let ol := l[i + 1] as list[any],
					olen := length(ol),
					o := 1
				in (while (o < olen)
						(if (ol[o] = oid)
							(res := ol[o + 1],
							break()), o :+ 2),
					break()), i :+ 2),
		res as (object U {unknown}))]


