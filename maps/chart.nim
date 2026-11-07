## The chart theme's map: the voyage geometry drawn as a nautical chart, with the
## conventions of real charts: buff land, blue shallows (darker where shallower),
## a green drying band along the coast, depth contours, soundings in metres with
## their decimal as a subscript, rocks, a magenta compass rose with a magnetic ring,
## a magenta course line with its bearings, a light on the island of the section,
## upright names for land, italic names for water, and a graduated border.
## Everything comes from the distance field of maps/geometry.nim.
import std / [math, strformat, strutils]
import geometry, base
export geometry

const
  ink = "#1f2a33"
  magenta = "#b0167a"
  depthLine = "#5f87a8"

func `+`(a: Pt, b: (float, float)): Pt = (a.x + b[0], a.y + b[1])

func seaMask*(v: Voyage, grow = 3.0): string =
  ## black land, slightly grown, for a mask that keeps the course lines at sea
  for poly in v.lands:
    result.add &"""<path d="{svgPath(poly)}" fill="black" stroke="black" stroke-width="{f1(2 * grow)}"/>"""

func fillBelow(f: Field, level: float): string =
  ## one path for the area closer to the coast than `level` (even-odd fill of its contours)
  for line in f.contours(level): result.add svgPath(line.smooth(2)) & " "

func soundingText(d: float, p: Pt): string =
  ## a sounding: whole metres, and the decimal as a subscript below 21 m
  let m = int(floor(d))
  let dec = int(floor((d - m.float) * 10))
  if d < 21:
    &"""<text x="{f1(p.x)}" y="{f1(p.y)}">{m}<tspan dy="3" font-size="8">{dec}</tspan></text>"""
  else:
    &"""<text x="{f1(p.x)}" y="{f1(p.y)}">{m}</text>"""

func bearing(a, b: Pt): int =
  ## true bearing from a to b, degrees from north, clockwise
  let deg = radToDeg(arctan2(b.x - a.x, -(b.y - a.y)))
  (int(round(deg)) + 360) mod 360

func roseSvg(c: Pt, r: float): string =
  ## a compass rose as on charts: a true ring with degrees and a magnetic ring inside
  result = &"""<g class="rose" transform="translate({f1(c.x)},{f1(c.y)})" stroke="{magenta}" fill="none">"""
  result.add &"""<circle r="{f1(r)}" stroke-width="1"/><circle r="{f1(r - 7)}" stroke-width="0.6"/>"""
  for deg in countup(0, 355, 5):
    let a = degToRad(deg.float - 90)
    let l = if deg mod 30 == 0: 7.0 elif deg mod 10 == 0: 5.0 else: 3.0
    result.add &"""<line x1="{f1(r * cos(a))}" y1="{f1(r * sin(a))}" x2="{f1((r - l) * cos(a))}" y2="{f1((r - l) * sin(a))}" stroke-width="0.6"/>"""
  for deg in countup(0, 330, 30):
    let a = degToRad(deg.float - 90)
    result.add &"""<text x="{f1((r + 7) * cos(a))}" y="{f1((r + 7) * sin(a) + 3)}" text-anchor="middle" font-size="7" fill="{magenta}" stroke="none">{deg}</text>"""
  # the magnetic ring, rotated by the variation, with its north arrow
  let variation = -3.0
  result.add &"""<g transform="rotate({variation})"><circle r="{f1(r * 0.62)}" stroke-width="0.6"/>"""
  for deg in countup(0, 350, 10):
    let a = degToRad(deg.float - 90)
    result.add &"""<line x1="{f1(r * 0.62 * cos(a))}" y1="{f1(r * 0.62 * sin(a))}" x2="{f1((r * 0.62 - 3) * cos(a))}" y2="{f1((r * 0.62 - 3) * sin(a))}" stroke-width="0.5"/>"""
  result.add &"""<path d="M0,{f1(-r * 0.6)} L3,-4 L-3,-4 Z" fill="{magenta}" stroke="none"/></g>"""
  result.add &"""<path d="M0,{f1(-r + 7)} L4,0 L0,{f1(r - 7)} L-4,0 Z" fill="none" stroke-width="0.6"/>"""
  result.add &"""<path d="M{f1(-r + 7)},0 L0,4 L{f1(r - 7)},0 L0,-4 Z" fill="none" stroke-width="0.6"/>"""
  result.add &"""<path d="M0,{f1(-r - 2)} l-3,6 h6 Z" fill="{magenta}" stroke="none"/>"""
  result.add &"""<text y="{f1(r * 0.3)}" text-anchor="middle" font-size="5.5" fill="{magenta}" stroke="none">VAR 3°W</text></g>"""

