import std / [math, strutils]
import nimib
import deepdive # useDeepDive, and the blocks of blocks.nim
import ggplotnim
import tabelline except Column # Datamancer has its own Column
import tabelline / nimib as tabNimib # nbTable

# The deep dive of Island 7 (Notebook): what nimib is, its blocks, what
# people make with it, how it compares with other notebooks, and its limits.
#   nim r deepdive/notebook.nim
# writes docs/deepdive/notebook.html. This page is itself a nimib document:
# Show Source, at the bottom, shows the file that made it.

const blocksSource = staticRead("../blocks.nim")

proc excerpt(source, startMarker, endMarker: string): string =
  ## the lines of `source` from the line starting with `startMarker`
  ## up to (not including) the line starting with `endMarker`
  ## (to the end when `endMarker` is empty)
  let lines = source.splitLines
  var first, last = -1
  for i, line in lines:
    if first < 0 and line.startsWith(startMarker):
      first = i
    elif first >= 0 and endMarker.len > 0 and line.startsWith(endMarker):
      last = i - 1
      break
  if first >= 0 and last < 0: last = lines.high
  doAssert first >= 0 and last >= first,
    "deep dive: code not found from '" & startMarker & "'"
  while last > first and lines[last].strip.len == 0:
    dec last
  lines[first .. last].join("\n")

nbInit(thisFileRel = "deepdive/notebook.nim")
const ownSource = staticRead("notebook.nim")
nb.useDeepDive("notebook", ownSource)

nbText """
# nimib: a notebook that is a Nim program

A notebook mixes text, code and the results of that code
in one document. Jupyter made it the lab notebook of
science. nimib is the Nim option, and it goes in an
unexpected direction: the notebook is not a kernel you
talk to from the browser, it is a plain Nim program you
run. Running it writes the page.

This page shows what that means, what you can make with
it, how it compares with the other notebooks, and where
it falls short. It is a nimib document itself, like
every page and slide of this talk.
"""

nbText """
## From literate programming to literate computing

In 1984 Donald Knuth proposed *literate programming*:
write a program as an essay for people, with the code in
the order of the explanation, and let tools extract the
program for the computer. He wrote TeX that way.
"""
nbQuote("""
Let us change our traditional attitude to the construction
of programs: Instead of imagining that our main task is to
instruct a computer what to do, let us concentrate rather
on explaining to human beings what we want a computer to do.""",
  "Donald Knuth, [Literate Programming](https://doi.org/10.1093/comjnl/27.2.97), The Computer Journal (1984)")

nbText """
Scientists needed something slightly different: not a
program explained, but a computation told as a story, with
its results. Fernando Pérez started IPython in 2001, the
IPython notebook came in 2011 and Project Jupyter in 2014.
He calls it *literate computing*. Notebooks are now where
much of science is written, taught and shared.

The price is well known. A kernel keeps state you cannot
see; cells can be run in any order, and the document on
disk is a JSON file with outputs inside, hard to diff and to
review. A [2019 study](https://doi.org/10.1109/MSR.2019.00077)
by Pimentel and others collected about 1.4 million
notebooks from GitHub: of those it could run, about one in
four ran without errors, and 4% gave the same results.

A new wave of tools keeps the notebook a plain file:
[Quarto](https://quarto.org) (Markdown with code chunks,
rendered top to bottom), [Pluto.jl](https://plutojl.org)
and [marimo](https://marimo.io) (reactive notebooks
saved as plain Julia or Python files). nimib belongs to that
family, at its far end: there is no kernel at all.
"""

