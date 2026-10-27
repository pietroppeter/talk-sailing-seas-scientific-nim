import nimib, nimiSlides
import std / math
import ggplotnim
import ../my
export math, ggplotnim

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
Arraymancer is by Mamy (mratsim), whose talk is in this session.
Datamancer and ggplotnim are by Vindaar,
built for his PhD (island 2), now under SciNim.
Let's try them on a dataset you all know.
"""
    imageLeftSlide("images/lter_penguins.png", 0.45): # 4.3
      nbText "## Meet the penguins"
      nbTextSmall """
344 penguins from three islands near Palmer Station, Antarctica:
three species, bill and flipper sizes, body mass, sex.
The friendly replacement of the iris dataset.
"""
      reference """
Data: Gorman, Williams and Fraser (2014),
[palmerpenguins](https://allisonhorst.github.io/palmerpenguins/)
by Horst, Hill and Gorman (CC0).
Artwork by @allison_horst.
"""
      speakerNote """
Familiar to the Python crowd (seaborn ships it)
and to the R crowd (palmerpenguins).
We use seaborn's CSV, missing values are empty fields.
"""
    slide: # 4.4
      nbText "## Dataframes: Datamancer"
      nbCode:
        let df = readCsv("data/penguins.csv")
          .filter(f{`body_mass_g` > 0.0}) # drop missing

        echo df.group_by("species").summarize(
          f{float: "mass" << mean(`body_mass_g`)},
          f{float: "flipper" << mean(`flipper_length_mm`)})
      speakerNote """
Reads like dplyr or pandas: read, filter, group by, summarize.
f{...} is a formula: a macro that turns the expression
into a typed, compiled loop over the columns.
Missing numbers are NaN, so `> 0.0` drops them.
Gentoo are the heavy ones, with the longest flippers.
"""
    slide: # 4.5
      nbText "## Plots: ggplotnim"
      nbCode:
        ggplot(df, aes("flipper_length_mm", "body_mass_g",
                       color = "species")) +
          geom_point() +
          ggsave("images/penguins.png", width = 500, height = 320)
      nbImg("images/penguins.png", "50%")
      speakerNote """
The grammar of graphics, as in R's ggplot2:
data, aesthetics, then layers added with `+`.
Flipper length and body mass go together,
and the species form clusters.
Backends: PNG/PDF via cairo, SVG, TikZ, Vega-Lite.
"""
    slide: # 4.6
      nbText "## Tensors: Arraymancer"
      nbTextSmall """
Underneath, every column is a tensor:
"""
      nbCode:
        let
          mass = df["body_mass_g", float]
          flipper = df["flipper_length_mm", float]
        proc zscore(t: Tensor[float]): Tensor[float] =
          (t -. t.mean) /. t.std

        echo mean(zscore(mass) *. zscore(flipper)).round(2)
      nbTextSmall """
More on Arraymancer in Mamy's talk, in this session.
[The penguins explored further here](island3_penguins_explainer.html).
"""
      speakerNote """
A column comes out of the dataframe as a Tensor[float].
`-.`, `/.` and `*.` are the broadcasting operators,
spelled with a dot so the broadcast is visible.
The mean of the product of z-scores is the correlation
of flipper length and body mass: strong, as the plot showed.
"""
    slide: # 4.7
      nbText "## Rocks ahead"
      nbText """
- good pieces and a collective start, gathered by [SciNim](https://github.com/SciNim)
- no scikit-learn: no systematic take on classic ML
- several tensor libraries, a scattered evolution
- no continuous effort towards a modern stack
"""
      speakerNote """
The pieces are good and you can do real work with them.
But there was an initial collective effort, not a continuous one:
SciNim collects libraries that grew scattered.
Classic machine learning has no scikit-learn,
and the stack has not kept up with the modern generation
of data tools.
"""
