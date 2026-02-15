// @doc JSON encoding
// These functions define how to encode different types of objects to JSON format.

[encode(self:any) : void -> Json/encode(self)]

[encode(self:table) : void -> Json/encode(self)]

[encode(self:boolean) : void -> if self princ("true") else princ("false")]


[encode(self:port) : void -> princ("")]


[encode(self:class) : void -> 
//[0] encode@class(~S) // self,
printf("~S",string!(name(self)))]
[encode(self:module) : void -> 
//[0] encode@module(~S) // self,
printf("~S",string!(self.name))]

[encode(prop:property, self:any) : void ->
//[0] encode(~S,~S) // prop,self,
when v := get(prop,self) in ( printf("~S : ~I",string!(prop.name), encode(v)))]

[encode(self:bag) : void ->
    printf("[~I]",(let first? := true in (
                    for i in self (
                        if first? (first? := false) else printf(", "),
                        encode(i)))))]


[encode(self:object) : void
-> //[0] encode(~S) // self,
    printf("{~I}",
    (let first? := true in (
        for p in self.isa.slots
            (if known?(p.selector,self)
                (if first? (first? := false) else printf(", "),
                encode(p.selector,self))))))]
