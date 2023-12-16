import std/[tables, options, math, hashes, json, strutils]
import binaryheap # external package 

import ../../src/nimlove
import ../../src/nimlove/image

# todo: steigung





type 

  X = int 
  Y = int

  GameTile* = concept C 
    ## Basic concept for the objects the user can inject into the map
    C.isPassable() is bool
    C.isSelected() is bool
    %(C) is JsonNode
  
  Tile*[T: GameTile] = ref object
    ## A tile is a square on the map.
    ## It contains a reference to the gameTile, which is the object the user
    ## can inject into the map.
    x, y: int ## position in the map, not in pixels, but in tiles
    plannedTravelWeight: float  ## How many units plan to cross this tile
    gameTile: T ## the object the user can inject into the map
    map: Map[T] ## the map this tile belongs to


  Chunk*[T: GameTile] = ref object
    ## A chunk is a square of tiles. It is used to speed up the pathfinding
    ## algorithm. 
    x, y: int ## position in the map, not in pixels, but in chunks
    tiles: seq[Tile[T]] ## the tiles this chunk contains
    travelHeat: float ## How many units plan to cross this chunk
    unpassableTiles: int ## number of tiles in this chunk that are not passable\
        ## Used in the heuristic function of the astar algorithm
    map: Map[T] ## the map this chunk belongs to
    node: Tile[T] ## used by the astar algorithm (the nim lib)

  Map*[T: GameTile] = ref object
    tileSizeInPixels:int = 32
    chunkSizeInTiles:int = 16
    tiles: Table[X, Table[Y, Tile[T]]]
    tilesAsList: seq[Tile[T]]
    chunks: Table[X, Table[Y, Chunk[T]]]


var tileTextures: Table[string, TextureAtlasTexture]




#################################################################################
#
#
#
#
#   TILE 
#
#
#
#
#################################################################################
####
## GAMETILE
####

proc x*[T:GameTile](self: Tile[T]): int = self.x * self.map.tileSizeInPixels
proc y*[T:GameTile](self: Tile[T]): int = self.y * self.map.tileSizeInPixels
proc gameTile*[T:GameTile](self: Tile[T]): T = self.gameTile
proc `$`*[T:GameTile](self: Tile[T]): string = 
    return "Tile: " & $self.x & "," & $self.y

proc newTile[T:GameTile](map: var Map[T], x, y: int): Tile[T] =
    result = Tile[T]()
    result.x = x
    result.y = y
    result.plannedTravelWeight = 0.0 
    if not map.tiles.hasKey(x):
        map.tiles[x] = initTable[Y, Tile[T]]()
    map.tiles[x][y] = result
    return result

proc drawTile[T:GameTile](self: Tile[T]) =
    let x = self.x * 32
    let y = self.y * 32
    let texture = tileTextures["gray"]
    texture.draw(x, y)
    #if passable:
    let texture2 = tileTextures["green_outline"]
    texture2.draw(x, y)




#################################################################################
#
#
#
#
#   CHUNK FUNCTIONS
#
#
#
#
#################################################################################
#########
##  CHUNK FUNCTIONS
#########

proc `$`*[T:GameTile](self: Chunk[T]): string = 
    return "Chunk: " & $self.x & "," & $self.y





#################################################################################
#
#
#
#
#   MAP FUNCTIONS
#
#
#
#
#################################################################################
#########
##  MAP FUNCTIONS
#########

proc getChunkAt*[T:GameTile](self: Map[T], x,y:int): Option[Chunk[T]] = 
    let xAsNum = x.floorDiv self.chunkSizeInTiles
    let yAsNum = y.floorDiv self.chunkSizeInTiles
    if self.chunks.hasKey(xAsNum) and self.chunks[xAsNum].hasKey(yAsNum):
        return some[Chunk[T]](self.chunks[xAsNum][yAsNum])
    else:
        return none(Chunk[T])

proc newChunk*[T:GameTile](
    map: var Map[T], 
    x, y: int,
    createGameTileCallback: proc(m: Map[T], chunk: Chunk[T], tile: Tile[T]): T 
): Chunk[T] =

    result = Chunk[T]()
    result.x = x
    result.y = y
    for tileX in 0 ..< map.chunkSizeInTiles:
        for tileY in 0 ..< map.chunkSizeInTiles:
            var t = newTile[T](
                map, 
                x * map.chunkSizeInTiles + tileX, 
                y * map.chunkSizeInTiles + tileY
            )
            t.gameTile = createGameTileCallback(map, result, t)
            result.tiles.add t 

    return result


