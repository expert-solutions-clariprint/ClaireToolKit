//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* monnaie.wcl                                                       *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2010-09-21 16:01:26 +0200 (Mar 21 sep 2010) $
//*	$Revision: 2053 $
//*********************************************************************


// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: *                                                       *
// *********************************************************************



//---------------------------------------------------------------------------
//	O. PREDEFINITIONS
//---------------------------------------------------------------------------
WebUserGroup <: object
WebUser <: object
WebOrganization <: ephemeral_object

WebUserGroupLink <: object 


//---------------------------------------------------------------------------
//	O.	EXCEPTIONS
//---------------------------------------------------------------------------
WebUserError <: exception()

WebUserMaxAttempError <: WebUserError()
WebUserUnknownUser <: WebUserError()
WebUserBadPassword <: WebUserError()
WebUserLocked <: WebUserError()
WebUserUnknownDatabase <: WebUserError()
// WebUserUnknownDatabase <: WebUserError()

//---------------------------------------------------------------------------
//	1. PERMISSIONS
//---------------------------------------------------------------------------

// prédifinition des property pour Dbo
permGroup 	:: Dbo/dbProperty()
permMenu 	:: Dbo/dbProperty()
permRead 	:: Dbo/dbProperty()
permModify 	:: Dbo/dbProperty()
permDelete 	:: Dbo/dbProperty()
permCreate 	:: Dbo/dbProperty()
permSite 	:: Dbo/dbProperty()

// Droits groupes/menu/site
MenuGroupPermission <: ephemeral_object(
		dbId:integer,
		permGroup:WebUserGroup,		// groupe concerné
		permMenu:string,			// menu concerné
		permSite:string,			// site concerné
		permRead:boolean = false,			// lecture ? 
		permModify:boolean = false,			// modification ?
		permDelete:boolean = false,			// suppression ?
		permCreate:boolean = false)			// create ??

[Dbo/dbStore?(c:{MenuGroupPermission}) : boolean -> true]

//---------------------------------------------------------------------------
//	2. GROUPES
//---------------------------------------------------------------------------

groupTitle 	:: Dbo/dbProperty()
groupAbstract? :: Dbo/dbProperty()

//
WebUserGroup <: object(
			dbId:integer,
			groupTitle:string = "",
			groupAbstract?:boolean = true
			)

[Dbo/dbStore?(c:{WebUserGroup}) : boolean -> true]
[getInfo(self:WebUserGroup) : string -> self.groupTitle]


//---------------------------------------------------------------------------
//	3.	UTILISATEURS
//---------------------------------------------------------------------------

oName		:: Dbo/dbProperty()
oIsdn 		:: Dbo/dbProperty()
oAdresses 	:: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_BLOB)
oBillingAdress 	:: Dbo/dbProperty()
oBillingEmail 	:: Dbo/dbProperty()
oBillingUrl 		:: Dbo/dbProperty()
oCommandAdress 	:: Dbo/dbProperty()
oCommandEmail 	:: Dbo/dbProperty()
oCommandUrl 	:: Dbo/dbProperty()
oPhones 		:: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_BLOB)
oFaxes 		:: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_BLOB)
oEmails		:: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_BLOB)
oWeb		:: Dbo/dbProperty()
oCountry	:: Dbo/dbProperty()
oGroup		:: Dbo/dbProperty()

WebOrganization <: ephemeral_object(
			dbId:integer,
			oName:string = "",
			oIsdn:string = "",
			oCountry:string = "",
			oAdresses:list[string],
			oBillingAdress:string = "",
			oBillingEmail:string = "",
			oBillingUrl:string = "",
			oCommandAdress:string = "",
			oCommandEmail:string = "",
			oCommandUrl:string = "",
			oPhones:list[string],
			oFaxes:list[string],
			oEmails:list[string],
			oGroup:WebUserGroup,

			oPrivateKey:port,
			oPublicKey:port,
			oCertificate:port,
			oWeb:string = ""
			)
			
[Dbo/dbStore?(c:{WebOrganization}) : boolean -> true]
[getInfo(self:WebOrganization) : string -> self.oName /+ "(" /+ self.oIsdn /+ ")" ]

[button_organization_identity(org_id:integer) : void
-> ( ?><input type=button onclick="javascript:window.open('<?= url(POPUPMENU_ORGANIZATION) ?>?id=<?= org_id ?>','identite','width=350px, height=350px, menubar=no, toolbar=no, status=no,resizable=yes, scrollbars=yes');" value="<?== translate("identité complète") ?>"><? )]