func borderSvg(w, h: float): string =
  ## a graduated border: alternating bars every minute, a label every ten
  let band = 8.0
  result = &"""<g class="chart-border"><rect x="0.5" y="0.5" width="{f1(w - 1)}" height="{f1(h - 1)}" fill="none" stroke="{ink}" stroke-width="1"/>"""
  result.add &"""<rect x="{band}" y="{band}" width="{f1(w - 2 * band)}" height="{f1(h - 2 * band)}" fill="none" stroke="{ink}" stroke-width="0.8"/>"""
  var k = 0
  var x = band
  while x < w - band:
    let x2 = min(x + 24, w - band)
    if k mod 2 == 0:
      result.add &"""<rect x="{f1(x)}" y="0" width="{f1(x2 - x)}" height="{band / 2}" fill="{ink}"/><rect x="{f1(x)}" y="{f1(h - band / 2)}" width="{f1(x2 - x)}" height="{band / 2}" fill="{ink}"/>"""
    else:
      result.add &"""<rect x="{f1(x)}" y="{band / 2}" width="{f1(x2 - x)}" height="{band / 2}" fill="{ink}"/><rect x="{f1(x)}" y="{f1(h - band)}" width="{f1(x2 - x)}" height="{band / 2}" fill="{ink}"/>"""
    if k mod 10 == 0 and k > 0:
      result.add &"""<text x="{f1(x)}" y="{f1(band + 9)}" text-anchor="middle" class="grad">{k}'</text>"""
    x = x2
    inc k
  k = 0
  var y = band
  while y < h - band:
    let y2 = min(y + 24, h - band)
    let off = if k mod 2 == 0: 0.0 else: band / 2
    result.add &"""<rect x="{off}" y="{f1(y)}" width="{band / 2}" height="{f1(y2 - y)}" fill="{ink}"/><rect x="{f1(w - band + off)}" y="{f1(y)}" width="{band / 2}" height="{f1(y2 - y)}" fill="{ink}"/>"""
    y = y2
    inc k
  result.add "</g>"

