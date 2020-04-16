

[setup_jdf_doc() : Dom3/Document
->	//[TAPI] setup_jdf_doc(),
	let doc := Dom3/Document()
//		jmf := Dom3/createElement(doc,"JMF")
	in (doc.Dom3/mime := "application/vnd.cip4-jdf+xml",
/*		Dom3/appendChild(doc,jmf),
		Dom3/setAttribute(jmf,"xmlns","http://www.CIP4.org/JDFSchema_1_1"),
		Dom3/setAttribute(jmf,"SenderID","CLAIRE Jdf module version " /+ Jdf.version),
		Dom3/setAttribute(jmf,"TimeStamp",Dom3/timestamp!()),
		Dom3/setAttribute(jmf,"MaxVersion","1.3"),
		Dom3/setAttribute(jmf,"Version","1.3"),
		Dom3/setAttribute(jmf,"xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance"), */
		doc)]
