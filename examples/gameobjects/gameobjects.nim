import ../../src/nimlove as nimlove
import ../../src/lovemodules/screenlogger as slogger

import gameobjectcontainer
import soldier

const WindowWidth = 800
const WindowHeight = 600

nimlove.setupNimLove(
  windowWidth = WindowWidth,
  windowHeight = WindowHeight,
  windowTitle = "NimLove",
  fullScreen = false,
)

soldier.loadSoldierResources()

var s = newSoldier(10, 20, 10)
echo "Soldier s " & infoStr s
slog "Soldier s " & infoStr s
s.x = 20000.0
s.x = s.x + 124.0

var someOtherSoldier = newSoldier(10, 20, 10)
someOtherSoldier.x = 20000.0
s.friend = someOtherSoldier

if s.hasFriend:
  echo "s has a friend " & infoStr s.friend
  slog "s has a friend " & infoStr s.friend
else:
  echo "s has no friend"
  slog "s has no friend"


var s3 = newSoldier(x=10, y=20, speed=10)

nimlove.runProgramm proc(delta_time: float) =
  slogger.drawLogs(100, 100)
  s3.x = s3.x + s3.speed * delta_time

  SoldierContainer.drawAll()
