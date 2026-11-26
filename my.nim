import std / [strutils, strformat, json, math, xmltree, sequtils]
import islandnames # the names of the islands, for the map slides
export islandnames
export strutils
import nimib, nimiSlides
import themes
export themes
import tabelline
import offline # freshRenderer
import blocks # nbImg, nbShowCode, nbSketch, ... (pages and slides share them)
export offline, blocks
import tabelline / nimib as tabellineNimib
# only nbTable: tabelline's other names (Column, readCsv, ...) clash with Datamancer's,
# so a slide file that makes a table imports tabelline itself
export tabellineNimib

const
  agileLightBlue* = "#02A4BD"
  agileDarkBlue* = "#0e1f53"
  agileWhite* = "#FFF"
  witboostOrange* = "#ee961a"
  softWhite* = "#F7F7F4" # background: white, not too bright
  agileLogUrl* = "https://www.agilelab.it/hubfs/logo-agilelab.png"

newNbBlock(NbTextSmall of NbText):
  toHtml:
    "<small>" & nb.renderPartial("nbText", jsonutils.toJson(blk)) & "</small>"

template nbTextSmall*(ttext: string) =
  nb.add newNbTextSmall(text = ttext)

template reference*(text: string) =
  nbTextSmall: text

const slideBlocksCss = """
/* blocks of blocks.nim on the slides, and the layouts of Island 2 */
.reveal .lede.story { font-size: 0.8em; }
.reveal h3 .gh-mark { height: 0.8em; width: 0.8em; vertical-align: -0.05em; margin-right: 0.15em; }
.reveal .rocks-quotes { display: grid; grid-template-columns: 1fr 1fr; gap: 1.5em; }
.reveal .rocks-quotes figure { margin: 0; }
.reveal .rocks-quotes blockquote { width: auto; margin: 0; font-size: 0.75em; }
.reveal .rocks-quotes figcaption { font-size: 0.55em; margin-top: 0.5em; }
/* Island 1: the line saying what the Vandermonde matrix is, as small as nbTextSmall (a div, since KaTeX breaks inside reveal's small) */
.reveal .perf-intro { font-size: 0.6em; }
/* an app compiled to JavaScript (nbApp, slide 7.3): sliders in a sidebar, then a canvas */
.reveal .app > div { display: flex; gap: 1.2em; align-items: center; justify-content: center; margin: 0.4em 0 0.4em 1.8em; }
.reveal .app .sidebar { display: flex; flex-direction: column; gap: 0.5em; width: 11em; font-size: 0.6em; text-align: left; }
.reveal .app label { display: grid; grid-template-columns: 1fr auto; column-gap: 0.5em; }
.reveal .app input { grid-column: 1 / 3; width: 100%; margin: 0.2em 0 0; }
/* code you drag (nbCodeStage, zogyn, slide 7.3): the code as an svg, its slider lines move */
.reveal .code-stage { width: 100%; }
.reveal .code-stage svg { display: block; width: 100%; height: auto; overflow: visible; touch-action: none; user-select: none; font-family: var(--r-code-font); font-size: 14px; }
.reveal .code-stage text, .reveal .code-stage tspan { fill: currentColor; }
.reveal .code-stage .item { transition: transform 0.3s cubic-bezier(0.2, 0.9, 0.25, 1); }
.reveal .code-stage .item.grab { cursor: grab; }
.reveal .code-stage .item.lifted { transition: none; cursor: grabbing; }
.reveal .code-stage .handle { fill: var(--r-link-color); fill-opacity: 0; } /* a secret: no hint that the lines move */
.reveal .code-stage .lifted .handle { fill-opacity: 0; }
.reveal .code-stage .scrub { cursor: ew-resize; } /* bounds you scrub, as in Bret Victor's explorable explanations */
/* what you are about to drag turns orange: the word slider of a line, or a number */
.reveal .code-stage .item:hover:not(:has(.scrub:hover)) .slider-word, .reveal .code-stage .item.lifted .slider-word,
.reveal .code-stage .scrub:hover { color: #ee961a; }
/* imageAside: a picture with something smaller beside it (slide 7.2) */
.reveal .img-aside { display: grid; grid-template-columns: 2fr 1fr; gap: 1em; align-items: center; margin-top: 0.6em; }
.reveal .img-aside img { width: 100%; margin: 0; }
.reveal .img-aside-text { font-size: 0.6em; }
/* a page of the site live in a slide (nbFrame), e.g. naffprop's figure on slide 5.6 */
.reveal iframe.frame { width: 100%; height: 500px; border: 1px solid #ddd; border-radius: 6px; background: white; }
/* Island 1: Python and Nim side by side, each column as wide as its code */
.reveal .perf-cols { display: grid; grid-template-columns: max-content 1fr; gap: 0.6em; margin-bottom: 0.6em; }
.reveal .perf-cols pre { font-size: 0.45em; width: 100%; margin: 0; }
/* Island 7 (slide 8.3): a nimib document (nimibCode) on the left, what it renders on the right, as a page */
.reveal .nimib-twin { display: grid; grid-template-columns: minmax(0, 1.4fr) minmax(0, 1fr); column-gap: 1.2em; row-gap: 0; align-items: start; margin-top: 0.4em; }
.reveal .nimib-twin > :first-child { grid-column: 1; grid-row: 1 / span 8; font-size: 0.48em; margin: 0; width: 100%; }
.reveal .nimib-twin > :not(:first-child) { grid-column: 2; margin: 0; padding: 0.2em 0.8em; background: white; border: 1px solid #ddd; border-top: none; border-bottom: none; text-align: left; }
.reveal .nimib-twin > :nth-child(2) { border-top: 1px solid #ddd; border-radius: 6px 6px 0 0; padding-top: 0.6em; }
.reveal .nimib-twin > :last-child { border-bottom: 1px solid #ddd; border-radius: 0 0 6px 6px; padding-bottom: 0.6em; }
.reveal .nimib-twin > pre { font-size: 0.4em; width: 100%; box-sizing: border-box; }
.reveal .nimib-twin > p { font-size: 0.6em; }
.reveal .nimib-twin > h3 { font-size: 0.8em; }
/* nbQuote on a slide (8.2) */
.reveal .slides section > figure.quote { margin: 0.4em 0 0.6em; }
.reveal .slides section > figure.quote blockquote { width: auto; margin: 0; font-size: 0.85em; }
.reveal .slides section > figure.quote figcaption { font-size: 0.55em; margin-top: 0.4em; }
/* the photo of the crew on the rocks ahead slide (8.6): smaller, rounded */
.reveal .crew-photo img { width: 60%; border-radius: 14px; }
.reveal .crew-photo figure { margin: 0.5em 0 0; }
.reveal .crew-photo figcaption { font-size: 0.5em; }
/* nbImg with a caption on a slide (8.6, the photo of the crew) */
.reveal .slides figure figcaption { font-size: 0.55em; margin-top: 0.3em; }
/* nbAvatars: round GitHub avatars of the people of nimib land (8.5) */
.reveal .avatars { display: flex; flex-wrap: wrap; justify-content: center; gap: 0.4em 0; margin: 0.4em auto 0.6em; max-width: 24em; }
/* nbCollage (slide 8.5): one big word over screenshots of pages, the whole slide */
.reveal .slides section:has(> .collage) { top: 0 !important; height: var(--slide-height); padding: 0; }
.reveal .collage { position: absolute; inset: 0; overflow: hidden; }
.reveal .collage-shots { position: absolute; inset: 0; }
.reveal .collage-shots img { position: absolute; width: 47%; margin: 0; border-radius: 6px;
  box-shadow: 0 6px 24px rgba(31, 42, 51, 0.25); }
.reveal .collage-shots img:nth-child(1) { left: 2%; top: 4%; transform: rotate(-3deg); }
.reveal .collage-shots img:nth-child(2) { right: 2%; top: 6%; transform: rotate(2.5deg); }
.reveal .collage-shots img:nth-child(3) { left: 4%; bottom: 6%; transform: rotate(2deg); }
.reveal .collage-shots img:nth-child(4) { right: 3%; bottom: 4%; transform: rotate(-2.5deg); }
.reveal .collage.phone .collage-shots { display: grid; grid-template-columns: repeat(8, 1fr); gap: 14px;
  align-content: center; padding: 0 24px; }
.reveal .collage.phone .collage-shots img { position: static; width: 100%; transform: none;
  border-radius: 12px; border: 3px solid var(--r-heading-color); }
.reveal .collage-word { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center;
  pointer-events: none; }
.reveal .collage-word { font-family: var(--r-heading-font); font-weight: 700; font-size: 2.6em;
  color: var(--r-heading-color); letter-spacing: 0.05em; }
.reveal .collage-word span { background: rgba(246, 243, 236, 0.9); padding: 0.1em 0.5em; border-radius: 0.2em;
  box-shadow: 0 4px 30px rgba(246, 243, 236, 0.9); }
.reveal .avatars a { display: flex; flex-direction: column; align-items: center; width: 3em; text-decoration: none; }
.reveal .avatars img { width: 2.1em; height: 2.1em; border-radius: 50%; margin: 0; border: 2px solid var(--r-link-color); }
.reveal .avatars.small { max-width: 40em; margin: 0.2em auto 0.3em; }
.reveal .avatars.small a { width: 2.1em; }
.reveal .avatars.small img { width: 1.4em; height: 1.4em; }
.reveal .avatars .nick { font-size: 0.32em; color: gray; margin-top: 0.3em; max-width: 100%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
/* no line numbers on code (dry run 1): reveal.js draws them as a table column */
.reveal .hljs-ln-numbers { display: none; }
/* centered: an image and its caption in the middle of a column (slide 4.8) */
.reveal .centered { text-align: center; }
.reveal .centered figure { margin: 0.3em auto 0; }
/* compactColumns: three narrow columns of code (Island 4 bridges), smaller code */
.reveal .compact-cols pre { font-size: 0.5em; }
.reveal .compact-cols ul { font-size: 0.8em; } /* lists too (1.4, You get / You pay) */
/* a table on its own in a slide (not in a layout's grid) gets room above and below */
.reveal .slides section > .tabella { margin: 0.8em 0; }
/* code in nimiSlides' columns (a grid) fills its column */
.reveal [style*="grid"] > div > pre { width: 100%; }
"""

