## The keys file
## included into nimlove.nim file via include

type NimLoveKey* = enum
  ## An enum that represents a key on the keyboard.
  ## Usually used on key events.
  KEY_A
  KEY_B
  KEY_C
  KEY_D
  KEY_E
  KEY_F
  KEY_G
  KEY_H
  KEY_I
  KEY_J
  KEY_K
  KEY_L
  KEY_M
  KEY_N
  KEY_O
  KEY_P
  KEY_Q
  KEY_R
  KEY_S
  KEY_T
  KEY_U
  KEY_V
  KEY_W
  KEY_X
  KEY_Y
  KEY_Z
  KEY_0
  KEY_1
  KEY_2
  KEY_3
  KEY_4
  KEY_5
  KEY_6
  KEY_7
  KEY_8
  KEY_9
  KEY_SPACE
  KEY_ESCAPE

func sdlScancodeToNimLoveKeyEnum(scancode: Scancode): NimLoveKey =
  case scancode
  of SDL_SCANCODE_A: KEY_A
  of SDL_SCANCODE_B: KEY_B
  of SDL_SCANCODE_C: KEY_C
  of SDL_SCANCODE_D: KEY_D
  of SDL_SCANCODE_E: KEY_E
  of SDL_SCANCODE_F: KEY_F
  of SDL_SCANCODE_G: KEY_G
  of SDL_SCANCODE_H: KEY_H
  of SDL_SCANCODE_I: KEY_I
  of SDL_SCANCODE_J: KEY_J
  of SDL_SCANCODE_K: KEY_K
  of SDL_SCANCODE_L: KEY_L
  of SDL_SCANCODE_M: KEY_M
  of SDL_SCANCODE_N: KEY_N
  of SDL_SCANCODE_O: KEY_O
  of SDL_SCANCODE_P: KEY_P
  of SDL_SCANCODE_Q: KEY_Q
  of SDL_SCANCODE_R: KEY_R
  of SDL_SCANCODE_S: KEY_S
  of SDL_SCANCODE_T: KEY_T
  of SDL_SCANCODE_U: KEY_U
  of SDL_SCANCODE_V: KEY_V
  of SDL_SCANCODE_W: KEY_W
  of SDL_SCANCODE_X: KEY_X
  of SDL_SCANCODE_Y: KEY_Y
  of SDL_SCANCODE_Z: KEY_Z
  of SDL_SCANCODE_0: KEY_0
  of SDL_SCANCODE_1: KEY_1
  of SDL_SCANCODE_2: KEY_2
  of SDL_SCANCODE_3: KEY_3
  of SDL_SCANCODE_4: KEY_4
  of SDL_SCANCODE_5: KEY_5
  of SDL_SCANCODE_6: KEY_6
  of SDL_SCANCODE_7: KEY_7
  of SDL_SCANCODE_8: KEY_8
  of SDL_SCANCODE_9: KEY_9
  of SDL_SCANCODE_SPACE: KEY_SPACE
  of SDL_SCANCODE_ESCAPE: KEY_ESCAPE
  else: raise newException(Exception, "Unknown scancode")