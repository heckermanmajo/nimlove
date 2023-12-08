

proc getMousePosition*(): tuple[x, y: int] =
  ## Returns the current mouse position.
  var x, y: cint
  discard getMouseState(addr x, addr y)
  return (x.int, y.int)

proc getMouseX*(): int =
  ## Returns the current mouse x position.
  return getMousePosition()[0]

proc getMouseY*(): int =
  ## Returns the current mouse y position.
  return getMousePosition()[1]