template useSoftBackground* =
  ## the deck's off-white background, for a deck without the AgileLab theme (slides/emilia.nim)
  nb.addStyle ":root { --r-background-color: " & softWhite & "; }"

template agileTheme*() =
  setSlidesTheme(White)
  nb.addStyle slideBlocksCss
  nb.addStyle codeLanguageCss
  nb.addStyle: """
:root {
  --r-background-color: $2;
  --r-heading-color: $1;
  --r-link-color: $3;
  --r-selection-color: $3;
  --r-link-color-dark: darken($3 , 15%);
  --r-main-color: $1;
}

.reveal ul, .reveal ol {
  display: block;
  text-align: left;
}

li {
  padding-left: 12px;
}

.reveal strong {
  color: $3;
  font-style: normal;
}

.reveal em {
  color: $4;
  font-style: normal;
  font-weight: 700;
}

.reveal pre samp.hljs {
  display: block;
  padding: 0.5em 1em;
  border-left: 4px solid $3;
}
""" % [agileDarkBlue, softWhite, agileLightBlue, witboostOrange]

const quartoCss = """
/* Quarto's reveal.js look (quarto-cli, src/resources/formats/revealjs/quarto.scss, MIT):
   the sizes and margins only, the AgileLab colours and logo stay */
:root {
  --r-main-font-size: 40px;
  --r-block-margin: 12px;
  --r-heading-margin: 0 0 12px 0;
  --r-heading-text-transform: none;
}
.reveal .slides { text-align: left; }
.reveal h1, .reveal h2, .reveal h3, .reveal h4 { text-transform: none; font-weight: 600; }
/* a second heading on a slide (e.g. About AgileLab under About me) starts a new part: more room above it */
.reveal .slides section > h2:not(:first-child) { margin-top: 1em; }
.reveal p, .reveal .slides section, .reveal .slides section > section { line-height: 1.3; }
.reveal ul, .reveal ol { margin-left: 1em; }
.reveal li { padding-left: 0; }
.reveal pre {
  width: 100%;
  margin: var(--r-block-margin) 0;
  box-shadow: none;
  border: 1px solid #D8DCE6;
  border-radius: 4px;
  font-size: 0.55em;
  line-height: 1.3;
}
.reveal pre code { max-height: 500px; padding: 6px 9px; }
.reveal blockquote {
  width: unset;
  margin: var(--r-block-margin) 0;
  padding: 0.6em 1.75em;
  border-left: 4px solid #D8DCE6;
  box-shadow: none;
  background: none;
  font-style: normal;
}
"""

