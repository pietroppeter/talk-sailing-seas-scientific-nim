# Spec Delta

## MODIFIED Requirements

### Requirement: Works offline
No page SHALL depend on CDNs: the deck, the themed decks, the explainers and the talk log load everything they need (reveal.js, KaTeX, p5.js, highlight.js and its code styles, water.css, plotly.js, fonts) from `docs/assets/`, vendored by `scripts/vendor-assets.sh` and `scripts/vendor-fonts.sh`, so they work without network access. `nim r build.nim check`, run by every full build and by the pages workflow, fails when a built page loads a script, a stylesheet, a font or an image from another site.

#### Scenario: No wifi at the venue
- **WHEN** the deck is opened from a local build with the network off
- **THEN** all slides, styles, math and animations render

#### Scenario: Reading an explainer offline
- **WHEN** an explainer or a talk log post is opened from a local build with the network off
- **THEN** its styles, highlighted code, math and interactive plots render

#### Scenario: A page adds a CDN link
- **WHEN** a change makes a page load something from a CDN
- **THEN** `nim r build.nim` fails and names the page and the URL

## ADDED Requirements

### Requirement: One command builds every page
`nim r build.nim` SHALL build every page into `docs/` (deck, style test deck, Thank You slide, themed decks, explainers, talk log), and each group on its own (`slides`, `themes`, `explainers`, `devlog`). Explainers and talk log posts SHALL be found by file name, so adding one needs no change to the script, the workflow or the README's commands. The pages workflow SHALL build with it.

#### Scenario: Building everything before a review
- **WHEN** someone runs `nim r build.nim` after `atlas install`
- **THEN** every page is written to `docs/` and the offline check runs

#### Scenario: A new explainer
- **WHEN** a new `slides/<name>_explainer.nim` is added
- **THEN** `nim r build.nim explainers` and the pages workflow build it without other changes
