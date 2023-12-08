import sdl2,  sdl2/ttf, sdl2/image, sdl2/mixer


# import standard library modules -> they are part of the nim compiler
import std/[options, os, strutils]

import core 
import ../nimlove/colors

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
  sdlFailIf(not sdl2.init(INIT_EVERYTHING)): "SDL2 initialization failed"
  # image.init(IMG_INIT_PNG)
  result.window = createWindow(
    title = "Pixels Canvas",
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

  setTitle(result.window, Title)
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