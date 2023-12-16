# test all serializations
echo "test all serializations"
import std/json
import std/tables
import ../src/nimlove/idobject


type MyObject1 = object
    a: int
    b: string
    c: float

proc `%`(self: MyObject1): JsonNode 
    = % {
        "a":                %self.a,
        "b":                %self.b,
        "c":                %self.c,
        "__version__":      %"0.1",
        "__type__":         %"MyObject1",
        "__userdefined__":  %true
    }.toTable

proc myObject1FromJson*(json: JsonNode): MyObject1 =
    assert json["__type__"].getStr() == "MyObject1"
    assert json["__version__"].getStr() == "0.1"
    assert json["__userdefined__"].getBool() == true
    result.a = json["a"].getInt()
    result.b = json["b"].getStr()
    result.c = json["c"].getFloat()
    return result


let mid: Id[MyObject1] = Id[MyObject1](1)

echo $(%mid)

let m = MyObject1(a: 1, b: "hello", c: 3.14)
echo %m
let nm = myObject1FromJson(%m)
echo nm
