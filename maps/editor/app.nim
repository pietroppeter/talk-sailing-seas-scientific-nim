## The map editor, in Nim compiled to JavaScript (the page is mapeditor.nim, built to
## docs/mapeditor.html). It draws the chart of maps/chart.nim from the same modules the deck uses:
## the arrangement is the json of maps/voyage.json, turned into a Voyage by `layoutFromJson` and
## `layoutVoyage` (maps/isole.nim), and drawn with the parts of the chart (maps/chart.nim). Only
## the distance field is its own: one per piece of land, kept while that piece does not move, so a
## dragged island redraws the depths at once.
import std / [dom, json, math, strutils, strformat, tables, algorithm, sugar]
import ../geometry, ../isole, ../chart

const
  W = 960.0
  H = 540.0
  magenta = "#b0167a"
  ink = "#1f2a33"
  depthLine = "#6f93b0"
  sampleTexts = [ # drafts by Claude, to be rewritten by Pietro
    "Seven islands off the mainland, sailed clockwise. Each island is drawn at its own scale; soundings in metres.",
    "First landfall. The passage most sailors come for: code that reads like Python and runs like C.",
    "Inhabited: crews of bioinformaticians and lattice physicists made port here and stayed. Ask for their logbooks.",
    "Well charted waters: tensors, data frames and plots. A small crew keeps the beacons lit; mind the rocks where the charts end.",
    "Bridges to Python, C and JavaScript. Ships of any flag may call here and leave with their cargo.",
    "Operators and units of your own making. Macros shape this coast: read the signs before going ashore.",
    "The same app sailed twice: once in Shiny, once compiled to JavaScript. Light winds, quick crossing.",
    "The home port of this chart: notebooks as plain Nim files, built into pages and slides.",
    "Landfall. Back on the mainland, the hold full of samples. Fair winds."]

# --- what javascript gives and std/dom does not ----------------------------------------------
proc now(): float {.importjs: "performance.now()".}
proc closest(e: Element, sel: cstring): Element {.importjs: "#.closest(#)".}
proc attr(e: Element, name: cstring): cstring {.importjs: "(#.getAttribute(#) || '')".}
proc pointerId(e: Event): int {.importjs: "#.pointerId".}
proc capture(e: Element, id: int) {.importjs: "try { #.setPointerCapture(#) } catch (e) {}".}
proc totalLength(e: Element): float {.importjs: "#.getTotalLength()".}
proc storageGet(key: cstring): cstring {.importjs: "(function(k){ try { return localStorage.getItem(k) || '' } catch (e) { return '' } })(#)".}
proc storageSet(key, value: cstring) {.importjs: "(function(k, v){ try { localStorage.setItem(k, v) } catch (e) {} })(#, #)".}
proc copyText(text: cstring, ok, fail: proc ()) {.importjs: "(function(t, ok, fail){ navigator.clipboard ? navigator.clipboard.writeText(t).then(ok, fail) : fail() })(#, #, #)".}
proc selectAll(e: Element) {.importjs: "#.select()".}
proc focused(e: Element): bool {.importjs: "(document.activeElement === #)".}
proc reflow(e: Element) {.importjs: "#.getBoundingClientRect()".}
proc setCss(e: Element, prop, value: cstring) {.importjs: "#.style.setProperty(#, #)".}
proc ctrlOrMeta(e: Event): bool {.importjs: "(function(e){ return e.ctrlKey || e.metaKey })(#)".}
proc shift(e: Event): bool {.importjs: "#.shiftKey".}
proc keyOf(e: Event): cstring {.importjs: "#.key".}
proc isEditable(e: Event): bool {.importjs: "(function(e){ return !!(e.target.closest && e.target.closest('textarea, input')) })(#)".}
proc rafLater(cb: proc ()) {.importjs: "requestAnimationFrame(#)".}
proc later(cb: proc (), ms: int) {.importjs: "setTimeout(#, #)".}
proc every(cb: proc (), ms: int): int {.importjs: "setInterval(#, #)".}
proc stopEvery(id: int) {.importjs: "clearInterval(#)".}
proc checked(id: string): bool = document.getElementById(cstring id).checked
proc el(id: string): Element = document.getElementById(cstring id)
proc setHtml(id: string, html: string) = el(id).innerHTML = cstring html
proc `[]=`(a: JsonNode, i: int, v: JsonNode) = a.elems[i] = v
proc clientXY(e: Event): Pt = (e.MouseEvent.clientX.float, e.MouseEvent.clientY.float)

func esc(t: string): string =
  for c in t:
    case c
    of '&': result.add "&amp;"
    of '<': result.add "&lt;"
    of '>': result.add "&gt;"
    of '"': result.add "&quot;"
    of '\'': result.add "&#39;"
    else: result.add c
func r2(x: float): float = round(x * 100) / 100
func pc(x: float): string = formatFloat(x, ffDecimal, 2)

# --- the arrangement: its json, as maps/voyage.json ------------------------------------------
var S: JsonNode
var names: seq[string]

func pt(n: JsonNode): Pt = (n[0].getFloat, n[1].getFloat)
func js(p: Pt): JsonNode = %*[r2(p.x), r2(p.y)]

proc withDefaults(j: JsonNode): JsonNode =
  result = j.copy
  result["format"] = %"voyage-map/1"
  result["w"] = %W
  result["h"] = %H
  if not result.hasKey("portolano"): result["portolano"] = newJObject()
  let p = result["portolano"]
  if not p.hasKey("box"): p["box"] = %*[28, 60, 320, 230]
  if not p.hasKey("texts"): p["texts"] = %sampleTexts
  while p["texts"].len < 9: p["texts"].add %""
  if not result.hasKey("agenda"): result["agenda"] = %*{"y": 522}
  for isl in result["islands"]:
    for (k, v) in [("near", newJArray()), ("rotate", %0), ("flip", %false), ("note", %"")]:
      if not isl.hasKey(k): isl[k] = v

# --- the voyage of the arrangement, and the distance field of its lands -----------------------
type
  Shape = object ## a piece of land, its points in flat arrays and in chunks with their boxes
    n: int
    xs, ys: seq[float]
    box: array[4, float]
    chunks: seq[array[6, float]] # first, last + 1, x0, y0, x1, y1
  Group = object
    key: string
    polys: seq[seq[Pt]]
  Piece = object
    d: seq[float]
    inside: seq[bool]

var V: Voyage       # the voyage drawn now
var groups: seq[Group]
var F, bed: Field   # the distance to the coast, and the sea floor (stretched)
var cache: Table[string, Piece]

proc voyageOf(j: JsonNode): Voyage =
  layoutVoyage(layoutFromJson("editor", $j))

proc islandGroups(v: Voyage, j: JsonNode): seq[Group] =
  ## the coast, then each island with the islets drawn near it (La Maddalena by Caprera)
  result.add Group(key: $j["coast"], polys: @[v.coast])
  for i, isl in v.islands:
    let s = j["islands"][i]
    result.add Group(key: $s["real"] & $s["center"] & $s["size"] & $s["rotate"] & $s["flip"] & $s["near"], polys: @[isl.polygon])
  for islet in v.islets:
    var best = Inf
    var k = 1
    for i, isl in v.islands:
      let d = hypot(islet[0].x - isl.center.x, islet[0].y - isl.center.y)
      if d < best: best = d; k = i + 1
    result[k].polys.add islet

