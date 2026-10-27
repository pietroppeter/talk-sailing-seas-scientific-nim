# Proposal

## Why

Code blocks use reveal.js' monokai theme: dark boxes on the off-white slides. Pietro does not love the contrast (2026-10-27). A light code theme keeps code readable and lets code slides (Island 4 first) sit in the same visual language as the rest of the deck.

## What Changes

- Three light highlight.js styles (github, atom-one-light, stackoverflow-light, highlight.js 11.11.1) are vendored in `docs/assets/highlight/` by `scripts/vendor-assets.sh`, so code themes work offline like the rest of the deck.
- `my.nim`: the code theme is a `codeTheme` constant (`-d:codeTheme=<style>` to try another), default atom-one-light; monokai is no longer loaded.
- `my.nim`: code output (`echo`) gets block padding and a light-blue bar on its left, so it reads as output and not as more code.
- Style test deck: a "Code and its output" demo slide.
- Living outline: no section changes, one Decisions entry for the code theme.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- slides-tooling: the offline requirement lists the vendored highlight.js styles; the theme requirement covers code blocks.

## Impact

- `my.nim`, `scripts/vendor-assets.sh`, `docs/assets/highlight/` (new), `openspec/specs/slides-tooling/spec.md`.
- Every slide with code changes look; timing unchanged.
