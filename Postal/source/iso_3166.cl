//*********************************************************************
//* Postal                                          Xavier Pehoultres *
//* iso_3166.cl                                                       *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2016-10-19 11:14:02 +0200 (Mer 19 oct 2016) $
//*	$Revision: 2149 $
//*********************************************************************

// *********************************************************************
// *  Table of contents                                                *
// *   Part 0: introduction                                                   *
// *   Part 1: model                                                   *
// *   Part 2: API                                                     *
// *   Part 3: generic sax handler                                     *
// *********************************************************************

// *********************************************************************
// *   Part 0: introduction                                                   *
// *********************************************************************
/*

Implémentation des normes ISO 3166 et ISO 3166-2 concernant les codes
ISO des pays et region administratives.
Le découpage par continent par sous continent proviens de l'ONU.

Références ISO :
http://www.statoids.com/
http://fr.wikipedia.org/wiki/ISO_3166

Références ONU :
http://unstats.un.org/unsd/methods/m49/m49regin.htm


PS : Pour UK, nous utilisons le découpage Postal en place du découpage
ISO pour des raisons pratiques.

*/
// *********************************************************************
// *   Part 1: model                                                   *
// *********************************************************************

POSTAL_TRACE_XML :: 4

zone <: ephemeral_object
continent <: zone
subcontinent <: zone
country <: zone
region <: zone

zone <: ephemeral_object(
				iso2:string,
				iso:string,
				uncode:integer,
				label:string,
				oversea?:boolean = false,
				parent:zone,
				allzones:table,
				subzones:list[zone])

(inverse(subzones) := parent)

worldzone <: zone(codes:table,
				worldcountries:list[country])

continent <: zone(
		countries:list[country])

subcontinent <: zone()
country <: zone(
		zcontinent:continent,
		zworld:worldzone,
		regions:list[region])

(inverse(zworld) := worldcountries)
(inverse(zcontinent) := countries)

region <: zone(
			zcountry:country,
			postal:string)

(inverse(zcountry) := regions)



DEFAULT_FILE_NAME :: "iso3166.xml"

DEFAULT_FILE: string := "source/iso3166.xml"

DEFAULT_WORLD:worldzone := unknown


// *********************************************************************
// *   Part 2: API                                                     *
// *********************************************************************


[set_data_path(p:string) : void
->	DEFAULT_FILE := p / DEFAULT_FILE_NAME,
	if not(isfile?(DEFAULT_FILE))
		//[0] WARNING : Postal file ~S not in path ~S ! // DEFAULT_FILE_NAME,p
		]
//		error("Postal file ~S not in path ~S !",DEFAULT_FILE_NAME,p)]

[get_world() : (worldzone U {unknown})
-> get_world(DEFAULT_FILE)]

[get_world(filename:string) : (worldzone U {unknown})
->	if unknown?(DEFAULT_WORLD) (
		try DEFAULT_WORLD := xml_load(filename)
		catch any //[-100] ERROR : xml load error : ~S // exception!()
		),
	DEFAULT_WORLD]

[xml_load() : worldzone	=> xml_load(DEFAULT_FILE)]


[get_countries() : list[country]
->	when w := get_world()
	in sort(sort_countries @ country, w.worldcountries)
	else nil]

[sort_countries(a:country,b:country) : boolean
->	a.label < b.label]

[get_country(self:string) : (country U {unknown})
->	when w := get_world() in (
		when c := w.allzones[self] in 
			(case c (country c, any unknown))
		else unknown)		
	else unknown]

[get_zone(iso:string) : (zone U {unknown})
->	when x := get_world() 
	in x.allzones[iso] as (zone U {unknown}) else unknown]

[get_regions(iso:string) : list[region] -> when c := get_country(iso) in regions(c) else nil]

// *********************************************************************
// *   Part 3: generic sax handler                                     *
// *********************************************************************

[start_handler(parser:Sax/sax_parser, self:worldzone,elem:{"world"},attr:table) : worldzone
->	//[POSTAL_TRACE_XML] start_handler@worldzone(~S,~S,~S ...) // self,elem, attr["label"],
	when i := attr["uncode"]  in self.uncode := integer!(i),
	self.label := attr["label"],
	self.allzones := make_table(string,(zone U {unknown}),unknown),
	self]

