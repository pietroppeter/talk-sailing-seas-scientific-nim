import nimib, nimiSlides
import ../my

template titleSlide* =
  slide:
    themedTitle:
      nbText """
## Sailing Seas of Scientific Nim
"""
      nbLede("Nim is a programming language", "title-sub")
      nbText """
**Pietro Peterlongo, AgileLab**

*Compute Paris, Nov 2026*

"""
      reference "[github.com/pietroppeter/talk-sailing-seas-scientific-nim](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim) or [bit.ly/pietro-scinim](https://bit.ly/pietro-scinim)"
    speakerNote """
Hello everyone! I am really happy to be here in Paris
and to talk about something I am passionate about
and rarely get to talk about: Nim for scientific
computing. I do not work with Nim, and I do not work
directly on scientific computing, so thanks to Sylvain
and the other organizers for opening up the format
to talks like mine.

Hands up: who has heard of Nim before this talk?
Nim is a programming language.
Keep your hand up if you have written some Nim.
Keep it up if you have contributed to scientific Nim.
(Probably only Clonkk and Mamy.)

(No time to explain the voyage metaphor here: the
map speaks for itself.)
"""

when isMainModule: # this part of the deck on its own: docs/slides_title.html
  buildDeckPart("title", "slides/title.nim"):
    titleSlide
