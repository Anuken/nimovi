--path:"."
--hints:off
--passC:"-DSTBI_ONLY_PNG"
--d:noAudio
--d:androidFullscreen

--gc:arc

when not defined(debug):
  --d:lto
  --d:strip