## A logger that logs stuff at a position on the screen and the newses message is always at the bottom
## 
## 
import ../nimlove
import text

var logMessages: seq[string] = @[];

proc slog*(msg: string) =
  logMessages.add(msg)
  if logMessages.len > 10:
    logMessages = logMessages[1..^1]

proc drawLogs*(startX, startY: int, color: Color = Black) =
  for i, msg in logMessages:
    drawText(msg, startX, startY + i * 20,color=color)