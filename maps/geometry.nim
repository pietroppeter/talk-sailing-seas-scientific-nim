## The geometry of the voyage map: the one layer every theme's map is drawn from.
##
## Islands, the mainland and the route are plain data (points), so a change here
## (another shape for an island, a volcano, a new route) shows up in every theme:
## the base svg (maps/base.nim), the pixel art map (maps/pixel.nim), the nautical chart
## (maps/chart.nim) and the hand-drawn map (maps/engraved.nim).
## A signed distance field (negative on land, positive at sea) gives depths, shores,
## contours and the pixels of the pixel art.
import std / [math, strutils, strformat, tables, hashes]

type
  Pt* = tuple[x, y: float]

  FeatureKind* = enum
    Hills, Palms, Volcano

  Feature* = object
    kind*: FeatureKind
    at*: Pt ## offset from the island's center

  Island* = object
    center*: Pt
    r*: float          ## size, for the default wobbly outline
    seed*: float       ## shape of the default wobbly outline
    outline*: seq[Pt]  ## control points of a custom outline, around `center`; empty: the default
    features*: seq[Feature]
    labelBelow*: bool
    label*: Pt         ## where its name goes (the middle of the name's baseline); (0, 0): above or below it
    exact*: bool       ## the outline is a real coast (maps/isole.nim), drawn as it is, not smoothed
    real*: string      ## the real island the outline is taken from, empty for an invented one
    elevation*: float  ## its highest point, metres (0: unknown)
    lore*: string      ## a line on the real island, for its chart
    note*: string      ## a note on the chart next to it, as charts have (an active volcano)

  Voyage* = object
    w*, h*: float
    islands*: seq[Island]
    mainland*: seq[Pt]   ## control points of the mainland's coast, top to bottom
    route*: seq[Pt]      ## from the mainland through the islands and back to land
    straightRoute*: bool ## straight legs (with `via` turning points) instead of a smooth curve
    via*: seq[seq[Pt]]   ## the turning points of each leg, between stop k and stop k + 1
    compassAt*: Pt
    seaName*: string
    islets*: seq[seq[Pt]] ## small islands around the islands of the voyage, unnamed, drawn as they are
    coast*: seq[Pt]      ## a real coast for the mainland, a closed polygon drawn as it is (maps/isole.nim); empty: `mainland`
    titleAt*: Pt         ## where the chart's title block goes (the middle of its first line)
    landLabel*: Pt       ## where the mainland's name goes
    landLabelAngle*: float ## and its angle, degrees
    roughCoast*: float   ## how far (map units) the mainland's coast wanders off its smooth line: 0 smooth

func catmullRom(pts: seq[Pt], closed: bool, steps = 8): seq[Pt] =
  ## dense points of a Catmull-Rom spline through `pts`
  let n = pts.len
  let last = if closed: n else: n - 1
  for i in 0 ..< last:
    let p0 = if closed: pts[(i - 1 + n) mod n] else: pts[max(i - 1, 0)]
    let p1 = pts[i mod n]
    let p2 = pts[(i + 1) mod n]
    let p3 = if closed: pts[(i + 2) mod n] else: pts[min(i + 2, n - 1)]
    for s in 0 ..< steps:
      let t = s.float / steps.float
      let t2 = t * t
      let t3 = t2 * t
      template c(a, b, c, d: float): float =
        0.5 * (2 * b + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t2 + (-a + 3 * b - 3 * c + d) * t3)
      result.add (c(p0.x, p1.x, p2.x, p3.x), c(p0.y, p1.y, p2.y, p3.y))
  if not closed: result.add pts[^1]

func controlPoints*(isl: Island): seq[Pt] =
  ## the island's outline control points, the custom one or a wobbly circle
  if isl.outline.len > 0:
    for p in isl.outline: result.add (isl.center.x + p.x, isl.center.y + p.y)
  else:
    let n = 12
    for i in 0 ..< n:
      let t = 2 * PI * i.float / n.float
      let s = isl.seed
      let rr = isl.r * (1 + 0.20 * sin(3 * t + s) + 0.10 * sin(5 * t + 2.3 * s) + 0.05 * cos(7 * t + s))
      result.add (isl.center.x + rr * cos(t), isl.center.y + 0.8 * rr * sin(t))

