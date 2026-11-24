# Spec Delta

## MODIFIED Requirements

### Requirement: Slides are nimib + nimiSlides code
The slides SHALL be written in Nim with nimib 0.4.3 and nimiSlides 0.4.0 (reveal.js), on Nim 2.2.12, with dependencies managed by atlas.

#### Scenario: Fresh build
- **WHEN** someone runs `atlas install` and `nim r index.nim` in a fresh checkout
- **THEN** `docs/index.html` is generated without errors

## ADDED Requirements

### Requirement: Tables are made with tabelline
Tables in slides and explainers SHALL be made with [tabelline](https://github.com/pietroppeter/tabelline) and shown with `nbTable`; tables on slides SHALL use `slideLook` from `my.nim`.

#### Scenario: A table on a slide
- **WHEN** a slide shows a table
- **THEN** it is a tabelline table in the deck's font and colours, on the slide's background
