## A lab for the voyage map: every chart of the voyage (0 the whole map, 1..7 the islands,
## 8 back on land) on one page, without building the deck: `nim r maps/maplab.nim`
## writes docs/maplab.html (not linked from the site; publish it to review a change of the map).
import std / [os, strutils]
import chart, isole
import ../islandnames

const names = islands

when isMainModule:
  let docs = currentSourcePath().parentDir.parentDir / "docs"
  let v = islandsVoyage()
  let showAll = paramCount() == 0 # `nim r maps/maplab.nim overview`: only the overview of each arrangement
  var page = "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width\">" &
    "<title>The voyage map, all charts</title><link rel=\"stylesheet\" href=\"assets/fonts/fonts.css\">" &
    "<style>body{margin:0;padding:12px;background:#f6f3ea;font-family:'Space Grotesk',sans-serif;color:#13334c}" &
    "h1{font-size:20px;margin:8px 0 12px} svg{width:100%;max-width:1200px;height:auto;display:block;margin:0 auto 18px}" &
    chartMapCss & "</style></head><body><h1>The voyage map: three arrangements, then every chart of the first</h1>"
  for l in layouts:
    page.add "<h1>Arrangement: " & l.name & "</h1>\n" & chartMap(layoutVoyage(l), names, 0, "lay-" & l.name, html = true) & "\n"
  if showAll:
    page.add "<h1>Every chart of the first arrangement</h1>"
    for current in 1 .. 8:
      page.add chartMap(v, names, current, "lab" & $current, html = true) & "\n"
  page.add "</body></html>"
  writeFile(docs / "maplab.html", page)
  echo "wrote ", docs / "maplab.html"
