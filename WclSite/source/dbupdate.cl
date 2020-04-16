//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* dbupdate.cl                                                        *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2014-07-10 15:12:30 +0200 (Jeu 10 jul 2014) $
//*	$Revision: 2133 $
//*********************************************************************


// *********************************************************************
// *  Table of contents                                                *
// *   Part 0: todo callback pour maj auto                             *
// *   Part 1: Création de WebUserGroup                                *
// *   Part 20: Ajout de WebUserGroupLink                              *
// *   Part 21: Ajout de WebUser::usrLocale                            *
// *   Part 22: Ajout de WebUserGroup::groupAbstract?                  *
// *   Part 23: Ajout de WebOrganization::oGroup                       *
// *   Part 24: Création des groupes abstraits représentant les société*
// *   Part 25: MAJ du champ groupAbstract? pour les groupes existants *
// *********************************************************************


// *********************************************************************
// *   Part 0: todo callback pour maj auto                             *
// *********************************************************************
/*
[get_dbupdate_keys(self:WebApp) : list[string] -> list()]

(abstract(get_dbupdate_keys))
*/
// *********************************************************************
// *   Part 1: Création de WebUserGroup                                *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{1}) : void
->	if not(Dbo/check_table_exists(db,WebUserGroup))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
CREATE TABLE t_WclSite_WebUserGroup (
	id serial PRIMARY KEY,
	WclSite_groupTitle varchar(200) default NULL
);
<? ),	{Db/MYSQL} ( ?>
CREATE TABLE t_WclSite_WebUserGroup (
	id int(11) NOT NULL auto_increment,
	WclSite_groupTitle varchar(200) default NULL,
	PRIMARY KEY	(id)
) TYPE=MyISAM;
<? )),	Db/endOfQuery(db))]

// *********************************************************************
// *   Part 2: Création de WebOrganization                             *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{2}) : void
->	if not(Dbo/check_table_exists(db,WebOrganization))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
CREATE TABLE t_WclSite_WebOrganization (
	id serial PRIMARY KEY,
	WclSite_oName varchar(255) NOT NULL default '',
	WclSite_oIsdn varchar(255) default NULL,
	WclSite_oAdresses bytea,
	WclSite_oBillingAdress varchar(255) default NULL,
	WclSite_oCommandAdress varchar(255) default NULL,
	WclSite_oPhones bytea,
	WclSite_oFaxes bytea,
	WclSite_oWeb varchar(255) default NULL,
	WclSite_oBillingEmail varchar(255) default NULL,
	WclSite_oBillingUrl varchar(255) default NULL,
	WclSite_oCommandEmail varchar(255) default NULL,
	WclSite_oCommandUrl varchar(255) default NULL,
	WclSite_oCountry char(2) default 'FR',
	WclSite_oCurrency char(3) default 'EUR',
	UNIQUE (WclSite_oName)
);
<? ),	{Db/MYSQL} ( ?>
CREATE TABLE t_WclSite_WebOrganization (
	id int(11) NOT NULL auto_increment,
	WclSite_oName varchar(255) NOT NULL default '',
	WclSite_oIsdn varchar(255) default NULL,
	WclSite_oAdresses blob,
	WclSite_oBillingAdress varchar(255) default NULL,
	WclSite_oCommandAdress varchar(255) default NULL,
	WclSite_oPhones blob,
	WclSite_oFaxes blob,
	WclSite_oWeb varchar(255) default NULL,
	WclSite_oBillingEmail varchar(255) default NULL,
	WclSite_oBillingUrl varchar(255) default NULL,
	WclSite_oCommandEmail varchar(255) default NULL,
	WclSite_oCommandUrl varchar(255) default NULL,
	WclSite_oCountry char(2) default 'FR',
	PRIMARY KEY	(id),
	UNIQUE KEY WclSite_oName (WclSite_oName)
) TYPE=MyISAM;
<? )),	Db/endOfQuery(db))]

