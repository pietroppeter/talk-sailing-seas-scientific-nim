## The nimib pages (explainers, talk log) without CDNs: `nb.useOfflineAssets` after `nbInit`
## loads nimib's default theme (water.css, highlight.js and its code theme) and KaTeX (`nb.useLatex`)
## from docs/assets, vendored by scripts/vendor-assets.sh, so the pages also work offline.
## The slides do the same in my.nim (useVendoredAssets).
import std / [json, strutils]
import nimib
import nimib / themes

const
  katexVersion = "0.12.0" # the KaTeX that nimib's useLatex loads
  cdnPrefixes = [
    # what nimib loads from a CDN, and where it is in docs/assets
    ("https://cdn.jsdelivr.net/npm/water.css@2/out/", "water.css/"),
    ("https://cdn.jsdelivr.net/gh/pietroppeter/nimib@main/assets/", "nimib/"),
    ("https://cdn.jsdelivr.net/gh/pietroppeter/nimib/assets/", "nimib/"),
  ]

func assetsDir*(nb: Nb): string =
  ## docs/assets, relative to the page being written
  {.cast(noSideEffect).}:
    nb.doc.relToRoot("assets")

func localKatex(assets: string): string =
  ## nimib's useLatex html, with KaTeX from docs/assets
  let katex = assets & "/katex/dist"
  """<link rel="stylesheet" href="$1/katex.min.css">
<script defer src="$1/katex.min.js"></script>
<script defer src="$1/contrib/auto-render.min.js" onload="renderMathInElement(document.body,{delimiters:[{left: '$$$$', right: '$$$$', display: true},{left: '$$', right: '$$', display: false}]});"></script>""" % katex

func offlineHead(blk: JsonNode, nb: Nb): string =
  ## nimib's head, with every CDN link pointing to docs/assets
  let assets = nb.assetsDir
  result = headToHtml(blk, nb)
  result = result.replace(themes.latex, localKatex(assets))
  for (cdn, local) in cdnPrefixes:
    result = result.replace(cdn, assets & "/" & local)
  doAssert "katex@" & katexVersion notin result, "offline.nim: nimib's KaTeX html changed, update localKatex"

proc useOfflineAssets*(nb: var Nb) =
  nb.backend.partials["head"] = offlineHead
