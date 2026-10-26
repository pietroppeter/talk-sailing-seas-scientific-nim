# Outline Delta

## Sections

### 9. Conclusion: back on land (~2.5 min)

Takeaways and an opinionated reflection on why Nim is still niche. Carries K1, K3 and K4. The thank-you slide is not part of the conclusion's vertical stack: it is the last slide of the top row, after it.

- REMOVED: 9.6 **Thank you** - links: slides, repo, nimib, Nim community.
- ADDED: 9.6 **Thank you** - the last slide of the top row, after the conclusion stack: an animation written in Nim with p5nim and compiled to JavaScript: a grid of colored points flies along curves into the words "Thank You!", one color per letter, and back into the grid, in a loop, based on a sketch by Okazz (the footer says it is built with p5nim and inspired by a sketch by Okazz, CC BY-NC-SA 3.0); the link to the deck is above the footer. It stays on screen during Q&A.

Unchanged: 0-8, and 9.1-9.5

## Decisions

- ADDED: Animated thank-you slide (Pietro, 2026-10-26): the closing slide is a p5nim sketch, a small show of the JavaScript backend (K2) and a playful last image for Q&A. Pietro chose points flying along curves with Okazz's palette, over straight moves with his easing and over bursting into big translucent circles. The sketch is CC BY-NC-SA 3.0 like Okazz's, the rest of the repo stays MIT. p5nim is used in global mode (one sketch in the deck), with p5.js 1.11.13 vendored in `docs/assets/p5`. It sits on the top row after the conclusion stack, so it is one right-arrow away from anywhere on the top row, and it can be built on its own (`nim r slides/thank_you.nim`, `docs/thank_you.html`, linked from the README). Alternative: a static slide with links.

## Risks / Trade-offs

- ADDED: [The animation lags or breaks on the venue laptop] → it only draws while its slide is shown, uses no network, and is checked on the presentation laptop in rehearsal.
