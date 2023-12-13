## Protocol example
## https://nim-lang.org/docs/manual_experimental.html#concepts-generic-concepts-and-type-binding-rules
##https://gist.github.com/honewatson/583135c1b191119a3b3be3fdbfe8607b

import std/[tables]

import ../../src/nimlove as nimlove

const WindowWidth = 800
const WindowHeight = 600

nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "Protocol",
  fullScreen = false,
)



type 
    # this is basically an protocol: a Collidable is what has these fields
    # so we can generate generics based on this
    # this can be used for tilemaps, physics, etc.
    Collidable*{.explain.} = concept C
        C.x is float
        C.y is float
        C.width is float
        C.height is float

    # This is an interface that needs to be implemented
    # in order to use the Fooer procs
    # in this case a collidable that has a foo proc
    # is a fooer
    Fooer* = concept C
        C is Collidable
        C.foo is Collidable

proc collidesWith*[A:Collidable,B:Collidable](x:A , other:B): bool =
    if x.x + x.width < other.x: return false
    if x.x > other.x + other.width: return false
    if x.y + x.height < other.y: return false
    if x.y > other.y + other.height: return false
    return true

type MyObject* = object
    x, y, width, height: float

proc foo*[A:Fooer](x:A): Collidable =
    return MyObject(x:0, y:0, width:10, height:10)

proc foo*(x:MyObject): Collidable =
    return MyObject(x:0, y:0, width:10, height:10)

type MyOtherObject* = object
    x, y, width, height: float

let myObject = MyObject(x:0, y:0, width:10, height:10)
let myOtherObject = MyOtherObject(x:5, y:5, width:10, height:10)
let noCollide = MyOtherObject(x:20, y:20, width:10, height:10)

echo myObject.collidesWith(myOtherObject)
echo myObject.collidesWith(noCollide)

echo myObject is Fooer


type

    SpacyObject* = concept C
      C.x is int
      C.y is int
      C.width is int
      C.height is int

    SpacyObjectWithVelocity* = concept C
      C is SpacyObject
      C.angle is float
      C.velocityX is float
      C.velocityY is float
      C.spinningVelocity is float

type
  
  NimLoveTile* = concept C
    C is SpacyObject

  NimLoveChunk* = concept C
    C.tilesAsSequence is seq[seq[NimLoveTile]]
    C.tilesAsTable is tables.Table[int, tables.Table[int, NimLoveChunk]]

  NimLoveMap* = concept C
    C.chunksAsSequence is seq[seq[NimLoveChunk]]
    C.chunksAsTable is tables.Table[int, tables.Table[int, NimLoveChunk]]


# todo: pathfind between chunks
# -> calculate the min cost for going through a chunk 
#    for this use every start position and calculate a star
#    we ignore for this caculation the "soft" elemnets in a chunk
#    but we search for more ways if too many units are in a chun
#    We increase the probability tzhat a unit goes to another chunk
#    if the chunk is with soft objects
#    we can safe the go through values for each border-tile
# todo: pathfins from one chunk to another


proc collidesWith*[T: SpacyObject](a: T, b: T): bool =
  return a.x < b.x + b.width and
         a.x + a.width > b.x and
         a.y < b.y + b.height and
         a.y + a.height > b.y

proc getCollisionDepth*[T: SpacyObject](a: T, b: T): tuple[xCollisionDepth, yCollisionDepth: int] =
  var xCollisionDepth = 0
  var yCollisionDepth = 0

  if a.x < b.x:
    xCollisionDepth = a.x + a.width - b.x
  else:
    xCollisionDepth = b.x + b.width - a.x

  if a.y < b.y:
    yCollisionDepth = a.y + a.height - b.y
  else:
    yCollisionDepth = b.y + b.height - a.y

  return (xCollisionDepth, yCollisionDepth)

proc applyVelocity*[T: SpacyObjectWithVelocity](a: T, delta_time: float) =
  a.x += int(a.velocityX * delta_time)
  a.y += int(a.velocityY * delta_time)
  a.angle += a.spinningVelocity * delta_time
  if a.angle > 360: a.angle -= 360

proc drawOutline*[T: SpacyObject](a: T, color: Color) =
  ## Draw an outline
  discard
  #love.graphics.setColor(color)
  #love.graphics.rectangle("line", a.x, a.y, a.width, a.height)

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
