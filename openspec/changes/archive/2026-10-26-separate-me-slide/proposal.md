# Proposal

## Why

The title slide is not part of the intro section, and the "About me" slide should not be either: both are the opening before the voyage starts. Keeping "About me" inside the intro mixes the speaker's introduction with the story of the talk.

## What Changes

- New opening section 0 in the outline: 0.1 title slide, 0.2 "About me".
- The intro section starts with "The mainland" and is renumbered 1.1-1.4; its time drops from 3 to 2 minutes, the opening takes 1 minute, so the total stays at 23 minutes.
- "About me" moves to its own file `slides/me.nim` (template `meSlide`), called in `index.nim` right after `titleSlide`, like the title slide.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. No requirement changes, so this change sets `skip_specs: true`.

## Impact

- `slides/me.nim` (new), `slides/intro.nim`, `index.nim`.
- Slide count unchanged (43).
