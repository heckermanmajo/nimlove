## Nimlove 0.1
## 
## @Author:  Marvin Knapp-Tietz
## 
## Nimlove is a simple 2D game library for nim inspired by the love2d for lua.
## But it is much simpler.
## 
## If you want to go crazy use sdl2, but if you want get started quickly
## and do some fun game-dev in nim, nimlove is for you.
## 
## Its focus is simplicity and ease of use (and beeing fast if possible).
## 
## - make sure to have sdl2 installed on your system
## 

# TODO: comment everything
# TODO: add saving images 
# TODO: draw a pixel, line, rect, circle, triangle, procs
# TODO: add debug logs that can be turned on and off -> into a nimlove.log file
# TODO: set mutliple cursors
# TODO: load multiple fonts by string
 
# and the nim sdl2 wrapper installed
import sdl2 ## import the offical nim sdl2 wrapper package
import sdl2/[ttf, mixer, image] 

# import standard library modules -> they are part of the nim compiler
import std/[tables, os, strutils, options]

# defect is a special type of object that is used to throw exceptions
# defect can on some compiler settings not be catched -> it should crash the program
type SDLException* = object of Defect
  ## This exception is thrown when an SDL2 function fails.
  
type NimBrokenHeartError* = object of Defect
  ## This exception is thrown when nimlove has some internal errors
  ## f.e. the NimLoveContext is not initialized but a proc needs it

let ABSOLUTE_PATH* = os.getAppDir() & "/" ## \
  ## The absolute path to the directory of the executable. \
  ## This is neccecary to load images and fonts. Since
  ## all images and fonts are loaded from the directory of the executable.

template sdlFailIf*(condition: typed, reason: string) =
  # todo: learn more about templates, so we can describe this function
  if condition: raise SDLException.newException(
    reason & ", SDL error " & $getError()
  )


##############################################
#
# Colors
#
##############################################

type
  Color* = distinct int

const
  White* = Color 0xffffff
  Black* = Color 0
  Gold* = Color 0xffd700
  Orange* = Color 0xFFA500
  Blue* = Color 0x00FFFF
  Red* = Color 0xFF0000
  Yellow* = Color 0xFFFF00
  Pink* = Color 0xFF00FF
  Gray* = Color 0x808080
  Green* = Color 0x44FF44
  Deeppink* = Color 0xFF1493

proc toColor*(r, g, b: int): Color =
  assert r in 0..255
  assert g in 0..255
  assert b in 0..255
  result = Color (r shl 16) or (g shl 8) or b

proc toSdlColor*(x: Color): sdl2.Color {.inline.} =
  let x = x.int
  result = color(x shr 16 and 0xff, x shr 8 and 0xff, x and 0xff, 0)


##############################################
#
# Keys
#
##############################################

type NimLoveKey* = enum
  ## An enum that represents a key on the keyboard.
  ## Usually used on key events.
  KEY_A
  KEY_B
  KEY_C
  KEY_D
  KEY_E
  KEY_F
  KEY_G
  KEY_H
  KEY_I
  KEY_J
  KEY_K
  KEY_L
  KEY_M
  KEY_N
  KEY_O
  KEY_P
  KEY_Q
  KEY_R
  KEY_S
  KEY_T
  KEY_U
  KEY_V
  KEY_W
  KEY_X
  KEY_Y
  KEY_Z
  KEY_0
  KEY_1
  KEY_2
  KEY_3
  KEY_4
  KEY_5
  KEY_6
  KEY_7
  KEY_8
  KEY_9
  KEY_SPACE
  KEY_ESCAPE
  KEY_ARROW_UP
  KEY_ARROW_DOWN
  KEY_ARROW_LEFT
  KEY_ARROW_RIGHT
  KEY_CTRL
  KEY_SHIFT
  KEY_ALT
  KEY_TAB
  KEY_ENTER
  KEY_BACKSPACE
  KEY_CAPSLOCK
  KEY_F1
  KEY_F2
  KEY_F3
  KEY_F4
  KEY_F5
  KEY_F6
  KEY_F7
  KEY_F8
  KEY_F9
  KEY_F10
  KEY_F11
  KEY_F12
  KEY_DELETE
  KEY_INSERT
  KEY_UNKNOWN


