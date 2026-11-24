# Outline

The living plan of the talk: sections, timing and slides (`<section>.<slide>` IDs, used by the slide files). Updated in place; decisions behind it are in [decisions/](decisions/).

## Narrative Arc

The talk is a sea voyage. From a boat you only get a very limited view of the land: we will not go in depth anywhere, and the audience gets the feeling of each island rather than a tour of it. We leave the familiar mainland of scientific computing (Fortran, C, C++, R, Python, Julia) noting that each language came with its own tradeoffs and promising to show Nim's (K1: Nim's tradeoffs as a scientific computing language, and its untapped potential). We then hop across seven islands, and together they show Nim's strengths (K2: easy like Python, fast as C, with superpowers: metaprogramming, the JavaScript backend and interop), while the success stories and the data stack show it holds up in real work (K3: pragmatic, Nim is ready for more). Where it fits, an island ends with an honest "rocks ahead" line on where Nim falls short, so the pitfalls add up along the way (K3). We touch back land in the conclusion with one takeaway for the beginner, one for the builder, and an opinionated look at why Nim is still niche despite being stable and ready for more (K3), closing K1: why it is fun, exciting, and has more potential than the impact it had so far. Throughout, comparisons with the audience's languages are framed as tradeoffs, not as a contest, so people leave appreciating their own language and the diversity of languages better (K4: appreciate the diversity of languages).

K1-K4 are the key messages in [decisions/tone.md](decisions/tone.md). Why the outline is shaped this way is in [decisions/islands.md](decisions/islands.md).

## Timing

| # | Section | Minutes | Ends at |
|---|---------|---------|---------|
| 0 | Opening: title and about me | 1 | 01:00 |
| 1 | Intro: leaving the mainland | 2 | 03:00 |
| 2 | Island 1: Accessible Performance | 1 | 04:00 |
| 3 | Island 2: Success Stories | 2.5 | 06:30 |
| 4 | Island 3: Data Stack | 3.5 | 10:00 |
| 5 | Island 4: Interoperability | 3 | 13:00 |
| 6 | Island 5: An Expressive Language | 2.5 | 15:30 |
| 7 | Island 6: Interactivity | 2.5 | 18:00 |
| 8 | Island 7: Notebook | 2.5 | 20:30 |
| 9 | Conclusion: back on land | 2.5 | 23:00 |

Total 23 minutes of content, leaving 7 minutes for Q&A and slack.

## Sections

Navigation: each section except the opening is a vertical stack in reveal.js. Its section/map slide (the intro's first slide) sits on the top row, and the section's content slides are below it, so left/right moves between sections and down goes through a section.

### 0. Opening (~1 min)

Title and speaker, before the voyage starts. Not part of the intro section.

0.1 **Sailing Seas of Scientific Nim** - title slide (short form, fits on one line) with speaker and conference (existing slide).
0.2 **👋 About me** (`slides/about.nim`) - Pietro Peterlongo; ~~Data Scientist~~ Delivery Manager at AgileLab; organizer of Python Milan and PyData Milan; Nim since 2018, the nimib "notebook" since 2020; applied math from geosciences to cryptography. Then a second heading, "About AgileLab?": data consulting, ~350 people (2x in 3 years), public handbook (linked), holacracy, nomads. Orange for the personal and Nim parts, teal for AgileLab. Emojis after Pietro's domain-driven data science talk; the Paris PhD years (LMD, ENS), the clients and the details go in the speaker notes.

### 1. Intro: leaving the mainland (~2 min)

Set up the voyage: many languages, each with its tradeoffs; this talk shows Nim's. Carries K1 and K4.

1.1 **The mainland** - a map of scientific computing languages over time: Fortran, C, C++, R, Python, Julia.
1.2 **Why so many languages?** - each language came to solve a problem the previous ones did not; the two-language problem as the classic example.
1.3 **Nim's tradeoffs** - the abstract's question "is there space for one more?" reframed: this talk is about Nim's specific tradeoffs, seven islands, and we won't hide where Nim falls short.
1.4 **The map** - the seven islands on one map, used again as a progress marker at each section start.

### 2. Island 1: Accessible Performance (~1 min)

Nim is as easy to write as Python and as fast as C, passed through quickly in one slide (Pietro, 2026-11-24: performance is a given): Mamy's talk in the same session goes deeper. Carries K2.

2.1 **Island 1** - section title on the map.
2.2 **Reads like Python, runs like C** - the Vandermonde matrix with for loops, Python and Nim side by side (the code of `bench/vandermonde`), and a mini benchmark table: Python loops, NumPy's `np.vander`, Nim loops (one 1000 x 100 matrix, Nim row highlighted, times read from `bench/vandermonde/results.csv`). One line in orange: *No ceiling*, down to SIMD, threads, GPUs and assembly (Mamy's talk in this session only in the speaker notes, Pietro). A reference line with the machine and a link to the deep dive (`deepdive/vandermonde.html`). The speaker says that in Nim you are allowed to write for loops (in Python you call NumPy, whose loop is in C), and that "no ceiling" means you can go down to assembly and optimise all you want.

