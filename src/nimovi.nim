import fcore

#enable once UI becomes a thing
#static: echo staticExec("faupack -p:../assets-raw/sprites -o:../assets/atlas")

proc init() =
  echo "Nimovi: init()"

proc run() =
  if keyEscape.tapped: quitApp()

  drawMat(ortho(0, 0, fau.widthf, fau.heightf))

  lineRect(0, 0, fau.widthf, fau.heightf, color = rgb(0, 0, 1), stroke = 5f)

initFau(run, init, windowTitle = "nimovi")