nbText """
## The smallest nimib document

A nimib document is a Nim file. `nbInit` starts the
document, each `nb` call adds a block, `nbSave` writes it:
"""
nbShowCode("""
import nimib

nbInit
nbText "# Hello"
nbCode:
  echo 6 * 7
nbSave""", caption = "hello.nim")
nbText """
`nim r hello.nim` compiles and runs it, and writes
`hello.html`: a heading, the code, and the `42` it printed.
`nbText` is Markdown. `nbCode` is real Nim code: it is
compiled with the rest of the file, runs when the program
runs, and what it prints is captured and shown below it.
The code you see is read from the source file, comments
included, so what is shown is what ran.
"""

nbText """
## Text and code that cannot drift apart

The example of the slide, here with its output. The
`nimibCode` block shows nimib calls and runs them: below
the code is what they render.
"""
nimibCode:
  nbText "### From the deck of a boat"
  nbCode:
    let earth = 6371e3 # m, radius
    let eyes = 2.0     # m above the sea
    let horizon = sqrt(2 * earth * eyes)
    echo horizon.round, " m"
  nbText "Horizon: **" &
    $round(horizon / 1000, 1) & " km**"

nbText """
The last line is the point. The number in the text comes
from the code, so it is right every time the page is built:
change `eyes`, build again, and the text follows. There is
no state to forget: every build runs the document from the
top, in order, and a value used before it is defined does
not compile.

Since a nimib document is a program, all of Nim is there:
the standard library, any package, types checked by the
compiler. Variables of a block are visible in the next ones.
`nbCodeSkip` shows code without running it, `nbCapture`
runs code and shows only its output.
"""

nbText """
## Pictures and plots

`nbImage` adds a picture. A plot is a picture the code
draws: here with ggplotnim, the plotting library of the
data stack (Island 3), how far the horizon is from higher up.
"""
nbCode:
  var heights, distances: seq[float]
  for h in 1 .. 100:
    heights.add h.float
    distances.add sqrt(2 * earth * h.float) / 1000
  ggplot(toDf({"eyes (m)": heights, "horizon (km)": distances}),
         aes("eyes (m)", "horizon (km)")) +
    geom_line() +
    ggsave("images/nimib_horizon.png", width = 480, height = 300)
nbImg("images/nimib_horizon.png", width = "480",
  caption = "From the top of a 100 m mast you see 36 km of sea.",
  alt = "The distance of the horizon against the height of the eyes")

nbText """
## Nim in the browser

Nim also compiles to JavaScript, and nimib uses it:
`nbJsFromCode` and `nbKaraxCode` blocks are compiled to
JavaScript when the page is built and run in the reader's
browser. The slider below is the horizon again, written with
[Karax](https://github.com/karaxnim/karax):
"""
nbCodeDisplay(nbKaraxCode):
  import std / [math, strutils]
  var eyesUp = 2.0
  karaxHtml:
    label:
      text kstring("eyes above the sea: " & $eyesUp & " m")
    input(`type` = "range", min = "1", max = "100",
          value = kstring($eyesUp)):
      proc onInput(e: Event, n: VNode) =
        eyesUp = parseFloat($n.value)
    p:
      text kstring("the horizon is " &
        formatFloat(sqrt(2 * 6371e3 * eyesUp) / 1000,
                    ffDecimal, 1) & " km away")

nbText """
The plant of the interactivity island is the same trick at a
larger scale: [its deep dive](plant_app.html) shows the code.
"""

nbText """
## Your own blocks

nimib ships blocks for text, code, images, video, files and
JavaScript. Anything else is a block of your own: a type,
the fields it needs, and how it renders. The aside below is
`nbNote`, one of the blocks of this talk, defined in
[`blocks.nim`](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim/blob/main/blocks.nim):
"""
nbShowCode(excerpt(blocksSource, "newNbBlock(NbNote)", ""),
  caption = "blocks.nim")
nbNote """
A page of this talk has no HTML in it: what is needed twice
becomes a block, and its style goes in one place. The tables,
the maps, the quotes and the plotly figures are blocks.
"""
nbText """
Blocks can contain blocks (`nbDiv`, the columns of a slide),
and every block can be rendered by more than one backend:
"""

