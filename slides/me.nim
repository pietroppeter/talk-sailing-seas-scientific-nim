import nimib, nimiSlides
import ../my

# Opening

#> Claude: rename to about.nim and about.slides, make sure the content fits, if not clean up and move extra in speaker notes, add emojis,
#> add emphasis in appropriate places (e.g. AgileLab)
#> for emoji refs I liked the ones in my domain driven data science talk: https://github.com/pietroppeter/domain-driven-data-science

template meSlide* =
  placeholderSlide("0.2", "About me", """mathematician, data scientist at AgileLab, nimib maintainer, Python Milan and PyData Milan organizer; the Paris climate-dynamics years as a personal hook [tbd: which details Pietro wants on stage].""")
  nbText """ # about

me (Pietro Peterlongo)

- ~~Data Scientist~~ Delivery Manager @ AgileLab (since 2024)
- community organizer (Python Milan, PyData Milan)
- passionate about Nim (since 2018), open source "notebook" since 2020
- Applied Math Background (from Geosciences to Cryptography)
  - (unfinished) PhD in Paris (LMD, ENS)

AgileLab

- data consulting for Big Enterprises (e.g. Poste Italiane)
- ~350 people, ~2x growth in last 2-3 years
- public handbook, self management (holacracy), nomads (e.g 2 weeks in Canary Islands... or in Toulouse)
"""