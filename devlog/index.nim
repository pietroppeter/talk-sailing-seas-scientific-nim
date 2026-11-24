## The talk log index (docs/devlog/index.html): the posts of devlog/devlog.nim, newest first.
## Build the posts first: the index refuses to build if a listed post was not built.
import std / [os, algorithm, json]
import nimib
import devlog

nbInit(thisFileRel = "devlog/index.nim")
const ownSource = staticRead("index.nim")
nb.usePage(ownSource)
nb.title = "Talk log · Sailing Seas of Scientific Nim"

# nimib runs from docs/ (see nimib.toml)
for p in devlogPosts:
  if not fileExists("devlog" / p.fileName):
    quit "devlog index: devlog/" & p.fileName & " is listed in devlog/devlog.nim but was not built"

nbText """
# Talk log

Notes on how the talk
[Sailing Seas of Scientific Nim](../slides.html)
(Compute Paris, 26 November 2026) is made, newest first.
The [site](../index.html) holds three things:
the slides of the talk,
the [deep dives](../deepdive/index.html)
that go deeper into what the slides only sketch,
and this log, which tells how the talk evolves.
Everything is built in public, with nimib.
"""

var items: seq[PageItem]
for p in devlogPosts.reversed:
  items.add PageItem(url: p.fileName, title: p.title, eyebrow: longDate(p.date) & " · " & $p.kind, summary: p.summary)
nbPageList items

nbSave
