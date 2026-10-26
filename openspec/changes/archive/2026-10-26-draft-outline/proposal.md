# Proposal

## Why

The deck has only a title slide, while the specs already fix what the talk promises: an intro, seven islands and a conclusion in about 25 minutes. Before writing slides we need a first outline that turns those promises into sections, a time budget and a list of slides, so that every later iteration fills in an agreed skeleton instead of a blank page. It is one month to the conference (26 November 2026), so the shape has to settle now.

## What Changes

- A first outline of the whole talk: narrative arc, time budget per section, and each section broken down into numbered slides, with unknown content marked `[tbd]`.
- The talk's key messages become a spec, so every section can be checked against them.
- One section file per outline section in `slides/` (intro, the seven islands, conclusion), each with a section title slide and placeholder slides carrying the outline's slide titles, wired into `index.nim`, so the published deck shows the skeleton of the whole talk.
- Speaker notes on each placeholder slide with the outline's one-line description of that slide.

## Capabilities

### New Capabilities

- `key-messages`: the four messages (K1-K4) the whole talk must leave with the audience, and where each one is carried. Draft wording, to refine with Pietro.

### Modified Capabilities

- `audience`: adds a finer breakdown of the audience by background (Python, R, C++, other) and by role (library authors, users). Draft, to refine with Pietro.
- `abstract`: the title slide uses the short form "Sailing Seas of Scientific Nim"; the programme keeps "Sailing the Seas of Scientific Nim".
- `format`: the readiness requirement now says examples are built into the deck and the talk does not rely on live demos.

## Impact

- New files `slides/intro.nim`, `slides/island1.nim` ... `slides/island7.nim`, `slides/conclusion.nim`; `index.nim` imports them after the title slide.
- `slides/title.nim` keeps the short form "Sailing Seas of Scientific Nim", so the title fits on one line.
- The published deck on GitHub Pages grows from one slide to a full skeleton (43 slides, mostly placeholders).
- No examples, images or theme changes in this iteration.
- No live demos in the talk: examples are code and output rendered in the deck (see the `format` delta).
