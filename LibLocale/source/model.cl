
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * model.cl                                                          *
// * Copyright (C) 2005 xl. All Rights Reserved                        *
// *********************************************************************

// *********************************************************************
// *   1. ISO locale codes                                             *
// *   2. model                                                        *
// *   3. API                                                          *
// *   4. table hashing                                                *
// *   5. serialized form                                              *
// *   6. XML form                                                     *
// *   7. admin API                                                    *
// *********************************************************************

LOCALE_KGB ::  2
LOCALE_FILES :: 0

// *********************************************************************
// *   1. ISO locale codes                                             *
// *********************************************************************

ISO_CODE :: {/* "Afar" */ "AA", /* "Abkhazian" */ "AB", /* "Afrikaans" */ "AF",
		/* "Amharic" */ "AM", /* "Arabic" */ "AR", /* "Assamese" */ "AS",
		/* "Aymara" */ "AY", /* "Azerbaijani" */ "AZ", /* "Bashkir" */ "BA",
		/* "Byelorussian" */ "BE", /* "Bulgarian" */ "BG", /* "Bihari" */ "BH",
		/* "Bislama" */ "BI", /* "Bengali" */ "BN", /* "Tibetan" */ "BO",
		/* "Breton" */ "BR", /* "Catalan" */ "CA", /* "Corsican" */ "CO",
		/* "Czech" */ "CS", /* "Welsh" */ "CY", /* "Danish" */ "DA",
		/* "German" */ "DE", /* "Bhutani" */ "DZ", /* "Greek" */ "EL",
		/* "English" */ "EN", /* "Esperanto" */ "EO", /* "Spanish" */ "ES",
		/* "Estonian" */ "ET", /* "Basque" */ "EU", /* "Persian" */ "FA",
		/* "Finnish" */ "FI", /* "Fiji" */ "FJ", /* "Faeroese" */ "FO",
		/* "French" */ "FR", /* "Frisian" */ "FY", /* "Irish" */ "GA",
		/* "Gaelic" */ "GD", /* "Galician" */ "GL", /* "Guarani" */ "GN",
		/* "Gujarati" */ "GU", /* "Hausa" */ "HA", /* "Hindi" */ "HI",
		/* "Croatian" */ "HR", /* "Hungarian" */ "HU", /* "Armenian" */ "HY",
		/* "Interlingua" */ "IA", /* "Interlingue" */ "IE", /* "Inupiak" */ "IK",
		/* "Indonesian" */ "IN", /* "Icelandic" */ "IS", /* "Italian" */ "IT",
		/* "Hebrew" */ "IW", /* "Japanese" */ "JA", /* "Yiddish" */ "JI",
		/* "Javanese" */ "JW", /* "Georgian" */ "KA", /* "Kazakh" */ "KK",
		/* "Greenlandic" */ "KL", /* "Cambodian" */ "KM", /* "Kannada" */ "KN",
		/* "Korean" */ "KO", /* "Kashmiri" */ "KS", /* "Kurdish" */ "KU",
		/* "Kirghiz" */ "KY", /* "Latin" */ "LA", /* "Lingala" */ "LN",
		/* "Laothian" */ "LO", /* "Lithuanian" */ "LT", /* "Latvian" */ "LV",
		/* "Malagasy" */ "MG", /* "Maori" */ "MI", /* "Macedonian" */ "MK",
		/* "Malayalam" */ "ML", /* "Mongolian" */ "MN", /* "Moldavian" */ "MO",
		/* "Marathi" */ "MR", /* "Malay" */ "MS", /* "Maltese" */ "MT",
		/* "Burmese" */ "MY", /* "Nauru" */ "NA", /* "Nepali" */ "NE",
		/* "Dutch" */ "NL", /* "Norwegian" */ "NO", /* "Occitan" */ "OC",
		/* "Oromo" */ "OM", /* "Oriya" */ "OR", /* "Punjabi" */ "PA",
		/* "Polish" */ "PL", /* "Pashto" */ "PS", /* "Portuguese" */ "PT",
		/* "Quechua" */ "QU", /* "Rhaeto-Romance" */ "RM", /* "Kirundi" */ "RN",
		/* "Romanian" */ "RO", /* "Russian" */ "RU", /* "Kinyarwanda" */ "RW",
		/* "Sanskrit" */ "SA", /* "Sindhi" */ "SD", /* "Sangro" */ "SG",
		/* "Serbo-Croatian" */ "SH", /* "Singhalese" */ "SI", /* "Slovak" */ "SK",
		/* "Slovenian" */ "SL", /* "Samoan" */ "SM", /* "Shona" */ "SN",
		/* "Somali" */ "SO", /* "Albanian" */ "SQ", /* "Serbian" */ "SR",
		/* "Siswati" */ "SS", /* "Sesotho" */ "ST", /* "Sudanese" */ "SU",
		/* "Swedish" */ "SV", /* "Swahili" */ "SW", /* "Tamil" */ "TA",
		/* "Tegulu" */ "TE", /* "Tajik" */ "TG", /* "Thai" */ "TH",
		/* "Tigrinya" */ "TI", /* "Turkmen" */ "TK", /* "Tagalog" */ "TL",
		/* "Setswana" */ "TN", /* "Tonga" */ "TO", /* "Turkish" */ "TR",
		/* "Tsonga" */ "TS", /* "Tatar" */ "TT", /* "Twi" */ "TW",
		/* "Ukrainian" */ "UK", /* "Urdu" */ "UR", /* "Uzbek" */ "UZ",
		/* "Vietnamese" */ "VI", /* "Volapuk" */ "VO", /* "Wolof" */ "WO",
		/* "Xhosa" */ "XH", /* "Yoruba" */ "YO", /* "Chinese" */ "ZH",
		/* "Zulu" */ "ZU",
		"?", "DOC"}

