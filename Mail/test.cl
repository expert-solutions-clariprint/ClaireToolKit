

(load(Mail), begin(Mail))

(verbose() := 2)
E:any := none

[test(self:string) : void
->	let f_in := fopen(self /+ ".eml","r"),
		f_out := fopen(self /+ "_out.eml","wb"),
		e := read_email(f_in)
	in (E := e,
		//[0] ************** ECRITURE,
		fclose(f_in),
		write(e,f_out),
		fclose(f_out))]

//(test("email_simple"))  // OK  petit probleme de \n en fin au niveau lecture puis ecriture 
//(test("email_avec_altenative")) // OK :)
//(test("email_simple_avec_une_image")) // OK :)
// (test("email_alternative_et_2_images")) // OK !!

[test2() : void
->	let self := email(),
		from := "x.pechoultres@expert-solutions.fr",
		to := "x.pechoultres@expert-solutions.fr",
		f := fopen("test2.eml","w")
	in (set_header(self,"from",from),
		set_header(self,"to",to),
		set_header(self,"subject","essai simple"),
		print_in_body(self,"text/ascii"),
		printf("test simple 10 lignes :\n"),
		for i in (1 .. 10) printf("~A\n",i),
		end_of_body(self),
		write(self,f),
		fclose(f))]

[test_smtp1() : void
->	let self := email(),
		from := "x.pechoultres@expert-solutions.fr",
		to := "x.pechoultres@claire-language.com",
		serv_h := "mailhost.galilee.fr",
		serv := smtp_connect(serv_h,from,"expert-solutions.fr")
//		f := fopen("test2.eml","w")
	in (set_header(self,"from",from),
		set_header(self,"to",to),
		set_header(self,"subject","essai simple"),
		print_in_body(self,"text/ascii"),
		printf("test simple 10 lignes :\n"),
		for i in (1 .. 10) printf("~A\n",i),
		end_of_body(self),
		smtp_send(serv,list(to),self),
		smtp_disconnect(serv))]
		
MESSAGES:any := false
[test_pop1() : void
->	let ps := pop_connect("mailhost.galilee.fr",
						"x.pechoultres%claire-language.com",
						"gcpq5289"),
		stats := pop_stat(ps),
		msgs := pop_messages(ps)
	in (printf("stat : ~A - ~A\n", stats[1],stats[2]),
		MESSAGES := msgs,
		mwrite(msgs,"./output"),
//		for i in msgs pop_delete_message(ps,i),
		pop_disconnect(ps))]
		
