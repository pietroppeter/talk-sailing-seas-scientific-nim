import nimib, nimiSlides
import std / [math, sequtils]
import ggplotnim
import arraymancer / linear_algebra # solve
import tabelline except Column, readCsv
import ../my
import island3_network, island3_nanuq, island3_plotly
export math, sequtils, ggplotnim, linear_algebra
export networkSlide, nanuqSlide, tabellineSlide, nanuqSlides, plotlySlide

# Section 4: Island 3: Ecosystem (see outline.md)
# The basic building blocks of the data ecosystem, through an exploration of the penguins dataset. Carries K2 and K3.
# Slides 4.5 (the network) and 4.8, 4.9 (nanuq, tabelline) are templates of their own modules.
# Paths are relative to docs/ (nimib's homeDir): the data is docs/data/penguins.csv,
# the plot is written to docs/images/penguins.png when the deck is built.

# the table of slide 4.2, made here and not in the (dirty) template below,
# so that tabelline's names do not meet Datamancer's where the template is used
proc stackTable*(): Tabella =
  let stack = @[
    (part: "Tensors", python: "NumPy, PyTorch", r: "arrays, torch",
     nim: "[Arraymancer](https://github.com/mratsim/Arraymancer)"),
    (part: "Dataframes", python: "pandas, Polars", r: "dplyr",
     nim: "[Datamancer](https://github.com/SciNim/Datamancer), [nanuq](https://github.com/pietroppeter/nanuq)"),
    (part: "Plots", python: "matplotlib", r: "ggplot2",
     nim: "[ggplotnim](https://github.com/Vindaar/ggplotnim)"),
    (part: "Display tables", python: "Great Tables", r: "gt",
     nim: "[tabelline](https://github.com/pietroppeter/tabelline)")]
  tabella(stack, rownameCol = "part")
    .colsLabel({"python": "Python", "r": "R", "nim": "Nim"})
    .fmtMarkdown("nim")
    .highlightCols("nim")
    .tabStyle(style.text(color = "#ee961a", weight = "bold"),
              loc.stub(labels = ["Display tables"]))
    .slideLook(fontSize = "0.7em")

# dirty: Datamancer's `f{...}` formulas read `f` and type hints like `float`
# as plain identifiers, which a normal template would bind to symbols
template stackSlide* {.dirty.} =
  slide: # 4.2
    nbText "## Ecosystem"
    nbTextSmall """
The building blocks of data science, as in the
[Python Data Science Handbook](https://jakevdp.github.io/PythonDataScienceHandbook/)
by Jake VanderPlas (plus Great Tables):
"""
    nbTable stackTable()
    columns:
      column:
        nbImg("images/lter_penguins.png", "45%")
      column:
        nbTextSmall """
🐋 [A data exploration with the stack](deepdive/penguins_data_stack.html):
344 penguins near Palmer Station, Antarctica.
Data: Gorman, Williams and Fraser (2014),
[palmerpenguins](https://allisonhorst.github.io/palmerpenguins/) (CC0).
Artwork by @allison_horst.
"""
    speakerNote """
Tensors, dataframes and plots are the core of every
book. But if you do not care about Nim and want a single
takeaway from this talk: go and use Great Tables (Python)
and gt (R). They are great, people should build more and
better great tables, and I have been enjoying it a lot.
To get inspired, go to their sites; you can also go to
tabelline's site, I put a lot of love into it (still a
lot to polish): there is an explainer on the islands of
the Mediterranean.

So, the ecosystem. If we start from the classic stack,
the one I learned from Jake VanderPlas's Python Data
Science Handbook: tensors, dataframes, plots. I add
display tables: I worked on them recently, they are
great and underused.
Nim has not one but at least two tensor libraries,
Arraymancer and Flambeau (more than one is also a
problem); a dataframe built on Arraymancer, and nanuq,
bindings to Polars; a plot library inspired by ggplot,
and one that uses Plotly; and since recently tabelline,
a port of Great Tables. nanuq and tabelline were born
a month ago, and thanks to AI they are already feature
complete and usable, which is kind of crazy.

Nim has the same building blocks.
Arraymancer is by Mamy (mratsim).
Datamancer and ggplotnim are by Vindaar,
built for his PhD (island 2), now under SciNim.
nanuq and tabelline are new, this autumn, and mine:
the modern side, Polars and Great Tables.
Let's try them on a dataset you all know.
"""

