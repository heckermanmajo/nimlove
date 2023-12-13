import std / [os, strformat]

# Package

version       = "0.0.1"
author        = "Marvin"
description   = "Super Simple 2D game framework for beginners and all lovers of the simplicity of love2d."
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.0"
requires "sdl2"  # nims offical sdl2 wrapper

# tasks


let runnableExamples = @[
  "game",
  "animation",
  "tiles",
  "mouse",
  "performance",
  "pixel"
]

task r, "run the game":
  # get 3rd argument
  echo &"my task {commandLineParams()}"
  let args = commandLineParams()
  let lastArg = args.len - 1
  let arg = args[lastArg]
  # check if argument is in examples
  if arg in runnableExamples:
    exec "nim -r c ./examples/" & arg & "/" & arg & ".nim"
    exec "rm ./examples/" & arg & "/" & arg
  else:
    echo "Please specify an example to run"
    echo "Available examples:"
    for example in runnableExamples:
      echo "  " & example

task compall , "compile all examples":
  for example in runnableExamples:
    exec "nim c ./examples/" & example & "/" & example & ".nim"
    exec "rm ./examples/" & example & "/" & example

task rall, "run all examples":
  for example in runnableExamples:
    exec "nim -r c ./examples/" & example & "/" & example & ".nim"
    exec "rm ./examples/" & example & "/" & example

task git, "commit changes":
  exec "git add ."
  let args = commandLineParams()
  let lastArg = args.len - 1
  let arg = args[lastArg]
  exec ("git commit -m \""& arg & "\" ")
  exec "git push"