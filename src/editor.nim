import fau/[fcore, ui], strformat, state, math

proc drawCanvas() =
  var size = min(fau.widthf, fau.heightf) * zoom
  var alpha = "alpha".patch

  let scl = 1f
  alpha.u = 0f
  alpha.v = 0f
  alpha.u2 = canvas.texture.width * zoom * scl
  alpha.v2 = canvas.texture.height * zoom * scl

  let pos = canvasPos * zoom + screen()/2f
  
  draw(alpha, pos.x, pos.y, size, size)
  draw(canvas.texture, pos.x, pos.y, size, size)

  lineRect(pos.x - size/2f, pos.y - size/2f, size, size, stroke = 4f.uis, color = downColor, margin = 2.uis)

proc drawPalette() =
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
        iconSize = psize - 8f.uis,
        style = ButtonStyle(up: fau.white.patch9, iconUpColor: color, iconDownColor: color, upColor: upColor, downColor: downColor, overColor: overColor)
      ):
      switchColor(i)
    
    if curColor == color:
      lineRect(bounds.x, bounds.y, bounds.w, bounds.h, stroke = 10f.uis, color = downColor, z = 1f)

    if (i+1) mod colorsPerRow == 0:
      row.inc

proc drawTools() =
  let bsize = fau.widthf / (Tool.high.float32 + 1f)

  if fau.insets[2] != 0f:
    fillRect(0, 0, fau.widthf, fau.insets[2].abs, color = upColor)
  for i in Tool.low..Tool.high:
    if button(rect(i.float32 * bsize, fau.insets[2].abs, bsize, bsize), icon = (&"icon-{$i}").patch, toggled = curTool == i):
      curTool = i

proc processEditor*() =
  drawCanvas()
  drawPalette()
  drawTools()
  
  