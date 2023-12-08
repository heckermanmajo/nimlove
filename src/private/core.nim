## Private Core functionality for nimlove
## 
import sdl2, sdl2/ttf, sdl2/image, sdl2/mixer
import std/os
import ../nimlove/colors

# defect is a special type of object that is used to throw exceptions
# defect can on som compiler settings not be catched -> it should crash the program
type SDLException* = object of Defect
  ## This exception is thrown when an SDL2 function fails.
  
type NimBrokenHeartError* = object of Defect
  ## This exception is thrown when nimlove has some internal errors
  ## f.e. the NimLoveContext is not initialized but a proc needs it

let ABSOLUTE_PATH* = os.getAppDir() & "/" ## \
  ## The absolute path to the directory of the executable. \
  ## This is neccecary to load images and fonts. Since
  ## all images and fonts are loaded from the directory of the executable.

template sdlFailIf*(condition: typed, reason: string) =
  # todo: learn more about templates, so we can describe this function
  if condition: raise SDLException.newException(
    reason & ", SDL error " & $getError()
  )

proc toSdlColor*(x: colors.Color): sdl2.Color {.inline.} =
  let x = x.int
  result = color(x shr 16 and 0xff, x shr 8 and 0xff, x and 0xff, 0)