##[

  Pixel-Example for NimLove.

  - Manipulate Pixels in an Image

]##
import ../../src/nimlove as nimlove
import ../../src/nimlove/[image]

const WindowWidth = 800
const WindowHeight = 600

nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "NimLove",
  fullScreen = false,
)

# 8 x 8 px wide image
var editableImage:EditableImage = newEditableImage("color_test.png")
let noChange = newImage("color_test.png")

echo "get the first pixel"
let pv1:PixelValue  = editableImage.getPixel(0,0)
echo pv1

for y in 0..(editableImage.height-1):
  for x in 0..(editableImage.width-1):
    let pv:PixelValue  = editableImage.getPixel(x,y)
    echo $x & $y & " " & $pv


# set the first pixel to red
let pv = PixelValue(r:255,g:255,b:255,a:255)
echo pv
editableImage.setPixel(0,0, pv)
editableImage.setPixel(1,1, pv)
editableImage.setPixel(2,2, PixelValueRed)
editableImage.setPixel(3,3, PixelValueBlue)
editableImage.setPixel(4,4, PixelValueGreen)
editableImage.setPixel(5,5, PixelValueBlack)
editableImage.setPixel(5,5, PixelValue(r:255,g:255,b:255,a:100))
echo editableImage.getPixel(0,0)
echo editableImage.getPixel(1,1)
echo editableImage.getPixel(2,2)
echo editableImage.getPixel(3,3)
echo editableImage.getPixel(4,4)

editableImage.replaceColor(PixelValue(r:255,g:255,b:255,a:255), PixelValueRed)
editableImage.replaceColor(PixelValue(r:0,g:0,b:0,a:255), PixelValueBlue)

let i = editableImage.makeImageFromEImage

nimlove.runProgramm(
  onUpdate= proc(deltaTime: float) =
    i.draw(0,0, 400, 400)
    noChange.draw(400,0, 400, 400)
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
