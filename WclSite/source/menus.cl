//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* menus.wcl                                                         *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2016-07-20 11:19:02 +0200 (Mer 20 jul 2016) $
//*	$Revision: 2147 $
//*********************************************************************


// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: *                                                       *
// *********************************************************************



[menu_visible?(self:WebMenu) : boolean -> self.menuVisible?]
(abstract(menu_visible?))

[menu_visible?(self:PopupMenu) : boolean -> false]
[menu_visible?(self:SecurePopupMenu) : boolean -> false]


[register_site(self:WebApp) : void
-> CURRENT_WEB_SITE := self]

[private/set_website(self:WebMenu, site:WebApp) : void
->	self.menuSite := site,
	for i in self.menuChilds
		set_website(i,site)]

[add_global_menu(self:WebMenu,site:WebApp) : void
->	set_website(self,site),
	site.siteGlobalsMenu :add self]

[add_global_menu(self:WebMenu) : void
-> if known?(CURRENT_WEB_SITE)
		add_global_menu(self,CURRENT_WEB_SITE)
	else
		error("define CURRENT_WEB_SITE before using add_global_menu(self:WebMenu)")]


// getInfo() restriction to display menu text
[getInfo(self:WebMenu) : string 
->  if known?(menuInfo,self) translate(self.menuInfo)
   else if known?(menuMetaData,self) getInfo($[self.menuMetaData])
   else "Menu inconnu *"]
   
// renvoir le menu courant
[getCurrentMenu() : WebMenu
-> CURRENT_MENU]


[echo(self:WebMenu) : void -> princ(url(self))]


// revoie le fichier associé au menu qui est associé à la classe
[getFileClass(c:class) : string 
-> when m := some(mm in WebMenu | known?(menuClass,mm) & c <= mm.menuClass) in m.menuFile 
	else ""]

// renvoie l emenu associé à une classe
[getMenuClass(c:class) : (WebMenu U {unknown})
-> some(mm in WebMenu | known?(menuClass,mm) & c <= mm.menuClass)]

// affiche le chemin vers un menu : hierarchie des menu
[showMenuPath(self:WebMenu) : void 
->	//[0]  showSubMenu(~S) // self,
	if (known?(menuParent,self))
		(showMenuPath(self.menuParent)),
	if (menu_visible?(self) & MenuShowInPath?(self)) (
		let info := call(getInfo,self)
		in
		printf("<a ~A href=~S class='menu_local_path' title=~S>~I &gt; </a>", (if known?(menuInfo,self) "" else "class='menu_local_path_special' ") , url(self),self_html((if known?(menuSubInfo,self) translate(self.menuSubInfo) else info)) ,self_html(info)))]

[showMenuPath(self:WebApp) : void 
->	//[0]  showSubMenu(~S) // self,
	if (known?(menuParent,self)) (
		showMenuPath(self.menuParent),
		if (menu_visible?(self)) (
			printf("<a ~A href=~S class='menu_local_path'>~I &gt; </a>",
						(if known?(menuInfo,self) "" else "class='menu_local_path_special' ") ,
								url(self),
														self_html(call(getInfo,self)))))
	else (
		printf("<a ~A href=~S class='menu_local_path' ~I>~A &gt; </a>",
				(if known?(menuInfo,self) "" else "class='menu_local_path_special' ") ,
							url(self),
													(if known?(siteDescription,self) printf(" title=~I", self_html(translate(self.siteDescription)))),
														translate("Accueil")))
		]

	
	
[private/drawMenuPath(self:WebMenu,show_lang:boolean) : void
-> ( ?><table class="wclsite_table_menu_path"><tr><td><? ), showMenuPath(self), ( ?></td></tr></table><? )]

[private/drawMenuPath(self:WebMenu) : void
->	drawMenuPath(self,false)]

[showSubMenu(self:WebMenu) : void
-> showSubMenu(self,self)]

[draw_upto_menu(self:WebMenu) : void
->	when parent := get(menuParent,self)
	in (if (url(parent) = url(self)) draw_upto_menu(parent)
		else ( ?><td width=16px  class="td_menu_local"><a href="<?= url(parent) ?>"><img src="/img/up.png"></a></td><? ))]