### 3. Island 2: Success Stories (~2.5 min)

Competent people did real science with Nim, in bioinformatics, in physics and in lattice QCD: pioneers, not a big ecosystem. Carries K3 (ready for more). Speaks to both users and authors.

3.1 **Island 2** - section title on the map.
3.2 **Success stories** - how we define success stories in scientific computing: people who used Nim to advance science. Three stories follow: 🧬 Bioinformatics, ☀️ Physics and ⚛️ Lattice QCD. A note links an explainer with Nim success stories beyond science (web, blockchain, security, games, chips and more), for the curious and to show breadth.
3.3 **🧬 Brent Pedersen · @brentp** - title with a DNA emoji, name and nick only, the nick linked to his GitHub profile with a small GitHub logo. "Genomics researcher and software developer: 6 papers on 6 Nim tools (2018-2022), with 1,944 citations and 1,833 stars. Others followed (awesome-bionimformatics)", with a link to the awesome-bionimformatics list. Two columns: on the left a compact table of the six tools with year, citations (Google Scholar) and GitHub stars, October 2026 (mosdepth, somalier, slivar, duphold, STRling, hts-nim); on the right six lines of hts-nim that read like Python, with short comments in plain words (read aligned DNA reads, take a region of chromosome 6, keep confident reads, print where each sits). Links to his website and to the explainer (`deepdive/brentp.html`) with the genomics background and more on each tool. The speaker says the hts-nim paper's point: scripting-like syntax without the performance cost, at genome scale, and that many users install these tools from bioconda without knowing they run Nim.
3.4 **☀️ Sebastian Schmidt · @Vindaar** - title with a sun emoji, name and nick only, the nick linked to his GitHub profile with a small GitHub logo; a PhD student in Physics, whose thesis (University of Bonn, 2024) searching for solar axions with a GridPix detector at CERN's CAST experiment, with the entire analysis code base written in Nim, and code, thesis and data public, plus a link to an explainer of the thesis in plain words; he ended up building an important part of the data stack in Nim. A short excerpt from the thesis: the axion flux as a Nim proc with physical units in its types, with a plain-words comment on top (how many axions the Sun sends us, units checked when compiling). The speaker quotes why he chose Nim: "the language gets out of my way".
3.5 **⚛️ Osborn & Jin · QEX** - title with an atom emoji, the two authors' surnames and QEX linked to its GitHub repository with a small GitHub logo. "Two physicists at Argonne National Laboratory build a lattice QCD framework in Nim: since 2016, still very active (298 commits in 2026). Others use it for new physics." Below, the plaquette loop from QEX's example `ex1.nim` (go around the smallest squares of the space-time lattice inside `threads:`), with a plain-words comment on top. Links to the 2016 framework paper (arXiv:1612.02750), the code, the symmetric mass generation paper that uses it (arXiv:2409.02062, PRL 2025) and the explainer (`deepdive/qex.html`). The speaker says what lattice QCD is in one line, that QEX is the most active scientific Nim project since 2024, that Curtis Peterson (Colorado) added the Pauli-Villars simulations used in Anna Hasenfratz's group papers, and that its docs are a nimibook.
3.6 **Rocks ahead** - a tiny ecosystem: pioneers build what they need, or move where the libraries are. Two quotes side by side: Brent, "I mostly switched to rust since that's where the bioinformatics libs are, but I still really like nim" (personal communication, 2026), and Vindaar in his thesis, "by choosing Nim [...] I underestimated the amount of code I would / had to write [...] I learned way more than I would have otherwise". "I still really like nim" is bold in the theme blue, and "I learned way more than I would have otherwise" is in orange emphasis.

