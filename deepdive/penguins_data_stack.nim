import std / [math, strutils, sequtils]
# only `%` from json: its `{}` would get in the way of `f{...}` formulas
from std / json import `%`, `[]=`
import nimib
import deepdive # useDeepDive, and the blocks of blocks.nim
import nimib / highlight
import ggplotnim
import arraymancer / [ml, nn, autograd] # k-means, the network
import plotly
import ../slides/nbplotly # nbPlotly: an interactive nim-plotly plot in nimib

# A nimib document that explains the penguins exploration of Island 3
# (slides 4.2 to 4.7 and 4.10, in slides/island3_datastack.nim and island3_network.nim;
# nanuq and tabelline have their own deep dive, penguins_polars.nim):
#   nim r deepdive/penguins_data_stack.nim
# writes docs/deepdive/penguins_data_stack.html.
# The code below runs when the page is built, like on the slides.

nbInit(thisFileRel = "deepdive/penguins_data_stack.nim")
const ownSource = staticRead("penguins_data_stack.nim")
nb.useDeepDive("penguins_data_stack", ownSource)
nbText """
# Penguins with the Nim data stack

In the talk [Sailing Seas of Scientific
Nim](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/slides.html),
Island 3 sails past the Nim data stack:
tensors with [Arraymancer](https://github.com/mratsim/Arraymancer),
dataframes with [Datamancer](https://github.com/SciNim/Datamancer)
and plots with [ggplotnim](https://github.com/Vindaar/ggplotnim).
They play the roles of NumPy, pandas and matplotlib in the
[Python Data Science
Handbook](https://jakevdp.github.io/PythonDataScienceHandbook/)
by Jake VanderPlas, or of arrays, dplyr and ggplot2 in R.
The slides only have room for one example each.
This page explores the penguins a bit further,
with the same three libraries.
The two newest blocks of the slides, nanuq and tabelline,
have [a deep dive of their own](penguins_polars.html).
All the code on this page runs when the page is built,
and the output below each block is its real output.
"""

nbText """
## The data

The [palmerpenguins](https://allisonhorst.github.io/palmerpenguins/)
dataset has 344 penguins of three species,
from three islands of the Palmer Archipelago, Antarctica,
collected by Kristen Gorman at Palmer Station LTER.
It is CC0, and the friendly replacement of the iris dataset.
We use the CSV that ships with seaborn, where missing values
are empty fields
([docs/data/penguins.csv](../data/penguins.csv)).
"""
nbCode:
  let raw = readCsv("data/penguins.csv")
  echo raw.head(5)

nbText """
Datamancer guesses the type of each column.
Empty fields in a number column become NaN,
and NaN fails every comparison, so a filter on a
positive body mass keeps the penguins that were measured:
"""
nbCode:
  let df = raw.filter(f{float -> bool: `body_mass_g` > 0.0})
  echo raw.len, " penguins, ", df.len, " measured"

nbText """
`f{...}` is a formula: a macro that turns the expression
into a loop over the columns, compiled and typed.
The backticks name a column, and `float -> bool`
gives the type of the input columns and of the result.
Without the hint, Datamancer guesses from the expression,
and asks for a hint when it cannot.
"""

nbText """
## Group and summarize

As in dplyr (or `groupby` and `agg` in pandas),
group the rows and reduce each group with `<<`:
"""
nbCode:
  echo df.group_by(["species", "island"]).summarize(
    f{string -> int: "n" << len(col("species"))},
    f{float: "mass" << mean(`body_mass_g`)})

nbText """
Adelie penguins live on all three islands,
Chinstrap only on Dream and Gentoo only on Biscoe.
Some penguins have no recorded sex, so we filter them
out before splitting by sex:
"""
nbCode:
  echo df.filter(f{string -> bool: `sex` != ""})
    .group_by(["species", "sex"])
    .summarize(f{float: "mass" << mean(`body_mass_g`)})
    .arrange("mass")

