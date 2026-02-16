// @cat Usage
// Pier is a simple REST API framework for Claire. 
// It expose the classes of your application as REST resources,
// and allows you to perform CRUD operations on them through HTTP requests.
// It must be used in conjunction with the Dbo module, which provides the database access layer for your application.
// To use it, just add to your module and start thr Harbor server. For example:
// `myModule -serve`
//
// @author Xavier Péchoultres <x.pechoultres@expert-solutions.fr>



// @doc Pier
// Database
DB:Db/Database := unknown

/*
    Set the database instance to be used by Dbo module
*/
// @doc Utils
// Set the database instance to be used by Dbo module
[set_db(db:Db/Database) : void
->  DB := db]

/*
tools
*/
// @doc Utils
// Get a module by name, return unknown if not found or if the name does not correspond
[get_module(self:string) : (module U {unknown}) -> when x := get_value(self) in (if (x % module) x as module else unknown) else unknown]

// @doc Utils
// Get a class by name from a module, return unknown if not found or if the name does not correspond
[get_class(module_name:string, self:string) : (class U {unknown}) 
-> when m := get_module(module_name) in (
        when ac := get_value(m,self) 
        in (if (ac % class) ac as class 
            else unknown) 
        else unknown)
    else unknown]


/*
    API registration and handling
*/

// @doc GET
// Return the list of object of the class
[Harbor/api(req:Http/http_handler, http_method:{"get"}, app:{"pier"}, version:string, module_name:string, class_name:string) : void
->  //[1] Pier API method ~S for path ~S // req.Http/http_method, req.Http/http_url,
    when cls := get_class(module_name, class_name)
    in (if (Dbo/dbStore?(cls)) encode(Dbo/dbLoad(DB,cls))
        else printf("Class ~S is not Dbo/Store? ", class_name))
    else printf("Class ~S not found in module ~S ", class_name, module_name)]  



// @doc GET
// return the object identified by obj_id
[Harbor/api(req:Http/http_handler, http_method:{"get"}, app:{"pier"}, version:string, module_name:string, class_name:string, obj_id:string) : void
-> //[1]Pier load object module:~S class:~S id:~S // module_name, class_name, obj_id,
    try (
        when cls := get_class(module_name, class_name)
        in (if (Dbo/dbStore?(cls))
                (when obj := Dbo/dbLoad(DB,cls, obj_id)
                in (encode(obj),
                    //[0] Object found: ~S  class ~S, id ~S // obj, class_name, obj_id,
                    // here you can customize the API response, for example by converting the object to JSON
                    none
                    )
                else printf("Object not found: ~S ", obj_id))
            else printf("Class ~S is not Dbo/Store? ", class_name))
        else printf("Class ~S not found in module ~S ", class_name, module_name))
    catch any (
        printf("Error while handling API request: ~S ",exception!()))]

// @doc GET
// return the object identified by obj_id
[Harbor/api(req:Http/http_handler, http_method:{"delete"}, app:{"pier"}, version:string, module_name:string, class_name:string, obj_id:string) : void
-> //[1]Pier load object module:~S class:~S id:~S // module_name, class_name, obj_id,
    try (
        when cls := get_class(module_name, class_name)
        in (if (Dbo/dbStore?(cls))
                (encode(Dbo/dbDelete(DB,cls,obj_id)))
            else printf("Class ~S is not Dbo/Store? ", class_name))
        else printf("Class ~S not found in module ~S ", class_name, module_name))
    catch any (
        printf("Error while handling API request: ~S ",exception!()))]


// @doc POST
// Create a new object of the given class
// require a JSON body with the object data
[Harbor/api(req:Http/http_handler, http_method:{"post"}, app:{"pier"}, version:string, module_name:string, class_name:string) : void
->  when cls := get_class(module_name, class_name)
    in (let o := new(cls) in (
        Dbo/dbCreate(DB,o),
        encode(o),
        //[0] Creating new object of class ~S: ~S // class_name, o,
        // here you can customize the object initialization with the data from the request body
        // for example by parsing a JSON body and setting the object properties accordingly
        none
    ))
    else printf("Class ~S not found in module ~S ", class_name, module_name)]  

// @doc Utils
// JSON parsing and encoding utilities
[json_integer!(s:integer) : integer -> s]
[json_integer!(s:string) : integer -> integer!(s)]
[json_float!(s:integer) : float -> float!(s)]
[json_float!(s:float) : float -> s]
[json_float!(s:string) : float -> float!(s)]
[json_boolean!(s:integer) : boolean -> not(s = 0)]
[json_boolean!(s:boolean) : boolean -> s]

// @doc Utils
// Extract the keys of a JSON object (represented as a table in Claire)
[json_keys(self:table) : list[string]
-> let i:integer := 1, 
    keys := list<string>()
    in (while (i < length(self.mClaire/graph))
        (if known?(self.mClaire/graph[i]) 
            (keys :add self.mClaire/graph[i]),
        i :+ 2),
    keys)]



// @doc POST
// Update the identified object
// require a JSON body with the object data
[Harbor/api(req:Http/http_handler, http_method:{"post"}, app:{"pier"}, version:string, module_name:string, class_name:string, obj_id:string) : void
-> when json := Json/decode((let p := port!() in (freadwrite(Http/input(req),p),p)))
    in (when cls := get_class(module_name, class_name)
        in (when obj := Dbo/dbLoad(DB,cls, obj_id)
            in ( // here you can customize the object update with the data from the request body
                if (json % table)
                    let keys := json_keys(json) in 
                    (for sl in {sl in cls.slots | sl.selector % Dbo/dbProperty}
                        let selector_name := string!(name(sl.selector))
                        in (//[0] Looking for property ~S in JSON body... // selector_name,
                            if (selector_name % keys)
                                (//[0] Found! Updating property ~S: ~S // selector_name, json[selector_name],
                                // update ... here you can customize the property update, for example by converting the JSON value to the appropriate type
                                case sl.range (
                                    {integer} write(sl.selector, obj, json_integer!(json[selector_name])),
                                    {float} write(sl.selector, obj, json_float!(json[selector_name])),
                                    {string} write(sl.selector, obj, json[selector_name]),
                                    {boolean} write(sl.selector, obj, json_boolean!(json[selector_name])),
                                    any printf("Unsupported property type for ~S, skipping update. \n", selector_name)
                                ),                                
                                none)
                            else //[0] Property ~S not found in JSON body. // selector_name
                            ))
                else printf("Invalid JSON body, not an object\n"),
                Dbo/dbUpdate(DB,obj),
                encode(obj))
            else printf("Object not found: ~S ", obj_id))
        else printf("Class ~S not found in module ~S ", class_name, module_name))
    else printf("Invalid JSON body: ~S ", Http/input(req))]



