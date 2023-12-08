
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