proc sdlScancodeToNimLoveKeyEnum*(scancode: Scancode): NimLoveKey =
  case scancode
  of SDL_SCANCODE_A: KEY_A
  of SDL_SCANCODE_B: KEY_B
  of SDL_SCANCODE_C: KEY_C
  of SDL_SCANCODE_D: KEY_D
  of SDL_SCANCODE_E: KEY_E
  of SDL_SCANCODE_F: KEY_F
  of SDL_SCANCODE_G: KEY_G
  of SDL_SCANCODE_H: KEY_H
  of SDL_SCANCODE_I: KEY_I
  of SDL_SCANCODE_J: KEY_J
  of SDL_SCANCODE_K: KEY_K
  of SDL_SCANCODE_L: KEY_L
  of SDL_SCANCODE_M: KEY_M
  of SDL_SCANCODE_N: KEY_N
  of SDL_SCANCODE_O: KEY_O
  of SDL_SCANCODE_P: KEY_P
  of SDL_SCANCODE_Q: KEY_Q
  of SDL_SCANCODE_R: KEY_R
  of SDL_SCANCODE_S: KEY_S
  of SDL_SCANCODE_T: KEY_T
  of SDL_SCANCODE_U: KEY_U
  of SDL_SCANCODE_V: KEY_V
  of SDL_SCANCODE_W: KEY_W
  of SDL_SCANCODE_X: KEY_X
  of SDL_SCANCODE_Y: KEY_Y
  of SDL_SCANCODE_Z: KEY_Z
  of SDL_SCANCODE_0: KEY_0
  of SDL_SCANCODE_1: KEY_1
  of SDL_SCANCODE_2: KEY_2
  of SDL_SCANCODE_3: KEY_3
  of SDL_SCANCODE_4: KEY_4
  of SDL_SCANCODE_5: KEY_5
  of SDL_SCANCODE_6: KEY_6
  of SDL_SCANCODE_7: KEY_7
  of SDL_SCANCODE_8: KEY_8
  of SDL_SCANCODE_9: KEY_9
  of SDL_SCANCODE_SPACE: KEY_SPACE
  of SDL_SCANCODE_ESCAPE: KEY_ESCAPE
  of SDL_SCANCODE_UP: KEY_ARROW_UP
  of SDL_SCANCODE_DOWN: KEY_ARROW_DOWN
  of SDL_SCANCODE_LEFT: KEY_ARROW_LEFT
  of SDL_SCANCODE_RIGHT: KEY_ARROW_RIGHT
  of SDL_SCANCODE_LCTRL: KEY_CTRL
  of SDL_SCANCODE_RCTRL: KEY_CTRL
  of SDL_SCANCODE_LSHIFT: KEY_SHIFT
  of SDL_SCANCODE_RSHIFT: KEY_SHIFT
  of SDL_SCANCODE_LALT: KEY_ALT
  of SDL_SCANCODE_RALT: KEY_ALT
  of SDL_SCANCODE_TAB: KEY_TAB
  of SDL_SCANCODE_RETURN: KEY_ENTER
  of SDL_SCANCODE_BACKSPACE: KEY_BACKSPACE
  of SDL_SCANCODE_CAPSLOCK: KEY_CAPSLOCK
  of SDL_SCANCODE_F1: KEY_F1
  of SDL_SCANCODE_F2: KEY_F2
  of SDL_SCANCODE_F3: KEY_F3
  of SDL_SCANCODE_F4: KEY_F4
  of SDL_SCANCODE_F5: KEY_F5
  of SDL_SCANCODE_F6: KEY_F6
  of SDL_SCANCODE_F7: KEY_F7
  of SDL_SCANCODE_F8: KEY_F8
  of SDL_SCANCODE_F9: KEY_F9
  of SDL_SCANCODE_F10: KEY_F10
  of SDL_SCANCODE_F11: KEY_F11
  of SDL_SCANCODE_F12: KEY_F12
  of SDL_SCANCODE_DELETE: KEY_DELETE
  of SDL_SCANCODE_INSERT: KEY_INSERT
  else:
    echo "unknown key: ", $scancode
    KEY_UNKNOWN


##############################################
#
# NimLoveContext
#
##############################################


type NimLoveContext* = object of RootObj
  ## The NimLoveContext is the main object that
  ## is passed into the main loop of the program.
  ## It contains the renderer and window objects
  ## and provides some helper procedures.
  renderer*: RendererPtr
  window*: WindowPtr
  WindowWidth*: int
  WindowHeight*: int
  Title*: string
  font*: FontPtr


proc newNimLoveContext*(
  WindowWidth: int = 800,
  WindowHeight: int = 600,
  Title: string = "NimLove",
  fullScreen: bool = false,
): NimLoveContext =
  # todo: detailed comments
  result = NimLoveContext()
  result.WindowWidth = WindowWidth
  result.WindowHeight = WindowHeight
  result.Title = Title
  
  # image.init(IMG_INIT_PNG)
  result.window = createWindow(
    title = Title.cstring,
    x = SDL_WINDOWPOS_CENTERED,
    y = SDL_WINDOWPOS_CENTERED,
    w = WindowWidth.cint,
    h = WindowHeight.cint,
    flags = SDL_WINDOW_SHOWN
  )
  sdlFailIf result.window.isNil: "window could not be created"
  result.renderer =  createRenderer(
    window = result.window,
    index = -1,
    flags = Renderer_TargetTexture
  )
  # Renderer_Accelerated or Renderer_PresentVsync or
  sdlFailIf result.renderer.isNil: "renderer could not be created"
  sdlFailIf(not ttfInit()): "SDL_TTF initialization failed"
  result.renderer.setDrawColor toSdlColor(Color 0)
  clear(result.renderer)

  #setTitle(result.window, Title)
  if fullScreen:
    echo "Try to set game to fullscreen"
    discard setFullscreen(result.window, SDL_WINDOW_FULLSCREEN_DESKTOP) # todo: handle error

  # load the basic font
  var font = openFont(cstring(ABSOLUTE_PATH & "font.ttf"), 20)
  sdlFailIf font.isNil: "font could not be created"
  #close font
  result.font = font

  return result

