type NimLoveImage* = object of RootObj
  ## Simple image object that can be passed into
  ## the draw procedures and will be drawn on the
  ## screen.
  texture: TexturePtr
  width: int
  height: int