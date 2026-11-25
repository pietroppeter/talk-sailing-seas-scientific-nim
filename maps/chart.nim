## The chart theme's map: the voyage geometry drawn as a nautical chart, with the
## conventions of real charts (Admiralty and NOAA): buff land with a thin coastline, three
## blue tints for the shallows (darker where shallower) and white paper beyond, depth contours
## at 5, 10 and 20 metres, soundings in metres with their decimal as a subscript, rocks, a magenta
## compass rose with a magnetic ring, a magenta course line, an anchor in the port
## of the section, upright names for land, italic names for water, a title block, a source note
## and a fine graduated border.
## The sea floor is the distance field of maps/geometry.nim, stretched by fractal noise so the
## shelves are wide on some coasts and steep on others.
import std / [math, strformat, strutils]
import geometry, base
export geometry

const
  islandNames {.booldefine.} = false
    ## the names of the real islands on the chart, hidden (with the lore lines, which name them) so
    ## the audience can guess the islands (Pietro, 2026-11-25); -d:islandNames=true shows them
  ink = "#1f2a33"
  magenta = "#b0167a"
  depthLine = "#6f93b0"
  paper = "#fdfcf7"

func `+`(a: Pt, b: (float, float)): Pt = (a.x + b[0], a.y + b[1])

func seaMask*(v: Voyage, grow = 3.0): string =
  ## black land, slightly grown, for a mask that keeps the course lines at sea
  for poly in v.lands:
    result.add &"""<path d="{svgPath(poly)}" fill="black" stroke="black" stroke-width="{f1(2 * grow)}"/>"""

# --- the sea floor ------------------------------------------------------------------------

func metres*(b: float): float =
  ## the depth in metres at a point whose stretched distance to the coast is `b`
  ## shallow shelves near the coast, then a slope down to the deep sea between the islands
  if b <= 0: 0.0 else: 2.0 * sqrt(b) + 0.12 * b + 0.006 * b * b

func level*(m: float): float =
  ## the stretched distance where the depth is `m` metres (the inverse of `metres`, by bisection)
  var lo = 0.0
  var hi = 2000.0
  for _ in 0 ..< 50:
    let mid = (lo + hi) / 2
    if metres(mid) < m: lo = mid else: hi = mid
  lo

func stretched*(f: Field): Field =
  ## the distance field stretched by noise: a shelf is wide where the noise is low, steep where high
  result = f
  for j in 0 ..< result.ny:
    for i in 0 ..< result.nx:
      let k = j * result.nx + i
      let d = result.d[k]
      if d > 0 and d < 1000:
        let p: Pt = ((i - 1).float * result.cell, (j - 1).float * result.cell)
        result.d[k] = d * (0.45 + 1.1 * fbm(p.x / 110, p.y / 110, 3))

proc seaFloor(v: Voyage): Field = v.field.stretched

func fillBelow*(f: Field, level: float): string =
  ## one path for the area closer to the coast than `level` (even-odd fill of its contours)
  for line in f.contours(level): result.add svgPath(line.smooth(2)) & " "

func soundingText*(d: float, p: Pt): string =
  ## a sounding: whole metres, and the decimal as a subscript below 21 m
  let m = int(floor(d))
  let dec = int(floor((d - m.float) * 10))
  if d < 21:
    &"""<text x="{f1(p.x)}" y="{f1(p.y)}">{m}<tspan dy="2.5" font-size="6.5">{dec}</tspan></text>"""
  else:
    &"""<text x="{f1(p.x)}" y="{f1(p.y)}">{m}</text>"""

# --- the furniture of a chart ---------------------------------------------------------------