template arraymancerSlide* {.dirty.} =
  slide: # 4.4
    nbText "## Tensors: Arraymancer"
    nbCode:
      let M = arange(1.0, 13.0).reshape(3, 4) # as in NumPy
      echo M[1.._, 2..3]         # slicing
      echo M -. M.mean(axis = 0) # explicit broadcasting
      let A = [[2.0, 1.0], [1.0, 3.0]].toTensor
      echo solve(A, [3.0, 5.0].toTensor) # linear system, with LAPACK
    nbTextSmall """
More than NumPy: CPU and GPU backends (CUDA, OpenCL),
a solid ndarray with linear algebra, deep learning (next slide),
and the seeds of scikit-learn.
"""
    speakerNote """
Bottom of the stack: tensors, as in NumPy.
A 3 x 4 matrix from a range, sliced with ranges,
centered column by column with broadcasting
(`-.`: a dot makes the broadcast visible),
and a linear system solved with LAPACK.
Arraymancer is by Mamy (mratsim).
Honest status: the ndarray is the solid part.
Deep learning is a compact framework that works
(autograd, layers, now transformers), its API marked unstable;
classic machine learning is a handful of algorithms.
Last release October 2024, a few commits a year since.
"""

template datamancerSlide* {.dirty.} =
  slide: # 4.6
    nbText "## Dataframes: Datamancer"
    nbCode:
      let df = readCsv("data/penguins.csv")
        .filter(f{`body_mass_g` > 0.0}) # drop missing

      echo df.group_by("species").summarize(
        f{float: "mass (g)" << mean(`body_mass_g`)},
        f{float: "flipper (mm)" << mean(`flipper_length_mm`)})
    nbTextSmall """
Looks like dplyr, with Arraymancer as its backend.
"""
    speakerNote """
Reads like dplyr or pandas: read, filter, group by, summarize.
f{...} is a formula: a macro that turns the expression
into a typed, compiled loop over the columns.
Missing numbers are NaN, so `> 0.0` drops them.
Mean body mass and flipper length per species:
Gentoo are the heavy ones, with the longest flippers.
"""

template ggplotnimSlide* {.dirty.} =
  slide: # 4.7
    nbText "## Plots: ggplotnim"
    nbTextSmall """
Looks like ggplot2, using Datamancer dataframes.
"""
    nbCode:
      ggplot(df, aes("flipper_length_mm", "body_mass_g",
                     color = "species")) +
        geom_point() +
        ggsave("images/penguins.png", width = 500, height = 320)
    nbImg("images/penguins.png", "45%")
    speakerNote """
The grammar of graphics, as in R's ggplot2:
data, aesthetics, then layers added with `+`.
Flipper length and body mass go together,
and the species form clusters.
Backends: PNG/PDF via cairo, SVG, TikZ, Vega-Lite.
"""

template scinimSlide* {.dirty.} =
  slide: # 4.10
    nbText "## SciNim"
    nbTextSmall """
[SciNim](https://github.com/SciNim) gathers the scientific Nim libraries.
Start from [getting started](https://scinim.github.io/getting-started/)
(it needs to be updated): tutorials and a list of libraries. A few more:
"""
    nbText """
- [flambeau](https://github.com/SciNim/flambeau): bindings to libtorch
- [numericalnim](https://github.com/SciNim/numericalnim): integration, ODEs, optimization, interpolation
"""
    speakerNote """
SciNim is the organization that collects libraries
that would otherwise be scattered: Datamancer, unchained,
numericalnim and more live there.
The getting started site has tutorials for the stack
and a list of libraries by topic.
nim-plotly was started by Brent Pedersen (brentp, island 2)
and donated to SciNim.
"""

template island3RocksSlide* {.dirty.} =
  slide: # 4.11
    nbText "## ⚠️ Rocks ahead 🪨"
    nbText """
- classic ML is only seeds: a few algorithms, no scikit-learn
- multiple tensor libraries, and now two dataframe libraries
- the ecosystem depends on a few contributors (Vindaar, mratsim, Clonkk, HugoGranstrom, ...): when life happens, development stops
- nanuq and tabelline are weeks old, one person's, mostly AI-written: they need usage
"""
    speakerNote """
The pieces are good and you can do real work with them.
Classic machine learning is only seeds:
a few algorithms in Arraymancer, no scikit-learn.
There is more than one tensor library,
and now two dataframe libraries.
A handful of people carry the stack:
when life happens to them, development stops.
nanuq and tabelline are mine, from this autumn,
written mostly with Claude: an experiment in how fast
one person can fill a gap. What they need now is usage.
So the ecosystem is not strong, but it is usable.
And you do not need that much ecosystem, because
interoperability is very strong (next island).
"""

template island3DataStackSection* {.dirty.} =
  slide:
    mapSlide(3) # 4.1
    stackSlide # 4.2 (with the penguins)
    arraymancerSlide # 4.3
    networkSlide # 4.4
    datamancerSlide # 4.5
    nanuqSlide # 4.6
    ggplotnimSlide # 4.7
    plotlySlide # 4.8
    tabellineSlide # 4.9
    scinimSlide # 4.10
    island3RocksSlide # 4.11

when isMainModule: # this part of the deck on its own: docs/slides_island3.html
  buildDeckPart("island3", "slides/island3_datastack.nim"):
    island3DataStackSection
