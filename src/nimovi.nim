import fcore

#enable once UI becomes a thing
#static: echo staticExec("faupack -p:../assets-raw/sprites -o:../assets/atlas")

type Touch = tuple[x: float32, y: float32, col: Color]

var touches: seq[Touch]

proc init() =
  echo "Nimovi: init()"

proc run() =
  if keyEscape.tapped: quitApp()

  fau.cam.resize(fau.widthf, fau.heightf)
  fau.cam.pos = vec2(fau.widthf, fau.heightf)/2f
  fau.cam.use()

  fillPoly(0, 0, 6, 300)

  for v in touches:
    fillCircle(v.x, v.y, 20, color = v.col)

addFauListener(proc(e: FauEvent) =
  case e.kind:
  of feTouch:
    if e.touchDown:
      touches.add (e.touchX, e.touchY, rgba(1, 1, 0))
  of feDrag:
    #if keyMouseLeft.down:
    touches.add (e.dragX, e.dragY, rgba(0, 0, 1, 0.2f))
  else: discard
)

initFau(run, init, windowTitle = "nimovi")
