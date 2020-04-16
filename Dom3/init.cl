
// init file for module Dom
// created 10/15/03 12:33:24 by claire v3.3.29

(use_module("Sax"))
(use_module("Iconv"))


Dom3 :: module(
	uses = list(Sax,Iconv),
	made_of = list("xmlcore.cl", "read.cl", "print.cl","datatypes.cl","xpath.cl"),
	source = "source",
	version = "v0.0.1") // put your version here


(load(Dom3))

