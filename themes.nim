## Slide themes explored in the talk log (devlog/dressing_the_voyage.nim); the deck wears the chart one.
##
## The deck wears the nautical chart theme (chart); the others explored are built on the side:
## `nim r -d:slideTheme=pirate deck.nim` (pirate, book, or agile, the plain AgileLab theme of my.nim).
## Each theme is css on top of the AgileLab theme, openly licensed fonts vendored in
## docs/assets/fonts (scripts/vendor-fonts.sh) and a map of the voyage drawn by code
## from one shared geometry (maps/), in the style of the theme.
import std / [strutils, strformat]
import maps / [base, pixel, chart, engraved, isole]
export base

const deckTheme* = "chart"
  ## the theme of the deck (Pietro, 2026-11-24): the nautical chart

const slideTheme* {.strdefine.} = deckTheme
  ## chart (the deck's), or one of the others explored: pirate, book, agile (the plain AgileLab theme)

const themed* = slideTheme != "agile"
  ## the theme's css, fonts and map apply (all but the plain AgileLab theme)

const sideTheme* = slideTheme != deckTheme
  ## a theme built on the side, as docs/slides_<theme>.html

# --- the voyage map -------------------------------------------------------------------
# One geometry (maps/geometry.nim), one map per theme drawn from it:
# the base svg styled by css (agile and the talk log), pixel art (pirate),
# a nautical chart (chart) and a hand-drawn 19th century chart (book).

proc voyageMap*(islands: openArray[string], current: int, id = ""): string =
  ## the map of the voyage in the theme of the build; `current` (1..7) is the island
  ## of the section, 0 for the whole map, 8 for back on land
  let v = islandsVoyage() # seven real islands of the Mediterranean (maps/isole.nim)
  case slideTheme
  of "pirate": pixelMap(v, islands, current)
  of "chart": chartMap(v, islands, current, id, html = true) # the words in html over the drawing
  of "book": engravedMap(v, islands, current, id)
  else: baseMap(v, islands, current, id)

# --- css --------------------------------------------------------------------------------

func noise(baseFreq: float, opacity: float): string =
  ## an svg turbulence texture as a css url, for paper grain without image files
  "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='400' height='400'>" &
    &"<filter id='n'><feTurbulence type='fractalNoise' baseFrequency='{baseFreq}' numOctaves='4' stitchTiles='stitch'/>" &
    "<feColorMatrix values='0 0 0 0 0.35  0 0 0 0 0.22  0 0 0 0 0.08  0 0 0 " & $opacity & " 0'/></filter>" &
    "<rect width='400' height='400' filter='url(%23n)'/></svg>\")"

const commonCss = """
.reveal .slides section .map-slide h2 { margin-bottom: 0.2em; }
.reveal .voyage-map { width: auto; height: 470px; margin: 0 auto; display: block; }
.reveal .title-art { position: absolute; inset: -40px -80px; z-index: -1; opacity: 0.35; pointer-events: none; }
.reveal .title-art .voyage-map { width: 100%; height: 100%; }
.reveal .title-art .label, .reveal .title-art .soundings { display: none; }
.voyage-map .label { font-size: 17px; }
.voyage-map .num { font-weight: 700; }
.voyage-map .compass-n { font-size: 14px; font-weight: 700; }
.voyage-map .soundings, .voyage-map .x-mark, .voyage-map .light, .voyage-map .grid,
.voyage-map .island-hatch, .voyage-map .land-hatch, .voyage-map .waves { display: none; }
.voyage-map .route, .voyage-map .route-done { fill: none; }
.reveal h1, .reveal h2, .reveal h3 { text-transform: none; }
"""

