
// init file for module Soap
// created Thu Jul  3 10:00:57 2003 by claire v3.3.23


(use_module("Wcl"))
(use_module("Xmlo"))
(use_module("Openssl"))


Soap :: module(
	uses = list(Wcl, Xmlo,Openssl),
	made_of = list("model", "response_parse", "soap_call","soap_scall.cl",
					"generate_wsdl", "soap_service"),
	source = "source",
	version = "v1.0.0") // put your version here


(load(Soap))