nbText """
## Plots

ggplotnim is a grammar of graphics, as ggplot2:
a dataframe, aesthetics that map columns to x, y and color,
then layers added with `+`.
The slide plots flipper length against body mass:
"""
nbCode:
  ggplot(df, aes("flipper_length_mm", "body_mass_g",
                 color = "species")) +
    geom_point() +
    ggsave("images/penguins_explainer_mass.png")
nbImage("images/penguins_explainer_mass.png")

nbText """
A histogram of the bill length, one color per species,
with the bars of each species drawn over each other:
"""
nbCode:
  ggplot(df, aes("bill_length_mm", fill = "species")) +
    geom_histogram(binWidth = 1.0, position = "identity",
                   alpha = 0.6) +
    ggsave("images/penguins_explainer_bill.png")
nbImage("images/penguins_explainer_bill.png")

nbText """
And the classic one: bill length against bill depth.
"""
nbCode:
  ggplot(df, aes("bill_length_mm", "bill_depth_mm",
                 color = "species")) +
    geom_point() +
    ggsave("images/penguins_explainer_simpson.png")
nbImage("images/penguins_explainer_simpson.png")

nbText """
Inside each species, a longer bill goes with a deeper bill.
Taken all together, the trend looks the other way,
because Gentoo have long but shallow bills.
This is Simpson's paradox, and the tensors below
put a number on it.
"""

nbText """
The same plot, interactive, with
[nim-plotly](https://github.com/SciNim/nim-plotly),
the Nim bindings to plotly.js:
hover on a penguin to see its island and sex,
click on a species in the legend to hide it.
One trace per species, built from the groups of the dataframe:
"""
nbCode:
  var traces: seq[Trace[float]]
  for (key, sub) in groups(df.group_by("species")):
    let t = Trace[float](mode: PlotMode.Markers,
                         `type`: PlotType.Scatter, name: $key[0][1])
    t.xs = sub["bill_length_mm", float].toSeq1D
    t.ys = sub["bill_depth_mm", float].toSeq1D
    let islands = sub["island", string].toSeq1D
    let sexes = sub["sex", string].toSeq1D
    for i in 0 ..< sub.len:
      t.text.add islands[i] & ", " & sexes[i].toLowerAscii
    traces.add t
  let bills = Plot[float](traces: traces, layout: Layout(
    xaxis: Axis(title: "bill length (mm)"),
    yaxis: Axis(title: "bill depth (mm)")))
nbPlotly(bills)
nbText """
`nbPlotly` is a small helper of this repository
([slides/nbplotly.nim](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim/blob/main/slides/nbplotly.nim)):
it turns the plot into JSON and adds a div and a script
that draw it with plotly.js.
"""

nbText """
## Tensors

Every column of a dataframe is a tensor underneath,
and `df[name, float]` gives it as a `Tensor[float]`.
Arraymancer spells the broadcasting operators with a dot
(`-.`, `/.`, `*.`), so a broadcast is always visible.
The mean of the product of two z-scores is the
(Pearson) correlation:
"""
nbCode:
  proc zscore(t: Tensor[float]): Tensor[float] =
    (t -. t.mean) /. t.std

  proc corr(df: DataFrame, x, y: string): float =
    mean(zscore(df[x, float]) *. zscore(df[y, float]))

  echo "flipper vs mass: ", corr(df, "flipper_length_mm", "body_mass_g").round(2)
  echo "bill length vs depth, all: ", corr(df, "bill_length_mm", "bill_depth_mm").round(2)
  for (key, sub) in groups(df.group_by("species")):
    echo "  ", key[0][1], ": ", corr(sub, "bill_length_mm", "bill_depth_mm").round(2)

nbText """
Strong and positive for flipper length and body mass,
as on the slide.
For the bills, negative overall and positive within
every species: Simpson's paradox in numbers.
(`std` here divides by n - 1, so these are a hair below
the exact correlation, which a statistics library would give.)
"""

