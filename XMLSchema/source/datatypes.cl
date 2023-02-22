

schema_object <: ephemeral_object()


complexType <: schema_object()
simpleType <: schema_object(isknown?:boolean = false)

[simple_known?(self:simpleType) : boolean -> self.isknown?]


[close(self:complexType) : complexType
->	for i in slots(owner(self))
		(if (range(i) <= simpleType)
			(if unknown?(selector(i),self)
				(write(selector(i),self,new(range(i)))))),
	self]


schema <: complexType(
		url:string,
		base_namespace:module,
		elementFormDefaultQualified?:boolean = true,
		attributeFormDefaultQualified?:boolean = false,
		private/tab_deep:integer = 0)
//		root:complexType)

// 3.2.1 string
xsl_string <: simpleType(val:string = "")


[get_enumeration(self:xsl_string) : type -> string]
(abstract(get_enumeration))

[cdata!(self:xsl_string,cdata:string) : void
->	if (cdata % get_enumeration(self)) (self.isknown? := true, self.val := cdata)
	else error("~S does not belong to ~S",cdata,get_enumeration(self))]

[self_xml_cdata(self:xsl_string) : void -> princ(self.val)]

// [simple_known?(self:xsl_string) : boolean -> known?(val,self)]

[read(x:xsl_string) : string
->	x.val]

[write(x:xsl_string,v:string) : void
->	x.isknown? := true,
	if (v % get_enumeration(x))  x.val := v
	else error("~S does not belong to ~S",v,get_enumeration(x))]

// [refied?(simpleType)
[reified?(self:subtype[simpleType]) : boolean -> true]

// 3.2.2 boolean
xsl_boolean <: simpleType(val:boolean = true)

[cdata!(self:xsl_boolean,cdata:string) : void
->	self.isknown? := true,
	self.val := (cdata = "1" | lower(cdata) = "true")]

[self_xml_cdata(self:xsl_boolean) : void
-> if (known?(val,self) & self.val) princ("true") else princ("false")]

// [simple_known?(self:xsl_boolean) : boolean -> known?(val,self)]

[read(x:xsl_boolean) : boolean
->	x.val]

[write(x:xsl_boolean,v:boolean) : void
->	x.isknown? := true,
	x.val := v]


// 3.2.3 decimal
xsl_decimal <: simpleType(val:float)

[cdata!(self:xsl_decimal,cdata:string) : void
->	self.isknown? := true,
	self.val := float!(cdata)]

[self_xml_cdata(self:xsl_decimal) : void
-> princ(self.val)]

// [simple_known?(self:xsl_decimal) : boolean -> known?(val,self)]

[read(x:xsl_decimal) : float
->	x.val]

[write(x:xsl_decimal,v:float) : void
->	x.isknown? := true,
	x.val := v]


// 3.2.4 float
xsl_float <: xsl_decimal()

// 3.2.5 double
xsl_double <: xsl_decimal()


// 3.2.6 duration
xsl_duration <: simpleType(positive:boolean,
							years:integer = 0,
							months:integer = 0, 
							days:integer = 0,
							hours:integer = 0,
							minutes:integer = 0,
							seconds:integer = 0)

// [simple_known?(self:xsl_duration) : boolean -> known?(positive,self)]


[cdata!(self:xsl_duration,cdata:string) : void
->	if (cdata != "") (
		self.isknown? := true,
		self.positive := (cdata[1] != '-'),
		let expl := explode(cdata,"T"),
			dat := port!(expl[1]),
			tim := (if (length(expl) = 2) port!(expl[2]) else port!())
		in (while (let res := freadline(dat,{'Y','M','D','P'})
					in (case res[2] (
							{""} false,
							{'P'} (true),
							{'Y'} (self.years := integer!(res[1]), true),
							{'D'} (self.days := integer!(res[1]), true),
							{'M'} (self.months := integer!(res[1]), true)))) none,
			while (let res := freadline(tim,{'H','M','S'})
					in (case res[2] (
							{""} false,
							{'H'} (self.hours := integer!(res[1]), true),
							{'M'} (self.minutes := integer!(res[1]), true),
							{'S'} (self.seconds := integer!(res[1]), true)))) none))]

