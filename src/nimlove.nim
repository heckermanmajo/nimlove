# import the offical nim sdl2 wrapper package
# make sure to have sdl2 installed on your system
# and the nim sdl2 wrapper installed
import sdl2, sdl2/ttf, sdl2/mixer
# import standard library modules -> they are part of the nim compiler
#import std/[options, os, strutils]

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

import private/keys
import nimlove/colors
import private/nimlove_context
import private/core


# todo: comment
var audio_rate : cint
var audio_format : uint16
var audio_buffers : cint    = 4096
var audio_channels : cint   = 2

sdlFailIf(
  mixer.openAudio(audio_rate, audio_format, audio_channels, audio_buffers) != 0,
  "Could not open audio"
)


# includes just paste the content of the included file into the current file
# import doees import another file and makes it available as a module
# so the private symbols are not visible, the private symbols on inlcude
# are visible
# IMPORANT: We include the types before we include the procs or do
# anything else. This way all types are available below.


## Expose functions some functions and values from private to the outside world
let ABSOLUTE_PATH* = ABSOLUTE_PATH
let setupNimLove*: proc (windowWidth: int, windowHeight: int, windowTitle: string, fullScreen: bool) = setupNimLove


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


var delayCPUWaste = true
proc setDelayCPUWaste*(value: bool) =
  ## This makes the program wait for on milisecond after each frame
  ## IF the FPS is higher than 200. This is to prevent the program
  ## from using 100% CPU for no work.
  delayCPUWaste = value


var mouseX, mouseY: int = 0
var mouseRightClickThisFrame: bool = false
var mouseLeftClickThisFrame: bool = false
var mouseMiddleClickThisFrame: bool = false
proc getMouseX*(): int = return mouseX
proc getMouseY*(): int = return mouseY
proc getMouseRightClickThisFrame*(): bool = return mouseRightClickThisFrame
proc getMouseLeftClickThisFrame*(): bool = return mouseLeftClickThisFrame
proc getMouseMiddleClickThisFrame*(): bool = return mouseMiddleClickThisFrame


proc drawText*(x: int, y: int, text: string, size: int = 10, color: colors.Color = White) =
  # todo: preload fonts of different sizes - this increases performance big time
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


proc runProgramm*(
  onUpdate: proc(deltaTime: float) {.closure.},
  onKeyDown: proc(key: NimLoveKey) {.closure.} = proc(key: NimLoveKey) = discard,
  onKeyUp: proc(key: NimLoveKey) {.closure.} = proc(key: NimLoveKey) = discard,
  onKeyPressed: proc(key: NimLoveKey) {.closure.} = proc(key: NimLoveKey) = discard,
  onKeyReleased: proc(key: NimLoveKey) {.closure.} = proc(key: NimLoveKey) = discard,
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

  while keepRunning:

    # calculate fps
    frame_counter += 1
    time_in_ms += (getTicks() - now).float
    if time_in_ms >= 1000.0:
      fps = frame_counter.float / (time_in_ms / 1000.0)
      time_in_ms = 0.0
      frame_counter = 0

    let newNow = getTicks()
    let deltaTime = (newNow - now).float / 1000.0
    now = newNow

    mouseRightClickThisFrame = false

    var event = defaultEvent
    while pollEvent(event):
      case event.kind
        of QuitEvent:
          keepRunning = false
          break
        of KeyDown:
          onKeyDown(sdlScancodeToNimLoveKeyEnum(event.key.keysym.scancode))
          if event.key.keysym.scancode == SDL_SCANCODE_ESCAPE:
            keepRunning = false
            break
          #if event.key.keysym.scancode == SDL_SCANCODE_A:
          #  echo "A pressed"
          #  break

        of KeyUp:
          # echo "key up"
          discard
        
        of MouseButtonDown:
          onMouseDown(event.button.x, event.button.y)
          if event.button.button == sdl2.BUTTON_RIGHT: mouseRightClickThisFrame = true
          if event.button.button == sdl2.BUTTON_LEFT: mouseLeftClickThisFrame = true
          if event.button.button == sdl2.BUTTON_MIDDLE: mouseMiddleClickThisFrame = true

        of MouseMotion:
          onMouseMove(event.motion.x, event.motion.y)
          mouseX = event.motion.x
          mouseY = event.motion.y

        else:
          # todo: handle other events
          discard


    onUpdate deltaTime  # the users update function for each tick
   
   
    # draw fps
    # todo: text should be the first parameter
    drawText(
      0, 0,
      "FPS: " & $fps,
      30,
      White
    )

    present(nimLoveContext.renderer)
    clear(nimLoveContext.renderer)
    nimLoveContext.renderer.setDrawColor toSdlColor(Green)
    nimLoveContext.renderer.fillRect(nil)

    # todo: add comment
    if delayCPUWaste:
      if getFPS() > 200.0: delay(1)

  onQuit() # the user can handle the end of the program

  mixer.closeAudio()
  ttfQuit()
  nimLoveContext.renderer.destroy()
  nimLoveContext.window.destroy()
  sdl2.quit()