template imageLeftStyle* =
  ## css for `imageLeftSlide`: reveal.js sets --viewport-width/height and --slide-scale,
  ## so dividing by the scale gives the screen size in slide pixels
  nb.addStyle: """
.reveal .slides section:has(> .img-left) {
  top: 0 !important;
  height: var(--slide-height);
  padding: 0;
}

.img-left {
  --vw: calc(var(--viewport-width) / var(--slide-scale));
  --vh: calc(var(--viewport-height) / var(--slide-scale));
  --screen-left: calc(50% - var(--vw) / 2);
  --screen-top: calc(50% - var(--vh) / 2);
  --text-left: calc(var(--screen-left) + var(--vw) * var(--img-left-width) + 40px);
  position: absolute;
  inset: 0;
}

.reveal .img-left img.img-left-image {
  position: absolute;
  left: var(--screen-left);
  top: var(--screen-top);
  width: calc(var(--vw) * var(--img-left-width));
  height: var(--vh);
  max-width: none;
  max-height: none;
  margin: 0;
  object-fit: cover;
}

.img-left-text {
  position: absolute;
  left: var(--text-left);
  right: calc(var(--screen-left) + 60px);
  top: 0;
  bottom: 0;
  display: flex;
  flex-direction: column;
  justify-content: center;
  text-align: left;
}

.img-left-logo {
  position: absolute;
  left: calc(var(--text-left) - 30px);
  bottom: var(--screen-top);
  width: calc(250px / var(--slide-scale));
  height: calc(70px / var(--slide-scale));
  background: url(./images/logo-agilelab.png) no-repeat;
  background-size: contain;
}

body:has(.slides section.present > .img-left) #agileLabLogo {
  display: none;
}
"""