// *********************************************************************
// *   Part 3: Création de WebUser                                     *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{3}) : void
->	if not(Dbo/check_table_exists(db,WebUser))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
CREATE TABLE t_WclSite_WebUser (
	id serial PRIMARY KEY,
	WclSite_usrLogin varchar(200) default NULL,
	WclSite_usrPassword varchar(200) default NULL,
	<?= Dbo/dbName(usrSecurePassword) ?> VARCHAR(32),
	WclSite_usrFullName varchar(200) default NULL,
	WclSite_usrGroup integer REFERENCES t_WclSite_WebUserGroup (id) DEFERRABLE,
	WclSite_usrLastLogin timestamp default NULL,
	WclSite_usrLoginAttemp integer default NULL,
	WclSite_usrLocked integer default 0,
	WclSite_usrLockedInfo varchar(200) default NULL,
	WclSite_usrLanguage integer default NULL,
	WclSite_usrSuperUser_ask integer default NULL,
	WclSite_usrMail varchar(255) default NULL,
	WclSite_usrTitle varchar(10) default '',
	WclSite_usrFunction varchar(255) NOT NULL default '',
	WclSite_usrOrganization integer REFERENCES t_WclSite_WebOrganization (id) DEFERRABLE,
	WclSite_usrPrivateKey bytea,
	WclSite_usrCertificate bytea,
	WclSite_usrPhones bytea,
	WclSite_usrFaxes bytea,
	WclSite_usrAdresses bytea,
	WclSite_usrWeb varchar(100) NOT NULL default '',
	WclSite_usrDefaultApp varchar(100),
	WclSite_usrLocale char(2) default 'FR'
);
<? ),	{Db/MYSQL} ( ?>
CREATE TABLE t_WclSite_WebUser (
	id int(11) NOT NULL auto_increment,
	WclSite_usrLogin varchar(200) default NULL,
	WclSite_usrPassword varchar(200) default NULL,
	<?= Dbo/dbName(usrSecurePassword) ?> VARCHAR(32),
	WclSite_usrFullName varchar(200) default NULL,
	WclSite_usrGroup int(11) default NULL,
	WclSite_usrLastLogin datetime default NULL,
	WclSite_usrLoginAttemp int(11) default NULL,
	WclSite_usrLocked int(11) default 0,
	WclSite_usrLockedInfo varchar(200) default NULL,
	WclSite_usrLanguage int(11) default NULL,
	WclSite_usrSuperUser_ask int(11) default NULL,
	WclSite_usrMail varchar(255) default NULL,
	WclSite_usrTitle varchar(10) default '',
	WclSite_usrFunction varchar(255) NOT NULL default '',
	WclSite_usrOrganization int(11) default NULL,
	WclSite_usrPrivateKey blob,
	WclSite_usrCertificate blob,
	WclSite_usrPhones blob,
	WclSite_usrFaxes blob,
	WclSite_usrAdresses blob,
	WclSite_usrWeb varchar(100) NOT NULL default '',
	WclSite_usrDefaultApp varchar(100),
	WclSite_usrLocale char(2) default 'FR',
	PRIMARY KEY  (id)
) TYPE=MyISAM;
<? )),	Db/endOfQuery(db),
		let admin := WebUser(	usrFullName = "superadmin",
								usrLogin = "root",
								usrSuperUser? = true)
		in (//[0] creating default super admin user root/root,
			Dbo/dbCreate(db,admin,list(usrFullName,usrLogin,usrSuperUser?)),
			Dbo/dbUpdatePassword(db,admin,"root")))]


// *********************************************************************
// *   Part 4: Création de MenuGroupPermission                         *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{4}) : void
->	if not(Dbo/check_table_exists(db,MenuGroupPermission))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
CREATE TABLE t_WclSite_MenuGroupPermission (
	id serial PRIMARY KEY,
	WclSite_permGroup integer default NULL,
	WclSite_permMenu varchar(200) default NULL,
	WclSite_permRead integer default NULL,
	WclSite_permModify integer default NULL,
	WclSite_permDelete integer default NULL,
	WclSite_permCreate integer default NULL,
	WclSite_permSite varchar(255) default NULL
);<? ),	{Db/MYSQL} ( ?>
CREATE TABLE t_WclSite_MenuGroupPermission (
	id int(11) NOT NULL auto_increment,
	WclSite_permGroup int(11) default NULL,
	WclSite_permMenu varchar(200) default NULL,
	WclSite_permRead int(11) default NULL,
	WclSite_permModify int(11) default NULL,
	WclSite_permDelete int(11) default NULL,
	WclSite_permCreate int(11) default NULL,
	WclSite_permSite varchar(255) default NULL,
	PRIMARY KEY	(id),
	INDEX (id)
) TYPE=MyISAM;
<? )),	Db/endOfQuery(db))]

