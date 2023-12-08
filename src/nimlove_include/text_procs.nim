

proc drawText*(x, y: int; text: string; size: int; color: Color = White) =
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