func roseSvg*(c: Pt, r: float): string =
  ## a compass rose as on charts: a true ring with degrees and a magnetic ring inside
  result = &"""<g class="rose" transform="translate({f1(c.x)},{f1(c.y)})" stroke="{magenta}" fill="none">"""
  result.add &"""<circle r="{f1(r)}" stroke-width="0.8"/><circle r="{f1(r - 6)}" stroke-width="0.5"/>"""
  for deg in countup(0, 355, 5):
    let a = degToRad(deg.float - 90)
    let l = if deg mod 30 == 0: 6.0 elif deg mod 10 == 0: 4.0 else: 2.5
    result.add &"""<line x1="{f1(r * cos(a))}" y1="{f1(r * sin(a))}" x2="{f1((r - l) * cos(a))}" y2="{f1((r - l) * sin(a))}" stroke-width="0.5"/>"""
  for deg in countup(0, 330, 30):
    let a = degToRad(deg.float - 90)
    result.add &"""<text x="{f1((r + 6) * cos(a))}" y="{f1((r + 6) * sin(a) + 2.5)}" text-anchor="middle" font-size="6" fill="{magenta}" stroke="none">{deg}</text>"""
  let variation = -3.0
  result.add &"""<g transform="rotate({variation})"><circle r="{f1(r * 0.62)}" stroke-width="0.5"/>"""
  for deg in countup(0, 350, 10):
    let a = degToRad(deg.float - 90)
    result.add &"""<line x1="{f1(r * 0.62 * cos(a))}" y1="{f1(r * 0.62 * sin(a))}" x2="{f1((r * 0.62 - 2.5) * cos(a))}" y2="{f1((r * 0.62 - 2.5) * sin(a))}" stroke-width="0.4"/>"""
  result.add &"""<path d="M0,{f1(-r * 0.6)} L2.5,-3 L-2.5,-3 Z" fill="{magenta}" stroke="none"/></g>"""
  result.add &"""<path d="M0,{f1(-r + 6)} L3,0 L0,{f1(r - 6)} L-3,0 Z" fill="none" stroke-width="0.5"/>"""
  result.add &"""<path d="M{f1(-r + 6)},0 L0,3 L{f1(r - 6)},0 L0,-3 Z" fill="none" stroke-width="0.5"/>"""
  result.add &"""<path d="M0,{f1(-r - 1.5)} l-2.5,5 h5 Z" fill="{magenta}" stroke="none"/>"""
  result.add &"""<text y="{f1(r * 0.3)}" text-anchor="middle" font-size="4.5" fill="{magenta}" stroke="none">VAR 3°W</text></g>"""

func borderSvg*(w, h: float): string =
  ## a fine graduated border: a neatline, minute bars in a thin band, a label every ten minutes
  let band = 5.0
  result = &"""<g class="chart-border"><rect x="0.5" y="0.5" width="{f1(w - 1)}" height="{f1(h - 1)}" fill="none" stroke="{ink}" stroke-width="0.6"/>"""
  result.add &"""<rect x="{band}" y="{band}" width="{f1(w - 2 * band)}" height="{f1(h - 2 * band)}" fill="none" stroke="{ink}" stroke-width="0.6"/>"""
  var k = 0
  var x = band
  while x < w - band:
    let x2 = min(x + 24, w - band)
    if k mod 2 == 0:
      result.add &"""<rect x="{f1(x)}" y="1" width="{f1(x2 - x)}" height="{band - 1}" fill="{ink}" opacity="0.75"/><rect x="{f1(x)}" y="{f1(h - band)}" width="{f1(x2 - x)}" height="{band - 1}" fill="{ink}" opacity="0.75"/>"""
    if k mod 10 == 0 and k > 0:
      result.add &"""<text x="{f1(x)}" y="{f1(band + 8)}" text-anchor="middle" class="grad">{k}'</text>"""
    x = x2
    inc k
  k = 0
  var y = band
  while y < h - band:
    let y2 = min(y + 24, h - band)
    if k mod 2 == 0:
      result.add &"""<rect x="1" y="{f1(y)}" width="{band - 1}" height="{f1(y2 - y)}" fill="{ink}" opacity="0.75"/><rect x="{f1(w - band)}" y="{f1(y)}" width="{band - 1}" height="{f1(y2 - y)}" fill="{ink}" opacity="0.75"/>"""
    if k mod 10 == 0 and k > 0:
      result.add &"""<text x="{f1(w - band - 3)}" y="{f1(y + 3)}" text-anchor="end" class="grad">{k}'</text>"""
    y = y2
    inc k
  result.add "</g>"

