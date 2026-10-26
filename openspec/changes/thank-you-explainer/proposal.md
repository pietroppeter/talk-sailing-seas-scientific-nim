# Proposal

## Why

The Thank You slide is a p5nim sketch, and people in the audience who like it will want to know how it works: how Nim ends up running in the browser and how the points find the letters. A short page that explains the code, linked from the slide, turns the last slide into an entry point to creative coding with Nim (K2: the JavaScript backend) and to nimib itself, since the page is a nimib document.

## What Changes

- New nimib document `slides/thank_you_explainer.nim`, built into `docs/thank_you_explainer.html` (also by the pages workflow, linked from the README): a short background on creative coding, Processing, p5.js and p5nim, the live slide in an iframe, then the code of `slides/thank_you.nim` step by step. The code excerpts are read from `slides/thank_you.nim` when the page is built, so they never go stale, and a missing excerpt stops the build.
- The slide's footer becomes "animation built with p5nim (explained here) and inspired by a sketch by Okazz, CC BY-NC-SA 3.0", with "explained here" linking the page.
- License: the page quotes `slides/thank_you.nim`, so it is CC BY-NC-SA 3.0 too (stated in the file and in the README).
- Living outline: the footer of slide 9.6 links the explainer.
- `openspec/config.yaml`: one outline rule quoted, so OpenSpec reads it as a string.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None: no requirement changes (`skip_specs: true`).

## Impact

- `slides/thank_you_explainer.nim` (new), `slides/thank_you.nim` (footer), `README.md`, `.github/workflows/pages.yml`, `openspec/config.yaml`.
- Timing unchanged.
