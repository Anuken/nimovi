import fau/[fcore], state
import stb_image/read as stbi

var
  lastDrag: Vec2i
  dragging = false
  drags: seq[Vec2i]

proc toCanvas*(vec: Vec2): Vec2i =
  var size = min(fau.widthf, fau.heightf) * zoom
  var raw = (vec - screen()/2f - canvasPos * zoom + vec2(size/2f)) / size * canvas.wh
  return vec2i(raw.x.int, canvas.height - 1 - raw.y.int)

template drawable(tool: Tool): bool = tool == tPencil or tool == tErase

proc fill*(pos: Vec2i) =
  canvas.push()

  #check for destination as a single pixel
  let 
    single = readPixels(pos.x, pos.y, 1, 1)
    dst = cast[ptr Color](single)[]

  single.dealloc

  if dst == curColor:
    canvas.pop()
    return

  var
    data = readPixels(0, 0, canvas.width, canvas.height)
    colors = cast[ptr UncheckedArray[Color]](data)
    points: seq[Vec2i]
    cur = curColor
    w = canvas.width
    h = canvas.height

  template col(x, y: int): Color = colors[x + y * w]
  template set(x, y: int, col: Color) = colors[x + y * w] = col
  template test(x, y: int): bool = col(x, y) == dst
  
  points.add vec2i(pos.x, pos.y)
  
  while points.len > 0:
    let 
      next = points.pop
      y = next.y

    var x1 = next.x
    while x1 >= 0 and test(x1, y): x1.dec
    x1.inc
    var
      spanAbove = false
      spanBelow = false
    
    while x1 < w and test(x1, y):
      set(x1, y, cur)

      if not spanAbove and y > 0 and test(x1, y - 1):
        points.add vec2i(x1, y - 1)
        spanAbove = true
      elif spanAbove and not test(x1, y - 1):
        spanAbove = false
      
      if not spanBelow and y < h - 1 and test(x1, y + 1):
        points.add vec2i(x1, y + 1)
        spanBelow = true
      elif spanBelow and y < h - 1 and not test(x1, y + 1):
        spanBelow = false
      
      x1.inc
  
  canvas.pop()

  canvas.texture.update(0, 0, w, h, data)

  dealloc data

proc pick*(pos: Vec2i) =
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

proc tapped(pos: Vec2i) =
  if curTool.drawable:
    lastDrag = pos
    if pos.inside(canvas.width, canvas.height):
      drags.add lastDrag
  elif curTool == tPick or curTool == tFill:
    if pos.inside(canvas.width, canvas.height):
      if curTool == tPick: pick(pos)
      else: fill(pos)

proc dragged(pos: Vec2i) =
  if curTool.drawable:
    #use bresenham's algorithm to link points
    for point in line(lastDrag, pos):
      if point != lastDrag and point.inside(canvas.width, canvas.height):
        drags.add point
      lastDrag = point

addFauListener(proc(e: FauEvent) =
  case e.kind:
  of feTouch:
    if e.touchDown and e.touchId == 0:
      tapped(e.touchPos.toCanvas)
  of feDrag:
    if keyMouseLeft.down and e.dragId == 0:
      dragged(e.dragPos.toCanvas)
  of feScroll:
    #for debugging only
    zoom += e.scroll.y / 10f * zoom
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
  ## Creates a new buffer for holding the canvas. #TODO don't clear the buffer?
  canvas = newFramebuffer(w, h)
  canvas.clear()

proc processCanvas*() =

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

  