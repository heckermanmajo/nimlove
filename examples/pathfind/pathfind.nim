echo "NimLove - empty game test"

import std/[tables, options, random]

import ../../src/nimlove as nimlove
import ../../src/nimlove/image
import ../../src/nimlove/text
import ../../src/nimlove/map


random.randomize()

const WindowWidth = 800
const WindowHeight = 600

nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "NimLove - empty game test",
  fullScreen = false,
)

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
    createGameTileCallback
      = proc(
        m: Map[MyGameTile], 
        chunk: Chunk[MyGameTile], 
        tile: Tile[MyGameTile]
      ): MyGameTile = 
        let t = new(MyGameTile)
        t.passable = if rand(100) < 15: false else: true
        t.selected = false
        return t 
)
let textures = map.getMapTextures()
var clickedTile = none(Tile[MyGameTile])





# select random start
# select random target
# then get the a star path between

let c: Option[Chunk[MyGameTile]] = m.getChunkAt(0, 0)

var paths: seq[Tile[MyGameTile]] = @[]    
if c.isSome:
  echo c.get
  var t: Tile[MyGameTile] = m.getTileAt(0, 0).get

  var t2: Tile[MyGameTile] = m.getTileAt(14*32, 14*32).get

  var myChunk: Chunk[MyGameTile] = c.get

  for n in myChunk.neighbors(m.getTileAt(14*32, 14*32).get):
    echo n

  paths = myChunk.getPathFromTo(t, t2)
  echo paths

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
    for tpos in map.allVisitedDebug:
      let texture = textures["ball_black"]
      texture.draw(tpos.x*32, tpos.y*32)
    for t in paths:
      let texture = textures["ball_blue"]
      texture.draw(t.x, t.y)
    for t in allCostsDebug:
      drawText($t.cost.int, t.x*32+4, t.y*32, color=Yellow)
    for t in allCostsDebug:
      drawText($t.cost.int, t.x*32+4, t.y*32+15, color=White)

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
