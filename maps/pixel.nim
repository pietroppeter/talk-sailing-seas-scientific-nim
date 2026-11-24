## The pirate theme's map: the voyage geometry drawn as pixel art, the look of a
## 90s point-and-click adventure. Every pixel comes from the distance field of
## maps/geometry.nim (sea, shoals, beach, grass, outline), sprites are drawn from
## small ascii pictures, and the image is a png inside the svg, scaled up without
## smoothing; labels stay svg text in a pixel font, so they are sharp and editable.
import std / [math, strformat, base64, strutils]
import pixie
import geometry, base
export geometry

const scale = 4.0 ## map units per pixel: a 960 x 540 map is 240 x 135 pixels

func hex(s: string): ColorRGBA =
  let v = parseHexInt(s)
  rgba(uint8((v shr 16) and 255), uint8((v shr 8) and 255), uint8(v and 255), 255)

let
  deep = hex("1b3b6f")
  deep2 = hex("21487f")
  mid = hex("2a5f97")
  shallow = hex("3c8fb5")
  shoal = hex("6cc6c8")
  foam = hex("d6f2ea")
  sand = hex("ecc985")
  sandDark = hex("c99a55")
  grass = hex("5fa03b")
  grassDark = hex("3f7a2a")
  outline = hex("3a2410")
  routeTodo = hex("f3e7c6")
  routeDone = hex("e0362c")
  shadow = hex("13284d")

const bayer = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]

func dither(x, y: int, t: float): bool =
  ## ordered dithering: true for a fraction `t` of the pixels
  (bayer[y mod 4][x mod 4].float + 0.5) / 16.0 < t

const
  palmSprite = [
    "..dd..dd...",
    ".dddddddd..",
    "dd.ddtdd.dd",
    "d...t...d..",
    "....t......",
    "....t......",
    ".....t.....",
    ".....t.....",
    ".....t.....",
    "....ttt....",
  ]
  hillSprite = [
    "....dd......",
    "...dGGd..dd.",
    "..dGGGGddGGd",
    ".dGGGGGGGGGd",
    "dGGGGGGGGGGd",
  ]
  volcanoSprite = [
    "....ss.s....",
    "...s..ss....",
    ".....ss.....",
    "....rrrr....",
    "...brrrrb...",
    "..bbbrrbbb..",
    ".bbbbbbbbbb.",
    "bbbbbbbbbbbb",
  ]
  xSprite = [
    "tt.....tt",
    "tXXt.tXXt",
    ".tXXtXXt.",
    "..tXXXt..",
    ".tXXtXXt.",
    "tXXt.tXXt",
    "tt.....tt",
  ]
  shipSprite = [
    ".....t.....",
    "....wtw....",
    "...wwtww...",
    "..wwwtwww..",
    ".wwwwtwwww.",
    ".....t.....",
    "bbbbbbbbbbb",
    ".bbbbbbbbb.",
    "..bbbbbbb..",
  ]
  flagSprite = [
    "|FFF",
    "|FF.",
    "|...",
    "|...",
  ]
  compassSprite = [
    "......N......",
    "......#......",
    ".....###.....",
    "....#####....",
    "......#......",
    ".#....#....#.",
    "####..#..####",
    ".#....#....#.",
    "......#......",
    ".....###.....",
    "......#......",
  ]

proc put(img: Image, x, y: int, c: ColorRGBA) =
  if x >= 0 and y >= 0 and x < img.width and y < img.height: img[x, y] = c

proc sprite(img: Image, art: openArray[string], cx, cy: int) =
  ## draw an ascii sprite centered at (cx, cy); `.` is transparent
  let h = art.len
  let w = art[0].len
  for j, row in art:
    for i, ch in row:
      let c = case ch
        of 'g': grass
        of 't': hex("6b4a2b")
        of 'd': grassDark
        of 'G': hex("4f8f33")
        of 's': hex("d9d3c7")
        of 'r': hex("e2552a")
        of 'b': hex("6b4a2b")
        of 'X': routeDone
        of '|': outline
        of 'F': hex("ffd24a")
        of 'N', '#', 'w': hex("f7ecd0")
        else: continue
      img.put(cx - w div 2 + i, cy - h div 2 + j, c)