[billing_emails(self:WebOrganization) : list[tuple(string,table)]
->	let res := list<tuple(string,table)>()
	in (when emails := get(oBillingEmail,self)
		in (for em in explode(emails,";")
				let vals := explode(em,"?"),
					t := make_table(string,string,"")
				in (if (length(vals)= 2)
						for r in explode(vals[2],"&") 
							let b := explode(r,"=") 
							in (if (length(r) > 2) (t[url_decode(b[1])] := b[2])),
					res add tuple(vals[1],t))),
		res)]

[command_emails(self:WebOrganization) : list[tuple(string,table)]
->	let res := list<tuple(string,table)>()
	in (when emails := get(oCommandEmail,self)
		in (for em in explode(emails,";")
				let vals := explode(em,"?"),
					t := make_table(string,string,"")
				in (if (length(vals)= 2)
						for r in explode(vals[2],"&") 
							let b := explode(r,"=") 
							in (if (length(r) > 2) (t[url_decode(b[1])] := b[2])),
					res add tuple(vals[1],t))),
		res)]
		



usrLogin 		:: Dbo/dbProperty()
usrPassword 	:: Dbo/dbProperty()
usrFullName 	:: Dbo/dbProperty()
usrGroup 		:: Dbo/dbProperty()
usrLastLogin 	:: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_TIMESTAMP)
usrLoginAttemp	:: Dbo/dbProperty()

usrLocked 		:: Dbo/dbProperty()
usrLockedInfo 	:: Dbo/dbProperty()

usrLanguage 	:: Dbo/dbProperty()
usrLocale 	:: Dbo/dbProperty() //<sb> +
usrMail 		:: Dbo/dbProperty()
usrSuperUser? 	:: Dbo/dbProperty()
usrOrganization	:: Dbo/dbProperty()
usrTitle		:: Dbo/dbProperty()
usrFunction		:: Dbo/dbProperty()

usrPrivateKey	:: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_BLOB)
usrCertificate	:: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_BLOB)

usrPhones		:: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_BLOB)
usrFaxes		:: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_BLOB)
usrAdresses		:: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_BLOB)
usrWeb			:: Dbo/dbProperty()
usrDefaultApp	:: Dbo/dbProperty()

usrLockedKey	:: Dbo/dbProperty()

usrSecurePassword	:: Dbo/dbProperty(Dbo/password? = true)

usrMultipleLogin	:: Dbo/dbProperty()
usrTimeZone	:: Dbo/dbProperty()
usrSignature :: Dbo/dbProperty()

// WebUser == Utilisateur identifié
WebUser <: object(
			dbId:integer,
						
			usrFullName:string = "",
			usrTitle:string = "",
			usrFunction:string = "",
			usrSignature:string = "",

			usrOrganization:WebOrganization,
			
			usrGroup:WebUserGroup,
			usrLanguage:WebLangue,
			usrLocale:string, //<sb>  +
			
			usrLogin:string = "",		// user login
			usrPassword:string = "",	// 
			usrSecurePassword:string,

			usrLastLogin:float,
			usrLoginAttemp:integer = 0,
			usrMultipleLogin:boolean = false,

			usrLocked:boolean = false,
			usrLockedInfo:string = "",
			usrLockedKey:string,

			usrSuperUser?:boolean = false,

			usrPrivateKey:port,
			usrPublicKey:port,
			usrCertificate:port,
						
			usrMail:string = "",
			usrPhones:list[string],
			usrFaxes:list[string],
			usrAdresses:list[string],
			usrWeb:string = "",
			usrDefaultApp:string = "",
			
			usrTimeZone:string = "CET"
			)

[Dbo/dbStore?(c:{WebUser}) : boolean -> true]
[getInfo(self:WebUser) : string ->
	if (self.usrFullName != "") self.usrFullName else 
	"(" /+ self.usrLogin /+ ")"]

// renvoie l'utilisateur courant
[get_user() : (WebUser  U {unknown})
->	if unknown?(CURRENT_USER) get_user(getenv("WCL_SESSION")),
	CURRENT_USER]

[Dbo/dbPrint(db:Db/Database, self:{usrCertificate},obj:WebUser,p:port) : void
-> freadwrite(obj.usrCertificate,p)]

[Dbo/value!(db:Db/Database, self:{usrCertificate},obj:WebUser,p:port) : port
->	//[3] Dbo/value!(db:Db/Database, self:{usrCertificate},obj:WebUser,p:port),
	let new_p := port!() in (freadwrite(p,new_p), new_p)]

