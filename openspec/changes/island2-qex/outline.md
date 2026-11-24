# Outline Delta

## Timing

| # | Section | Minutes | Ends at |
|---|---------|---------|---------|
| 0 | Opening: title and about me | 1 | 01:00 |
| 1 | Intro: leaving the mainland | 2 | 03:00 |
| 2 | Island 1: Accessible Performance | 1.5 | 04:30 |
| 3 | Island 2: Success Stories | 2.5 | 07:00 |
| 4 | Island 3: Data Stack | 3.5 | 10:30 |
| 5 | Island 4: Interoperability | 3 | 13:30 |
| 6 | Island 5: An Expressive Language | 2.5 | 16:00 |
| 7 | Island 6: Interactivity | 2.5 | 18:30 |
| 8 | Island 7: Notebook | 2.5 | 21:00 |
| 9 | Conclusion: back on land | 2.5 | 23:30 |

Total 23.5 minutes of content, leaving 6.5 minutes for Q&A and slack.

## Sections

### 3. Island 2: Success Stories (~2.5 min)

Competent people did real science with Nim, in bioinformatics, in physics and in lattice QCD: pioneers, not a big ecosystem. Carries K3 (ready for more). Speaks to both users and authors.

3.1 **Island 2** - section title on the map.
3.2 **Success stories** - how we define success stories in scientific computing: people who used Nim to advance science. Three stories follow: 🧬 Bioinformatics, ☀️ Physics and ⚛️ Lattice QCD. A note links an explainer with Nim success stories beyond science (web, blockchain, security, games, chips and more), for the curious and to show breadth.
3.3 **🧬 Brent Pedersen · @brentp** - title with a DNA emoji, name and nick only, the nick linked to his GitHub profile with a small GitHub logo. "Genomics researcher and software developer: 6 papers on 6 Nim tools (2018-2022), with 1,944 citations and 1,833 stars. Others followed (awesome-bionimformatics)", with a link to the awesome-bionimformatics list. Two columns: on the left a compact table of the six tools with year, citations (Google Scholar) and GitHub stars, October 2026 (mosdepth, somalier, slivar, duphold, STRling, hts-nim); on the right six lines of hts-nim that read like Python, with short comments in plain words (read aligned DNA reads, take a region of chromosome 6, keep confident reads, print where each sits). Links to his website and to the explainer (`island2_brentp_explainer.html`) with the genomics background and more on each tool. The speaker says the hts-nim paper's point: scripting-like syntax without the performance cost, at genome scale, and that many users install these tools from bioconda without knowing they run Nim.
3.4 **☀️ Sebastian Schmidt · @Vindaar** - title with a sun emoji, name and nick only, the nick linked to his GitHub profile with a small GitHub logo; a PhD student in Physics, whose thesis (University of Bonn, 2024) searching for solar axions with a GridPix detector at CERN's CAST experiment, with the entire analysis code base written in Nim, and code, thesis and data public, plus a link to an explainer of the thesis in plain words; he ended up building an important part of the data stack in Nim. A short excerpt from the thesis: the axion flux as a Nim proc with physical units in its types, with a plain-words comment on top (how many axions the Sun sends us, units checked when compiling). The speaker quotes why he chose Nim: "the language gets out of my way".
3.5 **⚛️ Osborn & Jin · QEX** - title with an atom emoji, the two authors' surnames and QEX linked to its GitHub repository with a small GitHub logo. "Two physicists at Argonne National Laboratory build a lattice QCD framework in Nim: since 2016, still very active (298 commits in 2026). Others use it for new physics." Below, the plaquette loop from QEX's example `ex1.nim` (go around the smallest squares of the space-time lattice inside `threads:`), with a plain-words comment on top. Links to the 2016 framework paper (arXiv:1612.02750), the code, the symmetric mass generation paper that uses it (arXiv:2409.02062, PRL 2025) and the explainer (`island2_qex_explainer.html`). The speaker says what lattice QCD is in one line, that QEX is the most active scientific Nim project since 2024, that Curtis Peterson (Colorado) added the Pauli-Villars simulations used in Anna Hasenfratz's group papers, and that its docs are a nimibook.
3.6 **Rocks ahead** - a tiny ecosystem: pioneers build what they need, or move where the libraries are. Two quotes side by side: Brent, "I mostly switched to rust since that's where the bioinformatics libs are, but I still really like nim" (personal communication, 2026), and Vindaar in his thesis, "by choosing Nim [...] I underestimated the amount of code I would / had to write [...] I learned way more than I would have otherwise". "I still really like nim" is bold in the theme blue, and "I learned way more than I would have otherwise" is in orange emphasis.

Unchanged: 0-2, 4-9

## Decisions

- ADDED: QEX as a success story (Pietro, 2026-10-28): island 2 gets a third story, QEX, the lattice QCD framework in Nim by James Osborn and Xiao-Yong Jin at Argonne, the most active scientific Nim project since 2024 and the base of other groups' physics papers. It is a story of a team and a framework rather than of one person, so the title names the two surnames and the project. Its explainer covers lattice QCD in plain words, a toy 2D U(1) lattice that runs at build time, the papers and Jin's neural network field transformations in QEX. Island 2 grows to 2.5 minutes. Alternative: a line in island 3 or in the beyond-science explainer, set aside since QEX is science.
- REMOVED: The Data Stack island gets the most time (3.5 min) because it is the one a PyData audience will judge hardest. Success Stories gets the least (2 min) because stories are told, not demoed.
- ADDED: The Data Stack island gets the most time (3.5 min) because it is the one a PyData audience will judge hardest. Success Stories gets 2.5 min for three stories, told, not demoed.

## Risks / Trade-offs

- ADDED: [Three stories in 2.5 minutes] → each story slide is about 30 seconds of talk; the code excerpt of any story can be skipped on stage, and the explainers carry the depth.
