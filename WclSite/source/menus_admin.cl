//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* menu_admin.wcl                                                         *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2012-04-05 10:48:06 +0200 (Jeu 05 avr 2012) $
//*	$Revision: 2096 $
//*********************************************************************

// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: *                                                       *
// *********************************************************************

//-----------------------------------------------------------------------------------
//							MENUS
//-----------------------------------------------------------------------------------
MENU_ADMINISTRATION :: SecureWebMenu(
							menuLargeImage = "administration.png",
							menuSmallImage = "administration_small.png",
							menuPath = "administration/",
							menuGlobal = true,
							menuInfo = "Administration",
							menuSubInfo = "Gestion des utilisateurs et des droits",
							menuFile = "index.wcl")

MENU_ADMINISTRATION_GROUPES :: SecureWebMenu(
							menuParent = MENU_ADMINISTRATION,
							menuInfo = "Groupes",
							menuFile = "groupes.wcl")

MENU_ADMINISTRATION_GROUPE :: WebMenu(
							menuMetaData = "GROUPE",
							menuParent = MENU_ADMINISTRATION_GROUPES,
							menuFile = "groupe_informations.wcl")

MENU_ADMINISTRATION_GROUPE_INFORMATIONS :: WebMenu(
							menuParent = MENU_ADMINISTRATION_GROUPE,
							menuInfo = "Informations",
							menuFile = "groupe_informations.wcl")

MENU_ADMINISTRATION_GROUPE_UTILISATEURS :: WebMenu(
							menuParent = MENU_ADMINISTRATION_GROUPE,
							menuInfo = "utilisateurs",
							menuFile = "groupe_utilisateurs.wcl")


[WclSite/menu_visible?(self:{MENU_ADMINISTRATION_GROUPE_UTILISATEURS}) : boolean
->	$["GROUPE"] & known?(dbId,$["GROUPE"])]
							

MENU_ADMINISTRATION_GROUPE_DROITS :: WebMenu(
							menuParent = MENU_ADMINISTRATION_GROUPE,
							menuInfo = "droits",
							menuFile = "groupe_droits.wcl")

[WclSite/menu_visible?(self:{MENU_ADMINISTRATION_GROUPE_DROITS}) : boolean
-> $["GROUPE"] & known?(dbId,$["GROUPE"]) & known?(groupAbstract?,$["GROUPE"]) & not($["GROUPE"].groupAbstract?)]


MENU_ADMINISTRATION_LANGUES :: SecureWebMenu(
							menuParent = MENU_ADMINISTRATION,
							menuInfo = "langues",
							menuFile = "langues.wcl")


MENU_ADMINISTRATION_LANGUE :: WebMenu(
							menuParent = MENU_ADMINISTRATION_LANGUES,
							menuMetaData = "LANGUE",
							menuFile = "langue.wcl")

MENU_ADMINISTRATION_ORGANIZATIONS :: SecureWebMenu(
							menuParent = MENU_ADMINISTRATION,
							menuInfo = "Sociétés",
							menuFile = "organizations.wcl")

MENU_ADMINISTRATION_ORGANIZATION :: WebMenu(
							menuMetaData = "ORGANIZATION",
							menuParent = MENU_ADMINISTRATION_ORGANIZATIONS,
							menuFile = "organization.wcl")

MENU_ADMINISTRATION_ORGANIZATION_INFORMATION :: WebMenu(
							menuInfo = "Informations",
							menuParent = MENU_ADMINISTRATION_ORGANIZATION,
							menuFile = "organization.wcl")

MENU_ADMINISTRATION_ORGANIZATION_UTILISATEURS :: WebMenu(
							menuInfo = "Utilisateurs",
							menuParent = MENU_ADMINISTRATION_ORGANIZATION,
							menuFile = "organization_users.wcl")

MENU_ADMINISTRATION_ORGANIZATION_CERTIFICAT :: WebMenu(
							menuInfo = "Certificat",
							menuParent = MENU_ADMINISTRATION_ORGANIZATION,
							menuFile = "organization_certificat.wcl")

