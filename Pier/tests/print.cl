
Dummyclass <: object

Dummyclass <: object(
    astring:string = "test",
    aninteger:integer = 12,
    afloat:float = 3.14,
    atrue:boolean = true,
    afalse:boolean = false,
    alist:list = list(1,2,3),
    atuple:tuple = tuple(1,"two",3.0),
    anunknown:{unknown} = unknown,
    atable:table,
    adummy:Dummyclass)


(let abob := Dummyclass(adummy = Dummyclass()) in (
    abob.atable := make_table(string,float,0.0),
    abob.atable["pi"] := 3.14,
    encode(abob)))

