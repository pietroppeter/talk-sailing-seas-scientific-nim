# Proposal

## Why

With 43 slides in one row it is hard to see the shape of the talk and to skip a section on stage. reveal.js vertical slides give each section its own column: the section/map slide on top, its content slides below.

## What Changes

- Every section except the opening (title and About me) becomes a vertical stack: the section/map slide on top, its content slides below.
- The intro has no map slide at its start, so its first slide ("The mainland") is the top of its stack.
- The outline documents the navigation in Sections and Decisions.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. No requirement changes, so this change sets `skip_specs: true`.

## Impact

- `slides/intro.nim`, `slides/island*_*.nim`, `slides/conclusion.nim`: each section template wraps its slides in one outer `slide:` (nimiSlides nests slides one level deep).
- Slide count unchanged (43); the top row has 11 slides (title, About me, intro, seven islands, conclusion).
