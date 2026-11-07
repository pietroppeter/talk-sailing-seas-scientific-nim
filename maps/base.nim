## The base layer: the voyage map as one plain svg, every part with a class,
## so a theme's css alone can style it. The richer maps of the themes start from the
## same geometry (maps/geometry.nim) and add their own layers.
import std / [math, strformat, strutils]
import geometry
export geometry

func compassSvg*(c: Pt, r: float): string =
  ## an eight-pointed compass rose
  result = &"""<g class="compass" transform="translate({f1(c.x)},{f1(c.y)})">"""
  result.add &"""<circle r="{f1(r)}" class="compass-ring"/><circle r="{f1(r * 0.82)}" class="compass-ring"/>"""
  for k in 0 ..< 8:
    let a = k.float * PI / 4 - PI / 2
    let long = k mod 2 == 0
    let l = if long: r * 1.15 else: r * 0.6
    let w = if long: r * 0.16 else: r * 0.12
    let tip = (l * cos(a), l * sin(a))
    let left = (w * cos(a - PI / 2), w * sin(a - PI / 2))
    let right = (w * cos(a + PI / 2), w * sin(a + PI / 2))
    result.add &"""<path class="compass-point{(if long: " long" else: "")}" d="M{f1(left[0])},{f1(left[1])} L{f1(tip[0])},{f1(tip[1])} L{f1(right[0])},{f1(right[1])} Z"/>"""
  result.add &"""<text class="compass-n" y="{f1(-r * 1.3)}" text-anchor="middle">N</text></g>"""

func islandState*(n, current: int): string =
  ## css class of island `n` when the voyage is at `current` (0 the whole map, 8 back on land)
  if n == current: " current" elif current == 8 or n < current: " visited" else: ""

func routeDone*(v: Voyage, current: int): seq[Pt] =
  ## the part of the route already sailed
  let upTo = if current == 8: v.route.high elif current >= 1: current else: 0
  if upTo > 0: v.routePolyline(upTo) else: @[]

func labelPos*(isl: Island, fontSize = 17.0): Pt =
  let off = isl.r * 0.8
  if isl.labelBelow: (isl.center.x, isl.center.y + off + fontSize + 10)
  else: (isl.center.x, isl.center.y - off - 14)

proc baseMap*(v: Voyage, names: openArray[string], current: int, id = ""): string =
  ## svg map of the voyage; `current` (1..7) is the island of the section,
  ## 0 for the whole map, 8 for back on land.
  ## Pattern ids are unique per map (`id`, default the slide number): reveal.js hides the other
  ## slides, and a fill pointing to a pattern in a hidden slide is not painted.
  let id = if id.len > 0: id else: $current
  let f = v.field
  result = &"""<svg class="voyage-map" viewBox="0 0 {v.w.int} {v.h.int}" xmlns="http://www.w3.org/2000/svg">
<defs>
<pattern id="hatch-{id}" width="6" height="6" patternUnits="userSpaceOnUse" patternTransform="rotate(35)"><line x1="0" y1="0" x2="0" y2="6" class="hatch-line"/></pattern>
<pattern id="grid-{id}" width="120" height="90" patternUnits="userSpaceOnUse"><path d="M120,0 L0,0 0,90" class="grid-line"/></pattern>
</defs>
<rect class="sea" width="{v.w.int}" height="{v.h.int}"/>
<rect class="grid" width="{v.w.int}" height="{v.h.int}" fill="url(#grid-{id})"/>
<g class="waves">"""
  for (x, y) in [(170.0, 330.0), (420.0, 110.0), (560.0, 260.0), (760.0, 330.0), (930.0, 150.0), (470.0, 470.0), (690.0, 60.0)]:
    result.add &"""<path d="M{f1(x)},{f1(y)} q8,-7 16,0 q8,7 16,0"/>"""
  result.add "</g>\n<g class=\"soundings\">"
  for (x, y) in [(180.0, 60.0), (420.0, 70.0), (560.0, 290.0), (470.0, 300.0), (760.0, 300.0), (560.0, 60.0),
                 (920.0, 360.0), (240.0, 280.0), (210.0, 420.0), (480.0, 450.0), (700.0, 470.0), (380.0, 250.0)]:
    result.add &"""<text x="{f1(x)}" y="{f1(y)}">{f.depth((x, y)).round.int}</text>"""
  result.add "</g>\n<g class=\"contours\">"
  for k in 1 .. 3:
    for line in f.contours(9.0 * k.float):
      result.add &"""<path class="contour c{k}" d="{svgPath(line.smooth)}"/>"""
  let ml = svgPath(v.mainlandPolygon)
  result.add &"""</g>
<path class="land mainland" d="{ml}"/>
<path class="land-hatch mainland" d="{ml}" fill="url(#hatch-{id})"/>
"""
  result.add &"""<path class="route" d="{svgPath(v.routePolyline, closed = false)}"/>"""
  let done = v.routeDone(current)
  if done.len > 0:
    result.add &"""<path class="route-done" d="{svgPath(done, closed = false)}"/>"""
  for i, isl in v.islands:
    let n = i + 1
    let state = islandState(n, current)
    let d = svgPath(isl.polygon)
    result.add &"""<path class="island{state}" d="{d}"/><path class="island-hatch{state}" d="{d}" fill="url(#hatch-{id})"/>"""
    let lp = isl.labelPos
    result.add &"""<text class="label{state}" x="{f1(lp.x)}" y="{f1(lp.y)}" text-anchor="middle"><tspan class="num">{n}</tspan> {names[i]}</text>"""
    if n == current:
      let c = isl.center
      result.add &"""<g class="x-mark" transform="translate({f1(c.x)},{f1(c.y)})"><path d="M-13,-13 L13,13 M13,-13 L-13,13"/></g>"""
      result.add &"""<g class="light" transform="translate({f1(c.x)},{f1(c.y)})"><path d="M0,0 C-9,-14 -6,-30 0,-38 C6,-30 9,-14 0,0 Z"/><circle r="4"/></g>"""
  result.add compassSvg(v.compassAt, 30.0)
  result.add &"""<text class="land-label" x="40" y="300" transform="rotate(-90 40 300)" text-anchor="middle">the mainland</text>"""
  result.add "\n</svg>"
