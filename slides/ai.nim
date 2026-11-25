import nimib, nimiSlides
import ../my

# Opening, slide 0.3: AI, one slide right after about me (a placeholder, content to decide)

template aiSlide* =
  placeholderSlide("0.3", "AI", """
One slide on AI, right after about me: content to decide.
""")

when isMainModule: # this part of the deck on its own: docs/slides_ai.html
  buildDeckPart("ai", "slides/ai.nim"):
    aiSlide
