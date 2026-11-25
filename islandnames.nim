## The names of the seven islands, in the order of the voyage: the one place to rename one.
## The deck's map slides and agenda bar (my.nim), the deep dives' labels (deepdive/deepdive.nim),
## the map editor (mapeditor.nim) and the map lab (maps/maplab.nim) read them from here.
## A rename also updates decisions/islands.md and outline.md.

const islands* = [
  "Accessible Performance",
  "Success Stories",
  "Data Stack",
  "Interoperability",
  "An Expressive Language",
  "Interactivity",
  "Notebook",
]

func islandLabel*(n: int): string =
  ## "Island 3 · Data Stack", for island `n` (1..7)
  "Island " & $n & " · " & islands[n - 1]
