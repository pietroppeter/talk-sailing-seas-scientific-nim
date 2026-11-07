## The book theme's map: the voyage geometry drawn like a hand-drawn chart of the
## 19th century. Coasts and lines wobble a little (an svg displacement filter), the sea
## is "water-lined" with many thin lines that follow the coast, the land is stippled
## along the shore and carries little hills drawn in profile, rhumb lines radiate
## from an ornate compass rose with a fleur-de-lis, a small ship sails the track,
## and the title sits in a cartouche. Everything comes from maps/geometry.nim.
import std / [math, strformat, strutils]
import geometry, base
export geometry

const
  ink = "#2a1d12"
  red = "#8e1b17"
  paper = "#efe5cf"

func hill(x, y, w, h: float): string =
  ## a hill drawn in profile, shaded with strokes on its right side
  result = &"""<path d="M{f1(x - w)},{f1(y)} Q{f1(x - w * 0.3)},{f1(y - h * 1.2)} {f1(x)},{f1(y - h)} Q{f1(x + w * 0.4)},{f1(y - h * 0.9)} {f1(x + w)},{f1(y)}" fill="{paper}" stroke="{ink}" stroke-width="0.9"/>"""
  for k in 1 .. 4:
    let t = k.float / 5
    let sx = x + w * t * 0.9
    let sy = y - h * (1 - t) * 0.95
    result.add &"""<line x1="{f1(sx)}" y1="{f1(sy + 1)}" x2="{f1(sx - 1.5)}" y2="{f1(y - 0.5)}" stroke="{ink}" stroke-width="0.5"/>"""

func volcano(x, y, s: float): string =
  result = &"""<path d="M{f1(x - s)},{f1(y)} L{f1(x - s * 0.25)},{f1(y - s * 0.9)} L{f1(x + s * 0.25)},{f1(y - s * 0.9)} L{f1(x + s)},{f1(y)}" fill="{paper}" stroke="{ink}" stroke-width="1"/>"""
  result.add &"""<path d="M{f1(x)},{f1(y - s)} q-6,-6 0,-12 q6,-6 0,-12" fill="none" stroke="{ink}" stroke-width="0.6"/>"""
  for k in 1 .. 5:
    let sx = x + s * 0.25 + k.float * s * 0.13
    result.add &"""<line x1="{f1(sx)}" y1="{f1(y - s * 0.9 + k.float * s * 0.15)}" x2="{f1(sx - 1)}" y2="{f1(y - 0.5)}" stroke="{ink}" stroke-width="0.5"/>"""

func palm(x, y, s: float): string =
  result = &"""<path d="M{f1(x)},{f1(y)} q2,{f1(-s * 0.5)} {f1(s * 0.15)},{f1(-s)}" fill="none" stroke="{ink}" stroke-width="0.8"/>"""
  let tx = x + s * 0.15
  let ty = y - s
  for a in [-150.0, -110.0, -70.0, -30.0, 10.0]:
    let r = degToRad(a)
    result.add &"""<path d="M{f1(tx)},{f1(ty)} q{f1(cos(r) * s * 0.3)},{f1(sin(r) * s * 0.3 - 2)} {f1(cos(r) * s * 0.6)},{f1(sin(r) * s * 0.6 + 2)}" fill="none" stroke="{ink}" stroke-width="0.7"/>"""

func ship(x, y, angle: float): string =
  ## a small three-masted ship, heading `angle` degrees (0 = east)
  let flip = if angle > 90 or angle < -90: -1.0 else: 1.0
  result = &"""<g transform="translate({f1(x)},{f1(y)}) scale({flip},1)" stroke="{ink}" stroke-width="0.7" fill="{paper}">"""
  result.add """<path d="M-14,0 L14,0 L10,5 L-11,5 Z"/>"""
  for (mx, h) in [(-7.0, 16.0), (0.0, 20.0), (7.0, 15.0)]:
    result.add &"""<line x1="{f1(mx)}" y1="0" x2="{f1(mx)}" y2="{f1(-h)}"/>"""
    result.add &"""<path d="M{f1(mx - 4)},{f1(-h + 3)} Q{f1(mx + 1)},{f1(-h + 6)} {f1(mx - 4)},{f1(-h * 0.45)} L{f1(mx + 4)},{f1(-h * 0.45)} Q{f1(mx + 8)},{f1(-h + 6)} {f1(mx + 4)},{f1(-h + 3)} Z"/>"""
  result.add """<path d="M14,0 L21,-6" fill="none"/></g>"""