[Dbo/dbPrint(db:Db/Database, self:{usrPrivateKey},obj:WebUser,p:port) : void
-> freadwrite(obj.usrPrivateKey,p)]

[Dbo/value!(db:Db/Database, self:{usrPrivateKey},obj:WebUser,p:port) : port
->	//[3] Dbo/value!(db:Db/Database, self:{usrPrivateKey},obj:WebUser,p:port),
	let new_p := port!()
	in (freadwrite(p,new_p),
		new_p)]


[Dbo/value!(db:Db/Database, self:{usrPhones,usrFaxes,usrAdresses},obj:WebUser,p:port) : list[string]
->	//[3] Dbo/value!(db:Db/Database, self:{~S},obj:WebUser,p:port), // self,
	let c := fread(p, 2)
	in (if (c != "SL") 
			let new_p := port!()
			in (if (c != Serialize/VERSION_HEADER)
					fwrite(Serialize/VERSION_HEADER, new_p),
				fwrite(c, new_p),
				freadwrite(p,new_p), 
				unserialize(new_p) as list[string])
		else
			let new_p := port!()
			in (fwrite(c, new_p), freadwrite(p,new_p), Dbo/extract_string_list(new_p)))]

[Dbo/value!(db:Db/Database, self:{oPhones,oFaxes,oEmails,oAdresses},obj:WebOrganization,p:port) : list[string]
->
	let c := fread(p, 2)
	in (if (c != "SL")
			let new_p := port!()
			in (if (c != Serialize/VERSION_HEADER)
					fwrite(Serialize/VERSION_HEADER, new_p),
				fwrite(c, new_p),
				freadwrite(p,new_p), 
				unserialize(new_p) as list[string])
		else
			let new_p := port!()
			in (fwrite(c, new_p), freadwrite(p,new_p), Dbo/extract_string_list(new_p)))]

link_user 	:: Dbo/dbProperty()
link_group 	:: Dbo/dbProperty()

WebUserGroupLink <: object(
		dbId:integer,
		link_user:WebUser,
		link_group:WebUserGroup)

[Dbo/dbStore?(c:{WebUserGroupLink}) : boolean -> true]


//---------------------------------------------------------------------------
//	4.	SECURITE
//---------------------------------------------------------------------------

//		4.1 Utilitaires
		
// CURRENT_USER_PERMISSIONS[app:string,h:string] : {boolean U AppGroupPermission U MenuGroupPermission}  := false

// clef dans la table de session
PERMISSIONS_KEY:string := "PERMISSIONS_KEY"  

// renvoie la table des droits
[private/get_permissions() : table
->	if not($[PERMISSIONS_KEY])
		rregister(PERMISSIONS_KEY ,
				make_table(	tuple(string,string),
							(boolean U  MenuGroupPermission),
							false)),
	$[PERMISSIONS_KEY] as table]

// supprime la table des droits
[private/erase_permissions() : void
->	$[PERMISSIONS_KEY] := false]

// definie une permission pour une application et un menu donné
[private/set_menu_permission(app:string,menu:string,perm:MenuGroupPermission) : void
->	get_permissions()[app,menu] := perm]

// definie une permission pour l'application courante et un menu donné
[private/set_menu_permission(menu:string,perm:MenuGroupPermission) : void
->	set_menu_permission(webapp().siteId,menu,perm)]

// definie la permission pour l'application donnée
[private/set_app_permission(app:string,perm:MenuGroupPermission) : void
->	get_permissions()[app,app] := perm]

[private/set_app_permission(app:string,group:WebUserGroup,mode:boolean) : void
->	when perm := some( p in Dbo/dbLoad(USER_DATABASE,
									MenuGroupPermission,
									list(tuple(permGroup,group),
										tuple(permSite,app))) | true) as MenuGroupPermission
	in (perm.permAccess := mode,
		Dbo/dbUpdate(USER_DATABASE,perm))
	else (Dbo/dbCreate(USER_DATABASE,
						MenuGroupPermission(permGroup = group,
											permAccess = mode,
											permSite = app)))]
						


