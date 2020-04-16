

(let e := email!()
in (e["From"] := "bbn@benilan.net",
	e["To"] := "s.benilan@expert-solutions.fr",
	e["Subject"] := uid(),
	print_in_related(e),

		print_in_alternative(e),

			print_in_email(e, "text/plain; charset=ISO-8859-1"),
			?>Alternative au format texte...<? ,
			end_of_part(e),


			print_in_email(e, "text/html; charset=ISO-8859-1"),
			?>Alternative au format HTML avec une image incluse <img src="cid:toto">
			<hr>
			<b>Source du script de test :</b>
			<hr>
			<? ,
				let f := fopen("test.cl","r")
				in ( ?><?== replace(fread(f), "\t", "     ") ?><? ,
					fclose(f)),
			end_of_part(e),

		end_of_part(e),
		
		let a := add_attachment(e, "../wcl.png", "image/png")
		in a["Content-ID"] := "toto",
		
		add_attachment(e, "../planning_xl.pdf", "application/pdf"),

	end_of_part(e),
/*	let f := fopen("test.msg","w"),
		op := use_as_output(f)
	in (print_email(e, false),
		fclose(f))))*/
	send(e, "mailhost.galilee.fr", "s.benilan@expert-solutions.fr")))

