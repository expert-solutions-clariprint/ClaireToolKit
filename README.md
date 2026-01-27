# ClaireToolKit

**ClaireToolKit** is a collection of reusable **CLAIRE / xlClaire** modules bundled in one public repository.  
Each top-level folder is a standalone Claire module you can build and publish independently, or build all at once via the root build script.

> Note: The descriptions below are **purpose-oriented** summaries based on module names and common usage patterns in the Claire ecosystem. If a module exposes multiple subpackages or has a different scope than its name suggests, prefer the module’s own sources/tests as the reference.

---

## Repository layout

- **One folder = one module**
- Root helper:
  - `build.sh` — build/publish the toolkit in one shot
  - `README.md` — this file
  - `LICENSE` — Apache-2.0

---

## Build everything

```bash
./build.sh
```

---

## Build / publish a single module

Typical pattern:

```bash
cd <ModuleName>
claire -os 3 -cls -publish
```

(Exact flags can vary depending on your Claire toolchain and target platform.)

---

## Modules catalog

### Web / HTTP / Apache integration

- **Http**  
  Low-level HTTP primitives (request/response, CGI-style handling, utilities for web services).

- **Wcl**  
  WebClaire runtime layer: server-side web tooling (sessions, web runtime helpers, debugging hooks, etc.).

- **WclSite**  
  Higher-level “site/application” conventions and helpers built on top of Wcl (project scaffolding patterns, common site glue).

- **WebLocale**  
  Web-oriented localization helpers (language resources, selection, formatting helpers suitable for web contexts).

- **Xmlrpc**  
  XML-RPC client/server utilities.

### Databases

- **Db**  
  Generic DB utilities used as a foundation for connectors and higher-level DB abstractions.

- **Dbo**  
  Higher-level database abstraction (object/relational helpers and patterns to reduce handwritten SQL in application code).

- **Mysql**  
  MySQL/MariaDB connector module.

- **Pgsql**  
  PostgreSQL connector module (variant).

- **Postgresql**  
  PostgreSQL connector module (variant/alternative).

> You have both **Pgsql** and **Postgresql**. That typically means different generations or APIs. Keep the one that matches your runtime and the rest of your codebase.

### Data formats / parsing / XML family

- **Json**  
  JSON parsing/serialization and helpers for structured data interchange.

- **Sax**  
  Streaming XML parsing (SAX-style).

- **Dom**  
  XML DOM API for document/tree manipulation.

- **Dom3**  
  DOM Level 3 extensions / compatibility layer.

- **Xmlo**  
  Additional XML helpers (convenience utilities around parsing/serialization/manipulation).

- **Soap**  
  SOAP utilities (typically built on XML parsing/serialization stacks).

- **Jdf**  
  JDF (Job Definition Format) related utilities (print/workflow oriented XML).

### Documents / imaging / rendering

- **Pdf**  
  PDF utilities (generation/manipulation pipeline depending on implementation).

- **Gd**  
  Bridge to the GD library (image generation, drawing, raster manipulation).

- **Gantt**  
  Gantt planning utilities (data structures + possible export/render helpers depending on implementation).

### System / utilities

- **Sys**  
  System-level helpers (filesystem, processes, environment, OS utilities).

- **Dns**  
  DNS querying/lookup utilities.

- **Iconv**  
  Charset conversion utilities via iconv (UTF-8, ISO-8859-*, etc.).

- **Regex**  
  Regular-expression utilities and wrappers.

- **LibLocale**  
  Localization utilities for non-web contexts (resources, formatting helpers).

### Security / crypto

- **Openssl**  
  OpenSSL bridge (crypto primitives, certificates, TLS-related helpers depending on implementation).

- **Md5**  
  MD5 hashing (legacy; suitable for compatibility checksums, not for modern security).

### Cache / KV-store

- **Redis**  
  Redis client module (KV, cache patterns, pub/sub depending on implementation).

- **Scache**  
  Shared cache helpers (in-memory and/or backend-driven cache primitives depending on implementation).

### Compression

- **Zlib**  
  Compression/decompression utilities (zlib/gzip/deflate depending on implementation).

### Optimization / constraint programming

- **choco**  
  Constraint programming / optimization bindings (Choco-style solver integration, depending on implementation).

- **michoco**  
  Smaller/auxiliary wrapper around choco (utility layer or reduced API).

- **Casper**  
  Constraint/optimization utilities (solver integration or higher-level CP patterns, depending on implementation).

### Messaging / email

- **Mail**  
  Email utilities (MIME building, sending, templates/utilities depending on implementation).

- **Postal**  
  Messaging-related helpers (naming suggests mail/addressing/delivery utilities; exact scope depends on module implementation).

---

## License

Licensed under **Apache License 2.0**. See `LICENSE`.
