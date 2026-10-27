# Outline Delta

## Sections

### 3. Island 2: Success Stories (~2 min)

Two competent people did real science with Nim, one in bioinformatics and one in physics: pioneers, not a big ecosystem. Carries K3 (ready for more). Speaks to both users and authors.

3.1 **Island 2** - section title on the map.
3.2 **Brent Pedersen (@brentp): bioinformatics** - genomics tools in Nim, each with its own paper and installed from bioconda by people who may never know they run Nim: hts-nim, a wrapper of the C library htslib (Bioinformatics 2018), mosdepth for sequencing depth (Bioinformatics 2018, per-base depth of a 30X genome in about half the time of samtools), somalier (Genome Medicine 2020) and slivar (npj Genomic Medicine 2021). A few lines of hts-nim that read like Python. The speaker says the hts-nim paper's point: scripting-like syntax without the performance cost, at genome scale.
3.3 **Sebastian Schmidt (@Vindaar): physics** - a PhD thesis (University of Bonn, 2024) searching for solar axions with a GridPix detector at CERN's CAST experiment, with the entire analysis code base written in Nim, and code, thesis and data public. A short excerpt from the thesis: the axion flux as a Nim proc with physical units in its types. The speaker quotes why he chose Nim: "the language gets out of my way".
3.4 **Rocks ahead** - a tiny ecosystem means pioneers build what they need themselves, in Vindaar's own words: "by choosing Nim as the target language I underestimated the amount of code I would / had to write", and yet "I learned way more than I would have otherwise".

Unchanged: 0-2, 4-9

## Decisions

- ADDED: Success stories (Pietro, 2026-10-27): island 2 tells that two competent people did science successfully with Nim, Brent Pedersen in bioinformatics and Vindaar in physics, named by name and nick. Slide content stays on the science, not on the libraries they built for the data stack, which island 3 covers. Alternatives: two shapes of success (toolmaker vs the scientist who built the stack) and a timeline of the pioneers; set aside to keep the island about science.
