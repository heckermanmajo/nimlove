import ../../src/nimlove as nimlove
import ../../src/nimlove/[sound,image, text]
import std/random
#import std/sequtils

echo nimlove.ABSOLUTE_PATH

const WindowWidth = 1900
const WindowHeight = 1200

nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "NimLove",
  fullScreen = false,
)

nimlove.setDelayCPUWaste false # max fps

var song = newSound("song.ogg")
discard song.play()

let testImage: Image = newImage("mob.png")
var pos_x = 100.0
var angle = 0.0

type SimpleObject = ref object
  x: float
  y: float
  width: float
  height: float
  angle: float
  image: Image

var objects: seq[SimpleObject] = @[]

for i in 0..4000:
  objects.add SimpleObject(
    x : rand(0..(WindowWidth-testImage.width)).float,
    y : rand(0..(WindowHeight-testImage.height)).float,
    width : testImage.width.float,
    height : testImage.height.float,
    angle : rand(0..360).float,
    image : testImage
  )

proc draw(self: SimpleObject) =
  self.image.draw(
    x=self.x.int,
    y=self.y.int,
    width=self.width.int,
    height=self.height.int,
    angle=self.angle
  )

proc rotate(self: SimpleObject, deltaTime: float) =
  self.angle += 45.0 * deltaTime
  if self.angle > 360.0:
    self.angle -= 360.0

proc slow_moving(self: SimpleObject, deltaTime: float) =
  self.x += 77.0 * deltaTime
  if self.x > WindowWidth.float:
    self.x = 0.0
  self.y += 77.0 * deltaTime
  if self.y > WindowHeight.float:
    self.y = 0.0

proc changeSize(self: SimpleObject, deltaTime: float) =
  self.width += 77.0 * deltaTime
  if self.width > 300.0:
    self.width = 0.0
  self.height += 77.0 * deltaTime
  if self.height > 300.0:
    self.height = 0.0

proc onUpdate(deltaTime: float) =
  testImage.draw 0, 0
  testImage.draw(
    x=pos_x,
    y=100,
    width=100,
    height=100,
    angle=angle
  )


  if getFPS() > 60 and false:
    let max = (100 * deltaTime).int
    for i in 0..max:
      objects.add SimpleObject(
        x : rand(0..(WindowWidth-testImage.width)).float,
        y : rand(0..(WindowHeight-testImage.height)).float,
        width : testImage.width.float,
        height : testImage.height.float,
        angle : rand(0..360).float,
        image : testImage
      )


  for obj in objects:
    obj.draw()
    obj.rotate(deltaTime)
    obj.slow_moving(deltaTime)
    obj.changeSize(deltaTime)

  drawText 500, 0, $objects.len, color=Red
  let speed = 77.0
  #if isDown "left":
  #  testImage.x -= speed * deltaTime
  pos_x += speed * deltaTime
  angle += 45.0 * deltaTime
  if angle > 360.0:
    angle -= 360.0
  drawText 180, 180, $deltaTime, color=Red

proc onKeyDown(key: NimLoveKey) =
  echo "keyDown: ", $key
  # cnvert int to string via ascii

nimlove.runProgramm(onUpdate, onKeyDown)