[menu_link?(self:WebMenu) : boolean -> true]
(abstract(menu_link?))

[private/drawTableMenus(self:WebMenu,l:list[WebMenu]) : void
-> ( ?><table class="wclsite_table_submenu"><tr><? ),
	let ls := length(l)
	in (draw_upto_menu(self),
        if (ls > 0)
			let cols_width := (100 / length(l))
			in (for m in l let linked? := menu_link?(m) in (
				if (m != self) ( ?>
					<td width="<?== cols_width ?>%" class="td_menu_local" <? (if linked? ( ?>onclick="XL.NavigationController.go('<?= url(m) ?>')" <? )) ?><? (if known?(menuSubInfo,m) ( ?> alt="<?== translate(m.menuSubInfo) ?>" <? )) ?>><?= getInfo(m) ?></td><? )
				else ( ?>
					<td width="<?== cols_width ?>%" class="td_menu_local_selected" <? (if linked? ( ?>onclick="XL.NavigationController.go('<?= url(m) ?>')" <? )) ?><? (if known?(menuSubInfo,m) ( ?> title="<?== translate(m.menuSubInfo) ?>" <? )) ?>><?= getInfo(m) ?></td><? )))
		else ( ?><td class="td_menu_local">&nbsp;</td><? ),
		( ?></tr></table><? ))]


[private/drawMenuLanguageChoice() : void
->	if ($["wclsite_switch_lang"]) set_session_locale($["wclsite_switch_lang"]),
//		register_locale($["wclsite_switch_lang"])
//		else if not($["CURRENT_LOCALE"])
//			register_locale("FR"),
	when langues := LibLocale/get_serialized_locale_set()
	in (if langues (
	?><th class="td_menu_local_lang"><form method="post"><?= translate("Langue") ?> :
				<select onchange="form.submit();" name="wclsite_switch_lang">
				<? (for i in langues ( ?>
					<option <? ( if (i = LibLocale/get_locale()) echo("selected")) ?>
						value="<?==  i ?>"><?= i ?></option><? )) ?>
				</select></form></th><? )) ]

[private/drawMenuAppChoice() : void
->	let app := topapp()
	in for i in WebApp (
		if (userCanAccess?(i) & not(i = app)) ( ?>
	<th class="th_menu_app_list"><?== i ?></th><? ))]


[private/drawToolMenus() : void
->	let app := topapp()
	in for i in ToolMenu (
		if (userCanAccess?(i) & not(i = app)) ( ?>
	<th class="th_tool_list"><?== i ?></th><? ))]


[self_html(self:WebApp) : void
-> ?><a href="<?= url(self) ?>"><? ,
	if known?(menuSmallImage,self) ( 
		?><img src="<?= url_img(self,self.menuSmallImage) ?>" title="<?== self.siteFullName ?>" alt="<?== self.siteFullName ?> "><? ),
	?></a><? ]



[self_html(self:WebMenu) : void
->	?><a href="<?= url(self) ?>"><? ,
	if known?(menuSmallImage,self) ( 
		?><img src="<?= url_img(webapp(self),self.menuSmallImage) ?>" title="<?== self.menuInfo ?>" alt="<?== self.menuInfo ?> "><? ),
	?></a><? ]

[self_html(self:ToolMenu) : void
->	?><a href="javascript:window.open('<?= url(self) ?>','<?= string!(name(self)) ?>','<?= self.menuPopupProperties ?>');"><? ,
	if known?(menuSmallImage,self) ( 
		?><img src="<?= url_img(webapp(self),self.menuSmallImage) ?>" title="<?== self.menuInfo ?>" alt="<?== self.menuInfo ?> "><? ),
	?></a><? ]


/* 
<th class="th_menu_app_list"><a href="<?= url(i) ?>"><img title="<?== i.siteFullName ?>" alt="<?== i.siteFullName ?>" src="/img/<?= i.siteSmallPicture ?>"></th><? ))] 
*/