proc prepare(polys: seq[seq[Pt]]): seq[Shape] =
  for poly in polys:
    var s = Shape(n: poly.len, box: [Inf, Inf, -Inf, -Inf])
    for p in poly:
      s.xs.add p.x; s.ys.add p.y
      s.box = [min(s.box[0], p.x), min(s.box[1], p.y), max(s.box[2], p.x), max(s.box[3], p.y)]
    var a = 0
    while a < s.n:
      let b = min(s.n, a + 24)
      var c = [a.float, b.float, Inf, Inf, -Inf, -Inf]
      for j in a ..< b:
        for q in [j, (j - 1 + s.n) mod s.n]:
          c[2] = min(c[2], s.xs[q]); c[4] = max(c[4], s.xs[q]); c[3] = min(c[3], s.ys[q]); c[5] = max(c[5], s.ys[q])
      s.chunks.add c
      a = b
    result.add s

func boxDist(x, y, x0, y0, x1, y1: float): float = hypot(max(max(x0 - x, 0.0), x - x1), max(max(y0 - y, 0.0), y - y1))

proc distance(shapes: seq[Shape], x, y: float): float =
  ## signed distance to the nearest coast of `shapes` (as signedDistance in maps/geometry.nim,
  ## skipping the chunks of coast farther than the nearest found)
  var best = Inf
  var inside = false
  for s in shapes:
    let b = s.box
    if x >= b[0] and x <= b[2] and y >= b[1] and y <= b[3]:
      for c in s.chunks:
        if y < c[3] or y > c[5] or x > c[4]: continue
        for i in c[0].int ..< c[1].int:
          let j = (i - 1 + s.n) mod s.n
          let (ax, ay, bx, by) = (s.xs[i], s.ys[i], s.xs[j], s.ys[j])
          if (ay > y) != (by > y) and x < (bx - ax) * (y - ay) / (by - ay) + ax: inside = not inside
    if boxDist(x, y, b[0], b[1], b[2], b[3]) >= best: continue
    for c in s.chunks:
      if boxDist(x, y, c[2], c[3], c[4], c[5]) >= best: continue
      for i in c[0].int ..< c[1].int:
        let j = (i - 1 + s.n) mod s.n
        let (ax, ay) = (s.xs[j], s.ys[j])
        let (dx, dy) = (s.xs[i] - ax, s.ys[i] - ay)
        let l2 = dx * dx + dy * dy
        let t = if l2 == 0: 0.0 else: clamp(((x - ax) * dx + (y - ay) * dy) / l2, 0.0, 1.0)
        best = min(best, hypot(x - (ax + t * dx), y - (ay + t * dy)))
  if inside: -best else: best

proc piece(g: Group, cell: float): Piece =
  let key = $cell & "|" & g.key
  if key in cache: return cache[key]
  let nx = int(W / cell) + 3
  let ny = int(H / cell) + 3
  let shapes = prepare(g.polys)
  result.d = newSeq[float](nx * ny)
  result.inside = newSeq[bool](nx * ny)
  for j in 0 ..< ny:
    for i in 0 ..< nx:
      let v = shapes.distance((i - 1).float * cell, (j - 1).float * cell)
      result.d[j * nx + i] = abs(v)
      result.inside[j * nx + i] = v < 0
  if cache.len > 60: cache.clear()
  cache[key] = result

proc fieldOf(gs: seq[Group], cell: float): Field =
  result = Field(cell: cell, nx: int(W / cell) + 3, ny: int(H / cell) + 3)
  let n = result.nx * result.ny
  result.d = newSeq[float](n)
  var inside = newSeq[bool](n)
  for k in 0 ..< n: result.d[k] = Inf
  for g in gs:
    let p = piece(g, cell)
    for k in 0 ..< n:
      if p.d[k] < result.d[k]: result.d[k] = p.d[k]
      if p.inside[k]: inside[k] = true
  for j in 0 ..< result.ny:
    for i in 0 ..< result.nx:
      let k = j * result.nx + i
      result.d[k] = if i == 0 or j == 0 or i == result.nx - 1 or j == result.ny - 1: 1000.0
                    elif inside[k]: -result.d[k] else: result.d[k]

# --- drawing ---------------------------------------------------------------------------------
var mode = "edit"
var current = 0

type Sel = object
  kind: string
  i, k, j: int
var selected: Sel

proc drawDepth(cell: float) =
  V = voyageOf(S)
  groups = islandGroups(V, S)
  F = fieldOf(groups, cell)
  bed = F.stretched
  var s = ""
  for (m, color) in [(20.0, "#e6f2fa"), (10.0, "#c8e2f3"), (5.0, "#a6cfec")]:
    s.add &"""<path d="{fillBelow(bed, level(m))}" fill="{color}" fill-rule="evenodd"/>"""
  s.add &"""<path d="{fillBelow(F, 1.6)}" fill="#c2d9a8" fill-rule="evenodd"/>"""
  for m in [5.0, 10.0, 20.0, 50.0, 100.0]:
    let dash = if m >= 50: " stroke-dasharray=\"5 3\"" else: ""
    for line in bed.contours(level(m)):
      if line.len.float < 8 * 4 / cell: continue
      s.add &"""<path d="{svgPath(line.smooth, closed = false)}" fill="none" stroke="{depthLine}" stroke-width="0.5"{dash}/>"""
      if line.len.float > 50 * 4 / cell:
        let p = line[line.len div 3]
        s.add &"""<text x="{f1(p.x)}" y="{f1(p.y + 2.5)}" class="contour-label">{int(m)}</text>"""
  setHtml("layer-depth", s)
  var l = ""
  for poly in V.lands:
    l.add &"""<path d="{svgPath(poly)}" fill="#f3e3ae" stroke="{ink}" stroke-width="0.8" stroke-linejoin="round"/>"""
  for lev in [-8.0, -16.0, -26.0]:
    for line in F.contours(lev):
      if line.len > 6: l.add &"""<path d="{svgPath(line.smooth, closed = false)}" fill="none" stroke="#c4a96c" stroke-width="0.4"/>"""
  for isl in V.islands:
    let top = F.summit(isl)
    l.add &"""<circle cx="{f1(top.x)}" cy="{f1(top.y)}" r="1.2" fill="{ink}"/><text x="{f1(top.x + 3)}" y="{f1(top.y + 2.5)}" class="spot">{int(round(isl.elevation))}</text>"""
  setHtml("layer-land", l)
  var mask = ""
  for poly in V.lands: mask.add &"""<path d="{svgPath(poly)}" fill="black" stroke="black" stroke-width="6"/>"""
  setHtml("sea-mask", mask)

proc route(): seq[Pt] =
  result.add pt(S["setOut"]["anchor"])
  for isl in S["islands"]: result.add pt(isl["anchor"])
  result.add pt(S["landfall"]["anchor"])

proc legOf(k: int): seq[Pt] =
  let r = route()
  result.add r[k]
  if k < S["legs"].len:
    for p in S["legs"][k]: result.add pt(p)
  result.add r[k + 1]

proc course(upTo = -1): seq[Pt] =
  let last = if upTo < 0: route().high else: min(upTo, route().high)
  for k in 0 ..< last:
    let l = legOf(k)
    result.add (if k == 0: l else: l[1 .. ^1])