const agileLogoHtml = """
<div id="agileLabLogo" style="background: url(./images/logo-agilelab.png);
background-repeat: no-repeat;
position: absolute;
bottom: 0px;
left: 10px;
width: 250px;
height: 70px;"></div>
"""

const
  revealAssets = "assets/reveal.js" # vendored by scripts/vendor-assets.sh into docs/assets
  katexAssets = "assets/katex"
  p5Assets = "assets/p5"
  highlightAssets = "assets/highlight" # highlight.js styles, vendored by scripts/vendor-assets.sh
  fontAssets = "assets/fonts" # fonts of the explored themes, vendored by scripts/vendor-fonts.sh

const deckLook* {.strdefine.} = "quarto"
  ## the proportions of the deck: `quarto` (default, Quarto's reveal.js look: 1050x700, top-left aligned,
  ## 40px text, tighter margins) or `centered` (the earlier look, reveal.js' White theme: 960x700,
  ## centered, 42px text, upper-case headings), built on the side as docs/slides_centered.html
  ## with `nim r build.nim looks`
const quartoLook* = deckLook == "quarto"
const sideLook* = not quartoLook
  ## a deck in a look other than the default, built on the side


const codeTheme* {.strdefine.} = "atom-one-light"
  ## highlight.js style for code blocks, one of the files in docs/assets/highlight
  ## (try another with `nim r -d:codeTheme=github my.nim`)

func assetPath(nb: Nb, path: string): string =
  {.cast(noSideEffect).}:
    nb.doc.relToRoot(path)