[private/drawMenuUserInfo() : void
->	when u := get_user() in ( 
		?><th class="th_menu_user_info"><?= getInfo(u) ?></th><? ) ]

WCL_DRAW_MENU_USER_INFO:boolean := true

[private/drawMenuTitle(self:WebMenu) : void
-> ( ?><table class="wclsite_table_menu_title">
		<tr>
			<th><?= topapp().siteFullName ?></th><? ) ,
	drawMenuAppChoice(),
	drawToolMenus(),
	if (WCL_DRAW_MENU_USER_INFO) drawMenuUserInfo(),
	drawMenuLanguageChoice(),
	if webapp().siteDoc? ( 
		?><th class="doc"><? (print_doc_link(self,true)) ?></th><? ),
	if webapp().siteExit? (
		if known?(siteExitPicture,topapp()) (
	?><th class="exit"><a href="<?= topapp().siteExitUrl ?>?logout=<?= getenv("WCL_SESSION") ?>"><img src="<?= topapp().siteExitPicture ?>" title="<?== translate(topapp().siteExitInfo) ?>"></a></th><? )
		else (	?><th class="exit"><a href="<?= topapp().siteExitUrl ?>?logout=<?= getenv("WCL_SESSION") ?>"><?= translate(topapp().siteExitInfo) ?></a></th><? )),
	(?></table><? )]

// achiche les sous-menu d'un menu
[showSubMenu(self:WebMenu,m_selected:WebMenu) : void
->	//[-100]  showSubMenu(~S) // self,	
	// if not(check_session_validity()) die(),
	if (known?(CURRENT_MENU) & CURRENT_MENU != self)
		//[-100] *********** showSubMenu(~S) & CURRENT_MENU = ~S //  self, CURRENT_MENU,
	CURRENT_MENU := self,
	none ]

// compatibilité
private/MENU_INIT_DONE?:boolean := false


[showMenu(self:WebMenu) : void
->	// showSubMenu(self,self)]
	CURRENT_MENU := self,
	if not(MENU_INIT_DONE?) menu_global_init(self)
	]


[on_soap_call?() : boolean -> (getenv("ON_SOAP_CALL") = "1" | isenv?("WCL_SOAP_SERVER")  | isenv?("HTTP_SOAPACTION"))]
		
[on_http_header_sent() : void -> 
	//[-100] on_http_header_sent(),
	if on_soap_call?()
		//[-100] on_http_header_sent() -> SOAP : menu not drawed
	else (if unknown?(CURRENT_MENU) 
		//[-100] on_http_header_sent() -> CURRENT_MENU is unknwon !!
		else drawMenu(CURRENT_MENU)),
	none]

[get_visible_childs(self:WebMenu) : list[WebMenu]
->	let l := list<WebMenu>()
	in (for m in self.menuChilds ( 
			if (menu_visible?(m) & not(m % {PopupMenu, SecurePopupMenu}) & userCanRead?(m)) (
				l :add m)),
		l)]

private/SHOW_MENU:boolean := true

[drawMenu?() : boolean -> SHOW_MENU]
[desactivate_drawMenu() : void -> SHOW_MENU := false]
[activate_drawMenu() : void -> SHOW_MENU := true]

[draw_sub_menu(self:WebMenu) : void -> none]
(abstract(draw_sub_menu))