// *********************************************************************
// *   Part 5: Création de WebCurrency                                 *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{5}) : void
->	if not(Dbo/check_table_exists(db,WebCurrency))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
CREATE TABLE t_WclSite_WebCurrency (
	id serial PRIMARY KEY,
	WclSite_curIsoCode char(3) NOT NULL default 'XXX',
	WclSite_curEuroParity float8 NOT NULL default 1,
	WclSite_curSymbol varchar(20) default NULL,
	WclSite_curName varchar(255) default NULL,
	UNIQUE (WclSite_curIsoCode)
);
<? ),	{Db/MYSQL} ( ?>
CREATE TABLE t_WclSite_WebCurrency (
	id int(11) NOT NULL auto_increment,
	WclSite_curIsoCode char(3) NOT NULL default 'XXX',
	WclSite_curEuroParity double NOT NULL default '1',
	WclSite_curSymbol varchar(20) default NULL,
	WclSite_curName varchar(255) default NULL,
	PRIMARY KEY (id)
) TYPE=MyISAM;
<? )),	Db/endOfQuery(db))]

// *********************************************************************
// *   Part 6: Création de WebOption                                   *
// *********************************************************************
[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{6}) : void
->	if not(Dbo/check_table_exists(db,WebOption))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
CREATE TABLE t_WclSite_WebOption (
	id serial PRIMARY KEY,
	WclSite_optCategorie varchar(200) default NULL,
	WclSite_optName varchar(200) default NULL,
	WclSite_optValue bytea,
	UNIQUE (WclSite_optCategorie,WclSite_optName)
);
<? ),	{Db/MYSQL} ( ?>
CREATE TABLE t_WclSite_WebOption (
	id int(11) NOT NULL auto_increment,
	WclSite_optCategorie varchar(200) default NULL,
	WclSite_optName varchar(200) default NULL,
	WclSite_optValue longblob,
	PRIMARY KEY  (id)
) TYPE=MyISAM;
<? )),	Db/endOfQuery(db))]

// *********************************************************************
// *   Part 7: Ajout de WebUser::usrSessionId                          *
// *********************************************************************
[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{7}) : void
->	none]
/*	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD COLUMN <?= Dbo/dbName(usrSessionId) ?> varchar(26);
<? ),	{Db/MYSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD <?= Dbo/dbName(usrSessionId) ?> varchar(26); <? )),
	Db/endOfQuery(db))] */

// *********************************************************************
// *   Part 8: Ajout de WebUser::usrSessionDate                        *
// *********************************************************************
[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{8}) : void
-> none]
/* (Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD COLUMN <?= Dbo/dbName(usrSessionDate) ?>	TIMESTAMP;
<? ),	{Db/MYSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD <?= Dbo/dbName(usrSessionDate) ?> DATETIME; <? )),
	Db/endOfQuery(db))] */


// *********************************************************************
// *   Part 9: Ajout de WebUser::usrSessionLastUrl                     *
// *********************************************************************
[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{9}) : void
->	none]
 /* (Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD COLUMN <?= Dbo/dbName(usrSessionLastUrl) ?>	varchar(255);
<? ),	{Db/MYSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD <?= Dbo/dbName(usrSessionLastUrl) ?>	varchar(255); <? )),
	Db/endOfQuery(db))] */

// *********************************************************************
// *   Part 10: Ajout de WebUser::usrLockedKey                         *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{10}) : void
->	if not(Dbo/check_column_exists(db,WebUser,usrLockedKey))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD COLUMN <?= Dbo/dbName(usrLockedKey) ?> varchar(26);
<? ),	{Db/MYSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD <?= Dbo/dbName(usrLockedKey) ?> varchar(26); <? )),
	Db/endOfQuery(db))]

// *********************************************************************
// *   Part 11: Maj de WebUser:: usrPhones,usrFaxes,usrAdresses        *
// *********************************************************************