[start_handler(parser:Sax/sax_parser, self:worldzone,elem:{"continent"},attr:table) : continent
->	//[POSTAL_TRACE_XML] start_handler@worldzone(~S,~S,~S ...) // self,elem, attr["label"],
	let c := continent()
	in (c.parent := self,
		c.allzones := self.allzones,
		c.label := attr["label"],
		when x := attr["iso2"] 	in c.iso2 := x,
		when x := attr["iso"] 	in c.iso := x,
		when i := attr["uncode"] in c.uncode := integer!(i),
//		c.uncode := integer!(attr["uncode"]),
		c)]

[start_handler(parser:Sax/sax_parser, self:continent,elem:{"subcontinent"},attr:table) : subcontinent
->	//[POSTAL_TRACE_XML] start_handler@continent(~S,~S,~S ...) // self,elem, attr["label"],
	let c := subcontinent()
	in (c.parent := self,
		c.allzones := self.allzones,
		c.label := attr["label"],
		when x := attr["iso2"] in c.iso2 := x,
		when x := attr["iso"] in c.iso := x,
		when i := attr["uncode"] in c.uncode := integer!(i),
		c)]

[start_handler(parser:Sax/sax_parser, self:(subcontinent U continent),elem:{"country"},attr:table) : country
->	//[POSTAL_TRACE_XML] start_handler@subcontinent(~S,~S,~S ...) // self,elem, attr["label"],
	let c := country()
	in (c.parent := self,
		case self (
			subcontinent (c.zcontinent := self.parent as continent,
						c.zworld := c.zcontinent.parent as worldzone),
			continent (c.zcontinent := self,
						c.zworld := c.zcontinent.parent as worldzone)),
		c.allzones := self.allzones,
		c.label := attr["label"],
		when x := attr["iso2"] in (c.iso2 := x, c.allzones[c.iso2] := c),
		when x := attr["iso"] in (c.iso := x, c.allzones[c.iso] := c),
		when i := attr["uncode"] in c.uncode := integer!(i),
		c)]

[start_handler(parser:Sax/sax_parser, self:(country U region),elem:{"region"},attr:table) : region
->	//[POSTAL_TRACE_XML] start_handler@country(~S,~S,~S ...) // self,elem, attr["label"],
	let c := region()
	in (c.parent := self,
		c.allzones := self.allzones,
		case self (
			country (c.zcountry := self),
			region (c.zcountry := self.zcountry)),
		c.label := attr["label"],
		c.oversea? := (attr["oversea"] = "true"),
		when x := attr["iso2"] in (c.iso2 := x, c.allzones[c.iso2] := c),
		when x := attr["iso"] in (c.iso := x, c.allzones[c.iso] := c),
		when i := attr["uncode"] in c.uncode := integer!(i),
		c.allzones[c.iso] := c,
//		c.iso := integer!(attr["worldzone"]),
		c)]

[end_handler(parser:Sax/sax_parser, self:zone,elem:string,data:string) : void 
->	/*
	if (verbose(Postal) >= POSTAL_TRACE_XML & trim(data) != "")
		//[POSTAL_TRACE_XML] WARNING data in ~S ~S ~S // zone,elem,data,
	*/
	none]


[xml_load(filename:string) : worldzone
->	let f := fopen(filename,"r"),
		zw := worldzone(codes = make_table(string,zone,unknown))
	in	(Sax/sax(f,start_handler,end_handler,zw),
		fclose(f),
		zw)]

[self_print(self:zone) : void
->	printf("<~A:~A:~A>",
			(if known?(iso,self) self.iso else "-"),
				(length(self.subzones)),
					(if known?(label,self) self.label else "-"))]


AjaxPostalMenu <: WclSite/UploadMenu()
WizardPostalMenu <: WclSite/PopupMenu()

[close(self:AjaxPostalMenu) : AjaxPostalMenu
->	self.WclSite/menuPopupShowTop := false,
	self.WclSite/menuInfo := "Ajax Postal Fake Menu",
	self.WclSite/menuFile := "ajax_zone.wcl",
	self]

[close(self:WizardPostalMenu) : WizardPostalMenu
->	self.WclSite/menuPopupShowTop := false,
	self.WclSite/menuInfo := "Wizard Postal Fake Menu",
	self.WclSite/menuFile := "postal_zone_wizard.wcl",
	self]


