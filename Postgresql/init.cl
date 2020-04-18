
// init file for module Postgresql
// created Thu Mar 31 15:19:29 2005 by claire v3.3.35

(use_module("Db"))


Postgresql :: module(
	uses = list(Db),
	part_of = Db,
	made_of = list("model.cl", "<libpq-fe.h>", "pgdriver.h", "pgdriver.cpp"),
	source = "source",
	version = "v1.0.0") // put your version here


(begin(Db))
(load(Postgresql))
(end(Db))

// Here you can customize the C++ compiler.
// You can uncomment and set any of the following option :

// ==== external libraries needed at link time ====
(if (compiler.env = "ntv")
	compiler.libraries :add "c:\\mysql\\lib\\opt\\libmySQL.lib  c:\\mysql\\lib\\opt\\zlib.lib"
else if (find(compiler.env,"Darwin") > 0)
	compiler.libraries :add "-L/usr/local/pgsql/lib/ -lpq"
else compiler.libraries :add " -lpq")

// ==== C++ compiler options ====
(compiler.options[1] :/+ " -I/usr/local/pgsql/include ") // Optimize mode (-O)
(compiler.options[2] :/+ " -I/usr/local/pgsql/include ") // Debug mode (-D)
(compiler.options[3] :/+ " -I/usr/local/pgsql/include ") // Release mode


// Here you can customize the CLAIRE compiler.
// You can uncomment and set any of the following option :

// ==== compiler safety ====
// 0 -> super safe
// 1 -> safe
// 2 -> trust explicit types & super
// 3 -> no overflow checking
// 4 -> assumes no selector or range error
// 5 -> assume no type errors of any kind
;(compiler.safety := 1)

// ==== compiler naming convention ====
// 0 -> long & explicit names
// 1 -> shorter names
// 2 -> protected names
;(compiler.naming := 0)

// ==== compiler inline flag ====
// set it to true if you want to include inline definitions in the generated library
;(compiler.inline? := false)

// ==== compiler overflow flag ====
// set it to true to produce safe code with respect to owerflow
;(compiler.overflow? := false)

// ==== fast dispatch flag ====
;(FCALLSTINKS := false)


// Here you can customize the CLAIRE code generator.
// Some symbol may be reserved in the target language,
// for such symbol you have to define a translation :

;(Generate/C++PRODUCER.Generate/bad_names :add some_symbol)
;(Generate/C++PRODUCER.Generate/good_names :add symbol!("some_symbol_translated"))

