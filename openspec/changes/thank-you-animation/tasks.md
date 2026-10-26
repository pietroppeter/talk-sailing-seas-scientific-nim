# Tasks

## 9. Conclusion: back on land

- [x] 9.6 `thankYouSlide` in `slides/thank_you.nim`, a p5nim sketch: grid of colored points flying along curves into "Thank You!" with one color per letter (Okazz palette) and back, in a loop, credit and CC BY-NC-SA 3.0 license for Okazz's sketch, deck link below, restarting from the grid each time the slide is shown; replaces the 9.6 placeholder and sits on the top row after the conclusion stack (`index.nim`); footer credits p5nim and Okazz's sketch; verify with screenshots of the start, middle and end frames and a recording

## Whole talk

- [x] W.1 Vendor p5.js 1.11.13 in `docs/assets/p5` with `scripts/vendor-assets.sh`, load it with `useP5` from `my.nim`, add p5nim with atlas; verify the deck loads no CDN script
- [x] W.2 Build the full deck with `nim r index.nim` and the style deck with `nim r my.nim`; verify both build and the deck still has 43 slides

- [x] W.3 Build the slide on its own with `nim r slides/thank_you.nim` (`docs/thank_you.html`, also in the pages workflow) and link it from the README; verify the letters use the deck's font when the slide is alone

## Workflow follow-up

- Archive the change after Pietro's review.
