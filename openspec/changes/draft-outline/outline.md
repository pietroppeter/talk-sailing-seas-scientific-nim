# Outline

## Narrative Arc

The talk is a sea voyage. We leave the familiar mainland of scientific computing (Fortran, C, C++, R, Python, Julia) asking whether there is room for one more language (K1: space for one more language). We then hop across seven islands, each a theme where Nim shows a strength: the first island sets the core promise (K2: easy like Python, fast like C), the next ones show it holds up in real work (success stories, data stack, expressive language), the fifth shows Nim does not ask you to leave home (K3: Nim works with your ecosystem), and the last two show what is special and what is still missing for interactive and literate computing. Each island ends with one honest "rocks ahead" line on where Nim falls short. We touch back land in the conclusion with one takeaway for the beginner, one for the builder, and an opinionated look at why Nim is still niche (K4: niche, honest, and worth trying).

K1-K4 refer to the requirements in the `key-messages` spec delta of this change.

## Timing

| # | Section | Minutes | Ends at |
|---|---------|---------|---------|
| 1 | Intro: leaving the mainland | 3 | 03:00 |
| 2 | Island 1: Accessible Performance without Ceiling | 2.5 | 05:30 |
| 3 | Island 2: Success Stories | 2 | 07:30 |
| 4 | Island 3: Data Stack | 3.5 | 11:00 |
| 5 | Island 4: An Expressive Language | 2.5 | 13:30 |
| 6 | Island 5: Interoperability | 3 | 16:30 |
| 7 | Island 6: Interactivity | 2.5 | 19:00 |
| 8 | Island 7: Notebook | 2.5 | 21:30 |
| 9 | Conclusion: back on land | 2.5 | 24:00 |

Total 24 minutes of content, leaving 6 minutes for Q&A and slack.

## Sections

### 1. Intro: leaving the mainland (~3 min)

Set up the voyage and the question "is there space for one more?" Carries K1.

1.1 **Sailing the Seas of Scientific Nim** - title slide with speaker and conference (existing slide).
1.2 **About me** - mathematician, data scientist at AgileLab, nimib maintainer, Python Milan and PyData Milan organizer; the Paris climate-dynamics years as a personal hook [tbd: which details Pietro wants on stage].
1.3 **The mainland** - a map of scientific computing languages over time: Fortran, C, C++, R, Python, Julia.
1.4 **Why so many languages?** - each language came to solve a problem the previous ones did not; the two-language problem as the classic example.
1.5 **Is there space for one more?** - the abstract's question, and the promise: seven islands, and we won't hide where Nim falls short.
1.6 **The map** - the seven islands on one map, used again as a progress marker at each section start.

### 2. Island 1: Accessible Performance without Ceiling (~2.5 min)

Nim is as easy to write as Python and as fast as C. Carries K2.

2.1 **Island 1** - section title on the map.
2.2 **Reads like Python** - the same small function in Python and in Nim side by side.
2.3 **Runs like C** - timing of that function in Python and Nim [demo] [tbd: which benchmark].
2.4 **No ceiling** - what "no ceiling" means: compiled, static types, control over memory when you need it; pointer to Mamy's HPC/AI talk in the same session.
2.5 **Rocks ahead** - one honest limitation [tbd].

### 3. Island 2: Success Stories (~2 min)

Pioneers have used Nim successfully in scientific computing. Carries K2.

3.1 **Island 2** - section title on the map.
3.2 **Story one** - [tbd: which project, who, what Nim made possible].
3.3 **Story two** - [tbd].
3.4 **Rocks ahead** - a tiny ecosystem means pioneers build what they need themselves.

### 4. Island 3: Data Stack (~3.5 min)

The basic building blocks of the data ecosystem, through an exploration of the penguins dataset. Carries K2.