func vendoredRevealCss(blk: JsonNode, nb: Nb): string =
  ## nimiSlides' revealCSS partial, loading reveal.js from docs/assets instead of the CDN
  let reveal = nb.assetPath(revealAssets)
  let theme = nb.doc.context{"slidesTheme"}.getStr
  result = &"""
<link rel="stylesheet" href="{reveal}/dist/reveal.css" />
<link rel="stylesheet" href="{reveal}/dist/theme/{theme}.css" />
<link rel="stylesheet" href="{nb.assetPath(highlightAssets)}/{codeTheme}.css" />
"""
  if themed: # fonts of the themes explored in the talk log (devlog/dressing_the_voyage.nim)
    result.add &"""<link rel="stylesheet" href="{nb.assetPath(fontAssets)}/fonts.css" />"""
  if nb.doc.context{"p5"}.getBool:
    result.add &"""<script src="{nb.assetPath(p5Assets)}/p5.min.js"></script>"""

func vendoredRevealJs(blk: JsonNode, nb: Nb): string =
  ## nimiSlides' revealJS partial, loading reveal.js and its plugins from docs/assets
  let reveal = nb.assetPath(revealAssets)
  result = &"""
<script src="{reveal}/dist/reveal.js"></script>
<script src="{reveal}/plugin/highlight/highlight.js"></script>
<script src="{reveal}/plugin/notes/notes.js"></script>
"""
  if nb.doc.context{"latex"}.getBool:
    result.add &"""<script src="{reveal}/plugin/math/math.js"></script>"""

func agileMainToHtml(doc: NbDoc, nb: Nb): string =
  ## nimiSlides' revealMainToHtml, plus the reveal math (KaTeX) plugin when LaTeX is on,
  ## with KaTeX loaded from docs/assets
  let docJson = %[]
  let renderedBlocks = nbContainerToHtml(doc, nb)
  let mathPlugin = if doc.context{"latex"}.getBool: "RevealMath.KaTeX," else: ""
  let katex = nb.assetPath(katexAssets)
  # Quarto's reveal.js settings (quarto-cli, format-reveal.ts): a wider slide, a larger margin
  # around it, and slides aligned at the top instead of centered; the title slide stays centered
  let layout = when quartoLook: "width: 1050, height: 700, margin: 0.1, center: false," else: ""
  let centerTitle = if quartoLook and doc.context{"centerFirst"}.getBool: "document.querySelector('.reveal .slides > section')?.classList.add('center');" else: ""
  result = withNewlines:
    hlHtmlF"""
<div class="reveal">
  <div class="slides">
    {renderedBlocks}
  </div>
</div>
    """
    nb.renderPartial("revealJS", docJson)
    "<script>"
    centerTitle
    &"""
    Reveal.initialize({{
      {layout}
      katex: {{ local: '{katex}' }},
      plugins: [
        RevealHighlight,
        RevealNotes,
        {mathPlugin}
      ]
    }});
    """
    nb.renderPartial("customJS", docJson)
    "</script>"

func agileNbDocToHtml(blk: NbBlock, nb: Nb): string =
  ## nimiSlides' revealNbDocToHtml with the AgileLab logo added at the end of body
  let doc = blk.NbDoc
  let docJson = %[]
  result = withNewlines:
    "<!DOCTYPE html>"
    """<html lang="en-us">"""
    nb.renderPartial("head", docJson)
    "<body>"
    agileMainToHtml(doc, nb)
    agileLogoHtml
    voyageDeckJs # the agenda bar and the course drawing itself, on the chart deck (themes.nim)
    "</body>"
    "</html>"

template useRevealLatex* =
  ## workaround: nimiSlides 0.4 checks `context["latex"]` as a bool, but
  ## nimib's `useLatex` stores the KaTeX html there, so the math plugin is never loaded
  nb.doc.context["latex"] = %true