// *********************************************************************
// *   2. model                                                        *
// *********************************************************************
language <: ephemeral_object
language <: ephemeral_object(
					iso:ISO_CODE,
					user?:boolean = false,
					virtual?:boolean = false,
					ref:string)

unknown_language :: language(iso = "?",virtual? = true)

[self_print(self:language) : void -> printf("<lang:~S>", get(iso,self))]


term <: ephemeral_object
term <: ephemeral_object(
			translated?:boolean = false,
			user?:boolean = false,
			applicable:string,
			lang:language,
			reference:string,
			localized:string,
			next:term) //<sb> linked list of term

unknown_term :: mClaire/new!(term)

	(unknown_term.applicable := "?",
	unknown_term.lang := unknown_language,
	unknown_term.reference := "?",
	unknown_term.localized := "?")




locale_context <: ephemeral_object(
					languages:list[language],
					locale_path:string,
					reference_file:string = "locale.xml",
					locale_file:string = "user_locale.xml",
					reference_language:language,
					current_locale:language,
					current_applicable:string = "",
					translation_map:list[term])


close(self:locale_context) : locale_context ->
	(self.current_locale := unknown_language,
	self.translation_map := make_list(4095, term, unknown_term),
	self)

[path() : string ->	usr_path()]

[system_path() : string
->	if isenv?("WCL_LOCALE_PATH") getenv("WCL_LOCALE_PATH")
	else if (isenv?("DOCUMENT_ROOT") & isdir?(getenv("DOCUMENT_ROOT") / ".." / "locale"))
			(getenv("DOCUMENT_ROOT") / ".." / "locale")
	else ("/tmp")]

[usr_path() : string
->	if isenv?("WCL_LOCALE_USER_PATH") getenv("WCL_LOCALE_USER_PATH")
	else let root := getenv("DOCUMENT_ROOT")
		in (if (isenv?("HTTP_HOST") & isdir?(root / "../themes" / explode(getenv("HTTP_HOST"),".")[1] / "locale"))
				(root / "../themes" / explode(getenv("HTTP_HOST"),".")[1] / "locale")
			else (system_path()))]


[init_context() : locale_context
->	let ctx := locale_context(current_locale = unknown_language)
	in (ctx.locale_path := usr_path(),
		ctx)]

// BASE_LOCALE_CONTEXT:locale_context := init_context("locale.xml")
// USER_LOCALE_CONTEXT:locale_context := init_context("user_locale.xml")
CURRENT_LOCALE_CONTEXT:locale_context := init_context()

[current_context() : locale_context -> CURRENT_LOCALE_CONTEXT]

locale_context!() : locale_context ->
	let ctx := locale_context()
	in (ctx.locale_path := path(),
		ctx)

locale_context!(self:string) : locale_context ->
	let ctx := locale_context()
	in (ctx.locale_path := self,
		ctx)

use_locale(self:locale_context) : locale_context ->
	let old := CURRENT_LOCALE_CONTEXT
	in (CURRENT_LOCALE_CONTEXT := self,
		old)

[self_print(self:term) : void ->
	if (self = unknown_term) princ("<unknown term>")
	else printf("<~S/~S/~A/~A => ~A>",
			get(lang,self),
			self.user?,
			self.applicable, self.reference, self.localized)]

[get_translated_terms() : list[term] ->
	get_translated_terms(CURRENT_LOCALE_CONTEXT)]
[get_translated_terms(self:locale_context) : list[term] ->
	let l := list<term>()
	in (for t in self.translation_map
			(if (t != unknown_term)
				(if t.translated? l :add t,
				while (t.next != unknown_term)
					(t := t.next,
					if t.translated? l :add t))),
		l)]

// *********************************************************************
// *   3. API                                                          *
// *********************************************************************


[get_applicable() : string -> CURRENT_LOCALE_CONTEXT.current_applicable]
[set_applicable(self:string) : string ->
	let old := CURRENT_LOCALE_CONTEXT.current_applicable
	in (CURRENT_LOCALE_CONTEXT.current_applicable := self,
		old)]


[get_language(self:ISO_CODE,ctx:locale_context) : language
->	when l := some(u in ctx.languages | u.iso = self) in l
	else unknown_language]

[get_language(self:ISO_CODE) : language => get_language(self,CURRENT_LOCALE_CONTEXT)]

[get_locale() : ISO_CODE -> CURRENT_LOCALE_CONTEXT.current_locale.iso]
[set_locale(self:string) : ISO_CODE ->
	//[LOCALE_KGB] set_locale(~S) // self,
	self := upper(self),
	case self (
		ISO_CODE (
			let old:ISO_CODE := CURRENT_LOCALE_CONTEXT.current_locale.iso
			in (//[LOCALE_KGB] ==== set locale ~A (was ~A) ==== // self, CURRENT_LOCALE_CONTEXT.current_locale.iso,
				if (available_locale?(self) | load_locale(self))
					CURRENT_LOCALE_CONTEXT.current_locale := get_language(self)
				else error("Locale ~A is not available", self),
				old)),
		any (error("Locale ~A is not available", self),
			"?"))]

[get_current_locale() : language
->	when i := CURRENT_LOCALE_CONTEXT in i.current_locale
	else unknown_language]

[available_locale?(self:ISO_CODE,ctx:locale_context) : boolean -> 
	//[LOCALE_KGB] available_locale?(~S, ~S) // self, ctx,
	exists(l in ctx.languages | l.iso = self)]
	
[available_locale?(self:ISO_CODE) : boolean -> available_locale?(self,CURRENT_LOCALE_CONTEXT)]