4.1 **Island 3** - section title on the map.
4.2 **Meet the penguins** - the palmerpenguins dataset in one slide, a familiar sight for the Python and R crowd.
4.3 **Dataframe** - load and summarise the penguins in a dataframe [demo] [tbd: library].
4.4 **Plot** - a scatter plot of the penguins [demo] [tbd: library].
4.5 **Tensor** - the tensor library underneath, one small computation [demo] [tbd: library].
4.6 **Rocks ahead** - one honest limitation of the data stack [tbd].

### 5. Island 4: An Expressive Language (~2.5 min)

Two language features that make Nim good for scientific use. Carries K2.

5.1 **Island 4** - section title on the map.
5.2 **Custom operators** - defining an operator in one line and using it in a formula (the easy feature) [tbd: example].
5.3 **Metaprogramming** - a macro or template that removes boilerplate in a scientific setting (the advanced feature) [tbd: example].
5.4 **Rocks ahead** - with great power: macros can make code hard to read for newcomers.

### 6. Island 5: Interoperability (~3 min)

Nim is easy to combine with other languages, in both directions. Carries K3.

6.1 **Island 5** - section title on the map.
6.2 **Wrapping C and C++** - calling an existing C library from Nim in a few lines [tbd: library].
6.3 **Bridges** - two-way bridges to Python, R and Julia, with an honest maturity rating for each [tbd: which libraries].
6.4 **Nim from Python** - a Nim function imported and called from Python, "almost like Rust" [demo] [tbd: example].
6.5 **Rocks ahead** - packaging and distribution of Nim extensions [tbd].

### 7. Island 6: Interactivity (~2.5 min)

Nim compiles to JavaScript: a snappy port of a fun Shiny app. Carries K2 and K4.

7.1 **Island 6** - section title on the map.
7.2 **The original Shiny app** - what the app does and why it is fun [tbd: which app].
7.3 **The Nim port** - the same app compiled to JavaScript, running in the browser [demo].
7.4 **Rocks ahead** - no Jupyter- or Marimo-style interactivity in Nim yet.

### 8. Island 7: Notebook (~2.5 min)

The literate computing paradigm Jupyter made central, and a Nim option that goes in an unexpected direction. Carries K4.

8.1 **Island 7** - section title on the map.
8.2 **Literate computing** - from Knuth to Jupyter: why notebooks matter in science.
8.3 **nimib** - a notebook that is a plain Nim program producing html; this very deck is made with it.
8.4 **Rocks ahead** - honest trade-offs of the nimib approach compared to Jupyter.

### 9. Conclusion: back on land (~2.5 min)

Takeaways and an opinionated reflection on why Nim is still niche. Carries K4.

9.1 **Back on land** - the map with all seven islands visited.
9.2 **For the beginner** - an accessible, fun language to try, at least as a learning tool, and where to start.
9.3 **For the builder** - the pros and cons of building scientific tools in Nim.
9.4 **Why still niche?** - an opinionated view of the language, the ecosystem, the community and the governance [tbd: Pietro's views].
9.5 **Thank you** - links: slides, repo, nimib, Nim community.

## Decisions

- Travel metaphor as the spine: a recurring map slide at each island start shows progress and keeps the audience oriented in a 9-section talk. Alternative: a plain agenda slide; rejected because the abstract already sells the voyage.
- "Rocks ahead" closing slide on each island, so the promise of not hiding shortcomings is kept throughout instead of being dumped in the conclusion. Alternative: one "shortcomings" slide in the conclusion; rejected as easy to cut when time runs short.
- The Data Stack island gets the most time (3.5 min) because it is the one a PyData audience will judge hardest. Success Stories gets the least (2 min) because stories are told, not demoed.
- Island 1 stays brief on HPC and points to Mamy's talk, as the audience spec requires.

## Risks / Trade-offs

- [Nine sections in 24 minutes leave about 2.5 minutes per island] → one core slide per island carries the message; everything else is cuttable, and the timing table is checked in rehearsal.
- [Live demos fail on stage or venue wifi is down] → demos are recorded as screenshots or embedded output in the deck (built offline), live runs are optional extras.
- [Too many [tbd] slides make the skeleton hard to judge] → this iteration only fixes the shape; content choices are the next iterations, one island at a time.
