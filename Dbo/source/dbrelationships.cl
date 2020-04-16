

[db_0?(self:property) : boolean
 => unknown?(inverse, self)]

[db_1-1?(self:property) : boolean
 => known?(inverse, self) &
 	not(self % dbProperty) & self.inverse % dbProperty &
	not(self.multivalued?) & not(self.inverse.multivalued?)]

[db_1-1?(self:dbProperty, o:object) : boolean
 => unknown?(inverse, self) & not(self.multivalued?) &
 	(get(Dbo/dbSqlType,self) != Db/SQL_BLOB) &
 	range(@(self, owner(o))) % class]

[db_1-1?(self:property, o:object) : boolean => false]

[db_N-1?(self:property) : boolean
 => known?(inverse, self) & self.inverse % dbProperty &
	not(self % dbProperty) &
	self.multivalued? & not(self.inverse.multivalued?)]

[db_1-N?(self:property) : boolean
 => known?(inverse, self) & not(self.inverse % dbProperty) & self % dbProperty &
 	not(self.multivalued?) & self.inverse.multivalued?]

/*
DB_0	:: 0
DB_1-1	:: 1
DB_N-1	:: 2
DB_1-N	:: 3

DB_RELATIOSHIP :: {DB_0, DB_1-1, DB_N-1, DB_1-N}

[relationship(self:property) : DB_RELATIOSHIP
 => if db_0?(self) DB_0
 	else if db_1-1?(self) DB_1-1
	else if db_N-1?(self) DB_N-1
	else if db_1-N?(self) DB_1-N
	else error("unsupported relationship on property ~S", self)]
*/