//<sb> find the set of locale that have terms
[get_locale_set() : set[ISO_CODE] -> {l.iso | l in CURRENT_LOCALE_CONTEXT.languages }]

//<sb> return the list of available locales seen as the set of
// serialized resource in the locale directory
[get_serialized_locale_set() : set[ISO_CODE] ->
	get_serialized_locale_set(CURRENT_LOCALE_CONTEXT)]
[get_serialized_locale_set(ctx:locale_context) : set[ISO_CODE] ->
	let res := set<ISO_CODE>()
	in (for e in {replace(e, ".serialized", "") |	
						e in entries(ctx.locale_path, "*.serialized")}
			case e
				(ISO_CODE res :add e),
		res)]

[load_locale(self:ISO_CODE) : boolean ->
	let ok? := false
	in (//[LOCALE_FILES] ==== load locale ~A ==== // self,
		try (load_serialized(self),
			//[LOCALE_FILES] ==== loaded serialized locale ~A ==== // self,
			ok? := true)
		catch any
			(//[LOCALE_FILES] ==== unfound serialized locale ~A ====\n~S // self, exception!(),
			try (load_xml(),
				//[LOCALE_KGB] ==== loaded XML locale ~A ==== // self,
				ok? := true)
			catch any
				(//[LOCALE_FILES] ==== failed to load locale ~A ====\n~S // self, exception!()
				)), ok?)]



[applicable_translate(ctx:locale_context, app:string, ref:string) : string ->
	let t := get_term(ctx,ctx.current_locale, app, ref)
	in (if (t != unknown_term)
			(//[LOCALE_KGB] == translate(~S, ~A) ~S => ~S // ctx.current_locale, app, ref, t.localized,
			t.translated? := true,
			t.localized)
		else
			(//[LOCALE_KGB] == ??? translate(~S, ~A) ~S // ctx.current_locale, app, ref,
			insert_term(ctx,app, ref, ref).translated? := true, //<sb> insert an empty term
			ref))]

[applicable_translate(app:string, ref:string) : string -> applicable_translate(CURRENT_LOCALE_CONTEXT,app, ref)]

[applicable_translate(app:string, ref:string, l:listargs) : string ->
	translate~(applicable_translate(app, ref), l)]


[translate(ctx:locale_context, ref:string) : string -> applicable_translate(ctx,ctx.current_applicable, ref)]
[translate(ref:string) : string -> translate(CURRENT_LOCALE_CONTEXT, ref)]

[translate(ref:string, l:listargs) : string ->
	translate~(applicable_translate(CURRENT_LOCALE_CONTEXT.current_applicable, ref), l)]


[translate~(ref:string, l:list) : string ->
	print_in_string(),
	let p := port!(ref)
	in while not(eof?(p))
		let (pref, suf) := freadline(p, {"~S", "~A"})
		in (princ(pref),
			if (length(suf) > 0)
				(if not(l)
					error("argument missing in translate(~S, ~A)", ref, l),
				case suf
					({"~S"} print(l[1]),
					{"~A"} princ(l[1])),
				l << 1)), end_of_string()]

//<sb> check wheither a term exists in the locale dictionary


[known_term?(ref:string) : boolean ->
	known_term?(CURRENT_LOCALE_CONTEXT.current_locale, CURRENT_LOCALE_CONTEXT.current_applicable, ref)]

[known_term?(app:string, ref:string) : boolean ->
	known_term?(CURRENT_LOCALE_CONTEXT.current_locale, app, ref)]

[known_term?(isoc:ISO_CODE, app:string, ref:string) : boolean ->
	get_term(isoc, app, ref) != unknown_term]

[known_term?(isoc:language, app:string, ref:string) : boolean ->
	get_term(isoc.iso, app, ref) != unknown_term]


// *********************************************************************
// *   4. table hashing                                                *
// *********************************************************************

//<sb> produce a fast hash value in the range (1 .. 4095)
// from a tuple of three string
[hash_term(self:language, app:string, ref:string) : integer ->
	let h := 0,
		len := length(self.iso)
	in (externC("while(len--) {h += self->iso[len]; h += (h << 10); h ^= (h >> 6);}"),
		externC("h += '#'; h += (h << 10); h ^= (h >> 6)"),
		len := length(app),
		externC("h += '#'; h += (h << 10); h ^= (h >> 6)"),
		externC("while(len--) {h += app[len]; h += (h << 10); h ^= (h >> 6);}"),
		len := length(ref),
		externC("while(len--) {h += ref[len]; h += (h << 10); h ^= (h >> 6);}"),
		externC("h += (h << 3); h ^= (h >> 11); h += (h << 15)"),
		externC("h &= 4095"),
		externC("if (h == 0) h = 1"),
		h)]

[hash_term(lang:string, app:string, ref:string) : integer ->
	let h := 0,
		len := length(lang)
	in (externC("while(len--) {h += lang[len]; h += (h << 10); h ^= (h >> 6);}"),
		externC("h += '#'; h += (h << 10); h ^= (h >> 6)"),
		len := length(app),
		externC("h += '#'; h += (h << 10); h ^= (h >> 6)"),
		externC("while(len--) {h += app[len]; h += (h << 10); h ^= (h >> 6);}"),
		len := length(ref),
		externC("while(len--) {h += ref[len]; h += (h << 10); h ^= (h >> 6);}"),
		externC("h += (h << 3); h ^= (h >> 11); h += (h << 15)"),
		externC("h &= 4095"),
		externC("if (h == 0) h = 1"),
		h)]


[insert_term(ref:string, loc:string) : term ->
	insert_term(CURRENT_LOCALE_CONTEXT.current_locale, CURRENT_LOCALE_CONTEXT.current_applicable, ref, loc)]

