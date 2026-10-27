# Outline Delta

## Sections

### 4. Island 3: Data Stack (~3.5 min)

The basic building blocks of the data ecosystem, through an exploration of the penguins dataset: Arraymancer, Datamancer and ggplotnim, the Nim mirror of NumPy, pandas/dplyr and matplotlib/ggplot2. Carries K2 and K3.

4.1 **Island 3** - section title on the map.
4.2 **The stack** - the building blocks of data science as in the Python Data Science Handbook by Jake VanderPlas: a table of tensors, dataframes and plots in Python (NumPy, pandas, matplotlib), R (arrays, dplyr, ggplot2) and Nim (Arraymancer, Datamancer, ggplotnim).
4.3 **Meet the penguins** - image-left with Allison Horst's artwork: 344 penguins from three islands near Palmer Station, three species, the friendly replacement of the iris dataset; data and artwork credits.
4.4 **Dataframes: Datamancer** - read the CSV, drop missing values with a formula, mean body mass and flipper length per species [example].
4.5 **Plots: ggplotnim** - flipper length against body mass colored by species, grammar of graphics as in ggplot2 [example].
4.6 **Tensors: Arraymancer** - every column is a tensor underneath: z-scores with the broadcasting operators and the correlation of flipper length and body mass [example]; pointer to Mamy's talk; the slide links its explainer.
4.7 **Rocks ahead** - good pieces and an initial collective effort, gathered by SciNim; no scikit-learn, no systematic take on classic ML; several tensor libraries, a scattered evolution; no continuous effort towards a modern stack.

Unchanged: 0-3, 5-9

## Decisions

- ADDED: Island 3 stack (Pietro, 2026-10-27): Arraymancer, Datamancer and ggplotnim, presented as the Nim mirror of the NumPy, pandas/dplyr and matplotlib/ggplot2 stack, following Jake VanderPlas's Python Data Science Handbook. Order on the slides: dataframe, plot, then the tensor underneath. The rocks ahead are Pietro's: good pieces and an initial collective effort, but no continuous effort, no modern stack, a scattered evolution, no systematic classic ML, other tensor variants, and SciNim collecting the scattered libraries. The data is seaborn's penguins CSV (missing values are empty fields, which Datamancer reads as NaN). Alternative: nimpy with pandas, set aside since the island is about Nim's own stack.
