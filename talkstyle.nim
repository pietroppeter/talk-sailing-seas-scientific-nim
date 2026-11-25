## The style of the nimib pages (deep dives and talk log): colours as tokens, and the CSS of
## the blocks in blocks.nim. Pages hold no CSS and no colour: what they need goes here.
## The slides have their own style, in my.nim (and themes.nim for the explored themes).
import std / json
import nimib
import maps / [pixel, chart, engraved]
import blocks # codeLanguageCss

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
/* a wide formula scrolls in its own box on a phone, as code does */
.katex-display { overflow-x: auto; overflow-y: hidden; }
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
/* an app compiled to JavaScript (nbApp, which Karax renders into): sliders in a sidebar, then a canvas */
.app { border: 1px solid var(--line); border-radius: 6px; padding: 0.8em; }
.app > div { display: flex; flex-wrap: wrap; gap: 1em; align-items: flex-start; }
.app .sidebar { display: flex; flex-direction: column; gap: 0.6em; flex: 0 0 13em; }
.app label { display: grid; grid-template-columns: 1fr auto; font-size: 0.9em; }
.app input { grid-column: 1 / 3; width: 100%; margin: 0.2em 0 0; }
/* code you drag (nbCodeStage, zogyn): the code as an svg, its slider lines move */
.code-stage svg { display: block; width: min(100%, 460px); height: auto; overflow: visible; touch-action: none; user-select: none; font-family: monospace; font-size: 14px; }
.code-stage text, .code-stage tspan { fill: currentColor; }
.code-stage .item { transition: transform 0.3s cubic-bezier(0.2, 0.9, 0.25, 1); }
.code-stage .item.grab { cursor: grab; }
.code-stage .item.lifted { transition: none; cursor: grabbing; }
.code-stage .handle { fill: var(--accent); fill-opacity: 0.1; }
.code-stage .lifted .handle { fill-opacity: 0.3; }
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

  # the map editor (mapeditor.nim, the block nbMapEditor): a chart table, the chart's paper, ink and
  # magenta, and the fonts of the deck; scoped to the editor, whose page is otherwise a site page
  mapEditorCss = """
.map-editor { color-scheme: light; --paper: #fdfcf7; --table: #ece7da; --ink: #1f2a33; --navy: #0e1f53; --magenta: #b0167a; --orange: #ee961a; --line: #c9c1ad; }
.map-editor * { box-sizing: border-box; min-width: 0; }
.map-editor [hidden] { display: none !important; }
.map-editor { margin: 0; background: var(--table); color: var(--ink); font: 15px/1.5 "Space Grotesk", system-ui, sans-serif; overflow-x: clip; }
.map-editor button, .map-editor select, .map-editor input, .map-editor textarea { font: inherit; color: inherit; }
.map-editor button { min-height: 38px; padding: 0 14px; border: 1px solid var(--ink); background: var(--paper); border-radius: 3px; cursor: pointer; }
.map-editor button:hover { background: #fff; }
.map-editor button:focus-visible, .map-editor select:focus-visible, .map-editor input:focus-visible, .map-editor textarea:focus-visible { outline: 2px solid var(--magenta); outline-offset: 2px; }
.map-editor button.primary { background: var(--navy); color: #fff; border-color: var(--navy); }
.map-editor .bar { display: flex; flex-wrap: wrap; align-items: center; gap: 12px 24px; padding: 12px max(2vw, 14px); border-bottom: 1px solid var(--line); background: var(--paper); }
.map-editor .bar h1 { margin: 0; font-size: 20px; letter-spacing: 0.04em; }
.map-editor .tabs { display: flex; gap: 4px; }
.map-editor .tab { border-color: transparent; background: transparent; }
.map-editor .tab.on { border-color: var(--ink); background: var(--ink); color: var(--paper); }
.map-editor .tools { display: flex; gap: 6px; margin-left: auto; }
.map-editor .layout { display: grid; grid-template-columns: minmax(0, 1fr) 320px; gap: 16px; padding: 16px max(2vw, 14px); align-items: start; }
.map-editor .stage-wrap { position: sticky; top: 8px; }
.map-editor .hint { font-size: 13px; color: #4a5763; margin: 8px 2px 0; max-width: 80ch; }
.map-editor .panel { display: grid; gap: 12px; }
.map-editor .card { background: var(--paper); border: 1px solid var(--line); border-radius: 4px; padding: 12px 14px; }
.map-editor .card h2 { font-size: 15px; margin: 0 0 8px; letter-spacing: 0.03em; }
.map-editor .muted { color: #4a5763; font-size: 13.5px; margin: 0 0 8px; }
.map-editor .row { display: flex; align-items: center; justify-content: space-between; gap: 10px; margin: 6px 0; font-size: 14px; }
.map-editor .row input[type=number] { width: 7em; min-height: 34px; padding: 0 6px; border: 1px solid var(--line); border-radius: 3px; background: #fff; font-size: 16px; }
.map-editor .row select { min-height: 34px; max-width: 60%; border: 1px solid var(--line); border-radius: 3px; background: #fff; }
.map-editor .check { display: flex; align-items: center; gap: 8px; margin: 4px 0; font-size: 14px; }
.map-editor .check input { width: 18px; height: 18px; accent-color: var(--magenta); }
.map-editor .btns { display: flex; flex-wrap: wrap; gap: 6px; margin: 8px 0; }
.map-editor textarea { width: 100%; border: 1px solid var(--line); border-radius: 3px; background: #fff; padding: 8px; font-size: 14px; resize: vertical; }
.map-editor #json { font: 12px/1.4 "JetBrains Mono", monospace; white-space: pre; overflow: auto; }
.map-editor #pt-text { font-family: "Spectral", serif; font-size: 15px; }
.map-editor input[type=range] { width: 55%; accent-color: var(--magenta); }
.map-editor .editor-stage { border: 1px solid var(--line); background: var(--paper); box-shadow: 0 8px 30px rgba(31, 42, 51, 0.12); overflow: hidden; user-select: none; -webkit-user-select: none; }
.map-editor .editor-stage > svg { touch-action: none; }
.map-editor .editor-stage svg > g:first-of-type, .map-editor .editor-stage #words { transition: opacity 0.6s ease; }
.map-editor #words { position: absolute; inset: 0; pointer-events: none; }
.map-editor .editor-stage:not(.previewing) #words .ct[data-kind] { pointer-events: auto; cursor: grab; }
.map-editor .editor-stage:not(.previewing) #words .ct[data-kind]:hover { outline: 1px dashed var(--magenta); outline-offset: 2px; }
.map-editor .busy { position: absolute; right: 10px; top: 10px; background: var(--ink); color: var(--paper); font-size: 12px; padding: 2px 8px; border-radius: 3px; }
.map-editor #layer-handles .hit { fill: transparent; stroke: none; cursor: move; }
.map-editor #layer-handles .island-hit:hover, .map-editor #layer-handles .coast-hit:hover { stroke: var(--magenta); stroke-width: 1; stroke-dasharray: 3 3; }
.map-editor #layer-handles .island-hit.sel, .map-editor #layer-handles .coast-hit.sel { stroke: var(--magenta); stroke-width: 1.6; stroke-dasharray: 4 3; }
.map-editor #layer-handles .coast-hit { cursor: move; }
.map-editor #layer-handles .leg-hit { fill: none; stroke: transparent; stroke-width: 9; cursor: copy; }
.map-editor #layer-handles .leg-hit:hover, .map-editor #layer-handles .leg-hit.sel { stroke: rgba(176, 22, 122, 0.18); }
.map-editor #layer-handles .rose-hit { cursor: move; }
.map-editor #layer-handles .wp { fill: #fff; stroke: var(--magenta); stroke-width: 1.4; cursor: move; }
.map-editor #layer-handles .wp.sel { fill: var(--magenta); }
.map-editor #layer-handles .anchor-hit { fill: transparent; stroke: var(--magenta); stroke-width: 1; stroke-dasharray: 2 2; cursor: move; }
.map-editor #layer-handles .anchor-hit.sel { stroke-width: 2; stroke-dasharray: none; }
.map-editor #layer-handles .knob { cursor: grab; }
.map-editor #layer-handles .knob circle { fill: #fff; stroke: var(--ink); stroke-width: 1.2; }
.map-editor #layer-handles .knob text { font: 700 10px "Space Grotesk", sans-serif; fill: var(--ink); pointer-events: none; }
.map-editor #layer-handles .guide { stroke: var(--ink); stroke-width: 0.6; stroke-dasharray: 2 2; }
.map-editor #layer-handles .pivot { fill: var(--ink); }
.map-editor .portolano { position: absolute; background: rgba(253, 252, 247, 0.93); border: 1px solid var(--ink); outline: 0.5px solid var(--ink); outline-offset: 0.25cqw; padding: 0.7cqw 0.9cqw; overflow: hidden; cursor: move; box-shadow: 0 0.4cqw 1.4cqw rgba(31, 42, 51, 0.12); transition: opacity 0.6s ease 0.6s, transform 0.6s ease 0.6s; }
.map-editor .portolano .pt-title { font: 700 1.25cqw "Space Grotesk", sans-serif; letter-spacing: 0.2em; color: var(--ink); }
.map-editor .portolano .pt-head { font: 700 0.78cqw "Space Grotesk", sans-serif; letter-spacing: 0.3em; color: var(--magenta); margin: 0.25cqw 0 0.5cqw; padding-bottom: 0.4cqw; border-bottom: 0.5px solid var(--ink); }
.map-editor .portolano.title-card .pt-title { font-size: 2.3cqw; letter-spacing: 0.01em; line-height: 1.1; color: var(--navy); }
.map-editor .portolano.title-card .pt-body { font-size: 1.3cqw; }
.map-editor .portolano .pt-body { font: italic 1.35cqw/1.4 "Spectral", serif; color: var(--ink); white-space: pre-wrap; }
.map-editor .pt-resize { position: absolute; right: 0; bottom: 0; width: 1.4cqw; height: 1.4cqw; min-width: 12px; min-height: 12px; cursor: nwse-resize; background: linear-gradient(135deg, transparent 50%, var(--ink) 50%); }
.map-editor .previewing .portolano { cursor: default; }
.map-editor .previewing .pt-resize { display: none; }
.map-editor .agenda-strip { position: absolute; left: 0; right: 0; height: 4.6%; transform: translateY(-50%); background: rgba(253, 252, 247, 0.9); border-top: 1px solid var(--ink); display: none; }
.map-editor #words.agenda-on .agenda-strip { display: block; transition: opacity 0.6s ease; }
.map-editor .previewing.on-map .agenda-strip { opacity: 0; }
.map-editor .agenda-measure { position: absolute; left: 1%; right: 1%; display: flex; justify-content: space-evenly; visibility: hidden; pointer-events: none; }
.map-editor .agenda-measure .ct { position: static; transform: none; }
.map-editor .ct.cname.bar { font-size: 0.86cqw; letter-spacing: 0.04em; }
.map-editor .ct.cname.bar.current { font-size: 0.98cqw; }
.map-editor .previewing .ct.cname { transition: left 1s cubic-bezier(.5, 0, .2, 1), top 1s cubic-bezier(.5, 0, .2, 1), font-size 1s ease, color 0.4s ease; }
.map-editor .previewing .ct.cname.instant { transition: none; }
.map-editor .previewing.on-slide > svg > g:first-of-type, .map-editor .previewing.on-slide > svg #layer-border { opacity: 0; }
.map-editor .previewing.on-slide #words > :not(.cname):not(.agenda-strip) { opacity: 0; }
.map-editor .previewing.on-slide .portolano { opacity: 0; transform: translateY(0.6cqw); transition: opacity 0.3s ease, transform 0.3s ease; }
.map-editor .previewing .ct.cname { pointer-events: none; }
.map-editor .slide-heading { position: absolute; left: 7%; top: 10%; right: 7%; pointer-events: none; }
.map-editor .slide-heading .sh-kicker { font: 700 1.1cqw "Space Grotesk", sans-serif; letter-spacing: 0.2em; color: var(--orange); text-transform: uppercase; }
.map-editor .slide-heading .sh-title { font: 700 3.4cqw/1.1 "Space Grotesk", sans-serif; color: var(--navy); margin-top: 0.4cqw; }
.map-editor .slide-heading .sh-lines span { display: block; height: 1.1cqw; margin-top: 1.6cqw; background: #e6e1d4; border-radius: 0.3cqw; }
.map-editor .slide-heading .sh-lines span:nth-child(1) { width: 70%; margin-top: 3cqw; }
.map-editor .slide-heading .sh-lines span:nth-child(2) { width: 58%; }
.map-editor .slide-heading .sh-lines span:nth-child(3) { width: 64%; }
.map-editor #layer-course .leg-draw.go { transition: stroke-dashoffset 1.8s cubic-bezier(.4, 0, .2, 1) 0.5s; }
.map-editor #layer-course .leg-draw.slow.go { transition-duration: 3.2s; }
.map-editor .anchor.drop { animation: drop 0.6s ease 1.9s both; }
@keyframes drop { from { opacity: 0; } to { opacity: 1; } }
.map-editor .preview-controls { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; margin-top: 10px; }
.map-editor .pv-steps { display: flex; flex-wrap: wrap; gap: 4px; }
.map-editor .pv-step { min-height: 34px; min-width: 34px; padding: 0 8px; font-size: 13px; }
.map-editor .pv-step.map { border-color: var(--magenta); color: var(--magenta); }
.map-editor .pv-step.on { background: var(--ink); color: var(--paper); border-color: var(--ink); }
.map-editor #pv-play { margin-left: auto; }
@media (max-width: 980px) { .map-editor .layout { grid-template-columns: minmax(0, 1fr); }
.map-editor .stage-wrap { position: static; } }
@media (prefers-reduced-motion: reduce) { .map-editor .previewing .ct.cname, .map-editor #layer-course .leg-draw.go, .map-editor .portolano { transition: none !important; }
.map-editor .anchor.drop { animation: none; } }
/* on the site: the editor takes the whole width, and water.css's forms give way to the chart table's */
body:has(.map-editor) { max-width: none; padding: 0 max(2vw, 14px); }
.map-editor { margin: 0 calc(-1 * max(2vw, 14px)); }
.map-editor button, .map-editor select, .map-editor input, .map-editor textarea { margin: 0; }
.map-editor select, .map-editor textarea, .map-editor input[type=number] { background: #fff; color: var(--ink); }
.map-editor input[type=range] { padding: 0; }
.map-editor .paper { fill: var(--paper); }
.map-editor code { background: var(--table); color: var(--ink); }
"""

