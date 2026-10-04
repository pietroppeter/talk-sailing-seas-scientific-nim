import nimib, nimiSlides
import my
import slides / title

template presentation* =
  titleSlide

when isMainModule:
  myInit("index.nim")
  presentation
  nbSave
