## The site index (docs/index.html): everything the talk publishes,
## the slides, the deep dives (deepdive/deepdive.nim) and the talk log (devlog/devlog.nim).
## The deck itself is deck.nim (docs/slides.html).
import std / [json, algorithm]
import nimib
import deepdive / deepdive, devlog / devlog

nbInit(thisFileRel = "index.nim")
const ownSource = staticRead("index.nim")
nb.usePage(ownSource)
nb.title = "Sailing Seas of Scientific Nim"

nbEyebrow "Compute Paris · 26 November 2026"
nbText """
# Sailing Seas of Scientific Nim

A talk by Pietro Peterlongo
([@pietroppeter](https://github.com/pietroppeter))
at [Compute Paris 2026](https://pretalx.com/compute-paris-2026/talk/8EM8ZA/),
on what Nim offers to scientific computing.
Everything here is built in public with
[nimib](https://github.com/pietroppeter/nimib),
from [the repository](""" & repoUrl & """).
"""

nbText "## Slides"
var slides = @[
  PageItem(url: "slides.html", title: "The talk", eyebrow: "Slides",
    summary: "The deck, seven islands of scientific Nim."),
]
# the themes explored in the talk log (themes.nim, built by `nim r build.nim themes`)
for (name, look) in [("pirate", "a pirate adventure game"), ("book", "an old book of sea tales"), ("chart", "a nautical chart")]:
  slides.add PageItem(url: "slides_" & name & ".html", title: "The talk, " & name & " theme", eyebrow: "Slides · theme explored",
    summary: "The deck dressed as " & look & " ([how](devlog/2026-11-07-dressing-the-voyage.html)).")
slides.add PageItem(url: "slides_centered.html", title: "The talk, centered look", eyebrow: "Slides · earlier look",
  summary: "The deck before it took Quarto's proportions: centered, larger text ([style test deck](my_centered.html)).")
slides.add PageItem(url: "thank_you.html", title: "Thank you", eyebrow: "Slide",
  summary: "The last slide on its own: a p5nim animation.")
slides.add PageItem(url: "my.html", title: "Style test deck", eyebrow: "Slides · tooling",
  summary: "The layouts and blocks of the slides, one per slide.")
nbPageList slides

nbText """
## Deep dives

For the topics the slides only sketch
([all of them](deepdive/index.html)).
"""
var dives: seq[PageItem]
for d in deepDives:
  dives.add PageItem(url: "deepdive/" & d.fileName, title: d.title, eyebrow: d.section, summary: d.summary)
nbPageList dives

nbText """
## Talk log

How the talk is made, newest first
([the log](devlog/index.html)).
"""
var posts: seq[PageItem]
for p in devlogPosts.reversed:
  posts.add PageItem(url: "devlog/" & p.fileName, title: p.title, eyebrow: longDate(p.date) & " · " & $p.kind, summary: p.summary)
nbPageList posts

nbSave
