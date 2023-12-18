## EDITOR-FEATURE GOAL
## -------------------
## Load a map
## Save a map
## Edit a map
## 
## Test Pathfinding.
## Visualize stuff like the flooding algorithm.
## 
import  ../../../src/nimlove
import  ../../../src/nimlove/[image, map, button, text]

# 1. Create an empty map and set fields to non passable
# 2. Save the fields into a file
# 3. at editor start display a list of all possible maps and for each one button to load

nimlove.setupNimLove(
  windowWidth = 1900,
  windowHeight = 1200,
  windowTitle = "NimLove - empty game test",
  fullScreen = true,
)

nimlove.runProgramm proc(deltaTime: float) =
  drawText("Hello editor", 12,12)

