
// init file for module Mysql
// created Thu May 22 10:01:04 2003 by claire v3.3.19

(if (compiler.env = "ntv")
	compiler.libraries :add "c:\\mysql\\lib\\opt\\libmySQL.lib  c:\\mysql\\lib\\opt\\zlib.lib"
else if (find(compiler.env,"Darwin") > 0)
	compiler.libraries :add " -L/opt/local/lib/mysql56/mysql -I/opt/local/include/mysql56 -lmysqlclient -lz"
else compiler.libraries :add "-L/usr/lib/mysql -L/usr/local/mysql/lib/ -lmariadbclient -lpthread -lz -lm -ldl")

(use_module("Db/v1.0.0"))

Mysql :: module(
	version = "v1.0.0",
	part_of = Db,
	uses = list(Db),
	made_of = list("model", (if (sys_name() = "Darwin") "<mysql/mysql.h>" else "<mariadb/mysql.h>")),
	source = "source")

(begin(Db))
(load(Mysql))
(end(Db))
