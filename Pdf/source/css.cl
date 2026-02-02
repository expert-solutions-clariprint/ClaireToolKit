
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * css.cl                                                            *
// * Copyright (C) 2000 - 2006 xl. All Rights Reserved                 *
// *********************************************************************

// @cat css
// CSS is at style This module comes with an implementation of CSS 2.
// @eval
// princ("\\br \\table\\align=center\\class=doc_paragraph\\border=1\\style='border-collapse:collapse'
// 						 \\thead \\tr \\th property\\th inheritance \\th default \\th range \\/thead "),
// for p in css_property
// 		printf("\\tr \\td ~A \\td ~I \\td ~S \\td ~S",
// 					replace(p.name.name,"css_",""),
// 					(if p.css_inherit? princ("inherit")),
// 					p.default,
// 					p.range),
// princ("\\/table \\br ")
// @eval
// @cat


// *********************************************************************
// *   Part 1: CSS units                                               *
// *********************************************************************

css_relative_length <: ephemeral_object(value:float)
	css_percentage <: css_relative_length()
	css_font_relative_length <: css_relative_length()
		css_em <: css_font_relative_length()
		css_ex <: css_font_relative_length()

self_print(self:css_em) : void -> printf("~Sem", self.value)
self_print(self:css_ex) : void -> printf("~Sex", self.value)
self_print(self:css_percentage) : void -> printf("~S%", self.value)

length!(self:string) : any ->
	let val := float!(self)
	in (if match_wildcard?(self, "*%")
			css_percentage(value = val)
		else if match_wildcard?(self, "*mm")
			mm2pt(val)
		else if match_wildcard?(self, "*cm")
			10. * mm2pt(val)
		else if match_wildcard?(self, "*in")
			72. * val
		else if match_wildcard?(self, "*pc")
			12. * val
		else if match_wildcard?(self, "*em")
			css_em(value = val)
		else if match_wildcard?(self, "*ex")
			css_ex(value = val)
		else val) // includes 'px' unit

// *********************************************************************
// *   Part 1: CSS properties                                          *
// *********************************************************************

css_counter <: ephemeral_object(name:string, value:integer = 0, reset-value:integer = 0)
css_counter_increment <: ephemeral_object(name:string, increment:integer = 1)
css_counter_reference <: ephemeral_object(name:string, style:string = "decimal")
	css_counters_reference <: css_counter_reference(separator:string = "")
css_string <: ephemeral_object(value:string)


self_print(self:css_counter) : void -> printf("~A ~S", self.name, self.reset-value)
self_print(self:css_counter_increment) : void -> printf("~A ~S", self.name, self.increment)
self_print(self:css_string) : void -> print(self.value)
self_print(self:css_counter_reference) : void -> printf("counter(~A, ~A)", self.name, self.style)
self_print(self:css_counters_reference) : void -> printf("counters(~A, ~A, ~S)", self.name, self.style, self.separator)

css_property <: thing(css_inherit?:boolean = false,
					float?:boolean = false,
					range:type = string,
					default:any)

		css_black :: BLACK
		css_white :: WHITE
		css_range_length :: (css_font_relative_length U float U {"inherit"})
		css_range_lineheight :: (css_font_relative_length U float U {"normal", "inherit"})
		css_range_width :: (css_relative_length U float U {"auto", "inherit"})
		css_range_font_size :: (css_relative_length U float U {"inherit"})
		css_range_color :: (tuple(float, float, float) U {"inherit"})
		css_range_vertical_alignement :: {"baseline", "super", "sub", "top", "middle", "bottom", "inherit"}
		css_range_text_alignement :: {"left", "right", "center", "justify", "inherit"}
		css_range_break_before_after :: {"always", "avoid", "auto", "inherit"}
		css_range_break_inside :: {"avoid", "auto", "inherit"}
		css_range_border_style :: {"none", "solid", "dashed", "dotted", "inherit"}

	// Box
	css_margin-top :: css_property(default = 0.0, range = css_range_length)
	css_margin-right :: css_property(default = 0.0, range = css_range_width)
	css_margin-bottom :: css_property(default = 0.0, range = css_range_length)
	css_margin-left :: css_property(default = 0.0, range = css_range_width)

	css_padding-top :: css_property(default = 0.0, range = css_range_length)
	css_padding-right :: css_property(default = 0.0, range = css_range_length)
	css_padding-bottom :: css_property(default = 0.0, range = css_range_length)
	css_padding-left :: css_property(default = 0.0, range = css_range_length)

	css_border-top-color :: css_property(default = css_black, range = css_range_color)
	css_border-right-color :: css_property(default = css_black, range = css_range_color)
	css_border-bottom-color :: css_property(default = css_black, range = css_range_color)
	css_border-left-color :: css_property(default = css_black, range = css_range_color)

	css_border-top-style :: css_property(default = "none", range = css_range_border_style)
	css_border-right-style :: css_property(default = "none", range = css_range_border_style)
	css_border-bottom-style :: css_property(default = "none", range = css_range_border_style)
	css_border-left-style :: css_property(default = "none", range = css_range_border_style)

	css_border-top-width :: css_property(default = 0., range = css_range_length)
	css_border-right-width :: css_property(default = 0., range = css_range_length)
	css_border-bottom-width :: css_property(default = 0., range = css_range_length)
	css_border-left-width :: css_property(default = 0., range = css_range_length)

	// Dimension
	css_width :: css_property(default = "auto", range = css_range_width)
	css_height :: css_property(default = "auto", range = css_range_width)

	css_vertical-align :: css_property(default = "baseline", range = css_range_vertical_alignement)

	// Paging
	css_page-break-before :: css_property(default = "auto", range = css_range_break_before_after)
	css_page-break-after :: css_property(default = "auto", range = css_range_break_before_after)
	css_page-break-inside :: css_property(default = "auto", css_inherit? = true, range = css_range_break_inside)

	// Color / background
	css_color :: css_property(default = css_black, css_inherit? = true, range = css_range_color)

	css_background-color :: css_property(default = css_white, range = css_range_color)
	css_background-image :: css_property(default = "none", range = string)
//	css_background-position :: css_property()

	// Text
	css_font-family :: css_property(css_inherit? = true, default = "Helvetica", range = (string U list))
	css_font-style :: css_property(css_inherit? = true, default = "normal", range = {"normal", "italic", "oblique", "inherit"})
	css_font-weight :: css_property(css_inherit? = true, default = "normal", range = {"normal", "bold", "inherit"})
	css_font-size :: css_property(css_inherit? = true, default = 12., range = css_range_font_size)

	css_text-align :: css_property(css_inherit? = true, default = "left", range = css_range_text_alignement)
	css_text-indent :: css_property(css_inherit? = true, default = 0., range = css_range_width)
	css_text-decoration :: css_property(default = "none", range = {"none", "underline", "inherit"})
	css_text-transform :: css_property(default = "none", range = {"none", "capitalize", "uppercase", "lowercase", "inherit"})

	css_letter-spacing :: css_property(css_inherit? = true, default = "normal", range = css_range_length)

	css_word-spacing :: css_property(css_inherit? = true, default = "normal", range = css_range_length)

	css_line-height :: css_property(css_inherit? = true, default = "normal", range = css_range_lineheight)

	css_white-space :: css_property(css_inherit? = true, default = "normal", range = {"normal", "pre", "nowrap", "inherit"})

	// Table
	css_border-collapse :: css_property(css_inherit? = true, default = "separate", range = {"collapse", "separate", "inherit"})
	css_border-spacing :: css_property(css_inherit? = true, default = css_em(value = 0.2), range = css_range_length)


	// generated content
	css_content :: css_property(css_inherit? = false, default = "none", range = ({"none", "inherit"} U list))
	css_counter-reset :: css_property(css_inherit? = false, default = "none", range = ({"none", "inherit"} U list))
	css_counter-increment :: css_property(css_inherit? = false, default = "", range = ({"none", "inherit"} U list))

	// generated content
	css_debug :: css_property(css_inherit? = false, default = "no", range = ({"yes", "no", "inherit"}))

