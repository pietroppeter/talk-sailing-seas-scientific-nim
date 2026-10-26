import nimib, nimiSlides
import my
import slides / [title, intro, island1, island2, island3, island4, island5, island6, island7, conclusion]

template presentation* =
  titleSlide
  introSection
  island1Section
  island2Section
  island3Section
  island4Section
  island5Section
  island6Section
  island7Section
  conclusionSection

when isMainModule:
  myInit("index.nim")
  presentation
  nbSave