func pirateCss(): string =
  ## a point-and-click pirate adventure: treasure map parchment, a chunky pirate display font,
  ## tropical sea colors and colored "dialogue" lines for quotes
  let ink = "#3b2412"
  let red = "#b3261e"
  let teal = "#11747a"
  result = &"""
.reveal-viewport {{
  background-color: #ecd9a8;
  background-image: {noise(0.9, 0.22)},
    radial-gradient(ellipse at center, rgba(255,240,200,0) 55%, rgba(120,70,20,0.45) 100%);
}}
.reveal {{ font-family: "Alegreya", serif; color: {ink}; font-size: 40px; }}
.reveal h1, .reveal h2, .reveal h3 {{
  font-family: "Germania One", serif; color: #5a1a0c; letter-spacing: 0.02em;
  text-shadow: 2px 2px 0 rgba(255,236,190,0.8), 3px 3px 0 rgba(90,26,12,0.25);
}}
.reveal h2 {{ font-size: 2.1em; }}
.reveal strong {{ color: {red}; }}
.reveal em {{ color: {teal}; }}
.reveal a {{ color: {teal}; }}
.reveal ul li::marker {{ content: "✗  "; color: {red}; }}
.reveal pre {{ box-shadow: 4px 5px 0 rgba(90,50,20,0.35); border: 2px solid #7a4a21; border-radius: 6px; background: #f8edd0; }}
.reveal pre code, .reveal code {{ font-family: "JetBrains Mono", monospace; }}
.reveal pre code.hljs, .reveal pre samp.hljs {{ background: #f8edd0; }}
.reveal pre samp.hljs {{ border-left-color: {teal}; }}
.reveal table:not(.hljs-ln) {{ border-collapse: collapse; }}
.reveal table:not(.hljs-ln) th {{ font-family: "Germania One", serif; font-size: 1.15em; color: #5a1a0c; border-bottom: 3px double #7a4a21 !important; }}
.reveal table:not(.hljs-ln) td {{ border-bottom: 1px dashed #9a6a3a !important; }}
.reveal .rocks-quotes blockquote {{
  font-family: "Pixelify Sans", sans-serif; font-style: normal; font-size: 0.9em; line-height: 1.35;
  background: rgba(28,18,40,0.88); color: #f2e6c9; border: none; box-shadow: 4px 4px 0 rgba(0,0,0,0.3);
  border-radius: 4px; padding: 0.6em 0.8em;
}}
.reveal .rocks-quotes figure:nth-child(1) blockquote {{ color: #8fe3e8; }}
.reveal .rocks-quotes figure:nth-child(2) blockquote {{ color: #f5d36b; }}
.reveal .rocks-quotes blockquote strong {{ color: #ffffff; text-decoration: underline; }}
.reveal .rocks-quotes blockquote em {{ color: #ffffff; text-decoration: underline; }}
.reveal .rocks-quotes figcaption {{ font-family: "Germania One", serif; font-size: 1.1em; color: #5a1a0c; }}
.reveal .title-slide h2 {{ font-size: 1.85em; line-height: 1.05; }}
.reveal .title-art {{ opacity: 0.35; }}
.voyage-map .sea {{ rx: 18px; }}
.reveal .voyage-map {{ filter: drop-shadow(3px 4px 0 rgba(90,50,20,0.35)); }}
.voyage-map .sea {{ fill: #8fc9c0; fill-opacity: 0.55; }}
.voyage-map .waves {{ display: inline; fill: none; stroke: #2f7f86; stroke-width: 2; stroke-linecap: round; }}
.voyage-map .contour {{ fill: #cfe8d8; fill-opacity: 0.5; stroke: none; }}
.voyage-map .contour.c2, .voyage-map .contour.c3 {{ display: none; }}
.voyage-map .land {{ fill: #d8b878; stroke: #6b3f16; stroke-width: 3; }}
.voyage-map .island {{ fill: #e2c487; stroke: #6b3f16; stroke-width: 3; }}
.voyage-map .island.visited {{ fill: #9cbf6a; }}
.voyage-map .island.current {{ fill: #7fb04e; stroke: {red}; stroke-width: 4; }}
.voyage-map .route {{ stroke: #7a4a21; stroke-width: 3; stroke-dasharray: 2 10; stroke-linecap: round; opacity: 0.7; }}
.voyage-map .route-done {{ stroke: {red}; stroke-width: 4; stroke-dasharray: 14 9; stroke-linecap: round; }}
.voyage-map .x-mark {{ display: inline; stroke: {red}; stroke-width: 7; stroke-linecap: round; }}
.voyage-map text {{ font-family: "Germania One", serif; fill: #4a1a0c; }}
.voyage-map .label {{ font-size: 21px; paint-order: stroke; stroke: #f3e3b8; stroke-width: 4px; }}
.voyage-map .label.current {{ fill: {red}; font-size: 25px; }}
.voyage-map .land-label {{ font-size: 24px; fill: #6b3f16; }}
.voyage-map .compass-ring {{ fill: none; stroke: #6b3f16; stroke-width: 1.5; }}
.voyage-map .compass-point {{ fill: #e9d29a; stroke: #6b3f16; stroke-width: 1.2; }}
.voyage-map .compass-point.long {{ fill: #6b3f16; }}
"""