/*
// renvoie la permission associée à l'application et au menu
[private/get_menu_permission(app:string,menu:string) : MenuGroupPermission
->	let perms:table := get_permissions() 
	in (if not(perms[app,menu]) (
			perms[app,menu] := MenuGroupPermission()),
		perms[app,menu])]

// renvoie la permission associée à l'application courante et au menu
[private/get_menu_permission(menu:string) : MenuGroupPermission
-> get_menu_permission(webapp(menu).siteId,menu)]

[private/get_menu_permission(app:WebApp,menu:WebMenu) : MenuGroupPermission
->	if (menu.menuPermissions)
		get_menu_permission(webapp(menu).siteId, string!(name(menu)))
	else (
		if known?(menuParent,menu)
			get_menu_permission(app,menu.menuParent)
		else MenuGroupPermission())]

[private/get_menu_permission(menu:WebMenu) : MenuGroupPermission
->	get_menu_permission(menu.menuParent)]

[private/get_menu_permission(menu:SecureWebMenu) : MenuGroupPermission
->	get_menu_permission(webapp(menu).siteId,string!(name(menu)))]

[private/get_menu_permission(menu:WebApp) : MenuGroupPermission
->	get_menu_permission(menu.siteId,string!(name(menu)))]
*/

//		4.2 APIs


[c!p(c:class,p:Dbo/dbProperty) : void
=>	printf("~A.~A",Dbo/dbName(c),Dbo/dbName(p))]


[user_can_do?(action:Dbo/dbProperty) : boolean
->	user_can_do?(get_user(),getCurrentMenu(),action)]

[user_can_do?(menu:WebMenu,action:Dbo/dbProperty) : boolean
->	user_can_do?(get_user(),menu,action)]

[user_can_do?(u:WebUser,menu:WebMenu,action:Dbo/dbProperty) : boolean
->	//[-100] user_can_do?(~S,~S,~S ) // u,menu,action ,
	if known?(menuParent,menu) user_can_do?(u,menu.menuParent,action)
	else false]


[user_can_do?(u:WebUser,menu:SecureWebMenu,action:Dbo/dbProperty) : boolean
->	//[-100] user_can_do?(~S,~S,~S ) // u,menu,action ,
	let p :=  Db/printInQuery(USER_DATABASE)
	in (printf("SELECT (COUNT(~I) > 0) FROM ~A, ~A WHERE ~I = ~A  AND ~I = ~I AND ~I = '~A' AND ~I = '~A' AND ~I = ~A AND ~I = ~A ;",
							c!p(WebUser,dbId),
									Dbo/dbName(WebUser),Dbo/dbName(MenuGroupPermission),
													c!p(WebUser,dbId), u.dbId,
																c!p(WebUser,usrGroup), c!p(MenuGroupPermission,permGroup),
																			c!p(MenuGroupPermission,permSite), webapp(menu).siteId,
																						c!p(MenuGroupPermission,permMenu), string!(name(menu)),
																									c!p(MenuGroupPermission,action),1,
																												c!p(WebUser,usrLocked),0),
		Db/endOfQuery(USER_DATABASE),
		if (Db/fetch(USER_DATABASE))
			(//[0] user_can_do?() SQL request return ~S //  Db/row(USER_DATABASE)[1],
			if (Db/row(USER_DATABASE)[1] % {"1","t","true"})  true 
			else user_can_do2?(u,menu,action))
		else false)]

[user_can_do2?(u:WebUser,menu:SecureWebMenu,action:Dbo/dbProperty) : boolean
->	//[-100] user_can_do2?(~S,~S,~S ) // u,menu,action ,
	let p :=  Db/printInQuery(USER_DATABASE)
	in (printf("SELECT (COUNT(~I) > 0) FROM ~A, ~A, ~A WHERE ~I = '~A' AND ~I = ~A AND ~I = 1 AND ~I = '~A' AND ~I = ~I AND ~I = ~I;",
							c!p(WebUser,dbId),
									Dbo/dbName(WebUser),
											Dbo/dbName(MenuGroupPermission),
												Dbo/dbName(WebUserGroupLink),
													c!p(MenuGroupPermission,permMenu),
														string!(name(menu)),
																c!p(WebUser,dbId), 
																	u.dbId,
																			c!p(MenuGroupPermission,action),
																						c!p(MenuGroupPermission,permSite),
																								webapp(menu).siteId,
																										c!p(WebUserGroupLink,link_user),
																											c!p(WebUser,dbId),
																													c!p(MenuGroupPermission,permGroup),
																														c!p(WebUserGroupLink,link_group)),
		Db/endOfQuery(USER_DATABASE),
		if (Db/fetch(USER_DATABASE))
			(Db/row(USER_DATABASE)[1]  % {"1","t","true"})
		else false)]




// Accès à une application
[userCanAccess?(app:WebMenu) : boolean
->	userCanRead?(app)]

