version       = "0.0.1"
author        = "Anuken"
description   = "none"
license       = "GPL-3.0"
srcDir        = ""
bin           = @["nimovi"]
binDir        = "build"

requires "nim >= 1.4.2"
requires "jsony >= 1.0.1"
#requires "https://github.com/Anuken/fau#" & staticExec("git -C fau rev-parse HEAD")

import strformat, os, json, sequtils

template shell(args: string) =
  try: exec(args)
  except OSError: quit(1)

const app = "nimovi"

task pack, "Pack textures":
  shell &"faupack -p:{getCurrentDir()}/assets-raw/sprites -o:{getCurrentDir()}/assets/atlas"

task debug, "Debug build":
  shell &"nim r -d:debug src/{app}"

task release, "Release build":
  shell &"nim r -d:release -d:danger -o:build/{app} src/{app}"

task androidBuild, "Android build":
  var cmakeText = "android/CMakeLists.txt".readFile()

  mkDir "android/src"
  cpFile("android/CMakeLists.txt", "android/src/CMakeLists.txt")

  for arch in ["32", "64"]:
    if dirExists(&"android/src/c{arch}"):
      rmDir &"android/src/c{arch}"
    let cpu = if arch == "32": "" else: "64"

    shell &"nim c -f --compileOnly --cpu:arm{cpu} --os:android -d:danger -c --noMain:on --nimcache:android/src/c{arch} src/{app}.nim"
    var 
      includes: seq[string]
      sources: seq[string]

    let compData = parseJson(readFile(&"android/src/c{arch}/{app}.json"))
    let compList = compData["compile"]
    for arr in compList.items:
      sources.add($arr[0])
    
    #scrape includes from C arguments
    if compList.len > 0:
      let firstCommand = compList[0][1]
      let split = ($firstCommand).split(" ").filterIt(it.startsWith("-I")).mapIt(it[2..^1]).mapIt(if it.startsWith("'"): it[1..^2] else: it)
      includes.add split

    cmakeText = cmakeText
    .replace("${NIM_SOURCES_" & arch & "}", sources.join("\n"))
    .replace("${NIM_INCLUDE_DIR}", includes.mapIt("\"" & it & "\"").join("\n"))

  writeFile("android/src/CMakeLists.txt", cmakeText)

task android, "Android Run":
  androidBuildTask()
  cd "android"
  shell "./gradlew run"

task androidDebug, "Android Run":
  androidBuildTask()
  cd "android"
  shell "./gradlew assembleDebug"