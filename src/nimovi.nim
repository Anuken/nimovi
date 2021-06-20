import fau/[fcore, ui], drawing, editor, tables, nio, state

#enable once UI becomes a thing
#static: echo staticExec("faupack -s -p:../assets-raw/sprites -o:../assets/atlas")

proc init() =
  echo "Nimovi: init()"

  loadConfig()

  uiScale = when not defined(Android): 1f else: fau.screenDensity/2f
  uiPatchScale = 4f * uiScale
  uiFontScale = 3f * uiScale
  defaultButtonStyle = ButtonStyle(upColor: upColor, downColor: downColor, overColor: overColor)
  defaultSliderStyle = SliderStyle(backColor: colorBlack, back: "white".patch9, up: "button".patch9, down: "button-down".patch9, sliderWidth: 30f)
  defaultFont = loadFont("font.ttf")

  var alphaTex = loadTextureStatic("alpha.png")
  alphaTex.wrapRepeat()
  fau.atlas.patches["alpha"] = alphaTex

  for i in 0..<maxBrushes:
    brushes[i] = fau.atlas.patches["brush" & $(i + 1)]

  initCanvas(32, 32)

proc run() =
  if keyEscape.tapped: quitApp()

  screenMat()

  processCanvas()
  processEditor()

  #discard button(rect(fau.widthf/2f, fau.heightf/2f, 300, 120), $fau.insets)

initFau(run, init, windowTitle = "nimovi", maximize = false, windowWidth = 600, windowHeight = 1200, clearColor = backColor)