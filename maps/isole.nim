## Real islands of the Mediterranean for the voyage map: their coasts are taken from the
## islands story of tabelline (deps/tabelline/docs/stories/data/isole/islands.csv), where each
## outline is an OpenStreetMap land polygon (© OpenStreetMap contributors, ODbL) simplified to
## at most 120 points, in kilometres from its middle (x east, y north).
## The file is read when the map is compiled, so nothing is copied here.
import std / [os, strutils, tables, math]
import geometry

const isoleCsv = currentSourcePath().parentDir.parentDir / "deps" / "tabelline" / "docs" / "stories" /
  "data" / "isole" / "islands.csv"

type Isola* = object
  ## an island of the story: its name, area, highest point and outline in km (y north)
  name*: string
  km2*, elevation*: float
  clon*, clat*: float ## the centroid of the outline, degrees
  outline*: seq[Pt]

func csvFields(line: string): seq[string] =
  ## the fields of a CSV line, quotes and all
  var field = ""
  var quoted = false
  var i = 0
  while i < line.len:
    let c = line[i]
    if quoted:
      if c == '"':
        if i + 1 < line.len and line[i + 1] == '"': field.add '"'; inc i
        else: quoted = false
      else: field.add c
    elif c == '"': quoted = true
    elif c == ',': result.add field; field = ""
    else: field.add c
    inc i
  result.add field

func parseIsole(text: string): Table[string, Isola] =
  var header: seq[string]
  for line in text.splitLines:
    if line.len == 0 or line.startsWith("#"): continue
    let f = csvFields(line)
    if header.len == 0: header = f; continue
    template col(name: string): string = f[header.find(name)]
    var isl = Isola(name: col("island"))
    isl.km2 = parseFloat(col("km2"))
    if col("elevation").len > 0: isl.elevation = parseFloat(col("elevation"))
    if col("clon").len > 0: isl.clon = parseFloat(col("clon")); isl.clat = parseFloat(col("clat"))
    let xs = col("x").splitWhitespace
    let ys = col("y").splitWhitespace
    for k in 0 ..< min(xs.len, ys.len):
      isl.outline.add (parseFloat(xs[k]), parseFloat(ys[k]))
    result[isl.name] = isl

const isole* = parseIsole(staticRead(isoleCsv))
  ## the 195 islands of the story, by name

func fitted*(isl: Isola, size: float, rotate = 0.0): seq[Pt] =
  ## the outline in map units around its middle, its larger side `size` long,
  ## north up (svg's y grows down), turned by `rotate` degrees if a slot needs it
  var lo = (x: Inf, y: Inf)
  var hi = (x: -Inf, y: -Inf)
  let a = degToRad(-rotate)
  var pts: seq[Pt]
  for p in isl.outline:
    let q: Pt = (p.x * cos(a) - p.y * sin(a), -(p.x * sin(a) + p.y * cos(a)))
    pts.add q
    lo = (min(lo.x, q.x), min(lo.y, q.y))
    hi = (max(hi.x, q.x), max(hi.y, q.y))
  let k = size / max(hi.x - lo.x, hi.y - lo.y)
  let mid: Pt = ((lo.x + hi.x) / 2, (lo.y + hi.y) / 2)
  for q in pts: result.add ((q.x - mid.x) * k, (q.y - mid.y) * k)

func centroidKm(isl: Isola): Pt =
  ## the centroid of the outline, in km from the middle of its bounding box
  var a, cx, cy: float
  let n = isl.outline.len
  for i in 0 ..< n:
    let p = isl.outline[i]
    let q = isl.outline[(i + 1) mod n]
    let f = p.x * q.y - q.x * p.y
    a += f; cx += (p.x + q.x) * f; cy += (p.y + q.y) * f
  if a == 0: (0.0, 0.0) else: (cx / (3 * a), cy / (3 * a))

func offsetKm*(isl, other: Isola): Pt =
  ## where the middle of `other` is from the middle of `isl`, in km (x east, y north)
  let kmLon = 111.32 * cos(degToRad(isl.clat))
  let c1 = isl.centroidKm
  let c2 = other.centroidKm
  ((other.clon - isl.clon) * kmLon - c2.x + c1.x, (other.clat - isl.clat) * 110.57 - c2.y + c1.y)

