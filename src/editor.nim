import fau/[fcore, ui], strformat, state, math

proc processEditor*() =
  #draw palette
  let 
    minSize = 60f.uis #minimum size, disregarding rows
    pad = 10f.uis #padding on left and right of screen
    colors = curPalette.colors.len
    awidth = fau.widthf - pad*2f #available width
    maxFit = (awidth / minSize).int #maximum amount of colors that can fit per row
    psize = max(awidth / maxFit, awidth / colors)
    colorsPerRow = min(maxFit, colors)
    yoff = -5f.uis
    xoff = (fau.widthf - colorsPerRow * psize) / 2f

  var row = 0

  for i, color in curPalette.colors:
    let bounds = rect((i mod colorsPerRow).float32 * psize + xoff, fau.heightf - psize - row*psize + yoff, psize, psize)
    if button(
        bounds, 
        icon = fau.white, toggled = curColor == color, 
        iconSize = psize - 6f.uis,
        style = ButtonStyle(up: "button".patch9, down: "button-down".patch9, iconUpColor: color, iconDownColor: color)
      ):
      switchColor(i)
    
    if curColor == color:
      lineRect(bounds.x, bounds.y, bounds.w, bounds.h, stroke = 10f.uis, color = colorCoral, z = 1f)

    if (i+1) mod colorsPerRow == 0:
      row.inc

  #draw tool buttons
  let bsize = fau.widthf / (Tool.high.float32 + 1f)

  for i in Tool.low..Tool.high:
    if button(rect(i.float32 * bsize, 0, bsize, bsize), icon = (&"icon-{$i}").patch, toggled = curTool == i):
      curTool = i