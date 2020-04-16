
// init file for module Zlib
// created Mon Jan 12 16:20:03 2004 by claire v3.3.33

WIN32_CONTRIB :: (realpath(getenv("_")) /- "" /- "" /- "" /- "contrib")

// ==== external libraries needed at link time ====
(if (compiler.env = "ntv")
	compiler.libraries :add WIN32_CONTRIB / "lib" / "zlibdll.lib"
else
	compiler.libraries :add " -lz ")

// ==== C++ compiler options ====
(if (compiler.env = "ntv")
	(compiler.options[1] :/+ " /I" /+ WIN32_CONTRIB / "zlib", // Optimize mode (-O)
	compiler.options[2] :/+ " /I" /+ WIN32_CONTRIB / "zlib", // Debug mode (-D)
	compiler.options[3] :/+ " /I" /+ WIN32_CONTRIB / "zlib")) // Release mode


Zlib :: module(
	uses = list(Core),
	made_of = list("model.cl", "<zlib.h>"),
	source = "source",
	version = "v1.0.0") // put your version here


(load(Zlib))


(Generate/C++PRODUCER.Generate/bad_names :add Zlib.name)
(Generate/C++PRODUCER.Generate/good_names :add symbol!("clZlib"))

