//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* install_update.cl                                                 *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2010-05-04 13:29:00 +0200 (Mar 04 mai 2010) $
//*	$Revision: 2033 $
//*********************************************************************

// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: Callbacks                                               *
// *   Part 2: Update databases for each WebApp                        *
// *   Part 3: Create databases for each WebApp                        *
// *   Part 4: Command line options                                    *
// *   Part 5: dump functions                                          *
// *   Part 6: dump command line options                               *
// *********************************************************************

// *********************************************************************
// *   Part 1: Callbacks                                               *
// *********************************************************************

[db_create(self:WebApp) : void -> none]
(abstract(db_create))

[connect_databases(self:WebApp) : list[Db/Database] -> nil]
(abstract(connect_databases))

[get_dbupdate_keys(self:WebApp) : list[string] -> nil]
(abstract(get_dbupdate_keys))

[get_db2update(self:WebApp,key:string) : (Db/Database U {unknown})  -> unknown]
(abstract(get_db2update))

// *********************************************************************
// *   Part 2: Update databases for each WebApp                        *
// *********************************************************************

[dispatch_db_update() : void
->	for i in WebApp db_update(i)]

[db_update(self:WebApp) : void
->	//[-100] db_update(~S) // self,
	connect_databases(self),
	for i in get_dbupdate_keys(self)
	when db := get_db2update(self,i) in (
										//[-100] ****** updating ~S with key ~S ************ // db, i,
										Dbo/beginTransaction(db),
										Dbo/dispatch_updates(db,i),
										Dbo/commitTransaction(db),
										none)]

// *********************************************************************
// *   Part 3: Create databases for each WebApp                        *
// *********************************************************************

[dispatch_db_create() : void
->	for i in WebApp db_create(i)]

// *********************************************************************
// *   Part 4: Command line options                                    *
// *********************************************************************

[option_usage(opt:{"-dbtest"}) : tuple(string,string,string)
-> tuple("setting test mode","-dbtest","equivalent to setting WCLSITE_MODE_TEST env var")]

[option_respond(opt:{"-dbtest"},l:list) : void
->	setenv("WCLSITE_MODE_TEST=1")]

[option_usage(opt:{"-dbpgsql"}) : tuple(string,string,string)
-> tuple("setting PGSQL mode","-dbpgsql","equivalent to setting MODE_PGSQL env var")]

[option_respond(opt:{"-dbpgsql"},l:list) : void
->	setenv("MODE_PGSQL=1")]

[option_usage(opt:{"-dbprefix"}) : tuple(string,string,string)
-> tuple("setting DB_NAME_PREFIX mode","-dbprefix <prefix>","equivalent to setting DB_NAME_PREFIX env var")]

[option_respond(opt:{"-dbprefix"},l:list) : void
->	if not(l) invalid_option_argument(),
	setenv("DB_NAME_PREFIX=" /+ l[1]),
	l << 1]
	
[option_usage(opt:{"-dbauto"}) : tuple(string,string,string)
-> tuple("extract database name from server name","-dbauto <hostname>","extract database name from server name")]

[option_respond(opt:{"-dbauto"},l:list) : void
->	if not(l) invalid_option_argument(),
	setenv("AUTO_DB_NAME=1"),
	setenv("SERVER_NAME=" /+ l[1]),
	l << 1]

[option_usage(opt:{"-dbupdate"}) : tuple(string,string,string)
->	tuple(	"updating database",
			"-dbupdate",
			"Update databases of current WebApp")]

[option_respond(opt:{"-dbupdate"},l:list) : void
-> dispatch_db_update()]

[option_usage(opt:{"-dbcreate"}) : tuple(string,string,string)
->	tuple(	"creating database",
			"-dbcreate",
			"Create databases of currents WebApp and update them")]

[option_respond(opt:{"-dbcreate"},l:list) : void
->	dispatch_db_create(),
	dispatch_db_update()]