[nth(self:css_selector, p:css_property) : any ->
	let res := unknown,
		i := 1,
		l := self.properties,
		len := length(l)
	in (while (i < len)
			(if (l[i] = p)
				(res := l[i + 1],
				break()), i :+ 2), res)]

(write(Core/status, nth @ css_selector, ^2(SAFE_GC) + ^2(SAFE_RESULT)))


// *********************************************************************
// *   Part 2: CSS selectors                                           *
// *********************************************************************


css_attribute_match <: ephemeral_object(name:string)
	css_attribute_match_exists <: css_attribute_match()
	css_attribute_match_equal <: css_attribute_match(value:string)
	css_attribute_match_start <: css_attribute_match(value:string)
	css_attribute_match_some <: css_attribute_match(values:list[string])



css_selector <: ephemeral_object(specificity:integer,
								element_name:string = "attribute", // * or a valid name
								attributes:list[css_attribute_match],
								child_of:css_selector,
								descendant_of:css_selector,
								sibling_to:css_selector,
								properties:list[any],
								slocation:bag)


css_style_sheet <: ephemeral_object(rules:list[css_selector])

// css_styler is an ordered linked list of selector matching
// a given element (used for style @ html_element)
css_styler <: ephemeral_object
css_styler <: ephemeral_object(selector:css_selector, next:css_styler)


[self_print(self:css_attribute_match) : void ->
	printf("[~A~I]", self.name,
		(case self
			(css_attribute_match_equal printf("=~A", self.value),
			css_attribute_match_start printf("~A=~A", "~", self.value),
			css_attribute_match_some printf("|=~A", self.values))))]

PRINTED_LOCATION:any := unknown

[print_location(self:css_selector) : void ->
	if (PRINTED_LOCATION != self.slocation)
		(PRINTED_LOCATION := self.slocation,
		?><tr><td style='background-color: #a6edbb;font-size:0.8em' colspan=4><?
			if (length(self.slocation) >= 3 & self.slocation[3] % string)
				( ?><?== self.slocation[3] ?> <? ),
			if isfile?(self.slocation[1]) Core/edit_link(self.slocation)
			else 
				( ?><?== self.slocation[1],
				if (length(self.slocation) > 1)
					( ?>:<?= self.slocation[2])))]

[self_print(self:css_selector) : void ->
	printf("~I~I~I",
			(if known?(descendant_of, self) printf("~S ", self.descendant_of)
			else if known?(sibling_to, self) printf("~S + ", self.sibling_to)
			else if known?(child_of, self) printf("~S > ", self.child_of)),
			(if known?(element_name,self) princ(self.element_name)),
			(for a in self.attributes print(a)))]

[print_prop_value(self:any) : void ->
	case self
		(list 
			let f? := true
			in for x in self
				(if f? f? := false else princ(" "),
				print_prop_value(x)),
		string princ(self),
		any print(self))]

[update_selector_specificity(self:css_selector) : css_selector ->
	let s := 0
	in (if known?(child_of, self)
			(update_selector_specificity(self.child_of),
			s :+ self.child_of.specificity),
		if known?(descendant_of, self)
			(update_selector_specificity(self.descendant_of),
			s :+ self.descendant_of.specificity),
		if known?(sibling_to, self)
			(update_selector_specificity(self.sibling_to),
			s :+ self.sibling_to.specificity),
		if not(match_wildcard?(self.element_name, "#**")) s :+  1,
		for a in self.attributes
			case a.name
				({"id"} s :+ 1000,
				{"class"} s :+ 100),
		self.specificity := s,
		self)]

pop :: 'P'
popo :: "popopo"





// *********************************************************************
// *   Part 4: CSS parsing                                             *
// *********************************************************************

[skip_comment(p:port) : void ->
	let c := fread(p, 1)
	in case c
		({"*"} freadline(p,"*/"),
		any unget(p, c))]

[skip_space(p:port) : void ->
	while not(eof?(p))
		let c := fread(p, 1)
		in case c
			({" ", "\t", "\r", "\n"} none,
			{"/"} skip_comment(p),
			any (unget(p, c), break()))]

[insert_selector(self:list[css_selector], x:css_selector) : void ->
	let len := length(self)
	in (if (len = 0) self add x
		else
			for i in (1 .. len)
				(if (x.specificity >= self[i].specificity)
					(nth+(self, i, x),
					break())
				else if (i = len) self add x))]

[read_css_at(self:css_style_sheet, p:port) : void ->
	let (cmd, dum) := freadline(p, {'\n', '\t', ' ', '\r', '{'})
	in (case cmd
			({"import"}
				let (st, dum) := freadline(p, {'\n', '\t', ' ', '\r'})
				in (try
						let f := fopen_source(st)
						in (CURRENT_LOCATION := nil,
							read_css(self, f),
							fclose(f))
					catch any none),
			{"media"}
				let types := explode(freadline(p, "{"),",")
				in (for t in types
						(t := trim(t),
						case t
							({"print", "screen"} read_css(self, p),
							any
								read_css(css_style_sheet(), p))))))]

[read_css(self:css_style_sheet, p:port) : void ->
	let sels := list<css_selector>(),
		cur := unknown
	in while not(eof?(p))
		(skip_space(p),
		let c := fread(p, 1)
		in case c
			({"/"} skip_comment(p),
			{"@"} read_css_at(self, p),
			{"}"} break(),
			{"{"} (skip_space(p),
					case cur
						(css_selector 
							(if not(cur % sels) sels add cur)),
					let pset := read_properties(p)
					in for sel in sels
						(sel.properties := pset,
						insert_selector(self.rules, update_selector_specificity(sel))),
					shrink(sels, 0),
					cur := unknown),
			{","} (case cur
						(css_selector sels add cur),
					cur := unknown),
			{">"}
				(skip_space(p),
				if unknown?(cur)
					error("CSS parsing error in ~S missing argument in > rule", p),
				let sel := read_selector(p)
				in (sel.child_of := cur,
					cur := sel)),
			{"+"}
				(skip_space(p),
				if unknown?(cur)
					error("CSS parsinf error in ~S missing argument in + rule", p),
				let sel := read_selector(p)
				in (case cur
						(css_selector sel.sibling_to := cur),
					cur := sel)),
			any (unget(p, c),
				let sel := read_selector(p)
				in (case cur
						(css_selector sel.descendant_of := cur),
					cur := sel))))]

// *********************************************************************
// *   Part 5: CSS selector parsing                                    *
// *********************************************************************

