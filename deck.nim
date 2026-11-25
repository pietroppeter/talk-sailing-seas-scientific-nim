## The deck: the talk (docs/slides.html). `nim r deck.nim` builds it on its own.
##
## Every slide is a template, and every module of slides/ has a template that lists its slides
## in order (`introSection`, ...): reorder slides there, reorder sections here.
## Each module also builds its part on its own with `when isMainModule`
## (`nim r slides/intro.nim`, or `nim r build.nim intro`: docs/slides_intro.html).
import nimib, nimiSlides
import my
import slides / [title, about, ai, intro, island1_performance, island2_stories, island3_datastack, island4_interop, island5_expressive, island6_interactivity, island7_notebook, conclusion, thank_you]
# exported, so the templates of the slides expand in all.nim too
export title, about, ai, intro, island1_performance, island2_stories, island3_datastack, island4_interop, island5_expressive, island6_interactivity, island7_notebook, conclusion, thank_you

template presentation* =
  titleSlide
  aboutSlide
  aiSlide
  introSection
  island1PerformanceSection
  island2StoriesSection
  island3DataStackSection
  island4InteropSection
  island5ExpressiveSection
  island6InteractivitySection
  island7NotebookSection
  conclusionSection
  thankYouSlide # 9.6, on the top row after the conclusion

template buildDeck*() =
  ## docs/slides.html, or docs/slides_<theme>.html with -d:slideTheme (see themes.nim);
  ## docs/index.html is the site index (index.nim)
  myInit("deck.nim")
  presentation
  when sideTheme:
    nb.doc.filename = "slides_" & slideTheme & ".html"
  elif sideLook: # -d:deckLook=centered, see my.nim
    nb.doc.filename = "slides_" & deckLook & ".html"
  else:
    nb.doc.filename = "slides.html"
  nbSave

when isMainModule:
  buildDeck()
