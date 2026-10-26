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
  ## draft slide from the outline: title, outline description, and a marker when content is still [tbd]
  slide:
    nbText "## " & title
    nbTextSmall description
    if "[tbd" in description:
      nbText "*draft: content to decide*"
    nbText "<small>slide " & id & "</small>"
    speakerNote description

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

when isMainModule:
  myInit("my.nim")
  testSlide
  nbSave
