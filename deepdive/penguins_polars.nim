import std / [options, strutils]
import nimib
import deepdive # useDeepDive, and the blocks of blocks.nim
import nanuq
import tabelline except Column, readCsv
import tabelline / [nimib, nanuq]

# A nimib document that explains slides 4.8 and 4.9 of Island 3
# (nanuq and tabelline, in slides/island3_nanuq.nim):
#   nim r deepdive/penguins_polars.nim
# writes docs/deepdive/penguins_polars.html.
# The code below runs when the page is built, like on the slides.
# nanuq links a static Polars library, downloaded the first time it is compiled.

nbInit(thisFileRel = "deepdive/penguins_polars.nim")
const ownSource = staticRead("penguins_polars.nim")
nb.useDeepDive("penguins_polars", ownSource)
nbText """
# Penguins with nanuq and tabelline

In the talk [Sailing Seas of Scientific
Nim](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/slides.html),
Island 3 ends with two new blocks of the Nim data stack:
[nanuq](https://github.com/pietroppeter/nanuq),
dataframes with [Polars](https://pola.rs),
and [tabelline](https://github.com/pietroppeter/tabelline),
display tables after R's [gt](https://gt.rstudio.com)
and Python's [Great Tables](https://posit-dev.github.io/great-tables/).
Both are mine (the speaker's), from October and November 2026,
and written mostly with an AI coding agent.
The rest of the stack, Arraymancer, Datamancer and ggplotnim,
is in [the other penguins deep dive](penguins_data_stack.html).
All the code on this page runs when the page is built,
and the output below each block is its real output.
"""

nbText """
## Why Polars in Nim

[Datamancer](https://github.com/SciNim/Datamancer) is a good
dataframe library written in Nim, after dplyr.
Polars is something else: a query engine written in Rust,
with lazy queries that it optimizes before running them,
streaming for data larger than memory,
and readers for Parquet, IPC, JSON, Excel and cloud storage.
It is what many Python users reach for today instead of pandas.
Rewriting it in Nim is out of reach;
calling it is not.

Rust can export functions with a C ABI, and Nim calls
a C function as easily as one of its own
(that is Island 4 of the talk).
So nanuq is three layers:
a thin Rust crate that exports Polars as C functions over
opaque pointers, raw `importc` declarations in Nim,
and a Nim API on top, where every object frees
its Rust half in a destructor.
The Rust part comes as a prebuilt static library,
downloaded the first time a program that imports nanuq
compiles, so a Nim user needs no Rust toolchain.
"""

nbText """
## The data

The same CSV as the rest of the island, from seaborn,
where missing values are empty fields.
Polars reads them as nulls, and says so:
"""
nbCode:
  let penguins = readCsv("data/penguins.csv")
  echo penguins.head(3)
  echo "missing body masses: ", penguins.nullCount("body_mass_g")

nbText """
## Expressions and lazy queries

The query of the slide, the mean body mass and flipper length
of each species.
A query on a `LazyFrame` is a plan: Polars optimizes it
and runs it on `collect`
(`scanCsv` instead of `readCsv` would also let it read
only the columns and rows the query needs).
Names are those of Python Polars in camelCase,
and `col("body_mass_g")` is `pl.col("body_mass_g")`:
"""
nbCode:
  let means = penguins.lazy
    .filter(col("body_mass_g").isNotNull)
    .groupBy("species")
    .agg(col("body_mass_g").mean.alias("mass (g)"),
         col("flipper_length_mm").mean.alias("flipper (mm)"))
    .sort("species")
  echo means.collect

nbText """
Two things read better in Nim than in Python.
`when/then/otherwise` can be written as a plain `if`
with the `choose` macro,
and the results come back typed (below).
As in Polars, an expression can be computed per group
with `over`, as in a SQL window function.
Is each penguin heavy or light for its species?
"""
nbCode:
  let mass = col("body_mass_g")
  let sized = penguins.dropNulls("body_mass_g").withColumns(
    choose(if mass > mass.mean.over("species"): "heavy"
           else: "light").alias("size"))
  echo sized.groupBy(["species", "size"]).agg(len().alias("n"))
    .sort(["species", "size"])

nbText """
Results come back as typed Nim values:
`rows` reads each row into a tuple, by column name,
with `Option` where a value can be missing
(`toList` does the same for one column).
The three heaviest penguins, and their sex:
"""
nbCode:
  let heaviest = penguins.dropNulls("body_mass_g")
    .sort("body_mass_g", descending = true).head(3)
  for p in heaviest.rows(tuple[species: string, body_mass_g: int,
                               sex: Option[string]]):
    echo p.species, ", ", p.body_mass_g, " g, ",
      p.sex.get("sex not recorded")

