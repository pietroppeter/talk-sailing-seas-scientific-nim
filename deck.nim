## The deck: the talk (docs/slides.html). `nim r deck.nim` builds it on its own.
import nimib, nimiSlides
import my
import slides / [title, me, intro, island1_performance, island2_stories, island3_datastack, island4_interop, island5_expressive, island6_interactivity, island7_notebook, conclusion, thank_you]
# exported, so the templates of the slides expand in all.nim too
export title, me, intro, island1_performance, island2_stories, island3_datastack, island4_interop, island5_expressive, island6_interactivity, island7_notebook, conclusion, thank_you

template presentation* =
  titleSlide
  meSlide
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
  when themed:
    nb.doc.filename = "slides_" & slideTheme & ".html"
  elif quartoLook: # -d:deckLook=quarto, see my.nim
    nb.doc.filename = "slides_quarto.html"
  else:
    nb.doc.filename = "slides.html"
  nbSave

when isMainModule:
  buildDeck()