[private/db_need_usrPhones(db:Db/Database) : void
->	if not(Dbo/check_column_exists(db,WebUser,usrPhones))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD COLUMN <?= Dbo/dbName(usrPhones) ?> bytea;
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD COLUMN <?= Dbo/dbName(usrFaxes) ?> bytea;
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD COLUMN <?= Dbo/dbName(usrAdresses) ?> bytea;
<? ),	{Db/MYSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD <?= Dbo/dbName(usrPhones) ?> blob;<? , 
					Db/endOfQuery(db), Db/printInQuery(db), ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD <?= Dbo/dbName(usrFaxes) ?> blob;<? , 
					Db/endOfQuery(db), Db/printInQuery(db), ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD <?= Dbo/dbName(usrAdresses) ?> blob;
<? )), Db/endOfQuery(db))]


[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{11}) : void
->	db_need_usrPhones(db),
	for i in Dbo/dbLoad(db,WebUser,list(usrPhones,usrFaxes,usrAdresses))
		Dbo/dbUpdate(db,i,list(usrPhones,usrFaxes,usrAdresses))]

// *********************************************************************
// *   Part 12: Maj de WebOrganization:: oPhones,oFaxes,oAdresses      *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{12}) : void
->	for i in Dbo/dbLoad(db,WebOrganization,list(oPhones,oFaxes,oAdresses))
		Dbo/dbUpdate(db,i,list(oPhones,oFaxes,oAdresses))]

// *********************************************************************
// *   Part 13: Ajout de WebOrganization::oEmails                      *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{13}) : void
->	if not(Dbo/check_column_exists(db,WebOrganization,oEmails))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebOrganization) ?> ADD COLUMN <?= Dbo/dbName(oEmails) ?> bytea;
<? ),	{Db/MYSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebOrganization) ?> ADD <?= Dbo/dbName(oEmails) ?> blob;
<? )), Db/endOfQuery(db))]

// *********************************************************************
// *   Part 14: Ajout de WebUser::usrSecurePassword                    *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{14}) : void
->	if not(Dbo/check_column_exists(db,WebUser,usrSecurePassword))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD COLUMN <?= Dbo/dbName(usrSecurePassword) ?> VARCHAR(32);
<? ),	{Db/MYSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD  <?= Dbo/dbName(usrSecurePassword) ?> VARCHAR(32);
<? )), Db/endOfQuery(db))]

// *********************************************************************
// *   Part 15: Maj de WebUser::usrSecurePassword                      *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{15}) : void
->	if Dbo/check_column_exists(db,WebUser,usrPassword)
	for i in Dbo/dbLoad(db, WebUser,list(usrPassword))
	 	(if (known?(usrPassword,i) & i.usrPassword != "") Dbo/dbUpdatePassword(db,i,i.usrPassword))]

// *********************************************************************
// *   Part 16: Création de user_session                               *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{16}) : void
->	if not(Dbo/check_table_exists(db,user_session))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
CREATE TABLE <?=  Dbo/dbName(user_session) ?> (
	<?= Dbo/dbName(dbId) ?> serial primary key,
	<?= Dbo/dbName(sess_id) ?> char(32),
	<?= Dbo/dbName(sess_user) ?> integer REFERENCES <?= Dbo/dbName(WebUser) ?> (<?= Dbo/dbName(dbId) ?>) ON DELETE CASCADE DEFERRABLE,
	<?= Dbo/dbName(sess_ip) ?> varchar(40),
	<?= Dbo/dbName(sess_url) ?> varchar(255),
	<?= Dbo/dbName(sess_active?) ?> integer,
	<?= Dbo/dbName(sess_created) ?> timestamp,
	<?= Dbo/dbName(sess_accessed) ?> timestamp,
	<?= Dbo/dbName(sess_closed) ?> timestamp
	);
<? ),	{Db/MYSQL} ( ?>
CREATE TABLE <?=  Dbo/dbName(user_session) ?> (
	<?= Dbo/dbName(dbId) ?> int(11) auto_increment primary key,
	<?= Dbo/dbName(sess_id) ?> char(32),
	<?= Dbo/dbName(sess_user) ?> integer,
	<?= Dbo/dbName(sess_ip) ?> varchar(40),
	<?= Dbo/dbName(sess_url) ?> varchar(255),
	<?= Dbo/dbName(sess_active?) ?> integer,
	<?= Dbo/dbName(sess_created) ?> datetime,
	<?= Dbo/dbName(sess_accessed) ?> datetime,
	<?= Dbo/dbName(sess_closed) ?> datetime
);
<? )), Db/endOfQuery(db))]

