# slides-tooling Specification

## Purpose

Defines how the slides are written, built, published and previewed, so every iteration of the deck can be built and checked the same way.

## Requirements

### Requirement: Slides are nimib + nimiSlides code
The slides SHALL be written in Nim with nimib 0.4.1 and nimiSlides 0.4.0 (reveal.js), on Nim 2.2.12, with dependencies managed by atlas.

#### Scenario: Fresh build
- **WHEN** someone runs `atlas install` and `nim r index.nim` in a fresh checkout
- **THEN** `docs/index.html` is generated without errors

### Requirement: Repository layout
The presentation entry point `index.nim`, the helpers `my.nim`, `nimib.toml`, `nim.cfg` and the `.nimble` file SHALL live at the repository root, and individual slide files SHALL live in `slides/`, imported by `index.nim`.

#### Scenario: Adding a section
- **WHEN** a new section of slides is written
- **THEN** it goes in a file under `slides/` and is wired into `index.nim`

### Requirement: Theme and branding
The deck SHALL use the AgileLab theme from `my.nim`: off-white background, AgileLab colors, the AgileLab logo fixed bottom-left, and a light code theme (highlight.js style chosen by `codeTheme` in `my.nim`) for code blocks.

#### Scenario: Any slide
- **WHEN** any slide is shown
- **THEN** it has the off-white background and the AgileLab logo bottom-left

#### Scenario: Code on a slide
- **WHEN** a slide shows Nim code and its output
- **THEN** the code is in a light box with the chosen highlight.js style, not a dark one, and the output is marked by a light-blue bar on its left

### Requirement: Published on GitHub Pages
The built deck SHALL be published at https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/ by CI: outputs go to `docs/`, generated html is not committed, and every push to `main` builds and deploys `docs/`.

#### Scenario: Merge to main
- **WHEN** a change is merged to `main`
- **THEN** the published deck shows the change after the pages workflow finishes

### Requirement: Works offline
The deck SHALL NOT depend on CDNs: reveal.js, KaTeX, p5.js and the highlight.js code styles are vendored in `docs/assets/`, so the deck works without network access.

#### Scenario: No wifi at the venue
- **WHEN** the deck is opened from a local build with the network off
- **THEN** all slides, styles, math and animations render

### Requirement: Math renders
LaTeX math in slides SHALL render with KaTeX.

#### Scenario: Formula on a slide
- **WHEN** a slide contains LaTeX math
- **THEN** it renders as typeset math, not as raw source

### Requirement: Every slide change is shown with screenshots
Every change to the slides SHALL be built and shown to the speaker as rendered output (screenshots or html) before it is reviewed.

#### Scenario: Slides changed in a change
- **WHEN** a change modifies slides
- **THEN** the review includes screenshots of the affected slides, made with `scripts/screenshot.sh`

### Requirement: Layouts are helpers tried in the style test deck
Slide layouts SHALL be helpers in `my.nim`, and every layout SHALL have demo slides in the style test deck that `nim r my.nim` builds (`docs/my.html`), so a layout is built, screenshotted and reviewed before talk slides use it.

#### Scenario: Iterating on a layout
- **WHEN** a change adds or modifies a layout
- **THEN** the review shows screenshots of its demo slides from `docs/my.html`, made with `scripts/screenshot.sh`

#### Scenario: Image on the left
- **WHEN** a slide uses the image-left layout with a width fraction
- **THEN** the image covers the full height of the screen and that fraction of its width, cropped and not stretched, the slide content sits to its right, and the AgileLab logo stays visible and does not cover the image

### Requirement: Animations are p5nim sketches
Animated slides SHALL be written in Nim with p5nim and compiled to JavaScript by nimib when the deck is built, and an animation SHALL start when its slide is shown.

#### Scenario: Showing an animated slide
- **WHEN** the speaker moves to a slide with an animation, also coming back to it later
- **THEN** the animation plays from its start

### Requirement: Code explainers
Code on a slide SHALL be limited to what fits the slide. An example that deserves more SHALL have an explainer: a nimib document, `slides/<name>_explainer.nim`, built to `docs/<name>_explainer.html` and deployed with the deck, that explains the example more thoroughly, with code that runs when the page is built. The example's slide SHALL link its explainer.

#### Scenario: Someone wants to explore an example further
- **WHEN** a reader of the published deck follows the link on an example's slide
- **THEN** they reach its explainer, with the full code, its output and the explanation that did not fit on the slide

#### Scenario: Deploying the deck
- **WHEN** the pages workflow builds the deck
- **THEN** it also builds every explainer into `docs/`, and the README lists them
