import nimib, nimiSlides
import tabelline
import ../my

# Section 1: Intro: leaving the mainland (see outline.md)
# Set up the voyage: many languages, each with its tradeoffs; this talk shows Nim's. Carries K1 and K4.
# 1.1 the mainland (the languages and their price), 1.2 Nim's tradeoffs, 1.3 how the voyage
# works (islands, rocks ahead, deep dives), 1.4 the map.

type Language* = tuple[lang: string, since: int, cameTo: string, price: string]

const mainland*: seq[Language] = @[
  (lang: "Fortran", since: 1957, cameTo: "turn formulas into fast code",
   price: "great on arrays, hard for the rest"),
  (lang: "C", since: 1972, cameTo: "be portable and close to the machine",
   price: "memory by hand"),
  (lang: "C++", since: 1985, cameTo: "add abstractions at no runtime cost",
   price: "complexity, long builds"),
  (lang: "Python", since: 1991, cameTo: "be easy, general, the glue",
   price: "slow loops: the fast part in C"),
  (lang: "R", since: 1993, cameTo: "do statistics interactively",
   price: "slow loops, odd beyond statistics"),
  (lang: "Julia", since: 2012, cameTo: "be easy and fast, for science",
   price: "compile latency, mostly science"),
  (lang: "Nim", since: 2008, cameTo: "?", price: "this talk"),
]

proc mainlandTable*(): Tabella =
  tabella(mainland, rownameCol = "lang")
    .fmtNumber("since", decimals = 0, useSeps = false)
    .colsLabel({"since": "since", "cameTo": "came to", "price": "the price"})

template mainlandSlide* =
  slide: # 1.1
    nbText "## The mainland"
    nbText """
Each language came to solve a problem the previous ones
did not, and each one has a price.
"""
    nbTable mainlandTable().slideLook(fontSize = "0.55em").highlightRows(where(it["lang"] == "Nim"))
    reference "Years of the first release; R grew out of S (1976), NumPy dates from 2006."
    speakerNote """
Scientific computing started with Fortran and never left it:
LAPACK and most climate models are still Fortran.
C and C++ came for the machine and for abstractions; R for statistics.
Python became the glue: easy to write, but loops are slow,
so the fast part is written in C or Fortran. Two languages:
the two-language problem, the reason Julia was made.
Every one of them pays a price for what it gives you.
Nim is older than Julia, and still niche.
Is there space for one more? This talk shows Nim's price.
"""

template tradeoffsSlide* =
  slide: # 1.2
    nbText "## Nim's tradeoffs"
    nbText """
*Nim*: general purpose, statically typed, compiled
(to C, C++ and JavaScript), with a syntax that reads like Python.
"""
    columns:
      column:
        nbText """
**You get**

- reads like Python, runs like C
- macros, JavaScript, interop
- one language, script to library
"""
      column:
        nbText """
**You pay**

- a compile step, no REPL
- a tiny ecosystem
- few people know it
"""
    reference "Andreas Rumpf, 2008 (as Nimrod); 1.0 in 2019, 2.0 in 2023. [nim-lang.org](https://nim-lang.org)"
    speakerNote """
Not a tutorial: just enough to read the examples.
Nim is a general purpose language, not made for science,
statically typed and compiled; it reads like Python.
What you get and what you pay is the whole talk:
each island shows something on the left,
and most of them end with something on the right.
"""

template voyageSlide* =
  slide: # 1.3
    nbText "## The voyage"
    nbText """
A niche language is an exotic land, and from a boat
you only see the coast: the feeling of each place, not a tour.

- 🏝️ **Seven islands**: themes where *Nim* shows its powers
- 🪨 **Rocks ahead**: where *Nim* falls short
- 🐋 **Deep dives**: a page for what a slide only sketches
"""
    reference "The slides, the deep dives and their code: [the talk's site](index.html)"
    speakerNote """
We will not go deep anywhere: thirty minutes, seven islands.
Each island is a theme where Nim shows its powers.
I will not hide where Nim falls short: most islands end with rocks ahead.
For those who want to land, each code-heavy slide has a deep dive,
a page with more code and the sources, built like these slides.
Everything is on the site, linked from the first slide.
"""

template introSection* =
  slide:
    mainlandSlide # 1.1
    tradeoffsSlide # 1.2
    voyageSlide # 1.3
    mapSlide(0) # 1.4

when isMainModule: # this part of the deck on its own: docs/slides_intro.html
  buildDeckPart("intro", "slides/intro.nim"):
    introSection
