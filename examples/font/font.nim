import ../../src/nimlove as nimlove
import ../../src/nimlove/[text]
const WindowWidth = 800
const WindowHeight = 600

nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "NimLove - empty game test",
  fullScreen = false,
)

loadFont(path="pixel.ttf", name="p16", size=16)
loadFont(path="pixel.ttf", name="p32", size=32)
loadFont(path="pixel.ttf", name="p64", size=64)

nimlove.runProgramm(
  onUpdate= proc(deltaTime: float) = 
    drawText("HELLO", 100, 100, fontName="p16", color=toColor(255, 0, 0))
    drawText("WORLD", 100, 200, fontName="p32")
    drawText("NIMLOVE", 100, 300, fontName="p64")
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
