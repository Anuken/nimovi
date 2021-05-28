import fcore, ui/ui, drawing, editor, tables, state, nio

#enable once UI becomes a thing
#static: echo staticExec("faupack -s -p:../assets-raw/sprites -o:../assets/atlas")

proc init() =
  echo "Nimovi: init()"

  loadConfig()

  uiPatchScale = 4f
  defaultButtonStyle = ButtonStyle(up: "button".patch9, down: "button-down".patch9)
  defaultFont = loadFont("font.ttf")
  uiFontScale = 3f

  var alphaTex = loadTextureStatic("alpha.png")
  alphaTex.wrapRepeat()
  fau.atlas.patches["alpha"] = alphaTex

  initCanvas(32, 32)
  #loadCanvas("/home/anuke/Projects/Mindustry/core/assets-raw/sprites/units/mono.png")

proc run() =
  if keyEscape.tapped: quitApp()

  screenMat()

  #lineRect(0, 0, fau.widthf, fau.heightf, color = colorRoyal, stroke = 5f)

  processCanvas()
  processEditor()

initFau(run, init, windowTitle = "nimovi", maximize = false, windowWidth = 600, windowHeight = 1200)
