/*
Pier -f tests/load.cl  -serve -q
*/
uuid :: Dbo/dbProperty(Dbo/id? = true)
counter :: Dbo/dbProperty()
content :: Dbo/dbProperty()

DummyClass <: ephemeral_object(
    uuid:integer,
    counter:integer,
    content:string
)

[Dbo/dbStore?(self:{DummyClass}) : boolean -> true]

(set_db(Db/connect!("Mysql:localhost:pierdb:root:root")),
    if not(Dbo/check_table_exists(DB,DummyClass))
        Dbo/dbCreateTable(DB, DummyClass,false))

