# Proposal

## Why

Island 3 is still made of placeholders. It is where the talk shows that Nim has the building blocks of data science (K2) and that real work can be done with them, with honest limits (K3): the stack mirrors NumPy, pandas/dplyr and matplotlib/ggplot2, as in Jake VanderPlas's Python Data Science Handbook (Pietro, 2026-10-27).

## What Changes

- ADDED 4.2 **The stack**: a table mapping Python, R and Nim for tensors, dataframes and plots (NumPy / arrays / Arraymancer, pandas / dplyr / Datamancer, matplotlib / ggplot2 / ggplotnim), framed by the VanderPlas handbook.
- 4.2 becomes 4.3 **Meet the penguins**: Allison Horst's penguin artwork on the left (image-left layout), the dataset in two lines and its credits.
- 4.3 becomes 4.4 **Dataframes: Datamancer**: read the CSV, drop the missing, mean body mass and flipper length per species, with its output.
- 4.4 becomes 4.5 **Plots: ggplotnim**: flipper length against body mass colored by species, made when the deck is built.
- 4.5 becomes 4.6 **Tensors: Arraymancer**: two columns as `Tensor[float]`, a z-score with broadcasting operators, their correlation (0.87); a pointer to Mamy's talk and a link to the explainer.
- 4.6 becomes 4.7 **Rocks ahead**: good pieces and a collective start gathered by SciNim; no scikit-learn; several tensor libraries and a scattered evolution; no continuous effort towards a modern stack.
- New explainer `slides/island3_penguins_explainer.nim` (`docs/island3_penguins_explainer.html`), linked from slide 4.6: loading and missing values, formulas, group and summarize, three plots, Simpson's paradox on the bills with tensors, k-means from Arraymancer, rocks ahead, further reading.
- New dependencies: Arraymancer, Datamancer, ggplotnim, added with atlas. Data `docs/data/penguins.csv` (seaborn's copy, CC0) and artwork `docs/images/lter_penguins.png` (CC0, by Allison Horst) are vendored.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None.

## Impact

- `slides/island3_datastack.nim`, new `slides/island3_penguins_explainer.nim`, `docs/data/penguins.csv`, `docs/images/lter_penguins.png`, `.github/workflows/pages.yml` (libcairo2, explainer build), `.gitignore`, `README.md`, `talk-sailing-seas-scientific-nim.nimble`, `nim.cfg`, `openspec/outline.md` (on archive).
- Island 3 grows from 5 to 6 content slides in the same 3.5 minutes.
