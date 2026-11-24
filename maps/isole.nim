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
  let a = degToRad(rotate)
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

func kmPerUnit*(isl: Isola, size: float): float =
  ## how many kilometres one unit of the map is, for an island drawn `size` long
  var lo = (x: Inf, y: Inf)
  var hi = (x: -Inf, y: -Inf)
  for p in isl.outline:
    lo = (min(lo.x, p.x), min(lo.y, p.y))
    hi = (max(hi.x, p.x), max(hi.y, p.y))
  max(hi.x - lo.x, hi.y - lo.y) / size

func realIsland*(name: string, center: Pt, size: float, labelBelow = false, rotate = 0.0): Island =
  ## an island of the voyage drawn with the coast of a real one, `size` units on its larger side
  let isl = isole[name]
  result = Island(center: center, outline: isl.fitted(size, rotate), exact: true, real: name,
    elevation: isl.elevation, labelBelow: labelBelow)
  var halfH = 0.0
  for p in result.outline: halfH = max(halfH, abs(p.y))
  result.r = (halfH + 4) / 0.8 # so that labelPos (maps/base.nim) clears the coast

# --- the voyage of the talk, on real islands ------------------------------------------------

type Slot* = object
  ## an island of the voyage: the real island it is drawn as, and where
  real*: string
  center*: Pt
  size*: float
  labelBelow*: bool
  rotate*: float
  near*: seq[string]  ## smaller islands around it, drawn at the same scale where they really are
  lore*: string       ## why this island: a line in the title block of its chart
  note*: string       ## a note on the chart beside it

const voyageSlots* = [
  Slot(real: "Sicily", center: (250.0, 145.0), size: 150, # 1 Accessible Performance
    near: @["Favignana", "Levanzo", "Marettimo", "Ustica", "Lipari", "Salina", "Vulcano", "Filicudi"],
    lore: "Sicily: Etna's power, Archimedes' levers, and orange groves on the volcano"),
  Slot(real: "Samos", center: (345.0, 372.0), size: 120, labelBelow: true, # 2 Success Stories
    lore: "Samos: Eupalinos' tunnel, dug from both ends by a small team, met in the middle"),
  Slot(real: "Sardinia", center: (500.0, 190.0), size: 150, # 3 Data Stack
    near: @["Asinara", "Sant'Antioco", "San Pietro", "La Maddalena", "Caprera"],
    lore: "Sardinia: thousands of nuraghi, towers of stones stacked without mortar"),
  Slot(real: "Malta", center: (620.0, 405.0), size: 95, labelBelow: true, near: @["Gozo"], # 4 Interoperability
    lore: "Malta: a Semitic language in Latin letters, with Italian and English words"),
  Slot(real: "Lesbos", center: (715.0, 150.0), size: 110, # 5 An Expressive Language
    lore: "Lesbos: Sappho's lyrics, and Aristotle's biology in the lagoon of Kalloni"),
  Slot(real: "Stromboli", center: (865.0, 250.0), size: 62, labelBelow: true, # 6 Interactivity
    lore: "Stromboli: the lighthouse of the Mediterranean, erupting every few minutes",
    note: "Volcano (active)"),
  Slot(real: "Mallorca", center: (830.0, 430.0), size: 120, labelBelow: true, near: @["Cabrera"], # 7 Notebook
    lore: "Mallorca: Ramon Llull's paper wheels, combining ideas to reason with them"),
]

func islandsVoyage*(): Voyage =
  ## the map of the talk on real islands: the default voyage (maps/geometry.nim), its islands
  ## drawn with the coasts of seven islands of the Mediterranean
  result = defaultVoyage()
  result.roughCoast = 14
  result.islands.setLen 0
  for s in voyageSlots:
    result.islands.add realIsland(s.real, s.center, s.size, s.labelBelow, s.rotate)
    result.islands[^1].lore = s.lore
    result.islands[^1].note = s.note
    let main = isole[s.real]
    let k = 1 / main.kmPerUnit(s.size)
    for name in s.near:
      let o = main.offsetKm(isole[name])
      var islet: seq[Pt]
      for p in isole[name].outline:
        islet.add (s.center.x + (o.x + p.x) * k, s.center.y - (o.y + p.y) * k)
      result.islets.add islet
  result.route = @[result.route[0]]
  for s in voyageSlots: result.route.add s.center
  result.route.add [(600.0, 505.0), (330.0, 500.0), (108.0, 470.0)]
