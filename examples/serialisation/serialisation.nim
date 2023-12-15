import std/[sequtils, strutils, tables] 
import json
import std/marshal
import ../../src/nimlove as nimlove
import ../../src/nimlove/serialize
import ../../src/nimlove/id

const WindowWidth = 800
const WindowHeight = 600

nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "Serialisation Example",
  fullScreen = false,
)

#[

  Ideas for serialisation:

    -> give the serialisation function a callback in which you closure in
       a container where to put the unserialised objects
    -> repr of string and all nimlove types are already implemented
    -> we can pass in the raw values, not the repr string
    -> we cann add additional infos like the version of the repr, etc.
    -> floats, bools and ints are already parsed to the normal format

    -> for creating the serialisation function we use getReprFields
    -> raw fields, the repr just adds : and the prefix and the() nd joins them 
    -> and off course checks them 
    -> all strngs are checked for quotes and newlines and escaped
    

    -> all passed in raw fields can only be comprised of base datatypes and Ids[]

]#

## serialisierung -> alle gleichen typoen kommen in eine datei.
## <json_string>
#[
echo %{
    "field_name1": {
      "__type__": "int", 
      "__value__": "1"
    },
    "field_name2": {
      "__type__": "int", 
      "__value__": "2"
      },
    "field_name3": {
      "__type__": "Table", 
      "__value__": 
    },
    "field_name4": {
      "__type__": "int", 
      "__value__": "4"
    }
}
]#

let MyGameObjectName = "MyGameObject"
type MyGameObject = ref object of RootObj
  id: Id[MyGameObject]
  x, y: float
  width, height: float
  color: Color
  name: string
  someTable: Table[string, string]



proc `%`[T](id: Id[T]): JsonNode =
  return %{
    "__nimlove_type__": "Id",
    "value": $id.int,
  }.toTable

let myGameObject3 = MyGameObject(
  x: 100.0,
  y: 100.0,
  width: 50.0,
  height: 50.0,
  color: toColor(255, 0, 0),
  name:"\"some name txt \n",
  someTable: {
    "key1 lol": "value1 poop",
    "key2 kek": "value2 boom",
  }.toTable,
)

proc colorFromJson*(node: JsonNode): Color =
  assert node.kind == json.JInt
  return Color node.getInt

proc idFromJson*[T](node: JsonNode): Id[T] =
  assert node["__nimlove_type__"].getStr == "Id"
  assert node["__value__"].kind == json.JInt
  return Id[T] node.getInt

# we need to map images on the source
# file path so that we dont load 
# a file multiple times if we load atlases
# from  
proc imageFromJson*(node: JsonNode) = discard
proc textureAtlasTextureFromJson*(node: JsonNode) = discard
proc soundFromJson*(node: JsonNode) = discard


echo %myGameObject3

let jsonNode = %myGameObject3
let jsonString = $jsonNode
var j = jsonString.parseJson

echo j.contains("id")
for key, value in j.fields:
  echo key, " : ", $value

quit 0



proc myObjectFromJsonNode*(node: JsonNode): MyGameObject =
  assert node.kind == json.JObject
  return MyGameObject(
    id: if node.contains("id"): idFromJson[MyGameObject] node["id"] else: cast[Id[MyGameObject]](-1), 
    #[x: x,
    y: y,
    width: width,
    height: height,
    color: color,
    name: name,
    someTable: someTable,]#
  )

var MyGameObjectContainer*:IdObjectContainer[MyGameObject]

proc getTypeName*(obj: MyGameObject): string = MyGameObjectName

proc serialize*(obj: MyGameObject): Table[string, string] =
  return {
    "__type__:": MyGameObjectName,
    "__version__:": "1.0",
    "id": serialize obj.id,
    "x" : serialize obj.x,
    "y" : serialize obj.y,
    "width":serialize obj.width,
    "height": serialize obj.height,
    "color": serialize obj.color,
    "name": serialize obj.name,
    "someTable": serialize obj.someTable,
  }.toTable

proc unserialize*(fields: Table[string, string]): MyGameObject =
  let myObject = MyGameObject(
    id:     if fields.hasKey("id"):       unSerializeId[MyGameObject] fields["id"] else: cast[Id[MyGameObject]](-1),
    x:      if fields.hasKey("x"):        unSerializeFloat fields["x"]       else: 0.0,
    y:      if fields.hasKey("y"):        unSerializeFloat fields["y"]       else: 0.0,
    width:  if fields.hasKey("width"):    unSerializeFloat fields["width"]   else: 0.0,
    height: if fields.hasKey("height"):   unSerializeFloat fields["height"]  else: 0.0,
    color:  if fields.hasKey("color"):    unSerializeColor fields["color"]   else: Color(0),
    name:   if fields.hasKey("name"):     unSerializeString fields["name"]   else: "",
  )
  return myObject

unSerializeCallbackTable[MyGameObjectName] = proc(fields: Table[string, string]) =
  let myObject = unserialize(fields)
  discard MyGameObjectContainer.insert(myObject)




let myGameObject = MyGameObject(
  x: 100.0,
  y :100.0,
  width: 50.0,
  height: 50.0,
  color: toColor(255, 0, 0),
  name:"\"some name txt \n",
  someTable: {
    "key1 lol": "value1 poop",
    "key2 kek": "value2 boom",
  }.toTable,
)
echo myGameObject.serialize

let myGameObject2 = unserialize(myGameObject.serialize)

echo myGameObject2.serialize

quit 0

nimlove.runProgramm(
  onUpdate= proc(deltaTime: float) = discard,
  onKeyDown= proc(key: NimLoveKey) = discard,
  onKeyUp= proc(key: NimLoveKey) = discard,
  onMouseDown= proc(x, y: int) = discard,
  onMouseUp= proc(x, y: int) = discard,
  onMouseMove= proc(x, y: int) = discard,
  onMouseScrollUp= proc() = discard,
  onMouseScrollDown= proc() = discard,
  onQuit= proc() = discard,
)