func polygon*(isl: Island): seq[Pt] =
  if isl.exact: isl.controlPoints else: catmullRom(isl.controlPoints, closed = true)

func valueNoise*(x, y: float): float =
  ## smooth value noise in [0, 1], the same at every build
  func h(i, j: int): float =
    let s = sin(i.float * 127.1 + j.float * 311.7) * 43758.5453
    s - floor(s)
  let i = int(floor(x))
  let j = int(floor(y))
  var tx = x - i.float
  var ty = y - j.float
  tx = tx * tx * (3 - 2 * tx)
  ty = ty * ty * (3 - 2 * ty)
  let a = h(i, j) * (1 - tx) + h(i + 1, j) * tx
  let b = h(i, j + 1) * (1 - tx) + h(i + 1, j + 1) * tx
  a * (1 - ty) + b * ty

func fbm*(x, y: float, octaves = 4): float =
  ## fractal noise in about [0, 1]: octaves of value noise, each finer and fainter
  var amp = 0.5
  var freq = 1.0
  var norm = 0.0
  for o in 0 ..< octaves:
    result += amp * valueNoise(x * freq + o.float * 17.3, y * freq - o.float * 9.1)
    norm += amp
    amp *= 0.5
    freq *= 2.1
  result /= norm

func mainlandPolygon*(v: Voyage): seq[Pt] =
  ## the mainland: its coast, closed along the left edge of the map (or the real coast, if any)
  if v.coast.len > 0: return v.coast
  result = catmullRom(v.mainland, closed = false, steps = if v.roughCoast > 0: 24 else: 8)
  if v.roughCoast > 0: # a coast that wanders like a real one: capes and bays at every scale
    for p in result.mitems:
      p.x += v.roughCoast * (2 * fbm(p.y * 0.025, 3.7, 5) - 1)
  result.add [(-20.0, v.h + 20), (-20.0, -20.0)]

func leg*(v: Voyage, k: int): seq[Pt] =
  ## the k-th leg of a straight route: from stop k through its turning points to stop k + 1
  result.add v.route[k]
  if k < v.via.len: result.add v.via[k]
  result.add v.route[k + 1]

func routePolyline*(v: Voyage, upTo = -1): seq[Pt] =
  ## dense points of the route; `upTo` = n stops at the n-th point of the route
  let last = if upTo < 0: v.route.high else: min(upTo, v.route.high)
  if v.straightRoute: # straight legs with turns, as a course is laid on a chart
    for k in 0 ..< last:
      let l = v.leg(k)
      result.add (if k == 0: l else: l[1 .. ^1])
    if result.len == 0: result = v.route[0 .. last]
    return
  let pts = v.route[0 .. last]
  if pts.len < 2: return pts
  catmullRom(pts, closed = false)

func f1*(x: float): string = formatFloat(x, ffDecimal, 1)

func landLabelAttrs*(v: Voyage): string =
  ## the svg attributes that place the mainland's name
  "x=\"" & f1(v.landLabel.x) & "\" y=\"" & f1(v.landLabel.y) & "\" transform=\"rotate(" & f1(v.landLabelAngle) &
    " " & f1(v.landLabel.x) & " " & f1(v.landLabel.y) & ")\""

func svgPath*(poly: seq[Pt], closed = true): string =
  for i, p in poly:
    result.add (if i == 0: "M" else: " L") & f1(p.x) & "," & f1(p.y)
  if closed: result.add " Z"

# --- the distance field ----------------------------------------------------------------

func pointInPolygon(p: Pt, poly: seq[Pt]): bool =
  var j = poly.high
  for i in 0 .. poly.high:
    let a = poly[i]
    let b = poly[j]
    if ((a.y > p.y) != (b.y > p.y)) and (p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x):
      result = not result
    j = i

func distToSegment(p, a, b: Pt): float =
  let dx = b.x - a.x
  let dy = b.y - a.y
  let l2 = dx * dx + dy * dy
  var t = if l2 == 0: 0.0 else: ((p.x - a.x) * dx + (p.y - a.y) * dy) / l2
  t = clamp(t, 0.0, 1.0)
  hypot(p.x - (a.x + t * dx), p.y - (a.y + t * dy))

