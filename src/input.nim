import fcore

var touches: array[10, Vec2]

addFauListener(proc(e: FauEvent) =
  case e.kind:
  of feTouch:
    if e.touchDown:
  of feDrag:
  else: discard
)