//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* init.wcl                                                           *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2010-09-21 16:01:26 +0200 (Mar 21 sep 2010) $
//*	$Revision: 2053 $
//*********************************************************************


(use_module("Dbo/v1.0.0"))
(use_module("LibLocale"))
(use_module("Mail"))
(use_module("Md5"))
(use_module("Wcl"))
(use_module("Soap"))

//(verbose() := 4)




WclSite :: module(
	uses = list(Core, Wcl, Db, Dbo, Md5, LibLocale, Mail, Soap),
//	part_of = Wcl,
	made_of = list( "model.cl",
					"langue.cl",
					"user.cl",
					"certificat.cl", //<sb> add
					"accueil.cl",
					"html.cl",
					"menus_admin.cl",
					"sites.cl",
					"erreurs.cl",
					"form.cl",
					"menus.cl",
					"site_fichiers.cl",
					"monnaie.cl",
					"options.cl",
					"webdoc.cl",
					"index.cl",
					"session.cl",
					"tickets.cl",
					"dbupdate.cl",
					"install_update.cl"),
	source = "source",
	version = "v2.0.0") // put your version here

// (add_wcl(WclSite,"source","*.wcl","administration"))

(load(WclSite))