proc chartMap*(v: Voyage, names: openArray[string], current: int, id = ""): string =
  let id = if id.len > 0: id else: $current
  let f = v.field
  result = &"""<svg class="voyage-map chart-map" viewBox="0 0 {v.w.int} {v.h.int}" xmlns="http://www.w3.org/2000/svg">
<defs><clipPath id="chart-clip-{id}"><rect width="{v.w.int}" height="{v.h.int}"/></clipPath>
<mask id="chart-sea-{id}"><rect width="{v.w.int}" height="{v.h.int}" fill="white"/>{seaMask(v)}</mask></defs>
<g clip-path="url(#chart-clip-{id})">
<rect width="{v.w.int}" height="{v.h.int}" fill="#fbfaf5"/>
"""
  # depth areas, deep to shallow, then the drying band
  for (level, color) in [(34.0, "#e3f0f8"), (18.0, "#c4dff0"), (8.0, "#a3cde8")]:
    result.add &"""<path d="{fillBelow(f, level)}" fill="{color}" fill-rule="evenodd"/>"""
  result.add &"""<path d="{fillBelow(f, 3.5)}" fill="#b9d6a5" fill-rule="evenodd"/>"""
  # depth contours, with their depth written on them
  for level in [8.0, 18.0, 34.0, 60.0]:
    for k, line in f.contours(level):
      let dash = if level >= 60: " stroke-dasharray=\"6 3\"" else: ""
      result.add &"""<path d="{svgPath(line.smooth, closed = false)}" fill="none" stroke="{depthLine}" stroke-width="0.7"{dash}/>"""
      if line.len > 40:
        let p = line[line.len div 3]
        result.add &"""<text x="{f1(p.x)}" y="{f1(p.y + 3)}" class="contour-label">{int(round(f.depth(p)))}</text>"""
  # land: buff, with the coastline, height contours and a spot height
  for poly in v.lands:
    result.add &"""<path d="{svgPath(poly)}" fill="#f4e2ac" stroke="{ink}" stroke-width="1.3"/>"""
  for level in [-12.0, -24.0, -36.0]:
    for line in f.contours(level):
      if line.len > 6:
        result.add &"""<path d="{svgPath(line.smooth, closed = false)}" fill="none" stroke="#b49b62" stroke-width="0.6"/>"""
  for i, isl in v.islands:
    var top = isl.center
    var best = 0.0
    for dx in countup(-30, 30, 6):
      for dy in countup(-24, 24, 6):
        let q: Pt = (isl.center.x + dx.float, isl.center.y + dy.float)
        if f.at(q) < best: best = f.at(q); top = q
    result.add &"""<circle cx="{f1(top.x)}" cy="{f1(top.y)}" r="1.4" fill="{ink}"/><text x="{f1(top.x + 4)}" y="{f1(top.y + 3)}" class="spot">{int(-best * 2.2)}</text>"""
  # soundings on a jittered grid, away from labels, the rose and the route
  var r = initRng(7)
  var keepOut: seq[(Pt, Pt)] # boxes
  for isl in v.islands:
    let lp = isl.labelPos
    keepOut.add ((lp.x - 120, lp.y - 18), (lp.x + 120, lp.y + 8))
  let rose = v.compassAt + (-8.0, 14.0)
  keepOut.add ((rose.x - 62, rose.y - 62), (rose.x + 62, rose.y + 62))
  keepOut.add ((320.0, 38.0), (800.0, 72.0)) # the name of the sea
  func inside(p: Pt, b: (Pt, Pt)): bool = p.x > b[0].x and p.x < b[1].x and p.y > b[0].y and p.y < b[1].y
  result.add "<g class=\"soundings\">"
  var y = 30.0
  while y < v.h - 20:
    var x = 30.0
    while x < v.w - 20:
      let p: Pt = (x + (r.next - 0.5) * 22, y + (r.next - 0.5) * 22)
      let d = f.at(p)
      var ok = d > 5
      for b in keepOut:
        if p.inside(b): ok = false
      if ok: result.add soundingText(f.depth(p), p)
      x += 58
    y += 50
  result.add "</g>"
  # rocks awash in a few shallow spots
  var placed = 0
  var tries = 0
  while placed < 7 and tries < 400:
    inc tries
    let p: Pt = (60 + r.next * (v.w - 120), 30 + r.next * (v.h - 60))
    let d = f.at(p)
    if d > 4 and d < 9:
      result.add &"""<g transform="translate({f1(p.x)},{f1(p.y)})" stroke="{ink}" stroke-width="0.8"><line x1="-3.5" x2="3.5"/><line y1="-3.5" y2="3.5"/><circle cx="-2.5" cy="-2.5" r="0.6" fill="{ink}" stroke="none"/><circle cx="2.5" cy="-2.5" r="0.6" fill="{ink}" stroke="none"/><circle cx="-2.5" cy="2.5" r="0.6" fill="{ink}" stroke="none"/><circle cx="2.5" cy="2.5" r="0.6" fill="{ink}" stroke="none"/></g>"""
      inc placed
  # the course: dashed ahead, solid where sailed, a bearing on every leg sailed
  result.add &"""<g mask="url(#chart-sea-{id})">"""
  result.add &"""<path d="{svgPath(v.routePolyline, closed = false)}" fill="none" stroke="{magenta}" stroke-width="1.2" stroke-dasharray="7 5" opacity="0.6"/>"""
  let done = v.routeDone(current)
  if done.len > 0:
    result.add &"""<path d="{svgPath(done, closed = false)}" fill="none" stroke="{magenta}" stroke-width="2.2"/>"""
  result.add "</g>"
  if done.len > 0:
    let upTo = if current == 8: v.route.high else: current
    for k in 0 ..< upTo:
      let a = v.route[k]
      let b = v.route[k + 1]
      let m: Pt = ((a.x + b.x) / 2, (a.y + b.y) / 2)
      var ang = radToDeg(arctan2(b.y - a.y, b.x - a.x))
      if ang > 90 or ang < -90: ang += 180
      result.add &"""<text class="bearing" transform="translate({f1(m.x)},{f1(m.y)}) rotate({f1(ang)})" y="-5" text-anchor="middle">{bearing(a, b):03}°</text>"""
  # names: upright for land, the light on the island of the section
  for i, isl in v.islands:
    let n = i + 1
    let lp = isl.labelPos
    let state = islandState(n, current)
    result.add &"""<text class="cname{state}" x="{f1(lp.x)}" y="{f1(lp.y)}" text-anchor="middle">{n} · {names[i].toUpperAscii}</text>"""
    if n == current:
      let c: Pt = (isl.center.x + isl.r * 0.35, isl.center.y - isl.r * 0.2)
      result.add &"""<g transform="translate({f1(c.x)},{f1(c.y)})"><path d="M0,0 C-7,-10 -5,-24 0,-30 C5,-24 7,-10 0,0 Z" fill="{magenta}" opacity="0.85"/><circle r="2.5" fill="{ink}"/><text x="8" y="-12" class="light-char">Fl(2) 6s 12M</text></g>"""
  result.add &"""<text class="sea-name" x="560" y="62" text-anchor="middle">{v.seaName.toUpperAscii}</text>"""
  result.add &"""<text class="land-name" x="42" y="300" transform="rotate(-90 42 300)" text-anchor="middle">THE MAINLAND</text>"""
  result.add &"""<text class="note" x="{f1(v.w / 2)}" y="{f1(v.h - 14)}" text-anchor="middle">SOUNDINGS IN METRES</text>"""
  result.add roseSvg(rose, 40)
  result.add "</g>"
  result.add borderSvg(v.w, v.h)
  result.add "\n</svg>"

