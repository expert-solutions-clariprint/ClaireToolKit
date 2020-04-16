
// init file for module Mysql
// created Thu May 22 10:01:04 2003 by claire v3.3.19

(if find(compiler.env,"Darwin")
	compiler.libraries :add "-L/usr/local/pgsql/lib -lpq -lssl -lcrypto"
else compiler.libraries :add "-L/usr/lib/pgsql/ -lpg ")

(use_module("Db/v1.0.0"))

Pgsql :: module(
	version = "v1.0.0",
	part_of = Db,
	uses = list(Db),
	made_of = list("model", "pgsqldriver.cpp", "pgsqldriver.h"),
	source = "source")

(begin(Db))
(load(Pgsql))
(end(Db))