// *********************************************************************
// *   Part 17: Ajout de WebUser::usrMultipleLogin                     *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{17}) : void
->	if not(Dbo/check_column_exists(db,WebUser,usrMultipleLogin))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD COLUMN <?= Dbo/dbName(usrMultipleLogin) ?> integer;
UPDATE <?= Dbo/dbName(WebUser) ?> SET <?= Dbo/dbName(usrMultipleLogin) ?>  = 0;
<? ),	{Db/MYSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD <?= Dbo/dbName(usrMultipleLogin) ?> int default 0;
<? )), Db/endOfQuery(db))]

// *********************************************************************
// *   Part 18: Ajout de user_session::sess_locale                     *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{18}) : void
->	if not(Dbo/check_column_exists(db,user_session,sess_locale))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(user_session) ?> ADD COLUMN <?= Dbo/dbName(sess_locale) ?> char(2);
<? ),	{Db/MYSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(user_session) ?> ADD <?= Dbo/dbName(sess_locale) ?> char(2);
<? )), Db/endOfQuery(db))]

// *********************************************************************
// *   Part 19: Ajout de ticket                                        *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{19}) : void
->	if not(Dbo/check_table_exists(db,ticket))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
CREATE TABLE <?=  Dbo/dbName(ticket) ?> (
	<?= Dbo/dbName(dbId) ?> serial primary key,
	<?= Dbo/dbName(t_user) ?> integer NULL REFERENCES <?= Dbo/dbName(WebUser) ?> (<?= Dbo/dbName(dbId) ?>) ON DELETE CASCADE DEFERRABLE,
	<?= Dbo/dbName(t_org) ?> integer NULL REFERENCES <?= Dbo/dbName(WebOrganization) ?> (<?= Dbo/dbName(dbId) ?>) ON DELETE CASCADE DEFERRABLE,
	<?= Dbo/dbName(t_group) ?> integer NULL REFERENCES <?= Dbo/dbName(WebUserGroup) ?> (<?= Dbo/dbName(dbId) ?>) ON DELETE CASCADE DEFERRABLE,
	<?= Dbo/dbName(t_created) ?> timestamp,
	<?= Dbo/dbName(t_validity?) ?> integer,
	<?= Dbo/dbName(t_validity_start) ?> timestamp,
	<?= Dbo/dbName(t_validity_end) ?> timestamp,
	<?= Dbo/dbName(t_class) ?> varchar(255),
	<?= Dbo/dbName(t_key) ?> varchar(255),
	<?= Dbo/dbName(t_str) ?> varchar(255),
	<?= Dbo/dbName(t_int) ?> integer
);
<? ),	{Db/MYSQL} ( ?>
CREATE TABLE <?=  Dbo/dbName(ticket) ?> (
	<?= Dbo/dbName(dbId) ?>  int(11) auto_increment primary key,
	<?= Dbo/dbName(t_user) ?> integer,
	<?= Dbo/dbName(t_org) ?> integer,
	<?= Dbo/dbName(t_group) ?> integer,
	<?= Dbo/dbName(t_created) ?> datetime,
	<?= Dbo/dbName(t_validity?) ?> int,
	<?= Dbo/dbName(t_validity_start) ?> datetime,
	<?= Dbo/dbName(t_validity_end) ?> datetime,
	<?= Dbo/dbName(t_class) ?> varchar(255),
	<?= Dbo/dbName(t_key) ?> varchar(255),
	<?= Dbo/dbName(t_str) ?> varchar(255),
	<?= Dbo/dbName(t_int) ?> int
	);
<? )), Db/endOfQuery(db))]