[load_wcl(self:{"*/ajax_html_zone.wcl"}) : void
->	if $["getcountries"] (
		when c := get_countries()
		in ( ?><select name="<?= $["select_name"] ?>"> <option value=""><?== translate("choisir") ?> ...</option><? ,
			for i in c ( ?><option value="<?== i.Postal/iso ?>" <? (if ($["country"] & $["country"] = i.iso) echo("selected")) ?>><?== i.Postal/label ?></option><? ),
			 ?></select><? )),
	if $["getregionsof"] (
		when c := get_country($["getregionsof"]) 
		in (if $["select_name"] ( ?><select name="<?= $["select_name"] ?>" id="<?= $["select_name"] ?>"><? ),
			for i in c.Postal/regions (
				?><option value="<?== i.iso ?>" <? (if ($["select_code"] & $["select_code"] = i.iso) echo("selected")) ?>><?== i.Postal/label ?></option><? ),
			if $["select_name"] ( ?></select><? )))]

[load_wcl(self:{"*/ajax_zone.wcl"}) : void
->	header("Content-Type: text/xml"),
	if $["getcountries"] (
		when c := get_countries()
		in ( printf("<? xml version=\"1.0\" encoding=\"UTF-8\" >\n"), ?>
<postal><? ,
			for i in c ( ?><country value="<?== i.Postal/iso ?>" <? (if ($["country"] & $["country"] = i.iso) echo("selected")) ?>><?== i.Postal/label ?></option><? ),
			 ?></postal><? )),
	if $["getregionsof"] (
		when c := get_country($["getregionsof"]) 
		in ( printf("<? xml version=\"1.0\" encoding=\"UTF-8\" >\n") , ?>
<postal><? ,
			for i in c.Postal/regions ( ?>
	<region iso="<?= i.iso ?>" label="<?= i.Postal/label ?>" /><? ), ?>
</postal><? ))]


[showCountrySelector(text_name:string,zcode:any)
->	?><select name="<?= text_name ?>">
<? (for i in get_countries() ( ?>
	<option value="<?= i.iso ?>" <? (if (zcode = i.iso) echo("selected")) ?>><?== i.label ?></option><? )) ?>
	</select><? ]

[showZoneFormData(text_name:string,zcode:any) : void
->	when m := WclSite/get_menu()
	in (showZoneFormData(WizardPostalMenu(WclSite/menuParent = m), text_name,zcode))]

[showZoneFormData(menu:WizardPostalMenu,text_name:string,zcode_iso:any) : void
->	let u := uid(),
		zcode := (case zcode_iso (string zcode_iso, any ""))
	in (when mz := get_zone(zcode) in (
		?><input name="<?= text_name ?>" id="<?= u ?>" type="text" value="<?= zcode ?>" size="6" Readonly><input type=button value="<?== translate("choisir") ?>"
			onclick="javascript:window.open('<?= WclSite/url(menu) ?>?from_zone=<?= zcode ?>&elem_id=<?= u ?>','ISO_Code','menubar=off,height=150px,width=500px')"><? ) 
		else (
		?><input name="<?= text_name ?>" id="<?= u ?>" type="text" value="" size="6" Readonly><input type=button value="<?== translate("choisir") ?>"
			onclick="javascript:window.open('<?= WclSite/url(menu) ?>?elem_id=<?= u ?>','ISO_Code','menubar=off,height=150px,width=500px')"><? ))]


[showCountryZoneFormData(textinput_country_id:string,textinput_zone_id:string) : void
->	when m := WclSite/get_menu()
	in (showCountryZoneFormData(WizardPostalMenu(WclSite/menuParent = m), textinput_country_id,textinput_zone_id))]

[showCountryZoneFormData(menu:WizardPostalMenu,textinput_country_id:string,textinput_zone_id:string) : void
-> ?><input type=button value="<?== translate("choisir") ?>"
			onclick="javascript:window.open('<?= WclSite/url(menu) ?>?textinput_zone_id=<?= textinput_zone_id ?>&textinput_country_id=<?= textinput_country_id ?>','ISO_Code','menubar=off,height=150px,width=500px')"><? ]

			

