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
"""
    speakerNote """
- Delivery Manager at AgileLab since 2024, before that
  Data Scientist.
- Applied math: started in geosciences, weather and climate
  dynamics, an (unfinished) PhD in Paris (LMD, ENS),
  later cryptography.
- Passionate about Nim since 2018; nimib, the open source
  "notebook" for Nim, since 2020 (this deck is made with it).
- AgileLab: data consulting for big enterprises
  (e.g. Poste Italiane), ~350 people, about 2x growth
  in the last 2-3 years; public handbook, self-management
  (holacracy).
- Nomads: e.g. 2 weeks in the Canary Islands... or in Toulouse.
"""

when isMainModule:
  myInit("about.nim")
  aboutSlide
  nbSave
