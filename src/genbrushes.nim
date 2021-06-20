import pixie, fau/fmath

#simple script for generating brush images

const max = 20
var i = 0.5f

while i <= 10f:
  let double = int(i*2)
  let size = double + 1 - (double mod 2)
  let res = newImage(size, size)
  for x in 0..<size:
    for y in 0..<size:
      if dst(x.float32 + 0.5f, y.float32 + 0.5f, size/2f, size/2f) <= i:
        res[x, y] = rgba(255, 255, 255, 255)
  
  res.writeFile("assets-raw/sprites/brushes/brush" & $double & ".png")
  i += 0.5f