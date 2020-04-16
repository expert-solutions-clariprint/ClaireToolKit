
// init file for module Expat
// created Wed Jun 18 16:03:54 2003 by claire v3.3.19

Sax :: module(
	uses = list(Core),
	made_of = list("api.cl"),
	source = "source",
	version = "v1.0.0") // put your version here


(load(Sax))

(Generate/C++PRODUCER.Generate/bad_names :add Sax.name)
(Generate/C++PRODUCER.Generate/good_names :add symbol!("clSax"))
