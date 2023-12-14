import std/[tables, os, strutils, options]

import sdl2 ## import the offical nim sdl2 wrapper package
import sdl2/[ttf, mixer, image] 

import ../nimlove as nl

##############################################
#
# Fonts & TEXT
#
##############################################

var fonts: tables.Table[string, FontPtr] = initTable[string, FontPtr]() ##\
  ## All loaded fonts.

proc loadFont*(path: string, name: string, size: int = 10) =
  ## Loads a font from a file and stores it in the fonts table.
  ## Returns the loaded font.
  let nimLoveContext = getNimLoveContext()
  let font = openFont(cstring(ABSOLUTE_PATH & path), size.cint)
  sdlFailIf font.isNil: "font could not be created"
  fonts[name] = font

proc fontExists(name: string): bool =
  ## Returns true if a font with the given name exists.
  return fonts.hasKey(name)

proc drawText*(x: int, y: int, text: string, fontName: string = "", color: nl.Color = White) =
  # todo: preload fonts of different sizes - this increases performance big time
  ## deprecated: use drawText() beneath instead
  let nimLoveContext = getNimLoveContext()
  let font 
    = if fontName == "": nimLoveContext.font 
    else: 
      if not fonts.hasKey(fontName):
        raise newException(NimBrokenHeartError, "Font " & fontName & " does not exist.")
      fonts[fontName]
  let surface = ttf.renderUtf8Solid(font, text, toSdlColor color)
  let texture = nimLoveContext.renderer.createTextureFromSurface(surface)
  var d: Rect
  d.x = cint x
  d.y = cint y
  queryTexture(texture, nil, nil, addr(d.w), addr(d.h))
  nimLoveContext.renderer.copy texture, nil, addr d
  surface.freeSurface
  texture.destroy

proc drawText*(text: string, x: int, y: int, fontName:string="", color: nl.Color = nl.White) =
  let nimLoveContext = getNimLoveContext()
  let font 
    = if fontName == "": nimLoveContext.font 
    else: 
      if not fonts.hasKey(fontName):
        raise newException(NimBrokenHeartError, "Font " & fontName & " does not exist.")
      fonts[fontName]
  let surface = ttf.renderUtf8Solid(font, text, toSdlColor color)
  let texture = nimLoveContext.renderer.createTextureFromSurface(surface)
  var d: Rect
  d.x = cint x
  d.y = cint y
  queryTexture(texture, nil, nil, addr(d.w), addr(d.h))
  nimLoveContext.renderer.copy texture, nil, addr d
  surface.freeSurface
  texture.destroy

type Width = int
type Height = int

proc getTextSizeInPixel*(text: string): (Width, Height) =
  # int TTF_SizeText(TTF_Font *font, const char *text, int *w, int *h)
  let nimLoveContext = getNimLoveContext()
  var w, h: cint
  let res = sizeText(nimLoveContext.font, text.cstring, addr w, addr h)
  sdlFailIf res != 0, "could not get text size"
  return (w.int, h.int)

proc displayDebugInfo*() = 
  drawText("FPS: " & $getFPS(), 0, 0)
  drawText("Slept ms: " & $getSleptMilisecondsPerSecond(), 0, 20)
  drawText("Mouse: " & $getMouseX() & ", " & $getMouseY(), 0, 40)