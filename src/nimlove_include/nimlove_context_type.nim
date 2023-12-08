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

