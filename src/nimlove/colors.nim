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