var nimLoveContext: Option[NimLoveContext] = NimLoveContext.none ## \
    ## The NimLoveContext is a global variable that is initialized by the \
    ## setupNimLove() proc. It is used by the other procs to access the \
    ## SDL2 context. It is not exported -> lack of asterisk.
    ## This way we hide the SDL2 context from the user and make it easier \
    ## to use the library.

proc getNimLoveContext*(): NimLoveContext =
  ## Returns the NimLoveContext. If the NimLoveContext is not initialized \
  ## it throws a NimBrokenHeartError.
  ## This proc is used to access the NimLoveContext from other procs.
  if not nimLoveContext.isSome:
    raise NimBrokenHeartError.newException(
      "NimLoveContext not initialized. Call setupNimLove() first."
    )
  return nimLoveContext.get

# https://stackoverflow.com/questions/33393528/how-to-get-screen-size-in-sdl

proc setupNimLove*(
    windowWidth: int = 800,
    windowHeight: int = 600,
    windowTitle: string = "NimLove",
    fullScreen: bool = false,
  ) =
  # set global nimLoveContext
  echo "setupNimLove"
  nimLoveContext = newNimLoveContext(
    WindowWidth = windowWidth,
    WindowHeight = windowHeight,
    Title = windowTitle,
    fullScreen = fullScreen,
  ).some


##############################################
#
# Init SDL2
#
##############################################

sdlFailIf(not sdl2.init(INIT_EVERYTHING)): "SDL2 initialization failed"

## audio values 
# todo: comment
var audio_rate : cint
var audio_format : uint16
var audio_buffers : cint    = 4096
var audio_channels : cint   = 2

sdlFailIf(
  mixer.openAudio(audio_rate, audio_format, audio_channels, audio_buffers) != 0,
  "Could not open audio"
)


##############################################
#
# Internal running values
#
##############################################

var keepRunning = true ## \
  ## Set to false to stop the main loop of the program.\
  ## Global variable used in the runProgramm() proc. \
  ## Not exported -> lack of asterisk.

proc killTheProgram*() =
  ## Stops the main loop of the program and therefore the program itself.
  keepRunning = false

var fps = 0.0 ## The actual Frames Per Second in the last second.
var time_in_ms = 0.0 ## The time in milliseconds since the last second.
var frame_counter = 0 ## The number of frames since the last second.
proc getFPS*(): float =
  ## Returns the current FPS of the program.
  ## calculated by the runProgramm() proc -> main loop
  return fps

var thisFrameWasTenthOfASecond : int = 0  ## from 1 to 10

var delayCPUWaste = true
proc setDelayCPUWaste*(value: bool) =
  ## This makes the program wait for on milisecond after each frame
  ## IF the FPS is higher than 200. This is to prevent the program
  ## from using 100% CPU for no work.
  delayCPUWaste = value

var sleptMilisecondsPerSecond = 0.0
var sleptMilisecondsPerSecondCounter = 0
proc getSleptMilisecondsPerSecond*(): float =
  ## Returns the number of miliseconds the program slept in the last second.
  ## @see setDelayCPUWaste()
  return sleptMilisecondsPerSecond


var mouseX, mouseY: int = 0
var mouseRightClickThisFrame: bool = false
var mouseLeftClickThisFrame: bool = false
var mouseMiddleClickThisFrame: bool = false
var mouseScrollUpThisFrame: bool = false
var mouseScrollDownThisFrame: bool = false

proc getMouseX*(): int = return mouseX
proc getMouseY*(): int = return mouseY
proc getMouseRightClickThisFrame*(): bool = return mouseRightClickThisFrame
proc getMouseLeftClickThisFrame*(): bool = return mouseLeftClickThisFrame
proc getMouseMiddleClickThisFrame*(): bool = return mouseMiddleClickThisFrame
proc getMouseScrollUpThisFrame*(): bool = return mouseScrollUpThisFrame
proc getMouseScrollDownThisFrame*(): bool = return mouseScrollDownThisFrame

proc mouseIsOver*(x: int, y: int, width: int, height: int): bool =
  ## Returns true if the mouse is over the given rectangle.
  return mouseX >= x and mouseX <= x + width and mouseY >= y and mouseY <= y + height

##############################################
#
# Fonts
#
##############################################

var fonts: tables.Table[string, FontPtr] = initTable[string, FontPtr]() ##\
  ## All loaded fonts.

proc loadFont*(path: string, name: string, size: int = 10) =
  ## Loads a font from a file and stores it in the fonts table.
  ## Returns the loaded font.
  let nimLoveContext = getNimLoveContext()
  let font = openFont(cstring(ABSOLUTE_PATH & "font.ttf"), 20)
  sdlFailIf font.isNil: "font could not be created"
  fonts[name] = font

