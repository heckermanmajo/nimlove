
proc newNimLoveContext*(
  WindowWidth: int = 800,
  WindowHeight: int = 600,
  Title: string = "NimLove",
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
  result.renderer.setDrawColor toSdlColor(Color 0)
  clear(result.renderer)

  # load the basic font
  var font = openFont(cstring(ABSOLUTE_PATH & "font.ttf"), 20)
  sdlFailIf font.isNil: "font could not be created"
  #close font
  result.font = font

  return result


proc setupNimLove*(
    windowWidth: int = 800,
    windowHeight: int = 600,
    windowTitle: string = "NimLove",
  ) =
  # set global nimLoveContext
  echo "setupNimLove"
  nimLoveContext = newNimLoveContext(
    WindowWidth = windowWidth,
    WindowHeight = windowHeight,
    Title = windowTitle
  ).some