[load_wcl(self:{"*/postal_zone_wizard.wcl"}) : void
->	when zw := get_world()
	in (let country_code := (if $["country_code"] $["country_code"] as string else ""),
			region_code := (if $["region_code"] $["country_code"] as string else "")
		in (if $["from_zone"] 
				(when z := get_zone($["from_zone"])
				in (case z (region (region_code := z.iso,
									country_code := z.zcountry.iso),
							country (country_code :=  z.iso)))),

			if (country_code != "")
				(when z := get_zone(country_code)
				in (case z (country (true),
							any (country_code := "", region_code := "")))),

			if (region_code != "" & country_code != "")
				(when z := get_zone(region_code)
				in (case z (region ( if (country_code != z.zcountry.iso) region_code := ""),
							any region_code := ""))),
			
			?><script language="javascript">
			function submit_data() 
			{
				need_close = true;
				i = document.getElementById("region_code_hidden");
				i2 = document.getElementById("country_code_hidden");
				v_country = null;
				<? (if $["elem_id"] ( ?>
				v = window.opener.document.getElementById("<?= $["elem_id"] ?>");
				<? ) else if $["textinput_country_id"] ( ?>
				v = window.opener.document.getElementById("<?= $["textinput_zone_id"] ?>");
				v_country = window.opener.document.getElementById("<?= $["textinput_country_id"] ?>");
				<? )) ?>
				if (i != null) 
				{
					if (v != null) v.value = i.value;
					if (v_country != null) v.value = i2.value;
				} else {
					i = document.getElementById("region_code_select");
					if (i != null) 
					{
						n = i.selectedIndex;
						if (n >= 0) {
							if (v != null) v.value = i.options[n].value;
							if (v_country != null) v_country.value = i2.value;
							}
						else {
							alert("<?= translate("Veuillez sélectionner une région") ?>");
							need_close = false;
						}
					}
				}
				if (need_close == true ) window.close();
			}
			</script>
			<form method=post>
				<? (if $["elem_id"] ( ?>
				<input type=hidden name="elem_id" value="<?= $["elem_id"] ?>"><? )) ?>
				<? (if $["textinput_country_id"] ( ?>
				<input type=hidden name="textinput_country_id" value="<?= $["textinput_country_id"] ?>"><? )) ?>
				<? (if $["textinput_zone_id"] ( ?>
				<input type=hidden name="textinput_zone_id" value="<?= $["textinput_zone_id"] ?>"><? )) ?>
				<table>
					<caption><?= translate("Sélection d'une zone géographique") ?></caption>
					<tr>
						<th><?== translate("Pays") ?></th>
						<td><select name="country_code" onchange="form.submit()">
								<option value=""><?== translate("choisir pays") ?></option>
								<? (for i in get_countries() ( ?>
								<option value="<?= i.iso ?>" <? (if (i.iso = country_code) echo("selected")) ?>><?== i.label ?></option><? )) ?></select></td>
					</tr>
					<? (when c := get_country(country_code) in (
						let regs := c.regions in (
							if regs ( ?>
					<tr>
						<td><?== translate("zone géographique") ?>
						<td><input type=hidden id="country_code_hidden" name="country_code_hidden" value="<?= country_code ?>">
							<select id="region_code_select" name="region_code"><? (for i in regs ( ?>
								<option value="<?= i.iso ?>" <? (if (i.iso = region_code) echo("selected")) ?> ><?= i.iso ?> - <?== i.label ?></option><? )) ?></select></td>
					<tr><? ) else (
							region_code := c.iso,
							?><input type=hidden id="region_code_hidden" name="region_code" value="<?= region_code ?>"><? )))) ?>
					<tr><td><input type=button value="<?== translate("Annuler") ?>" onclick="window.close()" >
						<td align=right><input type=button value="<?== translate("Valider") ?>" onclick="submit_data()">
					</tr>
				</table>
			</form><? )) ]
							

[load_wcl(self:{"*/ajax_postal_request.wcl"}) : void
->	header("Content-Type: text/xml"),
	WclSite/desactivate_drawMenu(),
	if $["country"] (
		when z := get_country($["country"]) 
		in ( ?><ajax_data><? ,
			for i in regions(z) ( ?><elem value="<?= i.iso ?>" name="<?= getInfo(i) ?>" <? (if ($["selected"] = i.iso) ( ?>selected="1"<? )) ?>/><? ),
			 ?></ajax_data><? ) else ( ?><ajax_data></ajax_data><? ))
	else ( ?><ajax_data><? ,
			for i in get_countries() ( ?><elem value="<?= i.iso ?>" name="<?= getInfo(i) ?>" <? (if ($["selected"] = i.iso) ( ?>selected="1"<? )) ?>/><? ),
			 ?></ajax_data><? )]


[getInfo(self:zone) : string -> (self.label /+ " (" /+ self.iso /+ ")")]

