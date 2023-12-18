## EDITOR-FEATURE GOAL
## -------------------
## Load a map
## Save a map
## Edit a map
## 
## Test Pathfinding.
## Visualize stuff like the flooding algorithm.
import std/strformat
import  ../../../src/nimlove
import  ../../../src/nimlove/[image, map, button, text, camera]

# 1. Create an empty map and set fields to non passable
# 2. Save the fields into a file
# 3. at editor start display a list of all possible maps and for each one button to load

nimlove.setupNimLove(
  windowWidth = 1900,
  windowHeight = 1200,
  windowTitle = "NimLove - empty game test",
  fullScreen = true,
)

type MyGameTile* = ref object
  passable: bool
  selected: bool
  tileType: int
  building: int

proc isSelected*(t: MyGameTile): bool = return t.selected
proc isPassable*(t: MyGameTile): bool = return t.passable


proc createDefaultMap(): Map[MyGameTile] =
  ###
  #[
    sideLenInChunks: int, 
    createGameTileCallback: proc(m: Map[T], chunk: Chunk[T], tile: Tile[T]): T, 
    chunkSizeInTiles:int = 16,
    tileSizeInPixels:int = 32,
  ]#

  proc localCreateMyGameTile(
    m: Map[MyGameTile], 
    chunk: Chunk[MyGameTile], 
    tile: Tile[MyGameTile]
  ): MyGameTile =
      var t = new(MyGameTile)
      t.passable = true
      t.selected = false
      t.tileType = 0
      t.building = 0
      return t

  var map = newMap[MyGameTile](
    sideLenInChunks = 4, # 4x4 chunks -> 32x32 x 4x4 tiles 
    createGameTileCallback = localCreateMyGameTile,
    chunkSizeInTiles = 16,
    tileSizeInPixels = 32,
  )
  return map

var selectedMap = createDefaultMap()
  
nimlove.runProgramm proc(deltaTime: float) =
  selectedMap.drawMap()
  drawText("Hello editor", 12,12)
  drawText( &"{camera.getCamera().x}" , 100, 100, color=Red)
  if getMouseLeftClickThisFrame(): camera.getCamera().moveX(-2)
  if getMouseRightClickThisFrame(): camera.getCamera().moveX(2)
  if getMouseScrollDownThisFrame(): camera.getCamera().zoomOut()
  if getMouseScrollUpThisFrame(): camera.getCamera().zoomIn()



