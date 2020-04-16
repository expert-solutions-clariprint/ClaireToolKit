//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* session.wcl                                                         *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2016-04-22 21:38:07 +0200 (Ven 22 avr 2016) $
//*	$Revision: 2144 $
//*********************************************************************


// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: Model                                                   *
// *   Part 2: Session Management                                      *
// *   Part 3: Session tools                                           *
// *   Part 4: User management                                          *
// *   Part 5: IHM Messages                                            *
// *********************************************************************



// *********************************************************************
// *   Part 1: Model                                                   *
// *********************************************************************


sess_id :: Dbo/dbProperty()
sess_user :: Dbo/dbProperty()
sess_ip :: Dbo/dbProperty()
sess_url :: Dbo/dbProperty()
sess_locale :: Dbo/dbProperty()
sess_active? :: Dbo/dbProperty()
sess_created :: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_TIMESTAMP)
sess_accessed :: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_TIMESTAMP)
sess_closed :: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_TIMESTAMP)

user_session <: ephemeral_object(
					dbId:integer,		// database id
					sess_id:string,		// session id
					sess_user:WebUser,	// user
					sess_ip:string,		// ip of user computer
					sess_url:string,	// last visited URL
					sess_active?:boolean,	// session active or not
					sess_locale:string,	// current locale setting
					sess_created:float,	// date of session creation
					sess_accessed:float,	// last session access date
					sess_closed:float)	// date of session close
					
CURRENT_SESSION:user_session := unknown


[Dbo/dbStore?(self:{user_session}) : boolean -> true]


WebUserNoSession <: WebUserError()
SessionTimeOut <: WebUserError()

private/SESSION_TIME_OUT:integer := 36000   // time_out d'une session en secondes

// *********************************************************************
// *   Part 2: Session Management                                      *
// *********************************************************************


[open_session(self:WebUser) : void
->	//[-100] open_session(~S) [~S] // self,getenv("WCL_SESSION"),
	let sess := user_session()
	in (sess.sess_id := getenv("WCL_SESSION"),
		sess.sess_user := self,
		sess.sess_ip := getenv("REMOTE_ADDR"),
		sess.sess_url := getenv("PATH_INFO"),
		sess.sess_locale := (if known?(usrLocale,self) self.usrLocale else "FR"),
		sess.sess_active? := true,
		sess.sess_created := now(),
		sess.sess_accessed := now(),
		CURRENT_SESSION := sess,
		Dbo/dbCreate(USER_DATABASE,sess)
		)]

[update_databases(self:WebUser) : void
->	try (if self.usrSuperUser? (ON_DB_UPDATE := true, dispatch_db_update(), ON_DB_UPDATE := false))
	catch Db/DbError (//[-100] lancement de dispatch_db_update() ~S sur erreur ~S // ON_DB_UPDATE, exception!(),
					if not(ON_DB_UPDATE) dispatch_db_update())]

[update_databases(app_key:string) : void
->	if (getenv("UPDATE_DB_DIR") != "") (
		let fname := (getenv("UPDATE_DB_DIR") / webapp().siteId /+ getenv("HTTP_HOST"))
		in (if not(isfile?(fname)) (
				let f := fopen(fname,"w")
				in (fwrite(strftime("%c",now()),f),
					dispatch_db_update(),
					fclose(f)))))]


[get_user(session_id:string) : (WebUser  U {unknown})
->	//[-100] get_user(~S) // session_id,
	when l := Dbo/dbLoad(USER_DATABASE,
							user_session,
							list(tuple(sess_id,session_id),
								tuple(sess_ip,getenv("REMOTE_ADDR")),
								tuple(sess_active?,true)))
		in (if l
				(let sess := l[1] as user_session in (
					if ((elapsed(sess.sess_accessed) / 1000)  > SESSION_TIME_OUT)
						(
						logout(sess.sess_id),
						unknown)
					else (when u := Dbo/dbGet(USER_DATABASE,sess_user,sess) as WebUser
						in (update_databases(u),
							sess.sess_accessed := now(),
							sess.sess_url := getenv("PATH_INFO"),
							Db/beginTransaction(USER_DATABASE),
							if $["wclsite_switch_lang"]
								(sess.sess_locale := $["wclsite_switch_lang"],
								Dbo/dbUpdate(USER_DATABASE,sess,list(sess_accessed,sess_url,sess_locale)))
							else Dbo/dbUpdate(USER_DATABASE,sess,list(sess_accessed,sess_url)),
							Db/commitTransaction(USER_DATABASE),
							LibLocale/set_locale(sess.sess_locale),
							LibLocale/set_applicable(topapp().siteId),
							set_timezone(u),
							CURRENT_SESSION := sess,
							$[CURRENT_USER_KEY] := u,
							CURRENT_USER := u,
							//[-100] get_user(~S) : OK // session_id,
							u)
						else unknown)))
			else  unknown)
		else unknown]

