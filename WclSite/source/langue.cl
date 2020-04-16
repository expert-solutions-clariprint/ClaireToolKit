//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* langue.cl                                                           *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2010-09-21 16:01:26 +0200 (Mar 21 sep 2010) $
//*	$Revision: 2053 $
//*********************************************************************


// compatibility layer with old language model for the Locale module


MODE_APPRENTISSAGE:boolean := false

// Classe contenant la liste des langues
langName :: Dbo/dbProperty()

WebLangue <: ephemeral_object(
			dbId:integer,
			langName:string = "Nouvelle langue")

[Dbo/dbStore?(c:{WebLangue}) : boolean -> true]

trLangue :: Dbo/dbProperty()
trReference :: Dbo/dbProperty()
trTraduction :: Dbo/dbProperty()
trSite :: Dbo/dbProperty()

// Table de traduction
Traduction <: ephemeral_object(
			dbId:integer,
			trSite:string,
			trLangue:WebLangue,
			trReference:string,
			trTraduction:string)
			
[Dbo/dbStore?(c:{Traduction}) : boolean -> true]


[instantiate_locale_from_db(save_xml:boolean) : void ->
	for lang in Dbo/dbLoad(LANG_DATABASE, WebLangue)
		let isoc := lang.langName
		in for trad in Dbo/dbLoad(LANG_DATABASE, Traduction, list(tuple(trLangue, lang)))
			LibLocale/insert_term(upper(isoc), trad.trSite, trad.trReference, trad.trTraduction),
	if save_xml LibLocale/save_xml()]

[instantiate_locale_from_db() : void -> instantiate_locale_from_db(true)]

claire/translate :: LibLocale/translate
claire/applicable_translate :: LibLocale/applicable_translate


/*
session_locale <: ephemeral_object(
		iso:LibLocale/ISO_CODE)

[close(self:session_locale) : session_locale ->
	(LibLocale/set_locale(self.iso),
	LibLocale/set_applicable(topapp().siteId),
	self)]

[register_locale(self:LibLocale/ISO_CODE) : void ->
	(register("CURRENT_LOCALE", session_locale(iso = self)))]

*/