proc newMap*[T:GameTile](
    sideLenInChunks: int, 
    createGameTileCallback: proc(m: Map[T], chunk: Chunk[T], tile: Tile[T]): T, 
    chunkSizeInTiles:int = 16,
    tileSizeInPixels:int = 32,
): Map[T] =
    result= Map[T]()
    result.chunkSizeInTiles = chunkSizeInTiles
    result.tileSizeInPixels = tileSizeInPixels
    result.tiles = initTable[X, Table[Y, Tile[T]]]()
    result.tilesAsList = @[]
    result.chunks = initTable[X, Table[Y, Chunk[T]]]()
    for x in 0 ..< sideLenInChunks:
        result.chunks[x] = initTable[Y, Chunk[T]]()
        for y in 0 ..< sideLenInChunks:
            var chunk = newChunk[T](result, x, y, createGameTileCallback)
            result.chunks[x][y] = chunk
            chunk.map = result
            for tile in result.chunks[x][y].tiles:
                result.tiles[tile.x][tile.y] = tile
                result.tilesAsList.add(tile)
                result.tiles[tile.x][tile.y].map = result
    return result 

proc drawMap*[T:GameTile](self: Map[T]) =
    for tile in self.tilesAsList:
        tile.drawTile()
        if tile.gameTile.isSelected():
            let x = tile.x * 32
            let y = tile.y * 32
            let texture = tileTextures["blue_outline"]
            texture.draw(x, y)
        if not tile.gameTile.isPassable():
            let x = tile.x * 32
            let y = tile.y * 32
            let texture = tileTextures["red_outline"]
            texture.draw(x, y)


proc getTileAt*[T: GameTile](self: Map[T], x,y:int): Option[Tile[T]] = 
    let xAsNum = x.floorDiv self.tileSizeInPixels
    let yAsNum = y.floorDiv self.tileSizeInPixels
    if self.tiles.hasKey(xAsNum) and self.tiles[xAsNum].hasKey(yAsNum):
        return some[Tile[T]](self.tiles[xAsNum][yAsNum])
    else:
        return none(Tile[T])


proc getTileAtNum*[T:GameTile](self: Map[T], x,y:int): Option[Tile[T]] =
    if self.tiles.hasKey(x) and self.tiles[x].hasKey(y):
        return some[Tile[T]](self.tiles[x][y])
    else:
        return none(Tile[T])





#################################################################################
#
#
#
#
#   WRITE TO FILE
#
#
#
#
#################################################################################
#########
# Write to file functions
#########

proc `%`*[T: GameTile](map: Map[T]) : string = 
    ## returns a string representation of the map
    ## Used for writing to file or snapshotting
    return %{ 
        "chunkSizeInTiles": %(map.chunkSizeInTiles),
        "tileSizeInPixels": %(map.tileSizeInPixels),
        "tiles":            %(map.tilesAsList),
        "chunks":           %(map.chunks)
    }

proc `%`*[T: GameTile](chunk: Chunk[T]) : string = 
    ## returns a string representation of the chunk
    ## Used for writing to file or snapshotting
    return %{ 
        "x": %(chunk.x),
        "y": %(chunk.y),
        "tiles": %(chunk.tiles)
    }

proc `%`*[T: GameTile](tile: Tile[T]) : string = 
    ## returns a string representation of the tile
    ## Used for writing to file or snapshotting
    return %{ 
        "x": %(tile.x),
        "y": %(tile.y),
        "plannedTravelWeight": %(tile.plannedTravelWeight),
        "gameTile": %(tile.gameTile) # this is why we need the GameTile concept "%"
    }

proc tileFromJson*[T: GameTile](
    node: JsonNode, 
    map: Map[T],
    unserializeGivenGameTileCallback: proc(node: JsonNode): T
): Tile[T] = 
    ## Creates a tile from a json node
    ## Used for loading from file or snapshotting
    result = Tile[T]()
    result.x = node["x"].getInt()
    result.y = node["y"].getInt()
    result.map = map
    result.plannedTravelWeight = node["plannedTravelWeight"].getFloat()
    result.gameTile = unserializeGivenGameTileCallback(node["gameTile"])

    return result


proc chunkFromJson*[T: GameTile](
    node: JsonNode, 
    map: Map[T],
    unserializeGivenGameTileCallback: proc(node: JsonNode): T
): Chunk[T] = 
    ## Creates a chunk from a json node
    ## Used for loading from file or snapshotting
    result = Chunk[T]()
    result.map = map
    result.x = node["x"].getInt()
    result.y = node["y"].getInt()
    result.tiles = initTable[X, Table[Y, Tile[T]]]()

    for tileNode in node["tiles"].getArray():
        let tile = tileFromJson[T](tileNode, unserializeGivenGameTileCallback)
        result.tiles[tile.x][tile.y] = tile
        result.tiles[tile.x][tile.y].map = result

    return result