nbText """
## Markdown too

The same blocks render to Markdown, which is how nimib
writes READMEs that cannot go stale:
"""
nbCodeSkip:
  nb.useMdBackend()
  nb.doc.filename = "README.md"
  nbSave

nbText """
## What people make with it

nimib is the base of a small family of tools, most of them
in the [nimib-land](https://github.com/nimib-land)
organisation:
"""
let family = tableData:
  tool: ["[nimiSlides](https://github.com/HugoGranstrom/nimiSlides)",
         "[nimibook](https://github.com/pietroppeter/nimibook)",
         "[nblog](https://github.com/pietroppeter/nblog)",
         "[nimiBoost](https://github.com/HugoGranstrom/nimiBoost)",
         "[nimibex](https://github.com/nimib-land/nimibex)",
         "[nimib.py](https://github.com/nimib-land/nimib.py)"]
  makes: ["slides on reveal.js, this deck",
          "books with a sidebar, like the QEX docs and SciNim's getting started",
          "a blog of nimib posts, with the plant app's first port",
          "a VS Code extension: preview, and highlighting inside nbText",
          "more blocks, such as chat bubbles",
          "an experimental port of the idea to Python"]
let familyTable = tabella(family, rownameCol = "tool"):
  tabStubhead "tool"
  colsLabel "makes", "what it makes"
  fmtMarkdown "tool"
nbTable familyTable

nbText """
And this site: the deck, the deep dives and the talk log are
nimib documents, built in one program by
[`build.nim`](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim/blob/main/build.nim)
in about 30 seconds. Every page has a Show Source button
(the file that made it) and a review mode, where a reader
leaves comments on any block and exports them for the author.
"""

nbText """
## nimib land: who builds it

The circle of faces on the slide is everyone with at least one
commit in nimib land: 13 people wrote code for nimib itself,
24 for the whole family. The counts come from the git history
of twelve repositories (nimib, nimiSlides, nimibook, nimiBoost,
nimitheme, nimipdf, nimibex, nblog, nimib.py, the nimib.land
site, libnimib, nimibujo), read on 25 November 2026, with
each person counted once: commits made under other names or
emails (neroist also commits as Grave, niko and Jazz, and
used to be t-h-rk-turner) are merged, which is why GitHub
shows 16 contributors for nimib and this page 13.
The whole ecosystem, repository by repository, with its
open issues and the move to nimib-land, is in
[State of NimibLand](https://pietroppeter.github.io/claude-artifacts/state-of-nimibland/)
(October 2026).
"""
let people = tableData:
  person: ["pietroppeter", "HugoGranstrom", "neroist", "Clonkk",
    "ptweir", "tobimori", "beef331", "nukopy", "dlesnoff",
    "Yardanico", "zetashift", "svenrdz", "PhilippMDoerner",
    "quimt", "Vindaar", "alesanchezr", "lbartoletti", "metagn",
    "sent44", "lost22git", "moigagoo", "dsrw", "bugct", "feluxe"]
  since: [2020, 2021, 2023, 2021, 2018, 2018, 2022, 2020, 2023,
    2021, 2021, 2023, 2023, 2023, 2021, 2019, 2024, 2022, 2023,
    2024, 2021, 2023, 2018, 2019]
  came: ["nimib", "nimib", "nimib", "nimib", "nimiBoost",
    "nimiBoost", "nimibook", "nimiBoost", "nimib", "nimib",
    "nimibujo", "nimiSlides", "nimibook", "nimib", "nimib",
    "nimiBoost", "nimib", "nimib", "nimib", "nimib", "nimibook",
    "nimibook", "nimiBoost", "nimiBoost"]
  commits: [350, 332, 266, 67, 39, 30, 19, 14, 5, 4, 5, 3, 3,
    2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1]
  where: ["nimib 165, nblog 88, nimibook 85, 4 more 12",
    "nimiSlides 226, nimiBoost 38, nimib 31, 3 more 37",
    "nimitheme 233, nimipdf 21, nimib 12",
    "nimibook 64, nimib 3", "nimiBoost 39", "nimiBoost 30",
    "libnimib 18, nimibook 1", "nimiBoost 14", "nimib 5",
    "nimib 4", "nimibujo 5", "nimiSlides 3", "nimibook 2, nimib 1",
    "nimib 1, nimiSlides 1", "nimib 2", "nimiBoost 2",
    "nimib 1, nimibook 1", "nimib 1", "nimib 1", "nimib 1",
    "nimibook 1", "nimibook 1", "nimiBoost 1", "nimiBoost 1"]
