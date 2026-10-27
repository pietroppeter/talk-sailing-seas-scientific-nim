# Proposal

## Why

Island 4 is still made of placeholders, and slides have little room for code. It is where the talk shows Nim's metaprogramming superpower (K2), and it is the island most inspired by Vindaar's unchained library: a hand-written custom operator example first, then the same idea, units and the operators between them, done for real by macros.

## What Changes

- 5.2 **Custom Operators: defined**: hand-written geometry types, `Line` and `Plane` over `Point` and `Vec` (a `distinct Point`), with `+` as join (two points make a line, a line and a point a plane) and `*` as meet (a line hits a plane in a point). The code is shown and runs when the deck is built.
- ADDED 5.3 **Custom Operators: applied**: the computation with those operators, the line through two points and the plane through three, with its output and a link to the explainer.
- 5.3 becomes 5.4 **Macros to define Units**: unchained's `declareUnits` macro adds two masses, the solar mass and the Earth mass, to its SI units; the slide shows the declaration and says what the macro and unchained's operators generate.
- ADDED 5.5 **Units applied**: Kepler's third law, the orbital period of Mars (astronomical units, solar mass) and of the Moon (kilometers, Earth mass) with unchained, with its output, and a compile time unit error.
- 5.4 becomes 5.6 **Rocks ahead**, unchanged.
- New explainer `slides/island4_operators_explainer.nim` (`docs/island4_operators_explainer.html`), linked from slide 5.3: operators in Nim (precedence, unicode operators), points and vectors, join and meet with their math, where a line meets a plane, where it breaks, and the meet of two planes as an exercise.
- New explainer `slides/island4_units_explainer.nim` (`docs/island4_units_explainer.html`), linked from slide 5.5: units as distinct floats, operators as macros, quantity concepts, `declareQuantities` and `declareUnits` with excerpts of unchained's SI units, the new masses, Kepler's third law with its units, and the pitfalls (case insensitivity, duplicated types).
- New dependency: unchained (SciNim/unchained), added with atlas.
- Helper modules `slides/island4_vectors.nim` (points, vectors, `∙` and `×`) and `slides/island4_units.nim` (the `declareUnits` call, read by slide 5.4 at build time).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `slides-tooling`: new requirement, code explainers. Code on slides stays short; an example that deserves more gets an explainer, a nimib document linked from its slide and deployed with the deck (Pietro, 2026-10-27). The Thank You explainer already follows it.

## Impact

- `slides/island4_expressive.nim`, new `slides/island4_vectors.nim` and `slides/island4_units.nim`, `slides/island4_operators_explainer.nim`, `slides/island4_units_explainer.nim`, `.github/workflows/pages.yml`, `README.md`, `talk-sailing-seas-scientific-nim.nimble`, `nim.cfg`, `openspec/outline.md` (on archive).
- Island 4 grows from 3 to 5 content slides in the same 2.5 minutes: the two code slides of each example go fast.
