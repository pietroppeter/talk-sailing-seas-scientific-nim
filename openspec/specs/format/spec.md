# format Specification

## Purpose

Fixes when, where and in what form the talk is delivered at Compute! Paris 2026, and the conference guidelines it follows.

## Requirements

### Requirement: Talk fits its conference slot
The talk SHALL be delivered at Compute! Paris 2026 (successor of PyData Paris, organized by QuantStack) on Thursday 26 November 2026, 14:40-15:10, Room 108, Centre International de Conférences de Sorbonne Université (CICSU), Paris, in the session "A Babel of Compilers".

#### Scenario: Slot on the schedule
- **WHEN** the speaker checks the conference schedule (https://pretalx.com/compute-paris-2026/talk/8EM8ZA/)
- **THEN** the talk is listed on Thursday 26 November 2026 at 14:40 in Room 108

### Requirement: Content fits the time with room for Q&A
The slot is 30 minutes including Q&A, so the talk content SHALL take at most 25 minutes, aiming for 22-25 minutes.

#### Scenario: Timed rehearsal
- **WHEN** the full deck is rehearsed with a timer
- **THEN** it ends within 25 minutes, leaving at least 5 minutes for questions

### Requirement: Outline carries a time breakdown
The talk outline SHALL give a time budget per section, as the CfP asks ("minutes 0-10: X, 10-15: Y").

#### Scenario: Reading the outline
- **WHEN** someone reads the current outline
- **THEN** every section has its minutes and the total fits the content time

### Requirement: Talk is consistent with title and proposal
The talk SHALL deliver what the published title, summary and description promise, since attendees choose the talk from them (see the abstract spec).

#### Scenario: Promise check
- **WHEN** the deck is compared with the published description
- **THEN** every agenda item of the description has a matching section in the deck

### Requirement: Example-driven tour, not a tutorial
The talk SHALL be an example-driven tour with a light, travel-themed narrative and SHALL NOT be a tutorial of the Nim language.

#### Scenario: No tutorial slides
- **WHEN** the deck is read
- **THEN** there are no slides that teach Nim syntax for its own sake; code appears only inside examples

### Requirement: New material
The talk SHALL be new material and SHALL NOT reuse a deck that is already published online, following the CfP preference for new talks.

#### Scenario: Reused content
- **WHEN** a slide or example comes from one of the speaker's past talks
- **THEN** it is reworked for this talk's story rather than copied as a block of slides

### Requirement: No sales pitch
The talk SHALL present tools, including the speaker's own project nimib, as open-source options with honest trade-offs, not as a sales pitch.

#### Scenario: Presenting nimib
- **WHEN** the notebook island presents nimib
- **THEN** it also states at least one limitation or trade-off of nimib

### Requirement: Core content shaped well before the day
Every example and demo the proposal promises SHALL work well before the conference day, following the CfP advice against relying on future work.

#### Scenario: Demo readiness
- **WHEN** a full rehearsal is run in the week before the conference
- **THEN** every demo in the deck runs without changes on the day
