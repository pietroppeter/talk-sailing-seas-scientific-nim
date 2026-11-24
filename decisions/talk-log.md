# Talk log

Status: accepted · Updated 2026-11-24

## Context

Pietro keeps devlogs for his libraries; the talk gets a small one, to tell how it evolves and to show nimib at work.

## Decision

- **Posts are nimib pages** in `devlog/`, listed in `devlog/devlog.nim` (date, slug, kind: retrospective or research, summary), written to `docs/devlog/<date>-<slug>.html`; `devlog/index.nim` lists them newest first and checks they were all built. A post starts with `nb.useDevlogPost(slug, ownSource)`.
- **Published** with the rest of the site, listed in the README and on the site index.
- **A post is a record of its time**: it is not rewritten when the talk moves on, only its links are kept working.

## Consequences

- Whether the log should say how the work is done (with coding agents) is open ([OPEN-POINTS.md](../OPEN-POINTS.md)).

## History

- 2026-11-07: the talk log, three posts (PR #26).
- 2026-11-24: this record created.
