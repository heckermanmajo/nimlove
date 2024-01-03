## RTS1-PROTOGAME
## 
## This is a veyr simple rts-example or units shooting at each other.
## 
import std/[strformat, json]
import  ../../../src/nimlove
import  ../../../src/nimlove/[image, map, button, text, camera, idobject]

nimlove.setupNimLove(
  windowWidth = 1900,
  windowHeight = 1200,
  windowTitle = "NimLove - empty game test",
  fullScreen = false,
)

# LOAD ASSETS
var teamBlueAtlasTextureRaw: EditableImage = newEditableImage("assets/soldier.png")
teamBlueAtlasTextureRaw.replaceColor(PixelValueRed, PixelValueBlue)
teamBlueAtlasTextureRaw.replaceColor(PixelValueIgnorePink, PixelValueTransparent)
var teamRedAtlasTextureRaw: EditableImage = newEditableImage("assets/soldier.png")
teamRedAtlasTextureRaw.replaceColor(PixelValueIgnorePink, PixelValueTransparent)

#echo teamRedAtlasTextureRaw.getPixel(0,0)
#quit 0

var teamBlueTextureAtlas = teamBlueAtlasTextureRaw.makeImageFromEImage()
var teamRedTextureAtlas = teamRedAtlasTextureRaw.makeImageFromEImage()

let soldierTeamRedFrames: seq[TextureAtlasTexture] = block:
  var f: seq[TextureAtlasTexture] = @[]
  f.add readLineOfTextureAtlas(fromImage=teamRedTextureAtlas,num=6,widthPX=64,heigthPX=64, rowNumber=0, startPosition = 5)
  f

let walkRedFrames: seq[TextureAtlasTexture] = block:
  var f: seq[TextureAtlasTexture] = @[]
  f.add readLineOfTextureAtlas(fromImage=teamRedTextureAtlas,num=1,widthPX=64,heigthPX=64, rowNumber=0, startPosition = 5)
  f.add readLineOfTextureAtlas(fromImage=teamRedTextureAtlas,num=1,widthPX=64,heigthPX=64, rowNumber=0, startPosition = 7)
  f

var soldierTeamRedWalk = newAnimation(frames=walkRedFrames, frameTime=0.3, loop=true)

type SoldierFrames = ref object
    walking: seq[TextureAtlasTexture]
    walkingEliteSoldier: seq[TextureAtlasTexture]
    shooting: seq[TextureAtlasTexture]
    shootingEliteSoldier: seq[TextureAtlasTexture]
    dead1Sprite: TextureAtlasTexture
    dead2Sprite: TextureAtlasTexture
    dead3Sprite: TextureAtlasTexture
    dead4Sprite: TextureAtlasTexture
    deadBurnedSprite: TextureAtlasTexture
    burnedExplosionDeathSprite: TextureAtlasTexture
    explosionDeathSprite: TextureAtlasTexture

type Faction* = ref object
    id: Id[Faction]
    soldierFrames: SoldierFrames

type Collidable = concept 
    proc isActive(): bool
    proc canCollideWith(other: Collidable): bool
    proc getCollisionBox(): tuple[x:int, y:int, width:int, height:int]
    proc getCollisionType(): string ##\
      ## Collision types allow to check if I collide with te other object

type RtsUnit* = ref object
    id:Id[RtsUnit]
    x,y,speed,rotation: float
    width, height: int
    dead: bool
    currentTarget: Id[RtsUnit]
    animation: Animation
    myType: string

#proc newRtsUnit(x,y): RtsUnit =  

proc calculateCollisions(self: var RtsUnit) = discard


proc isDeleted*(self: RtsUnit): bool =
  return self.dead

proc setBackToUndeleted*(self: RtsUnit) =
  self.dead = false

proc updateEachFrame*(self: RtsUnit, deltaTime: float) =
  assert self.dead != true

proc `%`*(self: RtsUnit, other: RtsUnit): JsonNode =
    return % { 
        "id": %self.id,
        "x": %self.x,
        "y": %self.y,
        "speed": %self.speed,
        "rotation": %self.rotation,
        "dead": %self.dead,
        "currentTarget": %self.currentTarget,
    }


var RtsUnitContainer = idobject.IdObjectContainer[RtsUnit]()



nimlove.runProgramm(
  onUpdate= proc(deltaTime: float) = 
    soldierTeamRedWalk.progress(deltaTime)
    soldierTeamRedWalk.draw(100,100)
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
