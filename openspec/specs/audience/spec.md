# audience Specification

## Purpose

Describes who the talk is for, what they already know, and what each kind of attendee takes home.

## Requirements

### Requirement: Primary audiences
The talk SHALL address two primary audiences: the scientific computing beginner and the scientific ecosystem builder. Programming language enthusiasts and community builders are a secondary audience.

#### Scenario: Both audiences served
- **WHEN** the conclusion is reached
- **THEN** there is a takeaway addressed to the beginner and one addressed to the builder

### Requirement: Mostly Python and Jupyter background
The talk SHALL assume a room of mostly Python/Jupyter scientific-computing people (the conference continues PyData Paris) in a session about languages and compilers, and SHALL use Python-like examples and comparisons as the bridge to Nim.

#### Scenario: Unfamiliar concept
- **WHEN** a Nim concept is shown
- **THEN** it is related to its Python equivalent or to what a Python user would do

### Requirement: No prior Nim knowledge required
The talk SHALL be followable without knowing Nim; looking up a Nim tutorial beforehand helps but is not required.

#### Scenario: Reading a code example
- **WHEN** a code example is on screen
- **THEN** a Python user can tell what it does from the code and the speaker's explanation alone

### Requirement: Beginner takeaway
The beginner SHALL leave with a first introduction to a language that is accessible, fun to play with, and possibly useful in day-to-day work, at the very least as a learning tool.

#### Scenario: Beginner leaves the room
- **WHEN** a beginner is asked what they learned
- **THEN** they can say why Nim is worth trying and where to start

### Requirement: Builder takeaway
The builder SHALL be able to evaluate the pros and cons of building scientific computing tools in Nim.

#### Scenario: Builder leaves the room
- **WHEN** a builder is asked what they learned
- **THEN** they can name at least one strength and one weakness of Nim for building scientific tools

### Requirement: Fits the session
The talk SHALL take its session neighbours into account: Mamy André-Ratsimbazafy's talk on high-performance computing for AI in Nim, and Antonio Cuni's talk on SPy. HPC and AI material SHALL stay brief and point to Mamy's talk instead of duplicating it.

#### Scenario: Performance island
- **WHEN** the performance island touches HPC or AI
- **THEN** it stays brief and refers to Mamy's talk in the same session
