import fcore, ui/ui, strformat, state

proc processToolbox*() =
  let size = fau.widthf / (Tool.high.float32 + 1f)

  for i in Tool.low..Tool.high:
    if button(rect(i.float32 * size, 0, size, size), icon = (&"icon-{$i}").patch, toggled = curTool == i):
      curTool = i
      echo i