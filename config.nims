--path:"fau/src"
--hints:off
--passC:"-DSTBI_ONLY_PNG"
--d:noAudio
--d:androidFullscreen
--passC:"-Wno-error=incompatible-pointer-types"

--gc:arc

when not defined(debug):
  --d:lto
  --d:strip
else:
  --d:fauGlCoreProfile
