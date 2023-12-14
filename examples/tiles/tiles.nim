import ../../src/nimlove as nimlove
import ../../src/nimlove/[image]
import std/tables

const WindowWidth = 1900
const WindowHeight = 1200

nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "NimLove",
  fullScreen = false,
)

let tileAtlas = newImage("tiles.png")

let gray = newTextureAtlasTexture(
  image=tileAtlas,
  textureStartX=5*32,
  textureStartY=0,
  textureWidth=32,
  textureHeight=32,
)

let yellowOutline = newTextureAtlasTexture(
  image=tileAtlas,
  textureStartX=4*32,
  textureStartY=0,
  textureWidth=32,
  textureHeight=32,
)

# todo: other colors


type Camera = object
  x, y: int

# camera movement
# highlight functions -> welche tiles werden wie gehighlighted??

setDelayCPUWaste(false)

nimlove.runProgramm proc(delta_time: float) =
  tileAtlas.draw(0, 0)

  for i in 0..(WindowWidth div 32):
    for j in 0..(WindowHeight div 32):
      gray.draw(i*32, j*32)

  for i in 0..(WindowWidth div 32):
    for j in 0..(WindowHeight div 32):
      yellowOutline.draw(i*32, j*32)