let peopleTable = tabella(people, rownameCol = "person"):
  tabStubhead "person"
  colsLabel "since", "first commit"
  colsLabel "came", "came through"
  colsLabel "where", "commits by repository"
nbTable peopleTable

nbText """
Most people came through nimib itself, often with one fix to
something that bit them; nimibook brought library authors who
document their projects with it (Norm, enu). The six people
whose history starts before 2020 came with nimiBoost: Hugo
built it in 2021 on an existing VS Code extension for
Markdown inside code, and its history kept their commits.

A commit is only the kind of contribution git remembers.
Using nimib, opening an issue, asking a question that shows
where the docs are wrong, telling us what you built with it:
that is how most of nimib got better, and with code getting
cheaper to write, it is the contribution that matters most.
None of it shows in this table.
"""

nbText """
### nimibook: documentation of 13 projects

Counted with a GitHub code search for projects that depend
on nimibook (28 October 2026), leaving out our own:
"""
let books = tableData:
  project: ["[enu](https://getenu.com/docs/intro.html)",
    "[owlkettle](https://can-lehmann.github.io/owlkettle/README.html)",
    "[Norm](https://norm.nim.town)",
    "[SciNim getting started](https://scinim.github.io/getting-started/)",
    "[QEX](http://jcosborn.github.io/qex/)",
    "[Snorlogue](https://philippmdoerner.github.io/Snorlogue/bookCompiled/)",
    "[Karkas](https://karkas.nim.town/)",
    "[mapster](https://philippmdoerner.github.io/mapster/index.html)",
    "[nova](https://neroist.github.io/nova/)",
    "[FrogCap](https://github.com/chutter/FrogCap-Sequence-Capture)",
    "[NimDrake](https://github.com/BontaVlad/NimDrake)",
    "[ThreadButler](https://github.com/PhilippMDoerner/ThreadButler)",
    "[Kiloneie's tutorials](https://kiloneie.github.io/)"]
  what: ["a Logo-like 3D environment",
    "declarative user interfaces (GTK)", "an ORM for SQLite and Postgres",
    "Nim for scientific computing",
    "lattice field theory (Island 2)", "an admin plugin for Prologue",
    "layout helpers for Karax", "mapping functions made at compile time",
    "a CLI for Govee light strips", "a sequence capture pipeline (biology)",
    "DuckDB bindings", "threads used as if they were servers",
    "video tutorials of Nim, as pages"]
  stars: [486, 459, 417, 64, 60, 27, 19, 17, 14, 10, 8, 7, 1]
let booksTable = tabella(books, rownameCol = "project"):
  tabStubhead "project"
  colsLabel "what", "what it is"
  colsLabel "stars", "GitHub stars"
  fmtMarkdown "project"
nbTable booksTable

nbText """
### nimiSlides: decks

The same search finds 8 decks by others (NimConf talks,
a club site, tutorials) and 14 of mine, from Python Milano
and PyCon talks to this one; Hugo keeps his own NimConf
decks in the nimiSlides repository.
"""