proc fontExists(name: string): bool =
  ## Returns true if a font with the given name exists.
  return fonts.hasKey(name)

proc drawText*(x: int, y: int, text: string, size: int = 10, color: Color = White) =
  # todo: preload fonts of different sizes - this increases performance big time
  ## deprecated: use drawText() beneath instead
  let nimLoveContext = getNimLoveContext()
  let surface = ttf.renderUtf8Solid(nimLoveContext.font, text, toSdlColor color)
  let texture = nimLoveContext.renderer.createTextureFromSurface(surface)
  var d: Rect
  d.x = cint x
  d.y = cint y
  queryTexture(texture, nil, nil, addr(d.w), addr(d.h))
  nimLoveContext.renderer.copy texture, nil, addr d
  surface.freeSurface
  texture.destroy

let DEFAULT_FONT = ""

proc drawText*(text: string, x: int, y: int, fontName:string=DEFAULT_FONT, color: Color = White) =
  let nimLoveContext = getNimLoveContext()
  let fontToUse = if fontName == DEFAULT_FONT: nimLoveContext.font else: fonts[fontName]
  let surface = ttf.renderUtf8Solid(fontToUse, text, toSdlColor color)
  let texture = nimLoveContext.renderer.createTextureFromSurface(surface)
  var d: Rect
  d.x = cint x
  d.y = cint y
  queryTexture(texture, nil, nil, addr(d.w), addr(d.h))
  nimLoveContext.renderer.copy texture, nil, addr d
  surface.freeSurface
  texture.destroy

type Width = int
type Height = int

proc getTextSizeInPixel*(text: string): (Width, Height) =
  # int TTF_SizeText(TTF_Font *font, const char *text, int *w, int *h)
  let nimLoveContext = getNimLoveContext()
  var w, h: cint
  let res = sizeText(nimLoveContext.font, text.cstring, addr w, addr h)
  sdlFailIf res != 0, "could not get text size"
  return (w.int, h.int)

proc displayDebugInfo*() = 
  drawText("FPS: " & $getFPS(), 0, 0)
  drawText("Slept ms: " & $getSleptMilisecondsPerSecond(), 0, 20)
  drawText("Mouse: " & $getMouseX() & ", " & $getMouseY(), 0, 40)

##############################################
#
# Image, TextureAtlasTexture, Animation
#
##############################################

type NimLoveImage* = ref object
  ## Simple image object that can be passed into
  ## the draw procedures and will be drawn on the
  ## screen.
  # todo: add source file name
  texture: TexturePtr
  width: int
  height: int

proc newNimLoveImage*(relativePath: string): NimLoveImage =
  ## Create a new NimLoveImage from a file (must be png).
  let nimLoveContext = getNimLoveContext()
  if not relativePath.endsWith(".png"):
    raise newException(NimBrokenHeartError, "Images must be png files.")
  result = NimLoveImage()
  let surface = load((ABSOLUTE_PATH & relativePath).cstring)
  result.width = surface.w.int
  result.height = surface.h.int
  sdlFailIf surface.isNil: "could not load image " & ABSOLUTE_PATH & relativePath
  result.texture = nimLoveContext.renderer.createTextureFromSurface(surface)
  sdlFailIf result.texture.isNil: "could not create texture from image " & relativePath
  surface.freeSurface

  # add the created image to resource manager 

  return result

proc width*(image: NimLoveImage): int = return image.width
proc height*(image: NimLoveImage): int = return image.height

proc draw*(
  image: NimLoveImage,
  x: int|float,
  y: int|float,
  width: int = 0,
  height: int = 0,
  angle: float = 0.0,
  zoom: float = 1.0,
  alpha: int = 255, # not implemented yet
  start_drawing_x: int = 0,
  start_drawing_y: int = 0,
  end_drawing_x: int = 0,
  end_drawing_y: int = 0
) =
  # todo: just drawing tiles can be achived easier than this
  #       so create a special proc for that
  let nimLoveContext = getNimLoveContext()
  var d: Rect
  d.x =  cint x
  d.y =  cint y
  d.w =  if width == 0: image.width.cint else: cint width
  d.h =  if height == 0: image.height.cint else: cint height

  assert d.w > 0 and d.h > 0, "width and height must be > 0"
  assert zoom > 0.3, "zoom must be > 0.0"
  assert zoom < 4.0, "zoom must be < 10.0"
  assert angle >= 0.0 and angle <= 360.0, "angle must be between 0.0 and 360.0"

  if zoom != 1.0:
    d.w = (d.w.float * zoom).cint
    d.h = (d.h.float * zoom).cint

  var imagePartRect: Rect ##  display only part of the image
  imagePartRect.x = if start_drawing_x == 0: 0 else: cint start_drawing_x
  imagePartRect.y = if start_drawing_y == 0: 0 else: cint start_drawing_y
  imagePartRect.w = if end_drawing_x == 0: image.width.cint else: cint end_drawing_x
  imagePartRect.h = if end_drawing_y == 0: image.height.cint else: cint end_drawing_y

  # apply alpha blend mode

  nimLoveContext.renderer.copyEx image.texture, addr imagePartRect, addr d, angle.cdouble, nil, SDL_FLIP_NONE

