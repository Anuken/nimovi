import fcore, ui/ui

#enable once UI becomes a thing
static: echo staticExec("faupack -s -p:../assets-raw/sprites -o:../assets/atlas")

const text = ["do not click", "5", "4", "3", "2", "1", "nothing"]
var i = 0

proc init() =
  echo "Nimovi: init()"
  uiPatchScale = 5f
  defaultButtonStyle = ButtonStyle(up: "button".patch9, down: "button-down".patch9, overColor: rgba(1, 1, 1, 0.2f))
  defaultFont = loadFont("font.ttf")
  uiFontScale = 3f

proc run() =
  if keyEscape.tapped: quitApp()

  drawMat(ortho(0, 0, fau.widthf, fau.heightf))

  lineRect(0, 0, fau.widthf, fau.heightf, color = rgb(0, 1, 1), stroke = 5f)

  if button(rect(fau.width/2f, fau.heightf/2f, 340, 60), text[i]):
    echo "button pressed"
    i.inc

initFau(run, init, windowTitle = "nimovi")