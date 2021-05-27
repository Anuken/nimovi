import fcore, ui/ui
import stb_image/read as stbi

var
  canvas*: Framebuffer
  canvasGrid*: bool

  canvasX = 0f
  canvasY = 0f
  zoom = 1f
  dragging = false

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
  var size = min(fau.widthf, fau.heightf)
  var alpha = "alpha".patch

  alpha.u = 0f
  alpha.v = 0f
  alpha.u2 = canvas.texture.width
  alpha.v2 = canvas.texture.height

  draw(alpha, fau.widthf/2f, fau.heightf/2f, size, size)

  draw(canvas.texture, fau.widthf/2f, fau.heightf/2f, size, size)

  