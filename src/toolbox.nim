import fcore, ui/ui, strformat

type Tool* = enum
  tPencil = "pencil",
  tErase = "eraser",
  tFill = "fill",
  tPick = "pick",
  tZoom = "zoom",
  tUndo = "undo",
  tRedo = "redo"

var curTool* = Tool.low

proc processToolbox*() =
  let size = fau.widthf / (Tool.high.float32 + 1f)

  for i in Tool.low..Tool.high:
    if button(rect(i.float32 * size, 0, size, size), icon = (&"icon-{$i}").patch, toggled = curTool == i):
      curTool = i
      echo i