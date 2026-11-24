import std / [strutils, math]
import nimib
import ../my
import ../maps / [base, pixel, chart, engraved]
import devlog

# A talk log post: the map of the voyage, one geometry and one map per theme.
#   nim r devlog/drawing_the_map.nim   (screenshots in docs/images/maps come from scripts/build-themes.sh builds)

nbInit(thisFileRel = "devlog/drawing_the_map.nim")
const ownSource = staticRead("drawing_the_map.nim")
nb.useDevlogPost("drawing-the-map", ownSource)
nbRawHtml "<link rel=\"stylesheet\" href=\"../assets/fonts/fonts.css\">"
nbRawHtml "<style>\n" & pixelMapCss & chartMapCss & engravedMapCss & """
.map-box svg { width: 100%; height: auto; display: block; }
.map-box.engraved { background: #efe5cf; }
.bare .sea { fill: #f0f6fa; } .bare .grid, .bare .waves, .bare .x-mark, .bare .light, .bare .island-hatch, .bare .land-hatch { display: none; }
.bare .island, .bare .land { fill: #eee; stroke: #333; } .bare .contour { fill: none; stroke: #9ab; }
.bare .route, .bare .route-done { fill: none; stroke: #c33; stroke-dasharray: 6 4; } .bare .route-done { stroke-dasharray: none; stroke-width: 3; }
.bare .compass-point { fill: #fff; stroke: #333; } .bare .compass-point.long { fill: #333; } .bare .compass-ring { fill: none; stroke: #333; }
.bare text { font-family: sans-serif; font-size: 15px; } .bare .soundings text { font-size: 11px; fill: #69c; }
.shots { display: grid; grid-template-columns: 1fr 1fr; gap: 0.6em; }
.shots img { width: 100%; border: 1px solid #ddd; }
""" & "</style>"

proc show(svg: string, cls = "") =
  nbRawHtml "<div class=\"map-box " & cls & "\">" & svg & "</div>"

nbText """
In the [previous post](2026-11-07-dressing-the-voyage.html)
every theme styled the same svg map with css.
That keeps the map in one place, but it only goes so far:
css can change colors and hide layers,
it cannot turn a map into pixel art or into a real chart.

So the map now has two levels.
At the bottom there is **one geometry**, plain data:
the islands, the mainland, the route.
On top of it, **one map per theme**, drawn by code from that geometry.
When the geometry changes (a new shape for an island,
a volcano, another route), every map follows.

## The geometry

`maps/geometry.nim` holds the voyage of the talk:
"""
nbCode:
  let v = defaultVoyage()
  echo v.islands.len, " islands on a ", v.w, " x ", v.h, " map"
  echo "island 3 at ", v.islands[2].center, ", outline of ", v.islands[2].polygon.len, " points"
  echo "the route has ", v.route.len, " stops"

nbText """
An island is a center, a size and a seed:
its outline is a wobbly circle
(a few sine waves on the radius, smoothed with Catmull-Rom splines),
unless it has an `outline` of its own.
It can also carry features (hills, palms, a volcano)
that each map draws in its own way.

From the geometry comes a **signed distance field**:
for every point of the map, the distance to the nearest coast,
negative on land and positive at sea.
It is the workhorse of all the maps:
depth contours are its level lines (marching squares),
depths and soundings come from it,
and in the pixel art every pixel is colored by it.
"""
nbCode:
  let f = v.field
  for p in [(495.0, 185.0), (495.0, 250.0), (560.0, 300.0), (480.0, 60.0)]:
    echo p, ": ", f.at(p).round(1), " from the coast, ", f.depth(p).round(1), " m deep"

nbText """
The base map draws the geometry as one plain svg, every part with a class,
so that css alone can style it (the default deck and the first themes used it):
"""
show(baseMap(v, islands, 3, id = "post-bare"), "bare")

nbText """
## Pixel art, for the pirate adventure

The look of a 90s point-and-click adventure, drawn from the same geometry.
The map is 240 x 135 pixels, one pixel every 4 units of the geometry.
Each pixel takes its color from the distance field:
foam on the shore, shoals, shallow and deep water,
blended with ordered (Bayer) dithering as in old games;
on land a beach, then grass, and a dark outline
wherever a land pixel touches the sea.
Palms, hills, the red X, flags on the islands already visited,
the compass and our ship are small ascii sprites in the code.
The route is dashed ahead and solid red where sailed, and stops at the shore.
The image is a png inside the svg, scaled up with `image-rendering: pixelated`,
and the labels stay svg text in Pixelify Sans, sharp at any size.
"""
show(pixelMap(v, islands, 3))

nbText """
## A real nautical chart

A chart follows conventions, and the map follows them too:
land in buff, shallow water in blue, darker where it is shallower,
a green band for the shore that dries at low tide,
depth contours with their depth written on them,
soundings in metres with the decimal as a subscript,
rocks awash as little crosses with dots,
height contours and spot heights on land,
upright capitals for names on land and spaced italics for the sea,
a magenta compass rose with its magnetic ring,
a magenta course line with the bearing of every leg sailed,
a light with its characteristic on the island of the section,
and a graduated border.
Contours, colors and soundings all come from the distance field.
"""
show(chartMap(v, islands, 3, id = "post-chart"))

nbText """
## A hand-drawn chart of the 19th century

The engraved map of an old book of voyages.
The sea is water-lined: many thin lines that follow the coast,
closer and darker near the shore (again level lines of the distance field).
Coasts and lines wobble a little, as drawn by hand
(an svg turbulence filter displaces them).
The land is stippled along the shore and carries hills drawn in profile,
rhumb lines radiate from a sixteen-point rose with a fleur-de-lis,
a small ship sails the dotted track,
the title sits in a cartouche
and the sea's name follows a curve.
"""
show(engravedMap(v, islands, 3, id = "post-engraved"), "engraved")

nbText """
## Change the geometry, every map follows

Here the first island gets a shape of its own, a crescent bay,
and a volcano in place of its hills.
Nothing else changes: the three maps are drawn again from the new geometry.
"""
nbCode:
  var w = defaultVoyage()
  w.islands[0].outline = @[(-50.0, -20.0), (-20.0, -42.0), (25.0, -40.0), (55.0, -12.0),
    (50.0, 25.0), (20.0, 38.0), (-5.0, 15.0), (-25.0, 30.0), (-55.0, 15.0)]
  w.islands[0].features = @[Feature(kind: Volcano, at: (5.0, -5.0))]
show(pixelMap(w, islands, 1))
show(chartMap(w, islands, 1, id = "post-chart-w"))
show(engravedMap(w, islands, 1, id = "post-engraved-w"), "engraved")

nbText """
## In the slides

The map slide of Island 3 in each theme
(build the whole deck in a theme with `scripts/build-themes.sh`:
[pirate](../index_pirate.html), [book](../index_book.html), [chart](../index_chart.html)):
"""
var shots = "<div class=\"shots\">"
for t in ["pirate", "book", "chart"]:
  for s in ["5.0", "0"]:
    shots.add "<a href=\"../images/maps/" & t & "-" & s & ".jpg\"><img src=\"../images/maps/" & t & "-" & s & ".jpg\" alt=\"" & t & " theme\"></a>"
shots.add "</div>"
nbRawHtml shots

nbText """
## Next

The geometry is a first sketch:
the next step is to draw the islands we actually want,
with the shapes and features that suit each one,
and then pick the theme that carries them to Paris.
"""

nb.devlogFooter("drawing-the-map")
nbSave
