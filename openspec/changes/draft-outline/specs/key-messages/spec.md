# Spec Delta

## Purpose

Fixes the few messages the whole talk must leave with the audience, so that every section can be checked against them and anything that carries none of them can be cut.

## ADDED Requirements

### Requirement: Nim's tradeoffs, and its untapped potential
The talk SHALL convey that scientific computing has used many languages, each with different tradeoffs, and SHALL present the specific tradeoffs of Nim, and why the speaker finds it fun, exciting and with a lot more potential than the limited impact it has had until now.

#### Scenario: Message set up in the intro
- **WHEN** the intro ends
- **THEN** the audience knows the talk is about Nim's specific tradeoffs, not a claim that Nim beats every other language

#### Scenario: Message closed in the conclusion
- **WHEN** the conclusion ends
- **THEN** the speaker has explained Nim's tradeoffs, its strengths and its shortcomings, and has said why Nim is fun and exciting and why its potential is bigger than its impact so far

### Requirement: Easy like Python, fast like C
The talk SHALL convey that Nim is as easy to write as Python and as fast as C, with no performance ceiling.

#### Scenario: Message backed by evidence
- **WHEN** the talk is over
- **THEN** the claim has been backed by at least one concrete example in the deck

### Requirement: Nim works with your ecosystem
The talk SHALL convey that adopting Nim does not mean leaving your ecosystem: C and C++ libraries are easy to wrap, and what you build in Nim is easy to use from Python.

#### Scenario: Message in the interop island
- **WHEN** the interoperability island ends
- **THEN** the audience has seen Nim code used from Python

### Requirement: Niche, honest, and worth trying
The talk SHALL convey that Nim is still a niche language with real shortcomings, and at the same time fun and worth trying, at least as a learning tool.

#### Scenario: Message in the conclusion
- **WHEN** the conclusion ends
- **THEN** the audience has heard both why Nim is niche and an invitation to try it

### Requirement: Every section carries a key message
Every section of the talk SHALL carry at least one of the key messages.

#### Scenario: Checking the outline
- **WHEN** the outline is reviewed
- **THEN** every section names the key message or messages it carries