proc drawSoundings() =
  if not checked("show-soundings"):
    setHtml("layer-soundings", ""); return
  var r = initRng(7)
  var keep: seq[array[4, float]]
  for s in S["islands"]:
    let lp = pt(s["label"])
    keep.add [lp.x - 110, lp.y - 14, lp.x + 110, lp.y + 6]
  let c = pt(S["compass"])
  keep.add [c.x - 56, c.y - 34, c.x + 44, c.y + 66]
  if checked("show-portolano"):
    let b = S["portolano"]["box"]
    keep.add [b[0].getFloat - 4, b[1].getFloat - 4, b[0].getFloat + b[2].getFloat + 4, b[1].getFloat + b[3].getFloat + 4]
  else:
    let tb = pt(S["titleBlock"])
    keep.add [tb.x - 165, tb.y - 18, tb.x + 165, tb.y + 42]
  keep.add [W - 260, H - 26, W, H]
  let crs = course()
  var s = ""
  var y = 24.0
  while y < H - 16:
    var x = 24.0
    while x < W - 16:
      let p: Pt = (x + (r.next - 0.5) * 20, y + (r.next - 0.5) * 18)
      var ok = F.at(p) > 5
      for b in keep:
        if p.x > b[0] and p.x < b[2] and p.y > b[1] and p.y < b[3]: ok = false
      for q in crs:
        if abs(q.x - p.x) < 9 and abs(q.y - p.y) < 9: ok = false
      if ok: s.add soundingText(metres(bed.at(p)) + 0.8 * r.next, p)
      x += 44
    y += 38
  var placed, tries = 0
  while placed < 9 and tries < 600:
    inc tries
    let p: Pt = (60 + r.next * (W - 120), 30 + r.next * (H - 60))
    let d = F.at(p)
    if d > 3 and d < 7 and metres(bed.at(p)) < 5:
      s.add &"""<g transform="translate({f1(p.x)},{f1(p.y)})" stroke="{ink}" stroke-width="0.6"><line x1="-3" x2="3"/><line y1="-3" y2="3"/><circle cx="-2" cy="-2" r="0.5" fill="{ink}" stroke="none"/><circle cx="2" cy="-2" r="0.5" fill="{ink}" stroke="none"/><circle cx="-2" cy="2" r="0.5" fill="{ink}" stroke="none"/><circle cx="2" cy="2" r="0.5" fill="{ink}" stroke="none"/></g>"""
      inc placed
  setHtml("layer-soundings", s)

proc drawCourse(animate = false) =
  ## the course: dashed ahead, solid where sailed; in the preview the leg just sailed draws itself
  let all = course()
  let moving = animate and mode == "preview"
  var s = &"""<path d="{svgPath(all, closed = false)}" fill="none" stroke="{magenta}" stroke-width="1" stroke-dasharray="6 4" opacity="0.6"/>"""
  let upTo = if current == 8: route().high else: current
  if upTo > 0:
    if moving:
      if upTo > 1: s.add &"""<path d="{svgPath(course(upTo - 1), closed = false)}" fill="none" stroke="{magenta}" stroke-width="1.8"/>"""
      s.add &"""<path class="leg-draw" d="{svgPath(legOf(upTo - 1), closed = false)}" fill="none" stroke="{magenta}" stroke-width="1.8"/>"""
    else:
      s.add &"""<path d="{svgPath(course(upTo), closed = false)}" fill="none" stroke="{magenta}" stroke-width="1.8"/>"""
  elif moving:
    s = &"""<defs><mask id="reveal"><path class="leg-draw slow" d="{svgPath(all, closed = false)}" fill="none" stroke="white" stroke-width="4"/></mask></defs>""" &
      &"""<path d="{svgPath(all, closed = false)}" fill="none" stroke="{magenta}" stroke-width="1" stroke-dasharray="6 4" opacity="0.6" mask="url(#reveal)"/>"""
  setHtml("layer-course", s)
  for p in el("layer-course").querySelectorAll(".leg-draw"):
    let L = p.totalLength
    p.setCss("stroke-dasharray", cstring $L)
    p.setCss("stroke-dashoffset", cstring $L)
    p.reflow
    p.classList.add "go"
    p.setCss("stroke-dashoffset", "0")
  let r = route()
  let a = if current in 1 .. 7: r[current] elif current == 8: r[^1] else: r[0]
  var anchor = anchorSvg(a)
  if moving: anchor = anchor.replace("class=\"anchor\"", "class=\"anchor drop\"")
  setHtml("layer-anchor", anchor)

func state(n, current: int): string =
  if n == current: " current" elif current == 8 or n < current: " visited" else: ""

func at(p: Pt): string = &"left:{pc(100 * p.x / W)}%;top:{pc(100 * p.y / H)}%"

proc subOf(n: int): string =
  if n in 1 .. 7: &"CHART {n} OF 7 · {names[n - 1].toUpperAscii}"
  elif n == 8: "LANDFALL · BACK ON THE MAINLAND"
  else: "FROM THE MAINLAND TO SEVEN ISLANDS"

proc drawPortolano() =
  let b = S["portolano"]["box"]
  let e = el("portolano")
  e.style.left = cstring(pc(100 * b[0].getFloat / W) & "%")
  e.style.top = cstring(pc(100 * b[1].getFloat / H) & "%")
  e.style.width = cstring(pc(100 * b[2].getFloat / W) & "%")
  e.style.height = cstring(pc(100 * b[3].getFloat / H) & "%")
  if checked("show-portolano"): e.removeAttribute("hidden") else: e.setAttribute("hidden", "")
  e.querySelector(".pt-head").textContent = cstring subOf(current)
  if current == 0: e.classList.add "title-card" else: e.classList.remove "title-card"
  e.querySelector(".pt-title").textContent = (if current == 0: "Sailing Seas of Scientific Nim" else: "SEAS OF SCIENTIFIC NIM")
  e.querySelector(".pt-body").textContent = cstring S["portolano"]["texts"][current].getStr
  el("pt-for").textContent = cstring(if current in 1 .. 7: &"island {current} · {names[current - 1]}"
                                     elif current == 8: "landfall (8)" else: "the whole map (0)")
  if not el("pt-text").focused: el("pt-text").value = cstring S["portolano"]["texts"][current].getStr

proc drawWords() =
  var s = &"""<div class="agenda-strip" style="top:{pc(100 * S["agenda"]["y"].getFloat / H)}%"></div>"""
  # in the preview the agenda also has the mainland, where the trip starts (0) and ends (8)
  let mainland = proc (n: int): string =
    if mode != "preview": return ""
    let cls = if n == 0: (if current <= 0: " current" else: " visited") elif current == 8: " current" else: ""
    &"""<div class="ct cname mainland{cls}" data-m="{n}">MAINLAND</div>"""
  s.add mainland(0)
  for i, isl in S["islands"].getElems:
    let n = i + 1
    s.add &"""<div class="ct cname{state(n, current)}" data-kind="label" data-i="{i}" style="{at(pt(isl["label"]))}">{n} · {esc(names[i].toUpperAscii)}</div>"""
  s.add mainland(8)
  let tb = pt(S["titleBlock"])
  let hidden = if checked("show-portolano"): " hidden" else: ""
  let cur = if current > 0: " current" else: ""
  s.add &"""<div class="ct title-block" data-kind="title" style="{at((tb.x, tb.y - 12))}"{hidden}><div class="tb-title">SEAS OF SCIENTIFIC NIM</div><div class="tb-sub{cur}">{esc(subOf(current))}</div><div class="tb-note">Soundings and heights in metres · each island at its own scale</div></div>"""
  for isl in V.islands:
    if isl.note.len > 0:
      let c = isl.cape((-1.0, 0.5))
      s.add &"""<div class="ct chart-note ct-end" style="{at((c.x - 5, c.y + 10))}">{esc(isl.note)}</div>"""
  s.add &"""<div class="ct land-name" data-kind="landLabel" style="{at(pt(S["landLabel"]))}">THE MAINLAND</div>"""
  s.add &"""<div class="ct note" style="{at((W / 2, H - 10))}">Coasts © OpenStreetMap contributors (ODbL)</div>"""
  setHtml("words", s)
  if checked("show-agenda") or mode == "preview": el("words").classList.add "agenda-on" else: el("words").classList.remove "agenda-on"
  drawPortolano()