SESSION_CHECKED:boolean := false
[check_session() : (WebUser U {unknown})
->	//[-100] check_session(),
	if unknown?(USER_DATABASE) (//[-100] USER_DATABASE UNSET !,
								unknown)
	else if (getenv("WCL_SESSION") = "") unknown
	else if known?(CURRENT_USER) CURRENT_USER
	else if ($["login"] & $["password"]) (
		when u := getSecureWebUser($["login"],$["password"])
		in (if not(u.usrMultipleLogin) db_close_user_sessions_but(u,"--"),
			open_session(u),
			if known?(usrLocale,u)
				LibLocale/set_locale(u.usrLocale),
			LibLocale/set_applicable(topapp().siteId),
			update_databases(u),
			set_timezone(u),
			$[CURRENT_USER_KEY] := u,
			CURRENT_USER := u,
			u) else unknown)
	else (get_user(getenv("WCL_SESSION")))]


[logout(session_id:string)
->	//[-100] logout(~S) // session_id,
	session_close(session_id),
	session_clean_files(session_id)]

private/ON_DB_UPDATE:boolean := false

[session_start() : void
->	//[-100] session_start(),
	if unknown?(CURRENT_USER) check_session(),
	session_url()]
	
	
[set_timezone(self:WebUser) : void
->	when tz := get(usrTimeZone,self)
	in (//[-100] timezone (user) = ~S // tz,
		tzset(tz))
	else (//[-100] timezone (default) = CET,
//		tzset("CET")
		none)]
		
		
// *********************************************************************
// *   Part 3: Session tools                                           *
// *********************************************************************

// API to set session timout
[set_session_timeout(i:integer) : void
->	if (i < 0) i := -(i),
	SESSION_TIME_OUT := i]

// close all open session of a user exepted current
[private/db_close_user_sessions_but(self:WebUser,but_session_id:string) : void
->	//[-100] db_close_user_sessions_but(),
	Dbo/printInQuery(USER_DATABASE),
?>UPDATE <?= Dbo/dbName(user_session) ?>
SET <?= Dbo/dbName(sess_active?) ?> = 0,
<?= Dbo/dbName(sess_closed) ?> = <? (Dbo/dbPrintValue(USER_DATABASE,now(),sess_closed)) ?>
WHERE <?= Dbo/dbName(sess_user) ?> = <?= Dbo/getDbId(self) ?>
AND <?= Dbo/dbName(sess_active?) ?> = 1
AND <?= Dbo/dbName(sess_id) ?> !=  <? (Dbo/dbPrintValue(USER_DATABASE,but_session_id,sess_id)) ?>; <?,
	Dbo/endOfQuery(USER_DATABASE)]



[private/session_close(session_id:string) : void
->	//[-100] session_close(),
	Dbo/dbUpdate(USER_DATABASE,user_session,list(tuple(sess_active?,false),tuple(sess_closed,now())), list(tuple(sess_id,session_id),
							tuple(sess_ip,getenv("REMOTE_ADDR"))))]
[private/session_close() : void
-> session_close(getenv("WCL_SESSION"))]

[private/session_clean_files(session_id:string)
->	if not(isenv?("WCLSITE_NOT_CLEAN_SESSION_FILES"))
		(//[-100] session_clean_files(~S) // session_id,
		when path := getenv("WCL_SESSION_PATH")
			in (shell("rm -rf " /+ path /+ "/*" /+ session_id /+ "*.session")))]


[check_session_validity() : boolean
->	//[-100] check_session_validity(),
	when u := check_session() in ($[CURRENT_USER_KEY] := u, true) else (show_session_error_logout(), false)]

// *********************************************************************
// *   Part 4: User management                                          *
// *********************************************************************


[mysqlPasswordUpdate(login:string,pass:string) : void
->	Db/printInQuery(USER_DATABASE),
	printf("UPDATE ~A SET ~A = MD5(~I) WHERE ~A = ~I AND ~A = OLD_PASSWORD(~I) LIMIT 1",
		Dbo/dbName(WebUser),
		Dbo/dbName(usrSecurePassword),
		Dbo/dbPrint(USER_DATABASE, pass),
		Dbo/dbName(usrLogin),
		Dbo/dbPrint(USER_DATABASE, login),
		Dbo/dbName(usrSecurePassword),
		Dbo/dbPrint(USER_DATABASE, pass)),
	Dbo/endOfQuery(USER_DATABASE)]


