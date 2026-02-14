

DB:Db/Database := unknown

/*
    Set the database instance to be used by Dbo module
*/
[set_db(db:Db/Database) : void
->  DB := db]

/*
    API registration and handling
*/

// @doc GET
// Return the list of object of the class
[api(req:Http/http_handler, http_method:{"get"}, app:{"pier"}, version:string, module_name:string, class_name:string) : void
-> echo("Register API method " /+ req.Http/http_method /+ " for path " /+ req.Http/http_url)]


// @doc GET
// return the object identified by obj_id
[api(req:Http/http_handler, http_method:{"get"}, app:{"pier"}, version:string, module_name:string, class_name:string, obj_id:string) : void
-> echo("Register API method " /+ req.Http/http_method /+ " for path " /+ req.Http/http_url)]


// @doc POST
// Create a new object of the given class
// require a JSON body with the object data
[api(req:Http/http_handler, http_method:{"post"}, app:{"pier"}, version:string, module_name:string, class_name:string) : void
-> echo("Register API method " /+ req.Http/http_method /+ " for path " /+ req.Http/http_url)]

// @doc POST
// Update the identified object
// require a JSON body with the object data
[api(req:Http/http_handler, http_method:{"post"}, app:{"pier"}, version:string, module_name:string, class_name:string, obj_id:string) : void
-> echo("Register API method " /+ req.Http/http_method /+ " for path " /+ req.Http/http_url)]






