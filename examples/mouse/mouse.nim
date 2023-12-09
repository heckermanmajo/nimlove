import ../../src/nimlove as nimlove
import ../../src/lovemodules/screenlogger

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
      log "Right mouse button clicked"

    if nimlove.getMouseLeftClickThisFrame():
      echo "Left mouse button clicked"
      log "Left mouse button clicked"

    if nimlove.getMouseMiddleClickThisFrame():
      echo "Middle mouse button clicked"
      log "Middle mouse button clicked"

    if nimlove.getMouseScrollUpThisFrame():
      echo "Mouse scroll up"
      log "Mouse scroll up"

    if nimlove.getMouseScrollDownThisFrame():
      echo "Mouse scroll down"
      log "Mouse scroll down"

    drawLogs 10, 60
  ,
  onKeyDown= proc(key: NimLoveKey) = discard,
  onKeyUp= proc(key: NimLoveKey) = discard,
  onMouseDown= proc(x, y: int) = discard,
  onMouseUp= proc(x, y: int) = discard,
  onMouseMove= proc(x, y: int) = 
    discard
  ,
  onMouseScrollUp= proc() = discard,
  onMouseScrollDown= proc() = discard,
  onQuit= proc() = discard,
)