[self_xml_cdata(self:xsl_duration) : void
->	if (self.years > 0 | self.months > 0 | self.days > 0 | self.hours > 0 | self.minutes > 0 | self.seconds > 0) (
		if (not(self.positive)) princ("-P") else princ("P"),
		if (self.years > 0) printf("~AY",self.years),
		if (self.months > 0) printf("~AM",self.months),
		if (self.days > 0) printf("~AD",self.days),
		if (self.hours > 0 | self.minutes > 0 | self.seconds > 0) princ("T"),
		if (self.hours > 0) printf("~AH",self.hours),
		if (self.minutes > 0) printf("~AM",self.minutes),
		if (self.seconds > 0) printf("~AS",self.seconds))]

// 3.2.7 dateTime
xsl_dateTime <: simpleType(val:float)

[cdata!(self:xsl_dateTime,cdata:string) : void
->	self.isknown? := true,
	self.val := make_date(cdata)]

[self_xml_cdata(self:xsl_dateTime) : void
-> princ(strftime("%Y-%m-%dT%H:%M:%S",self.val))]

// [simple_known?(self:xsl_dateTime) : boolean -> known?(val,self)]

[read(x:xsl_dateTime) : float
->	x.val]

[write(x:xsl_dateTime,v:float) : void
->	x.isknown? := true,
	x.val := v]


// 3.2.8 time
xsl_time <: simpleType(val:float)

[cdata!(self:xsl_time,cdata:string) : void
->	self.isknown? := true,
	self.val := make_time(cdata)]

[self_xml_cdata(self:xsl_time) : void
-> princ(strftime("%H:%M:%S",self.val))]

// [simple_known?(self:xsl_time) : boolean -> known?(val,self)]

[read(x:xsl_time) : float
->	x.val]

[write(x:xsl_time,v:float) : void
->	x.isknown? := true,
	x.val := v]

// 3.2.9 date
xsl_date <: simpleType(val:float)

[cdata!(self:xsl_date,cdata:string) : void
->	self.isknown? := true,
	self.val := make_date(cdata)]

[self_xml_cdata(self:xsl_date) : void
-> princ(strftime("%Y-%m-%d",self.val))]

// [simple_known?(self:xsl_date) : boolean -> known?(val,self)]

[read(x:xsl_date) : float
->	x.val]

[write(x:xsl_date,v:float) : void
->	x.isknown? := true,
	x.val := v]

// 3.2.10 gYearMonth

xsl_gYearMonth <: simpleType(val:float)

[cdata!(self:xsl_gYearMonth,cdata:string) : void
-> 	self.isknown? := true,
	let r := explode(cdata,"-")
	in (self.val := make_date(1,integer!(r[2]),integer!(r[1]),0,0,0))]

[self_xml_cdata(self:xsl_gYearMonth) : void
-> princ(strftime("%Y-%m",self.val))]

// [simple_known?(self:xsl_gYearMonth) : boolean -> known?(val,self)]

[read(x:xsl_gYearMonth) : float
->	x.val]

[write(x:xsl_gYearMonth,v:float) : void
->	x.isknown? := true,
	x.val := v]


// 3.2.11 gYear
xsl_gYear <: simpleType(val:float)

[cdata!(self:xsl_gYear,cdata:string) : void ->
	self.isknown? := true,
	self.val := make_date(1,1,integer!(cdata),0,0,0)]

[self_xml_cdata(self:xsl_gYear) : void
-> princ(strftime("%Y",self.val))]

// [simple_known?(self:xsl_gYear) : boolean -> known?(val,self)]

[read(x:xsl_gYear) : float
->	x.val]

[write(x:xsl_gYear,v:float) : void
->	x.isknown? := true,
	x.val := v]


