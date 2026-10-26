# Spec Delta

## Purpose

Fixes the three messages the whole talk must leave with the audience, so that every section can be checked against them and anything that carries none of them can be cut.

## ADDED Requirements

### Requirement: Nim's tradeoffs, and its untapped potential
The talk SHALL convey that scientific computing has used many languages, each with different tradeoffs, and SHALL present the specific tradeoffs of Nim, and why the speaker finds it fun, exciting and with a lot more potential than the limited impact it has had until now.

#### Scenario: Message set up in the intro
- **WHEN** the intro ends
- **THEN** the audience knows the talk is about Nim's specific tradeoffs, not a claim that Nim beats every other language

#### Scenario: Message closed in the conclusion
- **WHEN** the conclusion ends
- **THEN** the speaker has explained Nim's tradeoffs, its strengths and its shortcomings, and has said why Nim is fun and exciting and why its potential is bigger than its impact so far

### Requirement: Nim's strengths and superpowers
The talk SHALL convey Nim's strengths: as easy to write as Python, as fast as C, and with superpowers: metaprogramming, the JavaScript backend, and interoperability (wrapping C/C++, bridges to Python, R and Julia, using Nim from Python).

#### Scenario: Strengths backed by examples
- **WHEN** the talk is over
- **THEN** each strength (Python-like ease, C-like speed, metaprogramming, JavaScript backend, interoperability) has been shown with at least one concrete example

### Requirement: Pragmatic view, Nim is ready for more
The talk SHALL take a pragmatic view: Nim is ready for more than it is used for, it has been stable for a while, it has its own shortcomings, and the audience leaves aware of its pitfalls.

#### Scenario: Pitfalls named
- **WHEN** the talk is over
- **THEN** the audience has heard concrete shortcomings and pitfalls of Nim, alongside the evidence that it is stable and ready for more

### Requirement: Every section carries a key message
Every section of the talk SHALL carry at least one of the key messages.

#### Scenario: Checking the outline
- **WHEN** the outline is reviewed
- **THEN** every section names the key message or messages it carries
