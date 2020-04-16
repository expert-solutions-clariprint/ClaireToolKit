

[timestamp!(f:float) : string
->	let ts := strftime("%z",f)
	in (strftime("%FT%T",f) /+ substring(ts,1,3) /+ ":" /+ substring(ts,4,5))]

[timestamp!() : string -> timestamp!(now())]

