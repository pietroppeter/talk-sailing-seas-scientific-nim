import std / options
import nimib, nimiSlides
import nanuq
import tabelline except Column, readCsv
import tabelline / nanuq as tabellineNanuq
import ../my

# Island 3, the new part of the stack: nanuq (Polars for Nim) on slide 4.7
# and tabelline (Great Tables for Nim) on slide 4.9.
# nanuq's names (DataFrame, readCsv, ...) clash with Datamancer's, and `col("name")`
# (a call operator on a constant) does not work inside a template:
# so what is in the slides is a proc of this module, which gets the deck's `nb`,
# and its code binds to nanuq here (the `slide:` around it stays a template).
# Paths are relative to docs/ (nimib's homeDir), as in island3_datastack.nim.

proc nanuqSlide(nb: var Nb) = # 4.8
  nbText "## Dataframes: nanuq"
  # a shorter print than Polars' default (Python's pl.Config), for the slide only
  setTblHideDataframeShape(); setTblColumnDataTypeInline(); setFloatPrecision(1)
  nbCode:
    let penguins = readCsv("data/penguins.csv")
    echo penguins.lazy
      .filter(col("body_mass_g").isNotNull) # drop missing
      .groupBy("species")
      .agg(col("body_mass_g").mean.alias("mass (g)"),
           col("flipper_length_mm").mean.alias("flipper (mm)"))
      .sort("species")
      .collect
  setTblHideDataframeShape(none(bool)); setTblColumnDataTypeInline(none(bool))
  setFloatPrecision(none(int))
  nbTextSmall """
[Polars](https://pola.rs) for Nim:
the Rust library behind a C ABI,
116 of Polars' 128 feature groups
([deep dive](deepdive/penguins_polars.html)).
"""
  speakerNote """
The same query as with Datamancer, now Polars style:
a lazy query, optimized and run by Polars when we collect.
nanuq (Inuit for polar bear) is mine, started in October 2026:
Rust can export a C API, and Nim calls it like any C library
(more on that in the next island).
Version 0.6.1 covers 116 of the 128 feature groups of Python Polars:
expressions, joins, time windows, SQL, Parquet, streaming.
Written mostly with Claude, as nimlang-pypi and naffprop:
it needs users more than features now.
"""

proc tabellineSlide(nb: var Nb) = # 4.9
  let penguins = readCsv("data/penguins.csv") # as on the previous slide
  nbText "## Tables: tabelline"
  compactColumns:
    column:
      nbCode:
        let mass = col("body_mass_g")
        let bySpecies = penguins
          .dropNulls("body_mass_g")
          .groupBy("species")
          .agg(len().alias("n"),
            mass.mean.alias("mean"),
            mass.alias("spread")) # a list
          .sort("species")

        let table = tabella(bySpecies,
            rownameCol = "species"):
          tabHeader "Palmer penguins"
          tabSpanner "Body mass (g)",
            ["mean", "spread"]
          fmtInteger "mean"
          fmtNanoplot "spread",
            plotType = "boxplot",
            autoscale = true
    column:
      nbTable table.slideLook("0.6em")
  nbTextSmall """
After R's gt and Python's Great Tables, in plain Nim:
every table in this talk is made with it
([deep dive](deepdive/penguins_polars.html)).
"""
  speakerNote """
The last block: display tables, for people to read.
tabelline follows gt and Great Tables, with the same verbs:
header, spanners over columns, formatted numbers, nanoplots.
Here one boxplot per species, on a shared axis:
Gentoo weigh a kilo more.
Also mine, from November 2026, also mostly written with Claude.
"""

template nanuqSlides* =
  slide: nanuqSlide(nb)
  slide: tabellineSlide(nb)