proc knob(p: Pt, kind: string, i: int, label: string): string =
  &"""<g class="knob" data-kind="{kind}" data-i="{i}" transform="translate({f1(p.x)},{f1(p.y)})"><circle r="7"/><text y="3.5" text-anchor="middle">{label}</text></g>"""

proc drawHandles() =
  if mode != "edit" or not checked("show-handles"):
    setHtml("layer-handles", ""); return
  let sel = selected
  var s = &"""<path class="hit coast-hit{(if sel.kind == "coast": " sel" else: "")}" data-kind="coast" d="{svgPath(V.coast)}"/>"""
  for gi in 1 ..< groups.len:
    let i = gi - 1
    let on = if sel.kind == "island" and sel.i == i: " sel" else: ""
    for poly in groups[gi].polys:
      s.add &"""<path class="hit island-hit{on}" data-kind="island" data-i="{i}" d="{svgPath(poly)}"/>"""
  let r = route()
  for k in 0 ..< r.high:
    let on = sel.kind == "wp" and sel.k == k
    s.add &"""<path class="hit leg-hit{(if on: " sel" else: "")}" data-kind="leg" data-k="{k}" d="{svgPath(legOf(k), closed = false)}"/>"""
    if k < S["legs"].len:
      for j, p in S["legs"][k].getElems:
        let q = pt(p)
        s.add &"""<rect class="wp{(if on and sel.j == j: " sel" else: "")}" data-kind="wp" data-k="{k}" data-j="{j}" x="{f1(q.x - 4)}" y="{f1(q.y - 4)}" width="8" height="8"/>"""
  for i, p in r:
    s.add &"""<circle class="anchor-hit{(if sel.kind == "anchor" and sel.i == i: " sel" else: "")}" data-kind="anchor" data-i="{i}" cx="{f1(p.x)}" cy="{f1(p.y)}" r="5.5"/>"""
  let c = pt(S["compass"])
  s.add &"""<circle class="hit rose-hit" data-kind="compass" cx="{f1(c.x - 6)}" cy="{f1(c.y + 16)}" r="34"/>"""
  if sel.kind == "island":
    let isl = S["islands"][sel.i]
    let ce = pt(isl["center"])
    let size = isl["size"].getFloat
    let a = degToRad(isl["rotate"].getFloat - 90)
    let tip: Pt = (ce.x + size * 0.62 * cos(a), ce.y + size * 0.62 * sin(a))
    s.add &"""<line class="guide" x1="{f1(ce.x)}" y1="{f1(ce.y)}" x2="{f1(tip.x)}" y2="{f1(tip.y)}"/>"""
    s.add knob(tip, "island-rot", sel.i, "↻")
    s.add knob((ce.x + size * 0.5, ce.y + size * 0.5), "island-size", sel.i, "⤡")
  if sel.kind == "coast":
    let t = pt(S["coast"]["trieste"])
    let a = degToRad(S["coast"]["angle"].getFloat - 95 - 90)
    let tip: Pt = (t.x + 70 * cos(a), t.y + 70 * sin(a))
    s.add &"""<circle class="pivot" cx="{f1(t.x)}" cy="{f1(t.y)}" r="3"/><line class="guide" x1="{f1(t.x)}" y1="{f1(t.y)}" x2="{f1(tip.x)}" y2="{f1(tip.y)}"/>"""
    s.add knob(tip, "coast-rot", 0, "↻")
  setHtml("layer-handles", s)

proc exportJson(): string =
  ## the json, one island and one leg per line, as maps/voyage.json
  let o = S.copy
  for i, isl in o["islands"].getElems: isl["name"] = %names[i]
  proc flat(v: JsonNode): string =
    if v.kind == JArray:
      var parts: seq[string]
      for x in v: parts.add flat(x)
      "[" & parts.join(", ") & "]"
    else: $v
  proc row(v: JsonNode): string =
    var parts: seq[string]
    for k, x in v: parts.add escapeJson(k) & ": " & flat(x)
    "{" & parts.join(", ") & "}"
  var lines: seq[string]
  for k, v in o:
    if k == "islands":
      var rows: seq[string]
      for x in v: rows.add "    " & row(x)
      lines.add "  \"islands\": [\n" & rows.join(",\n") & "\n  ]"
    elif k == "legs":
      var rows: seq[string]
      for x in v: rows.add "    " & flat(x)
      lines.add "  \"legs\": [\n" & rows.join(",\n") & "\n  ]"
    elif k == "portolano":
      var rows: seq[string]
      for t in v["texts"]: rows.add "      " & $t
      lines.add "  \"portolano\": {\n    \"box\": " & flat(v["box"]) & ",\n    \"texts\": [\n" & rows.join(",\n") & "\n    ]\n  }"
    elif v.kind == JObject: lines.add "  " & escapeJson(k) & ": " & row(v)
    else: lines.add "  " & escapeJson(k) & ": " & flat(v)
  "{\n" & lines.join(",\n") & "\n}\n"

proc writeJson() =
  if not el("json").focused: el("json").value = cstring exportJson()

proc inspector()

proc renderLight() =
  drawSoundings(); drawCourse(); drawWords(); drawHandles()

proc renderAll(cell = 4.0) =
  setHtml("layer-rose", roseSvg((pt(S["compass"]).x - 6, pt(S["compass"]).y + 16), 34))
  drawDepth(cell)
  renderLight()
  inspector()
  writeJson()

var pending = false
proc scheduleGeometry(cell: float) =
  ## while dragging: at most once a frame, the coast coarser (it is the slow part)
  if pending: return
  pending = true
  rafLater(proc () =
    pending = false
    drawDepth(cell)
    renderLight())

proc busy(f: proc ()) =
  el("busy").removeAttribute("hidden")
  later(proc () = f(); el("busy").setAttribute("hidden", ""), 16)

# --- history and storage -------------------------------------------------------------------
var past, future: seq[string]
proc commit() =
  let snap = $S
  if past.len == 0 or past[^1] != snap:
    past.add snap
    if past.len > 200: past.delete(0)
    future.setLen 0
  storageSet("voyage-map-editor", cstring snap)

proc restore(snap: string) =
  S = withDefaults(parseJson(snap))
  storageSet("voyage-map-editor", cstring snap)
  renderAll()

proc msg(t: string) = el("json-msg").textContent = cstring t

# --- laying the course: the shortest way by sea, then as few straight legs as the water allows --
var clear = 9.0 ## how far from any coast a course keeps (map units), except near its ports; less in narrows

proc clearAt(p: Pt, ends: openArray[Pt]): bool =
  let d = F.at(p)
  for e in ends:
    if hypot(p.x - e.x, p.y - e.y) < 20: return d > min(1.5, clear)
  d > clear

proc seaLine(a, b: Pt, ends: openArray[Pt]): bool =
  let n = max(2, int(ceil(hypot(b.x - a.x, b.y - a.y) / 2)))
  for k in 0 .. n:
    let t = k / n
    if not clearAt((a.x + t * (b.x - a.x), a.y + t * (b.y - a.y)), ends): return false
  true