func cape*(isl: Island, dir: Pt): Pt =
  ## the point of the coast farthest out in direction `dir`
  var best = -Inf
  for p in isl.polygon:
    let s = (p.x - isl.center.x) * dir.x + (p.y - isl.center.y) * dir.y
    if s > best: best = s; result = p

func summit*(f: Field, isl: Island): Pt =
  ## the point of the island farthest from its coast, where its height is written
  var best = 0.0
  result = isl.center
  let r = isl.r * 1.2
  var dy = -r
  while dy <= r:
    var dx = -r
    while dx <= r:
      let q: Pt = (isl.center.x + dx, isl.center.y + dy)
      if f.at(q) < best: best = f.at(q); result = q
      dx += 3
    dy += 3

func anchorSvg*(at: Pt): string =
  ## the anchor of the charts, drawn over a pale halo so it reads on land, shoal and deep water
  let d = "M0,-7.5 V9 M-5,-3.5 H5 M-8,3.5 Q-7,9.5 0,10 Q7,9.5 8,3.5 M-9.5,5.5 L-8,3.5 L-6,5.2 M9.5,5.5 L8,3.5 L6,5.2"
  &"""<g class="anchor" transform="translate({f1(at.x)},{f1(at.y)}) scale(0.62) translate(0,-1.5)">""" &
    &"""<circle cx="0" cy="1.5" r="12.5" class="anchor-halo"/>""" &
    &"""<circle cx="0" cy="-9.6" r="2.2" fill="none"/><path d="{d}" fill="none"/></g>"""

func chartLabel*(isl: Island, name: string, current: bool, w: float): Pt =
  ## where the name of an island goes on the chart, when it is not set by hand: above or below it,
  ## kept inside the chart
  result = isl.labelPos
  let size = if current: 17.0 else: 14.5
  if not isl.labelBelow: result.y -= 2
  let half = 0.37 * size * (name.len + 4).float # about half the width of the name, at its size
  result.x = clamp(result.x, half + 10, w - half - 10)

