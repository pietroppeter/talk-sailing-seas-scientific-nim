import nimib
import page # usePage, the style and the blocks
import islandnames

# The voyage map editor: the chart of the deck in the browser, to move
# the coast and the islands (the depths follow), set the anchors, the
# turning points of the course, the names, the rose and the portolano
# box, and copy the arrangement as json. The json is maps/voyage.json,
# which the deck reads when it is built (`layoutFromJson` in maps/isole.nim).
#   nim r mapeditor.nim
# writes docs/mapeditor.html. The editor is Nim compiled to JavaScript
# (maps/editor/app.nim): it draws the chart with the modules the deck
# uses (maps/geometry.nim, maps/isole.nim, maps/chart.nim).

const
  ownSource = staticRead("mapeditor.nim")
  sections = islands

nbInit(thisFileRel = "mapeditor.nim")
nb.usePage(ownSource, withReview = false)
nb.useMapEditorStyle
nb.title = "Voyage map editor"

nbText "# Voyage map editor"
nbLede """
The chart of the [slides](slides.html), to arrange by hand:
the deck reads what you copy here.
"""
nbText """
Drag an island to move it, its knobs to turn (↻) and scale (⤡) it;
the coast moves the same way. Double click a leg of the course to
add a turning point, and a turning point to remove it. Names,
anchors, the rose and the portolano box are dragged too. The depths
and the soundings follow the land. **Preview the slides** shows the
agenda bar, the portolano box and the course drawing itself, as in
the deck. **Copy JSON** and paste it in the chat: it becomes
`maps/voyage.json`, the map of the deck.
"""
nbMapEditor()
nbJsFromCode(sections):
  import ../maps/editor/app
  mapEditor(sections)
nbSave