CURRENT_LOCATION:bag := tuple("[core style sheet] source/css.cl")

[read_selector(p:port) : css_selector ->
	let loc := (if CURRENT_LOCATION CURRENT_LOCATION else Core/get_location(p)),
		(elem, sep) := freadline(p, {".", "[", "#", ",", "{", " ", "\t", "\n", "\r"}),
		sel := css_selector(element_name = lower((if (length(elem) = 0) "*" else elem)),
							slocation = loc)
	in (unget(p, sep),
		if not(sep % {",", "{", " ", "\t", "\n", "\r"})
			let c := fread(p, 1)
			in (case c
					({"."} read_class_attribute(sel, p),
					{"#"} read_id_attribute(sel, p),
					{"["} read_any_attribute(sel, p))),
		sel)]

[read_class_attribute(self:css_selector, p:port) : void ->
	let (cls, sep) := freadline(p, {".", "#", "[", ",", "{", " ", "\t", "\n", "\r"})
	in (self.attributes add css_attribute_match_equal(name = "class", value = cls),
		case sep
			({"."} read_class_attribute(self, p),
			{"#"} read_id_attribute(self, p),
			{"["} read_any_attribute(self, p),
			any unget(p, sep)))]

[read_id_attribute(self:css_selector, p:port) : void ->
	let (id, sep) := freadline(p, {".", "#", "[", ",", "{", " ", "\t", "\n", "\r"})
	in (self.attributes add css_attribute_match_equal(name = "id", value = id),
		case sep
			({"."} read_class_attribute(self, p),
			{"#"} read_id_attribute(self, p),
			{"["} read_any_attribute(self, p),
			any unget(p, sep)))]

[read_any_attribute(self:css_selector, p:port) : void ->
	let (attr, sep) := freadline(p, {"=", "~=", "|=","]"}),
		att_match :=
			(case sep
				({"="} css_attribute_match_equal(name = trim(attr),
							value = trim(freadline(p, "]"))),
				{"~="} css_attribute_match_some(name = trim(attr),
							values = explode(trim(freadline(p, "]")), " ")),
				{"|="} css_attribute_match_start(name = trim(attr),
							value = trim(freadline(p, "]"))),
				any /*"]"*/ css_attribute_match_exists(name = trim(attr))))
	in (self.attributes add att_match,
		let c := fread(p, 1)
		in case c
				({"."} read_class_attribute(self, p),
				{"#"} read_id_attribute(self, p),
				{"["} read_any_attribute(self, p),
				any unget(p, c)))]


// *********************************************************************
// *   Part 5: CSS property parsing                                    *
// *********************************************************************

[add_property(self:css_selector, p:css_property, val:any) : void =>
	add_property(self.properties, p, val)]
[add_property(self:list[any], p:css_property, val:any) : void ->
	if (val % p.range)
		let i := get(self, p)
		in (val := (if (val = "inherit") css_inherit?
					else val),
			if (i > 0) self[i + 1] := val
			else
				(self add p,
				self add val))]

[add_counter_reset(self:list[any], l:list) : void ->
	let nl := list<any>()
	in (for v in l
			(if alpha?(v[1])
				nl add css_counter(name = v)
			else if (length(nl) > 0)
				(last(nl) as css_counter).reset-value := integer!(v)),
		if nl
			add_property(self, css_counter-reset, nl))]

[add_counter_increment(self:list[any], l:list) : void ->
	let nl := list<any>()
	in (for v in l
			(if alpha?(v[1])
				nl add css_counter_increment(name = v)
			else if (length(nl) > 0)
				(last(nl) as css_counter_increment).increment := integer!(v)),
		if nl
			add_property(self, css_counter-increment, nl))]


[read_counter(p:port) : css_counter_reference ->
	let ct := css_counter_reference()
	in (let (cname, e) := freadline(p, {",", ")"})
		in (ct.name := trim(cname),
			if (e = ",")
				let (cstyle, e) := freadline(p, {")"})
				in ct.style := trim(cstyle)),
		ct)]

[read_counters(p:port) : css_counters_reference ->
	let ct := css_counters_reference()
	in (let (cname, e) := freadline(p, {",", ")"})
		in (ct.name := cname,
			if (e = ",")
				let (dum, e) := freadline(p, {"\"", ")"})
				in (if (e = "\"")
						(ct.separator := freadline(p, "\"", false, '\\'),
						if (freadline(p, {",", ")"})[1] = ",")
							let (cstyle, e) := freadline(p, {")"})
							in ct.style := trim(cstyle)))),
		ct)]

[read_property_value(p:port) : tuple(list[any], string) ->
	let l := list<any>(),
		ed := ""
	in (while true
			let (s, e) := freadline(p, {"/*", "counter(", "counters(", "\t", " ", "\n", "\r", "\"", ";", "}"})
			in (if (length(s) > 0)
					l add trim(s),
				case e
					({"", ";", "}"} (ed := e, break()),
					{"counter("} l add read_counter(p),
					{"counters("} l add read_counters(p),
					{"\""} l add css_string(value = freadline(p, "\"", false, '\\')),
					{"/*"} freadline(p, "*/"))),
		if not(l) l add "",
		tuple(l, ed))]

[read_properties(p:port) : list[any] ->
	let pset := list<any>()
	in (while not(eof?(p))
			let (sprop, dot) := (skip_space(p), freadline(p,{":", "}"}))
			in (sprop := trim(sprop),
				if (dot = "}") break()
				else
					let	(l, end) := read_property_value(p),
						css_val := "css_" /+ sprop,
						short? := true,
						val := l[1]
					in (sprop := lower(sprop),
						when prop := some(p in css_property|p.name.name = css_val)
						in (short? := false,
							if (val = "inherit") add_property(pset, prop, "inherit")
							else if (prop = css_counter-reset) add_counter_reset(pset, l)
							else if (prop = css_counter-increment) add_counter_increment(pset, l)
							else if (list <= prop.range) add_property(pset, prop, l)
							else case val
								(string
									(if (prop.range = css_range_width)
										add_property(pset, prop,
											(case val ({"auto"} val, any length!(val))))
									else if (float <= prop.range)
										add_property(pset, prop, length!(val))
									else if (prop.range = css_range_color)
										add_property(pset, prop, string2color(val))
									else add_property(pset, prop, val)))),
						if short?
							shorthand_property(sprop, cast!(list{x in l|x % string}, string), pset),
						if (end = "}" | end = "") break())),
		pset)]

[shorthand_property(self:string, vals:list[string], pset:list[any]) : void -> none]


