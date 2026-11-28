import std / [math, sequtils]
import nimib
import nimiSlides except speakerNote # blogpost.nim has its own (my.nim exports it)
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
    nbQuote("""
"Literate computing": the weaving of a narrative directly
into a live computation, interleaving text with code and results.""",
      "Fernando Pérez, *Literate computing and computational reproducibility* (2013)")
    nbText """
*Jupyter* (2014, from IPython) created the notebook as we know it:
code, results and story, the lab notebook of science.
"""
    speakerNote """
So how does a notebook work with no REPL? That is what
started me doing open source: I wanted something that
covered the need of Jupyter, but I had no REPL, so I had
to invent something completely different, that took
advantage of what Nim offers: nimib.
But first, the definition. Literate programming: explaining
to human beings what we want a computer to do (Knuth).
Literate computing, as Fernando Pérez calls it: a narrative
woven into a live computation. And Jupyter created the
concept of a notebook: it did not exist before.

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

const horizonSource = staticRead("../examples/horizon.nim") # a plain nimib document

template nimibSlide* =
  slide: # 8.3
    nbText "## nimib: notebook as a library"
    compactColumns:
      column:
        nbShowCode(horizonSource)
      column:
        nbDiv("phone-frame", ""): # examples/horizon.nim built with plain nimib, on a phone
          nbImg("images/horizon-phone.png")
    nbTextSmall """
Run the file, get the page: no kernel, no hidden state,
top to bottom every time; diffs, review and CI like any code.
Every page of this talk is made with nimib, this deck too.
"""
    speakerNote """
So how do you make a notebook without a REPL?
This is why I think it is interesting to have different
languages bring different perspectives: my take was to
provide notebook-like functionality as a library.
I have never seen anything like it elsewhere
(if you have, let me know).

On the left a nimib document: a Nim program that imports nimib;
nbText is Markdown, nbCode is Nim code, nbSave writes the page.
On the right what it gives, on a phone, in nimib's default theme with Show Source: the code runs when the file runs, its output
is captured, and the text uses the result, so the number cannot go stale.
This is the real thing (examples/horizon.nim). The unexpected direction: Jupyter brings a kernel
into the browser, nimib brings the notebook into your editor and your compiler.
I started nimib in 2020; Hugo Granström maintains it with me.
"""

template nimibMakesSlide* =
  slide: # 8.4
    nbText "## What you can make with nimib"
    nbText """
