# Spec Delta

## MODIFIED Requirements

### Requirement: Theme and branding
The deck SHALL use the AgileLab theme from `my.nim`: off-white background, AgileLab colors, the AgileLab logo fixed bottom-left, and a light code theme (highlight.js style chosen by `codeTheme` in `my.nim`) for code blocks.

#### Scenario: Any slide
- **WHEN** any slide is shown
- **THEN** it has the off-white background and the AgileLab logo bottom-left

#### Scenario: Code on a slide
- **WHEN** a slide shows Nim code and its output
- **THEN** the code is in a light box with the chosen highlight.js style, not a dark one, and the output is marked by a light-blue bar on its left

### Requirement: Works offline
The deck SHALL NOT depend on CDNs: reveal.js, KaTeX, p5.js and the highlight.js code styles are vendored in `docs/assets/`, so the deck works without network access.

#### Scenario: No wifi at the venue
- **WHEN** the deck is opened from a local build with the network off
- **THEN** all slides, styles, math and animations render
