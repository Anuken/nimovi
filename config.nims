--path:"fau"
--hints:off
--passC:"-DSTBI_ONLY_PNG"
--d:noAudio

#when not defined(Android):
--gc:arc

when not defined(debug):
  --d:lto
  --d:strip