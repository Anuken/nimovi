import fcore

type Tool* = enum
  tPencil = "pencil",
  tErase = "eraser",
  tFill = "fill",
  tPick = "pick",
  tZoom = "zoom",
  tUndo = "undo",
  tRedo = "redo"

var 
  curTool* = Tool.low
  canvas*: Framebuffer
  canvasGrid*: bool
  cursorMode*: bool