proc layLegAt(k: int): (bool, seq[Pt]) =
  let r = route()
  let (src, dst) = (r[k], r[k + 1])
  let ends = [src, dst]
  if seaLine(src, dst, ends): return (true, @[])
  # A* on the grid of the distance field, 8 neighbours, a little extra cost close to land
  let c = F.cell
  let nx = int(W / c) + 1
  let ny = int(H / c) + 1
  proc idx(p: Pt): int = clamp(int(round(p.y / c)), 0, ny - 1) * nx + clamp(int(round(p.x / c)), 0, nx - 1)
  proc pos(i: int): Pt = ((i mod nx).float * c, (i div nx).float * c)
  let start = idx(src)
  let goal = idx(dst)
  var g = newSeq[float](nx * ny)
  var prev = newSeq[int](nx * ny)
  for i in 0 ..< g.len: g[i] = Inf; prev[i] = -1
  g[start] = 0
  var heap: seq[(float, int)] = @[(0.0, start)]
  let gp = pos(goal)
  proc push(f: float, i: int) =
    heap.add (f, i)
    var j = heap.high
    while j > 0:
      let q = (j - 1) div 2
      if heap[q][0] <= heap[j][0]: break
      swap(heap[q], heap[j]); j = q
  proc pop(): (float, int) =
    result = heap[0]
    let last = heap.pop
    if heap.len > 0:
      heap[0] = last
      var j = 0
      while true:
        let (l, rr) = (2 * j + 1, 2 * j + 2)
        var m = j
        if l < heap.len and heap[l][0] < heap[m][0]: m = l
        if rr < heap.len and heap[rr][0] < heap[m][0]: m = rr
        if m == j: break
        swap(heap[m], heap[j]); j = m
  while heap.len > 0:
    let (_, i) = pop()
    if i == goal: break
    let (x, y) = (i mod nx, i div nx)
    for dy in -1 .. 1:
      for dx in -1 .. 1:
        if dx == 0 and dy == 0: continue
        let (X, Y) = (x + dx, y + dy)
        if X < 0 or Y < 0 or X >= nx or Y >= ny: continue
        let j = Y * nx + X
        if j != goal and not clearAt(pos(j), ends): continue
        let cost = c * hypot(dx.float, dy.float) * (1 + 1.5 / max(1.0, F.at(pos(j)) / 10))
        if g[i] + cost < g[j]:
          g[j] = g[i] + cost
          prev[j] = i
          let p = pos(j)
          push(g[j] + hypot(p.x - gp.x, p.y - gp.y), j)
  if prev[goal] < 0: return (false, @[])
  var path = @[dst]
  var i = prev[goal]
  while i >= 0 and i != start:
    path.add pos(i); i = prev[i]
  path.add src
  path.reverse
  # string pulling: from each turn, sail straight to the farthest point still in clear water
  var turns: seq[Pt]
  var a = 0
  while a < path.high:
    var b = path.high
    while b > a + 1 and not seaLine(path[a], path[b], ends): dec b
    if b < path.high: turns.add (r2(path[b].x), r2(path[b].y))
    a = b
  (true, turns)

proc layLeg(k: int): JsonNode =
  for c in [9.0, 6.0, 4.0, 2.0, 0.5]:
    clear = c
    let (ok, turns) = layLegAt(k)
    if ok:
      clear = 9
      result = newJArray()
      for p in turns: result.add js(p)
      return
  clear = 9
  S["legs"][k]

proc layCourse(only = -1) =
  while S["legs"].len < route().high: S["legs"].add newJArray()
  for k in 0 ..< route().high:
    if only < 0 or only == k: S["legs"][k] = layLeg(k)
  commit(); renderLight(); inspector(); writeJson()

proc coastPort(port: Pt): Pt =
  let c = S["coast"]
  coastPoint(triesteGulf[triesteAt], c["angle"].getFloat, c["scale"].getFloat, pt(c["trieste"]), port)

proc islandPort(i: int): Pt =
  let s = S["islands"][i]
  let isl = isole[s["real"].getStr]
  var port: Pt
  for (name, p, _) in islandPicks:
    if name == s["real"].getStr: port = p
  isl.placement(pt(s["center"]), s["size"].getFloat, s["rotate"].getFloat, s["flip"].getBool).toMap(isl.kmOf(port))

proc shelter(i: int): Pt =
  ## the sheltered water near port i (0 Portorož, 1..7 the islands, 8 Koper), as maps/isole.nim finds it
  let last = S["islands"].len + 1
  let h = if i == 0: harbour(@[V.coast], coastPort(pt(S["setOut"]["port"])))
          elif i == last: harbour(@[V.coast], coastPort(pt(S["landfall"]["port"])))
          else: harbour(groups[i].polys, islandPort(i - 1))
  (r2(h.x), r2(h.y))

proc snapAnchors() =
  for i in 0 ..< S["islands"].len: S["islands"][i]["anchor"] = js(shelter(i + 1))
  S["setOut"]["anchor"] = js(shelter(0))
  S["landfall"]["anchor"] = js(shelter(S["islands"].len + 1))
  commit(); renderLight(); inspector(); writeJson()

# --- the inspector ------------------------------------------------------------------------
var nextId = 0
proc control(html: string, wire: proc (e: Element)): string =
  ## a control in the inspector, wired once it is on the page
  inc nextId
  let id = "c" & $nextId
  later(proc () = (let e = el(id); if not e.isNil: wire(e)), 0)
  html.replace("{id}", id)

func shown(v: float): string =
  ## a number as typed: 80, not 80.0
  if v == round(v): $int(v) else: $v

proc numberRow(label: string, value, step: float, on: proc (v: float)): string =
  control(&"""<label class="row">{label} <input id="{{id}}" type="number" step="{step}" value="{shown(value)}"></label>""",
    proc (e: Element) =
      e.onchange = proc (ev: Event) =
        on(parseFloat($e.value)); commit(); busy(proc () = renderAll()))

proc button(label: string, on: proc ()): string =
  control(&"""<button id="{{id}}">{label}</button>""", proc (e: Element) =
    e.onclick = proc (ev: Event) = on())

proc removeWp(k, j: int) =
  S["legs"][k].elems.delete(j)
  selected = Sel(kind: "wp", k: k, j: -1)
  commit(); renderLight(); inspector(); writeJson()

