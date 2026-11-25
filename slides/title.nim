import nimib, nimiSlides
import ../my

template titleSlide* =
  slide:
    themedTitle:
      nbText """
## Sailing Seas of Scientific Nim

**Pietro Peterlongo, AgileLab**

*Compute Paris, Nov 2026*

"""
      reference "[github.com/pietroppeter/talk-sailing-seas-scientific-nim](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim) or [bit.ly/pietro-scinim](https://bit.ly/pietro-scinim)"

when isMainModule: # this part of the deck on its own: docs/slides_title.html
  buildDeckPart("title", "slides/title.nim"):
    titleSlide
