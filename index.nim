import nimib, nimiSlides
import my
import slides / [title, me, intro, island1_performance, island2_stories, island3_datastack, island4_expressive, island5_interop, island6_interactivity, island7_notebook, conclusion]

template presentation* =
  titleSlide
  meSlide
  introSection
  island1PerformanceSection
  island2StoriesSection
  island3DataStackSection
  island4ExpressiveSection
  island5InteropSection
  island6InteractivitySection
  island7NotebookSection
  conclusionSection

when isMainModule:
  myInit("index.nim")
  presentation
  nbSave
