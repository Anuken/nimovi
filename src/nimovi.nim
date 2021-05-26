import fcore, ui/ui

#enable once UI becomes a thing
#static: echo staticExec("faupack -p:../assets-raw/sprites -o:../assets/atlas")

proc init() =
  echo "Nimovi: init()"

proc run() =
  if keyEscape.tapped: quitApp()

  drawMat(ortho(0, 0, fau.widthf, fau.heightf))

  lineRect(0, 0, fau.widthf, fau.heightf, color = rgb(0, 1, 1), stroke = 5f)

  if button(rect(fau.width/2f, fau.heightf/2f, 300, 60), region = "circle".patch):
    echo "button pressed"

initFau(run, init, windowTitle = "nimovi")
