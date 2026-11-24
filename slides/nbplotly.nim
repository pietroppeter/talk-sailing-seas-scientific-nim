import std / [json, strutils]
import nimib
import plotly
import ../offline # assetsDir

# Show a nim-plotly plot in a nimib document, as an interactive plot.
# plotly.js comes from docs/assets (scripts/vendor-assets.sh), loaded once before the first plot.
# Small and generic: a candidate for nimib or nim-plotly.
#   nbPlotly(p)  # p: Plot[T] from nim-plotly

const plotlyJs* = "plotly/plotly.min.js" # in docs/assets

var plotlyCount = 0

proc plotlyHtml*[T](p: Plot[T], assets = "assets"): string =
  ## the html of a plot: a div and the script that draws in it;
  ## `assets` is docs/assets relative to the page
  let pj = p.toPlotJson
  inc plotlyCount
  let id = "nb-plotly-" & $plotlyCount
  if plotlyCount == 1:
    result.add "<script src=\"$1\"></script>\n" % (assets & "/" & plotlyJs)
  result.add "<div id=\"$1\"></div>\n" % id
  result.add "<script>Plotly.newPlot(\"$1\", $2, $3, {responsive: true});</script>" %
    [id, $pj.traces, $pj.layout]

template nbPlotly*[T](p: Plot[T]) =
  nbRawHtml(plotlyHtml(p, nb.assetsDir))
