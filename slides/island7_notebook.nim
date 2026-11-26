import std / math
import nimib, nimiSlides
import ../my

# Section 8: Island 7: Notebook (see outline.md)
# Literate computing, which Jupyter made central, and nimib, the Nim option that goes in an
# unexpected direction: the notebook is a plain Nim program you run, not a kernel you talk to.
# Carries K2 and K3. The deep dive deepdive/notebook.nim goes further: what nimib is,
# the blocks, what people build with it, how it compares, and its limits.

template literateSlide* =
  slide: # 8.2
    nbText "## Literate computing"
    nbQuote("""
Let us concentrate rather on explaining to human beings
what we want a computer to do.""",
      "Donald Knuth, *Literate Programming* (1984)")
    nbText """
- 2001 IPython, 2014 Jupyter (Fernando Pérez):
  code, results and story, the lab notebook of science
- the price: hidden state, cells run out of order,
  JSON files hard to review
- plain files again: Quarto, Pluto.jl, marimo
"""
    reference """
Of the GitHub notebooks a 2019 study could run, 1 in 4 ran
without errors and 4% gave the same results (Pimentel et al.)
"""
    speakerNote """
Knuth wanted programs written for people to read, with the code
in the order of the explanation (WEB, then TeX).
Fernando Pérez, keynote of this conference, started IPython in 2001;
the notebook came in 2011 and Jupyter in 2014. He calls it
literate computing: not a program explained, but a computation
told as a story, with its results. Notebooks became where science happens.
The price is well known: a kernel keeps state you cannot see, cells run in any order.
A 2019 study (Pimentel et al.) collected 1.4 million notebooks from GitHub:
of those it ran, about one in four ran without errors, 4% gave the same results.
Quarto, Pluto.jl and marimo answer with plain files and, for the last two, reactivity.
"""

template nimibSlide* =
  slide: # 8.3
    nbText "## nimib: a notebook is a program"
    nbDiv("nimib-twin", ""):
      nimibCode:
        nbText "### From the deck of a boat"
        nbCode:
          let earth = 6371e3 # m, radius
          let eyes = 2.0     # m above the sea
          let horizon = sqrt(2 * earth * eyes)
          echo horizon.round, " m"
        nbText "Horizon: **" &
          $round(horizon / 1000, 1) & " km**"
    nbTextSmall """
Run the file, get the page: no kernel, no hidden state,
top to bottom every time; diffs, review and CI like any code.
Every page of this talk is made with nimib, this deck too.
"""
    speakerNote """
On the left a nimib document: nbText is Markdown, nbCode is Nim code.
On the right what it gives: the code runs when the file runs, its output
is captured, and the text uses the result, so the number cannot go stale.
This is the real thing: the right side was rendered from the left side
when this deck was built. The unexpected direction: Jupyter brings a kernel
into the browser, nimib brings the notebook into your editor and your compiler.
I started nimib in 2020; Hugo Granström maintains it with me.
"""

template nimibMakesSlide* =
  slide: # 8.4
    nbText "## What you can make with nimib"
    nbText """
- **pages**: the deep dives of this talk, with Show Source and a review mode
- **slides**: this deck, with [nimiSlides](https://github.com/HugoGranstrom/nimiSlides)
  (reveal.js)
- **books**: [nimibook](https://github.com/pietroppeter/nimibook), the docs of QEX
  and SciNim's getting started
- **interactive pages**: Nim compiled to JavaScript, like the plant of Island 6
- **READMEs**: the same blocks rendered as Markdown
- **your own blocks**: the tables, the maps and the plotly figures of this talk
"""
    nbTextSmall "[nimib, a deep dive](deepdive/notebook.html)"
    speakerNote """
A block is a type and a function that renders it:
nimib ships text, code, images, files; you add your own.
Every page of this site uses the same few blocks, defined once.
nimiSlides is by Hugo Granström: it adds slides and columns as blocks.
nimibook makes a book with a sidebar out of many documents.
The JavaScript backend means a page can carry a small app,
written in Nim and compiled when the page is built.
And there is nblog, a blog of nimib posts, and nimibex with more blocks.
"""

template nimibLandSlide* =
  slide: # 8.5
    nbText "## nimib land: 24 people"
    nbAvatars ["pietroppeter", "HugoGranstrom", "neroist", "Clonkk",
      "dlesnoff", "Yardanico", "Vindaar", "quimt", "metagn", "lost22git",
      "sent44", "PhilippMDoerner", "lbartoletti", # nimib
      "svenrdz", "dsrw", "moigagoo", "beef331", "ptweir",
      "tobimori", "nukopy", "alesanchezr", "bugct", "feluxe", "zetashift"]
    nbTextSmall """
13 wrote **nimib**, 24 with **nimiSlides**, **nimibook**, **nimiBoost**,
**nimitheme**, **nimipdf** and [nimib-land](https://github.com/nimib-land);
nimibook documents 13 projects (enu, owlkettle, Norm, QEX, ...),
nimiSlides made 10 of 41 NimConf talks since 2022
"""
    reference """
These are commits only: using it, reporting issues and telling us
what you built count as much, today more than ever
([who builds nimib land](deepdive/notebook.html))
"""
    speakerNote """
These are the people who wrote nimib land, from the git history of each repository.
Commits are only what git remembers: users, issues and feedback
are how most of nimib got better, and with AI writing code, they matter most.
nimiSlides made at least 10 of the 41 NimConf talks since 2022;
nimibook is the documentation of 13 projects, enu, owlkettle, Norm and QEX among them.
nimib: I started it in 2020, Hugo maintains it with me, 13 people wrote code for it.
Hugo made nimiSlides, this deck, and nimiBoost, the VS Code preview;
Clonkk wrote half of nimibook; neroist made nimitheme and nimipdf.
nimib-land is the GitHub organization where the ecosystem is moving:
nimibex for experiments and extra blocks, nblog, and nimib.py.
"""

template island7RocksSlide* =
  slide: # 8.6
    nbText "## Rocks ahead"
    columns:
      column:
        nbText """
- no kernel: every change reruns the whole
  document, seconds, not instant
- made to explain more than to explore:
  nothing to poke at
- a small community, two maintainers,
  docs behind the code
"""
      column:
        nbDiv("crew-photo", ""):
          nbImg("images/hugo-pietro.jpg",
            caption = "Hugo Granström and me at PyCon Sweden 2023, " &
              "our first meeting in person; co-maintainers since July 2022",
            alt = "Selfie of Pietro and Hugo Granström by the portholes of a boat at night")
    speakerNote """
The tradeoff of the unexpected direction.
Long computations you cache by hand.
Jupyter is a great place to explore: you keep the data in memory
and try things. nimib reruns everything, which is what makes it
reproducible, and what makes it slow when the work is heavy.
nimiBoost in VS Code shows a preview as you save.
The photo: PyCon Sweden 2023, the first time we met in person,
a year after Hugo became co-maintainer with nimib 0.3.
nimib is mine and Hugo's: a hobby project, and the 0.4 rewrite
left parts of the docs behind. Help is welcome.
"""

template island7NotebookSection* =
  slide:
    mapSlide(7) # 8.1
    literateSlide # 8.2
    nimibSlide # 8.3
    nimibMakesSlide # 8.4
    nimibLandSlide # 8.5
    island7RocksSlide # 8.6

when isMainModule: # this part of the deck on its own: docs/slides_island7.html
  buildDeckPart("island7", "slides/island7_notebook.nim"):
    island7NotebookSection
