# Tasks

## Layouts

- [x] L.1 Demo image `docs/images/demo-sea.svg` (drawn for this repo, no third-party content); verify it opens in the browser
- [x] L.2 Template `imageLeftSlide(url, width = 0.4, ...)` in my.nim: image on the left at full screen height and `width` of the screen width, cropped to fill, slide content vertically centered on the right; verify with `nim r my.nim`
- [x] L.3 The AgileLab logo moves bottom-right on every slide, left of the navigation arrows; verify in the screenshots that it covers neither the image nor the arrows
- [x] L.4 Demo slides in my.nim's style test deck: default width, a narrower width, and an image-left slide inside a vertical stack; verify in the screenshots of docs/my.html (`scripts/screenshot.sh docs/my.html <outdir>`)
- [x] L.5 Check the layout at a 4:3 and a 16:9 window size; verify image and text do not overlap in either

## Whole talk

- [x] W.1 Build the full deck with `nim r index.nim`; verify it builds and still has 43 slides

## Workflow follow-up

- Archive the change after Pietro's review.
