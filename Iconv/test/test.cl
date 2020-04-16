

(begin(Iconv))

(
//[0] Single char test ISO-8859-1 > UTF-8
)
(let _e_ :=  string!(char!(233)), // e accent aigue
	outb := port!(),
	converted := filter!(converter!("ISO-8859-1","UTF-8"),outb),
	utf8_str := ""
in (
	fwrite(_e_,converted),
	flush(converted),
	let utf8str := string!(outb)
	in (if (length(utf8str) != 2) error("length utf8str must be 2"),
		if (integer!(utf8str[1]) != 195
			| integer!(utf8str[2]) != 169) error("char codes utf8str must be C3 A9"),
		none)))
		
(//[0] OK,
//[0] ==========================================================,
//[0] Single char test ISO-8859-1 > UTF-8
)

(let _e_ :=  string!(char!(195)) /+  string!(char!(169)) , // e accent aigue en UTF8
	outb := port!(),
	converted := filter!(converter!("UTF-8","ISO-8859-1"),outb),
	utf8_str := ""
in (//[0] input:~S// _e_,
	fwrite(_e_,converted),
	flush(converted),
	//[0] TEST: outp[~S]=~S // length(outb),string!(outb),
	
	// check UTF8 
	let latinstr := string!(outb)
	in (if (length(latinstr) != 1) error("length latinstr must be 1"),
		if (integer!(latinstr[1]) != 233) error(" latinstr must be 233"),
		none)))

(
//[0] OK,
//[0] ==========================================================,
//[0] very long simple char char test ISO-8859-1 > UTF-8
)

(let n := 100000,
	_e_ :=  make_string(n,char!(233)),
	outb := port!(),
	converted := filter!(converter!("ISO-8859-1","UTF-8"),outb),
	utf8_str := ""
in (fwrite(_e_,converted),
	flush(converted),
	let utf8str := string!(outb),
		travel := 1
	in (if (length(utf8str) != (n * 2)) error("length utf8str must be double of original"),
		while (travel < (length(utf8str) - 1)) (
			if (integer!(utf8str[travel]) != 195
			| integer!(utf8str[travel + 1]) != 169) error("char codes utf8str must be C3 A9"),
			travel :+ 2),
			
		let latinb := port!(),
			reverser := filter!(converter!("UTF-8","ISO-8859-1"),latinb),
			latinstr := (fwrite(utf8str,reverser), string!(latinb))
		in (if (length(latinstr) != n) error("length latinstr must be same of original"),
			for i in (1 .. n) (if (latinstr[i] != char!(233)) error("badchar")),
			none
			),
		none)))
(
//[0] OK,
//[0] ==========================================================,
//[0] Test writting 1 ISO-8859-1 > UTF-8
)

(let inb := port!(),
	outb := fopen("eacute-utf8.txt","w"),
	converted := filter!(converter!("ISO-8859-1","UTF-8"),outb)
in (fwrite(make_string(1,'¾'),converted),
	fclose(converted),
	printf("fsize : ~S\n",fsize("eacute-utf8.txt"))))

(trace(0,"Test writting 2 UTF-8 > ISO-8859-1"))
(let
	inb := fopen("postscript-utf-8.html","r"),
	outb := fopen("postscript-ISO-8859-1.html","w"),
	converted := filter!(converter!("UTF-8","ISO-8859-1","//IGNORE"),outb)
in (try (freadwrite(inb,converted)) catch 
	any (//[0] == Error : ~S // exception!()
		),
	fclose(inb),
	fclose(converted),
	printf("fsize : ~S",fsize("postscript-ISO-8859-1.html"))))

(
//[0] OK,
//[0] ==========================================================,
//[0] Test writting 3 UTF-8 > UTF-16
)
(let
	inb := fopen("UTF-8-demo.txt","r"),
	outb := fopen("UTF-8-demo-2-UTF16.txt","w"),
	converted := filter!(converter!("UTF-8","UTF-16"),outb)
in (//[0] inb,
	try (freadwrite(inb,converted)) catch 
	any (//[0] == Error : ~S // exception!()
		),
	fclose(converted),
	fclose(inb),
	printf("fsize : ~S",fsize("UTF-8-demo-2-UTF16.txt"))))


(
//[0] OK,
//[0] ==========================================================,
//[0] File ISO-8859-15 > file UTF-8
)

(printf("Test writting 2"))
(let inb := port!(),
	outb := port!(),
	converted := filter!(converter!("ISO-8859-15","UTF-8"),outb),
	in_file := fopen("write_latin.txt","w"),
	out_file := fopen("write_utf8.txt","w")
in (for i in (1 .. 10000)
		(fwrite(string!(char!(i and 255)),converted),
		fwrite(string!(char!(i and 255)),in_file)),
	fclose(in_file),
	freadwrite(outb,out_file),
	fclose(out_file)))


(
//[0] OK,
//[0] TOUT TESTS OK
)