func bookCss(): string =
  ## a 19th century book of sea tales: cream paper with foxing, a printer's double rule frame,
  ## IM Fell (digitized types of the 17th century Fell collection, still the look of old printed books),
  ## black ink with red for rubrication, booktabs tables, engraved hatching on the map
  let ink = "#241a12"
  let red = "#8e1b17"
  result = &"""
.reveal-viewport {{
  background-color: #efe5cf;
  background-image: {noise(0.6, 0.12)},
    radial-gradient(circle at 12% 18%, rgba(150,100,40,0.06) 0 2.5%, transparent 4%),
    radial-gradient(circle at 85% 75%, rgba(150,100,40,0.05) 0 2%, transparent 3%),
    radial-gradient(ellipse at center, rgba(255,250,235,0) 60%, rgba(140,100,50,0.25) 100%);
}}
.reveal-viewport::after {{
  content: ""; position: fixed; inset: 16px; pointer-events: none;
  border: 4px double rgba(36,26,18,0.75); outline: 1px solid rgba(36,26,18,0.5); outline-offset: -12px;
}}
.reveal {{ font-family: "IM Fell English", serif; color: {ink}; font-size: 40px; }}
.reveal h1, .reveal h2, .reveal h3 {{ font-family: "IM Fell English SC", serif; color: {ink}; letter-spacing: 0.04em; font-weight: 400; }}
.reveal h2::after {{ content: "❧"; display: block; font-family: "IM Fell English", serif; font-size: 0.5em; color: {red}; margin-top: 0.15em; }}
.reveal strong {{ color: {red}; font-weight: 400; }}
.reveal em {{ color: {ink}; font-style: italic; font-weight: 400; text-decoration: underline; text-decoration-color: {red}; }}
.reveal a {{ color: {red}; }}
.reveal ul li::marker {{ content: "☞  "; color: {red}; }}
.reveal pre {{ box-shadow: none; border-top: 2px solid {ink}; border-bottom: 2px solid {ink}; background: transparent; }}
.reveal pre code, .reveal code {{ font-family: "Courier Prime", monospace; }}
.reveal pre code.hljs, .reveal pre samp.hljs {{ background: rgba(255,250,235,0.45); }}
.reveal pre samp.hljs {{ border-left-color: {red}; }}
.reveal table:not(.hljs-ln) {{ border-collapse: collapse; border-top: 2px solid {ink}; border-bottom: 2px solid {ink}; }}
.reveal table:not(.hljs-ln) th {{ font-family: "IM Fell English SC", serif; font-weight: 400; border-bottom: 1px solid {ink} !important; }}
.reveal table:not(.hljs-ln) td {{ border: none !important; }}
.reveal .rocks-quotes figure {{ border: none; }}
.reveal .rocks-quotes blockquote {{ background: none; box-shadow: none; border: none; font-style: italic; text-align: left; }}
.reveal .rocks-quotes blockquote::before {{ content: "“"; font-size: 2.4em; line-height: 0; vertical-align: -0.4em; color: {red}; margin-right: 0.05em; }}
.reveal .rocks-quotes blockquote strong, .reveal .rocks-quotes blockquote em {{ font-style: italic; }}
.reveal .rocks-quotes figcaption {{ font-family: "IM Fell English SC", serif; text-align: right; }}
.reveal .rocks-quotes figcaption::before {{ content: "— "; }}
.reveal .title-slide h2 {{ font-size: 2.3em; }}
.reveal .title-slide h2::before {{ content: "A Tale in Seven Islands"; display: block; font-family: "IM Fell English", serif; font-style: italic; font-size: 0.32em; letter-spacing: 0.1em; color: {red}; margin-bottom: 0.4em; }}
.reveal .title-art {{ display: none; }}
.reveal .chapter {{ font-family: "IM Fell English SC", serif; color: {red}; font-size: 0.75em; letter-spacing: 0.25em; margin: 0; }}
#agileLabLogo {{ filter: sepia(0.8) saturate(0.6); }}
.reveal .voyage-map {{ outline: 1px solid {ink}; outline-offset: 4px; }}
.reveal .map-slide h2::after {{ display: none; }}
.voyage-map .sea {{ fill: none; }}
.voyage-map .contour {{ fill: none; stroke: {ink}; stroke-width: 0.9; opacity: 0.55; }}
.voyage-map .contour.c2 {{ opacity: 0.35; }}
.voyage-map .contour.c3 {{ opacity: 0.2; }}
.voyage-map .hatch-line {{ stroke: {ink}; stroke-width: 1; opacity: 0.6; }}
.voyage-map .land {{ fill: #efe5cf; stroke: {ink}; stroke-width: 2; }}
.voyage-map .land-hatch, .voyage-map .island-hatch {{ display: inline; stroke: none; }}
.voyage-map .island {{ fill: #efe5cf; stroke: {ink}; stroke-width: 2; }}
.voyage-map .island-hatch {{ opacity: 0.35; }}
.voyage-map .island-hatch.visited {{ opacity: 0.7; }}
.voyage-map .island.current {{ stroke: {red}; stroke-width: 3; }}
.voyage-map .island-hatch.current {{ opacity: 0.9; }}
.voyage-map .route {{ stroke: {ink}; stroke-width: 1.4; stroke-dasharray: 5 6; opacity: 0.6; }}
.voyage-map .route-done {{ stroke: {red}; stroke-width: 2.2; stroke-dasharray: 9 5; }}
.voyage-map text {{ font-family: "IM Fell English", serif; fill: {ink}; font-style: italic; }}
.voyage-map .label {{ font-size: 19px; paint-order: stroke; stroke: #efe5cf; stroke-width: 5px; }}
.voyage-map .label.current {{ fill: {red}; font-size: 22px; }}
.voyage-map .land-label {{ font-family: "IM Fell English SC", serif; font-style: normal; font-size: 22px; letter-spacing: 0.3em; }}
.voyage-map .compass-ring {{ fill: none; stroke: {ink}; stroke-width: 1; }}
.voyage-map .compass-point {{ fill: #efe5cf; stroke: {ink}; stroke-width: 1; }}
.voyage-map .compass-point.long {{ fill: {ink}; }}
.voyage-map .compass-n {{ fill: {red}; }}
"""

