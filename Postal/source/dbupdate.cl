//*********************************************************************
//* Postal                                          Xavier Pehoultres *
//* dbupdate.cl                                                       *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*********************************************************************

// *********************************************************************
// *   Part 1: Ajout de WebAdressBook                                  *
// *   Part 2: Ajout de WebAdress                                      *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{1}) : void
->	if not(Dbo/check_table_exists(db,WebAdressBook))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
CREATE TABLE <?= Dbo/dbName(WebAdressBook) ?> (
	<?= Dbo/dbName(dbid) ?> serial primary key,
	<?= Dbo/dbName(webuser) ?> integer NOT NULL REFERENCES <?= Dbo/dbName(WclSite/WebUser) ?> (<?= Dbo/dbName(WclSite/dbId) ?>) ON DELETE CASCADE DEFERRABLE,
	<?= Dbo/dbName(webgroup) ?> integer  REFERENCES <?= Dbo/dbName(WclSite/WebUserGroup) ?> (<?= Dbo/dbName(WclSite/dbId) ?>) ON DELETE CASCADE DEFERRABLE,
	<?= Dbo/dbName(created_date) ?> timestamp default NULL,
	<?= Dbo/dbName(ab_label) ?> varchar(200) default NULL);
<? ),	{Db/MYSQL} ( ?>
CREATE TABLE IF NOT EXISTS <?= Dbo/dbName(WebAdressBook) ?> (
	<?= Dbo/dbName(dbid) ?> int(11) auto_increment PRIMARY KEY,
	<?= Dbo/dbName(webuser) ?> int(11),
	<?= Dbo/dbName(webgroup) ?> int(11),
	<?= Dbo/dbName(created_date) ?> datetime default NULL,
	<?= Dbo/dbName(ab_label) ?> varchar(200) default NULL);
<? )), Db/endOfQuery(db))]


// *********************************************************************
// *   Part 23: Ajout de WebAdress                                     *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{2}) : void
->	if not(Dbo/check_table_exists(db,WebAdress))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
CREATE TABLE <?= Dbo/dbName(WebAdress) ?> (
	<?= Dbo/dbName(dbid) ?> serial primary key,
	<?= Dbo/dbName(adress_book) ?> integer NOT NULL REFERENCES <?= Dbo/dbName(WebAdressBook) ?> (<?= Dbo/dbName(dbid) ?>) ON DELETE CASCADE DEFERRABLE,
	<?= Dbo/dbName(created_date) ?> timestamp default NULL,
	<?= Dbo/dbName(updated_date) ?> timestamp default NULL,
	<?= Dbo/dbName(country_code) ?> varchar(10) default NULL,
	<?= Dbo/dbName(region_code) ?> varchar(10) default NULL,
	<?= Dbo/dbName(person_lastname) ?> varchar(200) default NULL,
	<?= Dbo/dbName(person_name) ?> varchar(200) default NULL,
	<?= Dbo/dbName(person_function) ?> varchar(200) default NULL,
	<?= Dbo/dbName(corp) ?> varchar(200) default NULL,
	<?= Dbo/dbName(road) ?> varchar(200) default NULL,
	<?= Dbo/dbName(building) ?> varchar(200) default NULL,
	<?= Dbo/dbName(azone) ?> varchar(200) default NULL,
	<?= Dbo/dbName(town) ?> varchar(200) default NULL,
	<?= Dbo/dbName(postal_code) ?> varchar(200) default NULL,
	<?= Dbo/dbName(box) ?> varchar(200) default NULL,
	<?= Dbo/dbName(post_office) ?> varchar(200) default NULL,
	<?= Dbo/dbName(phone) ?> varchar(200) default NULL,
	<?= Dbo/dbName(phone_mobile) ?> varchar(200) default NULL,
	<?= Dbo/dbName(fax) ?> varchar(200) default NULL,
	<?= Dbo/dbName(e_mail) ?> varchar(200) default NULL,
	<?= Dbo/dbName(flags) ?> integer default 0,
	<?= Dbo/dbName(addr_data) ?> varchar(255) default NULL);
<? ),	{Db/MYSQL} ( ?>
CREATE TABLE IF NOT EXISTS <?= Dbo/dbName(WebAdress) ?> (
	<?= Dbo/dbName(dbid) ?> int(11) auto_increment PRIMARY KEY,
	<?= Dbo/dbName(adress_book) ?> int(11),
	<?= Dbo/dbName(created_date) ?> datetime default NULL,
	<?= Dbo/dbName(updated_date) ?> datetime default NULL,
	<?= Dbo/dbName(country_code) ?> varchar(10) default NULL,
	<?= Dbo/dbName(region_code) ?> varchar(10) default NULL,
	<?= Dbo/dbName(person_lastname) ?> varchar(200) default NULL,
	<?= Dbo/dbName(person_name) ?> varchar(200) default NULL,
	<?= Dbo/dbName(person_function) ?> varchar(200) default NULL,
	<?= Dbo/dbName(corp) ?> varchar(200) default NULL,
	<?= Dbo/dbName(road) ?> varchar(200) default NULL,
	<?= Dbo/dbName(building) ?> varchar(200) default NULL,
	<?= Dbo/dbName(azone) ?> varchar(200) default NULL,
	<?= Dbo/dbName(town) ?> varchar(200) default NULL,
	<?= Dbo/dbName(box) ?> varchar(200) default NULL,
	<?= Dbo/dbName(post_office) ?> varchar(200) default NULL,
	<?= Dbo/dbName(postal_code) ?> varchar(200) default NULL,
	<?= Dbo/dbName(phone) ?> varchar(200) default NULL,
	<?= Dbo/dbName(phone_mobile) ?> varchar(200) default NULL,
	<?= Dbo/dbName(fax) ?> varchar(200) default NULL,
	<?= Dbo/dbName(e_mail) ?> varchar(200) default NULL,
	<?= Dbo/dbName(flags) ?> int(11) default 0,
	<?= Dbo/dbName(addr_data) ?> varchar(255) default NULL);
<? )), Db/endOfQuery(db))]

