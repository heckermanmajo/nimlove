import ../private/[core, keys, nimlove_context]
import sdl2, sdl2/ttf, sdl2/image, sdl2/mixer
import std/strutils

type NimLoveSound = object
  soundFilePointerOgg: MusicPtr
  soundFilePointerWav: ChunkPtr
  soundFileType: string

# mixer.freeChunk(sound) #clear wav
#mixer.freeMusic(sound2) #clear ogg
#mixer.closeAudio()

proc newNimLoveSound*(filename: string): NimLoveSound =
  let nimLoveContext = getNimLoveContext() #  not used yet
  result = NimLoveSound()
  let path = ABSOLUTE_PATH & filename
  if filename.endsWith(".wav"):
    # todo: check that file exists
    # todo: use absolute path and remnid that file needs to be in the same folder as the executable
    result.soundFileType = "wav"
    result.soundFilePointerWav = mixer.loadWAV(path.cstring())
    if isNil(result.soundFilePointerWav):
      raise NimBrokenHeartError.newException("Unable to load sound file (.wav), error occured while loading")
  elif filename.endsWith(".ogg"):
    # todo: check that file exists
    # todo: use absolute path and remnid that file needs to be in the same folder as the executable
    result.soundFileType = "ogg"
    result.soundFilePointerOgg = mixer.loadMUS(path.cstring())
    if isNil(result.soundFilePointerOgg):
      raise NimBrokenHeartError.newException("Unable to load sound file (.ogg), error occured while loading: " & path)
  else:
    raise NimBrokenHeartError.newException("Unable to load sound file, only wav and ogg are supported")


proc play*(sound: NimLoveSound): cint =
  let nimLoveContext = getNimLoveContext() #  not used yet
  if sound.soundFileType == "wav":
    result = mixer.playChannel(-1.cint, sound.soundFilePointerWav, 0.cint)
  elif sound.soundFileType == "ogg":
    result = mixer.playMusic(sound.soundFilePointerOgg, 0.cint)
  else:
    raise NimBrokenHeartError.newException("Unable to play sound file, only wav and ogg are supported")
  if result == -1:
    raise NimBrokenHeartError.newException("Unable to play sound file, error occured while playing")