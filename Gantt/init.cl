
// init file for module Gantt
// created Tue Jul  1 10:51:54 2003 by claire v3.3.23

(use_module("Gd/v1.0.0"))

Gantt :: module(
	uses = list(Reader,Gd),
	made_of = list("model.cl","draw.cl","exemple.cl"),
	source = "source",
	version = "v0.0.0") // put your version here


(load(Gantt))
