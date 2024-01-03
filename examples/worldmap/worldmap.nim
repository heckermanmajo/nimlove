import std/[json, strutils, strformat]
import ../../src/nimlove as nimlove
import ../../src/nimlove/[image, map]

const WindowWidth = 800
const WindowHeight = 600

nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "NimLove - empty game test",
  fullScreen = false,
)
map.initMapTextures()
var worldMap = newEditableImage("worldmap.png")
# green
worldMap.replaceColor(PixelValue(r:106, g:190, b:48, a:255), PixelValueRed)
# green border
worldMap.replaceColor(PixelValue(r:54, g:143, b:96, a:255), PixelValueRed)
# blue water
worldMap.replaceColor(PixelValue(r:91, g:110, b:225, a:255), PixelValueBlue)

proc isWater*(p: PixelValue): bool = return p == PixelValueBlue
proc isLand*(p: PixelValue): bool = return p == PixelValueRed

type 
  TileType* = enum
    Water, Land
    
  MyGameTile* = ref object
    passable: bool
    selected: bool
    tileType: TileType
    building: int


var textures = map.getMapTextures()
var myTexture = textures["TileType.Water"]

proc isSelected*(t: MyGameTile): bool = return t.selected
proc isPassable*(t: MyGameTile): bool = return t.passable

proc draw*(t: MyGameTile, x, y: int) = 
  if t.tileType == TileType.Water:
    
    
  else:
    map.drawTile(TileType.Land, x, y)


proc `%`*(t: TileType): JsonNode = 
  case t
  of TileType.Water: return %"Water"
  of TileType.Land: return %"Land"




var myMap = newMap[MyGameTile](
    sideLenInChunksX= 32, 
    sideLenInChunksY= 16,
    createGameTileCallback= proc(m: Map[MyGameTile], chunk: Chunk[MyGameTile], tile: Tile[MyGameTile]): MyGameTile =
      result = new(MyGameTile)
      echo &"tile.xNum: {tile.xNum}, tile.yNum: {tile.yNum}"
      let pixelToReadX = tile.xNum
      let pixelToReadY = tile.yNum
      if pixelToReadX > 1024:
        echo "pixelToReadX > 1024"
        quit(-1)
      if pixelToReadY > 512:
        echo pixelToReadY
        echo "pixelToReadY > 512"
        quit(-1)

      if isWater(worldMap.getPixel(pixelToReadX, pixelToReadY)):
        result.tileType = TileType.Water
      else:
        result.tileType = TileType.Land

      result.passable = true
      result.selected = false
      result.building = 0
    , 
    chunkSizeInTiles = 32,
    tileSizeInPixels = 32,
)


let mapAsImage = worldMap.makeImageFromEImage()

nimlove.runProgramm(
  onUpdate= proc(deltaTime: float) = 
    #mapAsImage.draw(0, 0)
    myMap.drawMap()
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
