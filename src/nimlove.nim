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
## 
## ADD serialize and deserialize procs for all nimlove types 

# TODO: comment everything
# TODO: add saving images 
# TODO: draw a pixel, line, rect, circle, triangle, procs
# TODO: add debug logs that can be turned on and off -> into a nimlove.log file
# TODO: set mutliple cursors
# TODO: load multiple fonts by string
# TODO: add setBackgroundColor procs
 
{.experimental: "strictDefs".}

# and the nim sdl2 wrapper installed
import sdl2 ## import the offical nim sdl2 wrapper package
import sdl2/[ttf, mixer] 

# import standard library modules -> they are part of the nim compiler
import std/[tables, os, options]

import nimlove/private/keys
import nimlove/private/colors
export keys
export colors



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
# NimLoveContext
#
##############################################


type NimLoveContext* = object of RootObj
  ## The NimLoveContext is the main object that
  ## is passed into the main loop of the program.
  ## It contains the renderer and window objects
  ## and provides some helper procedures.
  renderer: RendererPtr
  window: WindowPtr
  WindowWidth: int
  WindowHeight: int
  Title: string
  font: FontPtr

proc font*(context: NimLoveContext): FontPtr =
  ## Returns the default font.
  ## The default font is used by the drawText() proc.
  return context.font

proc window*(context: NimLoveContext): WindowPtr =
  ## Returns the window object.
  ## Used by image/eimage.
  return context.window

proc renderer*(context: NimLoveContext): RendererPtr =
  ## Returns the renderer object.
  ## Used by image/eimage.
  return context.renderer

proc getWindowWidth*(context: NimLoveContext): int =
  ## Returns the width of the window.
  return context.WindowWidth

proc getWindowHeight*(context: NimLoveContext): int =
  ## Returns the height of the window.
  return context.WindowHeight


proc newNimLoveContext(
  WindowWidth: int = 800,
  WindowHeight: int = 600,
  Title: string = "NimLove",
  fullScreen: bool = false,
): NimLoveContext =
  ## Creates new nim love context.
  ## Called by setupNimLove() proc.
  runnableExamples:
    var lol = 13

  result = NimLoveContext()
  # https://stackoverflow.com/questions/33393528/how-to-get-screen-size-in-sdl
  # TODO: if width and height are -1 use the screen size
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

  result.renderer.setDrawColor toSdlColor(colors.Color 0)

  clear(result.renderer)

  # setTitle(result.window, Title)
  if fullScreen:
    echo "Try to set game to fullscreen"
    discard setFullscreen(result.window, SDL_WINDOW_FULLSCREEN_DESKTOP) # todo: handle error

  # load the basic font
  # check the root directory and the "baseassets" directory
  # TODO: LOAD MUCH MORE FONTS AND FONTSIZES ... 
  let possibleFontPath1 = ABSOLUTE_PATH & "font.ttf"
  let possibleFontPath2 = ABSOLUTE_PATH & "baseassets/font.ttf"

  var font: FontPtr
  if fileExists(possibleFontPath1):
    echo "load font from " & possibleFontPath1
    font = openFont(cstring(possibleFontPath1), 12)
  elif fileExists(possibleFontPath2):
    echo "load font from " & possibleFontPath2
    font = openFont(cstring(possibleFontPath2), 12)
  else:
    raise SDLException.newException(
      "Could not find font.ttf in " & ABSOLUTE_PATH
    )

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
var mouseLeftUpThisFrame = false
var mouseRightUpThisFrame = false
var mouseMiddleUpThisFrame = false

proc getMouseX*(): int = return mouseX
proc getMouseY*(): int = return mouseY
proc getMouseRightClickThisFrame*(): bool = return mouseRightClickThisFrame
proc getMouseLeftClickThisFrame*(): bool = return mouseLeftClickThisFrame
proc getMouseMiddleClickThisFrame*(): bool = return mouseMiddleClickThisFrame
proc getMouseScrollUpThisFrame*(): bool = return mouseScrollUpThisFrame
proc getMouseScrollDownThisFrame*(): bool = return mouseScrollDownThisFrame
proc getMouseLeftUpThisFrame*(): bool = return mouseLeftUpThisFrame
proc getMouseRightUpThisFrame*(): bool = return mouseRightUpThisFrame
proc getMouseMiddleUpThisFrame*(): bool = return mouseMiddleUpThisFrame

proc mouseIsOver*(x: int, y: int, width: int, height: int): bool =
  ## Returns true if the mouse is over the given rectangle.
  return mouseX >= x and mouseX <= x + width and mouseY >= y and mouseY <= y + height


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
    mouseLeftUpThisFrame = false
    mouseRightUpThisFrame = false
    mouseMiddleUpThisFrame = false

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
          if event.button.button == sdl2.BUTTON_RIGHT: mouseRightUpThisFrame = true
          if event.button.button == sdl2.BUTTON_LEFT: mouseLeftUpThisFrame = true
          if event.button.button == sdl2.BUTTON_MIDDLE: mouseMiddleUpThisFrame = true

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