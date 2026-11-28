import std / [os, strutils, sequtils, algorithm]
import nimib except md
import nimiSlides except speakerNote # blogpost.nim has its own (my.nim exports it)
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

type IslandRow* = tuple[island, sea, chart, code: string, shape: Value, people: float]

proc voyageIslands*(): seq[IslandRow] =
  ## the real islands of the chart, one row each, sea by sea from west to east
  ## and in each sea in the order of the voyage
  let isole = tl.readCsv(isoleCsv, comment = "#")
  for i in 0 ..< isole.nrows:
    let k = voyage.find($isole["island", i])
    if k < 0: continue
    let s = seas.mapIt(it[0]).find($isole["iho_sea", i])
    doAssert s >= 0, "no sea for " & $isole["island", i]
    result.add (island: $isole["island", i], sea: seas[s][1],
                chart: $(k + 1) & " · " & islands[k], code: $isole["code", i],
                shape: toValue((x: nums(isole["x", i]), y: nums(isole["y", i]))),
                people: isole["population", i].toFloat)
  doAssert result.len == voyage.len
  result.sort(proc (a, b: IslandRow): int =
    cmp((seas.mapIt(it[1]).find(a.sea), a.chart), (seas.mapIt(it[1]).find(b.sea), b.chart)))

proc onSlide(t: sink Tabella): Tabella =
  ## the deck's look, not shown on the slide: the chart's colours for the shapes,
  ## the seas in orange
  t.fmtNanoplot("shape", plotType = "shape", plotHeight = "2em",
      options = nanoplotOptions(dataBarFillColor = land, dataBarStrokeColor = ink))
    .fmtFlag("code", round = true, height = "0.9em")
    .fmtNanoplot("people", plotHeight = "1.4em",
      options = nanoplotOptions(dataLineStrokeColor = agileLightBlue, dataLineStrokeWidth = 6))
    .tabStyle(style.text(whitespace = "nowrap"), loc.body(cols("chart")))
    .tabStyle(style.text(color = "#ee961a", style = "italic"), loc.rowGroups())
    .slideLook(fontSize = "0.5em")
    .tabOptions(dataRowPadding = "0.05em", rowGroupPadding = "0.3em",
                rowGroupFontWeight = "bold")

proc islandsContent(nb: var Nb) = # 4.10
  nbText "## Display tables: tabelline"
  let rows = voyageIslands()
  const story = "https://pietroppeter.github.io/tabelline/stories/isole/"
  compactColumns:
    column:
      nbCode:
        # rows: the islands of the chart, with
        # their sea, flag, outline and people
        let islands = tabella(rows,
            rownameCol = "island",
            groupnameCol = "sea"):
          colsMove ["shape", "code"],
            after = "island"
          fmtNanoplot "shape", plotType = "shape"
          fmtFlag "code"
          fmtNanoplot "people"
          tabHeader(
            "A nice table with some islands",
            "API after gt and Great Tables")
          colsLabel:
            shape: ""
            code: ""
            chart: "on the chart"
          tabSourceNote md(
            "From tabelline's story " &
            "[Islands of the Mediterranean](" &
            story & ") (OSM, IHO, Wikipedia)")
    column:
      nbTable islands.onSlide
  speakerNote """
And now I can tell you where we are sailing:
every island of the chart has the coast of a real one.
Sea by sea, with its flag, its shape and how many people
live there (hover on a line for the number).
Caprera is Garibaldi's island, and nobody lives there.
The shapes are a new nanoplot of tabelline:
the data is from the islands story on tabelline's site,
gathered with nanuq.
"""

template islandsSlide* = # 4.10
  slide: islandsContent(nb)

when isMainModule: # this slide on its own: docs/slides_island3_islands.html
  buildDeckPart("island3_islands", "slides/island3_islands.nim"):
    islandsSlide
