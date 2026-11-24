## The deep dives index (docs/deepdive/index.html): the pages of deepdive/deepdive.nim, in talk order.
## Build the deep dives first: the index refuses to build if a listed page was not built.
import std / [os, json]
import nimib
import deepdive

nbInit(thisFileRel = "deepdive/index.nim")
const ownSource = staticRead("index.nim")
nb.usePage(ownSource)
nb.title = "Deep dives · Sailing Seas of Scientific Nim"

# nimib runs from docs/ (see nimib.toml)
for d in deepDives:
  if not fileExists("deepdive" / d.fileName):
    quit "deep dives index: deepdive/" & d.fileName & " is listed in deepdive/deepdive.nim but was not built"

nbEyebrow "[Sailing Seas of Scientific Nim](../index.html)"
nbText """
# Deep dives

A slide has room for little:
a name, a picture, a few lines of code.
These pages take the time the talk
[Sailing Seas of Scientific Nim](../slides.html)
does not have, for the topics it only sketches.
Each one is linked from its slide,
and its code runs when the page is built.
"""

var items: seq[PageItem]
for d in deepDives:
  items.add PageItem(url: d.fileName, title: d.title, eyebrow: d.section, summary: d.summary)
nbPageList items

nbSave
