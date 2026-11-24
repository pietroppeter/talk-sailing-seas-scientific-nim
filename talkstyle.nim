## The style of the nimib pages (deep dives and talk log): colours as tokens, and the CSS of
## the blocks in blocks.nim. Pages hold no CSS and no colour: what they need goes here.
## The slides have their own style, in my.nim (and themes.nim for the explored themes).
import std / json
import nimib
import maps / [pixel, chart, engraved]

const
  tokens = """
:root {
  --accent: #02A4BD;      /* AgileLab light blue, as on the slides */
  --muted: #6b7280;       /* small print: captions, dates */
  --soft-ink: #374151;    /* a lede */
  --line: #dddddd;        /* borders of pictures and frames */
  --swatch-line: #cccccc;
  --engraved-paper: #efe5cf; /* the paper of the engraved map */
}
"""
  pageCss = """
pre { overflow-x: auto; }
img { max-width: 100%; }
table { font-size: 0.9em; }
/* tabelline tables stripe (or not) on their own, not with the page's style */
.tabella tbody tr:nth-child(even) { background-color: transparent; }
.note { border-left: 4px solid var(--accent); padding-left: 1em; }
.code-caption { font-size: 0.8em; color: var(--muted); margin-top: -0.5em; }
figcaption { font-size: 0.85em; color: var(--muted); }
.frame { width: 100%; aspect-ratio: 16 / 9; border: 1px solid var(--line); border-radius: 6px; }
/* the easter egg of the Thank You deep dive: a heading that does not look like a link */
a[href$="emilia.html"], a[href$="emilia.html"]:hover { color: inherit; text-decoration: none; }
.gallery { display: grid; grid-template-columns: 1fr 1fr; gap: 0.6em; }
.gallery img { width: 100%; border: 1px solid var(--line); }
.swatches { display: flex; flex-wrap: wrap; gap: 0.4em; margin: 0.5em 0 1em; }
.swatch { font-size: 0.75em; padding: 0.4em 0.6em; border-radius: 4px; border: 1px solid var(--swatch-line); }
/* an app compiled to JavaScript (nbApp): sliders in a sidebar, then a canvas */
.app { display: flex; flex-wrap: wrap; gap: 1em; align-items: flex-start; border: 1px solid var(--line); border-radius: 6px; padding: 0.8em; }
.app .sidebar { display: flex; flex-direction: column; gap: 0.6em; flex: 0 0 13em; }
.app label { display: grid; grid-template-columns: 1fr auto; font-size: 0.9em; }
.app input { grid-column: 1 / 3; width: 100%; margin: 0.2em 0 0; }
.app canvas { flex: 1 1 18em; min-width: 0; max-width: 100%; height: auto; }
.drawing svg { width: 100%; height: auto; display: block; }
.drawing.engraved { background: var(--engraved-paper); }
.eyebrow { font-size: 0.8em; letter-spacing: 0.08em; text-transform: uppercase; color: var(--muted); }
.eyebrow a { color: inherit; }
.lede { font-size: 1.15em; color: var(--soft-ink); }
.pager { display: flex; justify-content: space-between; gap: 1em; border-top: 1px solid var(--line); margin-top: 3em; padding-top: 1em; font-size: 0.9em; }
.page-list { list-style: none; padding: 0; }
.page-list li { margin-bottom: 1.4em; }
.page-list .eyebrow { display: block; }
.page-list li > a { font-size: 1.25em; font-weight: 600; }
.page-list p { margin: 0.2em 0 0; }
/* the review mode (review.nim): water.css gives every button a margin, which the bar has no room for */
.rv-bar button, .rv-sheet button, .rv-panel button, .rv-toggle { margin: 0; }
"""
  # the voyage map without a theme (talk log): `layers` draws every layer plainly, in one colour
  # each; `bare` draws only the base map (islands, route, compass)
  bareMapCss = """
.drawing.layers .voyage-map { width: 100%; height: auto; background: #fff; }
.drawing.layers .voyage-map * { display: inline !important; }
.drawing.layers .sea { fill: #f0f6fa; }
.drawing.layers .grid { fill: none; }
.drawing.layers .island, .drawing.layers .land { fill: #eee; stroke: #333; }
.drawing.layers .island-hatch, .drawing.layers .land-hatch { opacity: 0.3; }
.drawing.layers .hatch-line, .drawing.layers .grid-line { stroke: #999; }
.drawing.layers .contour { fill: none; stroke: #9ab; }
.drawing.layers .route, .drawing.layers .route-done { fill: none; stroke: #c33; stroke-dasharray: 6 4; }
.drawing.layers .route-done { stroke-dasharray: none; stroke-width: 3; }
.drawing.layers .waves path { fill: none; stroke: #69c; }
.drawing.layers .x-mark { stroke: #c33; stroke-width: 4; }
.drawing.layers .light { fill: #c0c; }
.drawing.layers .compass-point { fill: #fff; stroke: #333; }
.drawing.layers .compass-point.long { fill: #333; }
.drawing.layers .compass-ring { fill: none; stroke: #333; }
.drawing.layers text { font-family: sans-serif; font-size: 15px; }
.drawing.layers .soundings text { font-size: 11px; fill: #69c; }
.drawing.bare .sea { fill: #f0f6fa; }
.drawing.bare .grid, .drawing.bare .waves, .drawing.bare .x-mark, .drawing.bare .light, .drawing.bare .island-hatch, .drawing.bare .land-hatch { display: none; }
.drawing.bare .island, .drawing.bare .land { fill: #eee; stroke: #333; }
.drawing.bare .contour { fill: none; stroke: #9ab; }
.drawing.bare .route, .drawing.bare .route-done { fill: none; stroke: #c33; stroke-dasharray: 6 4; }
.drawing.bare .route-done { stroke-dasharray: none; stroke-width: 3; }
.drawing.bare .compass-point { fill: #fff; stroke: #333; }
.drawing.bare .compass-point.long { fill: #333; }
.drawing.bare .compass-ring { fill: none; stroke: #333; }
.drawing.bare text { font-family: sans-serif; font-size: 15px; }
.drawing.bare .soundings text { font-size: 11px; fill: #69c; }
"""

proc addCss(nb: var Nb, css: string) =
  nb.doc.context["nb_style"] = %(nb.doc.context{"nb_style"}.getStr &
    "\n<style>\n" & css & "</style>")

proc useTalkStyle*(nb: var Nb) =
  ## the CSS of every nimib page: tokens, the blocks of blocks.nim, the plain voyage map
  nb.addCss(tokens & pageCss & bareMapCss)

proc useMapStyle*(nb: var Nb) =
  ## for a page that shows the voyage maps in the themes' looks (maps/): their CSS and fonts
  nb.addCss(pixelMapCss & chartMapCss & engravedMapCss)
  nb.doc.context["stylesheet"] = %(nb.doc.context{"stylesheet"}.getStr &
    "\n<link rel=\"stylesheet\" href=\"" & nb.doc.relToRoot("assets/fonts/fonts.css") & "\">")
