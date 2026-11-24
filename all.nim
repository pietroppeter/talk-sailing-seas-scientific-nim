## Builds the talk's pages in one program, one compile and one link instead of one per page.
## Use build.nim, which picks the groups and also builds the themed decks and runs the checks:
##
##   nim r build.nim                 # everything
##   nim r build.nim deepdives       # one group (slides, deepdives, devlog), see build.nim
##
## A single page still builds on its own: `nim r deck.nim`, `nim r deepdive/units_macros.nim`.
##
## The pages that are scripts (deep dives, the easter egg, talk log posts, the indexes) render when
## their module is initialised, in import order; the decks are built by templates of deck.nim, my.nim
## and slides/thank_you.nim, called below. Deep dives and talk log posts are found at compile time, so a
## new one needs no change here. `-d:only=slides,devlog` builds only those groups (build.nim passes it);
## the site index (index.nim) is built with any group.
## `-d:slideTheme=<theme>` builds only the deck, in that theme, as docs/slides_<theme>.html;
## `-d:deckLook=quarto` only the deck and the style test deck in Quarto's look (slides_quarto.html, my_quarto.html).
import std / [macros, os, strutils, algorithm]
import nimib, nimiSlides # the decks expand here: what deck.nim imports
import themes # themed, slideTheme
import my, deck
import slides / thank_you

const only {.strdefine.} = "slides,deepdives,devlog"

func wants(group: string): bool = group in only.split(',') and not themed and not quartoLook

macro importPages(): untyped =
  ## import the pages that render when imported, by group, in the order they must be built
  let root = currentSourcePath().parentDir
  proc found(dir, suffix: string): seq[string] =
    for line in staticExec("ls " & quoteShell(root / dir)).splitLines:
      if line.endsWith(suffix) and line notin ["devlog.nim", "deepdive.nim", "index.nim"]:
        result.add dir / line[0 ..< ^4]
    result.sort
  var pages: seq[string]
  if wants("slides"): pages.add "slides/emilia"
  if wants("deepdives"):
    pages.add found("deepdive", ".nim")
    pages.add "deepdive/index" # last: it checks that every deep dive was built
  if wants("devlog"):
    pages.add found("devlog", ".nim")
    pages.add "devlog/index" # last: it checks that every post was built
  if pages.len > 0: pages.add "index" # the site index, which lists all of them
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
elif quartoLook:
  block: buildDeck() # the deck in Quarto's proportions (docs/slides_quarto.html, see my.nim)
  block: buildStyleDeck() # docs/my_quarto.html
elif wants("slides"):
  block: buildDeck()
  block: buildStyleDeck()
  block: buildThankYou()
