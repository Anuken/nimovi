import core, system, os, state, jsony, base64

proc dir*(project: Project): string = projectFolder / project.name.encode

proc imageFile*(project: Project): string = project.dir / "0.png"

proc file*(palette: Palette): string = paletteFolder / palette.name.encode

proc writePalette*(pal: Palette): Palette =
  let f = pal.file
  var output = newString(pal.colors.len * 3)
  for i, color in pal.colors:
    output[i * 3] = color.rv.char
    output[i * 3 + 1] = color.gv.char
    output[i * 3 + 2] = color.bv.char
  f.writeFile(output)

proc readPalette*(path: string, name: string): Palette =
  var str = path.readFile()
  let count = str.len div 3

  result.name = name
  for i in 0..<count:
    result.colors.add Color(
      rv: cast[uint8](str[i * 3]), 
      gv: cast[uint8](str[i * 3 + 1]), 
      bv: cast[uint8](str[i * 3 + 2]), 
      av: 255'u8
    )

proc loadConfig*() =
  #TODO test on linux
  let configDir = when defined(Android): "" else: getConfigDir() / "nimovi"

  paletteFolder = configDir / "palettes"
  projectFolder = configDir / "projects"

  let configFile = configDir / "config.json"

  if configFile.fileExists:
    try:
      appConfig = configFile.readFile.fromJson(AppConfig)
    except:
      echo "Failed to load app config file."
    
    for pal in palettes:
      if pal.name == appConfig.lastPalette:
        curPalette = pal
        break
  
  #empty palette, revert to default
  if curPalette.colors.len == 0:
    curPalette = defaultPalette
  
  #load up project files
  for kind, file in projectFolder.walkDir():
    if kind == pcDir:
      try:
        #load project if its image file exists
        let 
          name = file.lastPathPart.decode
          project = Project(name: name)
          projectImage = project.imageFile
        
        if projectImage.fileExists:
          projects.add project
      except: discard #invalid project folder
    
  #load up palettes
  for kind, file in paletteFolder.walkDir():
    if kind == pcFile:
      try:
        #load palette if its data file is valid, otherwise skip
        let name = file.lastPathPart.decode
        palettes.add readPalette(file, name)
      except: discard #invalid palette
  
  curColorIdx = appConfig.lastColor
  curColor = curPalette[curColorIdx]
  