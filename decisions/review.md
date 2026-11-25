# Review

Status: accepted · Updated 2026-11-24

## Context

Pietro reviews mostly from his phone, in the project's chat threads, not on GitHub.

## Decision

- **Review in the thread** (Pietro, 2026-10-04): a change comes back with its rendered result (screenshots, built pages) and a short numbered list of open points, answered by number. The PR stays the record.
- **One PR per concern.**
- **Review mode on pages** (Pietro, 2026-11-24): every deep dive, talk log page and index has a version line and a **✎ Review** button (`review.nim`, `docs/assets/review.js`, ported from tabelline): select words, comment, export the comments as one text for a coding agent, which applies them with the `nimib-review` skill. The slides have none.
- **Open points** that outlive a thread go in [OPEN-POINTS.md](../OPEN-POINTS.md), the one list of them.

## Options considered

- Reviewing on GitHub: not where Pietro reads.
- Comments with a hosted service (hypothesis and the like): needs the network and an account.

## Consequences

- Review comments live in the reader's browser until exported.

## History

- 2026-10-04: review in the thread.
- 2026-11-24: review mode on pages; OPEN-POINTS.md (PR #28); this record created.
