## The talk log index (docs/devlog/index.html): the posts of devlog/devlog.nim, newest first.
## Build the posts first: the index refuses to build if a listed post was not built.
import std / [os, algorithm, json]
import nimib
import nimib / highlight
import devlog

nbInit(thisFileRel = "devlog/index.nim")
const ownSource = staticRead("index.nim")
nb.doc.source = ownSource
nb.doc.context["source"] = %ownSource
nb.doc.context["source_highlighted"] = %highlightNim(ownSource)
nb.title = "Talk log · Sailing Seas of Scientific Nim"
nbRawHtml "<style>\n" & devlogCss & "</style>"

# nimib runs from docs/ (see nimib.toml)
for p in devlogPosts:
  if not fileExists("devlog" / p.fileName):
    quit "devlog index: devlog/" & p.fileName & " is listed in devlog/devlog.nim but was not built"

nbText """
# Talk log

Notes on how the talk
[Sailing Seas of Scientific Nim](../index.html)
(Compute Paris, 26 November 2026) is made, newest first.
The repository holds three things:
the slides of the talk,
the [explainers](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim#readme)
that go deeper into the examples of the slides,
and this log, which tells how the talk evolves.
Everything is built in public, with nimib.
"""

var items = "<ol class=\"devlog-posts\">\n"
for p in devlogPosts.reversed:
  items.add "<li><time datetime=\"" & p.date & "\">" & longDate(p.date) & " · " & $p.kind & "</time>\n" &
    "<a href=\"" & p.fileName & "\">" & p.title & "</a>\n<p>" & p.summary & "</p></li>\n"
items.add "</ol>"
nbRawHtml items

nbSave