[getSecureWebUser(login:string,passwd:string) :  (WebUser U {unknown}) 
->	//[-100] getSecureWebUser(),
	if isenv?("OLD_PASSWORD")
		(Db/SQL_TYPES[Db/SQL_PASSWORD,Db/MYSQL]	:=	"OLD_PASSWORD")
	else mysqlPasswordUpdate(login,passwd),
	if unknown?(USER_DATABASE) (WebUserUnknownDatabase(), unknown)
	else (when u := some(x in Dbo/dbLoad(USER_DATABASE,WebUser,list(usrLogin,usrFullName,usrLocale,usrDefaultApp,usrSuperUser?,usrMultipleLogin,usrTimeZone), list(tuple(usrLogin,login),tuple(usrLocked,false))) | true) 
		in (if Dbo/dbValidPassword?(USER_DATABASE,u,passwd) u as WebUser
			else (register_bad_login_attemp(u),
				unknown))
		else unknown)]

[register_bad_login_attemp(self:WebUser)
->	//[-100] register_bad_login_attemp(),
	self.usrLoginAttemp :+ 1,
	if (self.usrLoginAttemp > MAX_WEB_USER_CONNECTION_ATTEMP) (
		self.usrLocked := true,
		self.usrLockedKey := uid(),
		Dbo/dbUpdate(USER_DATABASE,self,list(usrLocked,usrLockedKey)),
		send_usr_lock_mail(self),
		WebUserLocked())
	else (self.usrLocked := false,
			Db/beginTransaction(USER_DATABASE),
			Dbo/dbUpdate(USER_DATABASE,self,list(usrLocked,usrLoginAttemp)),
			Db/commitTransaction(USER_DATABASE))]
	
	
[set_session_locale(locale:string) : void
->	//[-100] set_session_locale() => inactived,
	none]
/*	when sess := CURRENT_SESSION in (
		sess.sess_locale := locale,
		LibLocale/set_locale(sess.sess_locale),
		Dbo/dbUpdate(USER_DATABASE,sess,list(sess_locale)))] */


// *********************************************************************
// *   Part 5: IHM Messages                                            *
// *********************************************************************

	
[send_usr_lock_mail(self:WebUser) : void
->	//[-100] send_usr_lock_mail(),
	if known?(usrMail,self) (
		let msg := Mail/email!()
		in (if known?(usrLocale,self) LibLocale/set_locale(self.usrLocale),
			msg["From"] := "no-reply@clariprint.com",
			msg["TO"] := self.usrMail,
			Mail/set_subject(msg, translate("Blocage de compte d'accès")),
			Mail/print_in_alternative(msg),			
			Mail/print_in_email(msg,"text/html"),
			( ?><html>
				<body>
				<p><?= translate("Votre compte d'accès à été bloqué par le système.") ?></p>
				<p><?= translate("Pour débloquer votre compte veuillez cliquer sur le lien ci-dessous") ?> :</p>
				<a href="http://<?= getenv("SERVER_NAME") ?>/wclsite/unlock_account.wcl?magic_key=<?= self.usrLockedKey ?>"><?== translate("Déblocage de compte") ?></a>
				<p><?= translate("Si vous rencontriez des difficulté veuillez vous référer à votre coordinateur Clariprint") ?>
				</body>
				</html><? ),
			Mail/end_of_part(msg),
			Mail/print_in_email(msg,"text/ascii"),
			( ?>
<?= translate("Votre compte d'accès à été bloqué par le système.") ?>
<?= translate("Pour débloquer votre compte veuillez cliquer sur le lien ci-dessous") ?> :</p>
<http://<?= getenv("SERVER_NAME") ?>/wclsite/unlock_account.wcl?magic_key=<?= self.usrLockedKey ?>>
<?= translate("Si vous rencontriez des difficulté veuillez vous référer à votre coordinateur Clariprint") ?><? ),
			Mail/end_of_part(msg),
			Mail/end_of_part(msg),
			try Mail/smtp_send(msg,"mailhost.clariprint.com",self.usrMail)
			catch any //[-100] ****Erreur : ~S // exception!(),
			none))]

[show_session_error_logout() 
->	//[-100] show_session_error_logout(),
	draw_top(topapp()),
	?>	<p class="session_error">Attention, votre session a expiré ou une erreur est survenue, merci de revenir à <a href="/">l'écran de connexion.</a></p>
		<p class="session_error">Sorry, your session has expired or an error as occured, please back to <a href="/">login screen.</a></p><? ]