type Field* = object
  ## signed distance to the nearest coast on a grid: negative on land, positive at sea
  cell*: float
  nx*, ny*: int   ## grid nodes, including one ring outside the map
  d*: seq[float]

func lands*(v: Voyage): seq[seq[Pt]] =
  result.add v.mainlandPolygon
  for isl in v.islands: result.add isl.polygon
  for islet in v.islets: result.add islet

func signedDistance*(lands: seq[seq[Pt]], p: Pt): float =
  var best = Inf
  var inside = false
  for poly in lands:
    if pointInPolygon(p, poly): inside = true
    var j = poly.high
    for i in 0 .. poly.high:
      best = min(best, distToSegment(p, poly[j], poly[i]))
      j = i
  if inside: -best else: best

func harbour*(lands: seq[seq[Pt]], p: Pt, search = 16.0, reach = 22.0): Pt =
  ## the most sheltered water near `p`: a point close to the shore (3.5 to 7 units off, room for the anchor) from which
  ## the most directions meet land within `reach`, the closer to `p` the better. An outline drawn
  ## at a few units per kilometre puts a real harbour on the shore or out on a point; this finds
  ## the bay it is in.
  result = p
  var best = -Inf
  const rays = 24
  var y = -search
  while y <= search:
    var x = -search
    while x <= search:
      let q: Pt = (p.x + x, p.y + y)
      let off = hypot(x, y)
      if off <= search:
        let d = signedDistance(lands, q)
        if d >= 3.5 and d <= 7:
          var hits = 0
          for k in 0 ..< rays:
            let a = 2 * PI * k.float / rays
            var t = 2.0
            while t <= reach:
              let r: Pt = (q.x + t * cos(a), q.y + t * sin(a))
              var land = false
              for poly in lands:
                if pointInPolygon(r, poly): land = true; break
              if land: inc hits; break
              t += 1.5
          let score = hits.float - 0.1 * off
          if score > best:
            best = score
            result = q
      x += 1
    y += 1

proc field*(v: Voyage, cell = 4.0): Field =
  ## the distance field of the map, cached: the same geometry is drawn by many slides
  var cache {.global.}: Table[Hash, Field]
  let key = hash($v & "|" & $cell)
  if key in cache: return cache[key]
  let ls = v.lands
  result.cell = cell
  result.nx = int(v.w / cell) + 3
  result.ny = int(v.h / cell) + 3
  result.d = newSeq[float](result.nx * result.ny)
  for j in 0 ..< result.ny:
    for i in 0 ..< result.nx:
      let p = ((i - 1).float * cell, (j - 1).float * cell)
      result.d[j * result.nx + i] =
        if i == 0 or j == 0 or i == result.nx - 1 or j == result.ny - 1: 1000.0 # open sea all around
        else: signedDistance(ls, p)
  cache[key] = result

func at*(f: Field, p: Pt): float =
  ## the distance at any point, interpolated on the grid
  let gx = clamp(p.x / f.cell + 1, 0.0, (f.nx - 1).float - 1e-6)
  let gy = clamp(p.y / f.cell + 1, 0.0, (f.ny - 1).float - 1e-6)
  let i = int(gx)
  let j = int(gy)
  let tx = gx - i.float
  let ty = gy - j.float
  let a = f.d[j * f.nx + i]
  let b = f.d[j * f.nx + i + 1]
  let c = f.d[(j + 1) * f.nx + i]
  let d = f.d[(j + 1) * f.nx + i + 1]
  (a * (1 - tx) + b * tx) * (1 - ty) + (c * (1 - tx) + d * tx) * ty

