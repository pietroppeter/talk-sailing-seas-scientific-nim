# Dry run 1 (26 Nov 2026, early morning)

The first run through the whole deck, the day of the talk, spoken over the slides and recorded. Messy on purpose: what to change, the speaker notes as spoken, and the timing. One section per part of the recording; fixes applied are ticked, the rest feeds follow-up work and [OPEN-POINTS.md](../OPEN-POINTS.md).

Many slides are still Claude's drafts that Pietro has not yet read or made his own: this run is also where he finds out which ones he can stand behind.

## Timing

| Part | Slides | Started | Notes |
|------|--------|---------|-------|
| 1 | 0.1 title, 0.2 about me, 0.3 AI | 01:21 | "These questions will take time": the opening is longer than its 1 minute in the outline. |
| 2 | 1.1 intro to 8.2 literate computing | 01:30 | Nine minutes for the first three slides (with dictating). The recording of part 2 stops mid-sentence in Island 7. |

## Part 1: opening

### 0.1 Title

- [x] The mainland was in magenta, but on the title slide the voyage has not started: now in the chart's ink. Magenta only for the route and the anchor in the first port.
- [x] "SCALE 1 : 25 (minutes + 5' Q&A)": liked a lot, but distracting. Removed.
- [x] Below the title, in gray: "Nim is a programming language" (not a given for this audience). Then (same morning): smaller, in parentheses, above the line under the title.
- [x] Under MAINLAND, in gray, on the title slide's map only: "mainstream languages for scientific computing: Python, R, Julia, C, C++" (these five, the most mainstream). Then: in parentheses, with ", ...", a bit lower so it does not touch MAINLAND.
- [ ] Minor: the compass rose (magnetic variation 3° W) has a small flaw in its north arrow.
- [ ] Minor: the route is not always great, especially the leg into the Notebook: it could stay a bit farther from the coast (without hitting the coast).

Speaker notes (now in the slide):

> Hello everyone! I am really happy to be here in Paris and to talk about something I am passionate about and rarely get to talk about: Nim for scientific computing. I do not work with Nim, and I do not work directly on scientific computing, so thanks to Sylvain and the other organizers for opening up the format to talks like mine.
>
> Hands up: who has heard of Nim before this talk? Nim is a programming language. Keep your hand up if you have written some Nim. Keep it up if you have contributed to scientific Nim. (Probably only Clonkk and Mamy.)

No time to explain the voyage metaphor at this point.

### 0.2 About me

Speaker notes rewritten as spoken:

> So who am I? I work at AgileLab, and I am a manager: I have not written code in about a year. Well, nobody codes anymore, everybody is becoming a manager of agents. In my spare time I help organize Python Milan and PyData Milan, a bit less lately. I have been passionate about Nim since I ran into it on Hacker News in 2018, and it is what pushed me into open source: I made a "notebook" for Nim, nimib. My background is applied math; one reason I am happy to give this talk here: I spent two years in Paris not finishing a PhD in geosciences. Happy to tell you about AgileLab later.

### 0.3 AI

- [x] The placeholder became a slide: "November 2026", three points in the context of this talk, then "what does not change: judgment, ownership, trust". Speaker notes as dictated.

The three points:

1. AI makes programming languages less important, and in a way that is liberating.
2. A small language is not a problem for AI: it writes excellent Nim (compiled, statically typed, so the compiler checks it), in Pietro's experience often better than Python.
3. Issues of a small language, like a small ecosystem, matter much less: porting is very easy.

Caveat said on stage: limited experience (a year learning to be a manager, deep into AI only in the last couple of months). What does not change and matters more: judgment (what to point your agent at and when to stop it), ownership (of everything you put out), trust (with your community of users, eroded much more easily by an irresponsible use of AI).

## Part 2: from the intro to the notebook

### Everywhere

- [x] Every rocks ahead slide has a warning sign and a rock in its title: "⚠️ Rocks ahead 🪨" (Pietro, 2026-11-26).
- [x] Every link to a deep dive has the 🐋.

### Intro

- [x] 1.1: a first bullet, 🏙️ **Mainland**: mainstream programming languages. In the notes: the deep dives are mostly AI generated, unpolished, some not read in their latest version, but they should be there.
- [x] 1.2: the map's box says "We start from the mainland: mainstream programming languages like Python, R, Julia, C, C++ and others."
- [x] 1.3: Rust added; the years of the first release are a tabelline footnote. Notes: the languages Pietro used, every language comes with tradeoffs, an interesting language pushes you to do things differently.
- [x] 1.4: "general purpose, universal and minimal"; still in strong evolution, Nimony / Nim 3.0 upcoming. Notes: universal and minimal is mind-bending; low cognitive load, easier to reason about than Python.

