# Spec Delta

## MODIFIED Requirements

### Requirement: Works offline
The deck SHALL NOT depend on CDNs: reveal.js, KaTeX and p5.js are vendored in `docs/assets/`, so the deck works without network access.

#### Scenario: No wifi at the venue
- **WHEN** the deck is opened from a local build with the network off
- **THEN** all slides, styles, math and animations render

## ADDED Requirements

### Requirement: Animations are p5nim sketches
Animated slides SHALL be written in Nim with p5nim and compiled to JavaScript by nimib when the deck is built, and an animation SHALL start when its slide is shown.

#### Scenario: Showing an animated slide
- **WHEN** the speaker moves to a slide with an animation, also coming back to it later
- **THEN** the animation plays from its start
