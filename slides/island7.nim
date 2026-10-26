import nimib, nimiSlides
import ../my

# Section 8: Island 7: Notebook (draft outline, see openspec/changes/draft-outline/outline.md)
# The literate computing paradigm Jupyter made central, and a Nim option that goes in an unexpected direction. Carries K2 and K3.

template island7Section* =
  mapSlide(7) # 8.1
  placeholderSlide("8.2", "Literate computing", """from Knuth to Jupyter: why notebooks matter in science.""")
  placeholderSlide("8.3", "nimib", """a notebook that is a plain Nim program producing html; this very deck is made with it.""")
  placeholderSlide("8.4", "Rocks ahead", """honest trade-offs of the nimib approach compared to Jupyter.""")
