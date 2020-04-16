
// init file for module Dbo
// created Thu May 29 09:47:00 2003 by claire v3.3.19

(use_module("Db"))
(use_module("Xmlo"))
(use_module("Zlib"))

Dbo :: module(
	version = "v1.0.0",
	part_of = Db,
	uses = list(Core,Reader,Db,Serialize,Xmlo,Zlib),
	made_of = list("error",
					"model",
					"dbprint",
					"create",
					"delete",
					"dbrelationships",
					"update",
					"load",
					"db_get_erase",
					"dbtables",
					"copy",
					"dbtools"),
	source = "source")


(load(Dbo))
