import ../../src/nimlove as nimlove
import ../../src/nimlove/colors

const WindowWidth = 800
const WindowHeight = 600

nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "NimLove",
  fullScreen = false,
)

nimlove.runProgramm(
  onUpdate= proc(deltaTime: float) =
    drawText 10,30, "mouseX: " & $nimlove.getMouseX() & " mouseY: " & $nimlove.getMouseY(), color=Black
  
    if nimlove.getMouseRightClickThisFrame():
      echo "Right mouse button clicked"
      # check collsion of button, and iff coliied do xyz
    #if Button("",123,124):
    #    echo "Button clicked"

  ,
  onKeyDown= proc(key: NimLoveKey) = discard,
  onKeyUp= proc(key: NimLoveKey) = discard,
  onKeyPressed=proc(key: NimLoveKey) = discard,
  onKeyReleased= proc(key: NimLoveKey) = discard,
  onMouseDown= proc(x, y: int) = discard,
  onMouseUp= proc(x, y: int) = discard,
  onMouseMove= proc(x, y: int) = 
    discard
  ,
  onMouseScrollUp= proc() = discard,
  onMouseScrollDown= proc() = discard,
  onQuit= proc() = discard,
)