[shorthand_property(self:{"border"}, vals:list[string], pset:list[any]) : void ->
	if (length(vals) = 1 & vals[1] = "inherit")
		(add_property(pset, css_border-top-style, vals[1]),
		add_property(pset, css_border-left-style, vals[1]),
		add_property(pset, css_border-bottom-style, vals[1]),
		add_property(pset, css_border-right-style, vals[1]),
		add_property(pset, css_border-top-width, vals[1]),
		add_property(pset, css_border-left-width, vals[1]),
		add_property(pset, css_border-bottom-width, vals[1]),
		add_property(pset, css_border-right-width, vals[1]),					
		add_property(pset, css_border-top-color, vals[1]),
		add_property(pset, css_border-left-color, vals[1]),
		add_property(pset, css_border-bottom-color, vals[1]),
		add_property(pset, css_border-right-color, vals[1]),					
		add_property(pset, css_border-top-color, vals[1]),
		add_property(pset, css_border-left-color, vals[1]),
		add_property(pset, css_border-bottom-color, vals[1]),
		add_property(pset, css_border-right-color, vals[1]))
	else
		for p in vals
			(case p
				(css_range_border_style
					(add_property(pset, css_border-top-style, p),
					add_property(pset, css_border-left-style, p),
					add_property(pset, css_border-bottom-style, p),
					add_property(pset, css_border-right-style, p)),
				{"thin"}
					(add_property(pset, css_border-top-width, 0.6),
					add_property(pset, css_border-left-width, 0.6),
					add_property(pset, css_border-bottom-width, 0.6),
					add_property(pset, css_border-right-width, 0.6)),
				{"thick"}
					(add_property(pset, css_border-top-width, 1.4),
					add_property(pset, css_border-left-width, 1.4),
					add_property(pset, css_border-bottom-width, 1.4),
					add_property(pset, css_border-right-width, 1.4)),
				{"medium"}
					(add_property(pset, css_border-top-width, 2.5),
					add_property(pset, css_border-left-width, 2.5),
					add_property(pset, css_border-bottom-width, 2.5),
					add_property(pset, css_border-right-width, 2.5)),
				any (if (digit?(p[1]) | p[1] = '.')
						let len := length!(p)
						in (add_property(pset, css_border-top-width, len),
							add_property(pset, css_border-left-width, len),
							add_property(pset, css_border-bottom-width, len),
							add_property(pset, css_border-right-width, len))						
					else 
						let c := string2color(p)
						in (add_property(pset, css_border-top-color, c),
							add_property(pset, css_border-left-color, c),
							add_property(pset, css_border-bottom-color, c),
							add_property(pset, css_border-right-color, c)))))]


[shorthand_property(self:{"border-width"}, vals:list[string], pset:list[any]) : void ->
	if (length(vals) = 1 & vals[1] = "inherit")
		(add_property(pset, css_border-top-width, vals[1]),
		add_property(pset, css_border-left-width, vals[1]),
		add_property(pset, css_border-bottom-width, vals[1]),
		add_property(pset, css_border-right-width, vals[1]))
	else let l := list{(case p
						({"thin"} 0.6,
						{"thick"} 1.4,
						{"medium"} 2.5,
						any length!(p)))|p in vals}
		in (if (length(l) = 1)
				(add_property(pset, css_border-top-width, l[1]),
				add_property(pset, css_border-left-width, l[1]),
				add_property(pset, css_border-bottom-width, l[1]),
				add_property(pset, css_border-right-width, l[1]))
			else if (length(l) = 2)
				(add_property(pset, css_border-top-width, l[1]),
				add_property(pset, css_border-left-width, l[2]),
				add_property(pset, css_border-bottom-width, l[1]),
				add_property(pset, css_border-right-width, l[2]))
			else if (length(l) = 3)
				(add_property(pset, css_border-top-width, l[1]),
				add_property(pset, css_border-left-width, l[2]),
				add_property(pset, css_border-bottom-width, l[3]),
				add_property(pset, css_border-right-width, l[2]))
			else if (length(l) > 3)
				(add_property(pset, css_border-top-width, l[1]),
				add_property(pset, css_border-left-width, l[4]),
				add_property(pset, css_border-bottom-width, l[3]),
				add_property(pset, css_border-right-width, l[2])))]


[shorthand_property(self:{"border-style"}, l:list[string], pset:list[any]) : void ->
	if (length(l) = 1)
		(add_property(pset, css_border-top-style, l[1]),
		add_property(pset, css_border-left-style, l[1]),
		add_property(pset, css_border-bottom-style, l[1]),
		add_property(pset, css_border-right-style, l[1]))
	else if (length(l) = 2)
		(add_property(pset, css_border-top-style, l[1]),
		add_property(pset, css_border-left-style, l[2]),
		add_property(pset, css_border-bottom-style, l[1]),
		add_property(pset, css_border-right-style, l[2]))]

[shorthand_property(self:{"border-color"}, vals:list[string], pset:list[any]) : void ->
	if (length(vals) = 1)
		(if (vals[1] = "inherit")
			(add_property(pset, css_border-top-color, vals[1]),
			add_property(pset, css_border-left-color, vals[1]),
			add_property(pset, css_border-bottom-color, vals[1]),
			add_property(pset, css_border-right-color, vals[1]))
		else
			let c := string2color(vals[1])
			in (add_property(pset, css_border-top-color, c),
				add_property(pset, css_border-left-color, c),
				add_property(pset, css_border-bottom-color, c),
				add_property(pset, css_border-right-color, c)))]


[shorthand_property(self:{"border-top"}, vals:list[string], pset:list[any]) : void ->
	if (length(vals) = 1 & vals[1] = "inherit")
		(add_property(pset, css_border-top-style, vals[1]),
		add_property(pset, css_border-top-width, vals[1]),
		add_property(pset, css_border-top-color, vals[1]))
	else
		for p in vals
			(case p
				(css_range_border_style
					add_property(pset, css_border-top-style, p),
				any (if (digit?(p[1]) | p[1] = '.')
						let len := length!(p)
						in add_property(pset, css_border-top-width, len)
					else 
						let c := string2color(p)
						in add_property(pset, css_border-top-color, c))))]

[shorthand_property(self:{"border-bottom"}, vals:list[string], pset:list[any]) : void ->
	if (length(vals) = 1 & vals[1] = "inherit")
		(add_property(pset, css_border-bottom-style, vals[1]),
		add_property(pset, css_border-bottom-width, vals[1]),
		add_property(pset, css_border-bottom-color, vals[1]))
	else
		for p in vals
			(case p
				(css_range_border_style
					add_property(pset, css_border-bottom-style, p),
				any (if (digit?(p[1]) | p[1] = '.')
						let len := length!(p)
						in add_property(pset, css_border-bottom-width, len)
					else 
						let c := string2color(p)
						in add_property(pset, css_border-bottom-color, c))))]

[shorthand_property(self:{"border-right"}, vals:list[string], pset:list[any]) : void ->
	if (length(vals) = 1 & vals[1] = "inherit")
		(add_property(pset, css_border-right-style, vals[1]),
		add_property(pset, css_border-right-width, vals[1]),
		add_property(pset, css_border-right-color, vals[1]))
	else
		for p in vals
			(case p
				(css_range_border_style
					add_property(pset, css_border-right-style, p),
				any (if (digit?(p[1]) | p[1] = '.')
						let len := length!(p)
						in add_property(pset, css_border-right-width, len)
					else 
						let c := string2color(p)
						in add_property(pset, css_border-right-color, c))))]

[shorthand_property(self:{"border-left"}, vals:list[string], pset:list[any]) : void ->
	if (length(vals) = 1 & vals[1] = "inherit")
		(add_property(pset, css_border-left-style, vals[1]),
		add_property(pset, css_border-left-width, vals[1]),
		add_property(pset, css_border-left-color, vals[1]))
	else
		for p in vals
			(case p
				(css_range_border_style
					add_property(pset, css_border-left-style, p),
				any (if (digit?(p[1]) | p[1] = '.')
						let len := length!(p)
						in add_property(pset, css_border-left-width, len)
					else 
						let c := string2color(p)
						in add_property(pset, css_border-left-color, c))))]


