# The voyage and its islands

Status: accepted · Updated 2026-11-24

## Context

The submitted description promises an intro, seven islands and a conclusion. This record says what each part must show and why the voyage has its shape; the slide by slide plan is [outline.md](../outline.md).

## Decision

### The shape

- **Order.** Opening (title, about me); Intro; Accessible Performance; Success Stories; Data Stack; Interoperability; An Expressive Language; Interactivity; Notebook; Conclusion; Thank you.
- **Names and order** (Pietro, 2026-10-27): the first island is just "Accessible Performance" (shorter on the map; slide 2.4 still explains "no ceiling"), and Interoperability comes before An Expressive Language. Files and slide IDs follow the new numbers (`slides/island4_interop.nim`, `slides/island5_*.nim`).
- **Travel metaphor as the spine**: a map slide at the start of each island shows progress and keeps the audience oriented.
- **Vertical sections** (Pietro, 2026-10-26): the top row of the deck is the voyage (opening, intro, islands, conclusion, thank you), each section's slides are below its map slide, so a section is easy to skip or shorten on stage.
- **Time per island**: the Data Stack gets the most (3.5 min), since a PyData audience judges it hardest; Island 1 the least (1 min, one slide: Pietro, 2026-11-24, performance is a given), performance is not the speaker's main interest and depth is in Mamy's talk; Success Stories 2.5 min for three stories, told, not demoed.

### What each part shows

