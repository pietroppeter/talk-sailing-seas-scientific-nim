import nimib, nimiSlides
import ../my

# Opening, slide 0.2: about me (not part of the intro section, like the title slide)

template aboutSlide* =
  slide:
    nbText """
## 👋 About me

*Pietro Peterlongo* 🇮🇹⛰️⛵️

- 🧑‍💼 ~~Data Scientist~~ **Delivery Manager** @ **AgileLab**
- 💙🧡 Organizer: Python Milan, PyData Milan
- 👑 *Nim* since 2018, 📓 *nimib* "notebook" since 2020
- 🧮 *Applied math*: geosciences 🌍 to cryptography 🔐

## 🔵⚪️ About AgileLab?

- 🏢 Data consulting, 📈 ~350 people (2x in 3 years)
- 📖 [Public handbook](https://handbook.agilelab.it/), 🌀 holacracy, 🏄 nomads
- 💚 Friendly to open source, 🎤 conferences (budget!)
- 🎂 Founded 12 years ago, 📮 now part of Poste Italiane
"""
    speakerNote """
So who am I? I work at AgileLab, and I am a manager:
I have not written code in about a year. Well, nobody
codes anymore, everybody is becoming a manager of agents.

In my spare time I help organize Python Milan and
PyData Milan, a bit less lately.

I have been passionate about Nim since I ran into it on
Hacker News in 2018, and it is what pushed me into open
source: I made a "notebook" for Nim, nimib, which this
deck is built with.

My background is applied math, and I did many things
with it. One reason I am happy to give this talk here:
I spent two years in Paris not finishing a PhD in
geosciences (LMD, ENS).

Happy to tell you about AgileLab later.
"""

when isMainModule: # this part of the deck on its own: docs/slides_about.html
  buildDeckPart("about", "slides/about.nim"):
    aboutSlide
