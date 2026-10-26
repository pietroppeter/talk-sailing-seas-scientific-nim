import nimib, nimiSlides
import my
import slides / [title, me, intro, island1_performance, island2_stories, island3_datastack, island4_expressive, island5_interop, island6_interactivity, island7_notebook, conclusion, thank_you]

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
  thankYouSlide # 9.6, on the top row after the conclusion

when isMainModule:
  myInit("index.nim")
  presentation
  nbSave
