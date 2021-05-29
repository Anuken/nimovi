import fau/[fcore, shapes], state
import stb_image/read as stbi

var
  canvasPos = vec2(0f, 0f)
  zoom = 1f
  lastDrag: Vec2i
  dragging = false
  drags: seq[Vec2i]

proc toCanvas*(vec: Vec2): Vec2i =
  var size = min(fau.widthf, fau.heightf) * zoom
  var raw = (vec - screen()/2f - canvasPos * zoom + vec2(size/2f)) / size * canvas.wh
  return vec2i(raw.x.int, canvas.height - 1 - raw.y.int)

template drawable(tool: Tool): bool = tool == tPencil or tool == tErase

addFauListener(proc(e: FauEvent) =
  case e.kind:
  of feTouch:
    if e.touchDown and e.touchId == 0:
      let pos = vec2(e.touchX, e.touchY).toCanvas
      if curTool.drawable:
        lastDrag = pos
        if pos.inside(canvas.width, canvas.height):
          drags.add lastDrag
      elif curTool == tPick:
        if pos.inside(canvas.width, canvas.height):
          canvas.push()
          let data = readPixels(pos.x, pos.y, 1, 1)
            
          var 
            found = false
            color = cast[ptr Color](data)[]

          color.av = 255'u8

          for i, col in curPalette.colors:
            if col == color:
              switchColor(i)
              found = true
              break
          
          if not found:
            changeColor(color)
          
          dealloc data
          canvas.pop()
  of feDrag:
    if keyMouseLeft.down and e.dragId == 0:
      if curTool.drawable:
        let next = vec2(e.dragX, e.dragY).toCanvas

        #use bresenham's algorithm to link points
        for point in line(lastDrag, next):
          if point != lastDrag and point.inside(canvas.width, canvas.height):
            drags.add point
          lastDrag = point
  of feScroll:
    zoom += e.scrollY / 10f * zoom
    zoom = clamp(zoom, 1f / 20f, 20f)
  else: discard
)

proc loadCanvas*(path: string) =
  ## Loads an image into the canvas. This may throw an exception!
  var
    width, height, channels: int
    data: seq[uint8]

  data = stbi.load(path, width, height, channels, 4)

  #TODO error handling
  canvas = newFramebuffer(width, height)
  canvas.texture.load(width, height, addr data[0])

proc initCanvas*(w, h: int) =
  ## Creates a new buffer for holding the canvas. This does not clear the buffer.
  canvas = newFramebuffer(w, h)

proc processCanvas*() =
  var size = min(fau.widthf, fau.heightf) * zoom
  var alpha = "alpha".patch

  if curTool == tZoom and fau.touches[0].down:
    canvasPos += fau.touches[0].delta / zoom

  if drags.len > 0:
    fau.batchSort = false
    
    if curTool == tErase: blendErase.drawBlend()

    canvas.push()
    drawMat(ortho(0, 0, canvas.width, canvas.height))
    for drag in drags:
      fillRect(drag.x.int, drag.y.int, 1, 1, color = curColor)
    drags.setLen 0
    canvas.pop()
    screenMat()
    fau.batchSort = true

    if curTool == tErase: blendNormal.drawBlend()

  let scl = 1f
  alpha.u = 0f
  alpha.v = 0f
  alpha.u2 = canvas.texture.width * zoom * scl
  alpha.v2 = canvas.texture.height * zoom * scl

  let pos = canvasPos * zoom + screen()/2f

  lineRect(pos.x - size/2f, pos.y - size/2f, size, size, stroke = 4f, color = colorRoyal)
  draw(alpha, pos.x, pos.y, size, size)
  draw(canvas.texture, pos.x, pos.y, size, size)

  