// Verification des droits de lecture de l'utilisateur courant
[userCanRead?(menu:WebMenu) : boolean 
->	when u := get_user()
	in (if u.usrSuperUser? true
		else user_can_do?(menu,permRead)) else false]

// Verification des droits de lecture de l'utilisateur courant sur le menu courant
[userCanRead?() : boolean 
->	userCanRead?(getCurrentMenu())]

// Verification des droits de création de l'utilisateur courant
[userCanCreate?(menu:WebMenu) : boolean 
->	when u := get_user()
	in (if u.usrSuperUser? true
		else user_can_do?(menu,permCreate)) else false]

// Verification des droits de création de l'utilisateur courant sur le menu courant
[userCanCreate?() : boolean 
->	userCanCreate?(getCurrentMenu())]

[userCanModify?(menu:WebMenu) : boolean 
->	when u := get_user()
	in (if u.usrSuperUser? true
		else user_can_do?(menu,permModify)) else false]

[userCanModify?() : boolean 
->	userCanModify?(getCurrentMenu())]

[userCanDelete?(menu:WebMenu) : boolean 
->	when u := get_user()
	in (if u.usrSuperUser? true
		else user_can_do?(menu,permDelete)) else false]

[userCanDelete?() : boolean 
->	userCanDelete?(getCurrentMenu())]

// renvoie les droit pour un groupe, un site et un menu
[groupPermissions(group:WebUserGroup,site:WebApp, menu:WebMenu) : tuple 
->	let i := Dbo/dbLoad(USER_DATABASE,
						MenuGroupPermission,
						list(tuple(permGroup,group),
							tuple(permSite,site.siteId),
							tuple(permMenu,string!(name(menu)))))
	in (if i tuple( i[1].permRead ,i[1].permModify  ,i[1].permCreate  ,i[1].permDelete  )
		else tuple(false,false,false,false))]




/*
// Chargement des droits
[private/loadPermissions(user:WebUser) : void 
-> 	if user.usrSuperUser? return,
	erase_permissions(),
	when g := Dbo/dbGet(USER_DATABASE,usrGroup,user)
	in (for i in Dbo/dbLoad(USER_DATABASE,MenuGroupPermission,list(tuple(permGroup,g))) (
			set_menu_permission(i.permSite,i.permMenu,i)))]

// Chargement des droits pour une application
[private/loadPermissions(app:WebApp,user:WebUser) : void 
-> 	if user.usrSuperUser? return,
	erase_permissions(),
	when g := Dbo/dbGet(USER_DATABASE,usrGroup,user)
	in (for i in Dbo/dbLoad(USER_DATABASE,MenuGroupPermission,list(tuple(permGroup,g),tuple(permSite,app.siteId))) (
			set_menu_permission(i.permSite,i.permMenu,i)))]


*/
//---------------------------------------------------------------------------
//	5.	CONNEXION UTILISATEUR
//---------------------------------------------------------------------------


//Nombre maximal d'echec de connexion accepté avant blocage
MAX_WEB_USER_CONNECTION_ATTEMP:integer := 3


// chargement des langues
[private/use_weblang(user:WebUser) : void 
-> when l := Dbo/dbGet(USER_DATABASE,usrLanguage,user) in use_weblang(l)]


// renvoie les droit pour un groupe et un menu pour le site courant
[groupPermissions(group:WebUserGroup, menu:WebMenu) : tuple 
->	groupPermissions(group,CURRENT_WEB_SITE, menu)]

// verification de l'utilisateur et création de l'instance

[set_default_guest_user()
->	$[CURRENT_USER_KEY] := WebUser(usrSuperUser? = false)]

[set_current_user(self:WebUser) : void
->	$[CURRENT_USER_KEY] := self,
	CURRENT_USER := self]


//---------------------------------------------------------------------------
//	6.	CONNEXION UTILISATEUR
//---------------------------------------------------------------------------

PASSWORD_CHAR_TABLE :: list(
'%','*','-','.','/',
'0','1','2','3','4','5','6','7','8','9',
':','@',
'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z')

MAIL_SERVER:string := "localhost"
MAIL_ADMINISTRATOR:string := "admin@wclsite"

[set_mail_server(host:string) -> MAIL_SERVER := host]

[set_mail_admin(mail:string) -> MAIL_ADMINISTRATOR := mail]

[generate_password() : string ->	random!(),	generate_password(random(3) + 5)]

