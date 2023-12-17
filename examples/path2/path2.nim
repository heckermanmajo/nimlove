import std/[random, options, math, heapqueue, tables]

import ../../src/nimlove as nimlove
import ../../src/nimlove/map

const WindowWidth = 800
const WindowHeight = 600

nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "NimLove - empty game test",
  fullScreen = false,
)

map.initMapTextures()


type MyGameTile* = ref object
  passable: bool
  selected: bool
  tileType: int
  building: int

proc isSelected*(t: MyGameTile): bool = return t.selected
proc isPassable*(t: MyGameTile): bool = return t.passable

var m = newMap[MyGameTile](
    sideLenInChunks= 1,
    createGameTileCallback
      = proc(
        m: Map[MyGameTile], 
        chunk: Chunk[MyGameTile], 
        tile: Tile[MyGameTile]
      ): MyGameTile = 
        let t = new(MyGameTile)
        t.passable = true
        #t.passable = if rand(100) < 15: false else: true
        t.selected = false
        return t 
)
let textures = map.getMapTextures()

var astarLogs: seq[string] = @[]

template yieldIfNotNone[T: GameTile](option: Option[Tile[T]])= 
  if option.isSome: yield option.get

iterator getNeighboursDirect*[T: GameTile](m: var Map[T], xnum, ynum: int): Tile[T] =
  yieldIfNotNone[T] m.getTileAtNum(xnum, ynum-1)
  yieldIfNotNone[T] m.getTileAtNum(xnum, ynum+1)
  yieldIfNotNone[T] m.getTileAtNum(xnum+1, ynum)
  yieldIfNotNone[T] m.getTileAtNum(xnum-1, ynum)

iterator getNeighboursVertical*[T: GameTile](m: var Map[T], xnum, ynum: int): Tile[T] =
  for n in getNeighboursDirect(m, xnum, ynum): yield n
    
  yieldIfNotNone[T] m.getTileAtNum(xnum+1, ynum+1)
  yieldIfNotNone[T] m.getTileAtNum(xnum+1, ynum-1)
  yieldIfNotNone[T] m.getTileAtNum(xnum-1, ynum+1)
  yieldIfNotNone[T] m.getTileAtNum(xnum-1, ynum-1)

proc getDirectCosts*[T: GameTile](m: Map[T], startNode, endNode: Tile[T]): float = 
  return sqrt(float(startNode.xnum - endNode.xnum).pow 2 + float(startNode.ynum - endNode.ynum).pow 2)

type 
  ReachedNode[T:GameTile] 
    = Tile[T]
  CheckedAndCameFromTable[T:GameTile] 
    = Table[
        ReachedNode[T], 
        tuple[
          fromWhichWeReachedIt:Tile[T],
          costToReachItFromHere: float
        ]
      ] 

proc heuristicCostEstimate*[T: GameTile](
  m: Map[T], 
  next, startNode, endNode: Tile[T],
  current: tuple[node: Tile[T], priority: float, cost: float],
  cameFrom: CheckedAndCameFromTable[T] 
): float = 
  # todo: optimize later
  return getDirectCosts(m, startNode, endNode)

iterator getAStarPath*[T: GameTile](
  m: var Map[T], 
  startNodePos, endNodePos: tuple[xInPixel:int,yInPixel:int]
): Tile[T] = 
  let optionStart = m.getTileAt(startNodePos.xInPixel, startNodePos.yInPixel)
  let optionEnd = m.getTileAt(endNodePos.xInPixel, endNodePos.yInPixel)
  
  if optionStart.isNone or optionEnd.isNone: 
    astarLogs.add("start or end tile is None, returning empty path")
    return
  
  let startNode = optionStart.get
  let endNode = optionEnd.get

  # open set is the algo-frontier: what nodes to check next -> 
  # therefore priority queue
  var toCheckPrioQueue
    : HeapQueue[tuple[node: Tile[T], priority: float, cost: float]]

  # A map of backreferences. After getting to the goal, you use this to walk
  # backwards through the path and ultimately find the reverse path
  var checkedAndCameFromTable: CheckedAndCameFromTable[T]


  while toCheckPrioQueue.len > 0:

    var currentNode: tuple[node: Tile[T], priority: float, cost: float] = toCheckPrioQueue.pop()

    if currentNode.node == endNode:
      # TODO: return path
      #for node in backtrack(cameFrom, start, goal):
      #  yield node
      break

    for nextTile in getNeighboursDirect(map, currentNode.node.xNum, currentNode.node.yNum):

      # The cost of moving into this node from the goal
      let cost: float = currentNode.cost + getDirectCosts(map, currentNode.node, nextTile)

      # If we haven't seen this point already, or we found a cheaper
      # way to get to that
      if not checkedAndCameFromTable.hasKey(nextTile) or cost < checkedAndCameFromTable[nextTile].cost:

        # Add this node to the backtrack map
        checkedAndCameFromTable[nextTile] = (node: currentNode.node, cost: cost)

        # Estimate the priority of checking this node
        let priority: float = cost + heuristicCostEstimate(
          m, 
          nextTile, 
          startNode, 
          endNode, 
          currentNode, 
          checkedAndCameFromTable 
        )

        # Also add it to the frontier so we check out its neighbors
        toCheckPrioQueue.push( (nextTile, priority, cost) )




nimlove.runProgramm(
  onUpdate= proc(deltaTime: float) = 
    m.drawMap()
  ,
  onKeyDown= proc(key: NimLoveKey) = discard,
  onKeyUp= proc(key: NimLoveKey) = discard,
  onMouseDown= proc(x, y: int) = discard,
  onMouseUp= proc(x, y: int) = discard,
  onMouseMove= proc(x, y: int) = discard,
  onMouseScrollUp= proc() = discard,
  onMouseScrollDown= proc() = discard,
  onQuit= proc() = discard,
)