func chartCss(): string =
  ## a modern nautical chart: chart paper, a thin neatline around the slide, a light grid,
  ## a grotesque sans for titles and Spectral for text. The slides keep the deck's colors (my.nim:
  ## AgileLab dark and light blue, orange for emphasis); chart magenta (the color charts use for
  ## lights and cautions) is only on the maps (Pietro, 2026-11-25)
  let navy = "#13334c"   # the maps' ink
  let magenta = "#b0167a"
  let blue = "#1f6fa3"   # the maps' water lines
  let ink = "#0e1f53"    # agileDarkBlue
  let light = "#02A4BD"  # agileLightBlue
  let orange = "#ee961a" # witboostOrange
  result = &"""
.reveal-viewport {{
  background-color: #f6f3ea;
  background-image:
    linear-gradient(rgba(2,164,189,0.07) 1px, transparent 1px),
    linear-gradient(90deg, rgba(2,164,189,0.07) 1px, transparent 1px);
  background-size: 80px 80px;
}}
.reveal-viewport::after {{
  content: ""; position: fixed; inset: 10px; pointer-events: none;
  border: 1px solid rgba(14,31,83,0.55); outline: 0.5px solid rgba(14,31,83,0.3); outline-offset: 4px;
}}
.reveal {{ font-family: "Spectral", serif; color: {ink}; font-size: 38px; }}
.reveal h1, .reveal h2, .reveal h3 {{ font-family: "Space Grotesk", sans-serif; color: {ink}; font-weight: 700; letter-spacing: 0.01em; }}
.reveal strong {{ color: {light}; }}
.reveal em {{ color: {orange}; font-style: normal; font-weight: 700; }}
.reveal a {{ color: {light}; }}
.reveal ul li::marker {{ color: {orange}; }}
.reveal pre {{ box-shadow: none; border: 1.5px solid {ink}; background: #ffffff; position: relative; }}
.reveal pre code, .reveal code {{ font-family: "JetBrains Mono", monospace; }}
.reveal pre code.hljs {{ background: #ffffff; }}
.reveal pre samp.hljs {{ background: #eef5f9; border-left-color: {light}; }}
.reveal table:not(.hljs-ln) {{ border-collapse: collapse; font-family: "Space Grotesk", sans-serif; font-size: 0.85em; }}
.reveal table:not(.hljs-ln) th {{ background: {ink}; color: #f6f3ea; border: none !important; }}
.reveal table:not(.hljs-ln) td {{ border-bottom: 1px solid rgba(14,31,83,0.3) !important; }}
.reveal .rocks-quotes figure {{ position: relative; }}
.reveal .rocks-quotes blockquote {{ background: #fff; border: 2px solid {orange}; box-shadow: none; padding-top: 1.1em; }}
.reveal .rocks-quotes blockquote::before {{ content: "CAUTION"; position: absolute; top: -0.65em; left: 0.8em; background: {orange}; color: #fff; font-family: "Space Grotesk", sans-serif; font-style: normal; font-weight: 700; font-size: 0.55em; letter-spacing: 0.15em; padding: 0.1em 0.5em; }}
.reveal .rocks-quotes figcaption {{ font-family: "Space Grotesk", sans-serif; font-size: 0.8em; }}
.reveal .title-slide h2 {{ font-size: 1.75em; margin-bottom: 0.15em; }}
.reveal .title-slide {{ position: relative; z-index: 1; }}
.reveal .title-slide .title-box {{ background: rgba(253,252,247,0.78); backdrop-filter: blur(3px); border: 1.5px solid {ink}; outline: 0.5px solid {ink}; outline-offset: 5px; padding: 0.35em 0.9em; font-size: 0.78em; display: inline-block; box-shadow: 0 6px 24px rgba(14,31,83,0.18); }}
.reveal .title-slide .title-sub {{ font-family: "Space Grotesk", sans-serif; color: #6b7682; font-size: 0.5em; margin: -0.2em 0 0.5em; }}
/* before the voyage nothing is in magenta but the route and the first port (Pietro, dry run 2026-11-26) */
.reveal .title-art .chart-stage .ct.land-name {{ color: {navy}; }}
/* the chart fills the screen and stays inside it: 1369 x 770 is 16:9 around the 1050 x 700 slide
   and its margin, scaled by --chart-fit (set by voyageDeckJs) on screens of other proportions */
.reveal .chart-stage > svg.voyage-map {{ width: 100%; height: auto; margin: 0; max-width: none; }}
.reveal .map-slide .chart-stage {{ position: absolute; width: calc(1369px * var(--chart-fit, 1)); left: 525px; top: 350px; transform: translate(-50%, -50%); }}
#agileLabLogo {{ z-index: 40; }}
.reveal .slides > section:has(.title-art) {{ top: 0 !important; height: 700px; display: flex !important; flex-direction: column; justify-content: center; }}
.reveal .title-art {{ opacity: 1; inset: auto; left: 525px; top: 350px; width: calc(1369px * var(--chart-fit, 1)); height: auto; transform: translate(-50%, -50%); z-index: 0; }}
.reveal .title-art .title-block {{ display: none; }}
.reveal .chapter {{ font-family: "Space Grotesk", sans-serif; color: {orange}; font-size: 0.6em; letter-spacing: 0.2em; margin: 0; }}
.voyage-map .sea {{ fill: #d7e9f2; }}
.voyage-map .grid {{ display: inline; }}
.voyage-map .grid-line {{ fill: none; stroke: {blue}; stroke-width: 0.6; opacity: 0.35; }}
.voyage-map .soundings {{ display: inline; }}
.voyage-map .soundings text {{ font-family: "Spectral", serif; font-style: italic; font-size: 13px; fill: {blue}; }}
.voyage-map .contour {{ fill: none; stroke: {blue}; stroke-width: 1; stroke-dasharray: 6 3; opacity: 0.6; }}
.voyage-map .contour.c1 {{ fill: #eef6fa; stroke-dasharray: none; opacity: 1; }}
.voyage-map .contour.c3 {{ opacity: 0.35; }}
.voyage-map .land {{ fill: #f2e3b3; stroke: {navy}; stroke-width: 1.5; }}
.voyage-map .island {{ fill: #f2e3b3; stroke: {navy}; stroke-width: 1.5; }}
.voyage-map .island.visited {{ fill: #e3d49f; }}
.voyage-map .island.current {{ fill: #f7d77a; stroke: {navy}; stroke-width: 2.5; }}
.voyage-map .route {{ stroke: {magenta}; stroke-width: 1.5; stroke-dasharray: 8 6; opacity: 0.55; }}
.voyage-map .route-done {{ stroke: {magenta}; stroke-width: 3; }}
.voyage-map .light {{ display: inline; fill: {magenta}; }}
.voyage-map text {{ font-family: "Space Grotesk", sans-serif; fill: {navy}; }}
.voyage-map .label {{ font-size: 17px; paint-order: stroke; stroke: #d7e9f2; stroke-width: 5px; }}
.voyage-map .label.current {{ fill: {magenta}; font-weight: 700; font-size: 19px; }}
.voyage-map .land-label {{ font-size: 18px; letter-spacing: 0.4em; text-transform: uppercase; }}
.voyage-map .compass-ring {{ fill: none; stroke: {magenta}; stroke-width: 1; }}
.voyage-map .compass-point {{ fill: #fff; stroke: {magenta}; stroke-width: 1; }}
.voyage-map .compass-point.long {{ fill: {magenta}; }}
.voyage-map .compass-n {{ fill: {magenta}; }}
"""