MENU_ADMINISTRATION_ORGANIZATION_TICKETS :: WebMenu(
							menuInfo = "tickets",
							menuParent = MENU_ADMINISTRATION_ORGANIZATION,
							menuFile = "organization_tickets.wcl")

MENU_ADMINISTRATION_ORGANIZATION_LOGS :: WebMenu(
							menuInfo = "log",
							menuParent = MENU_ADMINISTRATION_ORGANIZATION,
							menuFile = "organization_logs.wcl")

MENU_POPUP_ORGANIZATION_INFORMATION :: SecurePopupMenu(
							menuPopupShowTop = false,
							menuInfo = "Informations société",
							menuParent = MENU_ADMINISTRATION_ORGANIZATION,
							menuFile = "organization_identity.wcl")
							
MENU_ADMINISTRATION_UTILISATEUR :: SecureWebMenu(
							menuMetaData = "UTILISATEUR",
							menuParent = MENU_ADMINISTRATION_ORGANIZATION_UTILISATEURS,
							menuFile = "utilisateur.wcl")

MENU_ADMINISTRATION_UTILISATEUR_INFO :: WebMenu(
							menuParent = MENU_ADMINISTRATION_UTILISATEUR,
							menuInfo = "Informations",
							menuFile = "utilisateur.wcl")

MENU_ADMINISTRATION_UTILISATEUR_GROUPES :: WebMenu(
							menuParent = MENU_ADMINISTRATION_UTILISATEUR,
							menuInfo = "Groupes",
							menuFile = "utilisateur_groupes.wcl")
/*
MENU_ADMINISTRATION_UTILISATEUR_TICKETS :: WebMenu(
							menuParent = MENU_ADMINISTRATION_UTILISATEUR,
							menuInfo = "tickets",
							menuFile = "utilisateur_tickets.wcl")
*/
MENU_ADMINISTRATION_UTILISATEUR_CERTIFICAT :: WebMenu(
							menuParent = MENU_ADMINISTRATION_UTILISATEUR,
							menuInfo = "Certificat",
							menuFile = "utilisateur_certif.wcl")


MENU_ADMINISTRATION_UTILISATEUR_LOGS :: SecureWebMenu(
							menuParent = MENU_ADMINISTRATION_UTILISATEUR,
							menuInfo = "logs",
							menuFile = "utilisateur_log.wcl")

MENU_ADMINISTRATION_UTILISATEURS :: SecureWebMenu(
							menuInfo = "utilisateurs",
							menuParent = MENU_ADMINISTRATION,
							menuFile = "utilisateurs.wcl")

							
MENU_ADMINISTRATION_MONNAIES :: WebMenu(
							menuInfo = "Monnaies",
							menuParent = MENU_ADMINISTRATION,
							menuFile = "monnaies.wcl")
