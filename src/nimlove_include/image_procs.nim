

proc newNimLoveImage*(path: string): NimLoveImage =
  let nimLoveContext = getNimLoveContext()
  result = NimLoveImage()
  let surface = load((ABSOLUTE_PATH & path).cstring)
  result.width = surface.w.int
  result.height = surface.h.int
  sdlFailIf surface.isNil: "could not load image " & ABSOLUTE_PATH & path
  result.texture = nimLoveContext.renderer.createTextureFromSurface(surface)
  sdlFailIf result.texture.isNil: "could not create texture from image " & path
  surface.freeSurface
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
) =
  let nimLoveContext = getNimLoveContext()
  var d: Rect
  d.x =  cint x
  d.y =  cint y
  d.w =  if width == 0: image.width.cint else: cint width
  d.h =  if height == 0: image.height.cint else: cint height
  nimLoveContext.renderer.copyEx image.texture, nil, addr d, angle.cdouble, nil, SDL_FLIP_NONE

