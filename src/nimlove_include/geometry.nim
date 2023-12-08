#proc putPixel*(x, y: int; col: Color = White) =
#  renderer.setDrawColor toSdlColor(col)
#  renderer.drawPoint(x.cint, y.cint)
  #var r = rect(cint(x), cint(y), cint(10), cint(10))
  #renderer.fillRect(r)