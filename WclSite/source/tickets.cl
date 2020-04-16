//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* tickets.wcl                                                         *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2008-06-20 11:08:30 +0200 (Ven 20 jui 2008) $
//*	$Revision: 1975 $
//*********************************************************************


// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: *                                                       *
// *********************************************************************


t_user 	:: Dbo/dbProperty()
t_org 	:: Dbo/dbProperty()
t_group 	:: Dbo/dbProperty()
t_validity? 	:: Dbo/dbProperty()
t_validity_start 	:: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_TIMESTAMP)
t_validity_end 	:: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_TIMESTAMP)
t_class 	:: Dbo/dbProperty()
t_key 	:: Dbo/dbProperty()
t_str 	:: Dbo/dbProperty()
t_int 	:: Dbo/dbProperty()
t_created  	:: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_TIMESTAMP)
t_info 	:: Dbo/dbProperty()

ticket <: ephemeral_object(
				dbId:integer, 
				t_user:WebUser,
				t_org:WebOrganization,
				t_group:WebUserGroup,
				t_created:float,
				t_validity?:boolean,
				t_validity_start:float,
				t_validity_end:float,
				t_class:string,
				t_key:string,
				t_str:string,
				t_int:integer,
				t_info:string)

[Dbo/dbStore?(self:{ticket}) : boolean -> true]


// ---------------------  DATABASE INTEGRATION  --------------------



[check_ticket?(self:WebUser, tclass:string, t_key:string, value:string) : boolean
->	let db := USER_DATABASE in (
	Db/printInQuery(db),
	?>SELECT COUNT(<?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(dbId) ?>) FROM  <?= Dbo/dbName(ticket) ?>, <?= Dbo/dbName(WebUser) ?>
WHERE <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_validity?) ?> = 1 
AND (<?= Dbo/dbName(WebUser) ?>.<?= Dbo/dbName(dbId) ?> = <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_user) ?>
OR <?= Dbo/dbName(WebUser) ?>.<?= Dbo/dbName(usrGroup) ?> = <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_group) ?>
OR <?= Dbo/dbName(WebUser) ?>.<?= Dbo/dbName(usrOrganization) ?> = <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_org) ?>)
AND	NOW() BETWEEN  <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_validity_start) ?> AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_validity_end) ?>
AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_class) ?> = <? (Dbo/dbPrint(db,tclass)) ?>
AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_key) ?> = <? (Dbo/dbPrint(db,t_key)) ?>
AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_str) ?> = <? (Dbo/dbPrint(db,value)) ?>; <? ,
	Db/endOfQuery(db),
(integer!(Db/row(db)[1]) > 0))]

[check_ticket?(self:WebUser, tclass:string, t_key:string, value:integer) : boolean
->	let db := USER_DATABASE in (
	Db/printInQuery(db),
	?>SELECT COUNT(<?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(dbId) ?>) FROM  <?= Dbo/dbName(ticket) ?>, <?= Dbo/dbName(WebUser) ?>
WHERE <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_validity?) ?> = 1 
AND (<?= Dbo/dbName(WebUser) ?>.<?= Dbo/dbName(dbId) ?> = <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_user) ?>
OR <?= Dbo/dbName(WebUser) ?>.<?= Dbo/dbName(usrGroup) ?> = <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_group) ?>
OR <?= Dbo/dbName(WebUser) ?>.<?= Dbo/dbName(usrOrganization) ?> = <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_org) ?>)
AND	NOW() BETWEEN  <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_validity_start) ?> AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_validity_end) ?>
AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_class) ?> = <? (Dbo/dbPrint(db,tclass)) ?>
AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_key) ?> = <? (Dbo/dbPrint(db,t_key)) ?>
AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_int) ?> = <? (Dbo/dbPrint(db,value)) ?>; <? ,
	Db/endOfQuery(db),
	(integer!(Db/row(db)[1]) > 0))]


[get_ticket_strval(self:WebUser, tclass:string, t_key:string) : (string U {unknown}) 
->	let db := USER_DATABASE in (
	Db/printInQuery(db),
	?>SELECT <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_str) ?> FROM  <?= Dbo/dbName(ticket) ?>, <?= Dbo/dbName(WebUser) ?>
WHERE <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_validity?) ?> = 1 
AND (<?= Dbo/dbName(WebUser) ?>.<?= Dbo/dbName(dbId) ?> = <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_user) ?>
OR <?= Dbo/dbName(WebUser) ?>.<?= Dbo/dbName(usrGroup) ?> = <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_group) ?>
OR <?= Dbo/dbName(WebUser) ?>.<?= Dbo/dbName(usrOrganization) ?> = <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_org) ?>)
AND	NOW() BETWEEN  <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_validity_start) ?> AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_validity_end) ?>
AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_class) ?> = <? (Dbo/dbPrint(db,tclass)) ?>
AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_key) ?> = <? (Dbo/dbPrint(db,t_key)) ?>
ORDER BY <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_created) ?> DESC
LIMIT 1; <? ,
	Db/endOfQuery(db),
	when r := Db/row(db) in r[1] else unknown)] 

	

