import nimib, nimiSlides
import tabelline
import ../my

# Section 1: Intro: leaving the mainland (see outline.md)
# Set up the voyage: many languages, each with its tradeoffs; this talk shows Nim's. Carries K1 and K4.
# 1.1 the sailing metaphor (islands, rocks ahead, deep dives), then a vertical stack:
# 1.2 the map, 1.3 the mainland (the languages and their price), 1.4 Nim's tradeoffs.

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
  (lang: "Rust", since: 2012, cameTo: "be fast and memory safe, no GC",
   price: "the borrow checker, long builds"),
  (lang: "Nim", since: 2008, cameTo: "be universal and minimal", price: "small"),
]

proc mainlandTable*(): Tabella =
  tabella(mainland, rownameCol = "lang")
    .fmtNumber("since", decimals = 0, useSeps = false)
    .colsLabel({"since": "since", "cameTo": "came to", "price": "the price"})
    .tabFootnote("Year of the first release; R grew out of S (1976), NumPy dates from 2006.",
      loc.columnLabels("since"))

template mainlandSlide* =
  slide: # 1.3
    nbText "## The mainland"
    nbText """
Each language came to solve a problem the previous ones
did not, and each one has a price.
"""
    nbTable mainlandTable().slideLook(fontSize = "0.55em").highlightRows(where(it["lang"] == "Nim"))
    speakerNote """
I love programming languages. I mostly used Python,
and very little of the others.
What matters here: every language comes with tradeoffs,
and an interesting language pushes you to do things
differently, which often gives back to the ecosystem.
Nim is a very interesting project.

At the end of the talk, you should have a sense of what Nim gives you and what it costs.
You might come back refreshed with a new perspective on programming languages.
"""

template tradeoffsSlide* =
  slide: # 1.4
    nbText "## Nim's tradeoffs"
    nbText """
General purpose, universal and minimal;
statically typed, compiled (to C, C++, JavaScript),
with a syntax like Python.
Imperative first, functional later, object oriented when needed.
"""
    compactColumns:
      column:
        nbText """
**You get**

- reads like Python, runs like C
- metaprogramming (macros), JavaScript, interop
- one language for scripting, libraries, applications
"""
      column:
        nbText """
**You pay**

- a compile step, no REPL (yet)
- a tiny ecosystem
- few people know it
"""
    reference "Andreas Rumpf, 2008 (as Nimrod), 1.0 in 2019, 2.0 in 2023; still evolving: Nimony / Nim 3.0 upcoming. [nim-lang.org](https://nim-lang.org)"
    speakerNote """
Not a tutorial: just enough to read the examples.
Nim is a general purpose language, not made for science,
statically typed and compiled; it reads like Python.
I still find it mind-bending: very universal, and minimal.
It reduces the cognitive load: it is easy to reason about,
easier than Python, because you can understand what is
going on (and I think AI appreciates that too).
Still evolving a lot: Nimony, the future Nim 3.0.
What you get and what you pay is the whole talk:
each island shows something on the left,
and most of them end with something on the right.
"""

template voyageSlide* =
  slide: # 1.1
    nbText "## ⛵️ The sailing metaphor"
    nbText """
A "niche" language is an exotic land.
From a sailing boat you do not actually "live" a place but
it is a quick and fun way to get a feeling for a place.
The place we want to visit is:

*how does Nim feel as a language for scientific computing?*

- 🏙️ **Mainland**: mainstream programming languages
- 🏝️ **Seven islands**: topics for scientific computing
- 🪨 **Rocks ahead**: weak points and limitations
- 🐋 **Deep dives**: longer explainers (unpolished)
"""
    reference "The slides, the deep dives and their code: [the talk's site](index.html)"
    speakerNote """
I picked a sailing metaphor because a niche language is
an exotic land, and from a boat we stay far off and never
really touch land on many things.
We will not go deep anywhere: thirty minutes, seven islands.
Each island is a theme where Nim shows its powers.
I will not hide where Nim falls short: most islands end with rocks ahead.
For those who want to land, each code-heavy slide has a deep dive,
a page with more code and the sources, built like these slides.
Honestly: the deep dives are mostly AI generated and unpolished,
and I have not read the latest version of all of them;
I still think they should be there.
Everything is on the site, linked from the first slide.
"""

template introSection* =
  voyageSlide # 1.1
  slide:
    mapSlide(0) # 1.2
    mainlandSlide # 1.3
    tradeoffsSlide # 1.4

when isMainModule: # this part of the deck on its own: docs/slides_intro.html
  buildDeckPart("intro", "slides/intro.nim"):
    introSection