[insert_term(app:string, ref:string, loc:string) : term ->
	insert_term(CURRENT_LOCALE_CONTEXT.current_locale, app, ref, loc)]

[insert_term(ctx:locale_context,app:string, ref:string, loc:string) : term -> insert_term(ctx,ctx.current_locale, app, ref, loc,true)]

[insert_term(l:language, app:string, ref:string, loc:string) : term ->
	insert_term(term(lang = l, applicable = app, reference = ref, localized = loc))]

[insert_term(isoc:ISO_CODE, app:string, ref:string, loc:string) : term ->
	insert_term(term(lang = get_language(isoc), applicable = app, reference = ref, localized = loc))]

[insert_term(ctx:locale_context,isoc:ISO_CODE, app:string, ref:string, loc:string) : term ->
	insert_term(ctx,isoc, app, ref, loc, true)]

[insert_term(ctx:locale_context,isoc:ISO_CODE, app:string, ref:string, loc:string, user_mode:boolean) : term ->
	if user_mode //[LOCALE_KGB] OKKKKK,
	insert_term(term(lang = get_language(isoc,ctx),
					applicable = app,
					reference = ref,
					localized = loc,
					user? = user_mode),
				ctx)]

[insert_term(ctx:locale_context,l:language, app:string, ref:string, loc:string, user_mode:boolean) : term ->
	if user_mode //[LOCALE_KGB] OKKKKK,
	insert_term(term(lang = l,
					applicable = app,
					reference = ref,
					localized = loc,
					user? = user_mode),
				ctx)]

[insert_term(self:term) : term -> insert_term(self,CURRENT_LOCALE_CONTEXT)]

[insert_term(self:term,ctx:locale_context) : term ->
	if unknown?(next, self) self.next := unknown_term,
	let g := ctx.translation_map,
		h := hash_term(self.lang, self.applicable, self.reference),
		x := g[h],
		lapp := length(self.applicable),
		lref := length(self.reference)
	in (if (x = unknown_term)
			g[h] := self
		else let found? := false, n := x
			in (while (n != unknown_term)
					(if (length(n.reference) = lref &
						length(n.applicable) = lapp &
						externC("((n->lang == self->lang &&
							memcmp(n->applicable, self->applicable, lapp) == 0 &&
							memcmp(n->reference, self->reference, lref) == 0) ? 
							CTRUE : CFALSE)", boolean))
						(found? := true,
						n.localized := self.localized,
						n.user? := true,
						self := n,
						break()),
					externC("n = n->next")),
				if not(found?)
					(self.next := x,
					g[h] := self))), self]


[get_term(ref:string) : term ->
	get_term(CURRENT_LOCALE_CONTEXT.current_locale, CURRENT_LOCALE_CONTEXT.current_applicable, ref)]
[get_term(app:string, ref:string) : term ->
	get_term(CURRENT_LOCALE_CONTEXT.current_locale, app, ref)]
[get_term(isoc:ISO_CODE, app:string, ref:string) : term ->
	get_term(get_language(isoc), app, ref)]
	
[get_term(ctx:locale_context,isoc:ISO_CODE, app:string, ref:string) : term -> get_term(ctx,get_language(isoc,ctx), app, ref)]

[get_term(l:language, app:string, ref:string) : term -> get_term(CURRENT_LOCALE_CONTEXT, l, app, ref)]

[get_term(ctx:locale_context,l:language, app:string, ref:string) : term ->
	let h := hash_term(l, app, ref),
		x := ctx.translation_map[h],
		res := unknown_term,
		lapp := length(app),
		lref := length(ref)
	in (let n := x
		in while (n != unknown_term)
			(if (length(n.reference) = lref &
				length(n.applicable) = lapp &
				externC("((n->lang == l &&
							memcmp(n->applicable, app, lapp) == 0 &&
							memcmp(n->reference, ref, lref) == 0) ? 
							CTRUE : CFALSE)", boolean))
				(res := n,
				break()),
			externC("n = n->next")),
		res)]


[delete_term(ref:string) : void ->
	delete_term(CURRENT_LOCALE_CONTEXT.current_locale, CURRENT_LOCALE_CONTEXT.current_applicable, ref)]
[delete_term(app:string, ref:string) : void ->
	delete_term(CURRENT_LOCALE_CONTEXT.current_locale, app, ref)]

[delete_term(isoc:ISO_CODE, app:string, ref:string) : void ->
	delete_term(get_language(isoc), app, ref)]

[delete_term(l:language, app:string, ref:string) : void ->
	let g := CURRENT_LOCALE_CONTEXT.translation_map,
		h := hash_term(l, app, ref),
		x := g[h],
		lapp := length(app),
		lref := length(ref)
	in (if (x != unknown_term)
			let n := x, prev := n
			in (if (length(n.reference) = lref &
					length(n.applicable) = lapp &
					externC("((n->lang == l &&
							memcmp(n->applicable, app, lapp) == 0 &&
							memcmp(n->reference, ref, lref) == 0) ? 
							CTRUE : CFALSE)", boolean))
					g[h] := n.next
				else
					(n := n.next,
					while (n != unknown_term)
						(if (length(n.reference) = lref &
							length(n.applicable) = lapp &
							externC("((n->lang == l &&
										memcmp(n->applicable, app, lapp) == 0 &&
										memcmp(n->reference, ref, lref) == 0) ? 
										CTRUE : CFALSE)", boolean))
							(prev.next := n.next,
							break()),
						prev := n,
						n := n.next))))]



// *********************************************************************
// *   5. serialized form                                              *
// *********************************************************************

[save_serialized() : void -> save_serialized(CURRENT_LOCALE_CONTEXT)]

[get_best_term(l:string,t:term) : term -> get_best_term(CURRENT_LOCALE_CONTEXT,l,t)]

