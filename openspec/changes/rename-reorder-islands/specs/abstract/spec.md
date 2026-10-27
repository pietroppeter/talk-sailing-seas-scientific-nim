# Spec Delta

## MODIFIED Requirements

### Requirement: Intro, seven islands, conclusion
The talk SHALL consist of an intro, seven islands and a conclusion, in this order: Intro; Accessible Performance; Success Stories; Data Stack; Interoperability; An Expressive Language; Interactivity; Notebook; Conclusion. This order and the shorter name of the first island differ from the agenda as submitted (Pietro, 2026-10-27).

#### Scenario: Section order
- **WHEN** the deck is paged through
- **THEN** the sections appear in the order above, each island clearly announced as the next stop of the journey

## RENAMED Requirements

- FROM: `### Requirement: Island 1, Accessible Performance without Ceiling`
- TO: `### Requirement: Island 1, Accessible Performance`

## REMOVED Requirements

### Requirement: Island 4, An Expressive Language
**Reason**: the island moves to fifth place.
**Migration**: see "Island 5, An Expressive Language".

### Requirement: Island 5, Interoperability
**Reason**: the island moves to fourth place.
**Migration**: see "Island 4, Interoperability".

## ADDED Requirements

### Requirement: Island 4, Interoperability
The fourth island SHALL show that Nim interoperates easily: wrapping existing C and C++ libraries, two-way bridges to Python, R and Julia (of varying maturity), and Nim code used from Python almost as easily as Rust.

#### Scenario: Interop directions
- **WHEN** the fourth island ends
- **THEN** both directions have been shown: calling C/C++ or Python from Nim, and using Nim from Python

### Requirement: Island 5, An Expressive Language
The fifth island SHALL show two language features that make Nim good for scientific use: defining custom operators (an easy feature) and metaprogramming (an advanced feature).

#### Scenario: Two features shown
- **WHEN** the fifth island ends
- **THEN** one custom operator example and one metaprogramming example have been shown
