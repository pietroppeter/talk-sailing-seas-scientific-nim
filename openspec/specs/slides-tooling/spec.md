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
The deck SHALL use the AgileLab theme from `my.nim`: off-white background, AgileLab colors, and the AgileLab logo fixed bottom-left.

#### Scenario: Any slide
- **WHEN** any slide is shown
- **THEN** it has the off-white background and the AgileLab logo bottom-left

### Requirement: Published on GitHub Pages
The built deck SHALL be published at https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/ by CI: outputs go to `docs/`, generated html is not committed, and every push to `main` builds and deploys `docs/`.

#### Scenario: Merge to main
- **WHEN** a change is merged to `main`
- **THEN** the published deck shows the change after the pages workflow finishes

### Requirement: Works offline
The deck SHALL NOT depend on CDNs: reveal.js and KaTeX are vendored in `docs/assets/`, so the deck works without network access.

#### Scenario: No wifi at the venue
- **WHEN** the deck is opened from a local build with the network off
- **THEN** all slides, styles and math render

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
