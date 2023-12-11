import ../../src/nimlove as nimlove

const WindowWidth = 800
const WindowHeight = 600

nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "NimLove",
  fullScreen = false,
)

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
