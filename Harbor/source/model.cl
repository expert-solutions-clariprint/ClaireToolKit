
HTTP_METHODS :: {"get","post","put","delete","patch","copy","head"}  // supported HTTP methods

// @doc API
// Base REST API handler
[api(req:Http/http_handler, http_method:string) : void
->  echo("Register API method " /+ http_method /+ " for path " /+ req.Http/http_url)]


// @doc API
// Base REST API handler
[api(req:Http/http_handler, http_method:string, path:string) : void
->  echo("Register API method " /+ http_method /+ " for path " /+ req.Http/http_url)]

(open(api) := 3)

// @doc API
// TEST REST API handler
// called by doing au HTTP request to /test/myapi
[api(req:Http/http_handler, http_method:string, path:{"test"}, api:string) : void
->  printf("call ~S on test API ~S ",http_method, api)]

// @doc API
// The well known ping pong API
[api(req:Http/http_handler, http_method:string, path:{"ping"}) : void
-> echo("pong")]

// @doc API
// The well known ping pong API
[api(req:Http/http_handler, http_method:{"post"}, path:{"ping"}) : void
-> echo("pong post")]