[get_best_term(ctx:locale_context,l:string,t:term) : term
->	when ll := get_language(l,ctx)
	in get_best_term(ctx,ll,t)
	else unknown_term]
	
[get_best_term(l:language,t:term) : term -> get_best_term(CURRENT_LOCALE_CONTEXT,l,t)]

[get_best_term(ctx:locale_context,l:language,t:term) : term
->	let x := get_term(ctx,l,t.applicable,t.reference)
	in (if (x != unknown_term) x
		else if unknown?(ref, l) x
//		else if l.ref.virtual? t
		else get_best_term(ctx,l.ref, t))]

[get_best_term(ctx:locale_context,l:string,app:string,refe:string) : term
->	when ll := get_language(l,ctx)
	in get_best_term(ctx,ll,app,refe)
	else unknown_term]
	
[get_best_term(ctx:locale_context,l:language,app:string,refe:string) : term
->	let x := get_term(ctx,l,app,refe)
	in (if (x != unknown_term) x
		else if unknown?(ref, l) x
//		else if l.ref.virtual? t
		else get_best_term(ctx,l.ref,app,refe))]

[save_serialized(self:ISO_CODE) : void -> save_serialized(CURRENT_LOCALE_CONTEXT,self)]

[save_serialized(ctx:locale_context) : void -> for i in ctx.languages save_serialized(ctx,i.iso)]

[save_serialized(ctx:locale_context,self:ISO_CODE) : void ->
	//[LOCALE_FILES] save_serialized(~S) // self,
	if available_locale?(self,ctx)
		let path := ctx.locale_path / self /+ ".serialized",
			f := fopen(path, "w"),
			basel := ctx.reference_language,
			myl := get_language(self,ctx),
			ut := unknown_term
		in (//[LOCALE_FILES] save_serialized(~A) // self,
			if islocked?(f)
				//[LOCALE_KGB] Wait for session lock to be released on ~A // path,
			flock(f), //<sb> query exclusive access on the locale serialized file
			fwrite(self, f),

//to try : { t.Locale/reference | t in ctx.Locale/translation_map } // no pb of applicable !!
			for t in extract_terms(ctx,basel) (
				//[LOCALE_KGB] base: ~S // t,
				let x := get_best_term(ctx,myl,t as  term)
				in (let lapp := length(x.applicable),
							lref := length(x.reference),
							lloc := length(x.localized)
					in (write_port(f, externC("((char*)&lapp)", char*), 4),
						write_port(f, externC("((char*)&lref)", char*), 4),
						write_port(f, externC("((char*)&lloc)", char*), 4),
						fwrite(x.applicable, f),
						fwrite(x.reference, f),
						fwrite(x.localized, f)),
					externC("x = x->next"))),
			fclose(f))]

[load_serialized(self:ISO_CODE) : boolean ->
	load_serialized_file(CURRENT_LOCALE_CONTEXT.locale_path / self /+ ".serialized")]

[load_serialized_file(path:string) : boolean ->
	//[LOCALE_FILES]  load_serialized_file(~S) // path,
	if isfile?(path) (
		let f := fopen(path, "r"),
			isoc:ISO_CODE := "?"
		in (//[LOCALE_KGB] load_serialized_file(~A) // path,
			if islocked?(f)
				//[LOCALE_KGB] Wait for session lock to be released on ~A // path,
			flock(f), //<sb> query exclusive access on the locale serialized file
			isoc := fread(f, 2) as ISO_CODE,
			let myl := (when l := some(i in CURRENT_LOCALE_CONTEXT.languages | i.iso = isoc) in l 
						else let l := language(iso = isoc) in (CURRENT_LOCALE_CONTEXT.languages :add l, l))
			in (while not(eof?(f))
					let lapp := 0,
						lref := 0,
						lloc := 0,
						n := 0
					in (n :+ read_port(f, externC("((char*)&lapp)", char*), 4),
						n :+ read_port(f, externC("((char*)&lref)", char*), 4),
						n :+ read_port(f, externC("((char*)&lloc)", char*), 4),
						if (n != 12)
							error("load_serialized: premature eof while loading ~A", path),
						if not(eof?(f))
							let app := fread(f, lapp),
								ref := fread(f, lref),
								loc := fread(f, lloc)
							in insert_term(myl, app, ref, loc))),
			fclose(f),
			true)) else false]


// *********************************************************************
// *   6. XML form                                                     *
// *********************************************************************

[extract_terms(self:locale_context) : list[term] ->
	let res := list<term>()
	in (for t in self.translation_map
			while (t != unknown_term)
				(res :add t,
				t := t.next),
		res)]

[extract_terms(self:locale_context,l:language) : list[term] ->
	let res := list<term>()
	in (for t in self.translation_map
			while (t != unknown_term)
				(if (t.lang = l) res :add t,
				t := t.next),
		res)]