// *********************************************************************
// *   Part 20: Ajout de WebUserGroupLink                              *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{20}) : void
->	if not(Dbo/check_table_exists(db,WebUserGroupLink))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
CREATE TABLE <?=  Dbo/dbName(WebUserGroupLink) ?> (
	<?= Dbo/dbName(dbId) ?> serial primary key,
	<?= Dbo/dbName(link_user) ?> integer NOT NULL REFERENCES <?= Dbo/dbName(WebUser) ?> (<?= Dbo/dbName(dbId) ?>) ON DELETE CASCADE DEFERRABLE,
	<?= Dbo/dbName(link_group) ?> integer NOT NULL REFERENCES <?= Dbo/dbName(WebUserGroup) ?> (<?= Dbo/dbName(dbId) ?>) ON DELETE CASCADE DEFERRABLE,
	UNIQUE (<?= Dbo/dbName(link_user) ?>, <?= Dbo/dbName(link_group) ?>)
);
<? ),	{Db/MYSQL} ( ?>
CREATE TABLE IF NOT EXISTS <?=  Dbo/dbName(WebUserGroupLink) ?> (
	<?= Dbo/dbName(dbId) ?> int(11) auto_increment PRIMARY KEY,
	<?= Dbo/dbName(link_user) ?> int(11),
	<?= Dbo/dbName(link_group) ?> int(11),
	INDEX (<?= Dbo/dbName(link_user) ?>),
	INDEX (<?= Dbo/dbName(link_group) ?>),
	UNIQUE (<?= Dbo/dbName(link_user) ?>, <?= Dbo/dbName(link_group) ?>)
);
<? )), Db/endOfQuery(db))]

// *********************************************************************
// *   Part 21: Ajout de WebUser::usrLocale                            *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{21}) : void
->	if not(Dbo/check_column_exists(db,WebUser,usrLocale)) (
		Db/printInQuery(db),
		case db.Db/driverType (
			{Db/PGSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD COLUMN <?= Dbo/dbName(usrLocale) ?> char(2);
ALTER TABLE  <?= Dbo/dbName(WebUser) ?> ALTER COLUMN <?= Dbo/dbName(usrLocale) ?> SET DEFAULT 'FR';
<? ),		{Db/MYSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD <?= Dbo/dbName(usrLocale) ?> char(2) default 'FR';
<? )), Db/endOfQuery(db))]



// *********************************************************************
// *   Part 22: Ajout de WebUserGroup::groupAbstract?                  *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{22}) : void
->	if not(Dbo/check_column_exists(db,WebUserGroup,groupAbstract?)) (
		Db/printInQuery(db),
		case db.Db/driverType (
			{Db/PGSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUserGroup) ?> ADD COLUMN <?= Dbo/dbName(groupAbstract?) ?> integer;
ALTER TABLE  <?= Dbo/dbName(WebUserGroup) ?> ALTER COLUMN <?= Dbo/dbName(groupAbstract?) ?> SET DEFAULT 0;
<? ),		{Db/MYSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUserGroup) ?> ADD <?= Dbo/dbName(groupAbstract?) ?> int(11) default 0;
<? )), Db/endOfQuery(db))]


// *********************************************************************
// *   Part 23: Ajout de WebOrganization::oGroup                       *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{23}) : void
->	if not(Dbo/check_column_exists(db,WebOrganization,oGroup)) (
		Db/printInQuery(db),
		case db.Db/driverType (
			{Db/PGSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebOrganization) ?> ADD COLUMN <?= Dbo/dbName(oGroup) ?> integer REFERENCES <?= Dbo/dbName(WebUserGroup) ?> (<?= Dbo/dbName(dbId) ?>) DEFERRABLE;
<? ),		{Db/MYSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebOrganization) ?> ADD <?= Dbo/dbName(oGroup) ?> int(11) default 0;
<? )), Db/endOfQuery(db))]

// *********************************************************************
// *   Part 24: Création des groupes abstraits représentant les société*
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{24}) : void
->	for o in Dbo/dbLoad(db,WebOrganization) (
		let gr := WebUserGroup(groupAbstract? = true, groupTitle = o.oName)
		in (Dbo/dbCreate(db,gr),
			o.oGroup := gr,
			Dbo/dbUpdate(db,o,list(oGroup)),
			for u in get_users(o)
				Dbo/dbCreate(db,WebUserGroupLink(link_user = u, link_group = gr))))]

// *********************************************************************
// *   Part 25: MAJ du champ groupAbstract? pour les groupes existants *
// *********************************************************************
[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{25}) : void
->	if not(Dbo/check_column_exists(db,WebOrganization,oGroup)) (
		Db/printInQuery(db), ?>
UPDATE <?= Dbo/dbName(WebUserGroup) ?> 
SET <?= Dbo/dbName(groupAbstract?) ?> = 0
WHERE <?= Dbo/dbName(groupAbstract?) ?> IS NULL; <? ,
	Db/endOfQuery(db))]


