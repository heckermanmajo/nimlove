
type ZombieRef = distinct uint64

var GLOBALZOMBIES = tables.Table[int, Zombie]()

proc get(zref: ZombieRef): Zombie =
  ## Get the zombie referred to by the ref
  ## This is a hack to get around the fact that we can't
  return GLOBALZOMBIES[zref.int]

type Zombieesitzer = object
  oneZombie: ZombieRef

type GameObjectRef = object
  ## A ref contains a unique id and a classname
  ## It refers to another
  id: uint64
  classname: string

proc get[T](gref: GameObjectRef): T
  ## Get the object referred to by the ref
  ## This is a hack to get around the fact that we can't
  ## have a generic type that is a ref

type GameObjectContainer[T] = object
  ## A container for game objects
  ## This is a hack to get around the fact that we can't
  ## have a generic type that is a ref
  objects: tables.Table[int, T]

type Zombie= object
  someValue: int

type OtherZombie= object
  someValue: int

var zombies: GameObjectContainer[Zombie]
var otherZombies: GameObjectContainer[OtherZombie]

var ALLCLASSES= {
  "Zombie": zombies,
  "OtherZombie": otherZombies
}.toTable

var r = GameObjectRef(id: 1, classname: "Zombie")
var z = get[Zombie](r)