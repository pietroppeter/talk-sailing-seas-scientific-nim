# Agents and skills

Status: accepted · Updated 2026-11-24

## Context

Most of the repository is written with coding agents (Claude Code), in sessions that start from a fresh checkout. What they need to know must be in the repository, not in a chat.

## Decision

- **AGENTS.md** holds the working rules that are easy to miss; `CLAUDE.md` points to it. What the talk says and why is in these decision records and `outline.md`.
- **Decision records, not OpenSpec** (Pietro, 2026-11-24): one record per domain in `decisions/`, updated in place ([README](README.md)). OpenSpec (custom `talk` schema, proposals, spec deltas, outline deltas, archive) was overkill for a talk prepared by one person.
- **nimib skills** from [pietroppeter/skills](https://github.com/pietroppeter/skills), enabled in `.claude/settings.json` (nimib, nimib-blocks, nimib-theme, nimibook); `nimib-review` is in `.claude/skills/`.
- **local-changes branch and `#>` notes** (Pietro, 2026-11-24): Pietro works offline on a long-lived `local-changes` branch and leaves instructions for Claude as notes, runs of lines starting with `#>` (first line `#> Claude: ...`). Each push becomes a PR into `main` that keeps his commits and adds one that carries out and removes the notes; it is merged with a merge commit, so `local-changes` rebases on `main` cleanly. The build fails in CI on any line starting with `#>`, so no note reaches `main`.
- **SessionStart hook** installs Nim in cloud sessions when it is missing (`.claude/hooks/session-start-nim.sh`).

## Options considered

- Keep OpenSpec: changes stayed un-archived, and every change needed proposal, deltas and tasks.
- Context in chat threads or agent memory: lost between sessions, and not reviewable.

- Notes as `TODO(claude)` or `<!-- claude: -->`: the first clashes with ordinary TODOs and no check could tell them apart, the second only works in Markdown. `#>` is a comment in Nim, YAML and shell, plain text in Markdown and `nbText`, and rare enough to forbid.
- Squash merges of the local-changes PRs: shorter history, but the rebase of `local-changes` would conflict on every handled note.

## Consequences

- A change updates its decision record in the same PR; there is no separate archive step.
- A line starting with `#>` is reserved for notes: a page cannot show output in the style of R's reprex, which uses the same prefix.
- The old OpenSpec specs and changes are in git history (before 2026-11-24).

## History

- 2026-10-26: OpenSpec with a custom talk schema (PR #7).
- 2026-11-24: nimib skills (PR #30), AGENTS.md, decision records replace OpenSpec.
- 2026-11-24: local-changes branch and `#>` notes for Claude, with a build check.