[generate_password(pass_length:integer) : string
->	random!(),
	let pass := make_string(pass_length),
		char_table_length := (length(PASSWORD_CHAR_TABLE) - 1)
	in (for i in (1 .. pass_length)
			pass[i] := PASSWORD_CHAR_TABLE[random(char_table_length) + 1],
		pass)]

[set_user_password(self:WebUser, passwd:string) : void
-> set_user_password(self, passwd,false)]

[set_user_password(self:WebUser, passwd:string,send_mail:boolean) : void
->	Dbo/dbUpdatePassword(USER_DATABASE,self,passwd),
	if send_mail send_password_email(self, passwd)]

[set_user_password(self:WebUser) : void
->	set_user_password(self,generate_password())]

[send_password_email(self:WebUser, passwd:string) : void
->	if known?(usrMail,self) (
		let mailadmin := (when u := get_user() in (if known?(usrMail,u) u.usrMail else MAIL_ADMINISTRATOR) else MAIL_ADMINISTRATOR),
			msg := Mail/email!(mailadmin,self.usrMail),
			old_locale := LibLocale/get_locale()
		in (msg["From"] := mailadmin,
			msg["To"] := self.usrMail,

			if known?(usrLocale,self) LibLocale/set_locale(self.usrLocale)
			else LibLocale/set_locale("EN"),
			Mail/set_subject(msg, topapp().siteFullName /+ " : " /+ translate("Attribution d'identifiants de connexion")),
			Mail/print_in_alternative(msg),
	
				Mail/print_in_email(msg,"text/plain; charset=ISO-8859-1"),
			?><?= translate("identifiant de connexion (login) : ") ?><?== self.usrLogin ?>
		<?= translate("mot de passe de connexion (password) : ") ?><?== passwd ?>

<?= translate("Veillez à garder ces informations dans un endroit sûr.") ?>

<?= translate("Cordialement.") ?>

<?= translate("Attention : ce message est générée automatiquement, ne pas répondre.") ?><? ,
				Mail/end_of_part(msg),

				Mail/print_in_email(msg,"text/html; charset=ISO-8859-1"), ?>
<html>
	<head>
		<style>
			BODY				
			{
				color: black;
				font-family: arial, sans-serif;
				font-size: 11px;
				font-weight: bold;
			}
		</style>
	</head>
	<body>
		<p align=center><?== translate("Attribution d'identifiants de connexion") ?></p>
		<ul>
			<li>LOGIN : <?== self.usrLogin ?></li>
			<li>PASSWORD : <?== passwd ?>
		</ul>
		<p><?= translate("Veillez à garder ces informations dans un endroit sûr.") ?></p>
		<p><?= translate("Cordialement.") ?>
	</body>
</html><? ,
				Mail/end_of_part(msg),
			Mail/end_of_part(msg),
				
			try (Mail/smtp_send(msg,MAIL_SERVER,self.usrMail))
			catch any (//[-100] ****Erreur : ~S // exception!()
					 ),
			LibLocale/set_locale(old_locale),
			none))]




/*
ADMIN_NOTIFICATION_SMTP_SERVER:string := "10.0.1.100"
ADMIN_NOTIFICATION_ADMINISTRATOR_EMAIL:string := "x.pechoultres@clariprint.com"

[send_password_change_notification(s:WebUser) : void
->	s.usrPasswd := right(uid(),5),
	s.usrLocked := false,
	Dbo/dbUpdate(USER_DATABASE,s,list(usrPasswd,usrLocked)),
	let e := Mail/email()
	in (
		Mail/print_in_body(e,"text/ascii"),
		(?>new password for Clariprint : <?= s.usrPasswd ?>
		<? ),
		Mail/end_of_body(e),
		Mail/set_header(e,"from","Clariprint-System@no-reply"),
		try (Mail/smtp_send(ADMIN_NOTIFICATION_SMTP_SERVER,
						"admin-robot@clariprint",
						"localhost",
						list(s.usrMail),
						e))
		catch Mail/smtp_error (
			//[-100] mail services error : ~S // exception!()
			))]
		

[send_administrator_notification(s:WebUser) : void
->	try (let e := Mail/email()
		in (Mail/print_in_body(e,"text/html"),
			( ?><html>
			<body>
			<p>User <?= s.usrLogin ?> has riched the max connexion attemp and have been locked.</p>
			<p>Last known user ip : <?= getenv("REMOTE_HOST") ?> at  <?= getenv("REMOTE_ADDR") ?>
			</body>
			</html>
			<? ),
			Mail/end_of_body(e),
			Mail/smtp_send(ADMIN_NOTIFICATION_SMTP_SERVER,
						"admin-robot@localhost",
						"localhost",
						list(ADMIN_NOTIFICATION_ADMINISTRATOR_EMAIL),
						e)))
	catch Mail/smtp_error (
			//[-100] mail services error : ~S // exception!()
		)]




*/
cannot_delete_error <: error()


