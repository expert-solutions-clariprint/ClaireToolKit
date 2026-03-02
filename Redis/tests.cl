
LONG_TEXT :: "popo
dd

p"

(

//[0] connect default server,
connect(),

//[0] test values,
for v in list("a string", 12, 12.4, true, false,"\"quoted\"","line1\nline2","line1\r\nline2","json:3",LONG_TEXT) (
		retain("test_value", v),get("test_value"),

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

//[0] ******* TEST LARGE FILE *******,
let p := port!(),
	max_size := 1024 * 1024, // 1024, // 1MB
	f := fopen("tests/01.json", "r")
in (// retain("TEST_FILE",f),
	for i in (1 .. max_size) putc('x', p),
	//[-100] == write a large file to test the handling of large files in the REDIS server,
	retain("LARGE_FILE",p),

	let n := get("LARGE_FILE")
	in (//[-100] Large file size: ~S // length(n),
		if (length(n) = max_size)
			printf("Large file test passed.\n")
		else
			printf("!!!!!!!!! Large file test failed.\n"),
		none)),




//[0] TEST timeout,
retain("test_keep_me", "hoho", 3),
//[0] data stored : ~S // get("test_keep_me"),
//[0] wait 4s,
sleep(4000),
//[0] data stored : ~S // get("test_keep_me"),

let t := now()
in (
	//[0] lock : ~S // lock!("test_keep_me"),

	//[0] lock2,
	//[0] lock2 ... : ~S  after ~Ams // lock!("test_keep_me"), elapsed(t),
	none),


//[0] disconnect,

// disconnect()
print("ok"))

