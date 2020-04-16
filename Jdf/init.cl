
// init file for module Dom
// created 10/15/03 12:33:24 by claire v3.3.29

(use_module("Dom3"))
(use_module("Wcl"))


Jdf :: module(
	part_of = Dom3,
	uses = list(Dom3,Wcl),
	made_of = list("model.cl", "jmf.cl","jdf.cl"),
	source = "source",
	version = "v0.0.1") // put your version here


(load(Jdf))