- **Intro**: why there are so many languages in scientific computing (Fortran to Python, with C, C++, R and Julia still important) and that there is space for more.
- **Island 1, Accessible Performance** (Pietro, 2026-11-24): one slide, "Reads like Python, runs like C": the Vandermonde matrix written with for loops in Python and in Nim side by side, and a mini benchmark against the Python loops and NumPy (the case study of Jeff Bezanson's thesis behind Julia). The point, said by the speaker: in Nim you are allowed to write for loops. A pointer in orange to "no ceiling" (down to assembly when you need it); Mamy's talk is named in the speaker notes only (Pietro). The benchmark is reproducible (`bench/vandermonde/run.sh`), with its code and caveats in a deep dive.
- **Island 2, Success Stories** (Pietro, 2026-10-27): competent people did science with Nim, named by name and nick: Brent Pedersen in bioinformatics, Vindaar (Sebastian Schmidt) in physics, and QEX, the lattice QCD framework by James Osborn and Xiao-Yong Jin at Argonne (Pietro, 2026-10-28), a team and a framework rather than one person, the most active scientific Nim project since 2024. Success means using Nim to advance science; slides stay on the science, the libraries Vindaar built get a line (Island 3 covers them). Deep dives go further, plus one on success stories beyond science.
- **Island 3, Data Stack** (Pietro, 2026-10-27 and 2026-10-28): Arraymancer, Datamancer and ggplotnim as the Nim mirror of NumPy, pandas/dplyr and matplotlib/ggplot2, after Jake VanderPlas's Python Data Science Handbook, through the penguins dataset (seaborn's CSV; the penguins slide shows Allison Horst's whole artwork). Bottom-up: tensors, dataframes built on tensors, plots built on dataframes. The tensor slide shows NumPy-like tensors and linear algebra, not the penguins. Arraymancer is presented as "a solid ndarray with linear algebra, a compact deep learning framework, and the seeds of scikit-learn", with the maintenance facts (last release October 2024) in the speaker notes. Rocks ahead (Pietro): classic ML is only seeds, multiple tensor libraries, an ecosystem that depends on a few contributors.
- **Island 4, Interoperability**: wrapping C and C++, two-way bridges to Python, R and Julia (of varying maturity), and Nim used from Python almost as easily as Rust; both directions shown.
- **Island 5, An Expressive Language** (Pietro, 2026-10-27): custom operators as the easy feature, with hand-written geometry (points, lines, planes, join and meet; `Vec` is a `distinct Point`), and metaprogramming as the advanced one, with Vindaar's unchained (Kepler's third law with `declareUnits` for solar and earth masses). The new units live in `slides/island5_units.nim` and only `SolarMass`, `Msun`, `EarthMass`, `Mearth` are exported to the deck, since `declareUnits` also regenerates the compound SI types.
- **Island 6, Interactivity**: Nim compiled to JavaScript with a snappy port of a fun Shiny app, and an honest note that notebook-style interactivity (Jupyter, Marimo) is not there yet.
- **Island 6 app** (Pietro, 2026-11-24): the plant app, Nick Strayer's Shiny for Python app that Pietro first ported in nblog, contrasted with the original running in the browser with shinylive (offline, exported into `docs/shiny/` by the build, not committed). The Nim port uses Karax (its `buildHtml` code is shown on the slide, Pietro asked for it) and a canvas bound with importjs; the slider lines of that code are draggable with zogyn, Pietro's declarative dragging library, and reorder the app's sliders (both are dependencies in `atlas.lock`); the curve is a module that runs on both backends (the deep dive also plots it with ggplotnim). Rocks ahead is the REPL: experiments only, and a REPL fits a statically typed, ahead-of-time compiled language badly.
- **Island 7, Notebook**: literate programming and computing, which Jupyter made central, and nimib, the Nim option that goes in an unexpected direction, with at least one of its limitations.
- **Conclusion**: one takeaway for the beginner, one for the builder, why Nim is still niche, and an opinionated view of the language, the ecosystem, the community and the governance.
- **Thank you** (Pietro, 2026-10-26): an animation in Nim with p5nim (a small show of the JavaScript backend, K2): a grid of points flies along curves into "Thank You!" and "Questions?" and back, in a loop, after a sketch by Okazz (CC BY-NC-SA 3.0, like the slide's code; the rest of the repo is MIT). It stays on screen during Q&A, last on the top row; it builds on its own too (`docs/thank_you.html`).

## Options considered

- A plain agenda slide instead of the map: the abstract already sells the voyage.
- One flat row of slides instead of vertical sections.
- Island 2: two shapes of success (toolmaker vs scientist) or a timeline of the pioneers, set aside to keep it about science; QEX as a line in Island 3 instead of a story, set aside since QEX is science.
- Island 3: nimpy with pandas, set aside since the island is about Nim's own stack; "more than an ndarray" for Arraymancer, set aside because it reads as parity with PyTorch.
- Island 5: hand-written physical units for the easy example (a repeat of the second); a sailing theme for the examples (dropped: enough sea already).
- Thank you: straight moves with easing, or bursting into big circles (Pietro chose curves); a separate "Questions?" slide; a static slide with links.

## Consequences

- Three stories in 2.5 minutes: about 30 seconds each; any story's code can be skipped on stage, the deep dives carry the depth.
- Five content slides in Island 5's 2.5 minutes: each example is two quick slides; the line-meets-plane slide or the units declaration can be dropped if rehearsal runs long.
- The animation only draws while its slide is shown and uses no network; check it on the presentation laptop.

## History

- 2026-10-26: skeleton deck (PR #8), vertical sections (PR #9), thank-you animation (PR #12, #13, #15).
- 2026-10-27: Island 2 stories, Island 3 stack, Island 4 (now 5) operators and units (PR #19, #20, #17); names and order (PR #23).
- 2026-10-28: Arraymancer scope, bottom-up Island 3 (PR #24); QEX story (PR #25).
- 2026-11-24: Island 6, the plant app in Shiny (shinylive) and in Nim, its deep dive, the REPL as rocks ahead.
- 2026-11-24: Island 6, the Nim plant in Karax with its code on the slide, slider lines dragged with zogyn.
- 2026-11-24: Island 1 in one slide with the Vandermonde benchmark, 1 minute.
- 2026-11-24: moved from the OpenSpec abstract spec, the outline's decisions and the un-archived changes arraymancer-scope and island2-qex to this record.
