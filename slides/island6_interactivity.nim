import nimib, nimiSlides
import ../my

# Section 7: Island 6: Interactivity (see the latest outline in openspec)
# Nim compiles to JavaScript: a snappy port of a fun Shiny app. Carries K2 (JavaScript backend superpower).

template island6InteractivitySection* =
  slide:
    mapSlide(6) # 7.1
    placeholderSlide("7.2", "The original Shiny app", """what the app does and why it is fun [tbd: which app].""")
    placeholderSlide("7.3", "The Nim port", """the same app compiled to JavaScript, running in the browser [example].""")
    placeholderSlide("7.4", "Rocks ahead", """no REPL, so no Jupyter- or Marimo-style interactivity in Nim yet.""")
