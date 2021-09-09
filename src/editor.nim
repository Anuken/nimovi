import fau/[fcore, ui], strformat, state, math

proc drawCanvas() =
  var size = min(fau.widthf, fau.heightf) * zoom
  var alpha = "alpha".patch

  let scl = 1f
  alpha.u = 0f
  alpha.v = 0f
  alpha.u2 = canvas.texture.width * zoom * scl
  alpha.v2 = canvas.texture.height * zoom * scl

  let pos = canvasPos * zoom + fau.screen/2f
  
  draw(alpha, pos, size.vec2)
  draw(canvas.texture, pos, size.vec2)

  lineRect(pos - size/2f, size.vec2, stroke = 4f.uis, color = downColor, margin = 2.uis)

proc drawPalette() =
  let 
    tmh = 60.uis #top menu button height
    minSize = 60f.uis #minimum size, disregarding rows
    pad = 10f.uis #padding on left and right of screen
    colors = curPalette.colors.len
    awidth = fau.widthf - pad*2f #available width
    maxFit = (awidth / minSize).int #maximum amount of colors that can fit per row
    psize = max(awidth / maxFit, awidth / colors)
    colorsPerRow = min(maxFit, colors)
    yoff = -5f.uis - tmh
    xoff = (fau.widthf - colorsPerRow * psize) / 2f

  if button(rect(0, fau.heightf - tmh, fau.widthf, tmh), icon = (if topMenu: "icon-up" else: "icon-down").patch):
    topMenu = not topMenu

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
      lineRect(bounds, stroke = 10f.uis, color = downColor, z = 1f)

    if (i+1) mod colorsPerRow == 0:
      row.inc

proc drawTools() =
  let 
    bsize = fau.widthf / (Tool.high.float32 + 1f)
    offset = fau.insets[2].abs
    bmh = 60.uis #bottom menu button height
    menubot = offset + bsize + bmh
  
  if botMenu:
    fillRect(0, menubot, fau.widthf, 200.uis, color = upColor)
    var bs = brushSize.float32
    let bounds = rect(0, menubot + 40.uis, fau.widthf, 60.uis)
    slider(bounds, 0, maxBrushes - 1, bs)
    text(bounds, &"Brush Size: {$(brushSize + 1)}")
    brushSize = bs.int

  if fau.insets[2] != 0f:
    fillRect(0, 0, fau.widthf, offset, color = upColor)
  
  for i in Tool.low..Tool.high:
    if button(rect(i.float32 * bsize, offset, bsize, bsize), icon = (&"icon-{$i}").patch, toggled = curTool == i):
      curTool = i
  
  #TODO not sure if bot menu is a good idea
  if button(rect(0, offset + bsize, fau.widthf, bmh), icon = (if botMenu: "icon-down" else: "icon-up").patch):
    botMenu = not botMenu

proc processEditor*() =
  drawCanvas()
  drawPalette()
  drawTools()
  
  