const sketchCss = """
.reveal .slides section:has(> .sketch) {
  top: 0 !important;
  height: var(--slide-height);
  padding: 0;
}
.reveal .sketch {
  position: absolute;
  inset: 0;
}
.thank-you-link {
  position: absolute;
  z-index: 1;
  left: 0;
  right: 0;
  bottom: 12px;
  line-height: 1.3;
}
.thank-you-link p { margin: 0; }
/* the word over the sphere of the playfulness slide */
.reveal .playful-word {
  position: absolute;
  z-index: 1;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  pointer-events: none;
}
.reveal .playful-word h1 { font-size: 2.6em; margin: 0; padding: 0 0.4em; border-radius: 0.2em;
  background: rgba(246, 243, 236, 0.85); box-shadow: 0 4px 30px rgba(246, 243, 236, 0.9); }
/* the credit line, smaller than the link above it */
.thank-you-link small + small { opacity: 0.7; }
.thank-you-link small + small p { font-size: 0.67em; }
"""

template useP5* =
  ## load the vendored p5.js in the head, for slides with a p5nim sketch (see slides/thank_you.nim):
  ## a slide with an nbSketch is the sketch, full screen
  nb.doc.context["p5"] = %true
  nb.addStyle sketchCss

template useVendoredAssets* =
  ## load reveal.js and KaTeX from docs/assets instead of CDNs
  nb.backend.partials["revealCSS"] = vendoredRevealCss
  nb.backend.partials["revealJS"] = vendoredRevealJs

template myInit*(sourceFileRel = "my.nim", centerFirst = true) =
  ## `centerFirst`: the first slide is the title, centered (false for a part of the deck,
  ## which starts with its map slide: see buildDeckPart)
  nbInit(thisFileRel=sourceFileRel, theme=revealTheme, renderer=freshRenderer()) # a renderer of its own: see offline.nim
  nb.doc.context["centerFirst"] = %centerFirst
  useVendoredAssets
  useRevealLatex
  agileTheme()
  imageLeftStyle
  when quartoLook: # the default; -d:deckLook=centered for the earlier look
    nb.addStyle quartoCss
    if centerFirst: # the title slide stays centered
      nb.addStyle ".reveal .slides > section:first-child { text-align: center; }"
  when themed: # -d:slideTheme=pirate|book|chart, see themes.nim
    nb.addStyle: themeCss()
  nb.backend.funcs["NbDoc"] = agileNbDocToHtml

template buildDeckPart*(name, sourceFileRel: string, slides: untyped) =
  ## one part of the deck on its own, in the deck's look, into docs/slides_<name>.html,
  ## to review or share it without the whole talk: the `when isMainModule` of each module
  ## of slides/ (`nim r slides/intro.nim`, or `nim r build.nim intro`)
  myInit(sourceFileRel, centerFirst = name == "title")
  nb.doc.filename = "slides_" & name & ".html"
  slides
  nbSave



template mapSlide*(n: int) =
  ## placeholder for the map of the voyage: island `n` (1..7) highlighted,
  ## 0 for the whole map, 8 for back on land (all islands visited)
  when themed: # the voyage map drawn by themes.nim
    slide:
      nbDrawing(mapHeading(islands, n) & "\n" & voyageMap(islands, n), "map-slide")
  else:
    slide:
      var md = (if n == 0: "## The map\n\n" elif n == 8: "## Back on land\n\n" else: "## Island " & $n & "\n\n")
      for i, island in islands:
        let item = "Island " & $(i + 1) & ": " & island
        md.add "- " & (if i + 1 == n: "**" & item & "**" elif n == 8 or i + 1 < n: item & " ✓" else: item) & "\n"
      nbText md

template themedTitle*(body: untyped) =
  ## the title slide's content; a theme adds a class for its css and, behind it, the map of the voyage
  when themed:
    nbDrawing(voyageMap(islands, 0, "title"), "title-art")
    nbDiv("title-slide", ""):
      nbDiv("title-box", ""):
        body
  else:
    body

template placeholderSlide*(id, title, description: string) =
  ## draft slide from the outline: the published deck shows only the title and a draft marker,
  ## the outline description stays in the speaker notes
  slide:
    nbText "## " & title
    nbText "*draft*"
    nbTextSmall "slide " & id
    speakerNote description

newNbBlock(NbImageLeft of NbContainer):
  url: string
  width: float
  toHtml:
    # the width is a parameter of the layout, so it goes in a css variable on the element
    &"""<div class="img-left" style="--img-left-width: {blk.width}">
<img class="img-left-image" src="{blk.url}" alt="">
<div class="img-left-text">""" & nbContainerToHtml(blk, nb) & """</div>
<div class="img-left-logo"></div>
</div>"""