func roseSvg(c: Pt, r: float): string =
  ## a sixteen-point rose, points half shaded, a fleur-de-lis at north
  result = &"""<g transform="translate({f1(c.x)},{f1(c.y)})" stroke="{ink}" stroke-width="0.7">"""
  result.add &"""<circle r="{f1(r * 1.08)}" fill="none"/><circle r="{f1(r * 1.0)}" fill="none" stroke-width="0.4"/>"""
  for k in 0 ..< 72:
    let a = degToRad(k.float * 5)
    result.add &"""<line x1="{f1(r * cos(a))}" y1="{f1(r * sin(a))}" x2="{f1(r * 1.08 * cos(a))}" y2="{f1(r * 1.08 * sin(a))}" stroke-width="0.4"/>"""
  for level in [2, 1, 0]:
    let count = [4, 4, 8][level]
    let len = [1.0, 0.72, 0.5][level] * r
    let wid = [0.14, 0.11, 0.08][level] * r
    let start = [0.0, 45.0, 22.5][level]
    for k in 0 ..< count:
      let step = if level == 0: 45.0 else: 90.0
      let a = degToRad(start + k.float * step - 90)
      let tip = (len * cos(a), len * sin(a))
      let l = (wid * cos(a - PI / 2), wid * sin(a - PI / 2))
      let rr = (wid * cos(a + PI / 2), wid * sin(a + PI / 2))
      result.add &"""<path d="M0,0 L{f1(l[0])},{f1(l[1])} L{f1(tip[0])},{f1(tip[1])} Z" fill="{paper}"/>"""
      result.add &"""<path d="M0,0 L{f1(rr[0])},{f1(rr[1])} L{f1(tip[0])},{f1(tip[1])} Z" fill="{ink}"/>"""
  # fleur-de-lis
  let y0 = -r * 1.12
  result.add &"""<g transform="translate(0,{f1(y0)})" fill="{red}" stroke="{red}" stroke-width="0.5"><path d="M0,-12 C3,-8 3,-4 0,0 C-3,-4 -3,-8 0,-12 Z"/><path d="M0,-2 C4,-8 9,-6 7,-1 C6,1 3,0 2,-1 Z"/><path d="M0,-2 C-4,-8 -9,-6 -7,-1 C-6,1 -3,0 -2,-1 Z"/><rect x="-4" y="0" width="8" height="1.6"/></g>"""
  result.add "</g>"

