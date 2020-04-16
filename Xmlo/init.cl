
// init file for module Xmlo
// created Wed Jul  2 15:45:12 2003 by claire v3.3.23


(use_module("Sax"))
(use_module("Iconv"))

Xmlo :: module(
	uses = list(Sax,Iconv),
	made_of = list("xmlize","readxml","printxml","schema"),
	source = "source",
	version = "v0.0.0") // put your version here


(load(Xmlo))
