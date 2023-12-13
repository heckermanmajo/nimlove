import ../../src/nimlove as nimlove
import ../../src/lovemodules/button as btn

const WindowWidth = 800
const WindowHeight = 600


nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "Button-Test",
  fullScreen = false,
)



let button = nimlove.newNimLoveImage("button.png")
let button_default = nimlove.newTextureAtlasTexture(button, 0, 0, 100, 30)
let button_hover = nimlove.newTextureAtlasTexture(button, 100, 0, 100, 30)


# input: create "Keyinput was consumed" field

let b = newButton(
    defaultTexture=button_default,
    hoverTexture=button_hover,
    x=100, 
    y=100, 
    zoom=2.0, 
    text="Button-Test"
)



nimlove.runProgramm(
  onUpdate= proc(deltaTime: float) = 
    nimlove.displayDebugInfo()
    block:
        let state = b.drawAndCollectInteraction()
        if state.clickedLeft:
            echo "Left-Click"
        if state.clickedRight:
            echo "Right-Click"
        if state.clickedMiddle:
            echo "Middle-Click"
        if state.hovered:
            discard
            #echo "Hovered"

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
