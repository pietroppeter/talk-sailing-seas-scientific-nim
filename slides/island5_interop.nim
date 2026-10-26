import nimib, nimiSlides
import ../my

# Section 6: Island 5: Interoperability (see the latest outline in openspec)
# Nim is easy to combine with other languages, in both directions. Carries K2 (interop superpower) and K3.

template island5InteropSection* =
  mapSlide(5) # 6.1
  placeholderSlide("6.2", "Wrapping C and C++", """calling an existing C library from Nim in a few lines [tbd: library].""")
  placeholderSlide("6.3", "Bridges", """two-way bridges to Python, R and Julia, with an honest maturity rating for each [tbd: which libraries].""")
  placeholderSlide("6.4", "Nim from Python", """a Nim function imported and called from Python, "almost like Rust" [example] [tbd: example].""")
  placeholderSlide("6.5", "Rocks ahead", """packaging and distribution of Nim extensions [tbd].""")