/*
MENU_ADMINISTRATION_TECHNIQUE :: WebMenu(
							menuInfo = "Technique",
							menuParent = MENU_ADMINISTRATION,
							menuFile = "themes.wcl")


MENU_ADMINISTRATION_THEMES :: WebMenu(
							menuInfo = "Thémes",
							menuParent = MENU_ADMINISTRATION_TECHNIQUE,
							menuFile = "themes.wcl")
//<sb> securité

MENU_ADMINISTRATION_TECHNIQUE_CERTIFICAT :: WebMenu(
							menuInfo = "Certificat",
							menuParent = MENU_ADMINISTRATION_TECHNIQUE,
							menuFile = "certificat_root.wcl")

MENU_ADMINISTRATION_TECHNIQUE_CERTIFICAT_RACINE :: WebMenu(
							menuInfo = "Certificat racine",
							menuParent = MENU_ADMINISTRATION_TECHNIQUE_CERTIFICAT,
							menuFile = "certificat_root.wcl")

MENU_ADMINISTRATION_TECHNIQUE_CERTIFICAT_HTTPS :: WebMenu(
							menuInfo = "Certificat HTTPS",
							menuParent = MENU_ADMINISTRATION_TECHNIQUE_CERTIFICAT,
							menuFile = "certificat_https.wcl")

MENU_ADMINISTRATION_TECHNIQUE_CERTIFICAT_APP :: WebMenu(
							menuInfo = "Certificat d'application",
							menuParent = MENU_ADMINISTRATION_TECHNIQUE_CERTIFICAT,
							menuFile = "certificat_app.wcl")

MENU_ADMINISTRATION_TECHNIQUE_CERTIFICAT_CONFIANCE :: WebMenu(
							menuInfo = "Tiers de confiance",
							menuParent = MENU_ADMINISTRATION_TECHNIQUE_CERTIFICAT,
							menuFile = "certificat_trust.wcl")

MENU_ADMINISTRATION_TECHNIQUE_CERTIFICAT_LISTE :: WebMenu(
							menuInfo = "Liste complète",
							menuParent = MENU_ADMINISTRATION_TECHNIQUE_CERTIFICAT,
							menuFile = "certificat_list.wcl")


//</sb>

MENU_ADMINISTRATION_THEME_INFO :: WebMenu(
							menuInfo = "information theme",
							menuParent = MENU_ADMINISTRATION_THEMES,
							menuFile = "theme.wcl")

MENU_ADMINISTRATION_BACKUP :: WebMenu(
							menuInfo = "Sauvegarde",
							menuParent = MENU_ADMINISTRATION_TECHNIQUE,
							menuFile = "backups.wcl")

MENU_ADMINISTRATION_BACKUP_RESTORATION :: WebMenu(
							menuInfo = "Restoration",
							menuParent = MENU_ADMINISTRATION_BACKUP,
							menuFile = "backup_restoration.wcl")

MENU_ADMINISTRATION_BACKUP_CREATION :: WebMenu(
							menuInfo = "Restoration",
							menuParent = MENU_ADMINISTRATION_BACKUP,
							menuFile = "backup_creation.wcl")

MENU_ADMINISTRATION_CRON :: WebMenu(
							menuInfo = "Taches plannifiées",
							menuParent = MENU_ADMINISTRATION_TECHNIQUE,
							menuFile = "cron.wcl")
*/

MENU_ADMINISTRATION_DOCUMENTATION :: WebMenu(
							menuInfo = "Documentation",
							menuParent = MENU_ADMINISTRATION,
							menuFile = "doc.wcl")

MENU_WEBDOC :: SecurePopupMenu(menuInfo = "webdoc",
						menuParent = MENU_ADMINISTRATION_DOCUMENTATION,
						menuFile = "webdoc.wcl")

POPUPMENU_ORGANIZATION :: SecurePopupMenu(menuInfo = "inforomations sociétés",
						menuParent = MENU_ADMINISTRATION,
						menuFile = "organization_identity.wcl")


[menu_visible?(self:{MENU_ADMINISTRATION_DOCUMENTATION}) : boolean -> false]


[createMenuFiles(m:{MENU_ADMINISTRATION_GROUPES}) : void 
-> 	//[0] createMenuFiles ~S // m ,
	for i in m.menuChilds 
		createMenuFiles(i),
	Dbo/sleep(50),
	if (known?(menuFile,m) & not(isfile?(m.menuFile))) (
		let f := fopen(m.menuFile,"a") in (
			use_as_output(f),
			printf("<? 	// ------------ eXpert soLutions - tout droits reserves ~S \n", strftime("%Y",now())),
			printf("	// file generated : ~A \n", strftime("%D %R",now())),
			printf("(include(\"local.conf\"))\n"),
			printf("(WclSite/includeTop())\n"),
			printf("(showMenu(~A))\n \n",string!(m.name)),
			printf("(htmlTable())\n"),
			printf("(WclSite/includeBottom()) ?>"),
			fclose(f),
			Dbo/sleep(100)))]
			


