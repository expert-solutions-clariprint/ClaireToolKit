
LONG_TEXT :: "popo
dd

p"

(

//[0] connect default server,
connect(),

//[0] test values,
for v in list("a string", 12, 12.4, true, false,"\"quoted\"","line1\nline2","line1\r\nline2","json:3",LONG_TEXT) (
	//[0] retain(~S) ... ~S  => ~S // v , retain("test_value", v),get("test_value"),

	none),


//[0] CLIENT ID : ~S // query("CLIENT ID"),

//[0] ******* TEST PORT *******,
let 	val := tuple({2,3,4},{"popo","roro",'p',"\"quoted\"", "toto:toto"}),
		p := blob!()
in (serialize(p,val),
	retain("test_port", p),
	let r := blob!(get("test_port")),
		v2 := unserialize(r)
	in (//[0] ... ~S : ~S // val, v2,
		none)),
	
//[0] TEST timeout,
retain("test_keep_me", "hoho", 3),
//[0] data stored : ~S // get("test_keep_me"),
//[0] wait 4s,
sleep(4000),
//[0] data stored : ~S // get("test_keep_me"),


//[0] disconnect,

// disconnect()
print("ok"))

