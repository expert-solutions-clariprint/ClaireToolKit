
// init file for module Postal
// created Wed Aug 31 20:18:17 2005 by claire v3.3.35

(use_module("Sax"))
(use_module("WclSite"))

Postal :: module(
	uses = list(Core,Sax,WclSite),
	made_of = list("iso_3166.cl",
					"webform.cl",
					"dbupdate.cl",
					"model.cl"),
	source = "source",
	version = "v1.0.0") // put your version here


(load(Postal))


// Here you can customize the C++ compiler.
// You can uncomment and set any of the following option :

// ==== external libraries needed at link time ====
;(compiler.libraries :add "-lsome_lib")

// ==== C++ compiler options ====
;(compiler.options[1] :/+ "-a_cpp_option") // Optimize mode (-O)
;(compiler.options[2] :/+ "-a_cpp_option") // Debug mode (-D)
;(compiler.options[3] :/+ "-a_cpp_option") // Release mode


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

