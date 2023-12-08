# Package

version       = "0.0.1"
author        = "Marvin"
description   = "Super Simple 2D game framework for beginners and all lovers of the simplicity of love2d."
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.0"
requires "sdl2"

task game, "examples/game":
  exec "nim -r c ./examples/game/game.nim"
  exec "rm ./examples/game/game"

task animation, "examples/animation":
  exec "nim -r c ./examples/animation/animation.nim"
  exec "rm ./examples/animation/animation"

task tiles, "examples/tiles":
  exec "nim -r c ./examples/tiles/tiles.nim"
  exec "rm ./examples/tiles/tiles"

task mouse , "examples/mouse":
  exec "nim -r c ./examples/mouse/mouse.nim"
  exec "rm ./examples/mouse/mouse"