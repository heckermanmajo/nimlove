# idobjects: Game or simulation-objects...
import std/[tables, json]
import ../nimlove  # We need ABSOLUTE_PATH
#[
WEIRD ERROR:

/home/majo/Desktop/nimlove/tests/test_serialize.nim(15, 8) template/generic instantiation of `%` from here
/home/majo/Desktop/nimlove/src/nimlove/id.nim(31, 10) template/generic instantiation of `%` from here
/home/majo/.choosenim/toolchains/nim-2.0.0/lib/pure/json.nim(368, 15) Error: type mismatch
Expression: pairs(table)
  [1] table: Table[system.string, system.string]

Expected one of (first mismatch at [position]):
[1] iterator pairs(a: cstring): tuple[key: int, val: char]
[1] iterator pairs(a: string): tuple[key: int, val: char]
[1] iterator pairs(node: JsonNode): tuple[key: string, val: JsonNode]
[1] iterator pairs[IX, T](a: array[IX, T]): tuple[key: IX, val: T]
[1] iterator pairs[T](a: openArray[T]): tuple[key: int, val: T]
[1] iterator pairs[T](a: seq[T]): tuple[key: int, val: T]
]#


# what happens if we 
# save refs to dead ones?
# Well nothing - since they stay
# in the pool, they will be reused
# rule: make all fields provate and 
# then add error on bad access
# but compile it out in release mode

type IdObject* = concept C
    isDeleted(C) is bool ## deleted does not mean deleted from memory, since they are pooled
    setBackToUndeleted(C)
    updateEachFrame(C,float)

type IdObjectContainer*[T: IdObject] = ref object
  instances: tables.Table[int, T] ## todo: add getter
  instancesAsSequence: seq[T]
  currentUpdateFrame: int

type Id*[T] = distinct int

proc `$`*[T](id: Id[T]): string =
  return $id.int

proc `%`*[T](id: Id[T]): JsonNode =
  ## This function is used by the json module to serialize the object
  ## an it is used for serailizing the object in the nimlove way.
  return %{
    "__nimlove_type__": "Id",
    "__version__": "0.1",
    "__value__": $id.int,
  }.toTable

proc getId*[T: IdObject](node: JsonNode): Id[T] =
  if node.kind != JObject:
    raise newException(ValueError, "Expected JObject, got: " & $node.kind)
  case node["__version__"].getStr:
  of "0.1":
    if node["__nimlove_type__"].getStr != "Id":
      raise newException(ValueError, "Expected Id, got: " & $node["__nimlove_type__"].getStr)
    if node["__value__"].kind != JInt:
      raise newException(ValueError, "Expected int, got: " & $node["__value__"].kind)
    return Id[T](node["__value__"].getInt)
  else:
    raise newException(ValueError, "Unknown version for parsing nimlove JSON-Id-Node: " & $node)

proc numberOfInstances*[T: IdObject](self: IdObjectContainer[T]): int =
  return self.instances.len

proc numberOfDeletedInstances*[T: IdObject](self: IdObjectContainer[T]): int =
  return self.instancesAsSequence.len - self.instances.len

proc insert*[T: IdObject](self: var IdObjectContainer[T], obj: T): Id[T] =
  # todo: check taht if the id is already in the container set not to 0
  #       then we just add it to the container without giving ist a new id 
  #   this happens when we add loaded objects to the container whiche we
  #   have unserialized before
  var lastId = self.instances.len
  self.instances[lastId] = obj
  self.instancesAsSequence.add obj 
  return Id[T](lastId)

proc get*[T: IdObject](self: IdObjectContainer[T], id: Id[T]): T =
  return self.instances[id.int]

proc exists*[T: IdObject](self: IdObjectContainer[T], id: Id[T]): bool =
  return self.instances.hasKey(id.int)

proc existsAndActive*[T: IdObject](self: IdObjectContainer[T], id: Id[T]): bool =
  if not self.instances.hasKey(id.int):
    return false
  return not self.instances[id.int].isDeleted

proc updateAll*[T: IdObject](self: IdObjectContainer[T]) =
    for obj in self.instancesAsSequence:
      obj.updateEachFrame()
    
proc writeAllIdObjectsToFile*[T: IdObject](self: IdObjectContainer[T], filePath: string) =
  let path 
    = if filePath.endsWith("/"): ABSOLUTE_PATH & filePath
      else: ABSOLUTE_PATH & "/"  & filePath
  var file = open(path, fmWrite)
  file.writeLine("nimlove-IdObjects-file")
  file.writeLine("version: 0.1")
  file.writeLine("number-of-objects: " & $self.instances.len)
  for obj in self.instancesAsSequence:file.writeLine(%obj)
  file.close()

proc readAllIdObjectsFromFile*[T: IdObject](
  self: var IdObjectContainer[T], 
  filePath: string,
  readCallback: proc(jsonValue: string): T
) =

  # check beforehand that the container is empty
  if self.instances.len != 0:
    raise newException(ValueError, "The container is not empty, can not read from file into it.")
  let path 
    = if filePath.endsWith("/"): ABSOLUTE_PATH & filePath
      else: ABSOLUTE_PATH & "/"  & filePath
  var file = open(path, fmRead)
  var line = file.readLine()
  if line != "nimlove-idobjects-file":
    raise newException(ValueError, "Expected nimlove-idobjects-file, got: " & line)
  line = file.readLine()
  if line != "version: 0.1":
    raise newException(ValueError, "Expected version: 0.1, got: " & line)
  line = file.readLine()
  if line[0..18] != "number-of-objects:":
    raise newException(ValueError, "Expected number-of-objects: <number>, got: " & line)
  var numberOfObjects = line[19..line.len].parseInt()
  for i in 0..<numberOfObjects:
    line = file.readLine()
    var obj = readCallback(line)
    self.insert(obj)
  file.close()

