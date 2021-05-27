import fcore, ui/ui, canvas, toolbox, tables

#enable once UI becomes a thing
static: echo staticExec("faupack -s -p:../assets-raw/sprites -o:../assets/atlas")

var tog = false

proc init() =
  echo "Nimovi: init()"
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

  drawMat(ortho(0, 0, fau.widthf, fau.heightf))

  lineRect(0, 0, fau.widthf, fau.heightf, color = colorRoyal, stroke = 5f)

  processCanvas()
  processToolbox()

initFau(run, init, windowTitle = "nimovi", maximize = false, windowWidth = 600, windowHeight = 1200)
