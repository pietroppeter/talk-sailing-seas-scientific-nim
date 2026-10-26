# Outline Delta

## Sections

### 9. Conclusion: back on land (~2.5 min)

Takeaways and an opinionated reflection on why Nim is still niche. Carries K1, K3 and K4.

- REMOVED: 9.6 **Thank you** - links: slides, repo, nimib, Nim community.
- ADDED: 9.6 **Thank you** - an animation written in Nim with p5nim and compiled to JavaScript: a grid of colored points flies into the words "Thank You!", one color per letter, inspired by a sketch by Okazz; the link to the deck is below it. It stays on screen during Q&A.

Unchanged: 0-8, and 9.1-9.5

## Decisions

- ADDED: Animated thank-you slide (Pietro, 2026-10-26): the closing slide is a p5nim sketch, a small show of the JavaScript backend (K2) and a playful last image for Q&A. p5nim is used in global mode (one sketch in the deck), with p5.js 1.11.13 vendored in `docs/assets/p5`. Alternative: a static slide with links.

## Risks / Trade-offs

- ADDED: [The animation lags or breaks on the venue laptop] → it only draws while its slide is shown, uses no network, and is checked on the presentation laptop in rehearsal.
