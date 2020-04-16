//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* site_fichiers.wcl                                                         *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2005-08-16 10:33:21 +0200 (Mar 16 aoû 2005) $
//*	$Revision: 997 $
//*********************************************************************


// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: *                                                       *
// *********************************************************************



[createMenuFiles(m:WebMenu) : void 
-> 	//[0] createMenuFiles ~S // m ,
	for i in m.menuChilds 
		createMenuFiles(i),
	Dbo/sleep(50),
;	//[0] createMenuFiles 2 ~S ~S // m ,  m.menuFile,
	if (known?(menuFile,m) & not(isfile?(m.menuFile))) (
		let f := fopen(m.menuFile,"a") in (
			use_as_output(f),
			printf("<? 	// ------------ eXpert soLutions - tout droits reserves ~S \n", strftime("%Y",now())),
			printf("	// file generated : ~A \n",strftime("%D %R",now())),
			printf("(include(\"local.conf\"))\n"),
			printf("(WclSite/includeTop())\n"),
			printf("(showMenu(~I~A))\n ?>\n",
				(if (module!(m.name) != module!()) (princ(string!(module!(m.name).name)), princ("/"))),
				string!(m.name)),
			printf("Put your code here !\n\n"),
			printf("<? (WclSite/includeBottom()) ?>"),
			fclose(f),
			Dbo/sleep(100)))]
			
			
[createLocalConf(m:WebMenu,s:WebApp) : void 
-> 	//[0] createLocalConf ~S // m ,
	if not(isfile?("local.conf")) (
		let f := fopen("local.conf","a") in (
			use_as_output(f),
			printf("<? 	// ------------ eXpert soLutions - tout droits reserves ~S \n", strftime("%Y",now())),
			printf("	// file generated : ~A \n", strftime("%D %R",now())),
			printf("(include(\"../global.conf\")) \n"),
			printf("(~S.siteSelectedGlobalMenu := ~S)\n ?>",s,m),
			fclose(f)))]


[createUtilsFiles(s:WebApp) : void
-> 	//[0] createUtilsFiles ~S // s ,
	if not(isfile?("index.wcl")) fclose(fopen("index.wcl","a")),
	if not(isdir?("sitetheme")) (
		mkdir("sitetheme"),
		sleep(50),
		setcwd("sitetheme"),
		fclose(fopen("style.css","a")),
		fclose(fopen("inc_top.wcl","a")),
		fclose(fopen("inc_bottom.wcl","a")),
		setcwd(".."))]

[createGlobalConf(s:WebApp) : void 
-> //[0] createGlobalConf ~S // s ,
	if not(isfile?("global.conf")) (
		let f := fopen("global.conf","a") in (
			use_as_output(f),
			printf("<? 	// ------------ eXpert soLutions - tout droits reserves ~S \n", strftime("%Y",now())),
			printf("	// file generated : ~A \n",  strftime("%D %R",now())),
			printf("	// CONFIGURATION FILE FOR ~A \n\n", string!(s.name)),
			printf("WEBSITE :: ~A\n",string!(s.name)),
			
			printf("(WEBSITE.siteFullName := ~S)\n",s.siteFullName),
			printf("(WEBSITE.siteDescription := ~S)\n",s.siteDescription),
			printf("(WEBSITE.siteRootPath := ~S)\n",s.siteRootPath),
			printf("(WEBSITE.siteBaseUrl := ~S)\n\n",s.siteBaseUrl),
			
			printf("INC_TOP :: (WEBSITE.siteRootPath / \"sitetheme\" / \"inc_top.wcl\")\n"),
			printf("INC_BOTTOM :: (WEBSITE.siteRootPath / \"sitetheme\" / \"inc_bottom.wcl\")\n"),
			printf("?>"),
			fclose(f)))]
	
	

[createMainSiteFiles(s:WebApp) : void
-> 	//[0] createMainSiteFiles ~S // s ,
	if not(isfile?("index.wcl")) fclose(fopen("index.wcl","a")),
	if not(isfile?("verification.wcl")) fclose(fopen("verification.wcl","a")),
	createGlobalConf(s)]

		


[createSite(s:WebApp) : void 
-> 	// se deplacer dans le bon dossier
	//[0] createSite ~S // s ,
	setcwd(s.siteRootPath),
	for i in s.siteGlobalsMenu (
		if not(isdir?(i.menuPath))
			mkdir(i.menuPath),
		sleep(50),
		setcwd(i.menuPath),
		//[0] createSite 2,
		createMenuFiles(i),
		//[0] createSite 3,
		createLocalConf(i,s),
		setcwd(s.siteRootPath)
		),
	//[0] createSite 4,
	setcwd(s.siteRootPath),
	createUtilsFiles(s),	
	createMainSiteFiles(s)
]
