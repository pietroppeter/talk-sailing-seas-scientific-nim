import nimib
import nimiSlides except speakerNote # blogpost.nim has its own (my.nim exports it)
import ../my

template titleSlide* =
  slide:
   slide:
    themedTitle:
      nbText """
## Sailing Seas of Scientific Nim
"""
      nbLede("(Nim is a programming language)", "title-sub")
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
"""
    afterTheTalk """
Very few people in the room knew about Nim
(how many were we? 20 to 40 is my guess,
I was too nervous to count), and indeed
only Mamy and Clonkk had written any Nim.
"""
   slide: # below the title: the QR code to the slides, for phones
    nbQr("https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/slides.html", "slides",
      [("bit.ly/pietro-scinim", "https://bit.ly/pietro-scinim"),
       ("github.com/pietroppeter/talk-sailing-seas-scientific-nim",
        "https://github.com/pietroppeter/talk-sailing-seas-scientific-nim")])
    afterTheTalk """
In that room the screen had been switching off
at random, so I prepared a big QR code and asked
everyone to open the slides on their phone.
Luckily I was spared any interruption.
"""

when isMainModule: # this part of the deck on its own: docs/slides_title.html
  buildDeckPart("title", "slides/title.nim"):
    titleSlide
