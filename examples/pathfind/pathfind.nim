echo "NimLove - empty game test"

import std/[tables, options, random]

import ../../src/nimlove as nimlove
import ../../src/nimlove/image
import ../../src/nimlove/text

static:
    echo "astar loaded1"

import map

static:
    echo "astar loaded2"
random.randomize()

const WindowWidth = 800
const WindowHeight = 600
static:
    echo "astar loaded3"
nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "NimLove - empty game test",
  fullScreen = false,
)

static:
    echo "astar loaded4"
map.initMapTextures() 


#[
https://factorio.com/blog/post/fff-317

A* Reversed resumeable
-> der abstrakte Pathfinder speichert seine Daten zwischen
Base-Pathfinder (tile based)
Abstract-Pathfinder (chunk based) -> adds into the heuristic function for base pathfinder


]#

# Astar
# astar on chunks
# astar on tiles, based on which chunk we are in

type MyGameTile* = ref object
  passable: bool
  selected: bool

proc isSelected*(t: MyGameTile): bool = return t.selected
proc isPassable*(t: MyGameTile): bool = return t.passable

var m = newMap[MyGameTile](
    sideLenInChunks= 1,
    createGameTileCallback= proc(m: Map[MyGameTile], chunk: Chunk[MyGameTile], tile: Tile[MyGameTile]): MyGameTile = 
      let t = new(MyGameTile)
      t.passable = if rand(100) < 40: false else: true
      t.selected = false
      return t 
)
let textures = map.getMapTextures()
var clickedTile = none(Tile[MyGameTile])





# select random start
# select random target
# then get the a star path between
static:
    echo "astar loaded5"

let c: Option[Chunk[MyGameTile]] = m.getChunkAt(0, 0)
static:
    echo "astar loaded5"

var paths: seq[Tile[MyGameTile]] = @[]    
if c.isSome:
  echo c.get
  static:
    echo "astar loaded5"
  var t: Tile[MyGameTile] = m.getTileAt(0, 0).get

  #echo t
  static:
    echo "astar loaded6"

  var t2: Tile[MyGameTile] = m.getTileAt(14*32, 14*32).get
  static:
    echo "astar loaded7"

  var myChunk: Chunk[MyGameTile] = c.get

  for n in myChunk.neighbors(m.getTileAt(14*32, 14*32).get):
    echo n

  static:
    echo "astar loaded8"
  paths = myChunk.getPathFromTo(t, t2)
  echo paths
static:
    echo "astar loaded6"

nimlove.runProgramm(

  onUpdate = proc(deltaTime: float) = 

    m.drawMap()

    if nimlove.getMouseLeftClickThisFrame():
      echo "mouse left click"
      let tile = m.getTileAt(nimlove.getMouseX(), nimlove.getMouseY())
      if tile.isSome:
        if tile.get.gameTile.isPassable():
          clickedTile = tile
          let myT = cast[MyGameTile](tile.get.gameTile)
          myT.passable = false
          echo "clicked tile: ", clickedTile.get.x, ", ", clickedTile.get.y

    if clickedTile.isSome:
      let texture = textures["blue_outline"]
      texture.draw(clickedTile.get.x, clickedTile.get.y)

    for t in paths:
      let texture = textures["white"]
      texture.draw(t.x, t.y)

    text.displayDebugInfo()
    
  ,
  onKeyDown= proc(key: NimLoveKey) = discard,
  onKeyUp= proc(key: NimLoveKey) = discard,
  onMouseDown= proc(x, y: int) = discard,
  onMouseUp= proc(x, y: int) = discard,
  onMouseMove= proc(x, y: int) = discard,
  onMouseScrollUp= proc() = discard,
  onMouseScrollDown= proc() = discard,
  onQuit= proc() = discard,
)