[delete_organization(app:WebApp,self:WebOrganization) : void -> none]
(abstract(delete_organization))

[delete_organization(self:WebOrganization) : void
->	for w in WebApp delete_organization(w,self),
	Dbo/dbUpdate(USER_DATABASE,WebUser,list(tuple(usrOrganization,unknown)),list(tuple(usrOrganization,self))),
	Dbo/dbDelete(USER_DATABASE,self)]
[delete_organization(org_id:integer) : void
->	when org := Dbo/dbLoad(USER_DATABASE,WebOrganization,org_id)
	in (delete_organization(org))]

[getOrganization() : (WebOrganization U {unknown})
-> when u := get_user() in Dbo/dbGet(USER_DATABASE,usrOrganization,u) as (WebOrganization U {unknown}) else unknown]

[getOrganization(id:integer) : (WebOrganization U {unknown})
-> Dbo/dbLoad(USER_DATABASE,WebOrganization,id)]

[getOrganization(id:string) : (WebOrganization U {unknown})
-> getOrganization(integer!(id))]

[getOrganizationByIsdn(isdn:string) : (WebOrganization U {unknown})
->	let res := Dbo/dbLoad(WclSite/USER_DATABASE,WclSite/WebOrganization,list(tuple(WclSite/oIsdn,isdn)))
	in (if res res[1] else unknown)]

[get_users(self:WebOrganization) : list[WebUser]
->	Dbo/dbLoad(USER_DATABASE,WebUser,usrFullName,true,list(tuple(usrOrganization, self))) as list[WebUser]]

[getOrganizations(ids:list[integer]) : list[WebOrganization]
->	Dbo/dbLoadWhere(USER_DATABASE,WebOrganization,Dbo/dbProperties(WebOrganization),list(tuple(dbId,ids)),oName,true)]

[getOrganizationsByIsdn(isdns:list[string]) : list[WebOrganization]
->	Dbo/dbLoadWhere(USER_DATABASE,WebOrganization,Dbo/dbProperties(WebOrganization),list(tuple(oIsdn,isdns)),oName,true)]

[getOrganizations() : list[WebOrganization]
->	when u := get_user() in getOrganizations(u) else nil]

[getOrganizations(self:WebUser) : list[WebOrganization]
->	if (known?(usrSuperUser?,self) & self.usrSuperUser?)
		Dbo/dbLoad(USER_DATABASE,WebOrganization,oName,true)
	else (
		Db/printInQuery(USER_DATABASE),
		?>SELECT <?= Dbo/dbName(WebOrganization) ?>.* from <?= Dbo/dbName(WebOrganization) ?>, <?= Dbo/dbName(WebUserGroupLink) ?>
		WHERE <? c!p(WebOrganization,oGroup) ?> = <? c!p(WebUserGroupLink,link_group) ?>
		AND <? c!p(WebUserGroupLink,link_user) ?> = <?= Dbo/getDbId(self) ?>;<? ,
		Dbo/loadObjectListFromRows(USER_DATABASE, WebOrganization, dbId, list(dbId,oName,oIsdn)))]



[getWebUser(id:integer) : WebUser
-> Dbo/dbLoad(USER_DATABASE,WebUser,id)]

[getWebUser(id:string) : WebUser
-> getWebUser(integer!(id))]


[get_group() : (WebUserGroup U {unknown})
->	when u := get_user() in get_group(u)
	else unknown]

[get_group(self:WebUser) : (WebUserGroup U {unknown})
->	Dbo/dbGet(USER_DATABASE,usrGroup,self)]

[get_groups() : list[WebUserGroup]
->	when u := get_user() in get_groups(u)
	else nil]

[get_groups(self:WebUser) : list[WebUserGroup]
->	if (known?(usrSuperUser?,self) & self.usrSuperUser?)
		Dbo/dbLoad(WclSite/USER_DATABASE,WclSite/WebUserGroup,groupTitle,true)
	else (
		Db/printInQuery(USER_DATABASE),
		?>SELECT <?= Dbo/dbName(WebUserGroup) ?>.* from <?= Dbo/dbName(WebUserGroup) ?>, <?= Dbo/dbName(WebUserGroupLink) ?>
		WHERE <? c!p(WebUserGroup,dbId) ?> = <? c!p(WebUserGroupLink,link_group) ?>
		AND <? c!p(WebUserGroupLink,link_user) ?> = <?= Dbo/getDbId(self) ?>;<? ,
		Dbo/loadObjectListFromRows(USER_DATABASE, WebUserGroup, dbId, list(dbId,groupTitle)))]

