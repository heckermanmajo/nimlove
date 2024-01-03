## Obect serialisation:
## You can json serialize the following types:
## - Id 
## - IdObjectContainer (you need to implement % and put in a unserialize callback)
## - Colors
## - Images
## - Sounds
## - TextureAtlasTexture
## - EImage 
## - all nim-types like "string, int, float, etc."
## 
## Be carful with option, since it Option[T] will be serialized to null or %T


import std/[sequtils, strutils, tables, options, json] 
import ../../src/nimlove as nimlove
import ../../src/nimlove/idobject

const WindowWidth   = 800
const WindowHeight  = 600

nimlove.setupNimLove(
  windowWidth   = WindowWidth,
  windowHeight  = WindowHeight,
  windowTitle   = "Serialisation Example",
  fullScreen    = false,
)

type 
  
  GameObjectB = object
    id:       Id[GameObjectB]
    name:     string
    value:    int
    option:   Option[string]
    option2:  Option[Id[GameObjectA]]
    option3:  Option[Id[GameObjectA]]

  GameObjectA = object
    id: Id[GameObjectA]
    name: string
    value: int
    option: Option[string]
    option2: Option[Id[GameObjectB]]
    option3: Option[Id[GameObjectA]]
    values: Table[string, string]
    lols: seq[string]
    lols2: Table[string, Id[GameObjectB]]

# We need to implement the IdObject-concept for our GameObjects

proc isDeleted*(self: GameObjectA): bool = false
proc setBackToUndeleted*(self: GameObjectA) = discard
proc updateEachFrame*(self: GameObjectA, deltaTime: float) = discard

proc isDeleted*(self: GameObjectB): bool = false
proc setBackToUndeleted*(self: GameObjectB) = discard
proc updateEachFrame*(self: GameObjectB, deltaTime:float) = discard

proc `%`*(self: GameObjectA) : JsonNode =
  result = % {
    "id":       %self.id,
    "name":     %self.name,
    "value":    %self.value,
    "option":   %self.option,
    "option2":  %self.option2,
    "option3":  %self.option3,
    "values":   %self.values,
    "lols":     %self.lols,
    "lols2":    %self.lols2,
  }

proc GameObjectAFromJson*(node: JsonNode) : GameObjectA =
  result = GameObjectA()

  result.id =        getId[GameObjectA] node["id"]
  result.name =      getStr node["name"]
  result.value =     getInt node["value"]

  result.option 
    = if node["option"].isNil: none(string) 
    else: some(getStr node["option"])
  result.option2 
    = if node["option2"].isNil: none(Id[GameObjectB]) 
    else: some(getId[GameObjectB] node["option2"])
  result.option3 
    = if node["option3"].isNil: none(Id[GameObjectA]) 
    else: some(getId[GameObjectA] node["option3"])
  
  result.values = block:
    var table: Table[string, string] = initTable[string, string]()
    for key, value in node["values"].pairs:
      table[key] = getStr value
    table

  result.lols = block:
    var lols: seq[string] = @[]
    for value in node["lols"].items:
      lols.add getStr value
    lols

  result.lols2 = block:
    var table: Table[string, Id[GameObjectB]] = initTable[string, Id[GameObjectB]]()
    for key, value in node["lols2"].pairs:
      table[key] = getId[GameObjectB] value
    table



proc `%`*(self: GameObjectB) : JsonNode =
  result = % {
    "id":       %self.id,
    "name":     %self.name,
    "value":    %self.value,
    "option":   %self.option,
    "option2":  %self.option2,
    "option3":  %self.option3,
  }

proc GameObjectBFromJson*(node: JsonNode) : GameObjectB =
    result = GameObjectB()

    result.id =        getId[GameObjectB] node["id"]
    result.name =      getStr node["name"]
    result.value =     getInt node["value"]
  
    result.option 
      = if node["option"].isNil: none(string) 
      else: some(getStr node["option"])
    result.option2 
      = if node["option2"].isNil: none(Id[GameObjectA]) 
      else: some(getId[GameObjectA] node["option2"])
    result.option3 
      = if node["option3"].isNil: none(Id[GameObjectA]) 
      else: some(getId[GameObjectA] node["option3"])








var GameObjectAContainer = IdObjectContainer[GameObjectA]()

proc newGameObjectA(): GameObjectA =
  result = GameObjectA()
  result.id = GameObjectAContainer.insert(result)
  return result

let tenGameobjects = block:
  var gameObjects: seq[GameObjectA] = @[]
  for i in 0..<10:
    gameObjects.add newGameObjectA()
    echo %gameObjects[i]
  gameObjects

assert GameObjectAContainer.exists(tenGameobjects[0].id)
assert GameObjectAContainer.exists(tenGameobjects[1].id)
assert GameObjectAContainer.exists(tenGameobjects[2].id)
assert GameObjectAContainer.exists(tenGameobjects[3].id)
assert GameObjectAContainer.exists(tenGameobjects[4].id)
assert GameObjectAContainer.exists(tenGameobjects[5].id)
assert GameObjectAContainer.exists(tenGameobjects[6].id)
assert GameObjectAContainer.exists(tenGameobjects[7].id)
assert GameObjectAContainer.exists(tenGameobjects[8].id)
assert GameObjectAContainer.exists(tenGameobjects[9].id)


GameObjectAContainer.writeAllIdObjectsToFile("test.txt")


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
