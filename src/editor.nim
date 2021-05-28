import fcore, ui/ui, strformat, state

proc processEditor*() =

  #draw tool buttons
  let bsize = fau.widthf / (Tool.high.float32 + 1f)

  for i in Tool.low..Tool.high:
    if button(rect(i.float32 * bsize, 0, bsize, bsize), icon = (&"icon-{$i}").patch, toggled = curTool == i):
      curTool = i