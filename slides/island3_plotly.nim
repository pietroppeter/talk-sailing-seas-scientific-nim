import std / [strutils, sequtils]
import nimib, nimiSlides
import datamancer
import plotly
import nbplotly
import ../my

# Island 3, slide 4.8: interactive plots with nim-plotly, one quick slide (dry run 1, 2026-11-26).
# A proc of its own module, as in island3_nanuq.nim: plotly's names (Plot, Axis, ...)
# would clash with ggplotnim's in island3_datastack.nim.
# Paths are relative to docs/ (nimib's homeDir).

proc plotlyContent(nb: var Nb) =
  nbText "## Plots: nim-plotly"
  nbCode:
    let df = readCsv("data/penguins.csv")
    var p = Plot[float](layout: Layout(width: 520, height: 250))
    for (key, sub) in groups(df.group_by("species")):
      p.traces.add Trace[float](mode: PlotMode.Markers,
        `type`: PlotType.Scatter, name: $key[0][1],
        xs: sub["bill_length_mm", float].toSeq1D,
        ys: sub["bill_depth_mm", float].toSeq1D)
  nbPlotly(p)
  nbTextSmall """
Interactive plots with plotly.js: hover, zoom, click the legend.
Started by Brent Pedersen, now in [SciNim](https://github.com/SciNim/nim-plotly).
"""
  speakerNote """
One quick slide: the other plotting library,
nim-plotly, for interactive plots in the browser.
Bill length and depth by species: hover, zoom,
click a species in the legend to hide it.
"""

template plotlySlide* = # 4.8
  slide: plotlyContent(nb)

when isMainModule: # this part of the deck on its own: docs/slides_island3_plotly.html
  buildDeckPart("island3_plotly", "slides/island3_plotly.nim"):
    plotlySlide
