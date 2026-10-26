# Proposal

## Why

The last slide is the one left on screen during Q&A, and it is the last impression of the talk. A creative coding animation written in Nim, where a grid of colored points flies into the words "Thank You!" and back, closes the voyage with something playful, and it shows one of the superpowers of key message K2 at work: the JavaScript backend. The idea is inspired by a sketch by Okazz (https://openprocessing.org/sketch/3044593), where a grid morphs into packed circles and back; the slide uses his palette. Okazz's sketch is licensed under CC BY-NC-SA 3.0, so the slide's sketch is too, with attribution on the slide.

## What Changes

- Living outline: slide 9.6 "Thank you" becomes an animation written with p5nim (the Nim binding of p5.js): a grid of colored points that flies along curves to form "Thank You!", one color per letter, and back into the grid, in a loop, with the link to the deck and the credit to Okazz below it. The links to the repo, nimib and the Nim community are dropped from 9.6 for now.
- New slide file `slides/thank_you.nim` with `thankYouSlide`, used by `slides/conclusion.nim` in place of the 9.6 placeholder.
- `my.nim` gets `useP5`, which loads p5.js from `docs/assets/p5` in the deck's head.
- p5.js 1.11.13 is vendored in `docs/assets/p5` by `scripts/vendor-assets.sh`, so the animation works offline like the rest of the deck.
- p5nim is a new dependency (atlas, `deps/p5nim`).
- License: `slides/thank_you.nim` is CC BY-NC-SA 3.0 (as Okazz's sketch), stated in the file and in a new License section of the README; the rest of the repository stays MIT.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `slides-tooling`: the offline requirement now covers p5.js, and a new requirement says animations are p5nim sketches compiled with Nim's JavaScript backend.

## Impact

- `slides/thank_you.nim` (new), `slides/conclusion.nim`, `README.md`, `my.nim`, `scripts/vendor-assets.sh`, `docs/assets/p5/` (new, about 1 MB), the `.nimble` file and `nim.cfg`.
- Timing unchanged: the slide stays up during Q&A, so the animation loops.