proc mapFromJson*[T: GameTile](
    node: JsonNode, 
    unserializeGivenGameTileCallback: proc(node: JsonNode): T
): Map[T] = 
    ## Creates a map from a json node
    ## Used for loading from file or snapshotting
    result = Map[T]()
    result.chunkSizeInTiles = node["chunkSizeInTiles"].getInt()
    result.tileSizeInPixels = node["tileSizeInPixels"].getInt()
    result.tiles = initTable[X, Table[Y, Tile[T]]]()
    result.tilesAsList = @[]
    result.chunks = initTable[X, Table[Y, Chunk[T]]]()

    for chunkNode in node["chunks"].getArray():
        let chunk = chunkFromJson[T](chunkNode, result, unserializeGivenGameTileCallback)
        result.chunks[chunk.x][chunk.y] = chunk

    for tileNode in node["tiles"].getArray():
        let tile = tileFromJson[T](tileNode, result, unserializeGivenGameTileCallback)
        result.tiles[tile.x][tile.y] = tile
        result.tilesAsList.add(tile)

    return result

proc writeToFile*[T: GameTile](
    map: Map[T], 
    fileName: string
) = 
    ## Writes the map to a file
    
    let filePath 
        = if fileName.endsWith("/"): ABSOLUTE_PATH & fileName
        else: ABSOLUTE_PATH & "/" & fileName
    
    var file = open(filePath, fmWrite)
    file.writeLine( map.serialize() )

