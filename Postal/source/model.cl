//*********************************************************************
//* Postal                                          Xavier Pehoultres *
//* model.cl                                                          *
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

/*
country_code	:: Dbo/dbProperty()
region_code	:: Dbo/dbProperty()
person		:: Dbo/dbProperty()
person_function	:: Dbo/dbProperty()
corp		:: Dbo/dbProperty()
road		:: Dbo/dbProperty()
building	:: Dbo/dbProperty()
azone		:: Dbo/dbProperty()
town		:: Dbo/dbProperty()
box			:: Dbo/dbProperty()
post_office	:: Dbo/dbProperty()
addr_data	:: Dbo/dbProperty()
*/


postal_address <: ephemeral_object(	
		country_code:string = "",
		region_code:string = "",
		person:string = "",
		person_function:string = "",
		corp:string = "",
		road:string = "",
		building:string = "",
		azone:string = "",
		town:string = "",
		box:string = "",
		post_office:string = "",
		addr_data:string)


[address_serialize(self:postal_address,p:port) : void
->	  printf(p,"ADR1;~A;~A;~A;~A;~A;~A;~A;~A;~A;~A;~A;",
					url_encode(self.country_code),
					  url_encode(self.region_code),
  						   url_encode(self.person),
  							  url_encode(self.person_function),
  								 url_encode(self.corp),
  									url_encode(self.road),
  									   url_encode(self.building),
  										  url_encode(self.azone),
  											 url_encode(self.town),
  												url_encode(self.box),
  												   url_encode(self.post_office))]

[address_serialize(self:postal_address) : string
->	print_in_string(),
	address_serialize(self,cout()),
	end_of_string()]			

/*
private/TEST_ADRESS :: postal_address(	
									country_code = "FRA",
									region_code = "FR-33",
									person = "Xavier Péchoultres",
									person_function = "Directeur",
									corp = "eXpert soLutions SARL",
									road = "19bis, rue Marc Tallavi",
									building = "",
									azone = "",
									town = "LORMONT",
									box = ""	,
									post_office = "33310")

*/

[address_unserialize(self:string) : postal_address
->	if (left(self,5) = "ADR1;") (
		let a := explode(self,";")
		in (postal_address(	
							country_code = url_decode(a[2]),
							region_code = url_decode(a[3]),
							person = url_encode(a[4]),
							person_function = url_decode(a[5]),
							corp = url_decode(a[6]),
							road = url_decode(a[7]),
							building = url_decode(a[8]),
							azone = url_decode(a[9]),
							town = url_decode(a[10]),
							box = url_decode(a[11]),
							post_office = url_encode(a[12]))))
	else (postal_address(addr_data = self))]


[address!(self:string) : postal_address 
->	address_unserialize(self)]

[Dbo/value!(db:Db/Database, self:string, rg:{postal_address}) : postal_address -> address_unserialize(self)]

[Dbo/dbPrint(db:Db/Database, self:postal_address) : void ->	Dbo/dbPrint(db,address_serialize(self))]


[parse_form_data(prefix:string, formData:table) : (postal_address U {unknown})
->	let a :=  postal_address()
	in (if formData[prefix /+ "address_country_code"]
			a.country_code := formData[prefix /+ "address_country_code"]
		else a.country_code := "",
		if formData[prefix /+ "address_region_code"]
			a.region_code := formData[prefix /+ "address_region_code"]
		else a.region_code := "",
		if formData[prefix /+ "address_person"]
			a.person := formData[prefix /+ "address_person"]
		else a.person := "",
		if formData[prefix /+ "address_person_function"]
			a.person_function := formData[prefix /+ "address_person_function"]
		else a.person_function := "",
		if formData[prefix /+ "address_corp"]
			a.corp := formData[prefix /+ "address_corp"]
		else a.corp := "",
		if formData[prefix /+ "address_road"]
			a.road := formData[prefix /+ "address_road"]
		else a.road := "",
		if formData[prefix /+ "address_building"]
			a.building := formData[prefix /+ "address_building"]
		else a.building := "",
		if formData[prefix /+ "address_azone"]
			a.azone := formData[prefix /+ "address_azone"]
		else a.azone := "",
		if formData[prefix /+ "address_town"]
			a.town := formData[prefix /+ "address_town"]
		else a.town := "",
		if formData[prefix /+ "address_box"]
			a.box := formData[prefix /+ "address_box"]
		else a.box := "",
		if formData[prefix /+ "address_post_office"]
			a.post_office := formData[prefix /+ "address_post_office"]
		else a.post_office := "",
		a)]

[show_form(self:(postal_address U {unknown}),prefix:string) : void
->	if unknown?(self) self := postal_address(),
	?>
<table class="t_postal_address">
	<tr>
		<th><?== translate("Nom") ?></th>
		<td><input type=text name="<?= prefix ?>address_person" value="<?= self.person ?>"></td>
	</tr>
	<tr>
		<th><?== translate("Fonction") ?></th>
		<td><input type=text name="<?= prefix ?>address_person_function" value="<?= self.person_function ?>"></td>
	</tr>
	<tr>
		<th><?== translate("Société") ?></th>
		<td><input type=text name="<?= prefix ?>address_corp" value="<?= self.corp ?>"></td>
	</tr>
	<tr>
		<th><?== translate("Voie") ?></th>
		<td><textarea rows=2 cols=30 name="<?= prefix ?>address_road"><?== self.road ?></textarea></td>
	</tr>
	<tr>
		<th><?== translate("Bâtiments") ?></th>
		<td><input type=text name="<?= prefix ?>address_building" value="<?= self.building ?>"></td>
	</tr>
	<tr>
		<th><?== translate("Zone Industrielle") ?></th>
		<td><input type=text name="<?= prefix ?>address_azone" value="<?= self.azone ?>"></td>
	</tr>
	<tr>
		<th><?== translate("Boîte Postale") ?></th>
		<td><input type=text name="<?= prefix ?>address_box" value="<?= self.box ?>"></td>
	</tr>
	<tr>
		<th><?== translate("Ville") ?></th>
		<td><input type=text name="<?= prefix ?>address_town" value="<?= self.town ?>"></td>
	</tr>
	<tr>
		<th><?== translate("Code Postal") ?></th>
		<td><input type=text name="<?= prefix ?>address_post_office" value="<?= self.post_office ?>"></td>
	</tr>
	<tr>
		<th><?== translate("Code Pays") ?></th>
		<td><input type=text name="<?= prefix ?>address_country_code" value="<?= self.country_code ?>"></td>
	</tr>
	<tr>
		<th><?== translate("Code Régionnal") ?></th>
		<td><input type=text name="<?= prefix ?>address_region_code" value="<?= self.region_code ?>"></td>
	</tr>
</table><? ]