proc engravedMap*(v: Voyage, names: openArray[string], current: int, id = ""): string =
  let id = if id.len > 0: id else: $current
  let f = v.field
  let wob = &"url(#wobble-{id})"
  result = &"""<svg class="voyage-map engraved-map" viewBox="0 0 {v.w.int} {v.h.int}" xmlns="http://www.w3.org/2000/svg">
<defs>
<filter id="wobble-{id}" x="-5%" y="-5%" width="110%" height="110%"><feTurbulence type="fractalNoise" baseFrequency="0.035" numOctaves="2" seed="3"/><feDisplacementMap in="SourceGraphic" scale="3.5"/></filter>
<clipPath id="eng-clip-{id}"><rect x="14" y="14" width="{v.w.int - 28}" height="{v.h.int - 28}"/></clipPath>
<mask id="eng-sea-{id}"><rect width="{v.w.int}" height="{v.h.int}" fill="white"/>"""
  for poly in v.lands:
    result.add &"""<path d="{svgPath(poly)}" fill="black" stroke="black" stroke-width="6"/>"""
  result.add "</mask>\n</defs>\n"
  result.add &"""<g clip-path="url(#eng-clip-{id})">"""
  # rhumb lines from the rose, under everything
  let rose: Pt = (v.compassAt.x - 30, v.compassAt.y + 30)
  result.add &"""<g stroke="{ink}" stroke-width="0.35" opacity="0.45" mask="url(#eng-sea-{id})">"""
  for k in 0 ..< 32:
    let a = degToRad(k.float * 11.25)
    result.add &"""<line x1="{f1(rose.x)}" y1="{f1(rose.y)}" x2="{f1(rose.x + 1400 * cos(a))}" y2="{f1(rose.y + 1400 * sin(a))}"/>"""
  result.add "</g>"
  # water-lining: many thin lines following the coast, closer and darker near the shore
  result.add &"""<g fill="none" stroke="{ink}" filter="{wob}">"""
  var level = 3.0
  var k = 0
  while level < 46:
    let op = 0.75 * exp(-level / 20)
    let wid = 0.9 - k.float * 0.04
    for line in f.contours(level):
      result.add &"""<path d="{svgPath(line.smooth, closed = false)}" stroke-width="{f1(max(wid, 0.3))}" opacity="{formatFloat(op, ffDecimal, 2)}"/>"""
    level += 3.0 + k.float * 0.35
    inc k
  result.add "</g>"
  # land: paper, a wobbly coastline drawn twice like an inked line, stipple along the shore
  result.add &"""<g filter="{wob}">"""
  for poly in v.lands:
    result.add &"""<path d="{svgPath(poly)}" fill="{paper}" stroke="{ink}" stroke-width="1.6"/>"""
  result.add "</g>"
  var r = initRng(11)
  result.add &"""<g fill="{ink}">"""
  for n in 0 ..< 5000:
    let p: Pt = (r.next * v.w, r.next * v.h)
    let d = f.at(p)
    if d < 0 and d > -10 and r.next < (1 + d / 10) * 0.9:
      result.add &"""<circle cx="{f1(p.x)}" cy="{f1(p.y)}" r="0.55"/>"""
  result.add "</g>"
  # hills, palms and volcanoes from the islands' features, hills on the mainland too
  for i, isl in v.islands:
    for ft in isl.features:
      let p: Pt = (isl.center.x + ft.at.x, isl.center.y + ft.at.y)
      case ft.kind
      of Hills:
        result.add hill(p.x - 10, p.y + 6, 12, 10) & hill(p.x + 6, p.y + 2, 14, 14) & hill(p.x - 2, p.y + 12, 9, 7)
      of Palms: result.add palm(p.x, p.y + 6, 14) & palm(p.x + 8, p.y + 9, 11)
      of Volcano: result.add volcano(p.x, p.y + 8, 18)
  for (x, y) in [(40.0, 90.0), (60.0, 160.0), (50.0, 470.0)]:
    result.add hill(x, y, 13, 11) & hill(x + 14, y + 5, 10, 8)
  # the track: dotted, red where sailed, with the ship
  result.add &"""<g mask="url(#eng-sea-{id})" fill="none">"""
  result.add &"""<path d="{svgPath(v.routePolyline, closed = false)}" stroke="{ink}" stroke-width="1" stroke-dasharray="1 4" stroke-linecap="round" opacity="0.8"/>"""
  let done = v.routeDone(current)
  if done.len > 0:
    result.add &"""<path d="{svgPath(done, closed = false)}" stroke="{red}" stroke-width="1.6" stroke-dasharray="6 3"/>"""
  result.add "</g>"
  if current in 1 .. 7 and done.len > 8:
    var k = done.high
    while k > 0 and f.at(done[k]) < 16: dec k
    let a = done[max(0, k - 1)]
    let b = done[k]
    result.add ship(b.x, b.y - 4, radToDeg(arctan2(b.y - a.y, b.x - a.x)))
  # names
  for i, isl in v.islands:
    let n = i + 1
    let lp = isl.labelPos(19)
    let state = islandState(n, current)
    result.add &"""<text class="ename{state}" x="{f1(lp.x)}" y="{f1(lp.y)}" text-anchor="middle">{names[i]}</text>"""
  result.add &"""<path id="sea-arc-{id}" d="M300,515 Q560,470 820,512" fill="none"/>"""
  result.add &"""<text class="esea"><textPath href="#sea-arc-{id}" startOffset="50%" text-anchor="middle">{v.seaName.toUpperAscii}</textPath></text>"""
  result.add &"""<text class="eland" x="48" y="300" transform="rotate(-90 48 300)" text-anchor="middle">THE MAINLAND</text>"""
  result.add roseSvg(rose, 34)
  # cartouche
  result.add &"""<g transform="translate(470,48)"><rect x="-95" y="-26" width="190" height="48" fill="{paper}" stroke="{ink}" stroke-width="1"/><rect x="-91" y="-22" width="182" height="40" fill="none" stroke="{ink}" stroke-width="0.5"/>"""
  result.add &"""<path d="M-95,-2 q-10,-10 -4,-20 M95,-2 q10,-10 4,-20 M-95,0 q-10,10 -4,20 M95,0 q10,10 4,20" fill="none" stroke="{ink}" stroke-width="0.8"/>"""
  result.add """<text class="ecart-small" y="-8" text-anchor="middle">A NEW CHART OF THE</text><text class="ecart" y="12" text-anchor="middle">Seven Islands</text></g>"""
  result.add "</g>"
  # a double neat line with a degree scale
  result.add &"""<g fill="none" stroke="{ink}"><rect x="6" y="6" width="{v.w.int - 12}" height="{v.h.int - 12}" stroke-width="1.6"/><rect x="14" y="14" width="{v.w.int - 28}" height="{v.h.int - 28}" stroke-width="0.6"/>"""
  var x = 14.0
  var j = 0
  while x < v.w - 14:
    let h = if j mod 5 == 0: 8.0 else: 4.0
    result.add &"""<line x1="{f1(x)}" y1="6" x2="{f1(x)}" y2="{f1(6 + h)}" stroke-width="0.5"/><line x1="{f1(x)}" y1="{f1(v.h - 6)}" x2="{f1(x)}" y2="{f1(v.h - 6 - h)}" stroke-width="0.5"/>"""
    x += 18
    inc j
  result.add "</g>\n</svg>"

const engravedMapCss* = """
.reveal .engraved-map { outline: none; }
.engraved-map .ename { font-family: "IM Fell English", serif; font-style: italic; font-size: 17px; fill: #2a1d12; paint-order: stroke; stroke: #efe5cf; stroke-width: 4px; }
.engraved-map .ename.current { fill: #8e1b17; font-size: 20px; }
.engraved-map .esea, .engraved-map .eland { font-family: "IM Fell English SC", serif; font-size: 16px; letter-spacing: 0.45em; fill: #2a1d12; }
.engraved-map .ecart { font-family: "IM Fell English", serif; font-style: italic; font-size: 21px; fill: #2a1d12; }
.engraved-map .ecart-small { font-family: "IM Fell English SC", serif; font-size: 10px; letter-spacing: 0.25em; fill: #2a1d12; }
"""
  ## css for the labels of this map (the fonts are in docs/assets/fonts/fonts.css)
