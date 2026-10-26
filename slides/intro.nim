import nimib, nimiSlides
import ../my

# Section 1: Intro: leaving the mainland (see the latest outline in openspec)
# Set up the voyage: many languages, each with its tradeoffs; this talk shows Nim's. Carries K1 and K4.

template introSection* =
  slide:
    placeholderSlide("1.1", "The mainland", """a map of scientific computing languages over time: Fortran, C, C++, R, Python, Julia.""")
    placeholderSlide("1.2", "Why so many languages?", """each language came to solve a problem the previous ones did not; the two-language problem as the classic example.""")
    placeholderSlide("1.3", "Nim's tradeoffs", """the abstract's question "is there space for one more?" reframed: this talk is about Nim's specific tradeoffs, seven islands, and we won't hide where Nim falls short.""")
    mapSlide(0) # 1.4