nbText """
## Display tables with tabelline

A dataframe printed in a terminal is for the analyst.
A table in a report is for a reader:
a title, columns grouped under spanners,
numbers formatted, notes and sources.
R has gt for that, and Python Great Tables, by the same people at Posit.
tabelline follows them, with the same parts and verbs,
in plain Nim (its core needs only the standard library),
and takes a nanuq frame as it is
(`import tabelline/nanuq`).

The slide shows body mass by species with a boxplot per row.
Here a fuller summary, by species and island:
the counts, the mean of each measurement under a spanner,
and the body masses of each group as a boxplot
on one shared axis.
"""
nbCode:
  let byIsland = penguins.dropNulls("body_mass_g")
    .groupBy(["species", "island"])
    .agg(len().alias("n"),
         col("bill_length_mm").mean.alias("bill length"),
         col("bill_depth_mm").mean.alias("bill depth"),
         col("flipper_length_mm").mean.alias("flipper"),
         mass.alias("body mass")) # all of them, as a list
    .sort(["species", "island"])

  let table = tabella(byIsland, rownameCol = "island",
                      groupnameCol = "species"):
    tabHeader "Palmer penguins", "by species and island"
    tabSpanner "Mean (mm)", ["bill length", "bill depth", "flipper"]
    fmtNumber ["bill length", "bill depth", "flipper"], decimals = 1
    fmtNanoplot "body mass", plotType = "boxplot", autoscale = true
    colsLabel "body mass", "Body mass (g)"
    tabSourceNote "Data: Gorman, Williams and Fraser (2014), palmerpenguins (CC0)."
nbTable table

nbText """
Adelie live on all three islands,
and look much the same on each.
Gentoo are a kilo heavier, with longer flippers
and shallower bills.

Every table of the talk's slides is made with tabelline,
with a few helpers for the deck's look
(`slideLook` and `highlightCols` in the talk's `my.nim`).
Its [site](https://pietroppeter.github.io/tabelline/) has a guide,
a book of gt and Great Tables examples redone in Nim,
and stories told in tables, such as
[Islands of the Mediterranean](https://pietroppeter.github.io/tabelline/stories/isole/),
whose data was made with nanuq.
"""

nbText """
## Datamancer and nanuq

Two dataframe libraries for one small ecosystem:
which one?
"""
nbCode:
  let compare = newDataFrame:
    aspect: ["written in", "after", "queries", "file formats",
             "to install"]
    Datamancer: ["Nim", "dplyr", "eager, formulas f{...}",
                 "CSV, HDF5 (with nimhdf5)", "Nim only"]
    nanuq: ["Rust (Polars) and Nim", "Python Polars",
            "eager and lazy, expressions",
            "CSV, Parquet, IPC, JSON, Excel, SQL, cloud",
            "a 53 MB prebuilt library"]
nbTable tabella(compare, rownameCol = "aspect")

nbText """
Datamancer is pure Nim, small, and plots directly with ggplotnim,
which is built on it.
nanuq brings the speed and breadth of Polars,
at the cost of a large native library
(about 286 MB once unpacked, linked statically).
They meet: `nanuq/datamancer` converts a frame either way,
for example to plot a nanuq result with ggplotnim.
"""

nbText """
## Rocks ahead

nanuq 0.6.1 covers 116 of the 128 feature groups of Python Polars,
by [its own map](https://pietroppeter.github.io/nanuq/polars_coverage.html);
plotting is not one of them, and there is no
shared library yet.
tabelline 0.2 follows most of gt's verbs.
Both are weeks old, written by one person mostly with
an AI coding agent, and tested more by their own
specs and stories than by users.
They show how fast a gap can be filled today;
whether they last depends on people using them.
"""

nbText """
## Further reading

- [nanuq](https://github.com/pietroppeter/nanuq): the README,
  the [development log](https://pietroppeter.github.io/nanuq/)
  (how it works, the design of each release) and
  [the Nanuq Book](https://pietroppeter.github.io/nanuq-book/),
  public Polars tutorials ported to Nim, with the Python beside.
- [tabelline](https://pietroppeter.github.io/tabelline/):
  the guide, the book and the stories.
- [Polars](https://docs.pola.rs/) and
  [Great Tables](https://posit-dev.github.io/great-tables/)
  documentation.
"""

nbText """
## Try it

Group by sex instead of island, or add a nanoplot
of flipper lengths.
Clone [the
repository](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim)
and run `nim r deepdive/penguins_polars.nim`:
it builds this page in `docs/deepdive/penguins_polars.html`.
The
[README](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim#readme)
explains how to install the dependencies.
"""
nbSave