[shorthand_property(self:{"margin"}, vals:list[string], pset:list[any]) : void ->
	let l := list{(case x ({"auto", "inherit"} x, string length!(x), any 0.))|x in vals}
	in (if (length(l) = 2)
			(add_property(pset, css_margin-top, l[1]),
			add_property(pset, css_margin-bottom, l[1]),
			add_property(pset, css_margin-left, l[2]),
			add_property(pset, css_margin-right, l[2]))
		else if (length(l) = 1)
			(add_property(pset, css_margin-top, l[1]),
			add_property(pset, css_margin-bottom, l[1]),
			add_property(pset, css_margin-left, l[1]),
			add_property(pset, css_margin-right, l[1]))
		else if (length(l) = 3)
			(add_property(pset, css_margin-top, l[1]),
			add_property(pset, css_margin-bottom, l[3]),
			add_property(pset, css_margin-left, l[2]),
			add_property(pset, css_margin-right, l[2]))
		else if (length(l) = 4)
			(add_property(pset, css_margin-top, l[1]),
			add_property(pset, css_margin-bottom, l[3]),
			add_property(pset, css_margin-left, l[2]),
			add_property(pset, css_margin-right, l[4])))]


[shorthand_property(self:{"padding"}, vals:list[string], pset:list[any]) : void ->
	if (length(vals) = 1 & vals[1] = "inherit")
		(add_property(pset, css_padding-top, vals[1]),
		add_property(pset, css_padding-bottom, vals[1]),
		add_property(pset, css_padding-left, vals[1]),
		add_property(pset, css_padding-right, vals[1]))
	else
		let l := list{length!(x)|x in vals}
		in (if (length(l) = 2)
				(add_property(pset, css_padding-top, l[1]),
				add_property(pset, css_padding-bottom, l[1]),
				add_property(pset, css_padding-left, l[2]),
				add_property(pset, css_padding-right, l[2]))
			else if (length(l) = 1)
				(add_property(pset, css_padding-top, l[1]),
				add_property(pset, css_padding-bottom, l[1]),
				add_property(pset, css_padding-left, l[1]),
				add_property(pset, css_padding-right, l[1]))
			else if (length(l) = 3)
				(add_property(pset, css_padding-top, l[1]),
				add_property(pset, css_padding-bottom, l[3]),
				add_property(pset, css_padding-left, l[2]),
				add_property(pset, css_padding-right, l[2])))]

[shorthand_property(self:{"font"}, vals:list[string], pset:list[any]) : void ->
	for p in vals
		(if (digit?(p[1]) | p[1] = '.')
			let len := length!(p)
			in add_property(pset, css_font-size, len)
		else
			case p
				({"italic", "oblique"}
					add_property(pset, css_font-style, p),
				{"bold"}
					add_property(pset, css_font-weight, p),
				string
					add_property(pset, css_font-family, p)))]


// *********************************************************************
// *   Part 3: element styler                                          *
// *********************************************************************


[build_css_styler(self:css_style_sheet, e:html_element) : void ->
	let r := unknown,
		cur := r,
		att := get(attr_list, e),
		props := list<any>()
	in (while known?(att)
			(case att
				(html_attribute
					(case att.attr_name
						({"style"}
							let b := blob!(att.attr_value),
								pl := read_properties(b),
								len := length(pl)
							in (for i in (1 .. len)
									(if (i mod 2 = 1)
										add_property(props, pl[i], pl[i + 1])),
								fclose(b)),
						{"border"}
							let val := length!(att.attr_value)
							in (add_property(props, css_border-top-width, val),
								add_property(props, css_border-bottom-width, val),
								add_property(props, css_border-left-width, val),
								add_property(props, css_border-right-width, val),
								add_property(props, css_border-top-style, "solid"),
								add_property(props, css_border-bottom-style, "solid"),
								add_property(props, css_border-left-style, "solid"),
								add_property(props, css_border-right-style, "solid")),
						{"bordercolor"}
							let val := string2color(att.attr_value)
							in (add_property(props, css_border-top-color, val),
								add_property(props, css_border-bottom-color, val),
								add_property(props, css_border-left-color, val),
								add_property(props, css_border-right-color, val)),
						{"bgcolor"}
							let val := string2color(att.attr_value)
							in add_property(props, css_background-color, val),
						{"color"}
							let val := string2color(att.attr_value)
							in add_property(props, css_color, val),
						{"align"}
							(case e
								(html_table
									case att.attr_value
										({"center"}
											(add_property(props, css_margin-right, "auto"),
											add_property(props, css_margin-left, "auto")),
										{"justify"}
											add_property(props, css_text-align, "justify"),
										{"right"}
											(add_property(props, css_margin-left, "auto"),
											add_property(props, css_margin-right, 0.)),
										{"left"}
											(add_property(props, css_margin-left, 0.),
											add_property(props, css_margin-right, "auto"))),
								any
									case att.attr_value
										({"center"}
											add_property(props, css_text-align, "center"),
										{"left"}
											add_property(props, css_text-align, "left"),
										{"justify"}
											add_property(props, css_text-align, "justify"),
										{"right"}
											add_property(props, css_text-align, "right")))),
						{"valign"}
							add_property(props, css_vertical-align, att.attr_value),
						{"cellspacing"}
							add_property(props, css_border-spacing, length!(att.attr_value)),
						{"cellpadding"}
							let val := length!(att.attr_value)
							in (add_property(props, css_padding-top, val),
								add_property(props, css_padding-bottom, val),
								add_property(props, css_padding-left, val),
								add_property(props, css_padding-right, val)),
						{"width"}
							add_property(props, css_width, length!(att.attr_value)),
						{"face"}
							add_property(props, css_font-family, att.attr_value),
						{"point-size"}
							add_property(props, css_font-size, length!(att.attr_value)),
						{"size"}
							(if match_wildcard?(att.attr_value, "+*")
								add_property(props, css_font-size,
									css_em(value =  1.2 ^ float!(explode_wildcard(att.attr_value, "+*")[1])))
							else if match_wildcard?(att.attr_value, "-*")
								add_property(props, css_font-size,
									css_em(value = (1. / 1.2) ^ float!(explode_wildcard(att.attr_value, "-*")[1])))
							else let n := float!(att.attr_value) / 2.5
								in (add_property(props, css_font-size, css_font-size.default * n))),
						{"height"}
							add_property(props, css_height, length!(att.attr_value))))),
					att := get(next, att) as (html_attribute U {unknown})),
		if props
			(r := css_styler(selector = css_selector(properties = props, slocation = tuple("[attribute]"))),
			cur := r),
		for s in self.rules
			(if selector_match?(s, e)
				let nr := css_styler(selector = s)
				in (case cur (css_styler cur.next := nr, any r := nr),
					cur := nr)),
		case r
			(css_styler
				(e.style := r,
				build_counters(e),
				process_counter_increment(e),
				process_counter_reset(e))))]

// *********************************************************************
// *   Part 3: CSS matching                                            *
// *********************************************************************

