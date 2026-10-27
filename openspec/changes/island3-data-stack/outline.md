# Outline Delta

## Sections

### 4. Island 3: Data Stack (~3.5 min)

The basic building blocks of the data ecosystem, through an exploration of the penguins dataset: Arraymancer, Datamancer and ggplotnim, the Nim mirror of NumPy, pandas/dplyr and matplotlib/ggplot2. Carries K2 and K3.

4.1 **Island 3** - section title on the map.
4.2 **The stack** - the building blocks of data science as in the Python Data Science Handbook by Jake VanderPlas: a table of tensors, dataframes and plots in Python (NumPy, pandas, matplotlib), R (arrays, dplyr, ggplot2) and Nim (Arraymancer, Datamancer, ggplotnim).
4.3 **Meet the penguins** - Allison Horst's artwork in full on the top half, then a short summary of the dataset (344 penguins, three species, three islands near Palmer Station) and of what the explainer covers, with its link; data and artwork credits.
4.4 **Dataframes: Datamancer** - inspired by dplyr, built on Arraymancer: read the CSV, drop missing values with a formula, mean body mass (g) and flipper length (mm) per species [example].
4.5 **Plots: ggplotnim** - a port of ggplot2, using Datamancer dataframes: flipper length against body mass colored by species [example].
4.6 **Tensors: Arraymancer** - four columns stacked into a 342 x 4 matrix, standardized with broadcasting, and the 4 x 4 correlation matrix from a matrix product [example]; more than an ndarray: linear algebra, autograd, neural networks, CPU, CUDA and OpenCL backends.
4.7 **SciNim** - the organization that gathers the scientific Nim libraries; its getting started site (tutorials and a list of libraries); a few more libraries: flambeau (libtorch bindings), nim-plotly (plotly.js; started by Brent Pedersen and donated to SciNim, in the speaker notes), numericalnim (integration, ODEs, optimization, interpolation).
4.8 **Rocks ahead** - no scikit-learn, ML algorithms are scattered; multiple tensor libraries; the ecosystem depends on a few contributors (Vindaar, mratsim, Clonkk, HugoGranstrom): when life happens, development stops.

Unchanged: 0-3, 5-9

## Decisions

- ADDED: Island 3 stack (Pietro, 2026-10-27): Arraymancer, Datamancer and ggplotnim, presented as the Nim mirror of the NumPy, pandas/dplyr and matplotlib/ggplot2 stack, following Jake VanderPlas's Python Data Science Handbook. Order on the slides: the stack, the penguins (linking the explainer), dataframe, plot, tensors, then SciNim and rocks ahead. Each library slide says where it comes from (Datamancer: inspired by dplyr, built on Arraymancer, below its output; ggplotnim: a port of ggplot2 on Datamancer). The penguins slide shows the whole artwork on top (Pietro picked it over an image-left crop and a two-column layout). The tensor example shows multidimensional tensors (a correlation matrix), and Mamy's talk is not about Arraymancer, so the island does not point to it. The rocks ahead are Pietro's: no scikit-learn-like library, multiple tensor libraries, and an ecosystem that depends on a few contributors. The data is seaborn's penguins CSV (missing values are empty fields, which Datamancer reads as NaN). Alternative: nimpy with pandas, set aside since the island is about Nim's own stack.
