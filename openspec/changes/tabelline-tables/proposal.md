# Proposal

## Why

The deck and the explainers show their tables as plain Markdown or hand-written HTML: no units, no source notes, numbers without bars, nothing that points the eye to what matters. Pietro wrote [tabelline](https://github.com/pietroppeter/tabelline), great tables for Nim after R's gt and Python's Great Tables (2026-11-07), and asked to redo the talk's tables with it. It is also one more piece of the Nim scientific ecosystem shown at work.

## What Changes

- Dependency: tabelline (`requires "https://github.com/pietroppeter/tabelline#head"`); nimib moves from 0.4.1 to 0.4.3, which tabelline's `nbTable` block needs.
- `my.nim`: `slideLook` (the deck's font, colours and transparent background for a tabelline table, undoing reveal.js' table styles) and `highlightCols` (the theme's light blue behind columns); a "A table" demo slide in the style test deck.
- Slide 3.3 (Brent Pedersen): the tools table, with links, citations as bars and stars.
- Slide 4.2 (The stack): the Python / R / Nim table, with the Nim column highlighted.
- Brent Pedersen explainer: five tables (file formats, run times with bars and "vs mosdepth", tools with stars and citations as bars, tools by others, the polyglot table in year order with the Nim rows highlighted).
- Vindaar explainer: the limits table, with scientific notation, a "previous best" spanner and a "new best?" column.
- Living outline: no section changes, one Decisions entry for tables.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- slides-tooling: nimib 0.4.3; a requirement for tables made with tabelline.

## Impact

- `talk-sailing-seas-scientific-nim.nimble`, `nim.cfg`, `my.nim`, `slides/island2_stories.nim`, `slides/island3_datastack.nim`, `slides/island2_brentp_explainer.nim`, `slides/island2_vindaar_explainer.nim`, `openspec/specs/slides-tooling/spec.md`.
- Timing unchanged.