func kmPerUnit*(isl: Isola, size: float, rotate = 0.0): float =
  ## how many kilometres one unit of the map is, for an island drawn `size` long, turned `rotate` degrees
  var lo = (x: Inf, y: Inf)
  var hi = (x: -Inf, y: -Inf)
  let a = degToRad(-rotate)
  for o in isl.outline:
    let p: Pt = (o.x * cos(a) - o.y * sin(a), o.x * sin(a) + o.y * cos(a))
    lo = (min(lo.x, p.x), min(lo.y, p.y))
    hi = (max(hi.x, p.x), max(hi.y, p.y))
  max(hi.x - lo.x, hi.y - lo.y) / size

const displayNames = {"Lošinj": "Lussino"}.toTable
  ## the name written on the map, where it is not the list's

func realIsland*(name: string, center: Pt, size: float, labelBelow = false, rotate = 0.0): Island =
  ## an island of the voyage drawn with the coast of a real one, `size` units on its larger side
  let isl = isole[name]
  result = Island(center: center, outline: isl.fitted(size, rotate), exact: true, real: name,
    elevation: isl.elevation, labelBelow: labelBelow)
  if name in displayNames: result.real = displayNames[name]
  var halfH = 0.0
  for p in result.outline: halfH = max(halfH, abs(p.y))
  result.r = (halfH + 4) / 0.8 # so that labelPos (maps/base.nim) clears the coast

# --- the mainland: the Gulf of Trieste ---------------------------------------------------------

const triesteGulf*: seq[Pt] = @[
  # the coast of the Gulf of Trieste, longitude and latitude, from Umag in Istria round Trieste to
  # Grado: Natural Earth's 1:10m land (public domain), its points between 13.25°E and 13.82°E
  (13.5134, 45.4362), (13.5154, 45.4381), (13.5186, 45.4403), (13.5208, 45.4430), (13.5160, 45.4475), (13.5156, 45.4481), (13.5178, 45.4498), (13.5208, 45.4573), (13.5046, 45.4839), (13.5015, 45.4986), (13.5071, 45.5119), (13.5134, 45.5119), (13.5231, 45.5063), (13.5686, 45.4908), (13.5895, 45.4888), (13.5916, 45.4931), (13.5891, 45.5016), (13.5960, 45.5119), (13.5960, 45.5181), (13.5862, 45.5195), (13.5786, 45.5234), (13.5728, 45.5300), (13.5686, 45.5393), (13.5896, 45.5358), (13.6751, 45.5447), (13.7529, 45.5529), (13.7529, 45.5591), (13.7424, 45.5698), (13.7274, 45.5812), (13.7118, 45.5932), (13.7188, 45.6007), (13.7302, 45.6131), (13.7570, 45.6137), (13.7869, 45.6112), (13.8081, 45.6143), (13.7956, 45.6170), (13.7865, 45.6243), (13.7771, 45.6354), (13.7393, 45.6491), (13.7577, 45.6550), (13.7537, 45.6723), (13.7391, 45.6916), (13.7262, 45.7038), (13.6473, 45.7620), (13.6289, 45.7726), (13.5742, 45.7896), (13.5513, 45.7924), (13.5344, 45.7820), (13.5242, 45.7601), (13.5283, 45.7405), (13.5549, 45.7372), (13.5184, 45.7248), (13.5134, 45.7208), (13.5078, 45.7144), (13.4802, 45.7107), (13.4692, 45.7069), (13.4517, 45.6938), (13.4280, 45.6811), (13.4017, 45.6754), (13.3767, 45.6832), (13.3910, 45.6858), (13.4092, 45.6913), (13.4248, 45.6986), (13.4314, 45.7069), (13.4226, 45.7241), (13.3817, 45.7300), (13.3694, 45.7446), (13.3518, 45.7403), (13.2549, 45.7560)]