nbText """
## Some machine learning

Arraymancer has a few classic algorithms, among them
k-means clustering.
Put the four measurements in a matrix, standardize
each column, and ask for three clusters:
"""
nbCode:
  let cols = ["bill_length_mm", "bill_depth_mm",
              "flipper_length_mm", "body_mass_g"]
  var X = newTensor[float](df.len, cols.len)
  for j in 0 ..< cols.len:
    X[_, j] = zscore(df[cols[j], float]).reshape(df.len, 1)

  let clusters = kmeans(X, n_clusters = 3).labels
  var withClusters = df
  withClusters["cluster"] = clusters
  echo withClusters.group_by(["species", "cluster"])
    .summarize(f{string -> int: "n" << len(col("species"))})

nbText """
Without looking at the species, k-means puts every
Gentoo in a cluster of its own.
Adelie and Chinstrap overlap in size and shape,
so the other two clusters mix them:
the measurements alone do not tell those two apart.
What Nim lacks is a library that collects the classic
algorithms behind one consistent interface,
like scikit-learn does for Python,
with models, pipelines, cross validation and metrics.
"""

nbText """
## A small neural network

The deep learning slide trains a network
on the same four measurements.
Here it is again, step by step, on the matrix `X`
of the k-means section.
A network is declared with the `network` macro:
the layers, then the forward pass.
Four measurements go in, sixteen hidden units,
three species come out, one score each.
The macro must run at the top level of a module,
since it declares a type:
"""
nbCode:
  network PenguinNet:
    layers:
      hidden: Linear(4, 16)
      output: Linear(16, 3)
    forward x:
      x.hidden.relu.output

nbText """
The species become the numbers 0, 1 and 2,
and the rows are split in two:
the even rows train the network, the odd rows test it.
`index_select` picks rows of a tensor,
as fancy indexing does in NumPy;
the layers compute in 32-bit floats.
"""
nbCode:
  let speciesNames = ["Adelie", "Chinstrap", "Gentoo"]
  var y = newTensor[int](df.len)
  for i, s in df["species", string]:
    y[i] = speciesNames.find(s)
  let even = toSeq(countup(0, df.len - 1, 2))
  let odd = toSeq(countup(1, df.len - 1, 2))

  let ctx = newContext Tensor[float32] # the layers are float32
  let X32 = X.astype(float32)
  let xTrain = ctx.variable X32.index_select(0, even)
  let xTest = ctx.variable X32.index_select(0, odd)
  let (yTrain, yTest) = (y.index_select(0, even), y.index_select(0, odd))