type TextureAtlasTexture* = ref object
  ## A texture that is part of a texture atlas.
  ## if you pass in this into the draw procedures
  ## it will be drawn on the screen.
  image: NimLoveImage
  textureStartX: int
  textureStartY: int
  textureWidth: int
  textureHeight: int

proc getTextureAtlasTextureSize*(tat: TextureAtlasTexture): (int, int) =
  return (tat.textureWidth, tat.textureHeight)

proc newTextureAtlasTexture*(
  image: NimLoveImage,
  textureStartX: int,
  textureStartY: int,
  textureWidth: int,
  textureHeight: int
): TextureAtlasTexture =
  ## Create a new texture atlas texture.
  var result = TextureAtlasTexture()
  result.image = image
  # todo: check if the texture is big enough
  if textureStartX < 0 or textureStartY < 0 or textureWidth < 0 or textureHeight < 0:
    raise newException(NimBrokenHeartError, "Texture atlas texture parameters must be positive.")
  if textureStartX + textureWidth > image.width or textureStartY + textureHeight > image.height:
    raise newException(NimBrokenHeartError, "Texture atlas texture parameters must be smaller than the image.")
  result.textureStartX = textureStartX
  result.textureStartY = textureStartY
  result.textureWidth = textureWidth
  result.textureHeight = textureHeight
  return result

proc draw*(tat: TextureAtlasTexture, x: int,y: int, zoom: float = 1, angle: float = 0) =
  ## Render the texture atlas texture on the screen.
  draw tat.image, x, y, tat.textureWidth, tat.textureHeight, angle, zoom, 255, tat.textureStartX, tat.textureStartY, tat.textureWidth, tat.textureHeight

type Animation = ref object
  ## This is the animation object that is mapped 1:1 to the
  ## animated game object.
  frames: seq[TextureAtlasTexture]
  currentFrame: int
  frameTime: float
  currentFrameTime: float
  loop: bool

proc newAnimation*(
  frames: seq[TextureAtlasTexture],
  frameTime: float = 0.25,
  loop: bool = true
): Animation =
  ## Create a new animation object.
  var result = Animation()
  result.frames = frames
  result.currentFrame = 0
  result.frameTime = frameTime
  result.currentFrameTime = 0.0
  result.loop = loop
  return result

proc draw*(animation: Animation, x: int, y: int, zoom: float = 1, angle: float = 0) =
  ## Display the current frame of the animation.
  #echo "drawing frame ", animation.currentFrame
  draw animation.frames[animation.currentFrame], x, y, zoom, angle

proc progress*(animation: var Animation, delta_time: float) =
  assert animation.frames.len > 0
  animation.currentFrameTime += delta_time
  if animation.currentFrameTime > animation.frameTime:
    animation.currentFrameTime -= animation.frameTime
    animation.currentFrame += 1
    if animation.currentFrame >= animation.frames.len:
      if animation.loop:
        animation.currentFrame = 0
      else:
        animation.currentFrame = animation.frames.len - 1
  if animation.currentFrame > animation.frames.len - 1:
    animation.currentFrame = animation.frames.len - 1


proc readLineOfTextureAtlas*(
  fromImage: NimLoveImage,
  num: int,
  widthPX: int,
  heigthPX: int,
  rowNumber: int = 0,
  startPosition: int = 0
  ): seq[TextureAtlasTexture] =
  var result: seq[TextureAtlasTexture] = @[]
  for i in 0..num-1:
    result.add(
      newTextureAtlasTexture(
        fromImage,
        i*widthPX + startPosition * widthPX,
        rowNumber*heigthPX,
        widthPX,
        heigthPX
      )
    )
  return result

##############################################
#
#
#
# Edit Pixels
#
#
#
##############################################


type EditableImage* = ref object
  ## Image that can be edited. It cannot be drawn directly but can be
  ## converted to a NimLoveImage via the makeNormalImage() proc.
  surface: SurfacePtr ## the sdl2 surface -> the data of the image
  width: int ## width: int of the image, cannot be changed
  height: int ## height: int of the image, cannot be changed

proc width*(eImage: EditableImage): int = return eImage.width
proc height*(eImage: EditableImage): int = return eImage.height

proc newEditableImage*(relativePath: string): EditableImage =
  ## Create a new editable image from a file.
  ## The path is relative to the executable.
  let nimLoveContext = getNimLoveContext()
  result = EditableImage()
  if not relativePath.endsWith(".png"):
    raise newException(NimBrokenHeartError, "Editable images must be png files.")
  let surface = load((ABSOLUTE_PATH & relativePath).cstring)
  result.width = surface.w.int
  result.height = surface.h.int
  sdlFailIf surface.isNil: "could not load image " & ABSOLUTE_PATH & relativePath
  result.surface = surface

type PixelValue* = object
  ## A pixel value is a color with an alpha value.
  ## It is used to set and get pixels of an EditableImage.
  r*, g*, b*, a*: uint8

