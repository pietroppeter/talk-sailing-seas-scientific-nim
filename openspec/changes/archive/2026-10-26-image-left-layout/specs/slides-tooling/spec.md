# Spec Delta

## ADDED Requirements

### Requirement: Layouts are helpers tried in the style test deck
Slide layouts SHALL be helpers in `my.nim`, and every layout SHALL have demo slides in the style test deck that `nim r my.nim` builds (`docs/my.html`), so a layout is built, screenshotted and reviewed before talk slides use it.

#### Scenario: Iterating on a layout
- **WHEN** a change adds or modifies a layout
- **THEN** the review shows screenshots of its demo slides from `docs/my.html`, made with `scripts/screenshot.sh`

#### Scenario: Image on the left
- **WHEN** a slide uses the image-left layout with a width fraction
- **THEN** the image covers the full height of the screen and that fraction of its width, cropped and not stretched, the slide content sits to its right, and the AgileLab logo stays visible and does not cover the image
