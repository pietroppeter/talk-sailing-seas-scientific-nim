# Proposal

## Why

Pietro builds the talk on a train with a poor connection (2026-11-24). The deck already works offline, but the explainers and the talk log still load nimib's theme (water.css, highlight.js), KaTeX and plotly.js from CDNs, and building every page means typing a long list of `nim r` commands kept in sync by hand in the README and in the pages workflow.

## What Changes

- `offline.nim`: `nb.useOfflineAssets` (after `nbInit`) points nimib's default theme and `nb.useLatex` to `docs/assets`; every explainer and the talk log use it.
- `scripts/vendor-assets.sh` also vendors water.css 2.1.1, nimib's assets (highlight.min.js and code themes, v0.4.3) and plotly.js 2.35.2; `slides/nbplotly.nim` loads plotly.js from `docs/assets/plotly`.
- `nim r build.nim`: one command builds everything, or a group (`slides`, `themes`, `explainers`, `devlog`), finding explainers and talk log posts by name; `check` fails when a built page loads anything from the network. The pages workflow runs it.
- README: a Build section with the commands and an Offline section.
- Living outline: no section changes, one Decisions entry.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- slides-tooling: the offline requirement covers every page (explainers, talk log, themed decks) and is checked by the build; a new requirement for building every page with one command.

## Impact

- `offline.nim` (new), `nim r build.nim` (new), `scripts/vendor-assets.sh`, `docs/assets/{water.css,nimib,plotly}` (new, about 4.6 MB, mostly plotly.js), every `slides/*_explainer.nim`, `slides/nbplotly.nim`, `devlog/devlog.nim`, `devlog/index.nim`, `.github/workflows/pages.yml`, README.
- No slide changes; timing unchanged.