nbText """
#### nimiSlides at NimConf

NimConf is the online conference of the Nim community.
Since nimiSlides exists, at least 10 of its 41 talks were
given with nimiSlides decks, by six speakers; counted from the
talks whose slides are public (the conference schedules on
[conf.nim-lang.org](https://conf.nim-lang.org), collected in
[NimConf schedules](https://pietroppeter.github.io/claude-artifacts/nimconf-schedules/),
and a GitHub
search for decks that import nimiSlides).
"""
let nimconf = tableData:
  year: [2022, 2022, 2024, 2024, 2024, 2024, 2026, 2026, 2026, 2026]
  talk: ["Nimib goes interactive",
    "Make beautiful presentations in Nim using NimiSlides",
    "Karax Kraut Karkas", "The Ferus Web Engine",
    "avr_io, bare-metal embedded development in Nim",
    "Updates from NimibLand", "Nim for the Modern Linux Desktop",
    "Nimib v0.4: internals ref-actoring",
    "Nim for embedded software development", "Henka: Bind anything"]
  speakers: ["Pietro Peterlongo, Hugo Granström", "Hugo Granström",
    "Constantine Molchanov", "Trayambak Rai", "Gianmarco Marcello",
    "Pietro Peterlongo, Hugo Granström", "Trayambak Rai",
    "Hugo Granström", "Gianmarco Marcello", "Row"]
  share: ["2 of 11", "2 of 11", "4 of 10", "4 of 10", "4 of 10",
    "4 of 10", "4 of 20", "4 of 20", "4 of 20", "4 of 20"]
let nimconfTable = tabella(nimconf):
  colsLabel "share", "nimiSlides talks that year"
nbTable nimconfTable

nbText """
## nimib and the other notebooks

Not a contest: each makes a different tradeoff.
"""
let notebooks = tableData:
  notebook: ["Jupyter", "Quarto", "marimo", "Pluto.jl", "nimib"]
  file: ["`.ipynb`, JSON with outputs", "`.qmd`, Markdown",
         "`.py`", "`.jl`", "`.nim`"]
  runs: ["cells, in any order, in a kernel",
         "top to bottom, when rendered",
         "reactive: a change reruns what depends on it",
         "reactive: a change reruns what depends on it",
         "top to bottom, compiled, when built"]
  explore: ["yes", "no, through Jupyter or RStudio",
            "yes", "yes", "no"]
let notebooksTable = tabella(notebooks, rownameCol = "notebook"):
  tabStubhead "notebook"
  colsLabel "file", "saved as"
  colsLabel "runs", "runs"
  colsLabel "explore", "explore live"
  fmtMarkdown "file"
  tabStyle style.text(weight = "bold"), loc.stub()
nbTable notebooksTable

nbText """
Jupyter is the best place to explore: the data stays in
memory and you try things. The reactive notebooks keep that
and remove the hidden state. Quarto and nimib give up the
live session to get a document that is the same every time
it is built; nimib also gives up the interpreter, and gets
a compiler checking every page.
"""

nbText """
## Rocks ahead

- **No kernel.** Every change compiles and runs the whole
  document again: seconds, not instant, and a long
  computation runs again unless you cache it by hand.
- **Made to explain more than to explore.** You edit in your
  editor and build; there is nothing to poke at in between.
  nimiBoost previews the page on save, which helps.
- **A small community.** Two maintainers (Pietro and Hugo
  Granström), a hobby project; the 0.4 rewrite of the blocks
  left parts of the documentation behind the code.
- **Errors through templates.** A mistake inside `nbCode`
  is reported by the compiler through nimib's templates,
  which takes some getting used to.
"""

nbText """
## Where to start

- [nimib](https://github.com/pietroppeter/nimib) and its
  [documentation](https://pietroppeter.github.io/nimib/),
  itself made with nimib
- [nimiSlides](https://github.com/HugoGranstrom/nimiSlides)
  for slides, [nimibook](https://github.com/pietroppeter/nimibook)
  for books
- Show Source, at the bottom of this page
"""

nbSave
