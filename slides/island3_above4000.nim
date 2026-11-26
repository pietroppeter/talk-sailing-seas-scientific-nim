import std / [json, math, sequtils, strutils]
import nimib, nimiSlides
import nanuq
import plotly except Color
import nbplotly
import ../my

# Island 3, slide 4.8: nanuq and nim-plotly together, on the Alps' 4000ers
# (in place of the penguins' plotly slide, dry run 1, 2026-11-26).
# From nanuq's post "Above 4000" (deps/nanuq/docs/blog/above_4000.nim): its data is copied
# in docs/data/alps*.{csv,parquet} (the UIAA list from Wikipedia, CC BY-SA; coordinates from Wikidata and
# Camptocamp; the relief from Copernicus' GLO-90, as the post's relief_prep.py made it),
# the photo in docs/images/above4000.jpg (Pietro's own).
# A proc of its own module, as in island3_nanuq.nim: nanuq's names clash with Datamancer's.
# Paths are relative to docs/ (nimib's homeDir).

const terrain = [(0.0, "#2b6c8f"), (0.0001, "#e8eedb"), (0.15, "#c9d6a3"),
  (0.35, "#b9a173"), (0.6, "#8c6d4f"), (0.8, "#d8d2cb"), (1.0, "#ffffff")]

proc relief(path: string, zmax: float): JsonNode =
  ## the heights of the Alps as a heatmap trace, as in the post (plots.nim)
  let r = readParquet(path).select(col.lon, col.lat,
    col.ele.cast(Float64).clip(lowerBound = -1.0))
  let wide = r.pivot(on = "lon", index = "lat", values = "ele").sort("lat")
  let lons = wide.columns[1 .. ^1]
  var z: seq[seq[float]]
  for i in 0 ..< wide.height: z.add lons.mapIt(wide[it, i, float])
  result = %*{"type": "heatmap", "x": lons.mapIt(parseFloat(it)),
    "y": wide.toList("lat", float), "z": z, "zmin": 0, "zmax": zmax,
    "showscale": false, "hoverinfo": "skip"}
  result["colorscale"] = newJArray()
  for (p, c) in terrain: result["colorscale"].add %*[p, c]

proc above4000Content(nb: var Nb) = # 4.8
  nbText "## 🏔️ Above 4000: nanuq, nim-plotly"
  compactColumns:
    column:
      nbCode:
        let alps = readCsv("data/alps4000.csv")
          .filter(col("Nr.").isNotNull)
          .select(
            col("Nr.").cast(Int64).alias("nr"),
            col("Summit")
              .str.replaceAll(r"\[.*?\]", "")
              .alias("summit"),
            col("Height (m)").cast(Int64)
              .alias("height"))
          .join(readCsv("data/alps_xy.csv"),
            on = ["nr"])

        var p = Plot[float]()
        p.traces.add Trace[float](
          `type`: PlotType.Scatter,
          mode: PlotMode.Markers,
          xs: alps.toList("lon", float),
          ys: alps.toList("lat", float),
          text: alps.toList("summit", string))
    column:
      # the post's look, added to the JSON nim-plotly makes: the relief behind, red dots
      # sized by height, longitude and latitude in proportion
      let pj = p.toPlotJson
      pj.traces[0]["marker"] = %*{"color": "#c0392b",
        "size": alps.select(((col.height - 3900) / 60 + 5).alias("s")).toList("s", float),
        "line": {"width": 1, "color": "white"}}
      pj.traces[0]["hoverinfo"] = %"text"
      pj.traces.elems.insert(relief("data/alps_relief.parquet", 4800), 0)
      pj.layout = %*{"width": 470, "height": 250, "showlegend": false,
        "margin": {"l": 45, "r": 5, "t": 5, "b": 25},
        "paper_bgcolor": "rgba(0,0,0,0)", "font": {"size": 10}}
      pj.layout["xaxis"] = %*{"range": [5.6, 10.6], "showgrid": false,
        "constrain": "domain", "ticksuffix": "°E"}
      pj.layout["yaxis"] = %*{"range": [44.6, 47.0], "showgrid": false,
        "scaleanchor": "x", "scaleratio": 1 / cos(degToRad(45.8)),
        "constrain": "domain", "ticksuffix": "°N"}
      nb.plotly(pj)
      nbDiv("centered", ""):
        nbImg("images/above4000.jpg", "48%")
        nbTextSmall """
📱 Monte Rosa from Val Vigezzo: a photo taken while
working on nanuq with Claude on the phone

🐋 [Above 4000](https://pietroppeter.github.io/nanuq/blog/2026-11-01-above-4000.html):
the exploration in Nim and Python
"""

  speakerNote """
nanuq and nim-plotly together, on a dataset of mine:
the 82 mountains of the Alps above 4000 metres,
the official list of the UIAA, straight from Wikipedia.
nanuq cleans the table (footnotes, numbers as text)
and joins the coordinates; nim-plotly draws them on
the relief of the Alps, interactive: hover for the names
(the 82 of the UIAA list).
The photo is mine, from Val Vigezzo, looking at Monte Rosa:
six of those summits are in it.
The deep dive is the whole exploration, in Nim and in
Python side by side, with the same outputs.
"""

template above4000Slide* = # 4.8
  slide: above4000Content(nb)

when isMainModule: # this slide on its own: docs/slides_island3_above4000.html
  buildDeckPart("island3_above4000", "slides/island3_above4000.nim"):
    above4000Slide