[selector_match?(self:css_selector, e:html_element) : boolean ->
	known?(element_name, e) &
	match_wildcard?(e.element_name, self.element_name) &
		forall(a in self.attributes | attribute_match?(a, e)) &
		(unknown?(child_of, self) | child_of_match?(self, e)) &
		(unknown?(sibling_to, self) | sibling_to_match?(self, e)) &
		(unknown?(descendant_of, self) | descendant_of_match?(self, e))]


[attribute_match?(self:css_attribute_match, e:html_element) : boolean -> false]

[attribute_match?(self:css_attribute_match_exists, e:html_element) : boolean ->
	known?(e[self.name])]

[attribute_match?(self:css_attribute_match_start, e:html_element) : boolean ->
	when z := e[self.name]
	in (if alpha?(z) (find(z, self.value) = 1)
		else exists(a in explode(z, " ") | find(a, self.value) = 1))
	else false]

[attribute_match?(self:css_attribute_match_equal, e:html_element) : boolean ->
	when z := e[self.name]
	in (if alpha?(z) (z = self.value)
		else self.value % explode(z, " "))
	else false]

[attribute_match?(self:css_attribute_match_some, e:html_element) : boolean ->
	when z := e[self.name]
	in (if alpha?(z) (z % self.values)
		else exists(a in explode(z, " ") | a % self.values))
	else false]

(interface(attribute_match?))

[child_of_match?(self:css_selector, e:html_element) : boolean ->
	known?(hparent, e) &
		selector_match?(self.child_of, e.hparent)]

[sibling_to_match?(self:css_selector, e:html_element) : boolean ->
	known?(hparent, e) &
		(let l := e.hparent.hchildren,
			i := get(l, e) - 1
		in (while (i > 0 & not(l[i] % html_element)) i :- 1,
		(i >= 1 & selector_match?(self.sibling_to, l[i]))))]

[descendant_of_match?(self:css_selector, e:html_element) : boolean ->
	while known?(hparent, e)
		(e := e.hparent,
		if selector_match?(self.descendant_of, e)
			break(true))]


// *********************************************************************
// *   Part 3: CSS get                                                 *
// *********************************************************************


[css_get_element_selector(self:css_styler, prop:css_property) : (css_selector U {unknown}) ->
	when p := self.selector[prop] in self.selector
	else (if known?(next, self) css_get_element_selector(self.next, prop)
		else unknown)]

(write(Core/status, css_get_element_selector @ css_styler, ^2(SAFE_GC) + ^2(SAFE_RESULT)))


[print_element_info(self:html_entity) : void ->
	?><tr><th colspan=4 bgcolor="#93d2a6" align=left><?
		case self
			(html_element
				( ?>&lt;<? princ(self.element_name),
				let att := get(attr_list, self)
				in while known?(att)
					( ?> <?== att.attr_name
							?>='<?== att.attr_value ?>'<?
					att := get(next, att as html_attribute))  ?>&gt;<? ),
			html_word_chunk printf("~S", get(word, self)))]

[css_debug_cascade(self:html_entity, val:any, p:css_property) : void ->
	?><td><? princ(p.name.name, 5, length(p.name.name))
	?><td><? (case val (tuple printf("rgb(~A)", val), any ?><?== val)),
		case val (float ( ?>pt<? ))
	?><td<? (case val
			(tuple
				printf(" bgcolor='#~A~A~A'",
					right(hex!(integer!(val[1] * 255.)), 2),
					right(hex!(integer!(val[2] * 255.)), 2),
					right(hex!(integer!(val[3] * 255.)), 2)))) ?>><?
		case val
			(css_relative_length
				( ?><?== css_get(self, p) ?>pt<? ))]

[css_debug_cascade(self:html_entity, props:list[css_property], l:list[css_property]) : void ->
	print_element_info(self),
	case self
		(html_element
			for p in copy(props)
				(if (p = css_text-decoration)
					let ph := self,
						setby := ph
					in (while known?(hparent, ph)
							(if (css_get(ph, css_text-decoration) = "underline")
								(setby := ph,
								if (setby != self) break()),
							if (ph % html_block_element) break()
							else ph := ph.hparent),
						if (setby = self)
							(when sel := css_get_element_selector(setby.style, css_text-decoration)
							in let val := sel[p]
								in (if (known?(val) & val != css_inherit?)
									 	print_location(sel),
										if (sel.element_name = "attribute")
											( ?><tr><td>-<? )
										else
											( ?><tr><td><b><?== sel ?></b><? ),
										css_debug_cascade(self, val, p),
										props delete css_text-decoration)))
				else
					(when st := get(style, self)
					in (when sel := css_get_element_selector(st, p)
						in let val := sel[p]
							in (if (known?(val) & val != css_inherit?)
								 	(print_location(sel),
									if (sel.element_name = "attribute")
										( ?><tr><td>-<? )
									else
										( ?><tr><td><b><?== sel ?></b><? ),
									css_debug_cascade(self, val, p),
									props delete p))),
					if (p % props & (unknown?(hparent, self) | not(p.css_inherit?)))
						(l add p, props delete p)))),
	if (known?(hparent, self) & props)
		css_debug_cascade(self.hparent, props, l)]


[css_debug_cascade(self:html_entity) : void ->
	let l := list<css_property>()
	in (PRINTED_LOCATION := nil,
		css_debug_cascade(self, copy(css_property.instances), l),
		if l
			( ?><tr><th colspan=4 align=left bgcolor="#93d2a6">Core defaults<?
			for p in l
				( ?><tr><td align=center>-<?
					css_debug_cascade(self, p.default, p))))]




[css_get(self:css_styler, prop:css_property) : any ->
	when p := self.selector[prop] in p
	else (if known?(next, self) css_get(self.next, prop)
	else unknown)]

(write(Core/status, css_get @ css_styler, ^2(SAFE_GC) + ^2(SAFE_RESULT)))

[css_value(self:html_element, v:any) : any ->
	case v
		(css_em
			v.value *
				(if known?(hparent, self) css_get(self.hparent, css_font-size)
				else css_font-size.default),
		css_ex v.value *
				(let sz :=
						(if known?(hparent, self) css_get(self.hparent, css_font-size)
						else css_font-size.default),
					i := css_get_font(self)
				in get_xheight(self.ref_doc, i, sz)),
		float v,
		any v)]


[css_get(self:element_context, prop:css_property) : any => css_get(self.element, prop)]
[css_get_font(self:element_context) : integer => css_get_font(self.element)]
[css_get(self:html_entity, prop:css_property) : any ->
	case self
		(html_element none,
		html_entity self := self.hparent),
	case self
		(html_element
			let res := unknown
			in (while true
					(when st := get(style, self)
					in (let val := css_get(st, prop)
						in (if known?(val)
								(if (val = css_inherit?) // defined as 'inherit' by the style sheet
									(if known?(hparent, self) self := self.hparent
									else (res := css_value(self, prop.default), break()))
								else (res := css_value(self, val), break()))
							else if (known?(hparent, self) &
										(prop.css_inherit? | self.hparent % html_inline_element)) // inherit the parent value
								self := self.hparent
							else (res := css_value(self, prop.default), break())))
					else
						(if (known?(hparent, self) &
										(prop.css_inherit? | self.hparent % html_inline_element))
							self := self.hparent
						else (res := css_value(self, prop.default), break()))),
				res),
		any 0.)]

(write(Core/status, css_get @ html_entity, ^2(SAFE_GC)))


