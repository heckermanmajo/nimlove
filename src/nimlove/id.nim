# id 
import std/tables

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
    updateEachFrame(C)

type IdObjectContainer*[T] = object
  instances: tables.Table[int, T] ## todo: add getter
  instancesAsSequence: seq[T]
  currentUpdateFrame: int

type Id*[T] = distinct int

proc `$`*[T](id: Id[T]): string =
  return $id.int

proc serialize*[T](id: Id[T]): string =
  return "Id[" & $id.int & "]"

proc unSerializeId*[T](s: string): Id[T] =
    return Id[T](s.replace("Id[","").replace("]", "").parseInt())

proc numberOfInstances*[T](self: IdObjectContainer[T]): int =
  return self.instances.len

proc numberOfDeletedInstances*[T](self: IdObjectContainer[T]): int =
  return self.instancesAsSequence.len - self.instances.len

proc insert*[T](self: var IdObjectContainer[T], obj: T): Id[T] =
  # todo: check taht if the id is already in the container set not to 0
  #       then we just add it to the container without giving ist a new id 
  #   this happens when we add loaded objects to the container whiche we
  #   have unserialized before
  var lastId = self.instances.len
  self.instances[lastId] = obj
  self.instancesAsSequence.add obj 
  return Id[T](lastId)

proc get*[T](self: IdObjectContainer[T], id: Id[T]): T =
  return self.instances[id.int]

proc exists*[T](self: IdObjectContainer[T], id: Id[T]): bool =
  return self.instances.hasKey(id.int)

proc existsAndActive*[T](self: IdObjectContainer[T], id: Id[T]): bool =
  if not self.instances.hasKey(id.int):
    return false
  return not self.instances[id.int].isDeleted

proc updateAll*[T](self: IdObjectContainer[T]) =
    for obj in self.instancesAsSequence:
        if obj.existsAndActive:
            obj.updateEachFrame()
    


