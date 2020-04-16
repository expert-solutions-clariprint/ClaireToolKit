//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* webdoc.wcl                                                         *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2012-04-05 10:48:06 +0200 (Jeu 05 avr 2012) $
//*	$Revision: 2096 $
//*********************************************************************


// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: *                                                       *
// *********************************************************************

[getDocItem(self:WebMenu) : string
->	if known?(menuDocItem,self) self.menuDocItem
	else if known?(menuParent,self) getDocItem(self.menuParent)
	else ""]

[getDocItem(self:WebApp) : string
->	if known?(menuDocItem,self) self.menuDocItem
	else string!(name(self))]


[print_doc_url(self:WebMenu) : void
->	if (getenv("EXTERNAL_WEB_DOC") != "")
		(	?><?= translate(getenv("EXTERNAL_WEB_DOC")) ?><?= translate(getDocItem(self)) ?><? )
	else 
		?><?= url(MENU_WEBDOC) ?>?lang=<?= LibLocale/get_locale() ?>&current_menu=<?= string!(name(self)) ?>&current_app=<?= webapp(self).siteId ?><? ]

[print_doc_url(self:string) : void
->	if (getenv("EXTERNAL_WEB_DOC") != "")
		(	?><?= translate(getenv("EXTERNAL_WEB_DOC")) ?><?= translate(self) ?><? )
	else 
		?><?= url(MENU_WEBDOC) ?>?lang=<?= LibLocale/get_locale() ?><? ]

[print_doc_link(self:WebMenu,large?:boolean)
->	?><div class="doc"
		onclick="window.open('<? (print_doc_url(self)) ?>','doc_clariprint','menubar=no,resizable=yes,scrollbars=yes');"
		title="Help - Aide"><img class="doc" 
		alt="help"
		src="/img/<?= (if large? "aide" else "aide_mini") ?>.png"><?= translate("Help") ?></div><? ]

[print_doc_link(self:string,large?:boolean)
->	print_doc_link(self,"Help",large?)]

[print_doc_link(self:string,txt:string,large?:boolean)
->	?><div class="doc"
		title="Help - Aide"
		onclick="window.open('<? (print_doc_url(self)) ?>','doc_clariprint','menubar=no,resizable=yes,scrollbars=yes');">
		<img class="doc" 
		alt="help"
		src="/img/<?= (if large? "aide" else "aide_mini") ?>.png"><?= translate(txt) ?></div><? ]
