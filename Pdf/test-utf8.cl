


(begin(Pdf))

(let doc := Pdf/document!("A4", false)
in (doc.deflate? := false,
//	Pdf/new_page(doc),
	Pdf/print_in_html(doc),
//	printf("chaîne en utf8, é à ô"),
	printf("ô $ @ è à ö ñ ü ß ç"),
	Pdf/end_of_html(doc),
/*	Pdf/new_page(doc),

	Pdf/print_in_html(doc),
	printf("chaine sans utf8, e a o"),
	Pdf/end_of_html(doc), */
	Pdf/print_in_file(doc, "test-utf8.pdf")))

/*
(let doc := Pdf/document!("A4", false)
in (doc.deflate? := false,
	Pdf/print_in_html(doc),
	printf("chaine en utf8, e a o"),
	Pdf/end_of_html(doc),
	Pdf/print_in_file(doc, "test-flat.pdf")))
*/