// achiche les sous-menu d'un menu
[drawMenu(self:WebMenu,m_selected:WebMenu) : void
->	//[-100]  showSubMenu(~S) // self,
	if ($["WCL_HIDE_MENU"] | isenv?("WCL_HIDE_MENU")) (
		SHOW_MENU := false,
		if $["WCL_SHOW_HTML_HEADER"] (
				draw_top(self),
				?><div id="body"><? )),
	if SHOW_MENU (
		if (known?(CURRENT_USER) & userCanAccess?(self)) 
		(
			draw_top(self),
			?><div id="body"><? ,
			if known?(menuParent,self) (
				let parent := self.menuParent,
					childs_to_show := get_visible_childs(parent) // list{ mm in parent.menuChilds | menu_visible?(mm) & userCanRead?(mm)}
					in (( ?>
		<table class="wclsite_table_menu">
			<tr><td rowspan="4" class="td_picture"><a href="<?= url(webapp()) ?>"><img src="<?== url_img(topapp(), topapp().siteSmallPicture) ?>" alt="logo"></a></td>
				<td class="wclsite_table_menu_td"><? (drawMenuTitle(self)) ?></td></tr>
			<tr><td class="wclsite_table_menu_td"><? (drawMenuPath(self.menuParent)) ?></td></tr>
			<tr><td class="wclsite_table_menu_td"><? (drawTableMenus(m_selected,childs_to_show)) ?></td></tr>	
			<tr><td id="wclsite_table_menu_td_blank">&nbsp;</td></tr>		
		</table><? (when info := get(menuSubInfo,self)  in ( ?><p id="wclsite_menu_titre"><?= translate(info) ?></p><? )))))
		else (  ?>
		<table class="wclsite_table_menu">
			<tr><td rowspan="4" class="td_picture"><a href="<?= url(webapp()) ?>"><img src="<?== url_img(topapp(), topapp().siteSmallPicture) ?>"></a></td>
				<td class="wclsite_table_menu_td"><? (drawMenuTitle(self)) ?></td></tr>
			<tr><td class="wclsite_table_menu_td"><? (drawMenuPath(self,true)) ?></td></tr>
			<tr><td class="wclsite_table_menu_td"><table class="wclsite_table_submenu"><tr><td width="100%" class="td_menu_local">
					<?= translate("Bienvenue") ?> <?= get_user().usrFullName ?></td></tr></table></td></tr>
			<tr><td id="wclsite_table_menu_td_blank">&nbsp;</td></tr>		
		</table>
		<? ), 
		?><div id="wcl_content"><? ,
		draw_sub_menu(self)) else (show_session_error_logout(), die()))]



[drawMenu(self:WebMenu) : void
->	drawMenu(self,self)]

[drawMenu(self:(PopupMenu U SecurePopupMenu)) : void
->	//[-100] drawMenu@PopupMenu(~S) // self,
	if SHOW_MENU (
		if (known?(CURRENT_USER) & userCanAccess?(self)) (
		draw_top(self),
		if menuPopupShowTop(self) ( 
	?><div id="wcl_popupbody">
	<table class=wclsite_popupmenu>
		<tr><th><?= getInfo(webapp()) ?></th>
			<th><?= getInfo(self) ?></th><? , 
			if self.menuPrint ( ?><th><a onclick="window.print();"><?= translate("imprimer") ?></a></th><? ) ,
			?><td><a onclick="if (typeof wclsite_close_popup =='function') wclsite_close_popup(); else window.close();" style="cursor: pointer; text-decoration: underline"><?= translate("fermer") ?></a></td>
	</table><? )) else (show_session_error_logout(), die())) ]


[drawMenu(self:UploadMenu) : void
->	//[-100] drawMenu@UploadMenu,
	if not(userCanAccess?(self)) echo("ERROR")]

[drawMenu(self:SecureUploadMenu) : void
->	//[-100] drawMenu@UploadMenu,
	if not(userCanAccess?(self)) echo("ERROR")]


[drawMenu(self:WebApp) : void ->
	//[-100] drawMenu@WebApp(~S) // self,
	if not(isenv?("WCL_HIDE_MENU"))
		(when u := check_session() in (drawMenu@WebMenu(self) , print_index(self))
		else draw_login_page(self)) else desactivate_drawMenu()]

private/LOGIN_URL:string := "default"

[set_login_url(url:string) : string -> let old := LOGIN_URL in (LOGIN_URL := url, old)]

