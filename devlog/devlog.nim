## The talk log: posts on how the talk evolves, oldest first.
## The deck (index.nim) is the talk, the explainers (slides/*_explainer.nim) go deeper
## into its examples, and the talk log tells how the talk got made.
##
## Adding a post: append an entry here, start the post with
##   nbInit(thisFileRel = "devlog/my_post.nim")
##   const ownSource = staticRead("my_post.nim")
##   nb.useDevlogPost("my-slug", ownSource)
## and add it to the list in README.md (`nim r build.nim devlog` finds and builds it).
## Each post is written to docs/devlog/<date>-<slug>.html; `devlog/index.nim`
## (docs/devlog/index.html) lists them and checks they were all built.
import std / [json, os, strutils, times]
import nimib
import ../page # usePage, and the blocks of blocks.nim
export page

type
  PostKind* = enum
    Retrospective = "Retrospective"
    Research = "Research"

  DevlogPost* = object
    slug*: string
    date*: string     ## yyyy-MM-dd
    title*: string
    kind*: PostKind
    source*: string   ## path of the nimib source, from the repo root
    summary*: string  ## one line, for the index

const devlogPosts* = @[
  DevlogPost(slug: "setting-sail", date: "2026-11-07", kind: Retrospective,
    title: "Setting sail", source: "devlog/setting_sail.nim",
    summary: "How the talk got from an accepted abstract to a deck with seven islands: the tools, the outline, the explainers and the first islands."),
  DevlogPost(slug: "dressing-the-voyage", date: "2026-11-07", kind: Research,
    title: "Dressing the voyage", source: "devlog/dressing_the_voyage.nim",
    summary: "What Ines Montani teaches about slides, and three themes tried on real slides: a pirate adventure game, an old book of sea tales, a nautical chart."),
  DevlogPost(slug: "drawing-the-map", date: "2026-11-07", kind: Research,
    title: "Drawing the map", source: "devlog/drawing_the_map.nim",
    summary: "One geometry for the map of the voyage, drawn by code as pixel art, as a nautical chart and as a hand-drawn chart of the 19th century."),
]

const repoUrl* = "https://github.com/pietroppeter/talk-sailing-seas-scientific-nim"

func fileName*(p: DevlogPost): string = p.date & "-" & p.slug & ".html"

func findPost*(slug: string): int =
  for i, p in devlogPosts:
    if p.slug == slug: return i
  -1

func longDate*(date: string): string =
  {.cast(noSideEffect).}:
    parse(date, "yyyy-MM-dd").format("d MMMM yyyy")

proc useDevlogPost*(nb: var Nb, slug: string, ownSource: string) =
  ## title, dated file name, header and footer of the talk log post `slug`
  let i = findPost(slug)
  doAssert i >= 0, "devlog: add " & slug & " to devlog/devlog.nim"
  let p = devlogPosts[i]
  nb.usePage(ownSource)
  nb.title = p.title & " · talk log"
  nb.doc.filename = nb.doc.filename.parentDir / p.fileName
  nbEyebrow "[Talk log](index.html) · " & longDate(p.date) & " · " & $p.kind
  nbText "# " & p.title
  nbLede p.summary

proc devlogFooter*(nb: var Nb, slug: string) =
  ## previous and next post, and the source of this one
  let i = findPost(slug)
  let p = devlogPosts[i]
  let
    prev = if i > 0: PageLink(url: devlogPosts[i - 1].fileName, title: devlogPosts[i - 1].title) else: PageLink()
    next = if i < devlogPosts.high: PageLink(url: devlogPosts[i + 1].fileName, title: devlogPosts[i + 1].title) else: PageLink()
  nbPager(prev, PageLink(url: repoUrl & "/blob/main/" & p.source, title: "source"), next)
