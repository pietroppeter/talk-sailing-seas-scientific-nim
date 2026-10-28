import std / [json, strutils]
import nimib
import plotly

# Show a nim-plotly plot in a nimib document, as an interactive plot.
# plotly.js comes from a CDN, loaded once before the first plot.
# Small and generic: a candidate for nimib or nim-plotly.
#   nbPlotly(p)  # p: Plot[T] from nim-plotly

const plotlyJs* = "https://cdn.jsdelivr.net/npm/plotly.js-dist-min@2.35.2/plotly.min.js"

var plotlyCount = 0

proc plotlyHtml*[T](p: Plot[T]): string =
  ## the html of a plot: a div and the script that draws in it
  let pj = p.toPlotJson
  inc plotlyCount
  let id = "nb-plotly-" & $plotlyCount
  if plotlyCount == 1:
    result.add "<script src=\"$1\"></script>\n" % plotlyJs
  result.add "<div id=\"$1\"></div>\n" % id
  result.add "<script>Plotly.newPlot(\"$1\", $2, $3, {responsive: true});</script>" %
    [id, $pj.traces, $pj.layout]

template nbPlotly*[T](p: Plot[T]) =
  nbRawHtml(plotlyHtml(p))
