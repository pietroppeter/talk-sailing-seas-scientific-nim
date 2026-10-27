# Spec Delta

## ADDED Requirements

### Requirement: Code explainers
Code on a slide SHALL be limited to what fits the slide. An example that deserves more SHALL have an explainer: a nimib document, `slides/<name>_explainer.nim`, built to `docs/<name>_explainer.html` and deployed with the deck, that explains the example more thoroughly, with code that runs when the page is built. The example's slide SHALL link its explainer.

#### Scenario: Someone wants to explore an example further
- **WHEN** a reader of the published deck follows the link on an example's slide
- **THEN** they reach its explainer, with the full code, its output and the explanation that did not fit on the slide

#### Scenario: Deploying the deck
- **WHEN** the pages workflow builds the deck
- **THEN** it also builds every explainer into `docs/`, and the README lists them