const chartMapCss* = """
.chart-map .soundings text { font-family: "Spectral", serif; font-style: italic; font-size: 10px; fill: #1f2a33; }
.chart-map .contour-label { font-family: "Spectral", serif; font-style: italic; font-size: 8px; fill: #5f87a8; }
.chart-map .spot, .chart-map .grad, .chart-map .note { font-family: "Space Grotesk", sans-serif; font-size: 8px; fill: #1f2a33; }
.chart-map .note { font-size: 7px; letter-spacing: 0.2em; }
.chart-map .bearing { font-family: "Space Grotesk", sans-serif; font-weight: 700; font-size: 9px; fill: #b0167a; }
.chart-map .cname { font-family: "Space Grotesk", sans-serif; font-weight: 700; font-size: 13px; letter-spacing: 0.12em; fill: #1f2a33; paint-order: stroke; stroke: #f4e2ac; stroke-width: 3px; }
.chart-map .cname.current { fill: #b0167a; }
.chart-map .light-char { font-family: "Spectral", serif; font-style: italic; font-size: 9px; fill: #b0167a; }
.chart-map .sea-name { font-family: "Spectral", serif; font-style: italic; font-size: 20px; letter-spacing: 0.5em; fill: #3d6e93; }
.chart-map .land-name { font-family: "Space Grotesk", sans-serif; font-weight: 700; font-size: 14px; letter-spacing: 0.5em; fill: #1f2a33; }
.chart-map .rose text { font-family: "Space Grotesk", sans-serif; }
.reveal .title-art .chart-map { opacity: 0.7; }
"""
  ## css for the labels of this map (the fonts are in docs/assets/fonts/fonts.css)
