import ../../src/nimlove as nimlove
import ../../src/nimlove/image

const WindowWidth = 800
const WindowHeight = 600

nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "NimLove - A Popel Schipsing Software",
  fullScreen = false,
)

let pss1 = newImage("pss1.png")
let pss2 = newImage("pss2.png")
let pss3 = newImage("pss3.png")
let pss4 = newImage("pss4.png")
let pss5 = newImage("pss5.png")


var timer = 0.0
var counter = 0

nimlove.runProgramm(
  onUpdate= proc(deltaTime: float) = 
    timer += deltaTime
    if timer > 1:
        timer = 0
        counter += 1
        if counter > 4:
            counter = 0
    case counter:
        of 0: pss1.draw(0, 0, WindowWidth,WindowHeight)
        of 1: pss2.draw(0, 0, WindowWidth, WindowHeight)
        of 2: pss3.draw(0, 0, WindowWidth, WindowHeight)
        of 3: pss4.draw(0, 0, WindowWidth, WindowHeight)
        of 4: pss5.draw(0, 0, WindowWidth, WindowHeight)
        else: discard
      
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
