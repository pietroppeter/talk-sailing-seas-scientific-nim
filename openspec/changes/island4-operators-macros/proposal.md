# Proposal

## Why

Island 4 is still made of placeholders, and slides have little room for code. It is where the talk shows Nim's metaprogramming superpower (K2), and it is the island most inspired by Vindaar's unchained library: a hand-written custom operator example first, then the same idea, units and the operators between them, done for real by macros.

## What Changes

- 5.2 **Custom operators**: hand-written geometry types, `Line` and `Plane` over `Point` and `Vec`, with `+` as join (two points make a line, a line and a point a plane) and `*` as meet (a line hits a plane in a point). The code is shown and runs when the deck is built.
- ADDED 5.3 **A shadow at sea**: the non trivial computation with those operators, where the shadow of the mast top falls on the sea, with its output.
- 5.3 becomes 5.4 **Units with a macro**: unchained's `declareUnits` macro adds two sailing units, nautical mile and knot, to its SI units; the slide shows the declaration and says what the macro and unchained's operators generate.
- ADDED 5.5 **Hull speed**: a computation with unchained mixing feet, SI and knots, with its output, and a compile time unit error.
- 5.4 becomes 5.6 **Rocks ahead**, unchanged.
- New explainer `slides/island4_operators_explainer.nim` (`docs/island4_operators_explainer.html`), linked from slide 5.3: operators in Nim (precedence, unicode operators), points and vectors, join and meet with their math, the shadow, where it breaks, and the meet of two planes as an exercise.
- New dependency: unchained (SciNim/unchained), added with atlas.
- Helper modules `slides/island4_vectors.nim` (points, vectors, `∙` and `×`) and `slides/island4_units.nim` (the `declareUnits` call, read by slide 5.4 at build time).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `slides-tooling`: new requirement, code explainers. Code on slides stays short; an example that deserves more gets an explainer, a nimib document linked from its slide and deployed with the deck (Pietro, 2026-10-27). The Thank You explainer already follows it.

## Impact

- `slides/island4_expressive.nim`, new `slides/island4_vectors.nim` and `slides/island4_units.nim`, `slides/island4_operators_explainer.nim`, `.github/workflows/pages.yml`, `README.md`, `talk-sailing-seas-scientific-nim.nimble`, `nim.cfg`, `openspec/outline.md` (on archive).
- Island 4 grows from 3 to 5 content slides in the same 2.5 minutes: the two code slides of each example go fast.
