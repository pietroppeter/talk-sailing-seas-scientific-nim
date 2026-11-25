# Open points

Everything still open or undecided, collected on 2026-11-24 after merging PRs #24 to #27. Talk is Thu 26 Nov 2026. Tick or delete lines as they get decided.

## Decisions

- [ ] Voyage map (chart theme adopted 2026-11-24): the lore lines (hidden with the names; shown by `-d:islandNames=true`), coastal views (drawn profiles of an island seen from the sea, as on real charts) not done yet. See `decisions/themes.md`.
- [ ] Timing: with QEX, Island 2 is 2.5 minutes; with Island 1 down to one slide (1 minute) the talk is 23 minutes. Keep, or should the QEX slide replace something?

## Unanswered points from merged PRs

### Island 6 Interactivity (the plant app)

- [ ] Slide 7.2 shows a screenshot of the Shiny app and links the live one (it needs a few seconds and 16 MB to start). Embed it live in the slide instead?
- [ ] The numbers (16 MB, 8 s, 0.4 s; 300 KB, 30 ms) were measured on a cloud machine with headless Chromium; check them on the presentation laptop.
- [ ] "The end of Shiny" (`notes/refs.md`, D3 with the JS backend) is not used: mention it in the deep dive or the speaker notes?

### #24 Arraymancer scope (Island 3)

- [ ] Rocks ahead (4.8) contributor list: add Angel Ezquerra ("Vindaar, mratsim, Clonkk, HugoGranstrom, Angel Ezquerra"), or replace names with numbers ("one person wrote 60% of the commits")?

### Island 3 redo (nanuq, tabelline, deep learning)

Chosen by Claude on 2026-11-25 (Pietro: go with your guts, no slides removed); revisit when polishing:

- [ ] Island 3 has ten content slides for 3.5 minutes: all kept for now. Candidates when trimming: SciNim (4.10) into the stack slide's speaker notes, Datamancer and ggplotnim (4.6, 4.7) on one slide, or the deep learning slide (4.5) into the deep dive only.
- [ ] Slide 4.5 trains the network on every build, so its accuracy moves a little (96 to 97%): kept live, no fixed seed.
- [ ] "Mostly AI-written" stays on the rocks ahead slide itself, as an honest line next to "they need users".
- [ ] nanuq code uses `col("body_mass_g")`, as `pl.col` in Python (nanuq's `col.body_mass_g` does not compile inside the deck's templates): kept.

### #25 QEX success story (Island 2)

- [ ] Slide title "Osborn & Jin · QEX": Xiao-Yong Jin's GitHub handle is unknown. Do you know it?
- [ ] Verify from a paper's acknowledgments that arXiv:2412.10322 and arXiv:2409.02062 ran on QEX, and that Curtis Peterson added the Pauli-Villars code (claims came from search summaries).
- [ ] Rocks ahead (3.6): say something about QEX, like "a small team"? Unchanged for now.

### #26 Themes and talk log

- [ ] The talk log post *Setting sail* leaves out how the work is done (with Claude, decision records). Should the log mention it?
- [ ] Merging published the talk log (`docs/devlog/`) and the themed decks on Pages: check you are fine with them being public.

### #27 tabelline tables

- [ ] On a phone the brentp deep dive tools table scrolls sideways a little for the citations column: drop the "what it does" column there, or fine as is?
- [ ] Slide 3.3: with the content-sized table, the code box reaches further right than before. Shrink it?

### Island 1 in one slide (Vandermonde benchmark)

- [ ] Run `bash bench/vandermonde/run.sh` on the presentation laptop and commit `results.csv` and `machine.txt`, so the slide shows the machine of the talk (today: a cloud machine, where Nim and NumPy are close and Nim's time moves between runs).

## Outline still to fill (`outline.md`)

Placeholder slides that still need content:

- [ ] 1.1 to 1.3 Intro: the mainland map, why so many languages, Nim's tradeoffs.
- [ ] 6.6 Island 5 rocks ahead (macros readability, concepts).
- [ ] 9.2 to 9.5 Conclusion: for the beginner, for the builder, your language seen from Nim, why still niche (your views on governance, tooling, Nimony and NIF).
- [ ] Deep dives for the new code-heavy slides (one nimib page in deepdive/ per code slide).

### Island 7 Notebook

Choices made without you (2026-11-25, to revisit):
- [ ] Facts kept as written, unconfirmed: Hugo Granström as co-maintainer of nimib ("two maintainers" on 8.5), SciNim's getting started built with nimibook, nimibex and nimib.py under nimib-land.
- [ ] Slide 8.4 stays a list; screenshots (a deep dive, a nimibook, the review mode) would make it more visual.
- [ ] Slide 8.2 now has the 2019 notebook study (Pimentel et al.: 1 in 4 ran, 4% same results) as a small line under the bullets.

### Conclusion (draft, 9.2 to 9.5; choices made by Claude on 2026-11-25, to revisit)

- [ ] 9.5 Why still niche: the governance and tooling lines are Claude's draft of your view, kept as is; rewrite them in your words. Nimskull fork and Status funding left out of the speaker notes.
- [ ] 9.3 headings kept as "Fair winds" / "Rocks ahead" (plainer option: "Why build in Nim" / "What it costs").
- [ ] 9.4 rows kept as Python, R, Julia, C/C++ (no Fortran, no Rust).
- [ ] Timing: four content slides kept for 2.5 minutes; merge 9.2 and 9.3 into one "Takeaways" slide if rehearsal runs long.

## Upstream drafts on hold

Not sent; your call whether and when.

- [ ] nimiSlides 0.4.0 LaTeX bug (also footer, slide number, scroll wheel): issue and patch drafts ready; the talk uses a workaround in `my.nim`.
- [ ] Arraymancer `symeig` segfault without eigenvectors: issue, patch and repro ready; search existing issues for "symeig" first; keep or drop the note on failing SVD tests; Co-Authored-By line or not. The slide uses `solve`, and `symeig(a, true)` works.
- [ ] tabelline gotchas found while using it (not filed): `tabella(data): body` fails inside templates, `tableData:` column names get mangled in templates, name clashes with Datamancer (`readCsv`, `Column`) and nimib (`md`).
- [ ] `slides/nbplotly.nim` (`nbPlotly` helper): candidate to move into nimib or nim-plotly.

## Material outside the repo

Working notes that are not committed (on purpose, or not yet):

- Upstream drafts: `latex/upstream/` (nimiSlides issue, PR, patch, repro) and `arraymancer-symeig/` (issue, PR, patch, repro).
- Island 2 research: `island2/directions.md` (sources for Brent, Vindaar and beyond-science stories) and `island2/brentp-numbers.md` (stars and citations, checked 2026-10-27).
- Arraymancer assessment "What is in Arraymancer" and the contributions study "Who builds scientific Nim" (commit shares, yearly activity, QEX).
- Review screenshots and built pages for each piece of work (themes, tabelline, islands, thank-you animation versions).

## Outside this repository

- [ ] Rename `nimlang` to `nimlang-pypi` in the uv-add-nimlang repository and on PyPI (Pietro, 2026-11-24: "nimlang" alone is ambiguous). The talk already calls it nimlang-pypi; its commands (`uv add nimlang`, `uv run nimlang ...`) change with the rename.
