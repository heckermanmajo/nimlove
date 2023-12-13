import std/tables

type GameObjectContainer*[T] = object
  instances: tables.Table[int, T] ## todo: add getter
  instancesAsSequence: seq[T]

type Id*[T] = distinct int

proc `$`*[T](id: Id[T]): string =
  return $id.int

proc insert*[T](self: var GameObjectContainer[T], obj: T): Id[T] =
  var lastId = self.instances.len
  self.instances[lastId] = obj
  self.instancesAsSequence.add obj 
  return Id[T](lastId)

proc get*[T](self: GameObjectContainer[T], id: Id[T]):  T =
  return self.instances[id.int]

proc exists*[T](self: GameObjectContainer[T], id: Id[T]): bool =
  return self.instances.hasKey(id.int)

proc drawAll*[T](self: GameObjectContainer[T]) =
  for obj in self.instancesAsSequence:
    if obj.canBeDrawn:
        obj.draw()