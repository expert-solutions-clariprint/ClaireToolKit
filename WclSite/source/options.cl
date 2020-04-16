//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* options.cl                                                        *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2005-10-04 16:25:55 +0200 (Mar 04 oct 2005) $
//*	$Revision: 1175 $
//*********************************************************************


// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: *                                                       *
// *********************************************************************


optCategorie :: Dbo/dbProperty()
optName :: Dbo/dbProperty()
optValue :: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_BLOB)

WebOption <: ephemeral_object(
			dbId:integer,
			optCategorie:string,
			optName:string,
			optValue:any)

[Dbo/dbStore?(o:{WebOption}) : boolean -> true]

[getOption(category:string,option_name:string, default_value:any) : any
->	when o := some(i in Dbo/dbLoad(USER_DATABASE,
								WebOption,
								list(tuple(optCategorie,category),
									tuple(optName,option_name))) | true)
	in o.optValue else default_value]

[setOption(category:string,option_name:string, default_value:any) : void
->	when o:WebOption := some(i in Dbo/dbLoadWhere(USER_DATABASE,
								WebOption,
								list(tuple(optCategorie,category),
									tuple(optName,option_name))) | true)
	in (o.optValue := default_value, Dbo/dbUpdate(USER_DATABASE,o))
	else Dbo/dbCreate(USER_DATABASE,
				WebOption(optCategorie = category,
							optName = option_name,
							optValue = default_value))]

[eraseOption(category:string,option_name:string) : void
->	Dbo/dbDelete(USER_DATABASE,WebOption,
				list(tuple(optCategorie,category),
									tuple(optName,option_name)))]


[Dbo/dbPrint(db:Db/Database, self:{optValue}, obj:WebOption, p:port) : void
->	serialize(p, get(self, obj))]

[Dbo/value!(db:Db/Database, p:{optValue}, obj:WebOption, self:port) : any
->	unserialize(self)]

