

import sdl2
import std/[json, tables]

##############################################
#
# Colors
#
##############################################

type
  Color* = distinct int

const
  White* = Color 0xffffff
  Black* = Color 0
  Gold* = Color 0xffd700
  Orange* = Color 0xFFA500
  Blue* = Color 0x00FFFF
  Red* = Color 0xFF0000
  Yellow* = Color 0xFFFF00
  Pink* = Color 0xFF00FF
  Gray* = Color 0x808080
  Green* = Color 0x44FF44
  Deeppink* = Color 0xFF1493

proc toColor*(r, g, b: int): Color =
  assert r in 0..255
  assert g in 0..255
  assert b in 0..255
  result = Color (r shl 16) or (g shl 8) or b

proc toSdlColor*(x: Color): sdl2.Color {.inline.} =
  let x = x.int
  result = sdl2.color(x shr 16 and 0xff, x shr 8 and 0xff, x and 0xff, 0)

proc `%`*(color: Color): JsonNode =
  ## This function is used to serialize 
  ## a color field to json in the specific 
  ## nimlove serialization way.
  return %{
    "__version__": "0.1",
    "__nimlove_type__": "Color",
    "__value__": $color.int,
  }.toTable

proc colorFromJson*(node: JsonNode): Color =
  ## This function is used to deserialize
  ## a color field from json in the specific
  ## nimlove serialization way.
  if node.kind != json.JObject:
    raise newException(ValueError, "Invalid color json")
  if node["__nimlove_type__"].getStr != "Color":
    raise newException(ValueError, "Invalid color json type")
  if node["__version__"].getStr != "0.1":
    raise newException(ValueError, "Invalid color json version")
  if node["__value__"].kind != json.JInt:
    raise newException(ValueError, "Invalid color json value")
  assert node["__value__"].getInt >= 0
  return Color node["__value__"].getInt