# Outline

## Narrative Arc

The talk is a sea voyage. From a boat you only get a very limited view of the land: we will not go in depth anywhere, and the audience gets the feeling of each island rather than a tour of it. We leave the familiar mainland of scientific computing (Fortran, C, C++, R, Python, Julia) noting that each language came with its own tradeoffs and promising to show Nim's (K1: Nim's tradeoffs as a scientific computing language, and its untapped potential). We then hop across seven islands, and together they show Nim's strengths (K2: easy like Python, fast as C, with superpowers: metaprogramming, the JavaScript backend and interop), while the success stories and the data stack show it holds up in real work (K3: pragmatic, Nim is ready for more). Where it fits, an island ends with an honest "rocks ahead" line on where Nim falls short, so the pitfalls add up along the way (K3). We touch back land in the conclusion with one takeaway for the beginner, one for the builder, and an opinionated look at why Nim is still niche despite being stable and ready for more (K3), closing K1: why it is fun, exciting, and has more potential than the impact it had so far. Throughout, comparisons with the audience's languages are framed as tradeoffs, not as a contest, so people leave appreciating their own language and the diversity of languages better (K4: appreciate the diversity of languages).

K1-K4 refer to the requirements in the `key-messages` spec delta of this change.

## Timing

| # | Section | Minutes | Ends at |
|---|---------|---------|---------|
| 0 | Opening: title and about me | 1 | 01:00 |
| 1 | Intro: leaving the mainland | 2 | 03:00 |
| 2 | Island 1: Accessible Performance without Ceiling | 1.5 | 04:30 |
| 3 | Island 2: Success Stories | 2 | 06:30 |
| 4 | Island 3: Data Stack | 3.5 | 10:00 |
| 5 | Island 4: An Expressive Language | 2.5 | 12:30 |
| 6 | Island 5: Interoperability | 3 | 15:30 |
| 7 | Island 6: Interactivity | 2.5 | 18:00 |
| 8 | Island 7: Notebook | 2.5 | 20:30 |
| 9 | Conclusion: back on land | 2.5 | 23:00 |

Total 23 minutes of content, leaving 7 minutes for Q&A and slack.

## Sections

