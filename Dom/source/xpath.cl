
[parse_attributes(p:port) : list[tuple(string,string)] ->
	let l := list<tuple(string,string)>()
	in (while true
			let (nm, sep) := freadline(p, {" ", "='", "]"})
			in (case sep
					({" "} (if (length(nm) > 0) l add tuple(nm, "*")),
					{"='"} l add tuple(nm, freadline(p, "'")),
					any (if (length(nm) > 0) l add tuple(nm, "*"),
						break()))),
		l)]

//<sb> parse the port p and fill the given list l with
// path component filters. A path component is a tuple :
// 		tuple("tag_wildcard",
//				list(tuple("attribute_wilcard", "value_wilcard")))
// Such a component should be matched against an XML element while
// processing the XPath query
[fill_xpath_query(xpath:port, l:list) : void ->
	let (elem_name, sep) := freadline(xpath, {'[','/'}),
		attrs := (if (sep = '[')
					let l := parse_attributes(xpath)
					in (sep := getc(xpath), l)
				else nil)
	in (l add tuple(elem_name, attrs),
		if (sep = '/') fill_xpath_query(xpath,l))]


[xpath_query_internal(self:(XMLDoc U XMLNode), query:list, idx:integer, handler:property, data:any) : void ->
	let (elem_name, attrs) := query[idx]
	in (for e in self.children
			(if (match_wildcard?(e.tagname, elem_name) & match_attributes?(e, attrs))
				(if (idx < length(query)) xpath_query_internal(e, query, idx + 1, handler,data)
				else apply(handler, list(data, e)))))]

[match_attributes?(self:(XMLDoc U XMLNode), attrs:list[tuple(string,string)]) : boolean ->
	forall(att in attrs |
			exists(a in self.attr |
				match_wildcard?(a.attrname, att[1]) &
				match_wildcard?(a.text, att[2])))]


list_handler(data:list[XMLNode], e:XMLNode) : void -> (data add e)


//<sb> process an xpath query. self is the root node from which the query
// is performed,xpath is the wildcard path of the query, handler is a property to
// be called once a matching element is called as follow :
//  	handler(data, matched_element)
// an appropriate restriction should exists.
// here are sample xpaths :
// 		"company/employee[name='sb']"
// 		"company/*"
[xpath_query(self:(XMLDoc U XMLNode), xpath:string, handler:property, data:any) : void ->
	let p := port!(xpath),
		query := list<any>()
	in (fill_xpath_query(p, query),
		fclose(p),
		xpath_query_internal(self, query, 1, handler, data))]


//<sb> process an xpath query and returns matching elements.
[xpath_query(self:(XMLDoc U XMLNode), xpath:string) : list[XMLNode] ->
	let l := list<XMLNode>()
	in (xpath_query(self, xpath, list_handler, l),
		l)]

