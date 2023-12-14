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

let atlas = newImage("explosion.png")

let explosion_frames: seq[TextureAtlasTexture] = block:
  var f: seq[TextureAtlasTexture] = @[]
  f.add readLineOfTextureAtlas(fromImage=atlas,num=4,widthPX=400,heigthPX=400, rowNumber=0, startPosition = 0)
  f.add readLineOfTextureAtlas(fromImage=atlas,num=4,widthPX=400,heigthPX=400, rowNumber=1, startPosition = 0)
  f.add readLineOfTextureAtlas(fromImage=atlas,num=4,widthPX=400,heigthPX=400, rowNumber=2, startPosition = 0)
  f.add readLineOfTextureAtlas(fromImage=atlas,num=4,widthPX=400,heigthPX=400, rowNumber=3, startPosition = 0)
  f

# 4 x 4
# means 400 px per frame
var animation = newAnimation(
  frames=explosion_frames,
  frameTime=1/16,
  loop=true
)

let zombieAndSkeleton = newImage("ded.png")
# 9 x 4
# 288 - 256
# 256 / 4 = 64
# 288 / 9 = 32
echo zombieAndSkeleton.width,"x", zombieAndSkeleton.height

let zombie_walk = readLineOfTextureAtlas(fromImage=zombieAndSkeleton,num=3,widthPX=32,heigthPX=64, rowNumber=0, startPosition = 0)
let skeleton_walk = readLineOfTextureAtlas(fromImage=zombieAndSkeleton,num=6,widthPX=32,heigthPX=64, rowNumber=1, startPosition = 3)

var zombieAnimation = newAnimation(
  frames=zombie_walk,
  frameTime=1/3,
  loop=true
)

var skeletonAnimation = newAnimation(
  frames=skeleton_walk,
  frameTime=1/6,
  loop=true
)


var z_pos = 400.0


nimlove.runProgramm proc(delta_time: float) =
  animation.draw(x=0,y=0)
  zombieAnimation.draw(x=0,y=400)
  skeletonAnimation.draw(x=z_pos.int,y=400,2)
  z_pos -= 40 * delta_time
  progress(animation=animation,delta_time=delta_time)
  progress(animation=zombieAnimation,delta_time=delta_time)
  progress(animation=skeletonAnimation,delta_time=delta_time)