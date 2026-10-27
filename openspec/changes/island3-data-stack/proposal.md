# Proposal

## Why

Island 3 is still made of placeholders. It is where the talk shows that Nim has the building blocks of data science (K2) and that real work can be done with them, with honest limits (K3): the stack mirrors NumPy, pandas/dplyr and matplotlib/ggplot2, as in Jake VanderPlas's Python Data Science Handbook (Pietro, 2026-10-27).

## What Changes

- ADDED 4.2 **The stack**: a table mapping Python, R and Nim for tensors, dataframes and plots (NumPy / arrays / Arraymancer, pandas / dplyr / Datamancer, matplotlib / ggplot2 / ggplotnim), framed by the VanderPlas handbook.
- 4.2 becomes 4.3 **Meet the penguins**: Allison Horst's penguin artwork in full on top, a short summary of the dataset and of the explainer with its link, and the credits.
- 4.3 becomes 4.4 **Dataframes: Datamancer** (inspired by dplyr, built on Arraymancer): read the CSV, drop the missing, mean body mass (g) and flipper length (mm) per species, with its output.
- 4.4 becomes 4.5 **Plots: ggplotnim** (a port of ggplot2, using Datamancer): flipper length against body mass colored by species, made when the deck is built.
- 4.5 becomes 4.6 **Tensors: Arraymancer**: a 342 x 4 matrix of measurements, standardized with broadcasting, and its correlation matrix; more than an ndarray (linear algebra, autograd, neural networks, CPU/CUDA/OpenCL).
- ADDED 4.7 **SciNim**: the organization, its getting started site, and flambeau, nim-plotly and numericalnim.
- 4.6 becomes 4.8 **Rocks ahead**: no scikit-learn, ML algorithms scattered; multiple tensor libraries; a few contributors (Vindaar, mratsim, Clonkk, HugoGranstrom), when life happens development stops.
- New explainer `slides/island3_penguins_explainer.nim` (`docs/island3_penguins_explainer.html`), linked from slide 4.3: loading and missing values, formulas, group and summarize, three plots, Simpson's paradox on the bills with tensors, k-means clustering with Arraymancer, SciNim, rocks ahead, further reading.
- New dependencies: Arraymancer, Datamancer, ggplotnim, added with atlas. Data `docs/data/penguins.csv` (seaborn's copy, CC0) and artwork `docs/images/lter_penguins.png` (CC0, by Allison Horst) are vendored.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None.

## Impact

- `slides/island3_datastack.nim`, new `slides/island3_penguins_explainer.nim`, `docs/data/penguins.csv`, `docs/images/lter_penguins.png`, `.github/workflows/pages.yml` (libcairo2, explainer build), `.gitignore`, `README.md`, `talk-sailing-seas-scientific-nim.nimble`, `nim.cfg`, `openspec/reference/conference.md` (Mamy's talk is not about Arraymancer), `openspec/outline.md` (on archive).
- Island 3 grows from 5 to 7 content slides in the same 3.5 minutes.
