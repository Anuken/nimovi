import fau/fcore, options

type Tool* = enum
  tPencil = "pencil",
  tErase = "eraser",
  tFill = "fill",
  tPick = "pick",
  tZoom = "zoom",
  tUndo = "undo",
  tRedo = "redo"

type AppConfig* = object
  lastPalette*: string
  lastColor*: int

type Palette* = object
  name*: string
  colors*: seq[Color]

type Project* = object
  name*: string
  preview*: Option[Texture] #TODO I do not like options

const 
  defaultPalette* = Palette(
    name: "Pico-8",
    colors: @[%"000000", %"1D2B53", %"7E2553", %"008751", %"AB5236", %"5F574F", %"C2C3C7", %"FFF1E8",
            %"FF004D", %"FFA300", %"FFEC27", %"00E436", %"29ADFF", %"83769C", %"FF77A8", %"FFCCAA"]
  )

const
  upColor* = %"271c52"
  downColor* =  %"667fff"
  overColor* = %"211d54"

var
  paletteFolder*: string
  projectFolder*: string
  appConfig*: AppConfig
  projects*: seq[Project]
  palettes*: seq[Palette]
  curPalette*: Palette
  curTool* = Tool.low
  curColorIdx* = 0
  curColor*: Color = rgba(1f, 1f, 1f)
  curAlpha*: float32 = 1f
  canvas*: Framebuffer
  canvasGrid*: bool
  cursorMode*: bool
  brushSize*: int

#TODO move
proc `[]`*(pal: Palette, i: int): Color =
  return if i < 0 or i >= pal.colors.len: colorWhite
  else: pal.colors[i]

#TODO move
proc switchColor*(i: int) =
  curColorIdx = i
  curColor = curPalette.colors[i]

proc changeColor*(c: Color) =
  curColor = c
  curPalette.colors[curColorIdx] = c