CSS_FONT_NAMES[self:string] : string := ""

[css_get_font(self:html_entity) : integer => css_get_font(self.hparent)]
[css_get_font(self:html_element) : integer ->
	let faces := css_get(self, css_font-family),
		sw := css_get(self, css_font-weight) as string,
		ss := css_get(self, css_font-style) as string,
		b? := (sw = "bold" | sw = "strong"),
		i? := ss != "normal"
	in (case faces
			(string
				(try get_font(self.ref_doc, faces, b?, i?)
				catch any
					get_font(self.ref_doc, "Helvetica", b?, i?)),
			list
				let good := "Helvetica",
					fid := -1
				in (for x in faces
						(case x
							(string
								(if (x[length(x)] = ',')
									shrink(x, length(x) - 1),
								if (x = "mono-space") x := "Courier",
								try (fid := get_font(self.ref_doc, x, b?, i?),
									good := x,
									break())
								catch any none))),
					shrink(faces, 0),
					if (fid = -1) fid := get_font(self.ref_doc, good, b?, i?),
					faces add good,
					fid),
			any -1))]


(write(Core/status, css_get_font @ html_entity, ^2(SAFE_GC)))
(write(Core/status, css_get_font @ html_element, ^2(SAFE_GC)))

[css_get_lineheight(self:html_entity) : float ->
	let lh := css_get(self, css_line-height)
	in (case lh
			({"normal"} css_get_float(self, css_font-size),
			any css_value(self, lh) as float))]

[css_get_float(self:html_entity, p:css_property) : float ->
	let v := css_get(self, p)
	in case v
		(float
			(if (p = css_border-spacing)
				(case css_get(self, css_border-collapse)
					({"collapse"} 0.,
					any v))
			
			else if (p = css_border-left-width | p = css_border-top-width |
					p = css_border-right-width | p = css_border-bottom-width)
				(case css_get(self, css_border-collapse)
					({"collapse"} 0.5 * v,
					any v))
			else v),
		any 0.)]

(write(Core/status, css_get_float @ html_entity, ^2(SAFE_GC)))

// for the writer
[css_scaled_get(self:html_scalable_entity, prop:css_property) : float =>
	self.scale * css_get_float(self, prop)]

(write(Core/status, css_scaled_get @ html_scalable_entity, ^2(SAFE_GC)))

[css_get_surrounding_left(self:html_element) : float ->
	let w := 0.
	in (// margin
		w :+ css_get_float(self, css_margin-left),
		// borders
		if (css_get(self, css_border-left-style) != "none")
			w :+ css_get_float(self, css_border-left-width),
		// padding
		case self
			(html_td
				(when cp := self.hparent.hparent.hparent["cellpadding"]
				in let v := length!(cp)
					in w :+ css_value(self, v)
				else w :+ css_get_float(self, css_padding-left)),
			any w :+ css_get_float(self, css_padding-left)),
		w)]

[css_get_surrounding_right(self:html_element) : float ->
	let w := 0.
	in (// margin
		w :+ css_get_float(self, css_margin-right),
		// borders
		if (css_get(self, css_border-right-style) != "none")
			w :+ css_get_float(self, css_border-right-width),
		// padding
		case self
			(html_td
				(when cp := self.hparent.hparent.hparent["cellpadding"]
				in let v := length!(cp)
					in w :+ css_value(self, v)
				else w :+ css_get_float(self, css_padding-right)),
			any w :+ css_get_float(self, css_padding-right)),
		w)]


[css_get_surrounding_top(self:html_element) : float ->
	let h := 0.
	in (// margin
		h :+ css_get_float(self, css_margin-top),
		// borders
		if (css_get(self, css_border-top-style) != "none")
			h :+ css_get_float(self, css_border-top-width),
		// padding
		case self
			(html_td
				(when cp := self.hparent.hparent.hparent["cellpadding"]
				in let v := length!(cp)
					in h :+ css_value(self, v)
				else h :+ css_get_float(self, css_padding-top)),
			any h :+ css_get_float(self, css_padding-top)),
		h)]

[css_get_surrounding_bottom(self:html_element) : float ->
	let h := 0.
	in (// margin
		h :+ css_get_float(self, css_margin-bottom),
		// borders
		if (css_get(self, css_border-bottom-style) != "none")
			h :+ css_get_float(self, css_border-bottom-width),
		// padding
		case self
			(html_td
				(when cp := self.hparent.hparent.hparent["cellpadding"]
				in let v := length!(cp)
					in h :+ css_value(self, v)
				else h :+ css_get_float(self, css_padding-bottom)),
			any h :+ css_get_float(self, css_padding-bottom)),
		h)]


// *********************************************************************
// *   Part 4: CSS counters                                            *
// *********************************************************************


[get_counter(self:html_element, cname:string) : (css_counter U {unknown}) ->
	let ct := css_get(self, css_counter-reset),
		c:(css_counter U {unknown}) := unknown
	in (case ct
			(list
				for v in ct
					case v
						(css_counter
							(if (v.name = cname)
								(c := v, break())))),
		if known?(c) c
		else if known?(hparent, self)
			get_counter(self.hparent, cname)
		else unknown)]

LOWER-ROMAN :: list("i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix", "x",
					"xi", "xii", "xiii", "xiv", "xv", "xvi", "xvii", "xviii", "xix", "xx", "xx...")

[format_counter(self:css_counter_reference, v:integer) : string ->
	case self.style
		({"lower-roman"} LOWER-ROMAN[v min length(LOWER-ROMAN) max 1],
		{"upper-roman"} upper(LOWER-ROMAN[v min length(LOWER-ROMAN) max 1]),
		{"lower-alpha"} make_string(1, char!((96 + v) min 97 max 122)),
		{"upper-alpha"} make_string(1, char!((64 + v) min 65 max 90)),
		any string!(v))]

[get_counter_value(self:html_element, ref:css_counter_reference) : string ->
	let ct := (case self 
				(html_pseudo_element get_counter(self.hparent, ref.name),
				any get_counter(self, ref.name)))
	in (case ct
			(css_counter format_counter(ref, ct.value), any ""))]


[get_counter_value(self:html_element, ref:css_counters_reference) : string ->
	let ct := (if known?(style, self) css_get(self.style, css_counter-reset)),
		res := ""
	in (case ct
			(list
				for v in ct
					case v
						(css_counter
							(if (v.name = ref.name)
								(res := format_counter(ref, v.value), break())))),
		if known?(hparent, self)
			let ps := get_counter_value(self.hparent, ref)
			in (if (length(res) = 0) res := ps
				else if (length(ps) > 0)
					res := ps /+ ref.separator /+ res),
		res)]
	

[process_counter_increment(self:html_element) : void ->
	let cti := css_get(self, css_counter-increment)
	in case cti
		(list
			for x in cti
				case x
					(css_counter_increment
						let ct := get_counter(self, x.name)
						in (case ct
								(css_counter
									(//[0] (~S) counter increment ~S -> ~S + ~S // self, ct.name, ct.value, x.increment,
									ct.value :+ x.increment)))))]

[process_counter_reset(self:html_element) : void ->
	let cti := css_get(self, css_counter-reset)
	in case cti
		(list
			for x in cti
				case x
					(css_counter x.value := x.reset-value))]