proc chartMap*(v: Voyage, names: openArray[string], current: int, id = "", html = false): string =
  ## With `html` the words of the chart (the names of the islands, the title block, the notes) are
  ## html elements over the svg, placed in percent of the map, so css can move and restyle them;
  ## the svg keeps only the drawing and its small print (soundings, heights, graduations)
  var words: seq[string]
  template word(cls, text: string, at: Pt, anchor = "middle", attrs = "") =
    let p: Pt = at
    if html:
      words.add "<div class=\"ct " & cls & " ct-" & anchor & "\"" & attrs & " style=\"left: " & f1(100 * p.x / v.w) & "%; top: " &
        f1(100 * p.y / v.h) & "%\">" & text & "</div>"
    else:
      result.add "<text class=\"" & cls & "\" x=\"" & f1(p.x) & "\" y=\"" & f1(p.y) & "\" text-anchor=\"" & anchor & "\">" &
        text & "</text>"
  let id = if id.len > 0: id else: $current
  let f = v.field
  let bed = v.seaFloor
  result = &"""<svg class="voyage-map chart-map" viewBox="0 0 {v.w.int} {v.h.int}" xmlns="http://www.w3.org/2000/svg">
<defs><clipPath id="chart-clip-{id}"><rect width="{v.w.int}" height="{v.h.int}"/></clipPath>
<mask id="chart-sea-{id}"><rect width="{v.w.int}" height="{v.h.int}" fill="white"/>{seaMask(v)}</mask></defs>
<g clip-path="url(#chart-clip-{id})">
<rect width="{v.w.int}" height="{v.h.int}" fill="{paper}"/>
"""
  # depth areas, 20 m to the coast, then a thin drying band
  for (m, color) in [(20.0, "#e6f2fa"), (10.0, "#c8e2f3"), (5.0, "#a6cfec")]:
    result.add &"""<path d="{fillBelow(bed, level(m))}" fill="{color}" fill-rule="evenodd"/>"""
  result.add &"""<path d="{fillBelow(f, 1.6)}" fill="#c2d9a8" fill-rule="evenodd"/>"""
  # depth contours, with their depth written on the long ones
  for m in [5.0, 10.0, 20.0, 50.0, 100.0]:
    let dash = if m >= 50: " stroke-dasharray=\"5 3\"" else: ""
    for line in bed.contours(level(m)):
      if line.len < 8: continue
      result.add &"""<path d="{svgPath(line.smooth, closed = false)}" fill="none" stroke="{depthLine}" stroke-width="0.5"{dash}/>"""
      if line.len > 50:
        let p = line[line.len div 3]
        result.add &"""<text x="{f1(p.x)}" y="{f1(p.y + 2.5)}" class="contour-label">{int(m)}</text>"""
  # land: buff, a thin coastline, faint relief, the real height of each island at its summit
  for poly in v.lands:
    result.add &"""<path d="{svgPath(poly)}" fill="#f3e3ae" stroke="{ink}" stroke-width="0.8" stroke-linejoin="round"/>"""
  for lev in [-8.0, -16.0, -26.0]:
    for line in f.contours(lev):
      if line.len > 6:
        result.add &"""<path d="{svgPath(line.smooth, closed = false)}" fill="none" stroke="#c4a96c" stroke-width="0.4"/>"""
  for i, isl in v.islands:
    let top = f.summit(isl)
    let height = if isl.elevation > 0: $int(round(isl.elevation)) else: $int(-f.at(top) * 22)
    result.add &"""<circle cx="{f1(top.x)}" cy="{f1(top.y)}" r="1.2" fill="{ink}"/><text x="{f1(top.x + 3)}" y="{f1(top.y + 2.5)}" class="spot">{height}</text>"""
    if isl.real.len > 0 and islandNames:
      result.add &"""<text x="{f1(top.x)}" y="{f1(top.y + 12)}" text-anchor="middle" class="real-name">{isl.real.toUpperAscii}</text>"""
  # soundings on a jittered grid, away from labels, the title, the rose and the course
  var r = initRng(7)
  var keepOut: seq[(Pt, Pt)] # boxes
  for isl in v.islands:
    let lp = isl.labelPos
    keepOut.add ((lp.x - 110, lp.y - 14), (lp.x + 110, lp.y + 6))
  let rose = v.compassAt + (-6.0, 16.0)
  keepOut.add ((rose.x - 50, rose.y - 50), (rose.x + 50, rose.y + 50))
  let tb = v.titleAt
  let pb = v.portolanoBox
  let hasPortolano = html and pb[2] > 0 and v.portolano.len > 0 # the portolano box takes the title block's place
  if hasPortolano: keepOut.add ((pb[0] - 4, pb[1] - 4), (pb[0] + pb[2] + 4, pb[1] + pb[3] + 4))
  else: keepOut.add ((tb.x - 165, tb.y - 18), (tb.x + 165, tb.y + 42)) # the title block
  keepOut.add ((v.w - 260, v.h - 26), (v.w, v.h)) # the source note
  func inside(p: Pt, b: (Pt, Pt)): bool = p.x > b[0].x and p.x < b[1].x and p.y > b[0].y and p.y < b[1].y
  let course = v.routePolyline
  result.add "<g class=\"soundings\">"
  var y = 24.0
  while y < v.h - 16:
    var x = 24.0
    while x < v.w - 16:
      let p: Pt = (x + (r.next - 0.5) * 20, y + (r.next - 0.5) * 18)
      var ok = f.at(p) > 5
      for b in keepOut:
        if p.inside(b): ok = false
      for q in course:
        if abs(q.x - p.x) < 9 and abs(q.y - p.y) < 9: ok = false
      if ok: result.add soundingText(metres(bed.at(p)) + 0.8 * r.next, p)
      x += 44
    y += 38
  result.add "</g>"
  # rocks awash on a few shallow spots
  var placed = 0
  var tries = 0
  while placed < 9 and tries < 600:
    inc tries
    let p: Pt = (60 + r.next * (v.w - 120), 30 + r.next * (v.h - 60))
    let d = f.at(p)
    if d > 3 and d < 7 and metres(bed.at(p)) < 5:
      result.add &"""<g transform="translate({f1(p.x)},{f1(p.y)})" stroke="{ink}" stroke-width="0.6"><line x1="-3" x2="3"/><line y1="-3" y2="3"/><circle cx="-2" cy="-2" r="0.5" fill="{ink}" stroke="none"/><circle cx="2" cy="-2" r="0.5" fill="{ink}" stroke="none"/><circle cx="-2" cy="2" r="0.5" fill="{ink}" stroke="none"/><circle cx="2" cy="2" r="0.5" fill="{ink}" stroke="none"/></g>"""
      inc placed
  # the course: dashed ahead, solid where sailed
  result.add &"""<g mask="url(#chart-sea-{id})">"""
  # on the whole map the course is drawn through a mask, so the deck can draw it from the first port
  # on (the mask's path is drawn in full without javascript); on a chart of an island the leg just
  # sailed is a path of its own (class leg-new), for the deck to draw it
  let reveal = if html and current == 0: &" mask=\"url(#chart-course-{id})\"" else: ""
  if reveal.len > 0:
    result.add &"""<mask id="chart-course-{id}"><path class="course-mask" d="{svgPath(course, closed = false)}" fill="none" stroke="white" stroke-width="5"/></mask>"""
  result.add &"""<path d="{svgPath(course, closed = false)}" fill="none" stroke="{magenta}" stroke-width="1" stroke-dasharray="6 4" opacity="0.6"{reveal}/>"""
  let upTo = if current == 8: v.route.high elif current >= 1: current else: 0
  if upTo > 0:
    if html:
      if upTo > 1:
        result.add &"""<path d="{svgPath(v.routePolyline(upTo - 1), closed = false)}" fill="none" stroke="{magenta}" stroke-width="1.8"/>"""
      result.add &"""<path class="leg-new" d="{svgPath(v.leg(upTo - 1), closed = false)}" fill="none" stroke="{magenta}" stroke-width="1.8"/>"""
    else:
      result.add &"""<path d="{svgPath(v.routeDone(current), closed = false)}" fill="none" stroke="{magenta}" stroke-width="1.8"/>"""
  result.add "</g>"
  # names of the islands of the talk
  for i, isl in v.islands:
    let n = i + 1
    let state = islandState(n, current)
    let lp = if isl.label != (0.0, 0.0): isl.label # set by hand (maps/voyage.json)
             else: chartLabel(isl, names[i], n == current, v.w)
    word("cname" & state, &"{n} · {names[i].toUpperAscii}", lp, attrs = &" data-n=\"{n}\"")
  # an anchor, in the port of the island of the section; in the first port before the voyage,
  # in the last one after it
  if v.route.len > 0:
    let at = if current in 1 .. 7 and current < v.route.len: v.route[current]
             elif current == 8: v.route[^1]
             else: v.route[0]
    result.add anchorSvg(at)
  # the title block, the names of land and sea, the source of the coasts
  let sub =
    if current in 1 .. 7: &"CHART {current} OF 7 · {names[current - 1].toUpperAscii}"
    elif current == 8: "LANDFALL · BACK ON THE MAINLAND"
    else: "FROM THE MAINLAND TO SEVEN ISLANDS"
  let subClass = if current in 1 .. 8: "tb-sub current" else: "tb-sub"
  let tbNote =
    if current in 1 .. 7 and v.islands[current - 1].lore.len > 0 and islandNames: v.islands[current - 1].lore
    else: "Soundings and heights in metres · each island at its own scale"
  if hasPortolano:
    let text = if current < v.portolano.len: v.portolano[current] else: ""
    words.add &"""<div class="ct portolano" style="left: {f1(100 * pb[0] / v.w)}%; top: {f1(100 * pb[1] / v.h)}%; width: {f1(100 * pb[2] / v.w)}%; min-height: {f1(100 * pb[3] / v.h)}%">""" &
      &"""<div class="pt-title">SEAS OF SCIENTIFIC NIM</div><div class="pt-head">{sub}</div><div class="pt-body">{text}</div></div>"""
  elif html:
    words.add &"""<div class="ct title-block" style="left: {f1(100 * tb.x / v.w)}%; top: {f1(100 * (tb.y - 12) / v.h)}%">""" &
      &"""<div class="tb-title">SEAS OF SCIENTIFIC NIM</div><div class="{subClass}">{sub}</div><div class="tb-note">{tbNote}</div></div>"""
  else:
    result.add &"""<g class="title-block" text-anchor="middle"><text x="{f1(tb.x)}" y="{f1(tb.y)}" class="tb-title">SEAS OF SCIENTIFIC NIM</text>"""
    result.add &"""<text x="{f1(tb.x)}" y="{f1(tb.y + 14)}" class="{subClass}">{sub}</text>"""
    result.add &"""<text x="{f1(tb.x)}" y="{f1(tb.y + 26)}" class="tb-note">{tbNote}</text></g>"""
  for isl in v.islands:
    if isl.note.len > 0:
      let c = isl.cape((-1.0, 0.5))
      word("chart-note", isl.note, (c.x - 5, c.y + 10), "end")
  if html and v.landLabelAngle == 0: word("land-name", "THE MAINLAND", v.landLabel)
  else: result.add &"""<text class="land-name" {v.landLabelAttrs} text-anchor="middle">THE MAINLAND</text>"""
  word("note", "Coasts © OpenStreetMap contributors (ODbL) · the mainland is Istria", (v.w / 2, v.h - 10))
  result.add roseSvg(rose, 34)
  result.add "</g>"
  result.add borderSvg(v.w, v.h)
  result.add "\n</svg>"
  if html:
    result = "<div class=\"chart-stage\" data-current=\"" & $current & "\">" & result & words.join("\n") & "</div>"

