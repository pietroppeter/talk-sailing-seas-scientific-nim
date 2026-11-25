# Key messages and tone

Status: accepted · Updated 2026-11-24

## Context

A 30 minute talk leaves a few messages, not a manual. Fixing them lets every section be checked against them, and anything that carries none of them can be cut. The tone follows the CfP's advice (no sales pitch) and the voyage metaphor.

## Decision

- **K1 Tradeoffs and untapped potential.** Scientific computing has used many languages, each with its tradeoffs; the talk shows Nim's, and why the speaker finds it fun, exciting and with more potential than its impact so far. Set up in the intro, closed in the conclusion; the talk does not claim Nim beats every other language.
- **K2 Strengths and superpowers.** As easy to write as Python, as fast as C, with superpowers: metaprogramming, the JavaScript backend and interoperability (wrapping C and C++, bridges to Python, R and Julia, Nim from Python). Each is shown with at least one concrete example.
- **K3 Pragmatic, ready for more.** Nim is stable and ready for more than it is used for, and has its shortcomings: governance first, and on the technical side no REPL, concepts not robust until possibly recently, dev tooling not at Rust's level (Nimony and NIF could help). The audience leaves aware of the pitfalls.
- **K4 Diversity of languages.** No conversion pitch: attendees see tradeoffs of their own language they had not noticed, and leave appreciating the diversity of languages; learning Nim, at least as a learning tool, is one way to see them.
- **Every section carries a key message**, named in the outline.
- **Shortcomings are shown along the way**: most islands end with a "rocks ahead" slide, where there is an honest limitation worth naming (not on island 1).
- **No sales pitch.** Tools, nimib included, are open-source options with honest tradeoffs; the notebook island names at least one limitation of nimib.
- **Shallow by design.** From a boat you see only a little of the land: no island goes in depth, each gives the feeling of the place; depth is left to the deep dives, the links and the Q&A.
- **No live demos** (Pietro: no time to prepare them): examples are code and output computed when the deck is built.
- **The sea metaphor is spent sparingly**: the voyage frames the talk, but examples do not need sea themes (Pietro, 2026-10-27).

## Options considered

- One "shortcomings" slide in the conclusion instead of rocks ahead along the way: easy to cut when time runs short.
- Live coding or a terminal on stage: preparation time and stage risk.

## Consequences

- A section that carries no key message is a candidate to cut.
- A broken example shows up when the deck is built (CI), not on stage; it can fall back to a static snippet.

## History

- 2026-10-26: K1-K4, shallow by design, no live demos, rocks ahead (PR #8).
- 2026-11-24: moved from the OpenSpec key-messages spec and the outline's decisions to this record.