proc pixelImage*(v: Voyage, current: int): Image =
  let f = v.field
  let w = int(v.w / scale)
  let h = int(v.h / scale)
  result = newImage(w, h)
  var land = newSeq[bool](w * h)
  var dist = newSeq[float](w * h)
  for y in 0 ..< h:
    for x in 0 ..< w:
      let d = f.at(((x.float + 0.5) * scale, (y.float + 0.5) * scale))
      dist[y * w + x] = d
      land[y * w + x] = d < 0
  for y in 0 ..< h:
    for x in 0 ..< w:
      let d = dist[y * w + x]
      var c: ColorRGBA
      if d < 0:
        var edge = false
        for (dx, dy) in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
          let xx = x + dx
          let yy = y + dy
          if xx >= 0 and yy >= 0 and xx < w and yy < h and not land[yy * w + xx]: edge = true
        c = if edge: outline
            elif d > -6: (if dither(x, y, 0.25) and d < -3: sandDark else: sand)
            elif d > -9: (if dither(x, y, 0.5): sand else: grass)
            else: (if dither(x, y, 0.18): grassDark else: grass)
      else:
        c = if d < 4: foam
            elif d < 10: (if dither(x, y, (d - 4) / 6): shallow else: shoal)
            elif d < 26: (if dither(x, y, (d - 10) / 16): mid else: shallow)
            else: (if dither(x, y, clamp((d - 26) / 40, 0.0, 1.0)): deep else: mid)
        # little waves in open water
        if d > 30 and ((x * 7 + y * 13) mod 151 == 0):
          result.put(x + 1, y, foam)
          result.put(x + 2, y - 1, foam)
          result.put(x + 3, y, foam)
      if result[x, y].a == 0: result[x, y] = c
  # the route: dashes for the way ahead, a solid red line with a shadow for the way sailed
  proc pixels(line: seq[Pt]): seq[(int, int)] =
    ## every pixel along a polyline
    for k in 0 ..< line.high:
      let a = line[k]
      let b = line[k + 1]
      let steps = max(1, int(hypot(b.x - a.x, b.y - a.y) / scale * 2))
      for s in 0 ..< steps:
        let t = s.float / steps.float
        let p = (int((a.x + t * (b.x - a.x)) / scale), int((a.y + t * (b.y - a.y)) / scale))
        if result.len == 0 or result[^1] != p: result.add p
  template atSea(p: (int, int)): bool =
    p[0] >= 0 and p[1] >= 0 and p[0] < w and p[1] < h and dist[p[1] * w + p[0]] > 3
  for k, p in pixels(v.routePolyline):
    if k mod 4 < 2 and atSea(p): result.put(p[0], p[1], routeTodo)
  let sailed = pixels(v.routeDone(current))
  for p in sailed:
    if atSea(p): result.put(p[0] + 1, p[1] + 1, shadow)
  for p in sailed:
    if atSea(p): result.put(p[0], p[1], routeDone)
  # features of the islands, then the marks of the voyage
  for i, isl in v.islands:
    let n = i + 1
    for ft in isl.features:
      let p = ((isl.center.x + ft.at.x) / scale, (isl.center.y + ft.at.y) / scale)
      case ft.kind
      of Palms: result.sprite(palmSprite, int(p[0]), int(p[1]))
      of Hills: result.sprite(hillSprite, int(p[0]) - 3, int(p[1]))
      of Volcano: result.sprite(volcanoSprite, int(p[0]), int(p[1]))
    let c = (int(isl.center.x / scale), int(isl.center.y / scale))
    if n == current: result.sprite(xSprite, c[0], c[1] + 4)
    elif current == 8 or n < current: result.sprite(flagSprite, c[0] - 6, c[1] - 4)
  # our ship, at sea just before the island of the section
  if current in 1 .. 7 and sailed.len > 0:
    var k = sailed.high
    while k > 0 and not atSea(sailed[k]): dec k
    k = max(0, k - 6)
    result.sprite(shipSprite, sailed[k][0], sailed[k][1] - 3)
  result.sprite(compassSprite, int(v.compassAt.x / scale), int(v.compassAt.y / scale))
  # a two pixel frame, like a game window
  for x in 0 ..< w:
    for y in [0, 1, h - 2, h - 1]: result[x, y] = outline
  for y in 0 ..< h:
    for x in [0, 1, w - 2, w - 1]: result[x, y] = outline

proc pixelMap*(v: Voyage, names: openArray[string], current: int): string =
  ## the svg of the pirate map: the pixel art as a png, labels in a pixel font on top
  let png = encodeImage(v.pixelImage(current), PngFormat)
  result = &"""<svg class="voyage-map pixel-map" viewBox="0 0 {v.w.int} {v.h.int}" xmlns="http://www.w3.org/2000/svg">
<image href="data:image/png;base64,{encode(png)}" width="{v.w.int}" height="{v.h.int}" style="image-rendering: pixelated"/>
"""
  for i, isl in v.islands:
    let n = i + 1
    let lp = isl.labelPos(20)
    let state = islandState(n, current)
    result.add &"""<text class="plabel{state}" x="{f1(lp.x)}" y="{f1(lp.y)}" text-anchor="middle">{n}. {names[i]}</text>"""
  result.add """<text class="plabel land" x="40" y="300" transform="rotate(-90 40 300)" text-anchor="middle">THE MAINLAND</text>"""
  result.add "\n</svg>"

const pixelMapCss* = """
.reveal .pixel-map { filter: drop-shadow(4px 5px 0 rgba(60,30,10,0.45)); }
.pixel-map .plabel { font-family: "Pixelify Sans", sans-serif; font-size: 20px; fill: #f8f0d8; stroke: #2a1a10; stroke-width: 4px; paint-order: stroke; }
.pixel-map .plabel.current { fill: #ffd84a; }
.pixel-map .plabel.land { font-size: 16px; letter-spacing: 0.1em; }
.reveal .title-art .pixel-map .plabel { display: none; }
"""
  ## css for the labels of this map (the fonts are in docs/assets/fonts/fonts.css)
