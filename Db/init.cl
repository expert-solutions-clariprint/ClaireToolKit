
// init file for module Db
// created Thu May 22 09:37:58 2003 by claire v3.3.19



Db :: module(
	version = "v1.0.0",
	uses = list(Core),
	made_of = list("model", "error", "sqldef", "callback", "query",
	                 "database", "dump"),
	source = "source")


(load(Db))
