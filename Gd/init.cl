
// init file for module Gd
// created Thu May 22 09:41:31 2003 by claire v3.3.19

(if (compiler.env = "ntv")
	compiler.libraries :add " gd.lib "
else
	compiler.libraries :add "-L/sw/lib/ -lgd")


Gd :: module(
//	external = "clGd",
	version = "v1.0.0",
	uses = list(Core),
	made_of = list("gd.h","gdfontg.h","gdfontl.h","gdfontmb.h","gdfonts.h","gdfontt.h",
				"model.cl","utils.cl","sink.h","sink.cpp"),
	source = "source",
	version = "v1.0.0")


(load(Gd))

