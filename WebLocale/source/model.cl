

WebLocaleTool <: WclSite/ToolMenu()

/*
WEB_LOCALE_APP :: WclSite/WebApp(
			WclSite/siteFullName = "Babel",
			WclSite/siteId = "DEFAULT",
//			siteDescription:string,
			WclSite/siteRootPath = ".",
			WclSite/siteBaseUrl = "/",
			WclSite/siteIndexFile = "wcl_index.wcl",
			WclSite/siteSmallPicture = "help.png",
			WclSite/siteLargePicture = "help.png",
			WclSite/menuSmallImage = "help.png",
			WclSite/siteImgUrl = "/img/")
*/

WEB_LOCALE_TOOL :: WclSite/ToolMenu(WclSite/menuPopupShowTop = false,
									WclSite/menuInfo = "Traductions",
									WclSite/menuPopupProperties = "menubar=off,width=800,height=500,scrollbars=yes,resizable=yes,status=no,toolbar=no",
									WclSite/menuSubInfo = "Outils de traductions de pages",
									WclSite/menuFile = "web_locale_tool.wcl",
									WclSite/menuParent = WclSite/MENU_ADMINISTRATION_LANGUES,
									WclSite/menuSmallImage = "locale.png",
									WclSite/menuLargeImage = "locale.png")


// WEB_LOCALE_TOOL :: ToolMenu() 

[close(self:WebLocaleTool) : WebLocaleTool
->	self.WclSite/menuFile := "web_locale_tool.wcl",
	self]

[self_html(self:{WEB_LOCALE_TOOL}) : void
->	when parent := WclSite/get_menu() in 
		(// self.WclSite/menuParent := parent,
		?><a onclick="javascript:window.open('<?= WclSite/url(self,parent) ?>','<?= string!(name(self)) ?>','<?= self.WclSite/menuPopupProperties ?>');"><? ,
		if known?(WclSite/menuSmallImage,self) ( 
			?><img src="<?= WclSite/url_img(WclSite/webapp(self),self.WclSite/menuSmallImage) ?>" title="<?== self.WclSite/menuInfo ?>" alt="<?== self.WclSite/menuInfo ?> "><? ),
		?></a><? )]

WebLocalStartupItem <: WclSite/WebStartupItem()


WEB_LOCALE_STARTUP_ITEM :: WebLocalStartupItem( WclSite/itemInfo = "WebLocale Startup Item", WclSite/level = 1)

[WclSite/web_shutdown(self:WebLocalStartupItem)
->	//[-100] web_shutdown @ WEB_LOCALE_STARTUP_ITEM,
	if (WclSite/userCanModify?(WclSite/MENU_ADMINISTRATION_LANGUE) & REGISTER_UNTRANSLATED) (
		let terms := list{i.LibLocale/reference | i in get_translated_terms()}
		in register("WEB_LOCALE_APP_ITEMS", terms))]


REGISTER_UNTRANSLATED:boolean := true

[sortref(a:string,b:string) : boolean -> upper(a) < upper(b)]

[load_wcl(self:{"*/web_locale_tool.wcl"}) : void
->	WclSite/set_menu(WEB_LOCALE_TOOL),
	REGISTER_UNTRANSLATED := false,
	if $["WEB_LOCALE_APP_ITEMS"] 
		let li := $["WEB_LOCALE_APP_ITEMS"] as list[string],
			ctx := LibLocale/locale_context!(),
			lang_iso := upper((if $["TRANSLATE_ISO"] $["TRANSLATE_ISO"] else LibLocale/get_current_locale().LibLocale/iso)),
			val := ""
		in (LibLocale/load_xml(ctx),
			ctx.current_locale := get_language(lang_iso,ctx),
			ctx.current_applicable := get_applicable(),
			if ($["save_modif"] & $["refs"]) (
				for r in $["refs"]
					(if ($value["localized",r])
						LibLocale/insert_term(ctx,lang_iso,"CLARIPRINT",url_decode(r),$value["localized",r])
					else 
						LibLocale/insert_term(ctx,lang_iso,"CLARIPRINT",url_decode(r),"")),
				LibLocale/save_xml(ctx),
				let ctx2 := LibLocale/locale_context!() in (LibLocale/load_xml(ctx2), LibLocale/save_serialized(ctx2,lang_iso)),
//				generate_serialized_locale_files(),
				none),
						
	?>
<form method=post action="web_locale_tool.wcl">
<input type=hidden name="TRANSLATE_ISO" value="<?= lang_iso ?>">
<table><? ,
	let ii := 0 in for i in sort(sortref @ string, li) ( ii :+ 1, ?>
		<tr>
			<td><?= i ?>
				<input type=hidden name="refs[]" value="<?= url_encode( i ) ?>">
			<td><? , if (length(i) > 60 | find(i,"\"") > 0 | find(i,"\n") > 0) ( ?><textarea cols=60 rows=3 name="localized[<?= url_encode(i) ?>]"><?= ((LibLocale/translate(ctx,i))) ?></textarea><? )
					else ( ?><input type=text size=60 name="localized[<?= url_encode(i) ?>]" value="<?= ((LibLocale/translate(ctx,i))) ?>"><? ) , ?>
		</tr><? ) , ?>
		<tr>
			<td><input type=reset value="reset">
			<td><input type=submit name="save_modif" value="<?== translate("Enregistrer") ?>">
		</tr>
</table>
</form><? )]