nbText """
Training is the loop of PyTorch:
forward, loss, backward, step.
`ctx` records the operations,
so that `backprop` can compute the gradients.
"""
nbCode:
  let model = ctx.init(PenguinNet)
  var optim = model.optimizer(SGD, learning_rate = 0.1'f32)
  for epoch in 1 .. 300:
    let loss = model.forward(xTrain)
      .sparse_softmax_cross_entropy(yTrain)
    loss.backprop()
    optim.update()
    if epoch mod 100 == 0:
      echo "epoch ", epoch, ", loss ", loss.value[0].round(3)

nbText """
And on the penguins it has never seen,
species by species:
"""
nbCode:
  # the species with the highest score, row by row
  # (argmax(axis = 1) does this, but its C code fails with Nim 2.2.12)
  let scores = model.forward(xTest).value
  var guess = newTensor[int](scores.shape[0])
  for i in 0 ..< scores.shape[0]:
    for k in 1 ..< 3:
      if scores[i, k] > scores[i, guess[i]]: guess[i] = k
  for k, name in speciesNames:
    let these = yTest ==. k
    let right = (guess ==. yTest) and these
    echo name, ": ", right.astype(int).sum, " right of ",
      these.astype(int).sum

nbText """
Where k-means mixed Adelie and Chinstrap,
the network mostly tells them apart,
since it learns from the labels.
The few mistakes are Chinstraps, the smallest group.
Two dozen lines, and no library outside Arraymancer.
"""

nbText """
## What else is in Arraymancer

Arraymancer's README says it is inspired by NumPy and PyTorch,
and it targets three uses: n-dimensional arrays,
classic machine learning as in scikit-learn,
and deep learning.
The three are not at the same stage.

**Tensors, the NumPy part, are solid.**
Tensors of any element type up to rank 7,
slicing with steps and masks, explicit broadcasting,
map and reduce with OpenMP, reshaping and stacking,
complex numbers, einsum, convolution,
linear algebra through BLAS and LAPACK
(solve, least squares, SVD, QR, LU, eigenvalues),
a k-d tree for nearest neighbors,
and reading and writing CSV, `.npy`, HDF5 and images.
There is no FFT and no histogram.

**Machine learning, the scikit-learn part, is a seed.**
k-means (above), DBSCAN, PCA, least squares
and a few metrics.
There are no classifiers or regressors,
no cross validation and no pipelines.

**Deep learning, the PyTorch part, is a compact framework.**
Autograd, a `network` macro to declare models,
linear, convolution, GRU, embedding and graph layers,
SGD and Adam, and CUDA (with cuDNN) and OpenCL backends,
which have fewer features than the CPU one.
In October 2026 attention and normalization layers arrived,
with an example that trains a small GPT-2-like model
on Shakespeare
([PR #695](https://github.com/mratsim/Arraymancer/pull/695)
by Phil Wang, lucidrains, who had promised it in 2023).
The README still calls the deep learning interface unstable.
To use PyTorch itself from Nim, there is
[flambeau](https://github.com/SciNim/flambeau),
bindings to libtorch.

The last release, v0.7.33, is from October 2024;
the main branch has received fixes and new layers since.
"""

nbText """
## SciNim

The [SciNim](https://github.com/SciNim) organization gathers
the scientific Nim libraries, Datamancer and unchained among them.
Its [getting started](https://scinim.github.io/getting-started/)
site has tutorials for the stack and a list of libraries.
A few more: [flambeau](https://github.com/SciNim/flambeau)
(bindings to libtorch),
[nim-plotly](https://github.com/SciNim/nim-plotly)
(interactive plots with plotly.js, started by Brent Pedersen
and donated to SciNim) and
[numericalnim](https://github.com/SciNim/numericalnim)
(integration, ODEs, optimization, interpolation).
"""

nbText """
## Rocks ahead

The pieces are good and real work was done with them:
Vindaar wrote Datamancer and ggplotnim for his PhD analysis,
and every plot in his thesis is made with ggplotnim
(see Island 2).
Three things hold the stack back.
Classic machine learning is only seeds:
a few algorithms, no scikit-learn.
There is more than one tensor library.
And the ecosystem depends on a few contributors,
Vindaar, mratsim, Clonkk and HugoGranstrom among them:
when life happens, development stops.
If you would like to help, there is room.

Two new libraries fill gaps of this stack:
[nanuq](https://github.com/pietroppeter/nanuq) brings Polars
to Nim, and [tabelline](https://github.com/pietroppeter/tabelline)
makes display tables after Great Tables and gt.
They are young, written by one person (the speaker),
mostly with an AI coding agent:
[their own deep dive](penguins_polars.html) shows them
on the same penguins.
"""

nbText """
## Further reading

- [Python Data Science Handbook](https://jakevdp.github.io/PythonDataScienceHandbook/)
  by Jake VanderPlas, the map we followed.
- [SciNim getting started](https://scinim.github.io/getting-started/),
  tutorials for the Nim data stack.
- [Arraymancer](https://mratsim.github.io/Arraymancer/),
  [Datamancer](https://scinim.github.io/Datamancer/datamancer.html)
  and [ggplotnim](https://github.com/Vindaar/ggplotnim) documentation.
- [palmerpenguins](https://allisonhorst.github.io/palmerpenguins/)
  by Allison Horst, Alison Hill and Kristen Gorman.
"""

nbText """
## Try it

Color the scatter plot by island instead of species,
or ask k-means for two clusters and see which species merge.
Clone [the
repository](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim)
and run `nim r deepdive/penguins_data_stack.nim`:
it builds this page in `docs/deepdive/penguins_data_stack.html`.
The
[README](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim#readme)
explains how to install the dependencies.
"""
nbSave