### 4. Island 3: Data Stack (~3.5 min)

The basic building blocks of the data ecosystem, through an exploration of the penguins dataset: Arraymancer, Datamancer and ggplotnim, the Nim mirror of NumPy, pandas/dplyr and matplotlib/ggplot2, presented bottom-up. Carries K2 and K3.

4.1 **Island 3** - section title on the map.
4.2 **The stack** - the building blocks of data science as in the Python Data Science Handbook by Jake VanderPlas: a table of tensors, dataframes and plots in Python (NumPy, pandas, matplotlib), R (arrays, dplyr, ggplot2) and Nim (Arraymancer, Datamancer, ggplotnim).
4.3 **Meet the penguins** - Allison Horst's artwork in full on the top half, then a short summary of the dataset (344 penguins, three species, three islands near Palmer Station) and of what the explainer covers, with its link; data and artwork credits.
4.4 **Tensors: Arraymancer** - NumPy-like tensors on their own, not the penguins: a 3 x 4 matrix from a range, slicing, explicit broadcasting, and a linear system solved with LAPACK [example]; inspired by NumPy and PyTorch: a solid ndarray with linear algebra, a compact deep learning framework, and the seeds of scikit-learn; speaker notes: last release October 2024, a few commits a year since.
4.5 **Dataframes: Datamancer** - inspired by dplyr, built on Arraymancer: read the penguins CSV, drop missing values with a formula, mean body mass (g) and flipper length (mm) per species [example].
4.6 **Plots: ggplotnim** - a port of ggplot2, using Datamancer dataframes: flipper length against body mass colored by species [example].
4.7 **SciNim** - the organization that gathers the scientific Nim libraries; its getting started site (tutorials and a list of libraries); a few more libraries: flambeau (libtorch bindings), nim-plotly (plotly.js; started by Brent Pedersen and donated to SciNim, in the speaker notes), numericalnim (integration, ODEs, optimization, interpolation).
4.8 **Rocks ahead** - classic ML is only seeds: a few algorithms, no scikit-learn; multiple tensor libraries; the ecosystem depends on a few contributors (Vindaar, mratsim, Clonkk, HugoGranstrom): when life happens, development stops.

### 5. Island 4: Interoperability (~3 min)

Nim is easy to combine with other languages, in both directions. Carries K2 (interop superpower) and K3.

5.1 **Island 4** - section title on the map.
5.2 **Wrapping C and C++** - calling an existing C library from Nim in a few lines [tbd: library].
5.3 **Bridges** - two-way bridges to Python, R and Julia, with an honest maturity rating for each [tbd: which libraries].
5.4 **Nim from Python** - a Nim function imported and called from Python, "almost like Rust" [example] [tbd: example].
5.5 **Rocks ahead** - packaging and distribution of Nim extensions [tbd].

### 6. Island 5: An Expressive Language (~2.5 min)

