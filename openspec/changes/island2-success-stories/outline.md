# Outline Delta

## Sections

### 3. Island 2: Success Stories (~2 min)

Two competent people did real science with Nim, one in bioinformatics and one in physics: pioneers, not a big ecosystem. Carries K3 (ready for more). Speaks to both users and authors.

3.1 **Island 2** - section title on the map.
3.2 **🧬 Brent Pedersen · @brentp** - title with a DNA emoji, name and nick only. "Genomics researcher and software developer: 6 papers on 6 Nim tools (2018-2022), with 1,944 citations and 1,833 stars. Others followed (awesome-bionimformatics)", with a link to the awesome-bionimformatics list. Two columns: on the left a compact table of the six tools with year, citations (Google Scholar) and GitHub stars, October 2026 (mosdepth, somalier, slivar, duphold, STRling, hts-nim); on the right six lines of hts-nim that read like Python, with short comments in plain words (read aligned DNA reads, take a region of chromosome 6, keep confident reads, print where each sits). Links to his website and to the explainer (`island2_brentp_explainer.html`) with the genomics background and more on each tool. The speaker says the hts-nim paper's point: scripting-like syntax without the performance cost, at genome scale, and that many users install these tools from bioconda without knowing they run Nim.
3.3 **☀️ Sebastian Schmidt · @Vindaar** - title with a sun emoji, name and nick only; a PhD student in Physics, whose thesis (University of Bonn, 2024) searching for solar axions with a GridPix detector at CERN's CAST experiment, with the entire analysis code base written in Nim, and code, thesis and data public; he ended up building an important part of the data stack in Nim. A short excerpt from the thesis: the axion flux as a Nim proc with physical units in its types, with a plain-words comment on top (how many axions the Sun sends us, units checked when compiling). The speaker quotes why he chose Nim: "the language gets out of my way".
3.4 **Rocks ahead** - a tiny ecosystem: pioneers build what they need, or move where the libraries are. Two quotes side by side: Brent, "I mostly switched to rust since that's where the bioinformatics libs are, but I still really like nim" (personal communication, 2026), and Vindaar in his thesis, "by choosing Nim [...] I underestimated the amount of code I would / had to write [...] I learned way more than I would have otherwise". "I still really like nim" is bold in the theme blue, and "I learned way more than I would have otherwise" is in orange emphasis.

Unchanged: 0-2, 4-9

## Decisions

- ADDED: Success stories (Pietro, 2026-10-27): island 2 tells that two competent people did science successfully with Nim, Brent Pedersen in bioinformatics and Vindaar in physics, named by name and nick. Slide content stays on the science, not on the libraries they built for the data stack, which island 3 covers. Alternatives: two shapes of success (toolmaker vs the scientist who built the stack) and a timeline of the pioneers; set aside to keep the island about science.