[get_ticket_intval(self:WebUser, tclass:string, t_key:string) : (integer U {unknown}) 
->	let db := USER_DATABASE in (
	Db/printInQuery(db),
	?>SELECT <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_int) ?> FROM  <?= Dbo/dbName(ticket) ?>, <?= Dbo/dbName(WebUser) ?>
WHERE <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_validity?) ?> = 1 
AND (<?= Dbo/dbName(WebUser) ?>.<?= Dbo/dbName(dbId) ?> = <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_user) ?>
OR <?= Dbo/dbName(WebUser) ?>.<?= Dbo/dbName(usrGroup) ?> = <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_group) ?>
OR <?= Dbo/dbName(WebUser) ?>.<?= Dbo/dbName(usrOrganization) ?> = <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_org) ?>)
AND	NOW() BETWEEN  <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_validity_start) ?> AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_validity_end) ?>
AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_class) ?> = <? (Dbo/dbPrint(db,tclass)) ?>
AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_key) ?> = <? (Dbo/dbPrint(db,t_key)) ?>
ORDER BY <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_created) ?> DESC
LIMIT 1; <? ,
	Db/endOfQuery(db),
	when r := Db/row(db) in integer!(r[1]) else unknown)] 


[get_ticket_intvals(tclass:string, t_key:string) : list[integer] -> when u := get_user() in get_ticket_intvals(u,tclass, t_key) else list()]

[get_ticket_intvals(self:WebUser, tclass:string, tkey:string) : list[integer]
->	let db := USER_DATABASE,
		res := list<integer>()
	in (
	Db/printInQuery(db),
	?>SELECT <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_int) ?> FROM  <?= Dbo/dbName(ticket) ?>, <?= Dbo/dbName(WebUser) ?>, <?= Dbo/dbName(WebUserGroupLink) ?> 
WHERE <?= Dbo/dbName(t_validity?,ticket) ?> = 1 
AND <?= Dbo/dbName(dbId,WebUser) ?> = <?= Dbo/getDbId(self) ?>
AND <?= Dbo/dbName(link_user,WebUserGroupLink) ?> = <?= Dbo/dbName(dbId,WebUser) ?>
AND (<?= Dbo/dbName(dbId,WebUser) ?> = <?= Dbo/dbName(t_user,ticket) ?>
	OR <?= Dbo/dbName(usrGroup,WebUser) ?> = <?= Dbo/dbName(t_group,ticket) ?>
	OR <?= Dbo/dbName(link_group,WebUserGroupLink) ?> = <?= Dbo/dbName(t_group,ticket) ?>
	OR <?= Dbo/dbName(usrOrganization,WebUser) ?> = <?= Dbo/dbName(t_org,ticket) ?>)
AND	NOW() BETWEEN  <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_validity_start) ?> AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_validity_end) ?>
AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_class) ?> = <? (Dbo/dbPrint(db,tclass)) ?>
AND <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_key) ?> = <? (Dbo/dbPrint(db,tkey)) ?>
ORDER BY <?= Dbo/dbName(ticket) ?>.<?= Dbo/dbName(t_created) ?> DESC ; <? ,
	Db/endOfQuery(db),
	while (Db/fetch(db))
		let r := Db/row(db) in (res :add integer!(r[1]), true),
	res)] 



[get_tickets(tclass:string,tkey:string) : list[ticket]
->	Dbo/dbLoad(USER_DATABASE,ticket,nil,list(tuple(t_class,tclass),tuple(t_key,tkey)))]

[get_tickets(tclass:string,tkey:string,ival:integer) : list[ticket]
->	Dbo/dbLoad(USER_DATABASE,ticket,nil,list(tuple(t_class,tclass),tuple(t_key,tkey),tuple(t_int,ival)))]

[set_group_ticket(group_id:integer,tclass:string,tkey:string,ival:integer,info:string) : ticket
->	let t := ticket(t_group = WebUserGroup(dbId = group_id),
				t_created = now(),
				t_validity? = true,
				t_validity_start = now(),
				t_validity_end = date_add(now(),'y',10),
				t_class = tclass,
				t_key = tkey,
				t_int = ival,
				t_info = info) in (Dbo/dbCreate(USER_DATABASE,t),t)]

// ---------------------  MODELS  --------------------


ticket_model <: ephemeral_object(
		t_class:string,
		t_key:string,
		t_str:string,
		t_int:integer)

[get_ticket_models(self:WebApp) : list[ticket_model]
-> list<ticket_model>()]

(abstract(get_ticket_models))

[get_ticket_model_values(self:ticket_model,prop:{t_class,t_key,t_str,t_int}) : list[string U integer]
->	list()]

(abstract(get_ticket_model_values))

[get_ticket_model_strvalues(self:ticket_model) : list[string]
-> list<string>()]

(abstract(get_ticket_model_strvalues))


[get_ticket_model_intvalues(self:ticket_model) : list[integer]
-> list<integer>()]

(abstract(get_ticket_model_intvalues))

[delete_ticket(i:integer) : void -> Dbo/dbDelete(USER_DATABASE,ticket,i)]


