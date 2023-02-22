(begin(Pdf))

(time_set())

d :: document!("A4", false)
//(d.htmldebug? := true)

(print_in_css(d) ?>
body[section=toc] {margin-top: 20mm;}
TABLE {border: solid 1pt}
<? end_of_css(d))

do_tests() ->
	(for dir in list{dir in entries("test") | isdir?("test" / dir)}
		(//[0] == Enter ~A == // dir,
		print_in_html(d),
		?><h1><?== dir ?></h1><? ,
		end_of_html(d),
		for f in entries("test" / dir, "*.cl")
			do_test("test" / dir, f)))


CLSEP :: {" ", "\t", "\n", "(", ")", "[", "]", "{", "}", "->", "=>", "?>", "//", "<:", ":", ",", ";"}

html_read(p:port) ->
	let goon? := true
	in (while (goon? & not(eof?(p)))
		(let (data,sep) := freadline(p, {"<?","\n","\t"})
		in ( ?><?== data ?><? ,
			case sep
				({"<?"}
					( ?></font><font color=blue><b>&lt;?</b></font><? ,
					if (fread(p,1) = "=")
						( ?><font color=blue><b>=</b></font><? ,
						if (fread(p,1) = "=")
							( ?><font color=blue><b>=</b></font><? )
						else set_index(p, get_index(p) - 1))
					else set_index(p, get_index(p) - 1),
					goon? := false),
				{"\t"}
					?>&nbsp;&nbsp;&nbsp;&nbsp;<? ,
				{"\n"}
					?><br><? ))))

wcl_read(p:port) ->
	(while not(eof?(p))
		let (data, sep) := freadline(p, CLSEP)
		in (case get_value(data)
				((keyword U reserved_keyword)
					( ?><b><font color=blue><?== data ?></font></b><? ),
				type
					( ?><font color=#4444AA><?== data ?></font><? ),
				property
					( ?><font color=red><?== data ?></font><? ),
				any ?><?== data ?><? ),
			case sep
				({"\t"}
					?>&nbsp;&nbsp;&nbsp;&nbsp;<? ,
				{"//"}
					?><font color=orange>//<?== freadline(p, "\n") ?><br></font><? ,
				{";"}
					?><font color=orange>;<?== freadline(p, "\n") ?><br></font><? ,
				{"?>"}
					( ?><font color=blue><b>?&gt;</b></font><font color=#666666><? , html_read(p)),
				{"\n"}
					?><br><? ,
				any ?><?== sep ?><? )))


do_test(test:string, fp:string) ->
	let f := fopen(test / fp, "r"),
		p := port!()
	in (//[2] do_test(~S,~S) // test , fp ,
		freadwrite(f,p),
		fclose(f),
		//<sb> cutely backed script
		print_in_html(d),
		?><h2><?== replace(replace(fp, "_", " "), ".cl", "") ?></h2>
		<h3>tested script</h3><? ,
		( ?><code><? (wcl_read(p)) ?></code><? ),
		fclose(p),
		end_of_html(d),
		//[0] make test ~A // fp,
		print_in_html(d),
		?><h3>what it does</h3><? ,
		end_of_html(d),
		//<sb> exec test
		load(test / fp))



(set_current_section(d, "body"))


(print_in_html(d),
?>Header <a href="www.clariprint.com">bob</a><? ,
end_of_html_header(d))

(print_in_html(d),
?>Next headers<? ,
end_of_html_header(d))

(print_in_html(d),
?><p>Footer <a href="www.clariprint.com">bob</a> <pagenum>/<pagecount></p><? ,
end_of_html_footer(d))

// (do_tests())

(load("test/text/utf8.cl"))

(new_section_before(d, "toc", "body"),
print_in_html(d),
?><h1>Index</h1><? ,
end_of_html(d),
generate_toc(d, "body", 2))

(print_in_file(d, "test.pdf"))


(time_show())




