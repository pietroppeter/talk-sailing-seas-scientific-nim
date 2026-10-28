# Proposal

## Why

Arraymancer presents itself as inspired by NumPy and PyTorch, targeting n-dimensional arrays, classic machine learning as in scikit-learn, and deep learning. A review of its source (2026-10-28) shows the three are at different stages: the ndarray is solid, the machine learning part is a few algorithms (k-means, DBSCAN, PCA, least squares), and the deep learning part is a small framework whose interface the README calls unstable. Island 3 said "more than an ndarray", which reads as parity with PyTorch. The island also reads better bottom-up: tensors, then dataframes built on tensors, then plots built on dataframes (Pietro, 2026-10-28).

## What Changes

- 4.6 **Tensors: Arraymancer** moves up to 4.4, before Datamancer and ggplotnim; its example now reads the CSV and drops the missing values, and its tagline says "inspired by NumPy and PyTorch: a solid ndarray, with the seeds of scikit-learn (k-means, PCA) and of PyTorch (autograd, layers, CUDA)". The speaker notes carry the maintenance facts (last release October 2024, a few commits a year since).
- 4.4 **Dataframes: Datamancer** becomes 4.5 and starts at group by; 4.5 **Plots: ggplotnim** becomes 4.6.
- 4.8 **Rocks ahead**: the first bullet becomes "beyond the ndarray, only seeds: a few ML algorithms (no scikit-learn), a small neural network library (no PyTorch)".
- The penguins explainer gets a section "What else is in Arraymancer" (the three parts and their stage, flambeau for PyTorch itself) and the same rocks ahead wording; slide 4.3 mentions it.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None.

## Impact

- `slides/island3_datastack.nim`, `slides/island3_penguins_explainer.nim`, `openspec/outline.md` (on archive).
- Same 3.5 minutes and number of slides.
