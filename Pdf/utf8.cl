(begin(Pdf))

TEST1 :: "<b>latin</b>"
TEST2 :: "<p border=\"1\">UTF8 éàç`` (</p>"

(let d := document!("A4", false)
in (d.deflate? := false,
	print_in_html(d),
	princ("<b>latin</b>"),
	princ("<p>UTF8 éàç``</p>"),
	end_of_html(d),
	print_in_file(d, "utf8.pdf")))
	
(let d := document!("A4", false)
in (set_utf8(),
	d.deflate? := false,
	print_in_html(d),
	princ("<b>latin</b>"),
	princ("<p>UTF8 éàç`` (</p>"),
	end_of_html(d),
	print_in_file(d, "utf8_.pdf")))
