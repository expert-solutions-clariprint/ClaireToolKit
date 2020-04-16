
// init file for module Smtp
// created Thu Jun  5 18:25:04 2003 by claire v3.3.19


(use_module("Http"))

Mail :: module(
	version = "v2.0.0",
	uses = list(Http),
	made_of = list("model2.cl"),
	source = "source")

(load(Mail))