// *********************************************************************
// *   Part 26: MAJ des groupes utilisateurs                           *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{26}) : void
->	for u in Dbo/dbLoad(db,WebUser,list(dbId,usrGroup)) (
		if (known?(usrGroup,u) & (Dbo/dbCount(db,WebUserGroupLink,list(tuple(link_user,u), tuple(link_group , u.usrGroup))) = 0))  
			(Dbo/dbCreate(db,WebUserGroupLink(link_user = u, link_group = u.usrGroup))))]

// *********************************************************************
// *   Part 27: Ajout WebUser::usrTimeZone                             *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{27}) : void
->	if not(Dbo/check_column_exists(db,WebUser,usrTimeZone)) (
		Db/printInQuery(db),
		case db.Db/driverType (
			{Db/PGSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD COLUMN <?= Dbo/dbName(usrTimeZone) ?> varchar(20);
ALTER TABLE  <?= Dbo/dbName(WebUser) ?> ALTER COLUMN <?= Dbo/dbName(usrTimeZone) ?> SET DEFAULT 'CET';
<? ),		{Db/MYSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD <?= Dbo/dbName(usrTimeZone) ?> varchar(20) default 'CET';
<? )), Db/endOfQuery(db))]


// *********************************************************************
// *   Part 28: Ajout WebCertificate                                   *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{28}) : void
->	if not(Dbo/check_table_exists(db,WebCertificate))
	(Db/printInQuery(db),
	case db.Db/driverType (
		{Db/PGSQL} ( ?>
CREATE TABLE <?=  Dbo/dbName(WebCertificate) ?> (
	<?= Dbo/dbName(dbId) ?> serial primary key,
	<?= Dbo/dbName(cUsage) ?> integer,
	<?= Dbo/dbName(cX509) ?> bytea,
	<?= Dbo/dbName(cPrivateKey) ?> bytea,
	<?= Dbo/dbName(cOrganization) ?> integer NULL REFERENCES <?= Dbo/dbName(WebOrganization) ?> (<?= Dbo/dbName(dbId) ?>) ON DELETE CASCADE DEFERRABLE,
	<?= Dbo/dbName(cUser) ?> integer NULL REFERENCES <?= Dbo/dbName(WebUser) ?> (<?= Dbo/dbName(dbId) ?>) ON DELETE CASCADE DEFERRABLE
);
<? ),	{Db/MYSQL} ( ?>
CREATE TABLE <?=  Dbo/dbName(WebCertificate) ?> (
	<?= Dbo/dbName(dbId) ?>  int(11) auto_increment primary key,
	<?= Dbo/dbName(cUsage) ?> integer,
	<?= Dbo/dbName(cX509) ?> longblob,
	<?= Dbo/dbName(cPrivateKey) ?> longblob,
	<?= Dbo/dbName(cOrganization) ?> integer,
	<?= Dbo/dbName(cUser) ?> integer
	);
<? )), Db/endOfQuery(db))]


// *********************************************************************
// *   Part 29: Ajout WebUser::usrSignature                            *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{29}) : void
->	if not(Dbo/check_column_exists(db,WebUser,usrSignature)) (
		Db/printInQuery(db),
		case db.Db/driverType (
			{Db/PGSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD COLUMN <?= Dbo/dbName(usrSignature) ?> varchar(200);
<? ),		{Db/MYSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(WebUser) ?> ADD <?= Dbo/dbName(usrSignature) ?> varchar(200);
<? )), Db/endOfQuery(db))]


// *********************************************************************
// *   Part 30: Ajout ticket::t_info	                               *
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{30}) : void
->	if not(Dbo/check_column_exists(db,ticket,t_info)) (
		Db/printInQuery(db),
		case db.Db/driverType (
			{Db/PGSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(ticket) ?> ADD COLUMN <?= Dbo/dbName(t_info) ?> varchar(200);
<? ),		{Db/MYSQL} ( ?>
ALTER TABLE <?= Dbo/dbName(ticket) ?> ADD <?= Dbo/dbName(t_info) ?> varchar(200);
<? )), Db/endOfQuery(db))]

// *********************************************************************
// *   Part 31: Support ipv6
// *********************************************************************

[db_update_model(db:Db/Database,cat:{"WCLSITE"},vers:{31}) : void
->	Db/printInQuery(db), ?>
ALTER TABLE <?= Dbo/dbName(user_session) ?> MODIFY <?= Dbo/dbName(sess_ip) ?> varchar(40); <? ,
	Db/endOfQuery(db)]