### Island 1: Performance

- [x] Notes: very little time here; writing a lot of Python makes you scared of for loops and think you need a library for everything; in C a for loop is cheap; with Mamy: Nim is where performance can be pushed furthest, more than Rust, which is about safety.

### Island 2: Science

- [x] Notes: with just that value proposition people started doing science with Nim; Brent Pedersen in bioinformatics almost ten years ago; Sebastian (Vindaar), whole PhD in Nim, built the stack, gratitude; QEX at a US national laboratory, little contact with the community, still very active. Rocks ahead: Brent moved mostly to Rust (Nim and Rust were contending ten years ago, Rust grew, Nim did not); when you do science you want the ecosystem there.

### Island 3: Ecosystem

- [x] The stack slide carries the penguins: "(plus Great Tables)" after Jake VanderPlas, a small artwork, a link to the deep dive "A data exploration with the stack", Allison Horst credited. The "Meet the penguins" slide is gone.
- [x] Arraymancer: CPU and GPU backends, more than NumPy, deep learning. Datamancer: looks like dplyr, Arraymancer as its backend. ggplotnim: looks like ggplot2.
- [x] nanuq moved up, right after Datamancer.
- [x] nim-plotly: one quick slide, an interactive scatter of the penguins' bills.
- [x] SciNim: "getting started (it needs to be updated)"; Flambeau stays listed there (no slide: Pietro has never seen it).
- [x] Rocks ahead: "Vindaar, mratsim, Clonkk, HugoGranstrom, ..."; "they need usage".
- [x] Notes: the classic stack from the Python Data Science Handbook plus display tables; at least two tensor libraries (Arraymancer, Flambeau), two dataframes, two plot libraries, tabelline; nanuq and tabelline born a month ago and already usable thanks to AI; the ecosystem is not strong but usable, and you do not need much of it because of interop.
- [ ] Maybe list more libraries on the SciNim slide: to think about.

### Island 4: Interoperability

- [x] Bridges: nimpy the most stable; rnim (by Vindaar) and nimjl (by Clonkk) less stable and robust; each needs its runtime installed.
- [x] nimlang-pypi marked "weeks old, made with AI"; 🐋 on "How exemplars emerge".
- [x] Notes: compiles to C, C++, JavaScript, so it can use and produce libraries for them; the Nim-Julia bridge's creator is in the room; bridges both ways, Nim can compete with Rust for Python libraries; `uv add nimlang`; the affinity propagation story behind naffprop.

### Island 5: Expressivity

- [x] Notes: Python seemed expressive until Nim; two examples, custom operators (adding points, line times plane) and unchained (metaprogramming, units DSL, back to Vindaar's thesis).
- [x] The map's box: "Expressivity is ingrained in the language. Two landmarks: operators of your own making, and units checked by the compiler, built with a macro." (Pietro: "here in the box we probably should put something else".)
- [x] Rocks ahead (was a placeholder): Claude's proposal, to check.

### Island 6: Interactivity

- [x] The bounds in the plant's code (0, 100, 0, 20, 0, 10, 0, 1) scrub like Bret Victor's numbers: press and move left or right, the number changes by one (negative too) and the slider's bound with it. On hover, the word slider of a line (what you drag) or the number turns orange.
- [x] Karax noted as another example of metaprogramming: a reactive framework in Nim.
- [x] Notes: the interactivity Pietro means is interactive artifacts, native on the web through the JavaScript backend, not a REPL (which Nim does not have, yet); the fern Shiny app needed a server, with WASM it does not but it is clunky; cicak, a recent AI-driven explainer on providing a REPL.

### Island 7: Notebook

- [x] 8.2: Knuth's quote, then Fernando Pérez's definition of literate computing (verified from his 2013 post), then "Jupyter created the notebook as we know it"; the Pimentel study moved to the notes.
- [x] Notes: how does a notebook work with no REPL? That is what started Pietro doing open source: nimib.
- [ ] The recording stops at "And then some other": the rest of Island 7 and the conclusion are still to come.

## After the run (same morning)

- [x] 4.2 is now "Ecosystem"; its last row is "Display tables", in orange; the notes open with the single takeaway: use Great Tables and gt, build more and better great tables.
- [x] 4.8: "Above 4000: nanuq and nim-plotly", the Alps' 82 four-thousanders cleaned with nanuq and drawn with nim-plotly on their relief, with Pietro's photo of Monte Rosa and nanuq's post as the deep dive. It replaced the penguins' plotly slide.
- [x] 4.10: "The islands, uncovered", a tabelline table of the real islands of the chart, sea by sea: flag, outline (shape nanoplot), area and people with bars.
