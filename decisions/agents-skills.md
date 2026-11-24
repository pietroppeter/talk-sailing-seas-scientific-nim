# Agents and skills

Status: accepted · Updated 2026-11-24

## Context

Most of the repository is written with coding agents (Claude Code), in sessions that start from a fresh checkout. What they need to know must be in the repository, not in a chat.

## Decision

- **AGENTS.md** holds the working rules that are easy to miss; `CLAUDE.md` points to it. What the talk says and why is in these decision records and `outline.md`.
- **Decision records, not OpenSpec** (Pietro, 2026-11-24): one record per domain in `decisions/`, updated in place ([README](README.md)). OpenSpec (custom `talk` schema, proposals, spec deltas, outline deltas, archive) was overkill for a talk prepared by one person.
- **nimib skills** from [pietroppeter/skills](https://github.com/pietroppeter/skills), enabled in `.claude/settings.json` (nimib, nimib-blocks, nimib-theme, nimibook); `nimib-review` is in `.claude/skills/`.
- **SessionStart hook** installs Nim in cloud sessions when it is missing (`.claude/hooks/session-start-nim.sh`).

## Options considered

- Keep OpenSpec: changes stayed un-archived, and every change needed proposal, deltas and tasks.
- Context in chat threads or agent memory: lost between sessions, and not reviewable.

## Consequences

- A change updates its decision record in the same PR; there is no separate archive step.
- The old OpenSpec specs and changes are in git history (before 2026-11-24).

## History

- 2026-10-26: OpenSpec with a custom talk schema (PR #7).
- 2026-11-24: nimib skills (PR #30), AGENTS.md, decision records replace OpenSpec.