proc toUint32*(self: PixelValue): uint32 =
  return (self.r.uint32 shl 16) or (self.g.uint32 shl 8) or self.b.uint32

let 
  PixelValueRed* = PixelValue(r : 255, g: 0, b: 0, a: 255)
  PixelValueGreen* = PixelValue(r : 0, g: 255, b: 0, a: 255)
  PixelValueBlue* = PixelValue(r : 0, g: 0, b: 255, a: 255)
  PixelValueBlack* = PixelValue(r : 0, g: 0, b: 0, a: 255)
  PixelValueWhite* = PixelValue(r : 255, g: 255, b: 255, a: 255)
  PixelValueYellow* = PixelValue(r : 255, g: 255, b: 0, a: 255)
  PixelValuePink* = PixelValue(r : 255, g: 0, b: 255, a: 255)
  PixelValueGray* = PixelValue(r : 128, g: 128, b: 128, a: 255)
  PixelValueOrange* = PixelValue(r : 255, g: 165, b: 0, a: 255)
  PixelValueGold* = PixelValue(r : 255, g: 215, b: 0, a: 255)
  PixelValueDeepPink* = PixelValue(r : 255, g: 20, b: 147, a: 255)
  PixelValueBlueViolet* = PixelValue(r : 138, g: 43, b: 226, a: 255)
  PixelValueDarkBlue* = PixelValue(r : 0, g: 0, b: 139, a: 255)
  PixelValueDarkGreen* = PixelValue(r : 0, g: 100, b: 0, a: 255)
  PixelValueDarkRed* = PixelValue(r : 139, g: 0, b: 0, a: 255)
  PixelValueDarkOrange* = PixelValue(r : 255, g: 140, b: 0, a: 255)
  # todo: add more colors

proc `$`*(self: PixelValue): string =
  return "pv(" & $self.r & ", " & $self.g & ", " & $self.b & "; " & $self.a & ")"

proc setPixel*(eImage: var EditableImage, x, y: int, pixelValue: PixelValue) =
  ## Set a pixel of an EditableImage to the given PixelValue.
  let nimLoveContext = getNimLoveContext()
  let surface: ptr Surface = eImage.surface
  let pixelCast = (cast[ptr PixelFormat](surface.format))
  # echo getPixelFormatName(cast[uint32](surface.format))
  let bytesPerPixel: int = pixelCast.BytesPerPixel.int
  assert bytesPerPixel == 4
  assert pixelCast.BitsPerPixel.int == 32
  let pixelOffset: int = y * surface.pitch + x * bytesPerPixel

  let pixelAddress: ptr uint8 = cast[ptr uint8](cast[int](cast[ptr uint8](surface.pixels)) + pixelOffset)
  let pixelAddress2: ptr uint32 = cast[ptr uint32](pixelAddress)
  let format: uint32 = sdl2.getPixelFormat( nimLoveContext.window );
  # TODO: THIS CAN CAUSE HARM
  let mappingFormat: ptr PixelFormat = sdl2.allocFormat( SDL_PIXELFORMAT_ABGR8888 );
  # TODO: It is the bad format, since it "removes the right pixels at the right place but they are just empty"
  discard sdl2.lockSurface(eImage.surface)
  pixelAddress2[] = sdl2.mapRGBA( 
    format=mappingFormat, 
    r=pixelValue.r, #0xFF, 
    g=pixelValue.g, #0xFF, 
    b=pixelValue.b, #0xFF,
    a=pixelValue.a #0xFF
  )
  
  sdl2.unlockSurface(eImage.surface)

proc getPixel*(eImage: EditableImage, x, y: int): PixelValue =
  ## Get the PixelValue of a pixel of an EditableImage.
  let nimLoveContext = getNimLoveContext()
  let surface: ptr Surface = eImage.surface
  let format: uint32 = sdl2.getPixelFormat( nimLoveContext.window );
  #echo getPixelFormatName(format)

  #[if format == SDL_PIXELFORMAT_RGB888:
    echo "SDL_PIXELFORMAT_RGB888"
  elif format == SDL_PIXELFORMAT_RGBA8888:

    echo "SDL_PIXELFORMAT_RGBA8888"
  elif format == SDL_PIXELFORMAT_ABGR8888:

    echo "SDL_PIXELFORMAT_ABGR8888"
  elif format == SDL_PIXELFORMAT_BGRA8888:

    echo "SDL_PIXELFORMAT_BGRA8888"
  else:
    echo "unknown format: ", format  
    ]#

  let mappingFormat: ptr PixelFormat = sdl2.allocFormat( format );
  let pixelCast = (cast[ptr PixelFormat](surface.format))
  let bytesPerPixel: int = pixelCast.BytesPerPixel.int
  let pixelOffset: int = y * surface.pitch.int + x * bytesPerPixel
  let pixelAddress: ptr uint8 = cast[ptr uint8](cast[int](surface.pixels) + pixelOffset)
  let pixelAddress2: ptr uint32 = cast[ptr uint32](pixelAddress)
  let pixelValue: uint32 = pixelAddress2[]
  #echo "pixelValue: ", pixelValue
 
  #[
    proc getPixelFormatName*(format: uint32): cstring {.
  importc: "SDL_GetPixelFormatName".}
  ]#
  var r,g,b,a: uint8
  sdl2.getRGBA(pixelValue.uint32, mappingFormat, r, g, b, a)
  result = PixelValue()
  result.r = r
  result.g = g
  result.b = b
  result.a = a
  echo result
  return result