// 3.2.12 gMonthDay
xsl_gMonthDay <: simpleType(month:(1 .. 12) = 1,
							day:(1 .. 31) = 1)

[cdata!(self:xsl_gMonthDay,cdata:string) : void
-> 	self.isknown? := true,
	let r := explode(cdata,"-")
	in (self.month := integer!(r[2]),
		self.day := integer!(r[1]))]
		
[self_xml_cdata(self:xsl_gMonthDay) : void
-> printf("~S-~S",self.day,self.month )]

// [simple_known?(self:xsl_gMonthDay) : boolean -> known?(val,self)]

// 3.2.13 gDay
xsl_gDay <: simpleType(val:(1 .. 31) = 1)

[cdata!(self:xsl_gDay,cdata:string) : void
->	self.isknown? := true,
	self.val := integer!(cdata)]

[self_xml_cdata(self:xsl_gDay) : void
-> if known?(val,self) princ(self.val)]

// [simple_known?(self:xsl_gDay) : boolean -> known?(val,self)]


// 3.2.14 gMonth
xsl_gMonth <: simpleType(val:(1 .. 12) = 1)

[cdata!(self:xsl_gMonth,cdata:string) : void
->	self.isknown? := true,
	self.val := integer!(cdata)]

[self_xml_cdata(self:xsl_gMonth) : void
-> if known?(val,self) princ(self.val)]

// [simple_known?(self:xsl_gMonth) : boolean -> known?(val,self)]

// 3.2.15 hexBinar
xsl_hexBinary <: simpleType(val:port = stdout)

[cdata!(self:xsl_hexBinary,cdata:string) : void
->	self.isknown? := true,
	self.val := port!(cdata)]

[self_xml_cdata(self:xsl_hexBinary) : void
-> error("printing hexBinary is unsupported : ~S", self)]
// [simple_known?(self:xsl_hexBinary) : boolean -> known?(val,self)]

[read(x:xsl_hexBinary) : port
->	x.val]

[write(x:xsl_hexBinary,v:port) : void
->	x.isknown? := true,
	x.val := v]


// 3.2.16 base64Binary
xsl_base64Binary <: simpleType(val:string = "")

[cdata!(self:xsl_base64Binary,cdata:string) : void
->	self.isknown? := true,
	self.val := Http/decode64(cdata)]

[self_xml_cdata(self:xsl_base64Binary) : void
->	princ(encode64(self.val))]

// [simple_known?(self:xsl_base64Binary) : boolean -> known?(val,self)]

[read(x:xsl_base64Binary) : string
->	x.val]

[write(x:xsl_base64Binary,v:string) : void
->	x.isknown? := true,
	x.val := v]

// 3.2.17 anyURI
xsl_anyURI <: xsl_string()
/*
xsl_anyURI <: simpleType(val:string)

[cdata!(self:xsl_anyURI,cdata:string) : void
->	self.val := url_decode(cdata)]

[self_xml_cdata(self:xsl_anyURI) : void
->	princ(url_encode(self.val))]
*/
// 3.2.18 QName
xsl_QName <: xsl_string()

// 3.2.19 NOTATION
xsl_NOTATION <: xsl_QName()


// 3.3.1 normalizedString
xsl_normalizedString <: xsl_string()

// 3.3.2 token
xsl_token <: xsl_normalizedString()

// 3.3.3 language
xsl_language <: xsl_token()

// 3.3.4 NMTOKEN
xsl_NMTOKEN <: xsl_token()

// 3.3.5 NMTOKENS
xsl_NMTOKENS <: simpleType(val:list[string])

[cdata!(self:xsl_NMTOKENS,cdata:string) : void
->	self.isknown? := true,
	self.val := explode(cdata," ")]

[self_xml_cdata(self:xsl_NMTOKENS) : void
->	for i in self.val printf("~A ",i)]

// [simple_known?(self:xsl_NMTOKENS) : boolean -> known?(val,self)]