# --- the voyage on the chart deck: the title card, the agenda bar, the course drawing itself --------

proc titleCardCss(): string =
  ## the title slide's card sits where the portolano box is on the charts (maps/voyage.json), with
  ## the portolano's look and bigger text (Pietro, 2026-11-25). The chart behind the title is
  ## 1369 x 770 around the middle of the 1050 x 700 slide (see .title-art)
  let v = islandsVoyage()
  let pb = v.portolanoBox
  if pb[2] <= 0: return ""
  let k = 1369.0 / v.w
  let left = 525.0 - 1369.0 / 2 + pb[0] * k
  let top = 350.0 - 770.0 / 2 + pb[1] * k
  result = &"""
.reveal .title-slide {{ position: static; }}
.reveal .title-slide .title-box {{ position: absolute; left: {left:.1f}px; top: {top:.1f}px; width: {pb[2] * k:.1f}px; min-height: {pb[3] * k:.1f}px; box-sizing: border-box; text-align: left; display: block; font-size: 0.82em; padding: 0.5em 0.8em; background: rgba(253,252,247,0.93); border: 1px solid #1f2a33; outline: 0.5px solid #1f2a33; outline-offset: 4px; backdrop-filter: none; transform-origin: {525.0 - left:.1f}px {350.0 - top:.1f}px; transform: scale(var(--chart-fit, 1)); }}
.reveal .title-slide .title-box h2 {{ font-size: 1.75em; line-height: 1.05; margin: 0 0 0.2em; }}
.reveal .title-slide .title-box .title-sub {{ margin: 0 0 0.7em; padding-bottom: 0.6em; border-bottom: 0.5px solid #1f2a33; }}
.reveal .title-slide .title-box p {{ margin: 0.25em 0; }}
.reveal .title-art .portolano {{ display: none; }}
"""

