# Package

version       = "0.0.1"
author        = "Marvin"
description   = "Super Simple 2D game framework for beginners and all lovers of the simplicity of love2d."
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.0"
requires "sdl2"

task run_example, "Builds and runs example game":
  exec "nim -r c ./examples/game/game.nim"
  #exec "nim c ./examples/game/game.nim"
  #exec "cd ./examples/game;./game"
  exec "rm ./examples/game/game"