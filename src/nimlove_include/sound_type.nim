type NimLoveSound = object
  soundFilePointerOgg: MusicPtr
  soundFilePointerWav: ChunkPtr
  soundFileType: string


# mixer.freeChunk(sound) #clear wav
#mixer.freeMusic(sound2) #clear ogg
#mixer.closeAudio()