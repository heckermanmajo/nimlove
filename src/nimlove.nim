# import the offical nim sdl2 wrapper package
# make sure to have sdl2 installed on your system
# and the nim sdl2 wrapper installed
import sdl2, sdl2/ttf, sdl2/image, sdl2/mixer, sdl2/audio
# import standard library modules -> they are part of the nim compiler
import std/[options, os, strutils]



# defect is a special type of object that is used to throw exceptions
# defect can on som compiler settings not be catched -> it should crash the program
type SDLException = object of Defect
  ## This exception is thrown when an SDL2 function fails.
type NimBrokenHeartError = object of Defect
  ## This exception is thrown when nimlove has some internal errors
  ## f.e. the NimLoveContext is not initialized but a proc needs it

let ABSOLUTE_PATH* = os.getAppDir() & "/" ## \
  ## The absolute path to the directory of the executable. \
  ## This is neccecary to load images and fonts. Since
  ## all images and fonts are loaded from the directory of the executable.

template sdlFailIf(condition: typed, reason: string) =
  # todo: learn more about templates, so we can describe this function
  if condition: raise SDLException.newException(
    reason & ", SDL error " & $getError()
  )

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
include nimlove_include/keys
include nimlove_include/colors
include nimlove_include/image_type
include nimlove_include/nimlove_context_type
include nimlove_include/sound_type

var nimLoveContext: Option[NimLoveContext] = NimLoveContext.none ## \
    ## The NimLoveContext is a global variable that is initialized by the \
    ## setupNimLove() proc. It is used by the other procs to access the \
    ## SDL2 context. It is not exported -> lack of asterisk.
    ## This way we hide the SDL2 context from the user and make it easier \
    ## to use the library.

proc getNimLoveContext(): NimLoveContext =
  ## Returns the NimLoveContext. If the NimLoveContext is not initialized \
  ## it throws a NimBrokenHeartError.
  ## This proc is used to access the NimLoveContext from other procs.
  if not nimLoveContext.isSome:
    raise NimBrokenHeartError.newException(
      "NimLoveContext not initialized. Call setupNimLove() first."
    )
  return nimLoveContext.get


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
proc getMouseX*(): int = return mouseX
proc getMouseY*(): int = return mouseY
proc getMouseRightClickThisFrame*(): bool = return mouseRightClickThisFrame

# include all the procs for the nimlove-types
include nimlove_include/nimlove_context_procs
include nimlove_include/image_procs
include nimlove_include/text_procs
include nimlove_include/sound_procs
include nimlove_include/file_procs


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
          if event.button.button == sdl2.BUTTON_RIGHT:
            mouseRightClickThisFrame = true

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
