import nimib, nimiSlides
import tabelline
import ../my

# Section 9: Conclusion: back on land (see outline.md)
# Takeaways and an opinionated reflection on why Nim is still niche. Carries K1, K3 and K4.

# the tables of slides 9.4 and 9.5, made in procs and not in the templates below,
# so that tabelline's names stay out of the deck's templates (as in island3_datastack.nim)
proc seenFromNimTable*(): Tabella =
  let views = @[
    (lang: "Python", notice: "loops are slow, so you think in arrays; in Nim a for loop is fine (Island 1)"),
    (lang: "R", notice: "dplyr's formulas are metaprogramming: Datamancer's `f{...}` is the same idea (Island 3)"),
    (lang: "Julia", notice: "the JIT gives you a REPL and costs a warm-up; Nim compiles ahead of time: no warm-up, no REPL (Island 6)"),
    (lang: "C, C++", notice: "the same machine code with less ceremony; macros instead of templates and the preprocessor (Island 5)")]
  tabella(views, rownameCol = "lang")
    .colsLabel({"notice": "Nim makes you notice"})
    .fmtMarkdown("notice")
    .slideLook(fontSize = "0.7em")

proc nicheTable*(): Tabella =
  let views = @[
    (area: "Language", view: "stable: 1.0 in 2019, 2.0 in 2023, ready for more than it is used for"),
    (area: "Ecosystem", view: "small: libraries depend on a few people, users wait for libraries"),
    (area: "Community", view: "friendly and small: one person can make a difference"),
    (area: "Governance", view: "**the main shortcoming**: few people decide, the direction is hard to read from outside"),
    (area: "Tooling", view: "editor support and compile times behind Rust's; Nimony and NIF are the way to catch up")]
  tabella(views, rownameCol = "area")
    .colsLabel({"view": "My view"})
    .fmtMarkdown("view")
    .highlightRows(@[3])
    .slideLook(fontSize = "0.7em")

template beginnerSlide* =
  slide: # 9.2
    nbText "## For the beginner"
    nbLede """
Try it: accessible, fun, and a mirror
for your own language
"""
    nbText """
- reads like Python, a compiler that checks your types
- where to start: [the playground](https://play.nim-lang.org),
  [Nim for Python programmers](https://github.com/nim-lang/Nim/wiki/Nim-for-Python-Programmers),
  [Exercism](https://exercism.org/tracks/nim),
  [SciNim getting started](https://scinim.github.io/getting-started/)
- a first project: an Advent of Code puzzle, a small CLI, a nimib page
"""
    speakerNote """
If you are new to scientific computing, or just curious:
Nim is a good second language. It reads like Python,
and the compiler teaches you what types and compilation are about.
At the very least, a learning tool: it shows you
the tradeoffs of the language you use every day.
Start in the browser with the playground, then the wiki page
for Python programmers. Advent of Code starts in a few days.
"""

template builderSlide* =
  slide: # 9.3
    nbText "## For the builder"
    columns:
      column:
        nbText """
### Fair winds

- prototype and fast code in one language
- C and C++ libraries one line away
- a Python package with wheels, the browser for free
- macros for your own notation (units)
"""
      column:
        nbText """
### Rocks ahead

- a tiny ecosystem: you will write more code
- a few maintainers carry each library
- bridges and packaging of uneven maturity
- no REPL; macros can be hard to read
"""
    speakerNote """
If you build tools: the left column is what we saw on the islands,
the right column is the rocks we collected along the way.
Pioneers did real science with it (Island 2), and Vindaar says
he learned way more than he would have otherwise.
Write the algorithm in Nim, and ship it to Python users as a wheel:
that is the path naffprop took (Island 4).
"""

template seenFromNimSlide* =
  slide: # 9.4
    nbText "## Your language, seen from Nim"
    nbTable seenFromNimTable()
    nbLede """
Not "switch to Nim": every language is a set of tradeoffs,
and their diversity is how scientific computing explores them
"""
    speakerNote """
I am not asking you to switch. The voyage was a way to look
back at the mainland from the sea: the tradeoffs of your own
language that you no longer notice. Python is slow in loops,
so you learned to think in arrays. Julia has a REPL, and pays
with a warm-up. Each language made its choices for a reason,
and the variety of languages is how we try new tradeoffs.
"""

template nicheSlide* =
  slide: # 9.5
    nbText "## Why still niche?"
    nbTable nicheTable()
    nbLede """
Fun, exciting, and with more potential
than the impact it had so far
"""
    speakerNote """
My opinionated view. The language is stable and ready:
1.0 in 2019, 2.0 in 2023 with ARC/ORC memory management.
The ecosystem is the chicken and egg of every small language.
The community is friendly, and small enough that one person
makes a difference (most of scientific Nim is a handful of people).
The main shortcoming is governance: decisions rest with very few
people, and it is hard to know from outside where the language goes.
On tooling: editor support and compile times are behind Rust's;
Nimony, the next compiler, and NIF, its intermediate format,
are meant to bring incremental compilation and better tooling.
Still: it is fun, exciting, and has more potential than impact so far.
"""

template conclusionSection* =
  slide:
    mapSlide(8) # 9.1
    beginnerSlide
    builderSlide
    seenFromNimSlide
    nicheSlide
