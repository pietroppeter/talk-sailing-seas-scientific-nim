# Decision records

Why the talk and its repository are the way they are, one record per domain. A lightweight take on [MADR](https://adr.github.io/madr/): instead of adding a record for each decision, each domain has one record, updated in place when a decision changes, with a line in its History. Git keeps the older versions.

| Record | Domain |
|---|---|
| [talk.md](talk.md) | The talk as accepted: title, slot and timing, audience, format |
| [tone.md](tone.md) | Key messages and tone |
| [islands.md](islands.md) | The voyage: sections, islands, what each one shows and why |
| [slides.md](slides.md) | How slides are written: nimib and nimiSlides, layouts, branding, code, tables, animations |
| [themes.md](themes.md) | The look of the deck: AgileLab today, themes explored |
| [deep-dives.md](deep-dives.md) | Pages that go deeper than the slides |
| [talk-log.md](talk-log.md) | The talk log |
| [build-ci.md](build-ci.md) | Build, offline assets, checks, dependencies, publishing |
| [review.md](review.md) | How work is reviewed |
| [agents-skills.md](agents-skills.md) | Working with coding agents: AGENTS.md and skills |

The living plan of the talk (sections, timing, slides) is [outline.md](../outline.md); background notes are in [notes/](../notes/); open questions are in [OPEN-POINTS.md](../OPEN-POINTS.md).

## Format

Each record has a header line (status, last update) and these sections:

- **Context**: what the domain is about and what constrains it.
- **Decision**: what holds today, one bullet per decision, with who decided and when.
- **Options considered**: what was set aside, and why.
- **Consequences**: what follows, good and bad, and the risks.
- **History**: one line per change, newest last, with the date and the PR.

To change a decision: edit its bullet under Decision (and Options considered, Consequences), add a History line, in the same PR as the change it describes. A new domain gets a new file and a row in the table above.
