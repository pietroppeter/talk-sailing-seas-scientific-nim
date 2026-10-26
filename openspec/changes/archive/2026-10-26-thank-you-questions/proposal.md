# Proposal

## Why

The Thank You slide stays on screen during Q&A, so it can also invite the questions: the animation alternates "Thank You!" and "Questions?", with the grid in between.

## What Changes

- `slides/thank_you.nim`: the loop becomes grid → "Thank You!" → grid → "Questions?" → grid. Each message has its own letter targets and its own shuffle of the grid, which is sized for the longest message. Letter colors loop over Okazz's palette ("Questions?" has 10 letters, the palette 9). Each point has a random grid color and fades to its letter's color while it flies. `easeInOutCubic` moves next to `progress`, and the shuffle links Fisher–Yates.
- `slides/thank_you_explainer.nim`: updated for the two messages, with links to the Fisher–Yates shuffle and to the easing function, notes on `pixelDensity` and on the `toJs` escape hatch, and a "Try it" section.
- Living outline: slide 9.6 alternates the two messages.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None: no requirement changes (`skip_specs: true`).

## Impact

- `slides/thank_you.nim`, `slides/thank_you_explainer.nim`, `openspec/outline.md` (on archive).
- Timing unchanged: the slide is on screen during Q&A.
