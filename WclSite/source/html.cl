//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* html.cl                                                           *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2019-07-30 12:19:38 +0200 (Tue, 30 Jul 2019) $
//*	$Revision: 2163 $
//*********************************************************************


// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: standard html table                                     *
// *   Part 2: url generators                                          *
// *   Part 3: js redirection tools                                    *
// *********************************************************************


// *********************************************************************
// *   Part 1: standard html table                                     *
// *********************************************************************


htmlTable :: property()
(abstract(htmlTable))

[htmlTable(tableInfo:string,
					items:list[any],
					c:class,
					menuCreate:WebMenu,
					menuEdit:WebMenu,
					menuDelete:WebMenu) : void
-> 	//[0] htmlTable(),
	printf("<table class='tableAdmin'>
			<tr class='trAdminTitre'>
				<td>
				<td class='tdAdminTitre'>~A</th>
				<td class='tdAdminCreate' >",translate(tableInfo)),

	if (userCanCreate?(menuCreate))
		printf("<a class='hrefAdminCreate' href='~A'><img src='/img/plus.png'></a></td></tr>\n",
			getHref(menuCreate,"creation=1")),

	for m in items (
		//[0]   - ~S // m, 
		printf("<tr class='trAdmin'>
				<td class='tdAdminSupprimer'>~I</td>
				<td class='tdAdminInfo'>~A</td>
				<td class='tdAdminEdit'>~I</td></tr>\n",
				(if userCanDelete?(menuDelete)
					printf("<a onclick='return confirm(~S);' class='hrefAdminSupprimer' href='~A'><img src='/img/delete.png'></a>",
							translate("Attention : Suppression irréversible"),
							(getHref(menuDelete,"class=" /+ string!(name(c))  /+ "&suppression=" /+ string!(Dbo/getDbId(m)))))
				else printf("&nbsp;")),
				getInfo(m),
				(if userCanRead?(menuEdit)
					printf("<a class='hrefAdminEdit' href='~A'><img src='/img/select.png'></a>",
							(getHref(menuEdit,"class=" /+ string!(name(c))  /+ "&id=" /+ string!(Dbo/getDbId(m)))), 
							translate("modifier"))
				else printf("&nbsp;")
				))),
	printf("</table>")]


[htmlTable(tableInfo:string,items:list[any],c:class,menu:WebMenu) : void 
-> htmlTable(tableInfo,items,c,menu,menu,menu)]

// *********************************************************************
// *   Part 2: url generators                                          *
// *********************************************************************


[url_img(app:WebApp,self:string) : string
->	if (app.siteImgUrl[1] = '/')
		(app.siteImgUrl /+ self)
	else 
		(app.siteBaseUrl /+ app.siteImgUrl /+ self)]

[url_img(self:string) : string
->	url_img(webapp(),self)]

[url_webapp_file(app:WebApp,self:string) : string
->	if (app.siteImgUrl[1] = '/')
		(app.siteImgUrl /+ self)
	else 
		(app.siteBaseUrl /+ app.siteImgUrl /+ self)]

[url_webapp_file(self:string) : string
-> url_webapp_file(webapp(),self)]

[url_theme_file(app:WebApp,self:string) : string
->	if (app.siteThemeUrl[1] = '/')
		(app.siteThemeUrl /+ self)
	else
		(app.siteBaseUrl /+ app.siteThemeUrl  /+ self)]

[theme_path() : string
->	if isenv?("WCLSITE_THEME_PATH") getenv("WCLSITE_THEME_PATH")
	else if isenv?("DOCUMENT_ROOT") (
		let root :=  getenv("DOCUMENT_ROOT"),
			p:string := (root / "../themes" / explode(getenv("HTTP_HOST"),".")[1] / "wcl" / "theme")
		in (if (isenv?("HTTP_HOST") & isdir?(p)) p
			else
				(root / "theme"))) else "?"]


[image_path() : string -> 
	if isenv?("WCLSITE_IMAGE_PATH") getenv("WCLSITE_IMAGE_PATH")
	else (let bp := theme_path() in (
			if isdir?((bp / "img")) (bp / "img")
			else if isdir?((bp / "wcl" / "img")) (bp / "wcl" / "img")
			else if isdir?((bp / "../img")) (bp / "../img")
			else if isdir?((getenv("DOCUMENT_ROOT") / "img")) (getenv("DOCUMENT_ROOT") / "img")
			else "??")) as string ]


[url_theme_file(self:string) : string
-> url_theme_file(webapp(),self)]

[url_path(self:WebMenu) : string
->	let base := (if known?(menuParent,self) url_path(self.menuParent) else url_path(webapp()))  
	in (if (known?(menuPath,self) & self.menuPath != "") base :/+ self.menuPath /+ "/",
		base)]


[url_path(self:WebApp) : string
->	if (getenv("WCL_SESSION") != "")
		(self.siteBaseUrl /+ getenv("WCL_SESSION") /+ "/")
	else self.siteBaseUrl]

[url(self:WebMenu) : string ->
	when i := some(m in self.menuChilds | known?(menuFile,m) & m.menuFile = self.menuFile)
	in (url(i))
	else (
		if known?(CURRENT_MENU)
			url_path(self) /+ url_var(CURRENT_MENU) /+ "/" /+ url_var(self) /+ "/" /+ self.menuFile
		else url_path(self) /+ self.menuFile)]

[url_var(self:WebMenu) : string -> "$" /+ string!(name(self))]

[url(self:WebApp) : string
->	(url_path(self)  /+   url_var(self) /+ "/" /+ url_var(self) /+ "/" /+ self.siteIndexFile)]

[url(self:WebMenu,parent:WebMenu) : string
-> url_path(parent) /+ "/" /+ url_var(CURRENT_MENU) /+ "/" /+ url_var(self) /+ "/" /+ self.menuFile]


getHref :: property()

[getHref(h:WebMenu) : string 
-> let res := "" in (
	if known?(menuPath,h) res :/+ h.menuPath /+ "/",
	if known?(menuFile,h) res :/+ h.menuFile,
	res)]

[getHref(h:WebMenu,request:string) : string 
-> let res := "" in (
	if (h.menuPath != "")  res :/+ h.menuPath /+ "/",
	if known?(menuFile,h) res :/+ h.menuFile,
	res :/+ "?" /+ request, 
	res)]

	

// *********************************************************************
// *   Part 3: js redirection tools                                    *
// *********************************************************************


[htmlRedirect(url:string) : void 
-> printf("<script language=javascript>\n document.location.href = '~A'; </script>",url)]

[htmlRedirect(self:WebMenu) : void 
-> htmlRedirect(url(self))]


[htmlRedirect(self:WebApp) : void 
-> htmlRedirect(url(self))]

[htmlRedirectWithSession(self:WebApp) : void 
-> htmlRedirect(self.siteBaseUrl /+   getenv("WCL_SESSION")  /+ "/index.wcl" )]

// Javacript escaper escapre
[claire/escape_quote(src:string) : void ->
	let len := length(src)
	in externC("{
		char *max = src + len;
		char buf[256];
		char *travel = buf;
		while(src < max) {
			int c = (unsigned char)(*src);
			switch(c) {
				case '\\\"':
					{*travel++ = '\\\\';
					*travel++ = '\\\"';
					break;}
				case '\\'':
					{*travel++ = '\\\\';
					*travel++ = '\\\"';
					break;}
				default: *travel++ = c;
			}
			if (travel - buf > 240) {
				Core.write_port->fcall((CL_INT)ClEnv->cout, (CL_INT)buf, (CL_INT)(travel - buf));
				travel = buf;
			}
			src++;
		}
		if (travel - buf > 0)
			Core.write_port->fcall((CL_INT)ClEnv->cout, (CL_INT)buf, (CL_INT)(travel - buf));}")]