[read(x:xsl_NMTOKENS) : list[string]
->	x.val]

[write(x:xsl_NMTOKENS,v:list[string]) : void
->	x.isknown? := true,
	x.val := v]


// 3.3.6 Name
xsl_Name <: xsl_token()

// 3.3.7 NCName
xsl_NCName <: xsl_Name()

// 3.3.8 ID
xsl_ID <: xsl_NCName()

// 3.3.9 IDREF
xsl_IDREF <: xsl_NCName()

// 3.3.10 IDREFS
xsl_IDREFS <: simpleType(val:list[string])

[cdata!(self:xsl_IDREFS,cdata:string) : void
->	self.isknown? := true,
	self.val := explode(cdata," ")]

[self_xml_cdata(self:xsl_IDREFS) : void
->	for i in self.val printf("~A ",i)]

[read(x:xsl_IDREFS) : list[string]
->	x.val]

[write(x:xsl_IDREFS,v:list[string]) : void
->	x.isknown? := true,
	x.val := v]


// 3.3.11 ENTITY
xsl_ENTITY <: xsl_NCName()


// 3.3.12 ENTITIES
xsl_ENTITIES <: simpleType(val:list[string])

[cdata!(self:xsl_ENTITIES,cdata:string) : void
->	self.isknown? := true,
	self.val := explode(cdata," ")]

[self_xml_cdata(self:xsl_ENTITIES) : void
->	for i in self.val printf("~A ",i)]

// [simple_known?(self:xsl_ENTITIES) : boolean -> known?(val,self)]


[read(x:xsl_ENTITIES) : list[string]
->	x.val]

[write(x:xsl_ENTITIES,v:list[string]) : void
->	x.isknown? := true,
	x.val := v]

// 3.3.13 integer
xsl_integer <: simpleType(val:integer = 0)

[cdata!(self:xsl_integer,cdata:string) : void
->	self.isknown? := true,
	self.val := integer!(cdata)]

[self_xml_cdata(self:xsl_integer) : void
->	princ(self.val)]

// [simple_known?(self:xsl_integer) : boolean -> known?(val,self)]

[read(x:xsl_integer) : integer
->	x.val]

[write(x:xsl_integer,v:integer) : void
->	x.isknown? := true,
	x.val := v]

// 3.3.14 nonPositiveInteger
xsl_nonPositiveInteger <: xsl_integer()

[cdata!(self:xsl_nonPositiveInteger,cdata:string) : void
->	let i :=  integer!(cdata)
	in (if (i >= 0) (
			//[0] Warning ~S does not match  ~S // i, owner(self),
			self.val := 0)
		else (self.isknown? := true, self.val := i))]

// 3.3.15 negativeInteger
xsl_negativeInteger <: xsl_nonPositiveInteger()

// 3.3.16 long
xsl_long <: xsl_integer()

// 3.3.17 int
xsl_int <: xsl_long()

// 3.3.18 short
xsl_short <: xsl_int()

// 3.3.19 short
xsl_byte <: xsl_short()


// 3.3.20 nonNegativeInteger

xsl_nonNegativeInteger <: xsl_integer()

[cdata!(self:xsl_nonNegativeInteger,cdata:string) : void
->	let i :=  integer!(cdata)
	in (if (i <= 0) (
			//[0] Warning ~S does not match  ~S // i, owner(self),
			self.val := 0)
		else (self.isknown? := true, self.val := i))]

// 3.3.21 unsignedLong
xsl_unsignedLong <: xsl_nonNegativeInteger()

// 3.3.22 unsignedInt
xsl_unsignedInt <: xsl_unsignedLong()

// 3.3.23 unsignedShort
xsl_unsignedShort <: xsl_unsignedInt()

// 3.3.24 unsignedByte
xsl_unsignedByte <: xsl_unsignedShort()


// 3.3.25 positiveInteger

xsl_positiveInteger <: xsl_nonNegativeInteger()