proc addCss(nb: var Nb, css: string) =
  nb.doc.context["nb_style"] = %(nb.doc.context{"nb_style"}.getStr &
    "\n<style>\n" & css & "</style>")

proc useTalkStyle*(nb: var Nb) =
  ## the CSS of every nimib page: tokens, the blocks of blocks.nim, the plain voyage map
  nb.addCss(tokens & pageCss & codeLanguageCss & bareMapCss)

proc useMapStyle*(nb: var Nb) =
  ## for a page that shows the voyage maps in the themes' looks (maps/): their CSS and fonts
  nb.addCss(pixelMapCss & chartMapCss & engravedMapCss)
  nb.doc.context["stylesheet"] = %(nb.doc.context{"stylesheet"}.getStr &
    "\n<link rel=\"stylesheet\" href=\"" & nb.doc.relToRoot("assets/fonts/fonts.css") & "\">")

proc useMapEditorStyle*(nb: var Nb) =
  ## for the map editor (mapeditor.nim): the chart's CSS, the editor's, and the deck's fonts
  nb.addCss(chartMapCss & mapEditorCss)
  nb.doc.context["stylesheet"] = %(nb.doc.context{"stylesheet"}.getStr &
    "\n<link rel=\"stylesheet\" href=\"" & nb.doc.relToRoot("assets/fonts/fonts.css") & "\">")