proc inspector() =
  let s = selected
  var title, body: string
  case s.kind
  of "":
    title = "Nothing selected"
    body = """<p class="muted">Click an island, the coast, a turning point, an anchor or a name on the chart.</p><p class="muted">After moving islands, lay the course again: the shortest way by sea, in straight legs clear of the coasts.</p><div class="btns">""" &
      button("Lay the whole course again", proc () = layCourse()) & button("Anchors to sheltered water", snapAnchors) & "</div>"
  of "island":
    let isl = S["islands"][s.i]
    let near = if isl["near"].len > 0: " with " & isl["near"][0].getStr else: ""
    title = &"Island {s.i + 1} · {names[s.i]}"
    body = &"""<p class="muted">{esc(isl["real"].getStr)}{near}, {int(round(isole[isl["real"].getStr].elevation))} m high. Drag it, or its knobs: ↻ turns, ⤡ scales. Its name and anchor move with it.</p>""" &
      numberRow("Center x", isl["center"][0].getFloat, 1, proc (v: float) = isl["center"][0] = %v) &
      numberRow("Center y", isl["center"][1].getFloat, 1, proc (v: float) = isl["center"][1] = %v) &
      numberRow("Size (map units)", isl["size"].getFloat, 1, proc (v: float) = isl["size"] = %v) &
      numberRow("Turned (degrees)", isl["rotate"].getFloat, 1, proc (v: float) = isl["rotate"] = %v) &
      control(&"""<label class="check"><input type="checkbox" id="{{id}}"{(if isl["flip"].getBool: " checked" else: "")}> Mirrored north to south</label>""",
        proc (e: Element) =
          e.onchange = proc (ev: Event) =
            isl["flip"] = %e.checked
            let a = pt(isl["anchor"])
            isl["anchor"] = js((a.x, 2 * isl["center"][1].getFloat - a.y))
            commit(); busy(proc () = renderAll())) &
      """<div class="btns">""" & button("Anchor in sheltered water", proc () =
        isl["anchor"] = js(shelter(s.i + 1)); commit(); renderLight(); inspector(); writeJson()) & "</div>"
  of "coast":
    let c = S["coast"]
    title = "The mainland (Istria)"
    body = """<p class="muted">Drag the land to move it, the ↻ knob to turn it around Trieste. The anchors of Portorož and Koper move with it.</p>""" &
      numberRow("Scale (units per km)", c["scale"].getFloat, 0.1, proc (v: float) =
        let t = pt(c["trieste"])
        let k = v / c["scale"].getFloat
        for key in ["setOut", "landfall"]:
          let a = pt(S[key]["anchor"])
          S[key]["anchor"] = js((t.x + (a.x - t.x) * k, t.y + (a.y - t.y) * k))
        c["scale"] = %v) &
      numberRow("Turned (degrees)", c["angle"].getFloat, 0.5, proc (v: float) = c["angle"] = %v) &
      numberRow("Trieste x", c["trieste"][0].getFloat, 1, proc (v: float) = c["trieste"][0] = %v) &
      numberRow("Trieste y", c["trieste"][1].getFloat, 1, proc (v: float) = c["trieste"][1] = %v) &
      control(&"""<label class="row">Coast up to <select id="{{id}}"><option value="{muggia}">Muggia (Istria only)</option><option value="{triesteGulf.high}">Monfalcone (the whole gulf)</option></select></label>""",
        proc (e: Element) =
          e.value = cstring $c["to"].getInt
          e.onchange = proc (ev: Event) =
            c["to"] = %parseInt($e.value)
            c["openEast"] = %(c["to"].getInt == muggia)
            commit(); busy(proc () = renderAll()))
  of "wp":
    let k = s.k
    let src = if k == 0: "Portorož" else: &"island {k}"
    let dst = if k == S["islands"].len: "Koper" else: &"island {k + 1}"
    let n = if k < S["legs"].len: S["legs"][k].len else: 0
    title = &"Leg {k + 1}: {src} to {dst}"
    body = &"""<p class="muted">{n} turning points. Drag them; double-click the leg to add one, double-click a point (or Delete) to remove it.</p><div class="btns">""" &
      button("Lay this leg again", proc () = layCourse(k)) &
      (if s.j >= 0: button("Remove this turning point", proc () = removeWp(k, s.j)) else: "") & "</div>"
  of "anchor":
    let last = S["islands"].len + 1
    let what = if s.i == 0: "Portorož, where the voyage sets out" elif s.i == last: "Koper, the landfall"
               else: &"the anchor of island {s.i} · {names[s.i - 1]}"
    title = "Anchor"
    body = &"""<p class="muted">{esc(what)}: the course calls here and the magenta anchor is drawn here.</p><div class="btns">""" &
      button("Back to sheltered water", proc () =
        let p = js(shelter(s.i))
        if s.i == 0: S["setOut"]["anchor"] = p
        elif s.i == last: S["landfall"]["anchor"] = p
        else: S["islands"][s.i - 1]["anchor"] = p
        commit(); renderLight(); writeJson()) & "</div>"
  else:
    let what = {"label": "Name of an island", "title": "Title block", "landLabel": "Name of the mainland",
                "compass": "Compass rose", "portolano": "Portolano box", "portolano-size": "Portolano box"}.toTable
    title = what.getOrDefault(s.kind, s.kind)
    body = """<p class="muted">Drag it where it reads best.</p>"""
  el("ins-title").textContent = cstring title
  setHtml("ins-body", body)

proc select(s: Sel) =
  selected = s
  drawHandles(); inspector()

# --- dragging ------------------------------------------------------------------------------
type Drag = object
  on, moved: bool
  kind: string
  i, k, j, pointer: int
  p0: Pt
  s0: JsonNode

var drag: Drag

proc mapPoint(e: Event): Pt =
  let r = el("chart").getBoundingClientRect()
  let c = clientXY(e)
  ((c.x - r.left) / r.width * W, (c.y - r.top) / r.height * H)

func plus(p: Pt, d: Pt): Pt = (r2(p.x + d.x), r2(p.y + d.y))
func turnAround(p, c: Pt, a: float): Pt =
  let (x, y) = (p.x - c.x, p.y - c.y)
  (r2(c.x + x * cos(a) - y * sin(a)), r2(c.y + x * sin(a) + y * cos(a)))

proc startDrag(e: Event, kind: string, i, k, j: int) =
  if mode != "edit": return
  e.preventDefault()
  drag = Drag(on: true, kind: kind, i: i, k: k, j: j, p0: mapPoint(e), s0: S.copy, pointer: e.pointerId)
  case kind
  of "island", "island-rot", "island-size": select(Sel(kind: "island", i: i))
  of "coast", "coast-rot": select(Sel(kind: "coast"))
  of "wp": select(Sel(kind: "wp", k: k, j: j))
  of "leg": select(Sel(kind: "wp", k: k, j: -1))
  else: select(Sel(kind: kind, i: i))

