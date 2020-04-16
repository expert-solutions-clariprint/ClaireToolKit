
// init file for module Dom
// created 10/15/03 12:33:24 by claire v3.3.29

(use_module("Sax"))


Dom :: module(
	uses = list(Sax),
	made_of = list("model.cl", "xpath.cl"),
	source = "source",
	version = "v0.0.0") // put your version here


(load(Dom))
