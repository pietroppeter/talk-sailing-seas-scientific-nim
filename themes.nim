## Slide themes explored in slides/themes_explainer.nim (a proof of concept, not the deck's style yet).
##
## Build the deck with a theme: `nim r -d:slideTheme=pirate index.nim` (pirate, book or chart);
## the default `agile` is the AgileLab theme of my.nim and is unchanged.
## Each theme is css on top of the AgileLab theme, openly licensed fonts vendored in
## docs/assets/fonts (scripts/vendor-fonts.sh) and a map of the voyage drawn by code
## from one shared geometry (maps/), in the style of the theme.
import std / [strutils, strformat]
import maps / [base, pixel, chart, engraved]
export base

const slideTheme* {.strdefine.} = "agile"
  ## agile (default), pirate, book or chart

const themed* = slideTheme != "agile"

# --- the voyage map -------------------------------------------------------------------
# One geometry (maps/geometry.nim), one map per theme drawn from it:
# the base svg styled by css (agile and the explainer), pixel art (pirate),
# a nautical chart (chart) and a hand-drawn 19th century chart (book).

proc voyageMap*(islands: openArray[string], current: int, id = ""): string =
  ## the map of the voyage in the theme of the build; `current` (1..7) is the island
  ## of the section, 0 for the whole map, 8 for back on land
  let v = defaultVoyage()
  case slideTheme
  of "pirate": pixelMap(v, islands, current)
  of "chart": chartMap(v, islands, current, id)
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
  ## a modern nautical chart: chart paper, a graduated black and white border, a light grid,
  ## depth soundings and contours, chart magenta (the color charts use for lights and cautions)
  ## for emphasis and the "rocks ahead", a grotesque sans for titles and Spectral for text
  let navy = "#13334c"
  let magenta = "#b0167a"
  let blue = "#1f6fa3"
  result = &"""
.reveal-viewport {{
  background-color: #f6f3ea;
  background-image:
    linear-gradient(rgba(31,111,163,0.06) 1px, transparent 1px),
    linear-gradient(90deg, rgba(31,111,163,0.06) 1px, transparent 1px);
  background-size: 80px 80px;
}}
.reveal-viewport::after {{
  content: ""; position: fixed; inset: 10px; pointer-events: none; outline: 1px solid {navy};
  background:
    repeating-linear-gradient(90deg, {navy} 0 40px, transparent 40px 80px) top left / 100% 7px no-repeat,
    repeating-linear-gradient(90deg, {navy} 0 40px, transparent 40px 80px) bottom left / 100% 7px no-repeat,
    repeating-linear-gradient(180deg, {navy} 0 40px, transparent 40px 80px) top left / 7px 100% no-repeat,
    repeating-linear-gradient(180deg, {navy} 0 40px, transparent 40px 80px) top right / 7px 100% no-repeat;
}}
.reveal {{ font-family: "Spectral", serif; color: {navy}; font-size: 38px; }}
.reveal h1, .reveal h2, .reveal h3 {{ font-family: "Space Grotesk", sans-serif; color: {navy}; font-weight: 700; letter-spacing: 0.01em; }}
.reveal h2::before {{ content: ""; display: inline-block; width: 0.45em; height: 0.45em; background: {magenta}; transform: rotate(45deg); margin-right: 0.4em; vertical-align: 0.1em; }}
.reveal strong {{ color: {blue}; }}
.reveal em {{ color: {magenta}; }}
.reveal a {{ color: {blue}; }}
.reveal ul li::marker {{ color: {magenta}; }}
.reveal pre {{ box-shadow: none; border: 1.5px solid {navy}; background: #ffffff; position: relative; }}
.reveal pre code, .reveal code {{ font-family: "JetBrains Mono", monospace; }}
.reveal pre code.hljs {{ background: #ffffff; }}
.reveal pre samp.hljs {{ background: #eef5f9; border-left-color: {blue}; }}
.reveal table:not(.hljs-ln) {{ border-collapse: collapse; font-family: "Space Grotesk", sans-serif; font-size: 0.85em; }}
.reveal table:not(.hljs-ln) th {{ background: {navy}; color: #f6f3ea; border: none !important; }}
.reveal table:not(.hljs-ln) td {{ border-bottom: 1px solid rgba(19,51,76,0.3) !important; }}
.reveal .rocks-quotes figure {{ position: relative; }}
.reveal .rocks-quotes blockquote {{ background: #fff; border: 2px solid {magenta}; box-shadow: none; padding-top: 1.1em; }}
.reveal .rocks-quotes blockquote::before {{ content: "CAUTION"; position: absolute; top: -0.65em; left: 0.8em; background: {magenta}; color: #fff; font-family: "Space Grotesk", sans-serif; font-style: normal; font-weight: 700; font-size: 0.55em; letter-spacing: 0.15em; padding: 0.1em 0.5em; }}
.reveal .rocks-quotes figcaption {{ font-family: "Space Grotesk", sans-serif; font-size: 0.8em; }}
.reveal .title-slide h2 {{ font-size: 2.2em; }}
.reveal .title-slide h2::before {{ display: none; }}
.reveal .title-slide .title-box {{ background: rgba(246,243,234,0.92); border: 2px solid {navy}; outline: 1px solid {navy}; outline-offset: 5px; padding: 0.4em 0.8em; display: inline-block; }}
.reveal .title-slide .scale {{ font-family: "Space Grotesk", sans-serif; font-size: 0.5em; letter-spacing: 0.2em; color: {magenta}; }}
.reveal .title-art {{ opacity: 0.6; }}
.reveal .chapter {{ font-family: "Space Grotesk", sans-serif; color: {magenta}; font-size: 0.6em; letter-spacing: 0.2em; margin: 0; }}
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

func themeCss*(): string =
  case slideTheme
  of "pirate": commonCss & pirateCss() & pixelMapCss
  of "book": commonCss & bookCss() & engravedMapCss
  of "chart": commonCss & chartCss() & chartMapCss
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
  of "chart":
    if n == 0: "<p class=\"chapter\">CHART 0 · OVERVIEW</p>\n<h2>The map</h2>"
    elif n == 8: "<p class=\"chapter\">CHART 8 · LANDFALL</p>\n<h2>Back on land</h2>"
    else: "<p class=\"chapter\">CHART " & $n & " OF 7</p>\n<h2>" & name & "</h2>"
  else:
    if n == 0: "<h2>The map</h2>"
    elif n == 8: "<h2>Back on land</h2>"
    else: "<h2>Island " & $n & ": " & name & "</h2>"