const chartMapCss* = """
.chart-map .soundings text { font-family: "Spectral", serif; font-style: italic; font-size: 8.5px; fill: #2c3a45; }
.chart-map .contour-label { font-family: "Spectral", serif; font-style: italic; font-size: 7px; fill: #4f7898; paint-order: stroke; stroke: #fdfcf7; stroke-width: 2px; }
.chart-map .spot, .chart-map .grad, .chart-map .note { font-family: "Space Grotesk", sans-serif; font-size: 7px; fill: #1f2a33; }
.chart-map .real-name { font-family: "Space Grotesk", sans-serif; font-size: 6.5px; letter-spacing: 0.18em; fill: #5b4a26; }
.chart-map .note { font-size: 6px; fill: #4a5763; }
.chart-map .cname { font-family: "Space Grotesk", sans-serif; font-weight: 700; font-size: 14.5px; letter-spacing: 0.06em; fill: #13334c; paint-order: stroke; stroke: #fdfcf7; stroke-width: 4px; stroke-linejoin: round; }
.chart-map .cname.visited { fill: #4d6475; }
.chart-map .cname.current { fill: #b0167a; font-size: 17px; }
.chart-map .anchor { stroke: #b0167a; stroke-width: 2.6px; stroke-linecap: round; stroke-linejoin: round; }
.chart-map .anchor-halo { fill: #fdfcf7; fill-opacity: 0.85; stroke: none; }
.chart-map .tb-title { font-family: "Space Grotesk", sans-serif; font-weight: 700; font-size: 15px; letter-spacing: 0.22em; fill: #1f2a33; }
.chart-map .tb-sub { font-family: "Space Grotesk", sans-serif; font-size: 7.5px; letter-spacing: 0.3em; fill: #1f2a33; }
.chart-map .chart-note { font-family: "Spectral", serif; font-style: italic; font-size: 8px; fill: #1f2a33; paint-order: stroke; stroke: #fdfcf7; stroke-width: 2px; }
.chart-map .tb-sub.current { fill: #b0167a; font-weight: 700; font-size: 8.5px; }
.chart-map .tb-note { font-family: "Spectral", serif; font-style: italic; font-size: 8px; fill: #3d6e93; }
.chart-map .land-name { font-family: "Space Grotesk", sans-serif; font-weight: 700; font-size: 12px; letter-spacing: 0.5em; fill: #1f2a33; }
.chart-map .rose text { font-family: "Space Grotesk", sans-serif; }
/* the words of a chart in html (chartMap(html = true)): sizes in cqw, so they scale with the map */
.chart-stage { position: relative; container-type: inline-size; line-height: 1.15; }
.chart-stage > svg { display: block; width: 100%; max-width: none; height: auto; margin: 0; }
.chart-stage .ct { position: absolute; white-space: nowrap; transform: translate(-50%, -88%); color: #1f2a33; font-family: "Space Grotesk", sans-serif; }
.chart-stage .ct-end { transform: translate(-100%, -88%); }
.chart-stage .ct.cname { font-weight: 700; font-size: 1.510cqw; letter-spacing: 0.06em; color: #13334c; text-shadow: 0 0 1px #fdfcf7, 0 0 2px #fdfcf7, 0 0 3px #fdfcf7, 0 0 4px #fdfcf7; }
.chart-stage .ct.cname.visited { color: #4d6475; }
.chart-stage .ct.cname.current { color: #b0167a; font-size: 1.771cqw; }
.chart-stage .ct.title-block { transform: translate(-50%, 0); text-align: center; }
.chart-stage .tb-title { font-weight: 700; font-size: 1.562cqw; letter-spacing: 0.22em; }
.chart-stage .tb-sub { font-size: 0.781cqw; letter-spacing: 0.3em; margin-top: 0.4em; }
.chart-stage .tb-sub.current { color: #b0167a; font-weight: 700; font-size: 0.885cqw; }
.chart-stage .tb-note { font-family: "Spectral", serif; font-style: italic; font-size: 0.833cqw; color: #3d6e93; margin-top: 0.3em; }
.chart-stage .ct.chart-note { font-family: "Spectral", serif; font-style: italic; font-size: 0.833cqw; text-shadow: 0 0 1px #fdfcf7, 0 0 2px #fdfcf7, 0 0 3px #fdfcf7, 0 0 4px #fdfcf7; }
.chart-stage .ct.land-name { font-weight: 700; font-size: 1.250cqw; letter-spacing: 0.5em; }
.chart-stage .ct.note { font-size: 0.625cqw; color: #4a5763; }
/* the portolano: the sailing directions of each chart, in a box where the title block was */
.chart-stage .ct.portolano { transform: none; white-space: normal; box-sizing: border-box; background: rgba(253, 252, 247, 0.93); border: 1px solid #1f2a33; outline: 0.5px solid #1f2a33; outline-offset: 0.25cqw; padding: 0.8cqw 1cqw; box-shadow: 0 0.4cqw 1.4cqw rgba(31, 42, 51, 0.12); line-height: 1.3; }
.chart-stage .portolano .pt-title { font-weight: 700; font-size: 1.25cqw; letter-spacing: 0.2em; }
.chart-stage .portolano .pt-head { font-weight: 700; font-size: 0.78cqw; letter-spacing: 0.3em; color: #b0167a; margin: 0.3cqw 0 0.6cqw; padding-bottom: 0.5cqw; border-bottom: 0.5px solid #1f2a33; }
.chart-stage .portolano .pt-body { font-family: "Spectral", serif; font-style: italic; font-size: 1.4cqw; line-height: 1.4; }

"""
  ## css for the labels of this map (the fonts are in docs/assets/fonts/fonts.css)