[build_counters(self:html_element) : void ->
	let ctrst := css_get(self, css_counter-reset),
		cnt := css_get(self, css_content),
		l := list<any>()
	in (case self
			(html_pseudo_element self := self.hparent),
		case ctrst
			(list
				for c in ctrst
					(case c
						(css_counter
							(c.value := c.reset-value,
							l add c)))),
		for nc in l
			(if unknown?(get_counter(self, nc.name))
				when p := get(hparent, self)
				in (if unknown?(style, p)
						(p.style := css_styler(selector = css_selector()),
						add_property(p.style.selector, css_counter-reset, list<any>(nc)))
					else let pc := css_get(p, css_counter-reset)
						in (case pc
								(list pc add nc,
								any (p.style := css_styler(selector = css_selector(), next = p.style),
									add_property(p.style.selector, css_counter-reset, list<any>(nc))))))),
		case cnt
			(list
				for c in cnt
					(case c
						(css_counter_reference
							(if unknown?(get_counter(self, c.name))
								let nc := css_counter(name = c.name)
								in (when p := get(hparent, self)
									in (if unknown?(style, p)
											(p.style := css_styler(selector = css_selector()),
											add_property(p.style.selector, css_counter-reset, list<any>(nc)))
										else let pc := css_get(p, css_counter-reset)
											in (case pc
													(list pc add nc,
													any (p.style := css_styler(selector = css_selector(), next = p.style),
														add_property(p.style.selector, css_counter-reset, list<any>(nc))))))))))))]


// *********************************************************************
// *   Part 4: CSS user style sheet                                    *
// *********************************************************************

CORE_STYLE_SHEET :: css_style_sheet()

[load_core_css(self:pdf_document) : void ->
	self.style_sheet := css_style_sheet(rules = copy(CORE_STYLE_SHEET.rules))]

[load_css(self:pdf_document, path:string) : void ->
	load_css(self.style_sheet, path)]

[load_css(self:css_style_sheet, path:string) : void ->
	let f := fopen_source(path)
	in (CURRENT_LOCATION := nil,
		read_css(self, f),
		fclose(f))]

CSS_BLOB:blob := blob!()

print_in_css <: Macro()

macroexpand(self:print_in_css) : any ->
	let loc := Language/CODE_LOCS[self]
	in Do(args =
		list((if loc
				Gassign(var = get_value(Pdf, "CURRENT_LOCATION"),
						arg = tuple(loc[1], loc[2], "[print_in_css]")) else none),
			Call(put, list(css_oldport, self.args[1],
						Call(use_as_output, list(get_value(Pdf, "CSS_BLOB"))))),
			Call(set_length, list(get_value(Pdf, "CSS_BLOB"), 0))))

[end_of_css(self:pdf_document) : void ->
	use_as_output(self.css_oldport),
	read_css(self.style_sheet, CSS_BLOB)]

// *********************************************************************
// *   Part 3: CSS core style sheet                                    *
// *********************************************************************


(#if compiler.loading?
	let b := blob!(),
		old := use_as_output(b)
	in ( ?>

		*[nowrap]						{ white-space: nowrap }
		A[href]							{ text-decoration: underline; color:blue }
		U								{ text-decoration: underline }
		EM, I							{ font-style: italic }
		H1								{ font-size: 2em; margin: .6em .3em; }
		H2								{ font-size: 1.7em; margin: .8em .5em }
		H3								{ font-size: 1.45em; margin: 1em .7em }
		H4								{ font-size: 1.25em; margin: 1.2em .9em }
		H5								{ font-size: 1.15em; margin: 1.4em 1.1em }
		H6								{ font-size: 1.1em; margin: 1.6em 1.3em }
		BODY							{ padding: 8 }
		<? /* makes compiled code using smaller static string (VC++ consideration) */ ?>
		P								{ margin: 0.5em 0 }
		UL, OL							{ margin: 0.7em 2em 0.7em 0 }
		UL OL							{ margin: 0 2em 0 0 }
		OL OL							{ margin: 0 2em 0 0 }
		OL UL							{ margin: 0 2em 0 0 }
		DD								{ margin: 0 2em 0 0 }
		DL								{ margin: 1em 0 }
		LI:before						{ content: disc " " }
		OL								{ counter-reset: core_ol_counter }
		OL LI:before					{ content: counters(core_ol_counter, ".") ". "; counter-increment: core_ol_counter; font-weight: bold; font-size: 1.1em }
		H1, H2, H3, H4, H5, H6, B		{ font-weight: bold }
		H1, H2, H3, H4, H5, H6			{ page-break-inside: avoid; }
		<? /* makes compiled code using smaller static string (VC++ consideration) */ ?>
		SUP								{ vertical-align: super; font-size: .67em; white-space: nowrap }
		SUB								{ vertical-align: sub; font-size: .67em; white-space: nowrap }
		HR								{ margin: 0.5em 0; border-top: solid #333 1; border-bottom: solid #BBB 1; border-left: solid #333 1; border-right: solid #BBB 1; margin-left: auto; margin-right: auto }
		THEAD, TH						{ vertical-align: middle; font-weight: bold; text-align: center }
		TD, TH							{ padding: 1 }
		TBODY, THEAD, TFOOT, TR, TD, TH { border: inherit }
		TR, TD, TH						{ background-color: inherit; color: inherit }
		TR, TD							{ font-weight: inherit; text-align: inherit }
		TD								{ vertical-align: middle }
		<? /* makes compiled code using smaller static string (VC++ consideration) */ ?>
		A[href] IMG,
			A[href] XOBJECT,
				A[href] AREA			{ border: solid .05em blue }
		SUP, SUB, EM, I, B, FONT		{ text-decoration: inherit }
		CODE							{ font-family: mono-space; white-space: pre }
		
		CENTER > *						{ margin-left: auto; margin-right: auto; text-align: left }
		CENTER 							{ text-align: center }

		<? /* makes compiled code using smaller static string (VC++ consideration) */ ?>
		TABLE.TOC { border: none; width: 100%; border-spacing: 0; margin: 0 0}

		TABLE.TOC TD { margin: 0 0; padding: .1em .1em }
		TABLE.TOC A[href] { text-decoration: none }

		TD.TOC_ENTRY { border-bottom: solid .5pt }
		TD.TOC_PAGENUM { border-bottom: solid .5pt; text-align: right }

		<? /* makes compiled code using smaller static string (VC++ consideration) */ ?>
		TABLE.H1 { font-size: 1.1em }
		TABLE.H2 { font-size: 1.05em }
		TABLE.H3 { font-size: 1.025em }
		TABLE.H4 { font-size: 1.012em }
		TABLE.H5 { font-size: 1.em }
		TABLE.H6 { font-size: .99em }

		<? /* makes compiled code using smaller static string (VC++ consideration) */ ?>
		TABLE.H1 TD.TOC_INDENT { width: 1% }
		TABLE.H2 TD.TOC_INDENT { width: 3% }
		TABLE.H3 TD.TOC_INDENT { width: 5% }
		TABLE.H4 TD.TOC_INDENT { width: 7% }
		TABLE.H5 TD.TOC_INDENT { width: 9% }
		TABLE.H6 TD.TOC_INDENT { width: 11% }


			<? use_as_output(old),
			read_css(CORE_STYLE_SHEET, b),
			fclose(b)))