func contours*(f: Field, level: float): seq[seq[Pt]] =
  ## lines where the distance to the coast is `level` (marching squares), joined into polylines
  type Key = (int, int)
  func key(p: Pt): Key = (int(round(p.x * 10)), int(round(p.y * 10)))
  var segs: seq[(Pt, Pt)]
  template node(i, j: int): float = f.d[(j) * f.nx + (i)]
  template pos(i, j: int): Pt = ((i - 1).float * f.cell, (j - 1).float * f.cell)
  for j in 0 ..< f.ny - 1:
    for i in 0 ..< f.nx - 1:
      let v = [node(i, j), node(i + 1, j), node(i + 1, j + 1), node(i, j + 1)]
      let ps = [pos(i, j), pos(i + 1, j), pos(i + 1, j + 1), pos(i, j + 1)]
      var cross: seq[Pt]
      for e in 0 .. 3:
        let a = v[e]
        let b = v[(e + 1) mod 4]
        if (a < level) != (b < level):
          let t = (level - a) / (b - a)
          let pa = ps[e]
          let pb = ps[(e + 1) mod 4]
          cross.add (pa.x + t * (pb.x - pa.x), pa.y + t * (pb.y - pa.y))
      if cross.len == 2: segs.add (cross[0], cross[1])
      elif cross.len == 4:
        segs.add (cross[0], cross[1])
        segs.add (cross[2], cross[3])
  # join segments that share an end into polylines
  var ends: Table[Key, seq[int]]
  for k, s in segs:
    ends.mgetOrPut(key(s[0]), @[]).add k
    ends.mgetOrPut(key(s[1]), @[]).add k
  var used = newSeq[bool](segs.len)
  for k in 0 ..< segs.len:
    if used[k]: continue
    used[k] = true
    var line = @[segs[k][0], segs[k][1]]
    for dir in 0 .. 1:
      while true:
        let tip = line[^1]
        var found = -1
        for m in ends.getOrDefault(key(tip)):
          if not used[m]: found = m; break
        if found < 0: break
        used[found] = true
        let s = segs[found]
        line.add (if key(s[0]) == key(tip): s[1] else: s[0])
      if dir == 0:
        var rev: seq[Pt]
        for q in countdown(line.high, 0): rev.add line[q]
        line = rev
    result.add line

func smooth*(line: seq[Pt], every = 3): seq[Pt] =
  ## fewer, smoother points for a contour line
  for k in countup(0, line.high, every): result.add line[k]
  if line.len > 0 and (line.high mod every) != 0: result.add line[^1]

func depth*(f: Field, p: Pt): float =
  ## a made-up but plausible depth in metres at a sea point: shallow near the coast
  let d = f.at(p)
  if d <= 0: return 0
  2.0 * sqrt(d) + 0.12 * d + 1.5 * sin(p.x * 0.05) * cos(p.y * 0.07)

# --- the voyage of the talk ------------------------------------------------------------

type Rng* = object
  ## a small deterministic random generator (xorshift), so maps are the same at every build
  s: uint32

func initRng*(seed: int): Rng = Rng(s: uint32((seed * 2654435761 + 12345) and 0xFFFFFFFF) or 1)

proc next*(r: var Rng): float =
  ## a number in [0, 1)
  r.s = r.s xor (r.s shl 13)
  r.s = r.s xor (r.s shr 17)
  r.s = r.s xor (r.s shl 5)
  (r.s mod 100000).float / 100000.0

func defaultVoyage*(): Voyage =
  ## the map of the talk: the mainland on the left, seven islands, a route out and back
  let centers = [(250.0, 140.0), (345.0, 365.0), (495.0, 185.0), (620.0, 400.0),
                 (705.0, 150.0), (865.0, 235.0), (825.0, 430.0)]
  let radii = [46.0, 40.0, 54.0, 44.0, 40.0, 46.0, 38.0]
  let below = [false, true, false, true, false, false, true]
  result = Voyage(w: 960, h: 540, compassAt: (900.0, 78.0), seaName: "Seas of Scientific Nim",
    landLabel: (40.0, 300.0), landLabelAngle: -90, titleAt: (485.0, 40.0))
  for i in 0 ..< 7:
    result.islands.add Island(center: centers[i], r: radii[i], seed: i.float * 1.7, labelBelow: below[i],
      features: @[Feature(kind: Hills, at: (0.0, 0.0)),
                  Feature(kind: Palms, at: (radii[i] * 0.45, radii[i] * 0.2))])
  result.mainland = @[(150.0, -10.0), (110.0, 60.0), (105.0, 110.0), (140.0, 190.0), (125.0, 250.0),
    (75.0, 320.0), (85.0, 370.0), (130.0, 440.0), (110.0, 500.0), (95.0, 550.0)]
  result.route.add (118.0, 250.0)
  for c in centers: result.route.add c
  result.route.add [(600.0, 505.0), (330.0, 500.0), (108.0, 470.0)]