proc moveDrag(e: Event) =
  if not drag.on: return
  let p = mapPoint(e)
  let d: Pt = (p.x - drag.p0.x, p.y - drag.p0.y)
  let s0 = drag.s0
  if not drag.moved and hypot(d.x, d.y) > 0.5:
    drag.moved = true
    el("stage").capture(drag.pointer)
  if not drag.moved: return
  var geo = false
  case drag.kind
  of "island":
    let (a, b) = (s0["islands"][drag.i], S["islands"][drag.i])
    for key in ["center", "label", "anchor"]: b[key] = js(pt(a[key]).plus(d))
    geo = true
  of "island-rot":
    let (a, b) = (s0["islands"][drag.i], S["islands"][drag.i])
    let c = pt(a["center"])
    let ang = arctan2(p.y - c.y, p.x - c.x) - arctan2(drag.p0.y - c.y, drag.p0.x - c.x)
    b["rotate"] = %round(a["rotate"].getFloat + radToDeg(ang))
    b["anchor"] = js(pt(a["anchor"]).turnAround(c, degToRad(b["rotate"].getFloat - a["rotate"].getFloat)))
    geo = true
  of "island-size":
    let (a, b) = (s0["islands"][drag.i], S["islands"][drag.i])
    let c = pt(a["center"])
    let f = max(0.2, hypot(p.x - c.x, p.y - c.y) / max(1.0, hypot(drag.p0.x - c.x, drag.p0.y - c.y)))
    b["size"] = %round(a["size"].getFloat * f)
    let k = b["size"].getFloat / a["size"].getFloat
    let an = pt(a["anchor"])
    b["anchor"] = js((c.x + (an.x - c.x) * k, c.y + (an.y - c.y) * k))
    geo = true
  of "coast":
    S["coast"]["trieste"] = js(pt(s0["coast"]["trieste"]).plus(d))
    for key in ["setOut", "landfall"]: S[key]["anchor"] = js(pt(s0[key]["anchor"]).plus(d))
    S["landLabel"] = js(pt(s0["landLabel"]).plus(d))
    geo = true
  of "coast-rot":
    let c = pt(s0["coast"]["trieste"])
    let ang = arctan2(p.y - c.y, p.x - c.x) - arctan2(drag.p0.y - c.y, drag.p0.x - c.x)
    S["coast"]["angle"] = %(round((s0["coast"]["angle"].getFloat + radToDeg(ang)) * 10) / 10)
    let da = degToRad(S["coast"]["angle"].getFloat - s0["coast"]["angle"].getFloat)
    for key in ["setOut", "landfall"]: S[key]["anchor"] = js(pt(s0[key]["anchor"]).turnAround(c, da))
    geo = true
  of "wp": S["legs"][drag.k][drag.j] = js(pt(s0["legs"][drag.k][drag.j]).plus(d))
  of "anchor":
    let last = S["islands"].len + 1
    if drag.i == 0: S["setOut"]["anchor"] = js(pt(s0["setOut"]["anchor"]).plus(d))
    elif drag.i == last: S["landfall"]["anchor"] = js(pt(s0["landfall"]["anchor"]).plus(d))
    else: S["islands"][drag.i - 1]["anchor"] = js(pt(s0["islands"][drag.i - 1]["anchor"]).plus(d))
  of "label": S["islands"][drag.i]["label"] = js(pt(s0["islands"][drag.i]["label"]).plus(d))
  of "title": S["titleBlock"] = js(pt(s0["titleBlock"]).plus(d))
  of "landLabel": S["landLabel"] = js(pt(s0["landLabel"]).plus(d))
  of "compass": S["compass"] = js(pt(s0["compass"]).plus(d))
  of "portolano":
    let b = s0["portolano"]["box"]
    S["portolano"]["box"] = %*[r2(b[0].getFloat + d.x), r2(b[1].getFloat + d.y), b[2], b[3]]
  of "portolano-size":
    let b = s0["portolano"]["box"]
    S["portolano"]["box"] = %*[b[0], b[1], max(80.0, r2(b[2].getFloat + d.x)), max(40.0, r2(b[3].getFloat + d.y))]
  else: return
  if geo: scheduleGeometry(if drag.kind.startsWith("coast"): 8.0 else: 4.0)
  elif drag.kind == "compass":
    setHtml("layer-rose", roseSvg((pt(S["compass"]).x - 6, pt(S["compass"]).y + 16), 34)); renderLight()
  elif drag.kind.startsWith("portolano"): drawPortolano()
  else: renderLight()

proc endDrag() =
  if not drag.on: return
  let geo = drag.kind in ["island", "island-rot", "island-size", "coast", "coast-rot"]
  if drag.moved:
    commit()
    if geo: busy(proc () = renderAll())
    else: renderLight(); inspector(); writeJson()
  drag.on = false

proc doubleClick(e: Event, t: Element) =
  let kind = $t.attr("data-kind")
  if kind == "wp": removeWp(parseInt($t.attr("data-k")), parseInt($t.attr("data-j")))
  elif kind == "leg":
    # a new turning point on the leg, between the two points it falls between
    let k = parseInt($t.attr("data-k"))
    let p0 = mapPoint(e)
    let p: Pt = (r2(p0.x), r2(p0.y))
    let l = legOf(k)
    var best = Inf
    var at = 0
    for q in 0 ..< l.high:
      let (a, b) = (l[q], l[q + 1])
      let (dx, dy) = (b.x - a.x, b.y - a.y)
      let l2 = max(dx * dx + dy * dy, 1.0)
      let u = clamp(((p.x - a.x) * dx + (p.y - a.y) * dy) / l2, 0.0, 1.0)
      let dd = hypot(p.x - a.x - u * dx, p.y - a.y - u * dy)
      if dd < best: best = dd; at = q
    while S["legs"].len <= k: S["legs"].add newJArray()
    S["legs"][k].elems.insert(js(p), at)
    selected = Sel(kind: "wp", k: k, j: at)
    commit(); renderLight(); inspector(); writeJson()

# --- the preview of the slides: agenda bar, map, portolano ------------------------------------
type Step = tuple[map: bool, n: int]
var steps: seq[Step]
var stepAt = 0
var playing = -1

proc barPositions(): seq[Pt] =
  ## where each name sits in the agenda bar: measured from a hidden row of the same names
  let stage = el("stage")
  var m = stage.querySelector(".agenda-measure")
  if m.isNil:
    m = document.createElement("div")
    m.className = "agenda-measure"
    stage.appendChild(m)
  m.style.top = cstring(pc(100 * S["agenda"]["y"].getFloat / H) & "%")
  var html = ""
  html.add """<span class="ct cname bar">MAINLAND</span>"""
  for i, n in names: html.add &"""<span class="ct cname bar">{i + 1} · {esc(n.toUpperAscii)}</span>"""
  html.add """<span class="ct cname bar">MAINLAND</span>"""
  m.innerHTML = cstring html
  let r = stage.getBoundingClientRect()
  for c in m.children:
    let b = c.Element.getBoundingClientRect()
    result.add (((b.left + b.width / 2) - r.left) / r.width * W, S["agenda"]["y"].getFloat + 4)

proc place(e: Element, p: Pt) =
  e.style.left = cstring(pc(100 * p.x / W) & "%")
  e.style.top = cstring(pc(100 * p.y / H) & "%")

proc show(i: int) =
  stepAt = clamp(i, 0, steps.high)
  let s = steps[stepAt]
  current = s.n
  el("current").value = cstring $current
  for b in el("pv-steps").children:
    if parseInt($b.Element.attr("data-s")) == stepAt: b.Element.classList.add "on" else: b.Element.classList.remove "on"
  let stage = el("stage")
  stage.setAttribute("data-current", cstring $current) # the mainland in magenta on charts 0 and 8
  if s.map: stage.classList.add "on-map"; stage.classList.remove "on-slide"
  else: stage.classList.add "on-slide"; stage.classList.remove "on-map"
  drawWords(); drawCourse(s.map)
  let bar = barPositions()
  let labels = el("words").querySelectorAll(".cname") # the mainland, the islands, the mainland
  let last = labels.len - 1
  if not s.map:
    for k, e in labels:
      e.classList.add "bar"; e.place(bar[k])
  else: # the names start in the bar and sail to their places on the chart
    for k, e in labels:
      e.classList.add "bar"; e.classList.add "instant"; e.place(bar[k])
    el("words").reflow
    for k, e in labels:
      e.classList.remove "instant"
      let mainland = k == 0 or k == last
      if mainland and (k == 0) != (s.n < 8):
        e.classList.add "away"; continue # not this part of the trip
      capture e, k, mainland: # each name its own e and k (a closure in a loop shares the loop's)
        later(proc () =
          e.classList.remove "bar"
          if mainland: e.classList.add "ashore"; e.place(pt(S["landLabel"]))
          else: e.place(pt(S["islands"][k - 1]["label"])), 120 + 60 * k)
  var sh = el("slide-heading")
  if sh.isNil:
    sh = document.createElement("div")
    sh.id = "slide-heading"
    sh.className = "slide-heading"
  stage.appendChild(sh)
  sh.innerHTML = cstring(if s.map: "" else: &"""<div class="sh-kicker">Island {s.n}</div><div class="sh-title">{esc(names[s.n - 1])}</div><div class="sh-lines"><span></span><span></span><span></span></div>""")

proc stop() =
  if playing >= 0:
    stopEvery(playing); playing = -1
    el("pv-play").textContent = "Play the voyage"

