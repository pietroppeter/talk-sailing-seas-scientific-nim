import std / [strutils, strformat, json]
export strutils
import nimib, nimiSlides

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

newNbBlock(NbImg):
  url: string
  width: string
  caption: string
  alt: string
  toHtml:
    &"""<figure>
<img src="{blk.url}" alt="{blk.alt}" width="{blk.width}">
<figcaption>{blk.caption}</figcaption>
</figure>"""

func img*(nb: var Nb, url: string, width: string, caption = "", alt = "") =
  let blk = newNbImg(url = nb.doc.relToRoot(url), width = width, caption = caption,
    alt = if alt.len == 0: caption else: alt)
  nb.add blk

template nbImg*(url: string, width: string, caption = "", alt = "") =
  nb.img(url, width, caption, alt)

template reference*(text: string) =
  nbTextSmall: text

template agileTheme*() =
  setSlidesTheme(White)
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
""" % [agileDarkBlue, softWhite, agileLightBlue, witboostOrange]

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
"""

const agileLogoHtml = """
<div id="agileLabLogo" style="background: url(./images/logo-agilelab.png);
background-position: right;
background-repeat: no-repeat;
position: absolute;
bottom: 0px;
right: 120px;
width: 250px;
height: 70px;"></div>
"""

const
  revealAssets = "assets/reveal.js" # vendored by scripts/vendor-assets.sh into docs/assets
  katexAssets = "assets/katex"

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
<link rel="stylesheet" href="{reveal}/plugin/highlight/monokai.css" />
"""

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
    &"""
    Reveal.initialize({{
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
    "</body>"
    "</html>"

template useRevealLatex* =
  ## workaround: nimiSlides 0.4 checks `context["latex"]` as a bool, but
  ## nimib's `useLatex` stores the KaTeX html there, so the math plugin is never loaded
  nb.doc.context["latex"] = %true

template useVendoredAssets* =
  ## load reveal.js and KaTeX from docs/assets instead of CDNs
  nb.backend.partials["revealCSS"] = vendoredRevealCss
  nb.backend.partials["revealJS"] = vendoredRevealJs

template myInit*(sourceFileRel = "my.nim") =
  nbInit(thisFileRel=sourceFileRel, theme=revealTheme)
  useVendoredAssets
  useRevealLatex
  agileTheme()
  imageLeftStyle
  nb.backend.funcs["NbDoc"] = agileNbDocToHtml


const islands* = [
  "Accessible Performance without Ceiling",
  "Success Stories",
  "Data Stack",
  "An Expressive Language",
  "Interoperability",
  "Interactivity",
  "Notebook",
]

template mapSlide*(n: int) =
  ## placeholder for the map of the voyage: island `n` (1..7) highlighted,
  ## 0 for the whole map, 8 for back on land (all islands visited)
  slide:
    var md = (if n == 0: "## The map\n\n" elif n == 8: "## Back on land\n\n" else: "## Island " & $n & "\n\n")
    for i, island in islands:
      let item = "Island " & $(i + 1) & ": " & island
      md.add "- " & (if i + 1 == n: "**" & item & "**" elif n == 8 or i + 1 < n: item & " ✓" else: item) & "\n"
    nbText md

template placeholderSlide*(id, title, description: string) =
  ## draft slide from the outline: the published deck shows only the title and a draft marker,
  ## the outline description stays in the speaker notes
  slide:
    nbText "## " & title
    nbText "*draft*"
    nbText "<small>slide " & id & "</small>"
    speakerNote description

template imageLeftSlide*(url: string, width: float, body: untyped) =
  ## slide with an image on the left, full screen height and `width` (0..1) of the screen width,
  ## cropped to fill; the slide content is vertically centered on the right
  slide:
    nbRawHtml: "<div class=\"img-left\" style=\"--img-left-width: " & $width & "\">\n" &
      "<img class=\"img-left-image\" src=\"" & nb.doc.relToRoot(url) & "\" alt=\"\">\n" &
      "<div class=\"img-left-text\">"
    body
    nbRawHtml: """</div>
</div>"""

template imageLeftSlide*(url: string, body: untyped) =
  imageLeftSlide(url, 0.4, body)

template testSlide =
  slide:
    nbText """
## H2 header

### H3 header

Text with *italic*, **strong** and [link](recurse.com)

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
    slide:
      nbText "## A vertical stack"
      nbText "the next slide is below"
    imageLeftSlide("images/demo-sea.svg", 0.5):
      nbText "## Inside a stack"
      nbText "half the screen, inside a vertical stack like the talk's sections"
      reference "a small reference"

when isMainModule:
  myInit("my.nim")
  testSlide
  nbSave
