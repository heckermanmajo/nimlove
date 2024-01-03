import std/[strutils]

import sdl2 ## import the offical nim sdl2 wrapper package
import sdl2/[image] 

import ../../nimlove as nl

##############################################
#
#
#
# Edit Pixels
#
#
#
##############################################


type EditableImage* = ref object
  ## Image that can be edited. It cannot be drawn directly but can be
  ## converted to a NimLoveImage via the makeNormalImage() proc.
  surface: SurfacePtr ## the sdl2 surface -> the data of the image
  width: int ## width: int of the image, cannot be changed
  height: int ## height: int of the image, cannot be changed

proc width*(eImage: EditableImage): int = return eImage.width
proc height*(eImage: EditableImage): int = return eImage.height

proc newEditableImage*(relativePath: string): EditableImage =
  ## Create a new editable image from a file.
  ## The path is relative to the executable.
  let _ = getNimLoveContext()
  result = EditableImage()
  if not relativePath.endsWith(".png"):
    raise newException(NimBrokenHeartError, "Editable images must be png files.")
  let surface = load((ABSOLUTE_PATH & relativePath).cstring)
  result.width = surface.w.int
  result.height = surface.h.int
  sdlFailIf surface.isNil: "could not load image " & ABSOLUTE_PATH & relativePath
  result.surface = surface

type PixelValue* = object
  ## A pixel value is a color with an alpha value.
  ## It is used to set and get pixels of an EditableImage.
  r*, g*, b*, a*: uint8

proc toUint32*(self: PixelValue): uint32 =
  return (self.r.uint32 shl 16) or (self.g.uint32 shl 8) or self.b.uint32

let 
  PixelValueRed* = PixelValue(r : 255, g: 0, b: 0, a: 255)
  PixelValueGreen* = PixelValue(r : 0, g: 255, b: 0, a: 255)
  PixelValueBlue* = PixelValue(r : 0, g: 0, b: 255, a: 255)
  PixelValueBlack* = PixelValue(r : 0, g: 0, b: 0, a: 255)
  PixelValueWhite* = PixelValue(r : 255, g: 255, b: 255, a: 255)
  PixelValueYellow* = PixelValue(r : 255, g: 255, b: 0, a: 255)
  PixelValuePink* = PixelValue(r : 255, g: 0, b: 255, a: 255)
  PixelValueGray* = PixelValue(r : 128, g: 128, b: 128, a: 255)
  PixelValueOrange* = PixelValue(r : 255, g: 165, b: 0, a: 255)
  PixelValueGold* = PixelValue(r : 255, g: 215, b: 0, a: 255)
  PixelValueDeepPink* = PixelValue(r : 255, g: 20, b: 147, a: 255)
  PixelValueBlueViolet* = PixelValue(r : 138, g: 43, b: 226, a: 255)
  PixelValueDarkBlue* = PixelValue(r : 0, g: 0, b: 139, a: 255)
  PixelValueDarkGreen* = PixelValue(r : 0, g: 100, b: 0, a: 255)
  PixelValueDarkRed* = PixelValue(r : 139, g: 0, b: 0, a: 255)
  PixelValueDarkOrange* = PixelValue(r : 255, g: 140, b: 0, a: 255)
  # todo: add more colors

proc `$`*(self: PixelValue): string =
  return "pv(" & $self.r & ", " & $self.g & ", " & $self.b & "; " & $self.a & ")"

proc setPixel*(eImage: var EditableImage, x, y: int, pixelValue: PixelValue) =
  ## Set a pixel of an EditableImage to the given PixelValue.
  let _ = getNimLoveContext()
  let surface: ptr Surface = eImage.surface
  let pixelCast = (cast[ptr PixelFormat](surface.format))
  # echo getPixelFormatName(cast[uint32](surface.format))
  let bytesPerPixel: int = pixelCast.BytesPerPixel.int
  assert bytesPerPixel == 4
  assert pixelCast.BitsPerPixel.int == 32
  let pixelOffset: int = y * surface.pitch + x * bytesPerPixel

  let pixelAddress: ptr uint8 = cast[ptr uint8](cast[int](cast[ptr uint8](surface.pixels)) + pixelOffset)
  let pixelAddress2: ptr uint32 = cast[ptr uint32](pixelAddress)
  #let format: uint32 = sdl2.getPixelFormat( nimLoveContext.window );
  # TODO: THIS CAN CAUSE HARM
  let mappingFormat: ptr PixelFormat = sdl2.allocFormat( SDL_PIXELFORMAT_ABGR8888 );
  # TODO: It is the bad format, since it "removes the right pixels at the right place but they are just empty"
  discard sdl2.lockSurface(eImage.surface)
  pixelAddress2[] = sdl2.mapRGBA( 
    format=mappingFormat, 
    r=pixelValue.r, #0xFF, 
    g=pixelValue.g, #0xFF, 
    b=pixelValue.b, #0xFF,
    a=pixelValue.a #0xFF
  )
  
  sdl2.unlockSurface(eImage.surface)

proc getPixel*(eImage: EditableImage, x, y: int): PixelValue =
  ## Get the PixelValue of a pixel of an EditableImage.
  let nimLoveContext = getNimLoveContext()
  let surface: ptr Surface = eImage.surface
  let format: uint32 = sdl2.getPixelFormat( nimLoveContext.window );
  #echo getPixelFormatName(format)

  #[if format == SDL_PIXELFORMAT_RGB888:
    echo "SDL_PIXELFORMAT_RGB888"
  elif format == SDL_PIXELFORMAT_RGBA8888:

    echo "SDL_PIXELFORMAT_RGBA8888"
  elif format == SDL_PIXELFORMAT_ABGR8888:

    echo "SDL_PIXELFORMAT_ABGR8888"
  elif format == SDL_PIXELFORMAT_BGRA8888:

    echo "SDL_PIXELFORMAT_BGRA8888"
  else:
    echo "unknown format: ", format  
    ]#

  let mappingFormat: ptr PixelFormat = sdl2.allocFormat( format );
  let pixelCast = (cast[ptr PixelFormat](surface.format))
  let bytesPerPixel: int = pixelCast.BytesPerPixel.int
  let pixelOffset: int = y * surface.pitch.int + x * bytesPerPixel
  let pixelAddress: ptr uint8 = cast[ptr uint8](cast[int](surface.pixels) + pixelOffset)
  let pixelAddress2: ptr uint32 = cast[ptr uint32](pixelAddress)
  let pixelValue: uint32 = pixelAddress2[]
  #echo "pixelValue: ", pixelValue
 
  #[
    proc getPixelFormatName*(format: uint32): cstring {.
  importc: "SDL_GetPixelFormatName".}
  ]#
  var r,g,b,a: uint8
  sdl2.getRGBA(pixelValue.uint32, mappingFormat, r, g, b, a)
  result = PixelValue()
  result.r = r
  result.g = g
  result.b = b
  result.a = a
  echo result
  return result

proc replaceColor*(eImage: var EditableImage, oldColor: PixelValue, newColor: PixelValue) =
  ## Replace all pixels of an EditableImage that have the oldColor with the newColor.
  let _ = getNimLoveContext()
  for y in 0..eImage.height-1:
    for x in 0..eImage.width-1:
      if getPixel(eImage, x, y) == oldColor:
        setPixel(eImage, x, y, newColor)

proc surface*(eImage: EditableImage) :SurfacePtr =
  return eImage.surface