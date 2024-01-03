## Global camera.
## The idea is to create  a camera object
## that allows to only draw what is within the camera's view.
## You can register a camera to specific images, textureatlases and sounds.
## Also to the map.
## A camera is always as big as the screen.
import ../nimlove
import std/json 

# todo: add max zoom and min zoom
# todo: apply camera to all of the above listed objects

type Camera* = ref object
    zoom: float
    x: float
    y: float
    zoomCorrectionX: float
    zoomCorrectionY: float

proc newCamera*(zoom: float = 1.0): Camera =
    result = Camera(zoom:zoom, x:0.0, y:0.0)

proc zoom*(camera: Camera): float =
    camera.zoom

proc zoomIn*(camera: Camera) =
    let screenWidth = nimlove.getWindowWidth().float
    let screenHeight = nimlove.getWindowHeight().float
    camera.zoom += 0.03
    camera.zoomCorrectionX = (camera.zoom - 0.03) * screenWidth / 2
    camera.zoomCorrectionY = (camera.zoom - 0.03) * screenHeight / 2
    # move camera to center of screen
    # if we zoom in, we need to 
    


proc zoomOut*(camera: Camera) =
    let screenWidth = nimlove.getWindowWidth().float
    let screenHeight = nimlove.getWindowHeight().float
    camera.zoom -= 0.1
    camera.zoomCorrectionX = (camera.zoom + 0.1) * screenWidth / 2
    camera.zoomCorrectionY = (camera.zoom + 0.1) * screenHeight / 2

proc move*(camera: Camera, x, y: float) =
    camera.x += x
    camera.y += y

proc moveX*(camera: Camera, x: float) =
    camera.x += x

proc moveY*(camera: Camera, y: float) =
    camera.y += y

proc setX*(camera: Camera, x: float) =
    camera.x = x

proc setY*(camera: Camera, y: float) =
    camera.y = y

proc x*(camera: Camera): float =
    camera.x# + camera.zoomCorrectionX

proc y*(camera: Camera): float =
    camera.y# + camera.zoomCorrectionY

proc zoomCorrectionX*(camera: Camera): float =
    camera.zoomCorrectionX

proc zoomCorrectionY*(camera: Camera): float =
    camera.zoomCorrectionY

proc changeZoom*(camera: Camera, zoom: float) =
    camera.zoom = zoom

proc `%`*(camera: Camera): JsonNode =
    result = %{
        "__nimlove_type": %"Camera",
        "__nimlove_version": %"0.1.0",
        "zoom": %camera.zoom,
        "x": %camera.x,
        "y": %camera.y
    }

proc cameraFromJson*(node: JsonNode): Camera =
    result = newCamera()
    result.zoom = node["zoom"].getFloat()
    result.x = node["x"].getFloat()
    result.y = node["y"].getFloat()

# todo: maybe to the nimlove context??
var camera = newCamera()

proc getCamera*(): var Camera = camera
proc getCamX*(): float = camera.x
proc getCamY*(): float = camera.y
proc getCamZoom*(): float = camera.zoom

proc setCamera*(cam: Camera) =
    camera = cam
