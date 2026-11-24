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
  ## docs/index.html, or docs/index_<theme>.html with -d:slideTheme (see themes.nim)
  myInit("index.nim")
  presentation
  when themed:
    nb.doc.filename = "index_" & slideTheme & ".html"
  nbSave

when isMainModule:
  buildDeck()
