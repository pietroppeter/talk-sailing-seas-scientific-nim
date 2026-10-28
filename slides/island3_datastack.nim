import nimib, nimiSlides
import std / [math, sequtils]
import ggplotnim
import ../my
export math, sequtils, ggplotnim

# Section 4: Island 3: Data Stack (see the latest outline in openspec)
# The basic building blocks of the data ecosystem, through an exploration of the penguins dataset. Carries K2 and K3.
# Paths are relative to docs/ (nimib's homeDir): the data is docs/data/penguins.csv,
# the plot is written to docs/images/penguins.png when the deck is built.

# dirty: Datamancer's `f{...}` formulas read `f` and type hints like `float`
# as plain identifiers, which a normal template would bind to symbols
template island3DataStackSection* {.dirty.} =
  slide:
    mapSlide(3) # 4.1
    slide: # 4.2
      nbText "## The stack"
      nbTextSmall """
The building blocks of data science, as in the
[Python Data Science Handbook](https://jakevdp.github.io/PythonDataScienceHandbook/)
by Jake VanderPlas:
"""
      nbText """
| | Python | R | Nim |
|---|---|---|---|
| Tensors | NumPy | arrays, matrices | [Arraymancer](https://github.com/mratsim/Arraymancer) |
| Dataframes | pandas | dplyr | [Datamancer](https://github.com/SciNim/Datamancer) |
| Plots | matplotlib | ggplot2 | [ggplotnim](https://github.com/Vindaar/ggplotnim) |
"""
      speakerNote """
Nim has the same three building blocks.
Arraymancer is by Mamy (mratsim).
Datamancer and ggplotnim are by Vindaar,
built for his PhD (island 2), now under SciNim.
Let's try them on a dataset you all know.
"""
    slide: # 4.3
      nbText "## Meet the penguins"
      nbImg("images/lter_penguins.png", "42%")
      nbTextSmall """
344 penguins, three species, three islands near Palmer Station, Antarctica.
[The explainer](island3_penguins_explainer.html) explores them further:
missing values, group and summarize, three plots,
Simpson's paradox with tensors, k-means clustering,
and what else is in Arraymancer.
"""
      reference """
Data: Gorman, Williams and Fraser (2014),
[palmerpenguins](https://allisonhorst.github.io/palmerpenguins/) (CC0).
Artwork by @allison_horst.
"""
      speakerNote """
Familiar to the Python crowd (seaborn ships it)
and to the R crowd (palmerpenguins).
We use seaborn's CSV, missing values are empty fields.
"""
    slide: # 4.4
      nbText "## Tensors: Arraymancer"
      nbCode:
        let df = readCsv("data/penguins.csv") # Datamancer, next
          .filter(f{`body_mass_g` > 0.0}) # drop missing
        let cols = ["bill_length_mm", "bill_depth_mm",
                    "flipper_length_mm", "body_mass_g"]
        let X = stack(cols.mapIt(df[it, float]), axis = 1) # 342 x 4
        let Z = (X -. X.mean(axis = 0)) /. X.std(axis = 0)
        let C = Z.transpose * Z / float(X.shape[0] - 1) # correlations
        echo C.map_inline(x.round(2))
      nbTextSmall """
Inspired by NumPy and PyTorch: a solid ndarray,
with the seeds of scikit-learn (k-means, PCA)
and of PyTorch (autograd, layers, CUDA).
"""
      speakerNote """
Bottom of the stack: tensors.
Read the CSV (with Datamancer, next slide) and drop the missing,
then stack four columns into a 342 x 4 matrix, standardize each
column with broadcasting (`-.` and `/.`, a dot makes the broadcast
visible), and a matrix product gives the 4 x 4 correlation matrix.
Flipper length and body mass: 0.87.
Arraymancer is by Mamy (mratsim).
Honest status: the ndarray is the solid part.
Machine learning is a handful of algorithms,
deep learning works but its API is marked unstable.
Last release October 2024, a few commits a year since.
"""
    slide: # 4.5
      nbText "## Dataframes: Datamancer"
      nbCode:
        echo df.group_by("species").summarize(
          f{float: "mass (g)" << mean(`body_mass_g`)},
          f{float: "flipper (mm)" << mean(`flipper_length_mm`)})
      nbTextSmall """
Inspired by dplyr, built on Arraymancer.
"""
      speakerNote """
Reads like dplyr or pandas: read, filter, group by, summarize.
f{...} is a formula: a macro that turns the expression
into a typed, compiled loop over the columns.
Missing numbers are NaN, so the `> 0.0` filter
of the previous slide drops them.
Mean body mass and flipper length per species:
Gentoo are the heavy ones, with the longest flippers.
"""
    slide: # 4.6
      nbText "## Plots: ggplotnim"
      nbTextSmall """
A port of ggplot2, using Datamancer dataframes.
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
    slide: # 4.7
      nbText "## SciNim"
      nbTextSmall """
[SciNim](https://github.com/SciNim) gathers the scientific Nim libraries.
Start from [getting started](https://scinim.github.io/getting-started/):
tutorials and a list of libraries. A few more:
"""
      nbText """
- [flambeau](https://github.com/SciNim/flambeau): bindings to libtorch
- [nim-plotly](https://github.com/SciNim/nim-plotly): interactive plots with plotly.js
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
    slide: # 4.8
      nbText "## Rocks ahead"
      nbText """
- beyond the ndarray, only seeds: a few ML algorithms (no scikit-learn), a small neural network library (no PyTorch)
- multiple tensor libraries
- the ecosystem depends on a few contributors (Vindaar, mratsim, Clonkk, HugoGranstrom): when life happens, development stops
"""
      speakerNote """
The pieces are good and you can do real work with them.
Beyond the ndarray there are only seeds:
a few classic ML algorithms, no scikit-learn,
and a small neural network library, no PyTorch
(flambeau binds libtorch instead).
There is more than one tensor library.
And a handful of people carry the stack:
when life happens to them, development stops.
"""
