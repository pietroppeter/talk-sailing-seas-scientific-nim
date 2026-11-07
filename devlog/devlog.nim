## The talk log: posts on how the talk evolves, oldest first.
## The deck (index.nim) is the talk, the explainers (slides/*_explainer.nim) go deeper
## into its examples, and the talk log tells how the talk got made.
##
## Adding a post: append an entry here, start the post with
##   nbInit(thisFileRel = "devlog/my_post.nim")
##   const ownSource = staticRead("my_post.nim")
##   nb.useDevlogPost("my-slug", ownSource)
## add it to the build in .github/workflows/pages.yml and to the list in README.md.
## Each post is written to docs/devlog/<date>-<slug>.html; `devlog/index.nim`
## (docs/devlog/index.html) lists them and checks they were all built.
import std / [json, os, strutils, times]
import nimib
import nimib / highlight

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

const devlogCss* = """
.devlog-eyebrow { font-size: 0.8em; letter-spacing: 0.08em; text-transform: uppercase; color: #6b7280; }
.devlog-eyebrow a { color: inherit; }
.devlog-summary { font-size: 1.15em; color: #374151; }
.devlog-nav { display: flex; justify-content: space-between; gap: 1em; border-top: 1px solid #ddd; margin-top: 3em; padding-top: 1em; font-size: 0.9em; }
.devlog-posts { list-style: none; padding: 0; }
.devlog-posts li { margin-bottom: 1.4em; }
.devlog-posts time { font-size: 0.8em; color: #6b7280; display: block; }
.devlog-posts a { font-size: 1.25em; font-weight: 600; }
.devlog-posts p { margin: 0.2em 0 0; }
pre { overflow-x: auto; }
figure { margin: 1em 0; }
figure img { width: 100%; border: 1px solid #ddd; }
figcaption { font-size: 0.85em; color: #6b7280; }
"""

proc useDevlogPost*(nb: var Nb, slug: string, ownSource: string) =
  ## title, dated file name, header and footer of the talk log post `slug`
  let i = findPost(slug)
  doAssert i >= 0, "devlog: add " & slug & " to devlog/devlog.nim"
  let p = devlogPosts[i]
  nb.title = p.title & " · talk log"
  nb.doc.filename = nb.doc.filename.parentDir / p.fileName
  # nimib cannot find a source outside the current directory: give "Show Source" its source
  nb.doc.source = ownSource
  nb.doc.context["source"] = %ownSource
  nb.doc.context["source_highlighted"] = %highlightNim(ownSource)
  nbRawHtml "<style>\n" & devlogCss & "</style>"
  nbRawHtml "<p class=\"devlog-eyebrow\"><a href=\"index.html\">Talk log</a> · " & longDate(p.date) &
    " · " & $p.kind & "</p>"
  nbText "# " & p.title
  nbRawHtml "<p class=\"devlog-summary\">" & p.summary & "</p>"

proc devlogFooter*(nb: var Nb, slug: string) =
  ## previous and next post, and the source of this one
  let i = findPost(slug)
  let p = devlogPosts[i]
  var html = "<nav class=\"devlog-nav\"><span>"
  if i > 0: html.add "← <a href=\"" & devlogPosts[i - 1].fileName & "\">" & devlogPosts[i - 1].title & "</a>"
  html.add "</span><span><a href=\"" & repoUrl & "/blob/main/" & p.source & "\">source</a></span><span>"
  if i < devlogPosts.high: html.add "<a href=\"" & devlogPosts[i + 1].fileName & "\">" & devlogPosts[i + 1].title & "</a> →"
  html.add "</span></nav>"
  nbRawHtml html