[draw_login_page(self:WebApp) : void
->	if isenv?("WCL_LOGIN_APP") 
		let appid := getenv("WCL_LOGIN_APP") in when app := some(i in WebApp | known?(siteId,i) & i.siteId = appid) in self := app,
//	if session_started? claire/session_destroy(),
//	session_start(),
	setenv("WCL_SESSION=" /+ Wcl/new_session_id()),
	let post_url := (if $["wclsitenologinindex"] "" else if (LOGIN_URL = "default") url(self) else LOGIN_URL)
	in (if not(isenv?("WCL_HIDE_MENU")) (
	?><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html class="WebLogin">
<head>
	<title><?= self.siteFullName ?></title>
	<? ,
	for  h in html_headers() printf("~A\n",h), 
	if known?(siteFavicon,topapp()) ( ?>
	<link rel="shortcut icon" href="<?= topapp().siteFavicon ?>" type="image/vnd.microsoft.icon" />
	<link rel="icon" href="<?= topapp().siteFavicon ?>" type="image/vnd.microsoft.icon" /><? ),
	 ?>
</head>
<body class="body_index">
	<form method="post" action="<?= post_url ?>">
		<table>
			<tbody>
				<tr>
					<td class="logo" colspan="2">
						<img src="<?== (if isenv?("WCLSITE_IMG_ACCUEIL") getenv("WCLSITE_IMG_ACCUEIL") else url_webapp_file(topapp().siteLargePicture)) ?>"></td>
				</tr>
				<tr>
					<td class="titre" colspan="2"><?= topapp().siteFullName ?></td></tr>
				<tr class="login">
					<th><?= translate("login") ?> :</th>
					<td><input  type="text" name="login"/>
				<tr class="password">
					<th><?= translate("password") ?> :</th>
					<td><input type="password" name="password"><input type="submit" value="<?== translate("Connexion") ?>"/>
				</td>
			</tbody>
		</table>
	</form>
<? ))]		

private/BASE_HTML_HEADERS:list[string] := list<string>()

/*
"<script language=\"JavaScript\" src=\"/js/html.js\" type=\"text/javascript\"></script>",
"<script language=\"JavaScript\" src=\"/js/wclsite.js\" type=\"text/javascript\"></script>",
"<script language=\"JavaScript\" src=\"/js/ajax.js\" type=\"text/javascript\"></script>",
"<script language=\"JavaScript\" src=\"/js/xlforms.js\" type=\"text/javascript\"></script>")
*/

[html_headers() : list[string] ->
	when u := getCurrentMenu() in setup_html_headers(u),
	BASE_HTML_HEADERS]

[add_html_header(header:string) : void -> BASE_HTML_HEADERS add header]

[setup_html_headers(self:WebMenu) : void
->	if known?(menuParent,self) setup_html_headers(self.menuParent),
	if known?(menuHtmlHeaders,self) BASE_HTML_HEADERS :/+ self.menuHtmlHeaders]
(open(setup_html_headers) := 3)


[htmlCss(self:WebMenu) : string -> "WebMenu"]
[htmlCss(self:(PopupMenu U SecurePopupMenu)) : string -> "WebPopup"]


[draw_top(self:WebMenu) : void
-> ?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html class="<?= htmlCss(self) ?> <?= string!(name(self)) ?>">
<head>
	<meta http-equiv="content-type" content="text/html; <?= translate("charset=iso-8859-1") ?>" />
	<title><?= WclSite/topapp().WclSite/siteFullName   ?><? (if $["WINDOW TITLE"] echo($["WINDOW TITLE"])) ?></title>
	<? ,
	for  h in html_headers() printf("~A\n",h),
	if known?(siteFavicon,topapp()) ( ?>
	<link rel="shortcut icon" type="image/x-icon" href="<?= webapp().siteFavicon ?>" /><? ),
	?></head><body><? ]

[draw_bottom(self:WebMenu) : void
-> ?></div></div><? ,
	if isenv?("WCL_DEBUG") Core/edit_link(list(getenv("PATH_TRANSLATED"),1)),
	?></body></html><? ]

[draw_bottom(self:(PopupMenu U SecurePopupMenu)) : void
-> ?></div></body></html><? ]

[draw_bottom(self:(UploadMenu U SecureUploadMenu)) : void -> none]

(abstract(draw_bottom))


