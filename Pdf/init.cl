
// init file for module Pdf
// created Fri Apr 16 13:53:40 2004 by claire v3.3.33


(use_module("Zlib"))
(use_module("Openssl"))
(use_module("Iconv"))

Pdf :: module(
	uses = list(Serialize, Reader, Openssl, Zlib, Iconv),
	made_of = list("<stdlib.h>",
					"<math.h>",
					"model.cl",
					"tool.cl",
					"font.cl",
					"css.cl",
					"html.cl",
					"png.cl", 
					"reader.cl",
					"writer.cl",
					"api.cl"),
	source = "source",
	version = "v1.0.0")


(load(Pdf))
