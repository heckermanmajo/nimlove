import ../../src/nimlove as nimlove

import std/options
import gameobjectcontainer

var soldierImage: nimlove.NimLoveImage

proc loadSoldierResources*() =
  soldierImage = nimlove.newNimLoveImage("mob.png")

type Soldier* = ref object of RootObj
  id: Id[Soldier]
  x, y: float
  speed: float
  friend: Option[Id[Soldier]]

var SoldierContainer*: GameObjectContainer[Soldier]

proc infoStr*(self: Soldier): string =
  return " Soldier id=" & $self.id & " x=" & $self.x & " y=" & $self.y

proc `x=`*(self: var Soldier, value: float) {.inline.} =
  ## This is a setter for x
  ## It is called when you do `soldier.x = 10`
  ## since it is inline, it will be inlined in the code
  ## the when not defined(release) is a compile time check
  ## that will be removed in release mode
  #echo "x = x"
  when not defined(release):
    #echo "x = x"
    assert value >= 0, "x must be positive " & infoStr self 
    if value > 10000: 
      echo "warning: x is very big: " & $value & " " & infoStr self
  self.x = value

proc x*(self: Soldier): float {.inline.} =
  ## This is a getter for x
  ## It is called when you do `echo soldier.x`
  ## since it is inline, it will be inlined in the code
  ## the when not defined(release) is a compile time check
  ## that will be removed in release mode
  when not defined(release):
    discard
    #echo "read x from soldier" & infoStr self
  return self.x

proc speed*(self: Soldier): float {.inline.} = return self.speed

proc hasFriend*(self: Soldier): bool =
  return self.friend.isSome

proc friend*(self: Soldier): Soldier =
    if not self.friend.isSome:
      raise newException(Exception, "Soldier has no friend but you tried to get it")
    if not SoldierContainer.exists(self.friend.get):
      raise newException(Exception, "Soldier has a friend but it is not in the container")
    return SoldierContainer.get(self.friend.get)

proc `friend=`*(self: var Soldier, value: Soldier) =
    self.friend = value.id.option


proc newSoldier*(
  x: float, y: float,
  speed: float,
): Soldier =
  var s = new Soldier
  s.id = SoldierContainer.insert(s)
  s.x = x
  s.y = y
  s.speed = speed
  s.friend = none[Id[Soldier]]()
  return s

proc draw*(self: Soldier) =
    soldierImage.draw(self.x, self.y)

proc canBeDrawn*(self: Soldier): bool = 
    ## here you could check if the soldier is in the screen
    if self.x > 1000: return false
    return true