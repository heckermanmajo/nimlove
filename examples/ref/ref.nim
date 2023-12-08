import ../../src/nimlove as nimlove

const WindowWidth = 800
const WindowHeight = 600

nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "NimLove",
  fullScreen = false,
)


type GameObjectContainer[T] = object
  instances: tables.Table[int, T]
  instances: seq[T]

var soldiers: GameObjectContainer[Soldier]
var weapons: GameObjectContainer[Weapon]
var armors: GameObjectContainer[Armor]

type Soldier = object
  id: int
  x, y: float
  speed: float
  weapon: WeaponId
  armor: int

var s = Soldier(
  id: 1,
  x: 0.0,
  y: 0.0,
  speed: 1.0,
  weapon: 1,
  armor: 1,
)

proc `$`(self: Soldier): string =
  return [$x, $y, $speed, $weapon, $armor].join ","

proc weapon(self: Soldier): Weapon =
  return weapons.instances[self.weapon]

when(isDebug):
  type WeaponId = distinct int
  proc `$`(self: WeaponId): string = return $self.id
  proc get(self: WeaponId): Weapon = return weapons.instances[self.id]
  proc `weapon=`(self: Soldier, weapon: Weapon) =
    # todo: register soldier as user of weapon
    # todo: unregister soldier as user of old weapon
    self.weapon = weapon.id

when(isRelease):
  type WeaponId = int

s.weapon = weapons.instances[1]

type Weapon = object
  id: int
  damage: int
  range: int

proc getId(self: Weapon): WeaponId = return WeaponId(self.id)



type Armor = object
  id: int
  armor: int
  weight: int





nimlove.runProgramm proc(delta_time: float) =
  discard
