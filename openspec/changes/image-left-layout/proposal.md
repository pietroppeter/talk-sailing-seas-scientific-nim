# Proposal

## Why

Many slides of the voyage will pair one strong picture (an island, a plot, a screenshot of an app) with a few lines of text. The deck has no layout for that yet: `nbImg` puts an image in the flow of the slide, so it never fills the screen. A layout with an image on the left, using the full height of the screen and a chosen fraction of its width, with the text on the right, gives those slides a clean, recognizable look.

This is also the first change that iterates on a slide layout rather than on content, so it sets how layout work goes through OpenSpec: layouts are helpers in `my.nim`, tried out in the style test deck (`nim r my.nim`, `docs/my.html`) and reviewed with its screenshots before any talk slide uses them.

## What Changes

- New layout helper `imageLeftSlide` in `my.nim`: an image on the left, full height of the screen (edge to edge, not only the slide box), with its width given as a fraction of the screen width (default 40%), cropped to fill; the slide content is vertically centered in the space on the right. The AgileLab logo moves to the bottom-left of the text area on these slides, so it does not sit on the image.
- The style test deck (`my.nim`) gets demo slides of the new layout: default width, a narrower one, and one inside a vertical stack, like the talk's sections.
- A demo image (`docs/images/demo-sea.svg`, drawn for this repo) to try the layout.
- OpenSpec: `config.yaml` learns about the style test deck and how layout changes are planned (outline delta with Decisions only, a `Layouts` task group verified on `docs/my.html`).
- Living outline: no section or slide changes; one Decision on the new layout.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `slides-tooling`: adds a requirement that slide layouts are helpers in `my.nim` with demo slides in the style test deck, including the image-left layout.

## Impact

- `my.nim` (helper, CSS, demo slides), `docs/images/demo-sea.svg` (new), `openspec/config.yaml`.
- No talk slide uses the layout yet (`index.nim` and `slides/` unchanged); timing unchanged.
