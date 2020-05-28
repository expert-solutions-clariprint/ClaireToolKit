//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* model.wcl                                                         *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2012-04-05 10:48:06 +0200 (Jeu 05 avr 2012) $
//*	$Revision: 2096 $
//*********************************************************************


// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: *                                                       *
// *********************************************************************


wclSite_version :: "2.0.0"


// general id property
dbId :: Dbo/dbProperty(Dbo/id? = true)
// classe de base


// getInfo is a callback to get object information
claire/getInfo :: property(range = string)
(abstract(getInfo))
[getInfo(self:any) : string -> "get info non defini" ]

WebMenu <: thing 
SecureWebMenu <: WebMenu
WebApp <: SecureWebMenu
WebUser <: object

// Général menu
WebMenu <: thing(
		menuSite:WebApp,
		menuPath:string = "",
		menuMetaData:string,
		menuGlobal:boolean = false,
		menuParent:WebMenu,
		menuChilds:list[WebMenu] = list(),
		menuShowChilds:boolean = true,
		menuItem:property,
		menuVisible?:boolean = true,
		MenuShowInPath?:boolean = true,
		menuInfo:string,
		menuSubInfo:string,
		menuShowLangChoice:boolean = false,
		menuFile:string,
		menuSmallImage:string,
		menuLargeImage:string,
		menuPrint:boolean = false,
		menuDocItem:string,
		menuClass:class,
		menuHtmlHeaders:list[string])

(inverse(menuParent) := menuChilds)

SecureWebMenu <: WebMenu(
		menuPermissionsInfo:string = "",
		menuPermissionCreate:boolean = true,
		menuPermissionRead:boolean = true,
		menuPermissionModify:boolean = true,
		menuPermissionDelete:boolean = true)

PopupMenu <: WebMenu(menuPopupProperties:string = "menubar=off",
						menuPopupShowTop:boolean = true)

						

SecurePopupMenu <: SecureWebMenu(menuPopupProperties:string = "menubar=off",		
						menuPopupShowTop:boolean = true)

UploadMenu <: PopupMenu()
SecureUploadMenu <: SecurePopupMenu() 

ToolMenu <: PopupMenu()

// Describe a web site
WebApp <: SecureWebMenu(
			siteFullName:string = "",
			siteId:string = "DEFAULT",
			siteDescription:string,
			siteRootPath:string = ".",
			siteBaseUrl:string = "/",
			siteIndexFile:string = "wcl_index.wcl",
			siteSmallPicture:string,
			siteLargePicture:string,
			siteFavicon:string = "/img/favicon.ico",
			siteGlobalsMenu:list[WebMenu],
			siteDefaultMenu:WebMenu,
			siteSelectedGlobalMenu:WebMenu,
			siteDoc?:boolean = false,
			siteDocUrl:string = "/doc/",
			siteImgUrl:string = "/img/",	//need / at the end
			siteExit?:boolean = false,
			siteExitUrl:string = "/",
			siteExitPicture:string = "/img/exit.png",
			siteExitInfo:string = "Quitter",
			siteThemePath:string = "theme/",	//need / at the end
			siteThemeUrl:string = "/theme/")	//need / at the end

WebModule <: WebApp()

WebVirtualMenu <: WebMenu()

[getInfo(self:WebApp) : string -> self.siteFullName]
[getInfo(self:string) : string -> self]


// WclSite Manage one site at time
private/CURRENT_WEB_SITE:WebApp := unknown

[webapp() : WebApp -> CURRENT_WEB_SITE]

[webapp(self:WebMenu) : (WebApp U {unknown}) ->
	if known?(menuSite,self) self.menuSite
	else (if known?(menuParent,self) (self.menuSite := webapp(self.menuParent), self.menuSite) else unknown)]

[webapp(self:WebApp) : WebApp -> self]
	
[topapp(self:WebMenu) : WebApp -> if known?(menuParent,self) topapp(self.menuParent) else self as WebApp]

[topapp() : WebApp -> topapp(webapp())]

// Current displayed menu, updated by showMenu()
private/CURRENT_MENU:WebMenu := unknown

// key of current user in $ table
private/CURRENT_USER_KEY:string := "CURRENT_USER"
private/CURRENT_USER:WebUser := unknown

// Database where user, groups and permissions are stored
private/USER_DATABASE:Db/Database := unknown

// Database where language and translation are stored
private/LANG_DATABASE:Db/Database := unknown

[set_lang_database(self:Db/Database) : void
-> LANG_DATABASE := self]

[set_user_database(self:Db/Database) : void
-> USER_DATABASE := self]

[set_database(self:Db/Database) : void
->	set_user_database(self),
	set_lang_database(self)]

[get_user_database() : Db/Database -> USER_DATABASE]
[get_lang_database() : Db/Database -> LANG_DATABASE]

[get_admin_database() : Db/Database -> USER_DATABASE]




WebStartupItem <: object(itemInfo:string = "startup", level:integer = 0)

[web_startup(self:WebStartupItem) : void -> none]
(abstract(web_startup))

[web_shutdown(self:WebStartupItem) : void -> none]
(abstract(web_shutdown))

[sort_startup_item(a:WebStartupItem,b:WebStartupItem) : boolean
->	(a.level > b.level)]


[dispatch_startup_on_startupitem() : void
->	//[-100] dispatch_startup_on_startupitem,
	for i in sort(sort_startup_item @ WebStartupItem,list{ i | i in WebStartupItem} )
		web_startup(i)]

[dispatch_shutdown_on_startupitem() : void
->	//[-100] dispatch_shutdown_on_startupitem,
	for i in sort(sort_startup_item @ WebStartupItem,list{ i | i in WebStartupItem} )
		web_shutdown(i)]





[claire/strftime(t:float,f:string) : string 
=>  strftime(f,t)]

[claire/date(t:float,f:string) : string 
=>  strftime(f,t)]

[claire/fserialize(self:any, p:port) : void
=> serialize(p,self)]
