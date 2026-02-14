Harbor
======

Overview
--------
Harbor provides a lightweight framework to build API-first services. The
module routes HTTP requests to a single entry point that you override in
your application.

Usage
-----
To handle REST APIs, define (or override) the `Harbor/api` function. The
framework calls it for every incoming request.

Signature
---------
`Harbor/api(request, method, path elments, ...)`

Parameters
----------
- `request`: the HTTP request object.
- `method`: the HTTP method as a string (for example, "GET").
- `path`: the request path (for example, for "/v1/items/" : "v1", "items").

Example
-------
```
// handle GET /v1/items
[Harbor/api(request:Http/request, method:{"get"},v:{"v1"},cmd:{"items})
-> printf("OK")]
```
```
// handle any http method with path /health
[Harbor/api(request:Http/request, method:string,v:{"health"})
-> printf("I'm alive")]
```

```
// handle GET with path /item/[any value]
[Harbor/api(request:Http/request, method:{"get"},dom:{"item"},uid:string)
-> printf("try to load item with id ~S ", uid)]
```

```
// handle POST with path /item/[any value]
[Harbor/api(request:Http/request, method:{"post"},dom:{"item"},uid:string)
-> printf("try to update ? item with id ~S ", uid)]
```

Notes
-----
- Keep `Harbor/api` focused on routing and validation.
- Delegate business logic to dedicated modules.