CURRENT_MENU_ENV_VAR :: "WCL_URL_VAR2"
LAST_MENU_ENV_VAR :: "WCL_URL_VAR1"

[save_env_vars() : void ->
	let f := fopen(getenv("WCL_UPLOAD_FOLDER") /+ "/env.cl","w")
	in (for i in (1 .. maxenv())
			printf(f,"(setenv(~S))\n",environ(i)),
		fclose(f))]	

WLC_USE_SESSION:boolean := true

[Wcl/wcl_startup() : void
->	//[-100] WclSite/wcl_startup(),
	if isenv?("SAVE_ENVIRONMENT") save_env_vars(),
	// if not($["wclsite_no_global_setup"])
	webapp_global_setup(),
	dispatch_startup_on_startupitem(),
	if $["logout"] logout( $["logout"]),
	
	if (isenv?(LAST_MENU_ENV_VAR) & isenv?(CURRENT_MENU_ENV_VAR)) (
		when current := eval(get_value(getenv(CURRENT_MENU_ENV_VAR)))
		in (CURRENT_MENU := current, menu_global_init(current))
		else (CURRENT_MENU := webapp(), menu_global_init(webapp())))
	else (CURRENT_MENU := webapp(), menu_global_init(webapp())),
	
	if (WLC_USE_SESSION) session_start()]


[menu_init(self:WebMenu) : void -> none]

(abstract(menu_init))

[menu_global_init(self:WebMenu) : void
->	//[-100] menu_global_init(~S) // self,
	if known?(menuParent, self)
		(menu_global_init(self.menuParent)) ,
	try menu_init(self)
	catch any //[-100] ** error in menu_init(~S) : ~S // self, exception!(),
	MENU_INIT_DONE? := true ]

[init_session() : void -> check_session_validity()]

[webapp_setup(self:WebApp) : void ->
	//[-100] WclSite/webapp_setup(~S) not defined ! // self, 	
	none]

(abstract(webapp_setup))


[webapp_global_setup() : void
->	//[0] WclSite/webapp_global_setup(),
	for i in WebApp webapp_setup(i)]



[webapp_setdown(self:WebApp) : void ->
	//[1] WclSite/webapp_setdown(~S) not defined ! // self, 	
	none]

(abstract(webapp_setdown))


[webapp_global_setdown() : void
->	//[0] WclSite/webapp_global_setup(),
	for i in WebApp webapp_setdown(i)]


[Wcl/soap_finish(si:Soap/SoapIn, so:Soap/SoapOut) : void
->	//[0] WclSite/soap_finish() called ,
	when app := webapp() in menu_global_close(app),
	webapp_global_setdown()]


[Wcl/wcl_finish() : void
->	if on_soap_call?() 
		//[0] WclSite/wcl_finish() called but inactive on SOAP
	else (
	//[0] WclSite/wcl_finish() called ,
	if ((known?(CURRENT_MENU) & SHOW_MENU) | $["WCL_SHOW_HTML_HEADER"]) draw_bottom(CURRENT_MENU),
	
	dispatch_shutdown_on_startupitem(),
	webapp_global_setdown(),
	if (isenv?(LAST_MENU_ENV_VAR) & isenv?(CURRENT_MENU_ENV_VAR)) (
		when current := eval(get_value(getenv(CURRENT_MENU_ENV_VAR)))
		in menu_global_close(current)
		else menu_global_close(webapp()))
	else menu_global_close(webapp()))]
	

[menu_close(self:WebMenu) : void -> 
//[1] menu_close(~S) is undefined ! // self
		]

(abstract(menu_close))

[menu_global_close(self:WebMenu) : void
->	//[1] menu_global_close(~S) // self,
	try menu_close(self)
	catch any //[-100] ** error in menu_close(~S) : ~S // self, exception!(),
	if known?(menuParent, self) menu_global_close(self.menuParent)]



[get_menu() : (WebMenu U {unknown}) -> if known?(CURRENT_MENU) CURRENT_MENU else unknown]

[set_menu(self:WebMenu) : void ->  CURRENT_MENU := self]


