## Builds the talk's pages in one program, one compile and one link instead of one per page.
## Use build.nim, which picks the groups and also builds the themed decks and runs the checks:
##
##   nim r build.nim                 # everything
##   nim r build.nim explainers      # one group (slides, explainers, devlog), see build.nim
##
## A single page still builds on its own: `nim r index.nim`, `nim r slides/island5_units_explainer.nim`.
##
## The pages that are scripts (explainers, the easter egg, talk log posts) render when their module
## is initialised, in import order; the decks are built by templates of index.nim, my.nim
## and slides/thank_you.nim, called below. Explainers and talk log posts are found at compile time, so a new one
## needs no change here. `-d:only=slides,devlog` builds only those groups (build.nim passes it).
## `-d:slideTheme=<theme>` builds only the deck, in that theme, as docs/index_<theme>.html.
import std / [macros, os, strutils, algorithm]
import nimib, nimiSlides # the decks expand here: what index.nim imports
import themes # themed, slideTheme
import my, index
import slides / thank_you

const only {.strdefine.} = "slides,explainers,devlog"

func wants(group: string): bool = group in only.split(',') and not themed

macro importPages(): untyped =
  ## import the pages that render when imported, by group, in the order they must be built
  let root = currentSourcePath().parentDir
  proc found(dir, suffix: string): seq[string] =
    for line in staticExec("ls " & quoteShell(root / dir)).splitLines:
      if line.endsWith(suffix) and line != "devlog.nim" and line != "index.nim":
        result.add dir / line[0 ..< ^4]
    result.sort
  var pages: seq[string]
  if wants("slides"): pages.add "slides/emilia"
  if wants("explainers"): pages.add found("slides", "_explainer.nim")
  if wants("devlog"):
    pages.add found("devlog", ".nim")
    pages.add "devlog/index" # last: it checks that every post was built
  var src = ""
  for i, p in pages:
    # absolute paths (parseStmt has no file to be relative to), and an alias, since names repeat (index)
    src.add "import \"" & root / p & "\" as page" & $i & "\n"
  result = parseStmt(src)

{.warning[UnusedImport]: off.}
importPages()

# each deck in a block of its own: every deck has its own `nb`
when themed:
  block: buildDeck() # the deck in one of the explored themes (see themes.nim)
elif wants("slides"):
  block: buildDeck()
  block: buildStyleDeck()
  block: buildThankYou()