func coastPolygon*(lonLat: seq[Pt], angle, width, cx, bottom: float, w, h: float, rough = 5.0, reach = 60.0): seq[Pt] =
  ## a stretch of real coast as the mainland of a w × h map: turned `angle` degrees clockwise
  ## (90 puts the land of the Gulf of Trieste south), `width` units wide around `cx`, its lowest point
  ## at `bottom`, then closed to the edges of the map: the land is on the right of the coast's way
  let lat0 = lonLat[0].y
  let kLon = 111.32 * cos(degToRad(lat0))
  let a = degToRad(-angle)
  var pts: seq[Pt]
  for p in lonLat:
    let e = (p.x - lonLat[0].x) * kLon
    let n = (p.y - lat0) * 110.57
    pts.add (e * cos(a) - n * sin(a), -(e * sin(a) + n * cos(a))) # turned clockwise, y down
  var lo = (x: Inf, y: Inf)
  var hi = (x: -Inf, y: -Inf)
  for q in pts:
    lo = (min(lo.x, q.x), min(lo.y, q.y))
    hi = (max(hi.x, q.x), max(hi.y, q.y))
  let k = width / (hi.x - lo.x)
  var smooth: seq[Pt]
  for q in pts:
    smooth.add (cx + (q.x - (lo.x + hi.x) / 2) * k, bottom + (q.y - hi.y) * k)
  # the coast runs on past its ends, down to the edges of the map
  let (f0, f1) = (smooth[0], smooth[^1])
  smooth.insert((-30.0, f0.y + reach), 0)
  smooth.add (w + 30, f1.y + reach)
  # Natural Earth draws a long straight line where the coast has small capes and bays at this scale:
  # cut each segment in steps of about 6 units and move them across it by fractal noise
  for i in 0 ..< smooth.high:
    let p = smooth[i]
    let q = smooth[i + 1]
    let l = hypot(q.x - p.x, q.y - p.y)
    let n = max(1, int(l / 5))
    for j in 0 ..< n:
      let t = j.float / n.float
      let m: Pt = (p.x + t * (q.x - p.x), p.y + t * (q.y - p.y))
      let off = rough * (2 * fbm(m.x / 40, m.y / 40, 4) - 1)
      result.add (m.x - off * (q.y - p.y) / l, m.y + off * (q.x - p.x) / l)
  result.add smooth[^1]
  # close it along the edges, from the last point round the bottom of the map to the first
  let first = result[0]
  let last = result[^1]
  result.add [(w + 30, last.y), (w + 30, h + 30), (-30.0, h + 30), (-30.0, first.y)]

# --- the voyage of the talk, on real islands ------------------------------------------------

type
  Slot* = object
    ## an island of the voyage: the real island it is drawn as, and where
    real*: string
    center*: Pt
    size*: float
    labelBelow*: bool
    rotate*: float     ## degrees clockwise, to fit its place
    near*: seq[string] ## smaller islands around it, drawn at the same scale where they really are
    lore*: string      ## why this island: a line in the title block of its chart
    note*: string      ## a note on the chart beside it

  Layout* = object
    ## an arrangement of the voyage: the coast, the islands, the course
    name*: string
    coastFrom*, coastTo*: int ## the stretch of `triesteGulf` drawn
    coastAngle*, coastWidth*, coastX*, coastBottom*: float
    slots*: seq[Slot]
    start*, landfall*: seq[Pt] ## the course: from the coast to island 1; from island 7 back to land
    compassAt*, landLabel*, titleAt*: Pt

const islandPicks* = [
  # the islands of the talk (Pietro, 2026-11-24), in the order of the sections, with a line each
  ("Elba", "Elba: iron mined and smelted since the Etruscans, furnaces by the sea"),
  ("Lošinj", "Lussino: a small island with a big fleet of sailing ships in the 1800s"),
  ("Chios", "Chios: Mesta, a village whose stacked houses make one fortress wall"),
  ("Caprera", "Caprera: joined by a bridge to La Maddalena, its neighbour"),
  ("Porquerolles", "Porquerolles: a car-free island where a villa became a museum of art"),
  ("Vulcano", "Vulcano: the island that gave volcanoes their name, still steaming"),
  ("Leros", "Leros: Lakki, one of the largest natural harbours of the Mediterranean"),
]

func slot(i: int, center: Pt, size: float, labelBelow = false, rotate = 0.0, note = "", near: seq[string] = @[]): Slot =
  Slot(near: near, real: islandPicks[i][0], lore: islandPicks[i][1], center: center, size: size,
    labelBelow: labelBelow, rotate: rotate, note: note)

