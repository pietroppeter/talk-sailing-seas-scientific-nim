# Outline Delta

## Sections

### 4. Island 3: Data Stack (~3.5 min)

The basic building blocks of the data ecosystem, through an exploration of the penguins dataset: Arraymancer, Datamancer and ggplotnim, the Nim mirror of NumPy, pandas/dplyr and matplotlib/ggplot2, presented bottom-up. Carries K2 and K3.

4.1 **Island 3** - section title on the map.
4.2 **The stack** - the building blocks of data science as in the Python Data Science Handbook by Jake VanderPlas: a table of tensors, dataframes and plots in Python (NumPy, pandas, matplotlib), R (arrays, dplyr, ggplot2) and Nim (Arraymancer, Datamancer, ggplotnim).
4.3 **Meet the penguins** - Allison Horst's artwork in full on the top half, then a short summary of the dataset (344 penguins, three species, three islands near Palmer Station) and of what the explainer covers, with its link; data and artwork credits.
4.4 **Tensors: Arraymancer** - NumPy-like tensors on their own, not the penguins: a 3 x 4 matrix from a range, slicing, explicit broadcasting, and a linear system solved with LAPACK [example]; inspired by NumPy and PyTorch: a solid ndarray with linear algebra, a compact deep learning framework, and the seeds of scikit-learn; speaker notes: last release October 2024, a few commits a year since.
4.5 **Dataframes: Datamancer** - inspired by dplyr, built on Arraymancer: read the penguins CSV, drop missing values with a formula, mean body mass (g) and flipper length (mm) per species [example].
4.6 **Plots: ggplotnim** - a port of ggplot2, using Datamancer dataframes: flipper length against body mass colored by species [example].
4.7 **SciNim** - the organization that gathers the scientific Nim libraries; its getting started site (tutorials and a list of libraries); a few more libraries: flambeau (libtorch bindings), nim-plotly (plotly.js; started by Brent Pedersen and donated to SciNim, in the speaker notes), numericalnim (integration, ODEs, optimization, interpolation).
4.8 **Rocks ahead** - classic ML is only seeds: a few algorithms, no scikit-learn; multiple tensor libraries; the ecosystem depends on a few contributors (Vindaar, mratsim, Clonkk, HugoGranstrom): when life happens, development stops.

Unchanged: 0-3, 5-9

## Decisions

- ADDED: Arraymancer's scope (2026-10-28): its README targets NumPy, scikit-learn and PyTorch use cases; the talk presents the ndarray as solid and the deep learning part as a compact framework and the classic machine learning part as seeds, with the maintenance facts in the speaker notes. Island 3 goes bottom-up: tensors, dataframes, plots, and the tensor slide shows NumPy-like tensors and linear algebra rather than the penguins (Pietro). Alternative: keep "more than an ndarray", set aside because it reads as parity with PyTorch.