Navigation: each section except the opening is a vertical stack in reveal.js. Its section/map slide (the intro's first slide) sits on the top row, and the section's content slides are below it, so left/right moves between sections and down goes through a section.

### 0. Opening (~1 min)

Title and speaker, before the voyage starts. Not part of the intro section.

0.1 **Sailing Seas of Scientific Nim** - title slide (short form, fits on one line) with speaker and conference (existing slide).
0.2 **About me** - mathematician, data scientist at AgileLab, nimib maintainer, Python Milan and PyData Milan organizer; the Paris climate-dynamics years as a personal hook [tbd: which details Pietro wants on stage].

### 1. Intro: leaving the mainland (~2 min)

Set up the voyage: many languages, each with its tradeoffs; this talk shows Nim's. Carries K1 and K4.

1.1 **The mainland** - a map of scientific computing languages over time: Fortran, C, C++, R, Python, Julia.
1.2 **Why so many languages?** - each language came to solve a problem the previous ones did not; the two-language problem as the classic example.
1.3 **Nim's tradeoffs** - the abstract's question "is there space for one more?" reframed: this talk is about Nim's specific tradeoffs, seven islands, and we won't hide where Nim falls short.
1.4 **The map** - the seven islands on one map, used again as a progress marker at each section start.

### 2. Island 1: Accessible Performance without Ceiling (~1.5 min)

Nim is as easy to write as Python and as fast as C, passed through quickly: performance is not the focus here and Mamy's talk in the same session goes deeper. Carries K2.

2.1 **Island 1** - section title on the map.
2.2 **Reads like Python** - the same small function in Python and in Nim side by side.
2.3 **Runs like C** - timing of that function in Python and Nim [example] [tbd: which benchmark].
2.4 **No ceiling** - one line on what "no ceiling" means (compiled, static types, control over memory when you need it), then a pointer to Mamy's HPC/AI talk in the same session for the deep dive.

### 3. Island 2: Success Stories (~2 min)

Pioneers have used Nim successfully in scientific computing. Carries K3 (ready for more).

3.1 **Island 2** - section title on the map.
3.2 **Story one** - [tbd: which project, who, what Nim made possible].
3.3 **Story two** - [tbd].
3.4 **Rocks ahead** - a tiny ecosystem means pioneers build what they need themselves.

### 4. Island 3: Data Stack (~3.5 min)

The basic building blocks of the data ecosystem, through an exploration of the penguins dataset. Carries K2 and K3.

4.1 **Island 3** - section title on the map.
4.2 **Meet the penguins** - the palmerpenguins dataset in one slide, a familiar sight for the Python and R crowd.
4.3 **Dataframe** - load and summarise the penguins in a dataframe [example] [tbd: library].
4.4 **Plot** - a scatter plot of the penguins [example] [tbd: library].
4.5 **Tensor** - the tensor library underneath, one small computation [example] [tbd: library].
4.6 **Rocks ahead** - one honest limitation of the data stack [tbd].

### 5. Island 4: An Expressive Language (~2.5 min)

Two language features that make Nim good for scientific use. Carries K2 (metaprogramming superpower).

5.1 **Island 4** - section title on the map.
5.2 **Custom operators** - defining an operator in one line and using it in a formula (the easy feature) [tbd: example].
5.3 **Metaprogramming** - a macro or template that removes boilerplate in a scientific setting (the advanced feature) [tbd: example].
5.4 **Rocks ahead** - with great power: macros can make code hard to read for newcomers; concepts (compile-time duck typing) were not robust until possibly recently.

### 6. Island 5: Interoperability (~3 min)

Nim is easy to combine with other languages, in both directions. Carries K2 (interop superpower) and K3.

6.1 **Island 5** - section title on the map.
6.2 **Wrapping C and C++** - calling an existing C library from Nim in a few lines [tbd: library].
6.3 **Bridges** - two-way bridges to Python, R and Julia, with an honest maturity rating for each [tbd: which libraries].
6.4 **Nim from Python** - a Nim function imported and called from Python, "almost like Rust" [example] [tbd: example].
6.5 **Rocks ahead** - packaging and distribution of Nim extensions [tbd].

### 7. Island 6: Interactivity (~2.5 min)

Nim compiles to JavaScript: a snappy port of a fun Shiny app. Carries K2 (JavaScript backend superpower).

7.1 **Island 6** - section title on the map.
7.2 **The original Shiny app** - what the app does and why it is fun [tbd: which app].
7.3 **The Nim port** - the same app compiled to JavaScript, running in the browser [example].
7.4 **Rocks ahead** - no REPL, so no Jupyter- or Marimo-style interactivity in Nim yet.

### 8. Island 7: Notebook (~2.5 min)

The literate computing paradigm Jupyter made central, and a Nim option that goes in an unexpected direction. Carries K2 and K3.

8.1 **Island 7** - section title on the map.
8.2 **Literate computing** - from Knuth to Jupyter: why notebooks matter in science.
8.3 **nimib** - a notebook that is a plain Nim program producing html; this very deck is made with it.
8.4 **Rocks ahead** - honest trade-offs of the nimib approach compared to Jupyter.

### 9. Conclusion: back on land (~2.5 min)

Takeaways and an opinionated reflection on why Nim is still niche. Carries K1, K3 and K4. The thank-you slide is not part of the conclusion's vertical stack: it is the last slide of the top row, after it.

9.1 **Back on land** - the map with all seven islands visited.
9.2 **For the beginner** - an accessible, fun language to try, at least as a learning tool that shows you your own language's tradeoffs, and where to start.
9.3 **For the builder** - the pros and cons of building scientific tools in Nim.
9.4 **Your language, seen from Nim** - not "switch to Nim": the tradeoffs of your own language that this voyage made visible, and why diversity of languages is good for scientific computing.
9.5 **Why still niche?** - stable for a while and ready for more, yet niche: an opinionated view of the language, the ecosystem and the community, with governance as the main shortcoming, and dev tooling not yet at Rust's level, with Nimony and NIF as the way to catch up [tbd: Pietro's views].
9.6 **Thank you** - the last slide of the top row, after the conclusion stack. An animation written in Nim with p5nim and compiled to JavaScript: a grid of colored points flies along curves into the words "Thank You!", one color per letter, and back into the grid, in a loop, based on a sketch by Okazz (the footer says it is built with p5nim and inspired by a sketch by Okazz, CC BY-NC-SA 3.0); the link to the deck is above the footer. It stays on screen during Q&A.