[get_permission_groups(self:WebUser) : list[WebUserGroup]
->	if (known?(usrSuperUser?,self) & self.usrSuperUser?)
		Dbo/dbLoad(WclSite/USER_DATABASE,WclSite/WebUserGroup,nil,list(tuple(groupAbstract?,0)),groupTitle,true)
	else (
		Db/printInQuery(USER_DATABASE),
		?>SELECT <?= Dbo/dbName(WebUserGroup) ?>.* from <?= Dbo/dbName(WebUserGroup) ?>, <?= Dbo/dbName(WebUserGroupLink) ?>
		WHERE <? c!p(WebUserGroup,dbId) ?> = <? c!p(WebUserGroupLink,link_group) ?>
		AND <? c!p(WebUserGroup,groupAbstract?) ?> = 0
		AND <? c!p(WebUserGroupLink,link_user) ?> = <?= Dbo/getDbId(self) ?>;<? ,
		Dbo/loadObjectListFromRows(USER_DATABASE, WebUserGroup, dbId, list(dbId,groupTitle)))]


[get_abstract_groups(self:WebUser) : list[WebUserGroup]
->	Db/printInQuery(USER_DATABASE),
	?>SELECT <?= Dbo/dbName(WebUserGroup) ?>.* from <?= Dbo/dbName(WebUserGroup) ?>, <?= Dbo/dbName(WebUserGroupLink) ?>
	WHERE <? c!p(WebUserGroup,dbId) ?> = <? c!p(WebUserGroupLink,link_group) ?>
	AND <? c!p(WebUserGroup,groupAbstract?) ?> = 1
	AND <? c!p(WebUserGroupLink,link_user) ?> = <?= Dbo/getDbId(self) ?>;<? ,
	Dbo/loadObjectListFromRows(USER_DATABASE, WebUserGroup, dbId, list(dbId,groupTitle))]

[get_users() : list[WebUser]
->	when self := get_user()
	in (if (known?(usrSuperUser?,self) & self.usrSuperUser?)
			Dbo/dbLoad(USER_DATABASE,WebUser,usrFullName,true)
		else (when l := getOrganizations() in Dbo/dbLoadWhere(USER_DATABASE,WebUser,list(), list(tuple(usrOrganization,l)),usrFullName,true)
			else nil))
	else nil]

[get_users(self:WebUserGroup) : list[WebUser]
->	Db/printInQuery(USER_DATABASE),
	?>SELECT <?= Dbo/dbName(WebUser) ?>.* from <?= Dbo/dbName(WebUser) ?>, <?= Dbo/dbName(WebUserGroupLink) ?>
	WHERE <? c!p(WebUser,dbId) ?> = <? c!p(WebUserGroupLink,link_user) ?>
	AND <? c!p(WebUserGroupLink,link_group) ?> = <?= Dbo/getDbId(self) ?>;<? ,
	Dbo/loadObjectListFromRows(USER_DATABASE, WebUser, dbId, list(dbId,usrFullName,usrOrganization,usrLocked))]

[count_users(self:WebUserGroup) : integer
->	Db/printInQuery(USER_DATABASE),
	?>SELECT COUNT(<?= Dbo/dbName(WebUser) ?>.<?= Dbo/dbName(dbId) ?>) from <?= Dbo/dbName(WebUser) ?>, <?= Dbo/dbName(WebUserGroupLink) ?>
	WHERE <? c!p(WebUser,dbId) ?> = <? c!p(WebUserGroupLink,link_user) ?>
	AND <? c!p(WebUserGroupLink,link_group) ?> = <?= Dbo/getDbId(self) ?>;<? ,
	if Db/fetch(USER_DATABASE) integer!(Db/row[1])
	else 0]


[get_abstract_groups() : list[WebUserGroup]
->	when u := get_user() in get_abstract_groups(u)
	else nil]

[get_permission_groups() : list[WebUserGroup]
->	when u := get_user() in get_permission_groups(u)
	else nil]


[superUser?() : boolean -> when u := get_user() in u.usrSuperUser? else false]