const agendaCss = """
/* the agenda bar: the mainland and the seven islands along the bottom of every slide, the current
   one in magenta; the mainland comes first until the first island, then moves to the end, where the
   trip ends. On a map slide the names sail to their places on the chart, and back (Pietro,
   2026-11-25), the mainland to the chart's own "MAINLAND" */
#voyage-agenda { position: fixed; left: 280px; right: 120px; bottom: 16px; display: flex; justify-content: space-evenly; z-index: 30; pointer-events: none; opacity: 0; transition: opacity 0.5s ease; }
#voyage-agenda::before { content: ""; position: absolute; inset: -7px -12px; background: rgba(246,243,234,0.92); border-top: 1px solid rgba(14,31,83,0.55); z-index: -1; transition: opacity 0.6s ease; }
#voyage-agenda.shown { opacity: 1; }
#voyage-agenda.on-map::before { opacity: 0; }
#voyage-agenda span { font-family: "Space Grotesk", sans-serif; font-weight: 700; font-size: clamp(9px, 0.7vw, 16px); letter-spacing: 0.06em; color: #13334c; white-space: nowrap; transform-origin: 50% 50%; transition: transform 1.1s cubic-bezier(.5,0,.2,1), color 0.4s ease; text-shadow: 0 0 1px #fdfcf7, 0 0 2px #fdfcf7, 0 0 3px #fdfcf7, 0 0 4px #fdfcf7; }
#voyage-agenda span.visited { color: #4d6475; }
#voyage-agenda span.current { color: #b0167a; }
html.print-pdf #voyage-agenda, .reveal.overview ~ #voyage-agenda { display: none; }
body.voyage-agenda .reveal .slides section.present .map-slide :is(.ct.cname, .ct.land-name) { visibility: hidden; }
.reveal section.present .map-slide .anchor { animation: voyage-anchor 0.6s ease 3s both; }
@keyframes voyage-anchor { from { opacity: 0; } to { opacity: 1; } }
@media (prefers-reduced-motion: reduce) { #voyage-agenda span { transition: none; } .reveal section.present .map-slide .anchor { animation: none; } }
"""

