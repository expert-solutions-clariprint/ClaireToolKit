
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

[private/subNodes(self:Element) : list[Node] -> self.childNodes]
[private/subNodes(self:Document) : list[Node] -> list(self.documentElement)]

[xpath_query_internal(self:(Element U Document), query:list, idx:integer, handler:property, data:any) : void ->
	let (elem_name, attrs) := query[idx]
	in (for e in subNodes(self)
			(if (e % Element)
				(if (match_wildcard?(e.tagName, elem_name) & match_attributes?(e, attrs))
				(if (idx < length(query)) xpath_query_internal(e, query, idx + 1, handler,data)
				else apply(handler, list(data, e))))))]

[match_attributes?(self:Element, attrs:list[tuple(string,string)]) : boolean ->
	forall(att in attrs |
			exists(a in self.attributes |
				match_wildcard?(a.name, att[1]) &
				match_wildcard?(a.value, att[2])))]


list_handler(data:list[Element], e:Element) : void -> (data add e)


//<sb> process an xpath query. self is the root node from which the query
// is performed,xpath is the wildcard path of the query, handler is a property to
// be called once a matching element is called as follow :
//  	handler(data, matched_element)
// an appropriate restriction should exists.
// here are sample xpaths :
// 		"company/employee[name='sb']"
// 		"company/*"
[xpath_query(self:(Element U Document), xpath:string, handler:property, data:any) : void ->
	let p := port!(xpath),
		query := list<any>()
	in (fill_xpath_query(p, query),
		fclose(p),
		xpath_query_internal(self, query, 1, handler, data))]


//<sb> process an xpath query and returns matching elements.
[xpath_query(self:(Element U Document), xpath:string) : list[Element] ->
	let l := list<Element>()
	in (xpath_query(self, xpath, list_handler, l),
		l)]

