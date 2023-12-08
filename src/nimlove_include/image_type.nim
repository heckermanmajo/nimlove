type NimLoveImage* = object of RootObj
  ## Simple image object that can be passed into
  ## the draw procedures and will be drawn on the
  ## screen.
  # todo: add source file name
  texture: TexturePtr
  width: int
  height: int

type TextureAtlasTexture* = object
  ## A texture that is part of a texture atlas.
  ## if you pass in this into the draw procedures
  ## it will be drawn on the screen.
  image: NimLoveImage
  textureStartX: int
  textureStartY: int
  textureWidth: int
  textureHeight: int

proc newTextureAtlasTexture*(
  image: NimLoveImage,
  textureStartX: int,
  textureStartY: int,
  textureWidth: int,
  textureHeight: int
): TextureAtlasTexture =
  ## Create a new texture atlas texture.
  result.image = image
  # todo: check if the texture is big enough
  if textureStartX < 0 or textureStartY < 0 or textureWidth < 0 or textureHeight < 0:
    raise newException(NimBrokenHeartError, "Texture atlas texture parameters must be positive.")
  if textureStartX + textureWidth > image.width or textureStartY + textureHeight > image.height:
    raise newException(NimBrokenHeartError, "Texture atlas texture parameters must be smaller than the image.")
  result.textureStartX = textureStartX
  result.textureStartY = textureStartY
  result.textureWidth = textureWidth
  result.textureHeight = textureHeight

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
)

proc draw*(tat: TextureAtlasTexture, x: int,y: int, zoom: float = 1, angle: float = 0) =
  ## Render the texture atlas texture on the screen.
  draw tat.image, x, y, tat.textureWidth, tat.textureHeight, angle, zoom, 255, tat.textureStartX, tat.textureStartY, tat.textureWidth, tat.textureHeight

type Animation = ref object
  ## This is the animation object that is mapped 1:1 to the
  ## animated game object.
  frames: seq[TextureAtlasTexture]
  currentFrame: int
  frameTime: float
  currentFrameTime: float
  loop: bool

proc newAnimation*(
  frames: seq[TextureAtlasTexture],
  frameTime: float = 0.25,
  loop: bool = true
): Animation =
  ## Create a new animation object.
  var result = Animation()
  result.frames = frames
  result.currentFrame = 0
  result.frameTime = frameTime
  result.currentFrameTime = 0.0
  result.loop = loop
  return result

proc draw*(animation: Animation, x: int, y: int, zoom: float = 1, angle: float = 0) =
  ## Display the current frame of the animation.
  echo "drawing frame ", animation.currentFrame
  draw animation.frames[animation.currentFrame], x, y, zoom, angle

proc progress*(animation: var Animation, delta_time: float) =
  assert animation.frames.len > 0
  animation.currentFrameTime += delta_time
  if animation.currentFrameTime > animation.frameTime:
    animation.currentFrameTime -= animation.frameTime
    animation.currentFrame += 1
    if animation.currentFrame >= animation.frames.len:
      if animation.loop:
        animation.currentFrame = 0
      else:
        animation.currentFrame = animation.frames.len - 1
  if animation.currentFrame > animation.frames.len - 1:
    animation.currentFrame = animation.frames.len - 1


proc readLineOfTextureAtlas*(
  fromImage: NimLoveImage,
  num: int,
  widthPX: int,
  heigthPX: int,
  rowNumber: int = 0,
  startPosition: int = 0
  ): seq[TextureAtlasTexture] =
  var result: seq[TextureAtlasTexture] = @[]
  for i in 0..num-1:
    result.add(
      newTextureAtlasTexture(
        fromImage,
        i*widthPX + startPosition * widthPX,
        rowNumber*heigthPX,
        widthPX,
        heigthPX
      )
    )
  return result