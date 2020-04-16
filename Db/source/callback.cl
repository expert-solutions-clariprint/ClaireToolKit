//*********************************************************************
//* Db                                                Sylvain Benilan *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*********************************************************************


[private/fieldIndex(self:Query, fieldName:string) : integer -> 
	let f := lower(fieldName)
	in when desc := some(desc in self.cols|desc[1] as string = f)
		in (desc[2] as integer)
		else (dbError!(self.database, fieldName /+ " is an invalid field name"), 0)]

[private/addField(self:Query, fieldName:string, index:integer) : void -> 
	self.cols :add tuple(lower(fieldName), index)]

[private/addColumn(self:list[Column], t_:string, colName:string, 
					colNull?:boolean, colTypeName:string, dataType:integer, 
					precision:integer, digits:integer) : void -> 
	self :add Column(tableName = t_, name = colName, nullable? = colNull?, sqlTypeName = colTypeName, sqlDataType = dataType, sqlPrecision = precision, sqlDigits = digits)]

[private/updatePrimaryColumn(self:list[Column], colName:string) : void -> 
	when c := some(c in self|c.name = colName)
	in (c.primary? := true)]

[private/addForeignKey(self:list[Column], key:string, foreignKey:string, foreignTable:string) : void -> 
	when c := some(c in self|c.name = key)
 	in (c.foreignKeys : add tuple(foreignTable, foreignKey))]

[private/appendDriverInfo(self:Database, info:string) : void -> self.dbInfo :/+ info]

[private/executeFailed(self:Database, Q:Query) : void -> 
	if (self.firstQuery = Q) closeCursor(Q)
	else if known?(previousQuery, self) free(self.currentQuery)]

[private/addRs(self:Query, fieldValue:string) : void -> 
	for i in (1 .. 50)
 		self.rs :add fieldValue]