## Decisions

- Travel metaphor as the spine: a recurring map slide at each island start shows progress and keeps the audience oriented in a 9-section talk (plus the opening). Alternative: a plain agenda slide; rejected because the abstract already sells the voyage.
- "Rocks ahead" closing slide on most islands, where there is an honest limitation worth naming (not on island 1), so the promise of not hiding shortcomings is kept throughout instead of being dumped in the conclusion. Alternative: one "shortcomings" slide in the conclusion; rejected as easy to cut when time runs short.
- The Data Stack island gets the most time (3.5 min) because it is the one a PyData audience will judge hardest. Success Stories gets the least (2 min) because stories are told, not demoed.
- Island 1 is the shortest island (1.5 min): performance is not the speaker's main interest, and it points to Mamy's talk for depth, as the audience spec requires.
- No live demos: Pietro will not have time to prepare them. Slides marked `[example]` show code and its output, computed when the deck is built (nimib runs the code), which also fits the offline deck. Alternative: live coding or switching to a terminal; rejected for preparation time and stage risk.
- Vertical sections (Pietro, 2026-10-26): the top row of the deck is the voyage itself (opening, intro, the seven islands, conclusion), and each section's content is below it. This makes it easy to skip or shorten a section on stage. Alternative: one flat row of 43 slides.
- Shallow by design: following the sailing metaphor, no island goes in depth; each gives the feeling of the place. Depth is left to links and to the Q&A.
- Image-left layout (Pietro, 2026-10-26): slides that pair one picture with a few lines of text can use `imageLeftSlide` from `my.nim`, an image on the left at full screen height and a fraction of the width (40% by default), text on the right. Which slides use it is decided section by section, when their content is written. Alternative: images in the flow of the slide with `nbImg`, which stays available for small images.
- Animated thank-you slide (Pietro, 2026-10-26): the closing slide is a p5nim sketch, a small show of the JavaScript backend (K2) and a playful last image for Q&A. Pietro chose points flying along curves with Okazz's palette, over straight moves with his easing and over bursting into big translucent circles. The sketch is CC BY-NC-SA 3.0 like Okazz's, the rest of the repo stays MIT. p5nim is used in global mode (one sketch in the deck), with p5.js 1.11.13 vendored in `docs/assets/p5`. It sits on the top row after the conclusion stack, so it is one right-arrow away from anywhere on the top row, and it can be built on its own (`nim r slides/thank_you.nim`, `docs/thank_you.html`, linked from the README). Alternative: a static slide with links.

## Risks / Trade-offs

- [Nine sections in 23 minutes leave about 2.5 minutes per island] → one core slide per island carries the message; everything else is cuttable, and the timing table is checked in rehearsal.
- [Examples break or take too long to prepare] → each example is code plus its output, run by nimib when the deck is built, so a broken example shows up in CI and not on stage; an example can fall back to a static snippet.
- [Too many [tbd] slides make the skeleton hard to judge] → this iteration only fixes the shape; content choices are the next iterations, one island at a time.
- [The animation lags or breaks on the venue laptop] → it only draws while its slide is shown, uses no network, and is checked on the presentation laptop in rehearsal.
