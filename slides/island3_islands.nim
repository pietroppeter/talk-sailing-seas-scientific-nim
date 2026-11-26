import std / [os, strutils, sequtils, algorithm]
import nimib, nimiSlides
import tabelline except Column, readCsv
import tabelline as tl
import ../my, ../islandnames

# Island 3, after tabelline (4.9): the islands of the voyage, uncovered.
# Each island of the chart is drawn with the coast of a real one (maps/voyage.json, "real"),
# from the islands story of tabelline (deps/tabelline/docs/stories/data/isole/islands.csv):
# this slide reads the same file and tells which ones they are, sea by sea.

const
  isoleCsv = currentSourcePath().parentDir.parentDir / "deps" / "tabelline" / "docs" /
    "stories" / "data" / "isole" / "islands.csv"
  voyage = [ # the real island of each island of the voyage, in its order (maps/voyage.json)
    "Vulcano", "Lošinj", "Porquerolles", "Milos", "Elba", "Caprera", "Leros"]
  seas = [ # the seas as the IHO draws them, from west to east, and the name on the slide
    ("Mediterranean Sea - Western Basin", "Western Mediterranean"),
    ("Tyrrhenian Sea", "Tyrrhenian Sea"),
    ("Adriatic Sea", "Adriatic Sea"),
    ("Aegean Sea", "Aegean Sea")]
  land = "#f3e3ae" # the chart's buff land and its ink (maps/chart.nim)
  ink = "#1f2a33"

proc nums(v: Value): seq[float] = ($v).splitWhitespace.mapIt(it.parseFloat)

proc islandsTable*(): Tabella =
  let isole = tl.readCsv(isoleCsv, comment = "#")
  var rows: seq[tuple[island, sea, chart, code: string, shape: Value,
                      km2, population: float]]
  for i in 0 ..< isole.nrows:
    let k = voyage.find($isole["island", i])
    if k < 0: continue
    let s = seas.mapIt(it[0]).find($isole["iho_sea", i])
    doAssert s >= 0, "no sea for " & $isole["island", i]
    rows.add (island: $isole["island", i], sea: seas[s][1],
              chart: $(k + 1) & " · " & islands[k], code: $isole["code", i],
              shape: toValue((x: nums(isole["x", i]), y: nums(isole["y", i]))),
              km2: isole["km2", i].toFloat, population: isole["population", i].toFloat)
  doAssert rows.len == voyage.len
  # sea by sea from west to east, and in each sea in the order of the voyage
  rows.sort(proc (a, b: typeof(rows[0])): int =
    cmp((seas.mapIt(it[1]).find(a.sea), a.chart), (seas.mapIt(it[1]).find(b.sea), b.chart)))
  let shapes = nanoplotOptions(dataBarFillColor = land, dataBarStrokeColor = ink)
  tabella(rows, rownameCol = "island", groupnameCol = "sea")
    .colsMove(["shape", "code"], after = "island")
    .fmtNanoplot("shape", plotType = "shape", plotHeight = "2em", options = shapes)
    .fmtFlag("code", round = true, height = "0.9em")
    .fmtInteger(["km2", "population"])
    .barBefore("km2", plotHeight = "0.9em")
    .barBefore("population", plotHeight = "0.9em")
    .colsLabel({"shape": "", "code": "", "chart": "on the chart",
                "km2": "km²", "population": "people"})
    .tabStyle(style.text(color = "#ee961a", style = "italic"), loc.rowGroups())
    .slideLook(fontSize = "0.53em")
    .tabOptions(dataRowPadding = "0.05em", rowGroupPadding = "0.3em",
                rowGroupFontWeight = "bold")

template islandsSlide* = # 4.10
  slide:
    nbText "## The islands, uncovered"
    nbTable islandsTable()
    reference """
From tabelline's story
[Islands of the Mediterranean](https://pietroppeter.github.io/tabelline/stories/isole/)
(data: OpenStreetMap, IHO, Wikipedia)
"""
    speakerNote """
And now I can tell you where we are sailing:
every island of the chart has the coast of a real one.
Sea by sea, with its flag, its shape, how big it is
and how many people live there.
Caprera is Garibaldi's island, and nobody lives there.
The shapes are a new nanoplot of tabelline:
the data is from the islands story on tabelline's site,
gathered with nanuq.
"""

when isMainModule: # this slide on its own: docs/slides_island3_islands.html
  buildDeckPart("island3_islands", "slides/island3_islands.nim"):
    islandsSlide
