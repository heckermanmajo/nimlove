
import ../nimlove

type Button = ref object
  x, y, width, height: int
  defaultTexture, hoverTexture: TextureAtlasTexture
  zoom: float
  text: string
  textWidth, textHeight: int

proc newButton*(defaultTexture, hoverTexture: TextureAtlasTexture,x:int,y:int, zoom: float = 1.0, text: string = ""): Button =
    result = new(Button)
    # todo check that both textures have the same size
    let (w1,h1) = defaultTexture.getTextureAtlasTextureSize()
    let (w2,h2) = hoverTexture.getTextureAtlasTextureSize()
    if w1 != w2 or h1 != h2:
        raise newException(Exception, "Both textures must have the same size")

    result.x = x
    result.y = y

    result.width = w1
    result.height = h1
    result.defaultTexture = defaultTexture
    result.hoverTexture = hoverTexture
    result.zoom = zoom
    result.text = text
    let (widthOfText,heightOfText) = nimlove.getTextSizeInPixel(result.text)
    result.textWidth = widthOfText
    result.textHeight = heightOfText

proc updateText*(self:var Button, text: string) = 
    self.text = text
    let (widthOfText,heightOfText) = nimlove.getTextSizeInPixel(self.text)
    self.textWidth = widthOfText
    self.textHeight = heightOfText

type ButtonState* = tuple[clickedRight: bool, hovered: bool, clickedLeft: bool, clickedMiddle: bool]

proc drawAndCollectInteraction*(self: Button): ButtonState =
    var state: ButtonState = (clickedRight: false, hovered: false, clickedLeft: false, clickedMiddle: false)
    if nimlove.mouseIsOver(self.x, self.y, (self.width.float * self.zoom).int, (self.height.float * self.zoom).int):
        self.hoverTexture.draw(self.x, self.y, self.zoom)
        state.hovered = true
        if nimlove.getMouseLeftClickThisFrame():
            state.clickedLeft = true
        if nimlove.getMouseRightClickThisFrame():
            state.clickedRight = true
        if nimlove.getMouseMiddleClickThisFrame():
            state.clickedMiddle = true
    else:
        self.defaultTexture.draw(self.x, self.y, self.zoom)
    let (widthOfText,heightOfText) = nimlove.getTextSizeInPixel(self.text)
    let buttonWidth = (self.width.float * self.zoom).int
    let buttonHeight = (self.height.float * self.zoom).int
    let xPositionRelativeToButton = (buttonWidth - widthOfText) / 2
    let yPositionRelativeToButton = (buttonHeight - heightOfText) / 2
    let xPosition = self.x.float + xPositionRelativeToButton
    let yPosition = self.y.float + yPositionRelativeToButton
    drawText("Button-Test", xPosition.int, yPosition.int)
    return state