const voyageDeckJs* = when slideTheme == "chart": """
<div id="voyage-agenda" aria-hidden="true"></div>
<script>
// The voyage on the chart deck (themes.nim): the agenda bar and the course drawing itself.
// Functions are consts in a closure: a global `draw` would be called by p5 (the thank-you sketch)
(() => {
  const bar = document.getElementById("voyage-agenda");
  const printing = /print-pdf/.test(location.search);
  const slides = Reveal.getSlides();
  const mapOf = s => s.querySelector(".map-slide .chart-stage[data-current]");
  // the island of every slide: the one of the last map slide before it (-1 before the first map)
  let at = -1;
  const islandOf = slides.map(s => { const m = mapOf(s); if (m) at = +m.dataset.current; return at; });
  const any = document.querySelector(".chart-stage[data-current]");
  const islands = any ? [...any.querySelectorAll(".ct.cname[data-n]")].map(e => e.textContent) : [];
  // the trip: one mainland, at the start of the bar until the first island, then at its end
  const names = islands.length ? [...islands, "MAINLAND"] : [];
  const mainland = islands.length; // the index of its span
  bar.innerHTML = names.map(n => "<span></span>").join("");
  [...bar.children].forEach((e, k) => { e.textContent = names[k]; });
  if (names.length) bar.children[mainland].style.order = "-1"; // at the start: the trip starts there
  if (!printing && names.length) document.body.classList.add("voyage-agenda");
  const spans = () => [...bar.children];
  const sail = (section, onMap) => {
    const b = bar.getBoundingClientRect();
    spans().forEach((e, k) => {
      // the mainland sails to the chart's own name, as the islands do
      const label = onMap && section.querySelector(k === mainland ? ".ct.land-name" : `.ct.cname[data-n="${k + 1}"]`);
      if (!label) { e.style.transform = ""; return; }
      const r = label.getBoundingClientRect();
      const x = b.left + e.offsetLeft + e.offsetWidth / 2, y = b.top + e.offsetTop + e.offsetHeight / 2;
      const s = r.height / e.offsetHeight;
      e.style.transform = `translate(${r.left + r.width / 2 - x}px, ${r.top + r.height / 2 - y}px) scale(${s})`;
    });
  }
  const moveMainland = atEnd => { // first or last in the bar; the names slide to their new places
    const m = spans()[mainland];
    if ((m.style.order === "1") === atEnd) return;
    const before = spans().map(e => e.offsetLeft);
    m.style.order = atEnd ? "1" : "-1";
    spans().forEach((e, k) => {
      const dx = before[k] - e.offsetLeft;
      if (!dx || e.style.transform) return; // a name on the chart sails from where it is
      e.style.transition = "none"; e.style.transform = `translateX(${dx}px)`;
      e.getBoundingClientRect();
      e.style.transition = ""; e.style.transform = "";
    });
  }
  const drawCourse = section => { // the leg just sailed (or the whole course on the first map) draws itself
    for (const p of section.querySelectorAll(".map-slide .leg-new, .map-slide .course-mask")) {
      const L = p.getTotalLength(), slow = p.classList.contains("course-mask");
      p.style.transition = "none"; p.style.strokeDasharray = L; p.style.strokeDashoffset = L;
      p.getBoundingClientRect();
      p.style.transition = `stroke-dashoffset ${slow ? 3.2 : 1.8}s cubic-bezier(.4,0,.2,1) 1.4s`;
      p.style.strokeDashoffset = 0;
    }
  }
  const update = () => {
    if (printing || !names.length) return;
    const section = Reveal.getCurrentSlide();
    if (!section) return;
    const i = slides.indexOf(section), n = islandOf[i];
    const hide = i === 0 || section.querySelector(".sketch, .title-art");
    bar.classList.toggle("shown", !hide);
    spans().forEach((e, k) => {
      const atMainland = k === mainland && (n <= 0 || n === 8);
      e.classList.toggle("current", atMainland || k + 1 === n);
      e.classList.toggle("visited", !atMainland && (n === 8 || (n > 0 && (k + 1 < n || k === mainland))));
    });
    moveMainland(n >= 1);
    const onMap = !!mapOf(section);
    bar.classList.toggle("on-map", onMap);
    // the names sail once the slide is in place (while reveal.js slides it in, it is off screen)
    if (!onMap || Reveal.getConfig().transition === "none") sail(section, onMap);
    else sail(section, false);
    if (onMap) drawCourse(section);
  }
  const arrived = () => { const s = Reveal.getCurrentSlide(); if (s && mapOf(s)) sail(s, true); };
  // the chart (16:9, 1369 x 770 slide pixels) fits inside the window, whatever its proportions:
  // --chart-fit scales it (themes.nim, chartCss), 14px of the window left free around it
  const fit = () => {
    const v = Reveal.getViewportElement(), s = Reveal.getScale(), gap = 28;
    const f = Math.min((v.clientWidth - gap) / s / 1369, (v.clientHeight - gap) / s / 770);
    if (!printing && f > 0) document.documentElement.style.setProperty("--chart-fit", f.toFixed(4));
  }
  Reveal.on("ready", () => { fit(); update(); arrived(); });
  Reveal.on("slidechanged", update);
  Reveal.on("slidetransitionend", arrived);
  Reveal.on("resize", () => { fit(); const s = Reveal.getCurrentSlide(); if (s) sail(s, !!mapOf(s)); });
  if (Reveal.isReady()) { fit(); update(); arrived(); }
})();
</script>
""" else: ""

proc themeCss*(): string =
  case slideTheme
  of "pirate": commonCss & pirateCss() & pixelMapCss
  of "book": commonCss & bookCss() & engravedMapCss
  of "chart": commonCss & chartCss() & chartMapCss & titleCardCss() & agendaCss
  else: ""

# --- theme specific slide parts ---------------------------------------------------------

const romanNumerals = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

func mapHeading*(islands: openArray[string], n: int): string =
  ## the heading of a map slide, in the theme's voice
  let name = if n in 1..7: islands[n - 1] else: ""
  case slideTheme
  of "book":
    let chapter = "<p class=\"chapter\">Chapter " & romanNumerals[n + 1] & "</p>\n"
    if n == 0: chapter & "<h2>The Map of the Voyage</h2>"
    elif n == 8: chapter & "<h2>In which we return to Land</h2>"
    else: chapter & "<h2>The Island of " & name & "</h2>"
  of "chart": "" # the chart's own title block says which chart it is (maps/chart.nim)
  else:
    if n == 0: "<h2>The map</h2>"
    elif n == 8: "<h2>Back on land</h2>"
    else: "<h2>Island " & $n & ": " & name & "</h2>"
