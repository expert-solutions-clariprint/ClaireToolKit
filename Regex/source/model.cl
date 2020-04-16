
regex_t* <: import()
(c_interface(regex_t*,"regex_t *"))


regular_expression <: freeable_object(preg:regex_t*, pat:string)

regex_error <: exception(re:regular_expression, errcode:integer)

regex_error!(r:regular_expression, rc:integer) : void =>
	regex_error(re = r, errcode = rc)


self_print(self:regex_error) : void ->
	let n := externC("regerror(self->errcode, self->re->preg, NULL, 0)", integer),
		s := make_string(n, ' ')
	in (externC("regerror(self->errcode, self->re->preg, s, n)"),
		printf("**** regex error ~S ~S\n~A", self.errcode, self.re.pat, s))
			

//<sb> return the number of parenthesized subexpressions within the RE
regcomp(re:regular_expression) : void ->
	let rc := externC("regcomp(re->preg, re->pat, REG_EXTENDED)", integer)
	in (if (rc != 0) regex_error!(re, rc))


regular_expression!(self:string) : regular_expression ->
	let reg := externC("new regex_t", regex_t*)
	in (if externC("reg?CFALSE:CTRUE", boolean)
			error("Not enought memory to allocate regex with pattern ~S", self),
		let re := regular_expression(preg = reg, pat = self)
		in (regcomp(re),
			re))

free!(self:regular_expression) : void ->
	(externC("regfree(self->preg)"),
	externC("delete self->preg"))



regexec(re:regular_expression, s:string) : list[string] ->
	(externC("regmatch_t *pmatch = new regmatch_t[1 + re->preg->re_nsub]"),
	if externC("pmatch?CFALSE:CTRUE", boolean)
			error("Not enought memory to allocate match array for regex with pattern ~S", re.pat),
	let rc := externC("regexec(re->preg, s, 1 + re->preg->re_nsub, pmatch, 0)", integer),
		res := list<string>()
	in (if (rc = 0)
			for i in (0 .. externC("re->preg->re_nsub", integer))
				let so := externC("pmatch[i].rm_so", integer),
					eo := externC("pmatch[i].rm_eo", integer)
				in res :add substring(s, so + 1, eo)
		else if (rc != externC("REG_NOMATCH",integer))
			regex_error!(re, rc),
		externC("delete [] pmatch"),
		res))


matches(self:string, against:string) : list[string] ->
	let re := regular_expression!(against)
	in regexec(re, self)