let layouts* = @[
  Layout(name: "ring", coastFrom: 0, coastTo: 48, coastAngle: 95, coastWidth: 320, coastX: 480, coastBottom: 560,
    slots: @[slot(0, (116.0, 300.0), 100), slot(1, (170.0, 140.0), 90, rotate = -20),
             slot(2, (370.0, 85.0), 105), slot(3, (590.0, 80.0), 75, near = @["La Maddalena"]),
             slot(4, (790.0, 150.0), 105), slot(5, (850.0, 310.0), 70, labelBelow = true, note = "Volcano (active)"),
             slot(6, (480.0, 255.0), 95, labelBelow = true)],
    start: @[(250.0, 455.0)], landfall: @[(480.0, 495.0)], compassAt: (905.0, 60.0),
    landLabel: (180.0, 520.0), titleAt: (790.0, 470.0)),
  Layout(name: "gulf", coastFrom: 0, coastTo: 48, coastAngle: 95, coastWidth: 400, coastX: 480, coastBottom: 560,
    slots: @[slot(0, (110.0, 215.0), 105), slot(1, (215.0, 85.0), 90, rotate = -20),
             slot(2, (390.0, 95.0), 110), slot(3, (575.0, 85.0), 75, near = @["La Maddalena"]),
             slot(4, (745.0, 100.0), 110), slot(5, (860.0, 235.0), 70, labelBelow = true, note = "Volcano (active)"),
             slot(6, (480.0, 300.0), 95, labelBelow = true)],
    start: @[(205.0, 345.0)], landfall: @[(480.0, 480.0)], compassAt: (905.0, 60.0),
    landLabel: (150.0, 515.0), titleAt: (165.0, 430.0)),
  Layout(name: "lagoon", coastFrom: 0, coastTo: 68, coastAngle: 80, coastWidth: 980, coastX: 420, coastBottom: 700,
    slots: @[slot(0, (100.0, 120.0), 95), slot(1, (250.0, 65.0), 80, rotate = -30),
             slot(2, (420.0, 80.0), 100), slot(3, (590.0, 70.0), 65, near = @["La Maddalena"]),
             slot(4, (690.0, 200.0), 95), slot(5, (700.0, 360.0), 60, labelBelow = true, note = "Volcano (active)"),
             slot(6, (470.0, 270.0), 90, labelBelow = true)],
    start: @[(130.0, 290.0)], landfall: @[(470.0, 470.0)], compassAt: (60.0, 360.0),
    landLabel: (150.0, 520.0), titleAt: (165.0, 478.0)),
]

proc layoutVoyage*(l: Layout): Voyage =
  ## the voyage on real islands in an arrangement: the Gulf of Trieste south, the islands around
  result = defaultVoyage()
  result.coast = coastPolygon(triesteGulf[l.coastFrom .. l.coastTo], l.coastAngle, l.coastWidth, l.coastX,
    l.coastBottom, result.w, result.h)
  result.compassAt = l.compassAt
  result.landLabel = l.landLabel
  result.titleAt = l.titleAt
  result.landLabelAngle = 0
  result.islands.setLen 0
  for s in l.slots:
    result.islands.add realIsland(s.real, s.center, s.size, s.labelBelow, s.rotate)
    result.islands[^1].lore = s.lore
    result.islands[^1].note = s.note
    let main = isole[s.real]
    let k = 1 / main.kmPerUnit(s.size, s.rotate)
    let a = degToRad(-s.rotate)
    for name in s.near:
      let o = main.offsetKm(isole[name])
      var islet: seq[Pt]
      for p in isole[name].outline:
        let q: Pt = (o.x + p.x, o.y + p.y)
        islet.add (s.center.x + (q.x * cos(a) - q.y * sin(a)) * k, s.center.y - (q.x * sin(a) + q.y * cos(a)) * k)
      result.islets.add islet
  result.route = l.start
  for s in l.slots: result.route.add s.center
  result.route.add l.landfall

proc islandsVoyage*(): Voyage =
  ## the map of the talk: the first arrangement (the others are drawn by maps/maplab.nim)
  layoutVoyage(layouts[0])