Two language features that make Nim good for scientific use: custom operators written by hand, then units and their operators generated by macros, inspired by Vindaar's unchained library. Carries K2 (metaprogramming superpower).

6.1 **Island 5** - section title on the map.
6.2 **Custom Operators: defined** - "You can define custom operators easily in Nim, as a normal function, using backticks"; hand-written geometry: `Line` and `Plane` types over `Point` and `Vec` (a `distinct Point`), `+` joins (two points make a line, a line and a point a plane), `*` meets (a line hits a plane in a point); `Point + Point` is not a point, so the types let it mean the line through them [example].
6.3 **Custom Operators: applied** - "A line is defined by two points, a plane is defined by three points, they generically intersect in one point": the `pt` constructor, the line, the plane and their meet [example]; the slide links its explainer.
6.4 **Macros to define Units** - Vindaar's unchained: units checked at compile time, plain floats at run time; its `declareUnits` macro declares the SI units (left column: Gram and Meter, read from unchained's si_units.nim at build time) and adds the solar mass and the Earth mass (right column), and the macro writes the types, aliases and conversions while `*`, `/` and `+` are macros that work out the unit of the result.
6.5 **Units applied** - Kepler's third law: `period(a, mass)` is `2 * PI * sqrt(a^3 / (G_Newton * mass))` for any length and any mass: the year of Mars (1.524 AU around one solar mass) and the month of the Moon (384 400 km around one Earth mass); adding a length to a mass does not compile [example]; the slide links its explainer.
6.6 **Rocks ahead** - with great power: macros can make code hard to read for newcomers; concepts (compile-time duck typing) were not robust until possibly recently.

### 7. Island 6: Interactivity (~2.5 min)

Nim compiles to JavaScript: a snappy port of a fun Shiny app, the generative plant of Nick Strayer. Carries K2 (JavaScript backend superpower). The deep dive (`deepdive/plant_app.html`) has the code, the numbers, what the JavaScript backend can and cannot do, and the REPL attempts.

7.1 **Island 6** - section title on the map.
7.2 **🌱 A Shiny plant** - Nick Strayer's Shiny for Python app (2022): four sliders (leafiness, order, waviness, simplicity) and a plant drawn by matplotlib; a screenshot with the plant's equations beside it (LaTeX: x, y and the range of t), and a link to the app running on the site with shinylive (Python in the browser with Pyodide, exported by `scripts/shinylive.sh`). One line of numbers: 16 MB to download, 8 s to the first plot, 0.4 s per slider move. The speaker notes say that the shared link no longer runs (Shiny removed the layout it used, a two-line fix).
7.3 **🌿 The Nim plant** - the same app in Nim, compiled to JavaScript, live in the slide (`slides/island6_plant_app.nim`: Karax and a canvas bound with importjs), beside its Karax code (`buildHtml`); the slider lines of the code can be dragged to reorder the app's sliders (zogyn, declarative dragging, `slides/island6_plant_code.nim`). One line of numbers: first plot in 30 ms, 250× sooner than Shiny; 300 KB, 50× lighter; link to the deep dive. The speaker says it is not a fair fight: shinylive brings all of Python, Nim translates the program and draws its own plot.
7.4 **Rocks ahead** - no REPL yet, only experiments (nim secret, INim, jupyternim, cicak); a REPL fits interpreted or JIT languages, Nim is statically typed and compiled ahead of time; so no Jupyter- or Marimo-style interactivity in Nim (nimib goes another way: next island).

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
9.6 **Thank you** - the last slide of the top row, after the conclusion stack. An animation written in Nim with p5nim and compiled to JavaScript: a grid of colored points flies along curves into the words "Thank You!", one color per letter, back into the grid, then into "Questions?" and back, in a loop, based on a sketch by Okazz (the footer says it is built with p5nim, links a page that explains the code, and credits the sketch by Okazz, CC BY-NC-SA 3.0); the link to the deck is above the footer. It stays on screen during Q&A.
