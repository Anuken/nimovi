import fau/[fcore, ui], drawing, editor, tables, nio

#enable once UI becomes a thing
#static: echo staticExec("faupack -s -p:../assets-raw/sprites -o:../assets/atlas")

proc init() =
  echo "Nimovi: init()"

  loadConfig()

  uiScale = fau.screenDensity/2f
  uiPatchScale = 4f * uiScale
  uiFontScale = 4f * uiScale
  defaultButtonStyle = ButtonStyle(up: "button".patch9, down: "button-down".patch9)
  defaultFont = loadFont("font.ttf")

  var alphaTex = loadTextureStatic("alpha.png")
  alphaTex.wrapRepeat()
  fau.atlas.patches["alpha"] = alphaTex

  initCanvas(32, 32)

proc run() =
  if keyEscape.tapped: quitApp()

  screenMat()

  processCanvas()
  processEditor()

  #text(rect(0, 0, fau.widthf, fau.heightf), "density: " & $fau.screenDensity)

initFau(run, init, windowTitle = "nimovi", maximize = false, windowWidth = 600, windowHeight = 1200, clearColor = colorBlack)