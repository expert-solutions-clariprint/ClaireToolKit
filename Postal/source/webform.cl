//*********************************************************************
//* Postal                                          Xavier Pehoultres *
//* webmodel.cl                                                       *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*********************************************************************

// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: model                                                   *
// *   Part 2: generic sax handler                                     *
// *   Part 3: parsing strings                                         *
// *   Part 4: parsing ports (blocking)                                *
// *   Part 5: parsing ports (non blocking)                            *
// *********************************************************************

// *********************************************************************
// *   Part 1: model                                                   *
// *********************************************************************


dbid	:: Dbo/dbProperty(Dbo/id? = true)
webuser	:: Dbo/dbProperty()
webgroup	:: Dbo/dbProperty()
created_date	:: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_TIMESTAMP)
ab_label	:: Dbo/dbProperty()


WebAdressBook <: object(
	dbid:integer,
	webuser:WclSite/WebUser,
	webgroup:WclSite/WebUserGroup,
	created_date:float,
	ab_label:string)
	
[Dbo/dbStore?(self:{WebAdressBook}) : boolean -> true]


adress_book	:: Dbo/dbProperty()
updated_date	:: Dbo/dbProperty(Dbo/dbSqlType = Db/SQL_TIMESTAMP)
country_code	:: Dbo/dbProperty()
region_code	:: Dbo/dbProperty()
person_lastname	:: Dbo/dbProperty()
person_name	:: Dbo/dbProperty()
person	:: Dbo/dbProperty()
person_function	:: Dbo/dbProperty()
corp	:: Dbo/dbProperty()
road	:: Dbo/dbProperty()
building	:: Dbo/dbProperty()
azone	:: Dbo/dbProperty()
town	:: Dbo/dbProperty()
postal_code :: Dbo/dbProperty()
box	:: Dbo/dbProperty()
post_office	:: Dbo/dbProperty()
flags	:: Dbo/dbProperty()
addr_data	:: Dbo/dbProperty()
phone	:: Dbo/dbProperty()
phone_mobile	:: Dbo/dbProperty()
fax	:: Dbo/dbProperty()
e_mail	:: Dbo/dbProperty()



WebAdress <: object(
	dbid:integer,
	adress_book:WebAdressBook,
	created_date:float,
	updated_date:float,

	country_code:string = "",
	region_code:string = "",

	person_lastname:string = "",
	person_name:string = "",
	person_function:string = "",
	corp:string = "",
	road:string = "",
	building:string = "",
	azone:string = "",
	town:string = "",
	box:string = "",
	post_office:string = "",
	postal_code:string = "",

	phone:string,
	phone_mobile:string,
	fax:string,
	e_mail:string,

	flags:integer = 0,
	addr_data:string)

[Dbo/dbStore?(self:{WebAdress}) : boolean -> true]




WebAdressFlag <: object(
			flag:integer,
			flag_label:string)
			
[getInfo(self:WebAdressFlag) : string -> translate(self.flag_label)]
	
ADRESSE_LIVRAISON :: WebAdressFlag(flag = 1,
									flag_label = "Adresse de livraison")

ADRESSE_FACTURATION :: WebAdressFlag(flag = 2,
									flag_label = "Adresse de facturation")

ADRESSE_QUAI_CHARGEMENT :: WebAdressFlag(flag = 3,
									flag_label = "Quai de chargement")


[set_flag(self:WebAdress,_flags:list[WebAdressFlag]) : void
->	for i in _flags self.flags :or (1 << i.flag)] 

[set_flag(self:WebAdress,_flag:WebAdressFlag) : void
->	self.flags :or (1 << _flag.flag)] 




[check_flag?(self:WebAdress,_flags:list[WebAdressFlag]) : boolean
->	let f := self.flags in forall(fl in _flags | f[fl.flag])]


[check_flag?(self:WebAdress,aflag:WebAdressFlag) : boolean
->	check_flag?(self,list(aflag))]



AnnuaireMenu <: WclSite/ToolMenu()

[close(self:AnnuaireMenu) : AnnuaireMenu
->	self.WclSite/menuPopupShowTop := false,
	self.WclSite/menuInfo := "Annuaire",
	self.WclSite/menuFile := "postal_annuaire.wcl",
	self.WclSite/menuSmallImage := "annuaire.png",
	self]



[get_adress_books() : list[WebAdressBook]
->	when u := WclSite/get_user() in get_adress_books(u)
	else nil]


[get_adress_books(self:WclSite/WebUser) : list[WebAdressBook]
->	let l := Dbo/dbLoadWhere(WclSite/get_admin_database(),
								WebAdressBook,list(dbid,webuser,ab_label),list(tuple(webuser,self)))
	in (if l l 
		else
			(let a := WebAdressBook(webuser = self, ab_label = self.WclSite/usrFullName, created_date = now())
			in (Dbo/dbCreate(WclSite/get_admin_database(),a),
				list(a))))]


[get_adresses() : list[WebAdress]
->	when u := WclSite/get_user() in get_adresses(u)
	else nil]

[get_adresses(self:WclSite/WebUser) : list[WebAdress]
->	let ab := get_adress_books(self)
	in (Dbo/dbLoadWhere(WclSite/get_admin_database(),
						WebAdress,Dbo/dbProperties(WebAdress),list(tuple(adress_book,ab)),person_lastname,true))]
	