proc setMode(m: string) =
  mode = m
  stop()
  for (id, on) in [("tab-edit", m == "edit"), ("tab-preview", m == "preview")]:
    if on: el(id).classList.add "on" else: el(id).classList.remove "on"
    el(id).setAttribute("aria-selected", cstring $on)
  if m == "preview": el("preview-controls").removeAttribute("hidden") else: el("preview-controls").setAttribute("hidden", "")
  let stage = el("stage")
  if m == "preview": stage.classList.add "previewing" else: stage.classList.remove "previewing"
  stage.classList.remove "on-map"; stage.classList.remove "on-slide"
  stage.removeAttribute("data-current")
  let sh = el("slide-heading")
  if not sh.isNil: sh.parentNode.removeChild(sh)
  el("hint").textContent = cstring(if m == "edit":
    "Drag the islands, the coast, the names, the anchors, the turning points, the rose and the portolano box. Double-click a leg to add a turning point; double-click a turning point to remove it. The depths follow."
    else: "The agenda bar sits at the bottom of every slide; on a map slide the names sail to their islands, the leg just sailed draws itself and the portolano opens. Arrow keys step through.")
  drawHandles()
  if m == "preview": show(stepAt) else: drawWords(); drawCourse()

# --- the editor ----------------------------------------------------------------------------
proc mapEditor*(sectionNames: openArray[string]) =
  ## the editor, in the html of the nbMapEditor block (blocks.nim)
  names = @sectionNames
  S = withDefaults(parseJson(voyageJson))
  let saved = $storageGet("voyage-map-editor")
  if saved.len > 0:
    try: S = withDefaults(parseJson(saved))
    except CatchableError: discard
  # the steps of the preview: the whole map, then for each island its map and one of its slides
  steps = @[(true, 0)]
  for n in 1 .. 7: steps.add [(true, n), (false, n)]
  steps.add (true, 8)
  var chips = ""
  for i, s in steps:
    let label = if not s.map: $s.n elif s.n == 0: "Map" elif s.n == 8: "Land" else: "⚓" & $s.n
    chips.add &"""<button class="pv-step{(if s.map: " map" else: "")}" data-s="{i}">{label}</button>"""
  setHtml("pv-steps", chips)
  var options = """<option value="0">0 · the whole map</option>"""
  for n in 1 .. 8:
    options.add &"""<option value="{n}">{(if n == 8: "8 · back on land" else: $n & " · " & esc(names[n - 1]))}</option>"""
  setHtml("current", options)
  setHtml("layer-border", borderSvg(W, H))

  let stage = el("stage")
  var last: tuple[t: float, p: Pt] = (0.0, (0.0, 0.0))
  stage.addEventListener("pointerdown", proc (e: Event) =
    let target = e.target.Element
    let t = target.closest("[data-kind]")
    # a second press within 350 ms is a double click (pointer events stop the browser's dblclick)
    let c = clientXY(e)
    let dbl = now() - last.t < 350 and hypot(c.x - last.p.x, c.y - last.p.y) < 6
    last = (t: (if dbl: 0.0 else: now()), p: c)
    if dbl and not t.isNil and mode == "edit":
      e.preventDefault(); doubleClick(e, t); return
    if not t.isNil:
      let num = proc (name: cstring): int = (let v = $t.attr(name); if v.len > 0: parseInt(v) else: 0)
      startDrag(e, $t.attr("data-kind"), num("data-i"), num("data-k"), num("data-j"))
    elif not target.closest(".pt-resize").isNil: startDrag(e, "portolano-size", 0, 0, 0)
    elif not target.closest("#portolano").isNil: startDrag(e, "portolano", 0, 0, 0)
    elif mode == "edit": select(Sel()))
  stage.addEventListener("pointermove", moveDrag)
  stage.addEventListener("pointerup", proc (e: Event) = endDrag())
  stage.addEventListener("pointercancel", proc (e: Event) = endDrag())

  el("undo").onclick = proc (e: Event) =
    if past.len > 1: future.add past.pop; restore(past[^1])
  el("redo").onclick = proc (e: Event) =
    if future.len > 0: (let s = future.pop; past.add s; restore(s))
  el("reset").onclick = proc (e: Event) =
    S = withDefaults(parseJson(voyageJson)); selected = Sel(); commit(); renderAll(); msg("Back to the deck's map.")
  document.addEventListener("keydown", proc (e: Event) =
    if e.isEditable: return
    let key = $e.keyOf
    if e.ctrlOrMeta and key.toLowerAscii == "z":
      e.preventDefault()
      if e.shift: el("redo").click() else: el("undo").click()
    if key in ["Delete", "Backspace"] and selected.kind == "wp" and selected.j >= 0: removeWp(selected.k, selected.j)
    if mode == "preview" and key == "ArrowRight": show(stepAt + 1)
    if mode == "preview" and key == "ArrowLeft": show(stepAt - 1))

  el("copy").onclick = proc (e: Event) =
    let t = exportJson()
    el("json").value = cstring t
    copyText(cstring t, proc () = msg("Copied: paste it in the thread."),
      proc () = (el("json").selectAll; msg("Copy is blocked here: the text is selected, copy it with Ctrl+C.")))
  el("load").onclick = proc (e: Event) =
    try:
      let j = parseJson($el("json").value)
      if not (j.hasKey("islands") and j.hasKey("coast") and j.hasKey("legs")): raise newException(ValueError, "this is not the json of the map editor")
      S = withDefaults(j); selected = Sel(); commit(); renderAll(); msg("Loaded.")
    except CatchableError as err: msg("Could not load it: " & err.msg)

  el("pv-steps").onclick = proc (e: Event) =
    let b = e.target.Element.closest("[data-s]")
    if not b.isNil: (stop(); show(parseInt($b.attr("data-s"))))
  el("pv-prev").onclick = proc (e: Event) = (stop(); show(stepAt - 1))
  el("pv-next").onclick = proc (e: Event) = (stop(); show(stepAt + 1))
  el("pv-play").onclick = proc (e: Event) =
    if playing >= 0: stop(); return
    if stepAt >= steps.high: show(0)
    el("pv-play").textContent = "Pause"
    playing = every(proc () = (if stepAt >= steps.high: stop() else: show(stepAt + 1)), 3200)
  el("tab-edit").onclick = proc (e: Event) = setMode("edit")
  el("tab-preview").onclick = proc (e: Event) = setMode("preview")
  el("current").onchange = proc (e: Event) =
    current = parseInt($el("current").value)
    if mode == "preview":
      for i, s in steps:
        if s.map and s.n == current: show(i)
    else: drawCourse(); drawWords()
  for id in ["show-handles", "show-agenda", "show-portolano"]:
    el(id).onchange = proc (e: Event) = drawSoundings(); drawWords(); drawHandles()
  el("show-soundings").onchange = proc (e: Event) = drawSoundings()
  el("pt-text").addEventListener("input", proc (e: Event) =
    S["portolano"]["texts"][current] = %($el("pt-text").value); drawPortolano(); writeJson())
  el("pt-text").onchange = proc (e: Event) = commit()
  el("agenda-y").value = cstring $S["agenda"]["y"].getFloat.int
  el("agenda-y").addEventListener("input", proc (e: Event) =
    S["agenda"]["y"] = %parseFloat($el("agenda-y").value); drawWords(); writeJson())
  el("agenda-y").onchange = proc (e: Event) = commit()

  commit()
  let t0 = now()
  renderAll()
  echo "chart drawn in ", int(now() - t0), " ms"
  setMode("edit")
