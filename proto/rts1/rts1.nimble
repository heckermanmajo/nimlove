import std / [os, strformat]

# Package

version       = "0.0.1"
author        = "Marvin"
description   = "Proto-Rts for nimlove-applications."
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.0"
# not needed, if we switch to the official stdlib-binaryheap
# https://github.com/Nycto/AStarNim
requires "binaryheap"
# https://github.com/nim-lang/sdl2
requires "sdl2"  # nims offical sdl2 wrapper
# todo: add astar

# tasks
task r, "Run the application.": 
  exec ("nim c -r src/rts1.nim")

