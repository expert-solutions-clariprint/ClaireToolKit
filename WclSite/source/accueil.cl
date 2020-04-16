//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* accueil.cl                                                        *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2008-03-14 15:11:27 +0100 (Ven 14 mar 2008) $
//*	$Revision: 1969 $
//*********************************************************************


// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: tools                                                   *
// *********************************************************************


// *********************************************************************
// *   Part 1: tools                                                   *
// *********************************************************************

// affiche un tableau de liens vers les menu principaux
[printIndexPage(css: string) : void 
-> printIndexPage(css,2)]

// affiche un tableau de liens vers les menu principaux
[printIndexPage(css: string, nbCols:integer) : void 
-> let 	nbRow:integer := 0,
		col:integer := 0,
		row:integer := 0
	in (printf("<table ~A>\n",css),
		for m in CURRENT_WEB_SITE.menuChilds
			(if menu_visible?(m)
			(//[0] ici,
			printf("~I<td>~I~I~I~I</td>",
					(if (col = nbCols) (printf("<tr>"), col := 0), col :+ 1 ),
					(if (userCanRead?(m)) printf("<a href='~I'>",
							(
							 if (known?(siteBaseUrl,CURRENT_WEB_SITE))
								printf("~A",CURRENT_WEB_SITE.siteBaseUrl), 
							 if known?(menuPath,m)
							 	printf("~A",m.menuPath),
							 if known?(menuFile,m)
							 	printf("/~A",m.menuFile)))),
					(if known?(menuLargeImage,m)
						printf("<img src='~A'><br>",m.menuLargeImage)),
					(if known?(menuInfo,m)
						printf("~A",translate(m.menuInfo))),
					(if (userCanRead?(m)) printf("</a>"))))),
		printf("</table>"))]


[print_index() : void
-> print_index(webapp())]

[insert_index_left(self:WebApp) : void -> none]
(abstract(insert_index_left))
[insert_index_right(self:WebApp) : void -> none]
(abstract(insert_index_right))

[print_index(self:WebMenu) : void
->	//[-100] print_index(~S) // self,
	let nbCols := 2,
		nbRow:integer := 0,
		col:integer := 0,
		row:integer := 0,
		subs := list{ mm in self.menuChilds  | menu_visible?(mm) & userCanAccess?(mm) }
	in (insert_index_left(self),
		?>
		<table class=app_list>
			<tbody>
			<tr><? ,
		for m in subs
			(printf("~I<td>~I</td>\n",
					(if (col = nbCols) (
							if (row = 0) insert_index_right(self),
							row :+ 1,
							printf("<tr>\n"), col := 0)),
					(if (print_subindex(m) = true) (col :+ 1 )))),
		if (row = 0) (insert_index_right(self),printf("<tr>\n")),
	( ?></tbody></table><? ),
		if (length(subs) = 1) htmlRedirect(subs[1]))]
	
(abstract(print_index))

[print_subindex(self:WebMenu) : boolean
->	if not(userCanRead?(self)) false
	else (printf("<table align=center class=wclsite_index_soustable>
			<tr><td class=td_menuLargeImage><a href='~A'>~I</a></td>
			<tr><td class=td_menuInfo><a href='~A'>~I</a></td>
			<tr><td class=td_menuSubInfo><a href='~A'>~I</a></td></tr>
			</table>",
			(url(self)),
			(if known?(menuLargeImage,self)
				printf("<img src='~A'>",url_webapp_file(self.menuLargeImage))),
			(url(self)),
			(if known?(menuInfo,self)
				printf("~A",translate(self.menuInfo))),
			(url(self)),
			(if known?(menuSubInfo,self)
				printf("~A",translate(self.menuSubInfo)))),
			true)]


[print_subindex(self:WebApp) : boolean
-> 	if not(userCanAccess?(self)) false
	else (printf("<table align=center class=wclsite_index_soustable>
					<tr><td class=td_menuLargeImage>~I</td>
					<tr><td class=td_menuInfo>~I</td>
					<tr><td class=td_menuSubInfo>~I</td>
					</tr>
				</table>",
			(if known?(siteLargePicture,self)
				printf("<a href='~A'><img src='~A'></a>",url(self),url_webapp_file(self,self.siteLargePicture))),
			(if known?(siteFullName,self)
				printf("<a href='~A'>~A</a>",url(self),translate(self.siteFullName))),
			(if known?(siteDescription,self)
				printf("~A",translate(self.siteDescription)))),
		true)]