template imageLeftSlide*(url: string, width: float, body: untyped) =
  ## slide with an image on the left, full screen height and `width` (0..1) of the screen width,
  ## cropped to fill; the slide content is vertically centered on the right
  slide:
    let imgLeft = newNbImageLeft(@[], nb.doc.relToRoot(url), width) # positional: the parameters share the fields' names
    nb.withContainer(imgLeft):
      body
    nb.add imgLeft

template compactColumns*(body: untyped) =
  ## nimiSlides' `columns`, with smaller code and lists, for narrow columns
  nbDiv(classes = "compact-cols", styles = "display: grid; grid-auto-flow: column; grid-auto-columns: minmax(0, 1fr); column-gap: 0.8em;"):
    body

template imageLeftSlide*(url: string, body: untyped) =
  imageLeftSlide(url, 0.4, body)

newNbBlock(NbAvatars of NbBlock):
  logins: seq[string]
  dir: string
  small: bool
  toHtml:
    var html = if blk.small: "<div class=\"avatars small\">" else: "<div class=\"avatars\">"
    for login in blk.logins:
      html.add &"""<a href="https://github.com/{login}"><img src="{blk.dir}/{login}.jpg" alt="{login}"><span class="nick">{login}</span></a>"""
    html & "</div>"

template nbAvatars*(logins: openArray[string], small = false) =
  ## inside a slide: a wall of round GitHub avatars (vendored in docs/images/contributors/<login>.jpg),
  ## each linked to its profile (slide 8.5, the people of nimib land)
  nb.add newNbAvatars(@logins, nb.doc.relToRoot("images/contributors"), small)

newNbBlock(NbCollage of NbBlock):
  word: string
  shots: seq[string]
  phone: bool
  toHtml:
    var html = "<div class=\"collage" & (if blk.phone: " phone" else: "") & "\"><div class=\"collage-shots\">"
    for shot in blk.shots:
      html.add &"""<img src="{shot}" alt="">"""
    html & &"""</div><div class="collage-word"><span>{blk.word}</span></div></div>"""

template nbCollage*(word: string, shots: openArray[string], phone = false) =
  ## inside a slide: one big word over a collage of page screenshots (paths relative to docs/):
  ## four desktop shots as tilted cards, or with `phone` many phone-sized ones in a grid (slide 8.5)
  nb.add newNbCollage(word, @shots.mapIt(nb.doc.relToRoot(it)), phone)

newNbBlock(NbImageAside of NbContainer):
  url: string
  alt: string
  toHtml:
    &"""<div class="img-aside">
<img src="{blk.url}" alt="{xmltree.escape(blk.alt)}">
<div class="img-aside-text">""" & nbContainerToHtml(blk, nb) & """</div>
</div>"""

template imageAside*(url: string, alt: string, body: untyped) =
  ## inside a slide: a picture (path relative to docs/) taking about two thirds of the width,
  ## and beside it, smaller and vertically centered, what `body` adds (slide 7.2: the plant's equations)
  block:
    let aside = newNbImageAside(@[], nb.doc.relToRoot(url), alt)
    nb.withContainer(aside):
      body
    nb.add aside

proc slideLook*(t: sink Tabella, fontSize = "0.6em"): Tabella =
  ## the deck's look for a tabelline table: the slide's font, colours and background,
  ## the theme's blue for the rules, column labels in bold
  t.tabOptions(tableFontNames = "inherit", tableFontSize = fontSize, tableFontColor = agileDarkBlue,
    tableBackgroundColor = "transparent", tableMarginLeft = "auto", tableMarginRight = "auto",
    tableBorderTopColor = agileDarkBlue, tableBorderBottomColor = agileDarkBlue,
    columnLabelsBorderBottomColor = agileDarkBlue, columnLabelsFontWeight = "bold",
    tableBodyHlinesColor = "#D8DCE6", dataRowPadding = "0.25em",
    # reveal.js styles every table: undo its cell borders and padding
    extraCss = " th, td { border-bottom: none; padding-left: 0.6em; padding-right: 0.6em; }")

