# Outline Delta

## Sections

### 9. Conclusion: back on land (~2.5 min)

- REMOVED: 9.6 **Thank you** - the last slide of the top row, after the conclusion stack. An animation written in Nim with p5nim and compiled to JavaScript: a grid of colored points flies along curves into the words "Thank You!", one color per letter, and back into the grid, in a loop, based on a sketch by Okazz (the footer says it is built with p5nim and inspired by a sketch by Okazz, CC BY-NC-SA 3.0); the link to the deck is above the footer. It stays on screen during Q&A.
- ADDED: 9.6 **Thank you** - the last slide of the top row, after the conclusion stack. An animation written in Nim with p5nim and compiled to JavaScript: a grid of colored points flies along curves into the words "Thank You!", one color per letter, and back into the grid, in a loop, based on a sketch by Okazz (the footer says it is built with p5nim, links a page that explains the code, and credits the sketch by Okazz, CC BY-NC-SA 3.0); the link to the deck is above the footer. It stays on screen during Q&A.

Unchanged: 0-8, and 9.1-9.5

## Decisions

- ADDED: Code explainer for the thank-you slide (Pietro, 2026-10-26): a nimib document, `slides/thank_you_explainer.nim` (`docs/thank_you_explainer.html`), explains creative coding, Processing, p5.js and p5nim, then the slide's code step by step, with excerpts read from `slides/thank_you.nim` at build time. The slide's footer links it. It uses nimib's default theme, which loads its styles from a CDN: it is a page to read online, not part of the offline deck. Alternative: an explainer only in the README or a blog post.