proc readFromFile*[T: GameTile](
    fileName: string, 
    unserializeGivenGameTileCallback: proc(node: JsonNode): T
): Map[T] = 
    ## Reads the map from a file
    let filePath 
        = if fileName.endsWith("/"): ABSOLUTE_PATH & fileName
        else: ABSOLUTE_PATH & "/" & fileName
    var file = open(filePath, fmRead)
    let content = file.readLine()
    let node = parseJson(content)
    return mapFromJson[T](node, unserializeGivenGameTileCallback








#################################################################################
#
#
#
#
#   TEXTURE FUNCTIONS
#
#
#
#
#################################################################################
#########
##  TEXTURE FUNCTIONS 
#########

proc initMapTextures*() = 
    var ei = newEditableImage("tiles.png")
    #echo ei.getPixel(32*7-1,0)# (9, 120, 0; 255)
    ei.replaceColor(PixelValue(r: 9, g: 120, b: 0, a: 255), PixelValueWhite)

    let  tileAtlas= ei.makeImageFromEImage()
    tileTextures = block:
        var textures = initTable[string, TextureAtlasTexture]()
        let all = readLineOfTextureAtlas(
            fromImage=tileAtlas,
            num=7,
            widthPX=32,
            heigthPX=32, 
            rowNumber=0, 
            startPosition=0
        )
        textures["green_outline"] = all[0]
        textures["blue_outline"] = all[1]
        textures["red_outline"] = all[2]
        textures["lightblue_outline"] = all[3]
        textures["yellow_outline"] = all[4]
        textures["gray"] = all[5]
        textures["white"] = all[6]
        textures 

proc getMapTextures*(): Table[string, TextureAtlasTexture] = 
    if tileTextures.len == 0: initMapTextures()
    return tileTextures





#################################################################################
#
#
#
#
#   ASTAR
#
#
#
#
#################################################################################

type
    FrontierElem[T: GameTile] = tuple[node: Tile[T], priority: float, cost: float]
        ## Internally used to associate a graph node with how much it costs

    CameFrom[T: GameTile] = tuple[node: Tile[T], cost:float]
        ## Given a node, this stores the node you need to backtrack to to get
        ## to this node and how much it costs to get here

iterator backtrack[T: GameTile](
    cameFrom: Table[Tile[T], CameFrom[T]], start, goal: Tile[T]
): Tile[T] =
    ## Once the table of back-references is filled, this yields the reversed
    ## path back to the consumer
    yield start

    var current: Tile[T] = goal
    var path: seq[Tile[T]] = @[]

    while current != start:
        path.add(current)
        current = `[]`(cameFrom, current).node

    for i in countdown(path.len - 1, 0):
        yield path[i]

proc calcHeuristic[T: GameTile] (
    graph: Chunk[T],
    next, start, goal: Tile[T],
    current: FrontierElem[T],
    cameFrom: Table[Tile[T], CameFrom[T]],
): float {.inline.} =
    ## Delegates the heuristic call off to the matching function
    when compiles(graph.heuristic(next, start, goal, current.node)):
        return graph.heuristic(next, start, goal, current.node)

    elif compiles(graph.heuristic(next, start, goal, current.node, none(T))):
        var grandparent: Option[T]
        if cameFrom.hasKey(current.node):
            grandparent = some[T]( `[]`(cameFrom, current.node).node )
        else:
            grandparent = none(T)
        return graph.heuristic(next, start, goal, current.node, grandparent)

    else:
        return graph.heuristic(next, goal)

iterator path*[T: GameTile](graph: Chunk[T], start, goal: Tile[T]): Tile[T] =
    ## Executes the A-Star algorithm and iterates over the nodes that connect
    ## the start and goal

    # The frontier is the list of nodes we need to visit, sorted by a
    # combination of cost and how far we estimate them to be from the goal
    var frontier = newHeap[FrontierElem[T]] do (a, b: FrontierElem[T]) -> int:
            return cmp(a.priority, b.priority)

    # Put the start node into the frontier so we have a place to kick off
    frontier.push( (node: start, priority: 0.0, cost: 0.0) )

    # A map of backreferences. After getting to the goal, you use this to walk
    # backwards through the path and ultimately find the reverse path
    var cameFrom = initTable[Tile[T], CameFrom[T]]()

    while frontier.size > 0:
        echo "frontier size: " & $frontier.size
        let current = frontier.pop

        # Now that we have a map of back-references, yield the path back out to
        # the caller
        if current.node == goal:
            for node in backtrack(cameFrom, start, goal):
                yield node
            break

        for next in graph.neighbors(current.node):

            # The cost of moving into this node from the goal
            let cost = current.cost + graph.cost(current.node, next) 

            # If we haven't seen this point already, or we found a cheaper
            # way to get to that
            if not cameFrom.hasKey(next) or cost < `[]`(cameFrom, next).cost:

                # Add this node to the backtrack map
                `[]=`(cameFrom, next, (node: current.node, cost: cost))

                # Estimate the priority of checking this node
                let priority: float = cost + calcHeuristic[T](
                    graph, next, start, goal, current, cameFrom )

                # Also add it to the frontier so we check out its neighbors
                frontier.push( (next, priority, cost) )


#################################################################################
#
#
#
#
#   PATHFINDING
#
#
#
#
#################################################################################
########
## PATHFINDING - for now chunk based  (for astar-lib)
########

# For the tile:
proc `==`*[T:GameTile](self: Tile[T], other: Tile[T]): bool = return self.x == other.x and self.y == other.y
proc `hash`*[T:GameTile](n: Tile[T]): Hash = return ($n).hash

iterator neighbors*[T:GameTile]( grid: Chunk[T], tile: Tile[T] ): Tile[T] =
    echo "neighbors of " & $tile
    let lenOfChunk = grid.map.chunkSizeInTiles
    ## An iterator that yields the neighbors of a given tile
    echo "lenOfChunk: " & $lenOfChunk
    # y and x are switched because the grid is stored as [y][x]
    echo "tile.y: " & $tile.y
    echo "tile.x: " & $tile.x
    if tile.y > 0:  
        echo "yielding " & $grid.map.getTileAtNum(tile.y-1, tile.x).get  
        let t = grid.map.getTileAtNum(tile.y-1, tile.x).get   
        if t.gameTile.isPassable(): yield t #     
    if tile.y < lenOfChunk - 1:   
        echo "yielding " & $grid.map.getTileAtNum(tile.y+1, tile.x).get
        let t = grid.map.getTileAtNum(tile.y+1, tile.x).get
        if t.gameTile.isPassable(): yield t #
        yield grid.map.getTileAtNum(tile.y+1, tile.x).get  # grid[tile.y + 1][tile.x]
    if tile.x > 0:                
        echo "yielding " & $grid.map.getTileAtNum(tile.y, tile.x-1).get
        let t = grid.map.getTileAtNum(tile.y, tile.x-1).get
        if t.gameTile.isPassable(): yield t #
        yield t
    if tile.x < lenOfChunk - 1:   
        echo "yielding " & $grid.map.getTileAtNum(tile.y, tile.x+1).get
        let t = grid.map.getTileAtNum(tile.y, tile.x+1).get
        if t.gameTile.isPassable(): yield t #
        yield t

proc cost*[T:GameTile](grid: Chunk[T], a, b: Tile[T]): float =
    ## Returns the cost of moving from point `a` to point `b`
    return abs(float(a.x - b.x) + float(a.y - b.y))

proc heuristic*[T:GameTile]( grid: Chunk[T], node, goal: Tile[T] ): float =
    ## Returns the priority of inspecting the given node
    return sqrt(
        pow(float(node.x) - float(goal.x), 2) +
        pow(float(node.y) - float(goal.y), 2) ) 


proc getPathFromTo*[T:GameTile](grid: Chunk[T], start, goal: Tile[T]): seq[Tile[T]] =
    ## Returns a path from the start to the goal, if one exists
    ## TODO: leaving it a iterator might improve performance ???
    echo "Calculating path from " & $start & " to " & $goal
    var lpath: seq[Tile[T]] = @[]
    for point in path[T](grid, start, goal):
        lpath.add(point)
    return lpath
static:
    echo "astar loaded"