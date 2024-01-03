import std/[strformat]

import ../../src/nimlove as nimlove
import ../../src/nimlove/[image, camera, text]

nimlove.setupNimLove(
  windowWidth = 1900,
  windowHeight = 1200,
  windowTitle = "NimLove - empty game test",
  fullScreen = false,
)

let someImage = image.newImage("mob.png")

var middleMouseDown = false
var lastFrameMouseX: int = 0
var lastFrameMouseY: int = 0
var velocityX: float = 0.0
var velocityY: float = 0.0
var mode = "velocity"



proc update (deltaTime: float) = 
  someImage.draw(100,100, width=200, height=200)

  drawText(100, 100, &"Mode: {mode}  (click 'M' to change the Mode)", color=Black)

  case mode:
  of "velocity":
    if middleMouseDown:
      velocityX += (lastFrameMouseX - nimlove.getMouseX()).float
      velocityY += (lastFrameMouseY - nimlove.getMouseY()).float
    camera.getCamera().moveX velocityX*deltaTime
    camera.getCamera().moveY velocityY*deltaTime
  else:
    if middleMouseDown:
      echo "cam move applied"
      let mouseDeltaX = lastFrameMouseX - nimlove.getMouseX()
      let mouseDeltaY = lastFrameMouseY - nimlove.getMouseY()
      camera.getCamera().moveX mouseDeltaX.float
      camera.getCamera().moveY mouseDeltaY.float

  velocityX = velocityX - velocityX * 0.9 * deltaTime
  if velocityX.abs < 0.1: velocityX = 0.0
  velocityY = velocityY - velocityY * 0.9 * deltaTime
  if velocityY.abs < 0.1: velocityY = 0.0

  lastFrameMouseX = nimlove.getMouseX()
  lastFrameMouseY = nimlove.getMouseY()
  if nimlove.getMouseMiddleClickThisFrame(): 
    velocityX = 0.0
    velocityY = 0.0
    middleMouseDown = true
  if nimlove.getMouseMiddleUpThisFrame(): middleMouseDown = false

nimlove.runProgramm onUpdate=update, onKeyDown=proc (key: NimLoveKey) = 
  case key:
  of NimLoveKey.KEY_M: 
    if mode == "velocity": mode = "default"
    else: mode = "velocity"
  else: discard

  


