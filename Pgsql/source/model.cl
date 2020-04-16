
// win32: www.mysql.com -> install mysql/win32
// os X: already installed!

PgSqlHandle <: import()

(c_interface(PgSqlHandle,"PGconn* "))

PgSqlDatabase <: Database(pgSqlHandle:PgSqlHandle)

[dbPort!(self:PgSqlDatabase) : port -> function!(pgSqlPort)]
[dbFetch(self:PgSqlDatabase, Q:Query) : boolean -> function!(pgSqlFetch)]
[dbExecute(self:PgSqlDatabase, Q:Query) : void -> function!(pgSqlExecute)]
[dbFree(self:PgSqlDatabase, Q:Query) : void -> function!(pgSqlFree)]
[dbOpenCursor(self:PgSqlDatabase, Q:Query) : void -> function!(pgSqlOpenCursor)]
[dbCloseCursor(self:PgSqlDatabase, Q:Query) : void -> function!(pgSqlCloseCursor)]
[dbDisconnect(self:PgSqlDatabase) : void -> function!(pgSqlDisconnect)]
[dbConnect(self:PgSqlDatabase, dbName:string, address:string, user:string, password:string) : PgSqlDatabase -> function!(pgSqlConnect)]
[dbTables(self:PgSqlDatabase, lc:list[string]) : list[string] -> function!(pgSqlTables,NEW_ALLOC, RETURN_ARG)]

[dbColumns(self:PgSqlDatabase, t_:string, lc:list[Column]) : list[Column]
 -> if (execute(self, "show columns from " /+ t_) != -1)
 		dbError!(self, "Unable to retreview " /+ t_ /+ "'s columns"),
 	while fetch(self)
 		lc :add Column(tableName = t_, name = field(self,"Field"), nullable? = (field(self,"Null") = "YES"), 
 						sqlTypeName = field(self,"Type"), primary? = (field(self,"Key") = "PRI")), lc]

[Db/pgSql!(dbName:string) : Database 
-> let x := parseConnectionQuery(dbName)
	in initFirstQuery(dbConnect(PgSqlDatabase(), x[4], x[3], x[1],x[2]))]

[Db/pgSql!(dbName:string, address:string) : Database 
-> initFirstQuery(dbConnect(PgSqlDatabase(), dbName, address, "", ""))]

[Db/pgSql!(dbName:string, address:string, user:string) : Database -> initFirstQuery(dbConnect(PgSqlDatabase(), dbName, address, user, ""))]
[Db/pgSql!(dbName:string, address:string, user:string, password:string) : Database -> initFirstQuery(dbConnect(PgSqlDatabase(), dbName, address, user, password))]

[Db/connect!(driver:{"Postgresql"},host:string,dbname:string,login:string,pass:string) : Database
-> pgSql!(dbname,host,login,pass)]