proc replaceColor*(eImage: var EditableImage, oldColor: PixelValue, newColor: PixelValue) =
  ## Replace all pixels of an EditableImage that have the oldColor with the newColor.
  let nimLoveContext = getNimLoveContext()
  for y in 0..eImage.height-1:
    for x in 0..eImage.width-1:
      if getPixel(eImage, x, y) == oldColor:
        setPixel(eImage, x, y, newColor)


proc makeNormalImage*(eImage: EditableImage): NimLoveImage =
  let nimLoveContext = getNimLoveContext()
  result = NimLoveImage()
  result.width = eImage.width
  result.height = eImage.height
  result.texture = nimLoveContext.renderer.createTextureFromSurface(eImage.surface)
  sdlFailIf result.texture.isNil: "could not create texture from edtiable image "

#proc replaceColor(image: NimLoveImage, oldColor: Color, newColor: Color): NimLoveImage =




  


##############################################
#
# Sound
#
##############################################

type NimLoveSound* = object
  soundFilePointerOgg: MusicPtr
  soundFilePointerWav: ChunkPtr
  soundFileType: string

# mixer.freeChunk(sound) #clear wav
#mixer.freeMusic(sound2) #clear ogg
#mixer.closeAudio()

proc newNimLoveSound*(filename: string): NimLoveSound =
  let nimLoveContext = getNimLoveContext() #  not used yet
  result = NimLoveSound()
  let path = ABSOLUTE_PATH & filename
  if filename.endsWith(".wav"):
    # todo: check that file exists
    # todo: use absolute path and remnid that file needs to be in the same folder as the executable
    result.soundFileType = "wav"
    result.soundFilePointerWav = mixer.loadWAV(path.cstring())
    if isNil(result.soundFilePointerWav):
      raise NimBrokenHeartError.newException("Unable to load sound file (.wav), error occured while loading")
  elif filename.endsWith(".ogg"):
    # todo: check that file exists
    # todo: use absolute path and remnid that file needs to be in the same folder as the executable
    result.soundFileType = "ogg"
    result.soundFilePointerOgg = mixer.loadMUS(path.cstring())
    if isNil(result.soundFilePointerOgg):
      raise NimBrokenHeartError.newException("Unable to load sound file (.ogg), error occured while loading: " & path)
  else:
    raise NimBrokenHeartError.newException("Unable to load sound file, only wav and ogg are supported")


proc play*(sound: NimLoveSound): cint =
  let nimLoveContext = getNimLoveContext() #  not used yet
  if sound.soundFileType == "wav":
    result = mixer.playChannel(-1.cint, sound.soundFilePointerWav, 0.cint)
  elif sound.soundFileType == "ogg":
    result = mixer.playMusic(sound.soundFilePointerOgg, 0.cint)
  else:
    raise NimBrokenHeartError.newException("Unable to play sound file, only wav and ogg are supported")
  if result == -1:
    raise NimBrokenHeartError.newException("Unable to play sound file, error occured while playing")

# If we focus for example a text-field, other 
# handler should not consume the input event
# these functions help to manage input in case 
# of ui
var currentKeyEventWasConsumedVar = false
var currentMouseEventWasConsumedVar = false
proc setCurrentKeyEventAsConsumed*() =
  currentKeyEventWasConsumedVar = false
proc setCurrentMouseEventAsConsumed*() =
  currentMouseEventWasConsumedVar = true
proc currentKeyEventWasConsumed*(): bool =
  return currentKeyEventWasConsumedVar
proc currentMouseEventWasConsumed*(): bool =
  return currentMouseEventWasConsumedVar




##############################################
#
# MAIN - LOOP
#
##############################################