[option_usage(opt:{"-dbconnect"}) : tuple(string,string,string)
->	tuple(	"connecting databases",
			"-dbconnect",
			"Connect databases for each WebApp")]

[option_respond(opt:{"-dbconnect"},l:list) : void
-> for i in WebApp connect_databases(i)]

	
// *********************************************************************
// *   Part 5: dump functions                                          *
// *********************************************************************

DUMP_OUTPUT_CLASS:class := unknown

[dump_db(db:Db/Database,app:WebApp,out_target:class,out_path:string)  : void
->	connect_databases(app),
	let fname := out_path / strftime("%Y_%m_%d_%H_%M",now()) /+ "_" /+ Db/getDbName(db) /+ Db/getDbFileExt(db)
	in (Db/dump(db,fname,out_target,false,false,false))]

[dump_db(db:Db/Database,app:WebApp,out_path:string)  : void
->	if known?(DUMP_OUTPUT_CLASS)
		dump_db(db,app,DUMP_OUTPUT_CLASS, out_path)
	else dump_db(db,app,owner(db), out_path)]


[dump_webapp_db() : void
->	let outpath := (if isenv?("WCLSITE_BACKUP_PATH") getenv("WCLSITE_BACKUP_PATH") else ".")
	in	for app in WebApp
			for db in connect_databases(app)
				(dump_db(db,app,outpath))]

[dump_db(db:Db/Database) : void
->	let outpath := (if isenv?("WCLSITE_BACKUP_PATH") getenv("WCLSITE_BACKUP_PATH") else "."),
		fname := outpath / strftime("%Y_%m_%d_%H_%M",now()) /+ "_" /+ Db/getDbName(db) /+ Db/getDbFileExt(db)
	in (Db/dump(db,fname,owner(db),false,false,false),
		shell("gzip " /+ fname))]

// *********************************************************************
// *   Part 6: dump command line options                               *
// *********************************************************************
				
[option_usage(opt:{"-dbtarget"}) : tuple(string,string,string)
-> tuple("setting target database class","-dbtarget <target:class>","setting target class for dump ( Postgresql/pgDatabase or Mysql/MySqlDatabase ... )")]


[option_respond(opt:{"-dbtarget"},l:list) : void
->	if not(l) invalid_option_argument(),
	let i := explode(l[1],"/")
	in (if (length(i) = 1) (
			when c := get_value(i[1])
			in (if not(c % Db/Database) (//[0] -dbtarget : ~S not % Db/Database // i[1],
										invalid_option_argument()),
				DUMP_OUTPUT_CLASS := c)
			else (//[0] -dbtarget : class ~S is unknown // i[1],
				invalid_option_argument()))
		else (
			when mod := get_value(i[1])
			in (if not(mod % module) ( //[0] -dbtarget : ~S not a module // i[1],
										invalid_option_argument()),
				when c := get_value(mod,i[2])
				in (if not(c <= Db/Database) (//[0] -dbtarget : ~S not a Database // i[2],
											invalid_option_argument()),
					DUMP_OUTPUT_CLASS := c)
				else (//[0] -dbtarget : class ~S is unknown // i[2],
						invalid_option_argument()))
			else (//[0] -dbtarget : module ~S is unknown // i[1],
				invalid_option_argument()))),
		l << 1]

[option_respond(opt:{"-dbdump"},l:list) : void
-> dump_webapp_db()]

[option_respond(opt:{"-dbdump2"},l:list) : void
->	if not(l) invalid_option_argument(),
	setenv("WCLSITE_BACKUP_PATH=" /+ l[1]),
	l << 1,
	dump_webapp_db()]

[option_usage(opt:{"-dbdump","-dbdump2"}) : tuple(string,string,string)
->	tuple(	"dumping databases",
			"{ -dbdump | -dbdump2 <directory:path> }",
			"-dbdump export databases to path define on environ. var WCLSITE_BACKUP_PATH if is set or in current path")]


			

