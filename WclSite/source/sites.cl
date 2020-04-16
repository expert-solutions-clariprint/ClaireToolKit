//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* sites.wcl                                                         *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2005-10-04 16:25:55 +0200 (Mar 04 oct 2005) $
//*	$Revision: 1175 $
//*********************************************************************


// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: *                                                       *
// *********************************************************************


[showGlobalsMenu(s:WebApp) : void
->	printf("<table class='tableGlobalMenu'>\n"),
	if known?(siteSmallPicture,s) 
		printf("<tr><td align=center><img alt='logo' class='smallImgSite' src=~S></td></tr>",s.siteBaseUrl /+ s.siteSmallPicture  ),
	
	printf("<tr><td class=titreSite>~A</td></tr>\n",s.siteFullName),
	for i in s.siteGlobalsMenu (
		if (userCanRead?(i)) (
			printf("<tr class=~S><td class=~S><a href=~S class=~S>~A</a></td></tr>\n",
				(if (i = s.siteSelectedGlobalMenu) "trGlobalMenuSelected" else "trGlobalMenu"),
				(if (i = s.siteSelectedGlobalMenu) "tdGlobalMenuSelected" else "tdGlobalMenu"),
				(s.siteBaseUrl /+ i.menuPath /+ "/" /+ i.menuFile  ),
				(if (i = s.siteSelectedGlobalMenu) "tdGlobalMenuSelected" else "tdGlobalMenu"),
				getInfo(i)))),
	
	printf("<tr class='trGlobalMenuQuit'><td class='tdGlobalMenuQuit'><a href=~S class='tdGlobalMenuQuit'>~A</a></td></tr>\n",
			s.siteBaseUrl,translate("Quitter")),	
	printf("</table>\n")]

[includeThemeFile(app:WebApp,self:string) : void 
->	if (app.siteThemePath[1] = '/' | app.siteThemePath[2] = ':')
		include(app.siteThemePath /+ self)
	else (include(app.siteRootPath /+ app.siteThemePath /+ self))]

[includeThemeFile(self:string) : void 
->	includeThemeFile(webapp(),self)]

[includeTop() : void 
-> //[-100] includeTop() ,
	none]
	// includeThemeFile(webapp().siteThemeDefaultTop)]

[includeBottom() : void 
-> none]
	//includeThemeFile(webapp().siteThemeDefaultBottom)]