proc slideBars*(): NanoplotOptions =
  ## nanoplot options for bars on slides: the theme's light blue
  nanoplotOptions(dataBarFillColor = agileLightBlue, dataBarStrokeColor = agileLightBlue)

proc barBefore*(t: sink Tabella, column: string, plotHeight = "1em",
                options = slideBars()): Tabella =
  ## a bar for each number of `column` (a nanoplot), in an unlabelled column just before it,
  ## all bars from one zero line, so they compare; the number stays visible beside its bar
  let bar = column & "Bar"
  t.colsAdd(bar, proc (r: Row): Value = r[column], before = column)
    .fmtNanoplot(bar, plotType = "bar", plotHeight = plotHeight, options = options)
    .colsLabel(bar, "")

proc highlightCols*(t: sink Tabella, cols: ColSel): Tabella =
  ## the theme's light blue behind `cols`, from the label to the last row
  t.tabStyle(style.fill("#D9F2F6") & style.text(weight = "bold"), loc.body(cols), loc.columnLabels(cols))

proc highlightRows*(t: sink Tabella, rows: RowSel): Tabella =
  ## the theme's light blue behind `rows`, from the stub to the last column
  t.tabStyle(style.fill("#D9F2F6") & style.text(weight = "bold"), loc.body(rows = rows), loc.stub(rows = rows))

template testSlide* =
  slide:
    nbText """
## H2 header

### H3 header

Text with *italic*, **strong** and [link](https://www.recurse.com)

> a quote
"""
    reference "a small reference"
  slide:
    nbText: "### LaTeX and images"
    nbText: r"Inline math $e^{i\pi} + 1 = 0$ and display math $$\sum_{n=1}^\infty \frac{1}{n^2} = \frac{\pi^2}{6}$$"
    nbImg("images/logo-agilelab.png", width = "200px", caption = "an image with a width")
  imageLeftSlide("images/demo-sea.svg"):
    nbText: """
## Image on the left

- full screen height
- 40% of the screen width (default)
- text centered on the right
"""
  imageLeftSlide("images/demo-sea.svg", 0.25):
    nbText: """
## A narrower image

`imageLeftSlide(url, 0.25)`: a quarter of the screen width, the image is cropped to fill it
"""
  slide:
    nbText "### Code and its output"
    nbCode:
      type Boat = object
        name: string
        length: float # m
      func hullSpeed(b: Boat): float =
        ## knots, a rule of thumb
        1.34 * sqrt(b.length / 0.3048)
      let boat = Boat(name: "Nimbus", length: 9.0)
      echo boat.name, ": ", hullSpeed(boat).round(1), " knots"
  slide:
    nbText "### A table"
    let fleet = @[(boat: "Nimbus", length: 9.0, crew: 4),
                  (boat: "Cumulus", length: 12.5, crew: 6),
                  (boat: "Stratus", length: 7.2, crew: 2)]
    # inside a template: rows as named tuples (`tableData:` column names get mangled there)
    # and chained verbs (the `tabella(data): body` form does not compile there yet)
    let fleetTable = tabella(fleet, rownameCol = "boat")
      .tabStubhead("boat")
      .colsLabel("length", "length (m)")
      .fmtNumber("length", decimals = 1)
      .barBefore("crew")
      .highlightCols("length")
      .tabSourceNote("made with tabelline, slideLook and highlightCols in my.nim")
    nbTable fleetTable.slideLook
  slide:
    slide:
      nbText "## A vertical stack"
      nbText "the next slide is below"
    imageLeftSlide("images/demo-sea.svg", 0.5):
      nbText "## Inside a stack"
      nbText "half the screen, inside a vertical stack like the talk's sections"
      reference "a small reference"

template buildStyleDeck*() =
  ## the style test deck, docs/my.html
  myInit("my.nim")
  testSlide
  when sideLook:
    nb.doc.filename = "my_" & deckLook & ".html"
  nbSave

when isMainModule:
  buildStyleDeck()