/*
[copy_from_locale_set(self:ISO_CODE, newiso:ISO_CODE) : void ->
	for t in extract_references(self)
		insert_term(newiso, t[2], t[1], t[1])]
*/
[xml_encode_locale(self:string) : void ->
	for i in (1 .. length(self))
		externC("if (self[i - 1] == '>') princ_string(\"&gt;\");
				else if (self[i - 1] == '<') princ_string(\"&lt;\");
				else if (self[i - 1] == '&') princ_string(\"&amp;\");
				else princ_string1(self, i, i)")]

[xml_decode_locale(self:string) : string ->
	replace(replace(replace(self, "&gt;", ">"), "&lt;", "<"), "&amp;","&")]

[save_xml() : void ->	save_xml(CURRENT_LOCALE_CONTEXT)]

[save_xml(xmlfile:string) : void ->
	let xml := fopen(xmlfile, "w"),
		op := use_as_output(xml)
	in (if islocked?(xml)
			//[LOCALE_KGB] Wait for locale lock to be released on ~A // xmlfile,
		flock(xml), //<sb> query exclusive access on the locale file
		print_xml(),
		use_as_output(op),
		fclose(xml))]

[save_xml(xmlfile:string,all:boolean) : void ->
	let xml := fopen(xmlfile, "w"),
		op := use_as_output(xml)
	in (if islocked?(xml)
			//[LOCALE_KGB] Wait for locale lock to be released on ~A // xmlfile,
		flock(xml), //<sb> query exclusive access on the locale file
		print_xml(true),
		use_as_output(op),
		fclose(xml))]

[save_xml(ctx:locale_context,xmlfile:string) : void ->
	let xml := fopen(xmlfile, "w"),
		op := use_as_output(xml)
	in (if islocked?(xml)
			//[LOCALE_KGB] Wait for locale lock to be released on ~A // xmlfile,
		flock(xml), //<sb> query exclusive access on the locale file
		print_xml(ctx),
		use_as_output(op),
		fclose(xml))]

[save_xml(ctx:locale_context) : void -> 
	let xmlfile:string := ctx.locale_path / ctx.locale_file,
		xml := fopen(xmlfile, "w"),
		op := use_as_output(xml)
	in (if islocked?(xml)
			//[LOCALE_KGB] Wait for locale lock to be released on ~A // xmlfile,
		flock(xml), //<sb> query exclusive access on the locale file
		print_xml(ctx),
		use_as_output(op),
		fclose(xml))]
	

[load_xml() : boolean -> load_xml(CURRENT_LOCALE_CONTEXT)]

[load_xml(xmlfile:string) : boolean ->
	//[LOCALE_FILES] loading locale xml from : ~S // xmlfile, 
	if isfile?(xmlfile) 
	let xml := fopen(xmlfile, "r")
	in (if islocked?(xml)
			//[LOCALE_KGB] Wait for locale lock to be released on ~A // xmlfile,
		flock(xml), //<sb> query exclusive access on the locale file
		try Sax/sax(xml, start_tag, leave_tag, list<string>())
		catch any
			//[LOCALE_FILES] Error loading XML locale :\n~S // exception!(),
		fclose(xml),
		true) else false]
		

[leave_tag(parser:Sax/sax_parser,x:list[string], self:{"locales"}, cdata:string) : void -> none]
[start_tag(parser:Sax/sax_parser,x:list[string], self:{"locales"}, attrs:table) : list[string] -> x]

[leave_tag(parser:Sax/sax_parser,x:list[string], self:{"lang","reflang","vreflang"}, cdata:string) : void -> none]
[start_tag(parser:Sax/sax_parser,x:list[string], self:{"lang","reflang","vreflang"}, attrs:table) : list[string] ->
	let l := language(iso = attrs["iso"])
	in (if not(exists(i in CURRENT_LOCALE_CONTEXT.languages | i.iso = l.iso)) (
			if (self = "reflang" | self = "vreflang")
				(l.virtual? := (self = "vreflang"),
				CURRENT_LOCALE_CONTEXT.reference_language := l)
			else l.ref := attrs["ref"], // get_language(attrs["ref"]),
			CURRENT_LOCALE_CONTEXT.languages :add l)
		else //[LOCALE_FILES] lang allready exists : ~S // attrs["iso"], 
		x)]


[leave_tag(parser:Sax/sax_parser,x:list[string], self:{"term"}, cdata:string) : void -> shrink(x, 0)]
[start_tag(parser:Sax/sax_parser,x:list[string], self:{"term"}, attrs:table) : list[string] ->
	x :add url_decode(attrs["applicable"] as string),
	x]

[leave_tag(parser:Sax/sax_parser,x:list[string], self:{"reference"}, cdata:string) : void ->
	x :add xml_decode_locale(cdata),
	insert_term(CURRENT_LOCALE_CONTEXT.reference_language, x[1], x[2], xml_decode_locale(cdata))]

[start_tag(parser:Sax/sax_parser,x:list[string], self:{"reference"}, attrs:table) : list[string] -> x]


[start_tag(parser:Sax/sax_parser,ud:list[string], self:ISO_CODE, attrs:table) : list[string] -> ud]
[leave_tag(parser:Sax/sax_parser,ud:list[string], self:ISO_CODE, cdata:string) : void ->
	insert_term(upper(self), ud[1], ud[2], xml_decode_locale(cdata))]


[xp_sort_term(term1:term,term2:term) : boolean
->	if (term1.applicable = term2.applicable)
		let t1 := upper(term1.reference), t2 := upper(term2.reference)
		in (if (t1 = t2) (
				if (term1.reference = term2.reference) term1.lang.iso < term2.lang.iso
				else (term1.reference < term2.reference))
			else (t1 < t2))
	else (term1.applicable < term2.applicable)]
		
[print_xml() : void -> print_xml(CURRENT_LOCALE_CONTEXT)]

[print_xml(all:boolean) : void -> print_xml(CURRENT_LOCALE_CONTEXT,all)]

[print_xml(ctx:locale_context) : void -> print_xml(ctx,false)]

[print_xml(ctx:locale_context,all:boolean) : void ->
	printf("<?xml version=\"1.0\" encoding=\"windows-1252\"?>\n"),
	printf("<locales>\n"),
	when l := get(reference_language,ctx)
	in (if (all | l.user?)
			printf("\t<~A iso=~S/>\n",
					(if virtual?(l) "vreflang" else "reflang"),
							l.iso)),
	for l in (ctx.languages but get(reference_language,ctx))
		(if (all | l.user?)
			printf("\t<lang iso=~S~I/>\n",
								l.iso,
								(if known?(ref,l) printf(" ref=~S",l.ref)))),
	let curr_ref:string := "",
		curr_app:string := "",
		ontag:boolean := false
	in (for t in sort(xp_sort_term @ term, extract_terms(ctx)) (
			if ((all | t.user?) & (t.reference != t.localized))
				(//[LOCALE_KGB] ~S curr_app=~S curr_ref=~S // t,curr_app,curr_ref,
				if ((curr_app != t.applicable | curr_ref != t.reference)) (
					if ontag printf("\n\t</term>")
					else ontag := true,
					curr_app := t.applicable,
					curr_ref := t.reference, 
					?>
	<term applicable="<?= url_encode(curr_app) ?>">
		<reference><? xml_encode_locale(curr_ref) ?></reference><? ),
			?>
		<<?= t.lang.iso ?>><? xml_encode_locale(t.localized) ?></<?= t.lang.iso ?>><? )),
		if ontag printf("\n\t</term>"),
		printf("\n</locales>"))]


// *********************************************************************
// *   7. admin API                                                    *
// *********************************************************************

[reset_locale() : void ->
	for i in (1 .. length(CURRENT_LOCALE_CONTEXT.translation_map))
		CURRENT_LOCALE_CONTEXT.translation_map[i] := unknown_term]

[generate_serialized_locale_files() : void ->
	for l in CURRENT_LOCALE_CONTEXT.languages (if not(virtual?(l)) save_serialized(l.iso))]

[generate_serialized_locale_files(ctx:locale_context) : void ->
	for l in ctx.languages (if not(virtual?(l)) save_serialized(l.iso))]


[merge_locale_with_xml_file(xmlfile:string) : void ->
	(// load_xml(xmlfile),
	load_xml(),
	generate_serialized_locale_files())]

[reset_locale_with_xml_file() : void ->
	let ctx := locale_context!()
	in (reset_locale_with_xml_file(ctx))]

[reset_locale_with_xml_file(xmlfile:string) : void ->
	reset_locale(),
	merge_locale_with_xml_file(xmlfile)]


should_update_xml_from_serialized?() : boolean -> false


// *********************************************************************
// *   7. admin API                                                    *
// *********************************************************************

private/context_loader <: ephemeral_object(private/loader_ctx:locale_context, private/xmldata:list[string], user?:boolean = false)

[load_xml(_ctx:locale_context,xmlfile:string) : boolean -> load_xml(_ctx,xmlfile,false)]

[load_xml(_ctx:locale_context,xmlfile:string,user_mode:boolean) : boolean
->	//[LOCALE_FILES] load_xml(_ctx,~S,~S) // xmlfile, user_mode,
	if isfile?(xmlfile)
		let xml := fopen(xmlfile, "r"),
			loader := context_loader(loader_ctx = _ctx, xmldata = list<string>(), user? = user_mode)
		in (if islocked?(xml)
				//[LOCALE_KGB] Wait for locale lock to be released on ~A // xmlfile,
			flock(xml), //<sb> query exclusive access on the locale file
			try (Sax/sax(xml, start_tag, leave_tag,loader), 
				//[LOCALE_KGB] load ok,
				true)
			catch any (
				//[LOCALE_FILES] Error loading XML locale :\n~S // exception!(),
				false))
	else ( 
		//[LOCALE_FILES] load_xml :  file not found ~S // xmlfile,
		false)]
		

[load_xml(_ctx:locale_context) : boolean
->	load_xml(_ctx,_ctx.locale_path / _ctx.reference_file,false),
	load_xml(_ctx,_ctx.locale_path / _ctx.locale_file,true),
	true]

[context_from_file(xmlfile:string) : (locale_context U {unknown}) ->
	//[LOCALE_FILES] loading locale xml from : ~S // xmlfile, 
	if isfile?(xmlfile) 
		let xml := fopen(xmlfile, "r"),
			loader := context_loader(loader_ctx = locale_context!(xmlfile), xmldata = list<string>())
		in (if islocked?(xml)
				//[LOCALE_KGB] Wait for locale lock to be released on ~A // xmlfile,
			flock(xml), //<sb> query exclusive access on the locale file
			when res := (try (Sax/sax(xml, start_tag, leave_tag,loader), loader.loader_ctx)
						catch any (
							//[LOCALE_FILES] Error loading XML locale :\n~S // exception!(),
							unknown))
			in (fclose(xml), res)
			else (fclose(xml),unknown)) else unknown]
		

[leave_tag(parser:Sax/sax_parser, x:context_loader, self:{"locales"}, cdata:string) : void -> none]
[start_tag(parser:Sax/sax_parser, x:context_loader, self:{"locales"}, attrs:table) : context_loader -> x]

[leave_tag(parser:Sax/sax_parser,x:context_loader, self:{"lang","reflang","vreflang"}, cdata:string) : void -> none]
[start_tag(parser:Sax/sax_parser,x:context_loader, self:{"lang","reflang","vreflang"}, attrs:table) : context_loader ->
	let l := language(iso = attrs["iso"], user? = x.user?)
	in (if not(exists(i in x.loader_ctx.languages | i.iso = l.iso)) (
			if (self = "reflang" | self = "vreflang")
				(l.virtual? := (self = "vreflang"),
				x.loader_ctx.reference_language := l)
			else l.ref := attrs["ref"], // get_language(attrs["ref"],x.loader_ctx),
			x.loader_ctx.languages :add l)
		else //[LOCALE_FILES] lang allready exists : ~S // attrs["iso"], 
		x)]

[leave_tag(parser:Sax/sax_parser,x:context_loader, self:{"term"}, cdata:string) : void -> 
	shrink(x.xmldata, 0)]
[start_tag(parser:Sax/sax_parser,x:context_loader, self:{"term"}, attrs:table) : context_loader ->
	x.xmldata :add url_decode(attrs["applicable"] as string),
	x]

[leave_tag(parser:Sax/sax_parser, x:context_loader, self:{"reference"}, cdata:string) : void ->
	x.xmldata :add xml_decode_locale(cdata),
	//[LOCALE_KGB] reference = ~S , user = ~S // cdata , x.user?,
	insert_term(x.loader_ctx,x.loader_ctx.reference_language, x.xmldata[1], x.xmldata[2], xml_decode_locale(cdata),x.user?)]

[start_tag(parser:Sax/sax_parser, x:context_loader, self:{"reference"}, attrs:table) : context_loader -> x]


[start_tag(parser:Sax/sax_parser, ud:context_loader, self:ISO_CODE, attrs:table) : context_loader -> ud]
[leave_tag(parser:Sax/sax_parser, ud:context_loader, self:ISO_CODE, cdata:string) : void
-> insert_term(ud.loader_ctx,upper(self), ud.xmldata[1], ud.xmldata[2], xml_decode_locale(cdata), ud.user?)]




[html_entities(src:string) : void ->
	let len := length(src)
	in externC("{
		char *max = src + len;
		char buf[256];
		char *travel = buf;
		while(src < max) {
			int c = (unsigned char)(*src);
			if(c >= 32 && c <= 64) {
				switch(c) {
					case '\\\"':
						{*travel++ = '&';
						*travel++ = 'q';
						*travel++ = 'u';
						*travel++ = 'o';
						*travel++ = 't';
						*travel++ = ';';
						break;}
					case '\\'':
						{*travel++ = '&';
						*travel++ = '#';
						*travel++ = '3';
						*travel++ = '9';
						*travel++ = ';';
						break;}
					case '<':
						{*travel++ = '&';
						*travel++ = 'l';
						*travel++ = 't';
						*travel++ = ';';
						break;}
					case '>':
						{*travel++ = '&';
						*travel++ = 'g';
						*travel++ = 't';
						*travel++ = ';';
						break;}
					case '&':
						{*travel++ = '&';
						*travel++ = 'a';
						*travel++ = 'm';
						*travel++ = 'p';
						*travel++ = ';';
						break;}
					default: *travel++ = c;
				}
			}
			else *travel++ = c;
			if (travel - buf > 240) {
				Core.write_port->fcall((CL_INT)ClEnv->cout, (CL_INT)buf, (CL_INT)(travel - buf));
				travel = buf;
			}
			src++;
		}
		if (travel - buf > 0)
			Core.write_port->fcall((CL_INT)ClEnv->cout, (CL_INT)buf, (CL_INT)(travel - buf));}")]


[option_respond(opt:{"-buildlocales"}, l:list[string]) : void ->
	if not(l) invalid_option_argument(),
	let sources := list<string>()
	in (while (l & isfile?(l[1])) (
				sources add l[1],
				l << 1),
		//[LOCALE_FILES] Build serialized from files ~S // sources,
		if not(sources) invalid_option_argument(),
		for s in sources load_xml(s),
		CURRENT_LOCALE_CONTEXT.locale_path := ".",
		generate_serialized_locale_files())]

[option_usage(self:{"-buildlocales"}) : tuple(string, string, string) ->
	tuple("Build serialied files from xml sources",
			"-buildlocales +[<file>]",
			"Build serialized locales from xml source")]

// *********************************************************************
// *   8. JSON                                                        *
// *********************************************************************

[save_json(ctx:locale_context,self:ISO_CODE) : void ->
	//[LOCALE_FILES] save_json(~S) // self,
	if available_locale?(self,ctx)
		let path := ctx.locale_path / self /+ ".json",
			f := fopen(path, "w"),
			basel := ctx.reference_language,
			myl := get_language(self,ctx),
			ut := unknown_term,
			oldp := use_as_output(f),
			first := true
		in (//[LOCALE_FILES] save_json(~A) // self,
			if islocked?(f)
				//[LOCALE_KGB] Wait for session lock to be released on ~A // path,
			flock(f), //<sb> query exclusive access on the locale json file
			printf("{"),
			for t in extract_terms(ctx,basel) (
				//[LOCALE_KGB] base: ~S // t,
				let x := get_best_term(ctx,myl,t as  term)
				in (let lapp := length(x.applicable),
							lref := length(x.reference),
							lloc := length(x.localized)
					in (if not(first) printf(",") else first := false,
						printf("~S:~S",x.reference,x.localized)))),
			printf("}"),
			use_as_output(oldp),
			fclose(f))]

[save_json(ctx:locale_context) : void ->
	for l in ctx.languages (if not(virtual?(l)) save_json(ctx,l.iso))]

[save_json() : void -> save_json(CURRENT_LOCALE_CONTEXT)]

[option_respond(opt:{"-locales2json"},l:list[string]) : void ->
	if not(l) invalid_option_argument(),
	let sources := list<string>()
	in (while (l & isfile?(l[1])) (
				sources add l[1],
				l << 1),
		//[LOCALE_FILES] Build serialized from files ~S // sources,
		if not(sources) invalid_option_argument(),
		for s in sources load_xml(s),
		CURRENT_LOCALE_CONTEXT.locale_path := ".",
		save_json())]

[option_usage(self:{"-locales2json"}) : tuple(string, string, string) ->
	tuple("Build json files from xml sources",
			"-locales2json +[<xmlfile>]",
			"Build json locales from xml source")]

/*
[gettext(self:string) : string -> copy(externC("((char*)gettext(self))",string))]

[bindtextdomain(domainname:string,dirname:string) : string -> copy(externC("((char*)bindtextdomain(domainname,dirname))",string))]
*/