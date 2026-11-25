## The deck: the talk (docs/slides.html). `nim r deck.nim` builds it on its own.
import nimib, nimiSlides
import my
import slides / [title, about, intro, island1_performance, island2_stories, island3_datastack, island4_interop, island5_expressive, island6_interactivity, island7_notebook, conclusion, thank_you]
# exported, so the templates of the slides expand in all.nim too
export title, about, intro, island1_performance, island2_stories, island3_datastack, island4_interop, island5_expressive, island6_interactivity, island7_notebook, conclusion, thank_you

# deckSection (in my.nim, -d:deckSection=island1) builds one part of the deck on its own, in the deck's
# look, into docs/slides_<deckSection>.html, to review or share it without the whole talk:
# `nim r build.nim island1`. One of `deckSections` (checked by build.nim); empty: the whole deck
const deckSections* = ["title", "about", "intro", "island1", "island2", "island3", "island4",
                   "island5", "island6", "island7", "conclusion", "thank_you"]
func deckWants*(name: string): bool = deckSection == "" or deckSection == name

template presentation* =
  when deckWants("title"): titleSlide
  when deckWants("about"): aboutSlide
  when deckWants("intro"): introSection
  when deckWants("island1"): island1PerformanceSection
  when deckWants("island2"): island2StoriesSection
  when deckWants("island3"): island3DataStackSection
  when deckWants("island4"): island4InteropSection
  when deckWants("island5"): island5ExpressiveSection
  when deckWants("island6"): island6InteractivitySection
  when deckWants("island7"): island7NotebookSection
  when deckWants("conclusion"): conclusionSection
  when deckWants("thank_you"): thankYouSlide # 9.6, on the top row after the conclusion

template buildDeck*() =
  ## docs/slides.html, or docs/slides_<theme>.html with -d:slideTheme (see themes.nim);
  ## docs/index.html is the site index (index.nim)
  myInit("deck.nim")
  presentation
  when deckSection != "":
    nb.doc.filename = "slides_" & deckSection & ".html"
  elif sideTheme:
    nb.doc.filename = "slides_" & slideTheme & ".html"
  elif sideLook: # -d:deckLook=centered, see my.nim
    nb.doc.filename = "slides_" & deckLook & ".html"
  else:
    nb.doc.filename = "slides.html"
  nbSave

when isMainModule:
  buildDeck()
