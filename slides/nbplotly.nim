import std / [json, strformat]
import nimib
import plotly
import ../offline # assetsDir

# Show a nim-plotly plot in a nimib document, as an interactive plot: a block of its own.
# plotly.js comes from docs/assets (scripts/vendor-assets.sh), loaded once, before the first plot.
# Small and generic: a candidate for nimib or nim-plotly.
#   nbPlotly(p)  # p: Plot[T] from nim-plotly

const plotlyJs* = "plotly/plotly.min.js" # in docs/assets

newNbBlock(NbPlotly):
  id: string
  traces: string  # JSON
  layout: string  # JSON
  lib: string     # plotly.js to load before this plot, empty when an earlier plot loaded it
  toHtml:
    if blk.lib.len > 0:
      result.add &"""<script src="{blk.lib}"></script>
"""
    result.add &"""<div id="{blk.id}"></div>
<script>Plotly.newPlot("{blk.id}", {blk.traces}, {blk.layout}, {{responsive: true}});</script>"""

proc plotly*[T](nb: var Nb, p: Plot[T]) =
  var count = 0
  for b in nb.doc.blocksFlattened:
    if b of NbPlotly: inc count
  let pj = p.toPlotJson
  nb.add newNbPlotly(id = "nb-plotly-" & $(count + 1), traces = $pj.traces, layout = $pj.layout,
    lib = if count == 0: nb.assetsDir & "/" & plotlyJs else: "")

template nbPlotly*[T](p: Plot[T]) =
  nb.plotly(p)
