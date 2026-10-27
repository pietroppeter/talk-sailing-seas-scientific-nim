# Tasks

## 5. Island 4: An Expressive Language

- [x] 5.2 Slide "Custom Operators: defined" in slides/island4_expressive.nim, with `Point`, `Vec` (a `distinct Point`), `∙` and `×` in slides/island4_vectors.nim; verify the code fits the slide in the screenshot
- [x] 5.3 Slide "Custom Operators: applied" (with the `pt` constructor; unchained is imported without `pT`, picotesla, which would clash with it): the computation and its output, built by nimib; verify the output is (2.50, 3.50, 0.00)
- [x] 5.3b Explainer slides/island4_operators_explainer.nim, linked from slide 5.3, built by the pages workflow and listed in the README; verify `nim r slides/island4_operators_explainer.nim` builds and check every output
- [x] 5.4 Slide "Macros to define Units": add unchained with atlas, declare the solar and Earth masses in slides/island4_units.nim, show the declaration read from that file next to a column with Gram and Meter read from unchained's si_units.nim; verify the code is highlighted and fits
- [x] 5.5 Slide "Units applied" (Kepler's third law): the computation with unchained and its output; verify Mars 1.88 yr, Moon 27.45 days, and `compiles(1.AU + 1.Msun)` is false
- [x] 5.5b Explainer slides/island4_units_explainer.nim, linked from slide 5.5, built by the pages workflow and listed in the README; verify it builds and check every output
- [x] 5.6 Slide "Rocks ahead" stays a placeholder, renumbered

## Whole talk

- [x] W.1 The full deck builds with `nim r index.nim`; screenshots of slides 5.2-5.5

## Workflow follow-up

- Archive the change after Pietro's review.