proc runProgramm*(
  onUpdate: proc(deltaTime: float) {.closure.},
  onKeyDown: proc(key: NimLoveKey) {.closure.} = proc(key: NimLoveKey) = discard,
  onKeyUp: proc(key: NimLoveKey) {.closure.} = proc(key: NimLoveKey) = discard,
  onMouseDown: proc(x, y: int) {.closure.} = proc(x, y: int) = discard,
  onMouseUp: proc(x, y: int) {.closure.} = proc(x, y: int) = discard,
  onMouseMove: proc(x, y: int) {.closure.} = proc(x, y: int) = discard,
  onMouseScrollUp: proc() {.closure.} = proc() = discard,
  onMouseScrollDown: proc() {.closure.} = proc() = discard,
  onQuit: proc() {.closure.} = proc() = discard,
) =
  ## Runs the main loop of the program and calls the callback-procs that are passed in
  ##
  # todo: document each callback proc

  let nimLoveContext = getNimLoveContext()
  var now = getTicks()
  thisFrameWasTenthOfASecond = 1 #  start the system with 1
  while keepRunning:

    # calculate fps
    frame_counter += 1
    time_in_ms += (getTicks() - now).float
    if time_in_ms > 100 and thisFrameWasTenthOfASecond == 1:
      thisFrameWasTenthOfASecond = 2
    elif time_in_ms > 200 and thisFrameWasTenthOfASecond == 2:
      thisFrameWasTenthOfASecond = 3
    elif time_in_ms > 300 and thisFrameWasTenthOfASecond == 3:
      thisFrameWasTenthOfASecond = 4
    elif time_in_ms > 400 and thisFrameWasTenthOfASecond == 4:
      thisFrameWasTenthOfASecond = 5
    elif time_in_ms > 500 and thisFrameWasTenthOfASecond == 5:
      thisFrameWasTenthOfASecond = 6
    elif time_in_ms > 600 and thisFrameWasTenthOfASecond == 6:
      thisFrameWasTenthOfASecond = 7
    elif time_in_ms > 700 and thisFrameWasTenthOfASecond == 7:
      thisFrameWasTenthOfASecond = 8
    elif time_in_ms > 800 and thisFrameWasTenthOfASecond == 8:
      thisFrameWasTenthOfASecond = 9
    elif time_in_ms > 900 and thisFrameWasTenthOfASecond == 9:
      thisFrameWasTenthOfASecond = 10
    elif time_in_ms < 100 and thisFrameWasTenthOfASecond == 10:
      thisFrameWasTenthOfASecond = 1

    if time_in_ms >= 1000.0:
      fps = frame_counter.float / (time_in_ms / 1000.0)
      time_in_ms = 0.0
      frame_counter = 0

    let newNow = getTicks()
    let deltaTime = (newNow - now).float / 1000.0
    now = newNow

    mouseRightClickThisFrame = false
    mouseLeftClickThisFrame = false
    mouseMiddleClickThisFrame = false
    mouseScrollUpThisFrame = false
    mouseScrollDownThisFrame = false

    var event = defaultEvent
    while pollEvent(event):

      case event.kind

        of QuitEvent:
          keepRunning = false
          break

        of KeyDown:
          currentKeyEventWasConsumedVar = false
          onKeyDown(sdlScancodeToNimLoveKeyEnum(event.key.keysym.scancode))
          if event.key.keysym.scancode == SDL_SCANCODE_ESCAPE:
            keepRunning = false
            break
          #if event.key.keysym.scancode == SDL_SCANCODE_A:
          #  echo "A pressed"
          #  break

        of KeyUp:
          # echo "key up"
          currentKeyEventWasConsumedVar = false
          onKeyUp(sdlScancodeToNimLoveKeyEnum(event.key.keysym.scancode)) 

        # paste?
        of TextInput:
          # echo "text input"
          echo event.text.text
        
        of MouseButtonDown:
          currentMouseEventWasConsumedVar = false
          onMouseDown(event.button.x, event.button.y)
          if event.button.button == sdl2.BUTTON_RIGHT: mouseRightClickThisFrame = true
          if event.button.button == sdl2.BUTTON_LEFT: mouseLeftClickThisFrame = true
          if event.button.button == sdl2.BUTTON_MIDDLE: mouseMiddleClickThisFrame = true

        of MouseButtonUp:
          currentMouseEventWasConsumedVar = false
          onMouseUp(event.button.x, event.button.y)

        of MouseMotion:
          currentMouseEventWasConsumedVar = false
          onMouseMove(event.motion.x, event.motion.y)
          mouseX = event.motion.x
          mouseY = event.motion.y

        of MouseWheel:
          currentMouseEventWasConsumedVar = false
          if event.wheel.y > 0: 
            mouseScrollUpThisFrame = true
            onMouseScrollUp()
          if event.wheel.y < 0: 
            mouseScrollDownThisFrame = true
            onMouseScrollDown()

        else:
          # todo: handle other events
          discard

    onUpdate deltaTime  # the users update function for each tick
   
    # draw fps
    # todo: text should be the first parameter
    #drawText(
    #  0, 0,
    #  "FPS: " & $fps,
    #  30,
   #   White
   # )

    present(nimLoveContext.renderer)
    clear(nimLoveContext.renderer)
    nimLoveContext.renderer.setDrawColor toSdlColor(Green)
    nimLoveContext.renderer.fillRect(nil)

    # TODO: STH seems wrong here ...
    if delayCPUWaste:
      if getFPS() > 60.0: 
        delay(1)
        sleptMilisecondsPerSecondCounter += 1
      if thisFrameWasTenthOfASecond == 10:
        sleptMilisecondsPerSecond = sleptMilisecondsPerSecondCounter.float
        sleptMilisecondsPerSecondCounter = 0

  onQuit() # the user can handle the end of the program

  mixer.closeAudio()
  ttfQuit()
  nimLoveContext.renderer.destroy()
  nimLoveContext.window.destroy()
  sdl2.quit()