- 📄 **pages**: the deep dives of this talk, with Show Source and a review mode
- 🎞️ **slides**: this deck, with [nimiSlides](https://github.com/HugoGranstrom/nimiSlides)
  (reveal.js)
- 📚 **books**: [nimibook](https://github.com/pietroppeter/nimibook), the docs of QEX
  and SciNim's getting started
- 🕹️ **interactive pages**: Nim compiled to JavaScript, like the plant of Island 6
- 🧱 **your own blocks**: the tables, the maps and the plotly figures of this talk
"""
    nbTextSmall "🐋 [nimib, a deep dive](deepdive/notebook.html)"
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

const
  explainerShots = ["nanuq-aged19", "tabelline-fosdem", "dragging", "faretto"]
  phoneShots = ["devrooms", "dragging", "eight", "faretto", "iphone", "month",
    "nanuq-above4000", "nanuq-aged19", "nanuq-elnino", "nanuq-move37", "nimibland",
    "nimony", "tabelline-explainer", "tabelline-fosdem", "tabelline-isole", "tabelline-milano"]

template explainersSlide* =
  slide: # 8.5: what nimib is for me now
    nbCollage("EXPLAINERS", explainerShots.mapIt("images/explainers/desk-" & it & ".jpg"))
    speakerNote """
What I make with nimib today, mostly with Claude: explainers.
A nanuq post on a teenager's cycling season, a tabelline story
on FOSDEM, a port of declarative dragging, Faretto
(can Nim code be alive, like Pharo?), which I made on the spot
at this conference, after Marcus Denker's talk on Pharo.
Each one is a nimib page.
"""

template explainersPhoneSlide* =
  slide: # 8.6: the same, as I read them, on the phone
    nbCollage("EXPLAINERS", phoneShots.mapIt("images/explainers/phone-" & it & ".jpg"), phone = true)
    speakerNote """
And this is how I read them: on the phone. Nanuq's blog,
tabelline's stories, my Claude artifacts, all nimib pages.
"""

template nimibLandSlide* =
  slide: # 8.5
    nbText "## nimib land community"
    nbAvatars ["pietroppeter", "HugoGranstrom", "neroist", "Clonkk",
      "dlesnoff", "Yardanico", "Vindaar", "quimt", "metagn", "lost22git",
      "sent44", "PhilippMDoerner", "lbartoletti", # nimib
      "svenrdz", "dsrw", "moigagoo", "beef331", "ptweir",
      "tobimori", "nukopy", "alesanchezr", "bugct", "feluxe", "zetashift"],
      small = true
    columns:
      column:
        nbTextSmall """
13 wrote **nimib**, 24 with **nimiSlides**, **nimibook**, **nimiBoost**,
**nimitheme**, **nimipdf** and [nimib-land](https://github.com/nimib-land);
nimibook documents 13 projects (enu, owlkettle, Norm, QEX, ...),
nimiSlides made 10 of 41 NimConf talks since 2022.

These are commits only: using it, reporting issues and telling us
what you built count as much, today more than ever
(🐋 [who builds nimib land](deepdive/notebook.html))
"""
      column:
        nbDiv("crew-photo", ""):
          nbImg("images/hugo-pietro.jpg",
            caption = "Hugo Granström and me at PyCon Sweden 2023, " &
              "our first meeting in person; co-maintainers since July 2022",
            alt = "Selfie of Pietro and Hugo Granström by the portholes of a boat at night")
    speakerNote """
These are the people who wrote nimib land, from the git history of each repository.
Commits are only what git remembers: users, issues and feedback
are how most of nimib got better, and with AI writing code, they matter most,
and they are not tracked here.
nimiSlides made at least 10 of the 41 NimConf talks since 2022;
nimibook is the documentation of 13 projects, enu, owlkettle, Norm and QEX among them.
nimib: I started it in 2020, Hugo maintains it with me, 13 people wrote code for it.
The photo: PyCon Sweden 2023, the first time Hugo and I met in person,
a year after he became co-maintainer with nimib 0.3.
Hugo made nimiSlides, this deck, and nimiBoost, the VS Code preview;
Clonkk wrote half of nimibook; neroist made nimitheme and nimipdf.
nimib-land is the GitHub organization where the ecosystem is moving:
nimibex for experiments and extra blocks, nblog, and nimib.py.
"""

template island7RocksSlide* =
  slide: # 8.6
    nbText "## ⚠️ Rocks ahead 🪨"
    nbText """
- no kernel: every change reruns the whole document,
seconds, not instant
- made to explain more than to explore: nothing to poke at
- a small community, two maintainers, docs behind the code
"""
    speakerNote """
The tradeoff of the unexpected direction.
Long computations you cache by hand.
Jupyter is a great place to explore: you keep the data in memory
and try things. nimib reruns everything, which is what makes it
reproducible, and what makes it slow when the work is heavy.
nimiBoost in VS Code shows a preview as you save.
nimib is mine and Hugo's: a hobby project, and the 0.4 rewrite
left parts of the docs behind. Help is welcome.
"""

template island7NotebookSection* =
  slide:
    mapSlide(7) # 8.1
    literateSlide # 8.2
    nimibSlide # 8.3
    nimibMakesSlide # 8.4
    explainersSlide # 8.5
    explainersPhoneSlide # 8.6 (one of the two, Pietro picks)
    nimibLandSlide # 8.5
    island7RocksSlide # 8.6

when isMainModule: # this part of the deck on its own: docs/slides_island7.html
  buildDeckPart("island7", "slides/island7_notebook.nim"):
    island7NotebookSection
