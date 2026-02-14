//*********************************************************************
//* WclSite                                        Xavier Pechoultres *
//* form.cl                                                           *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*	$Date: 2010-10-26 09:46:10 +0200 (Mar 26 oct 2010) $
//*	$Revision: 2064 $
//*********************************************************************

// *********************************************************************
// *  Table of contents                                                *
// *   Part 1: standard html combobox printing                         *
// *   Part 2: javascript utils                                        *
// *   Part 3: automatic form parsing                                  *
// *********************************************************************


// *********************************************************************
// *   Part 1: standard html combobox printing                         *
// *********************************************************************


[htmlFormSelect(inputName:string,l:list[object],selected:any) : void 
-> printf("<select name=~S>", inputName),
	for o in l
	(when i := Dbo/getDbId(o) in
		printf("<option value='~S' ~A >~A</option>\n",i,
					(if (i = selected | o = selected) "selected" else "") ,
					getInfo(o))),
	princ("</select>")]

[htmlFormSelectUnknown(inputName:string,l:list,selected:any) : void 
->	printf("<select name=~S>", inputName),
	printf("<option value=''>~A</option>",translate("indéfini")),
	for o in l
	(when i := Dbo/getDbId(o) in
		printf("<option value='~S' ~A >~A</option>\n",
					i,
					(if (i = selected | o = selected) "selected" else "") ,
					getInfo(o))),
	princ("</select>")]

[htmlFormSelect(inputName:string,l:subtype[string],selected:(string U {unknown})) : void 
-> printf("<select name=~S>", inputName),
	for o in l
	(printf("<option value=\"~A\" ~A >~A</option>\n",o,
					(if (o = selected) "selected" else "") ,
					o)),
	princ("</select>")]
	

[formButtonUncheckAll(self:string) : void 
-> printf("<button onclick='javascript: for(i=0;i < form.elements.length;i++) { form.elements[i].checked = false;} '>~A</button>",
			self)]


[formCheckBoxRadio(self:object,p:property)
-> 	printf("~A<input type=radio name=~S value=1 ~A>&nbsp;~A<input name=~S type=radio value=0 ~A>",
			translate("oui"),
			string!(name(p)),
			(if (get(p,self) & known?(p,self)) "Checked" else ""),
			translate("non"),
			string!(name(p)),
			(if (get(p,self) & known?(p,self)) "" else "Checked"))]

// *********************************************************************
// *   Part 3: automatic form parsing                                  *
// *********************************************************************

htmlformData! :: property()
(abstract(htmlformData!))

[htmlformData!(p:property,formData:table) : any
-> unknown]

[htmlBoolean!(s:string) : boolean
-> not(s % list("0","false","-1"))]


[claire/htmlfloat!(s:string) : float -> s := replace(s," ",""), s := replace(s,",","."), float!(s)]
[claire/htmlfloat!(s:integer) : float -> float!(s)]
[claire/htmlfloat!(s:float) : float -> s]

[round!(f:float) : integer -> externC("round(f)",integer)]

[claire/htmlinteger!(s:float) : integer -> round!(s)]
[claire/htmlinteger!(s:string) : integer -> s := replace(s," ",""), integer!(s)]
[claire/htmlinteger!(s:integer) : integer -> s]

// Parse form date to object information

[xssFilter(src:string,prop:Dbo/dbProperty) : string
->	if not(prop.Dbo/xssFilter) src
	else (
		let result := "" in (externC("
		char *res = (char*)malloc(LENGTH_STRING(src)*6 + 1);
	if(res == 0) Cerror(61, _string_(\"escape @ string\"),0);
	char *travel = res;
	while(*src) {
		int c = integer_I_char(_char_(*src));
		if(c < 0) c = 256 + c;
		if(c > 256) c -= 256;
		
		if(c >= 32 && c <= 64) {
			switch(c) {
				case '=': strcpy(travel,\":\"); travel += 1; break;
				case '\"': strcpy(travel,\"&quot;\"); travel += 6; break;
				case '\\'': strcpy(travel,\"&#39;\"); travel += 5; break;
				case '<': strcpy(travel,\"&lt;\"); travel += 4; break;
				case '>': strcpy(travel,\"&gt;\"); travel += 4; break;
				case '&': strcpy(travel,\"&amp;\"); travel += 5; break;
				default: *travel++ = c;
			}
		} else *travel++ = c;
		src++;
	}
	*travel = 0;
	travel = copy_string1(res, travel - res);
	free(res);
	
	result = travel;
	"),
	result))]



[formValue(self:property,formData:table) : (integer U float U string U boolean) ->
	formData[string!(self.name)]]

(open(formValue) := 3)


[htmlFormParse(self:object,formData:table) : object
->	for s in { @(p,owner(self)) | p  in Dbo/dbPropertiesButId(self) }
		(   //[2] parseForm(~S) : slot ~S   range : ~S   value = ~S // self,s,range(s),formData[string!(s.selector.name)],
			case (s.range)
			(	{ string  }
					(if (formData[string!(s.selector.name)] % string)
						write(s.selector,self,xssFilter(formValue(s.selector,formData),s.selector))),
				{  integer  }
					(if (formData[string!(s.selector.name)])
						write(s.selector,self,htmlinteger!(formValue(s.selector,formData)))),
				{  float }
					(if (formData[string!(s.selector.name)]) (
						if (known?(Dbo/dbSqlType,s.selector) & s.selector.Dbo/dbSqlType % Db/SQL_DATE_TYPE)
							case s.selector.Dbo/dbSqlType (
								{Db/SQL_DATE}
									write(s.selector,self,make_date(formData[string!(s.selector.name)])),
								{Db/SQL_TIME} 
									write(s.selector,self,make_time(formData[string!(s.selector.name)])),
								any
									write(s.selector,self, htmlfloat!(formValue(s.selector,formData))))
						else
							write(s.selector,self,htmlfloat!(formValue(s.selector,formData))))),
				{  boolean }
					(if (formData[string!(s.selector.name)])
						write(s.selector,self,htmlBoolean!(formData[string!(s.selector.name)]))),
				any
					(if (formData[string!(s.selector.name)])
						when i := htmlformData!(s.selector,formData)
						in	write(s.selector,self,i)
						else erase(s.selector,self) )
				),
			none),
	self]

