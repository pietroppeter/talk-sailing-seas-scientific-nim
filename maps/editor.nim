## The map editor: the voyage map in the browser, to move the coast and the islands, set the
## anchors, the turning points of the course and the names, and export the arrangement as json.
## `nim r maps/editor.nim` writes docs/mapeditor.html (not linked from the site, like the map lab).
## The page draws the chart in javascript (maps/editor/editor.js), the same way maps/chart.nim does,
## from the same data: the coast of Istria, the outlines of the islands and maps/voyage.json, the
## arrangement of the deck. Its export replaces maps/voyage.json: the deck reads it at build time
## (`layoutFromJson` in maps/isole.nim).
import std / [os, json, strutils, tables]
import chart, isole

const names = ["Accessible Performance", "Success Stories", "Data Stack", "Interoperability",
  "An Expressive Language", "Interactivity", "Notebook"]

proc islandData(name: string): JsonNode =
  let isl = isole[name]
  var xs, ys: seq[float]
  for p in isl.outline: xs.add p.x; ys.add p.y
  %*{"name": name, "elevation": isl.elevation, "clon": isl.clon, "clat": isl.clat, "x": xs, "y": ys}

when isMainModule:
  let here = currentSourcePath().parentDir
  let docs = here.parentDir / "docs"
  var islands = newJObject()
  var picks = newJArray()
  for (name, port, lore) in islandPicks:
    islands[name] = islandData(name)
    picks.add %*{"real": name, "port": [port[0], port[1]], "lore": lore}
  for name in ["La Maddalena"]: islands[name] = islandData(name)
  var coast = newJArray()
  for p in triesteGulf: coast.add %*[p.x, p.y]
  let data = %*{"names": names, "picks": picks, "islands": islands, "coast": coast, "triesteAt": triesteAt,
    "muggia": muggia, "defaults": parseJson(voyageJson)}
  let page = readFile(here / "editor" / "editor.html")
    .replace("/*CHART_CSS*/", chartMapCss)
    .replace("/*EDITOR_CSS*/", readFile(here / "editor" / "editor.css"))
    .replace("/*DATA*/", "const DATA = " & $data & ";")
    .replace("/*EDITOR_JS*/", readFile(here / "editor" / "editor.js"))
  writeFile(docs / "mapeditor.html", page)
  echo "wrote ", docs / "mapeditor.html"
