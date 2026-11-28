import nimib
import nimiSlides except speakerNote # blogpost.nim has its own (my.nim exports it)
import tabelline
import ../my

# Section 3: Island 2: Science (see outline.md)
# Competent people did real science with Nim: in bioinformatics, in physics and in lattice QCD.
# Carries K3 (ready for more).

template storiesIntroSlide* = # 3.2
  slide:
    nbText: """
## Success stories in Science

How do we define success stories in scientific computing?
By looking at *people who used Nim to advance science*.

The following are three stories:

- 🧬 Bioinformatics
- ☀️ Experimental physics
- ⚛️ Theoretical physics
"""
    reference """
Beyond science, Nim runs on the web, in blockchains,
security tools, games, chips and more:
🐋 [Nim success stories beyond science](deepdive/beyond_science.html)
"""
    speakerNote """
Now let's talk science, because we want to do science.
The fun thing: with just that value proposition,
people started doing science with Nim.

Success here means people who used Nim to advance science:
published, cited, used by others.
For the curious, the deep dive collects stories
outside science, to show the breadth.
"""

template bioSlide* = # 3.3
  slide:
    nbText "### 🧬 Nim in Bioinformatics"
    nbLede("""Started by Brent Pedersen
([@brentp](https://github.com/brentp)) with hts-nim (2018):
6 papers on Nim tools he wrote or co-wrote, 2,134 citations.  
Others followed, with papers of their own""", "story")
    let bioTools = @[
      (tool: "[mosdepth](https://github.com/brentp/mosdepth)", by: "Brent Pedersen (+1)",
       paper: "Bioinformatics 2018", citations: 1490, stars: 883),
      (tool: "[somalier](https://github.com/brentp/somalier)", by: "Brent Pedersen (+8)",
       paper: "Genome Medicine 2020", citations: 175, stars: 345),
      (tool: "[slivar](https://github.com/brentp/slivar)", by: "Brent Pedersen (+11)",
       paper: "npj Genomic Medicine 2021", citations: 290, stars: 275),
      (tool: "[SeqFu](https://github.com/telatin/seqfu2)", by: "Andrea Telatin (+2)",
       paper: "Bioengineering 2021", citations: 77, stars: 133),
      (tool: "[STRling](https://github.com/quinlan-lab/STRling)", by: "Harriet Dashnow (+13)",
       paper: "Genome Biology 2022", citations: 68, stars: 72),
      (tool: "[BamToCov](https://github.com/telatin/bamtocov)", by: "Giovanni Birolo (+1)",
       paper: "Bioinformatics 2022", citations: 34, stars: 68)]
    let bioTable = tabella(bioTools, rownameCol = "tool")
      .tabStubhead("tool")
      .colsLabel("by", "first author")
      .fmtMarkdown("tool")
      .fmtInteger(["citations", "stars"])
      .slideLook(fontSize = "0.5em")
    nbTable bioTable
    reference """
Citations from Google Scholar, stars from GitHub (November 2026);
more tools in [awesome-bionimformatics](https://github.com/andreas-wilm/awesome-bionimformatics);
🐋 [the tools, the people and the genomics, explained](deepdive/bioinformatics.html)
"""
    speakerNote """
Almost ten years ago Brent Pedersen started doing
bioinformatics with Nim: it is easier to start in a
domain where there is not a lot of stuff yet.
A tool and a paper, then more tools and more papers,
with good citations and good stars, and others followed.
A successful run for Nim in bioinformatics.

Brent Pedersen started it: hts-nim wraps htslib,
the C library behind samtools, and its paper says
scripting languages are easy but slow at genome scale;
Nim gives a scripting-like syntax without that cost.
mosdepth computes sequencing depth in about half
the time of samtools.
Others followed: SeqFu (Quadram Institute), BamToCov and
sgcocaller are built by other groups, some on hts-nim;
STRling is from the Quinlan lab, with Brent.
Heng Li, the author of samtools, put Nim in his biofast
benchmark: close to C.
Many users install these tools from bioconda
without knowing they run Nim.
"""

template vindaarSlide* = # 3.4
  slide:
    nbText "### ☀️ Nim in Physics 1/2"
    nbLede("""Sebastian Schmidt ([@Vindaar](https://github.com/Vindaar)),
PhD in experimental physics (Bonn, 2024),
searched for solar axions at CERN's CAST:
the entire analysis code base is written in Nim.  
He ended up building an important part
of the data stack in Nim""", "story")
    nbText: """
```nim
# how many axions the Sun sends us at energy E_a,
# per keV, cm² and second; units checked when compiling
proc axionFluxPrimakoff(E_a: keV,
                        g_aγ: GeV⁻¹): keV⁻¹•cm⁻²•s⁻¹ =
  let g₁₀ = g_aγ / 1e-10.GeV⁻¹
  result = g₁₀^2 * 3.821e10.cm⁻²•s⁻¹•keV⁻¹ *
    (E_a / 1.keV)^3 / (exp(E_a / (1.103.keV)) - 1)
```
"""
    reference """
[Thesis](https://doi.org/10.48565/bonndoc-303) (University of Bonn, 2024),
[source](https://github.com/Vindaar/phd),
[code](https://github.com/Vindaar/TimepixAnalysis),
[data](https://zenodo.org/uploads/10521887);
🐋 [the thesis in plain words](deepdive/vindaar.html)
"""
    speakerNote """
Another person who wanted to do science with Nim is
Sebastian, aka Vindaar: he did his whole PhD in Nim,
and doing that he built the stack. More about him later:
he could not be here, and the scientific Nim community
owes him a lot of gratitude.

A GridPix detector at the CERN Axion Solar Telescope.
Code, thesis and data are all public.
The excerpt is from the thesis: the axion flux,
with physical units in the types, checked at compile time.
Why Nim, in his words: "the language gets out of my way".
"""

template qexSlide* = # 3.5
  slide:
    nbText "### ⚛️ Nim in Physics 2/2"
    nbLede("""James Osborn and Xiao-Yong Jin (Argonne National Laboratory)
build [QEX](https://github.com/jcosborn/qex), a lattice QCD framework in Nim
(theoretical physics, computed on supercomputers):
since 2016, still very active (298 commits in 2026).  
Others use it for new physics""", "story")
    nbText: """
```nim
# the plaquette: go around the smallest squares
# of the space-time lattice, add up what you get
threads:
  m := 0
  for mu in 1..<nd:
    for nu in 0..<mu:
      m += (t[mu]^*g[nu]) * (t[nu]^*g[mu]).adj
  tr = trace(m)
```
"""
    reference """
[Paper](https://arxiv.org/abs/1612.02750) (2016),
[code](https://github.com/jcosborn/qex),
[new physics](https://arxiv.org/abs/2409.02062) (PRL 2025);
🐋 [lattice QCD and QEX in plain words](deepdive/qex.html)
"""
    speakerNote """
And then you discover people at a US national
laboratory using Nim for QEX. They do not interact much
with the community, and that is fine: Nim is just a very
good language, usable without a big ecosystem.
Still ongoing, still very active.

QEX is Quantum EXpressions, by James Osborn and Xiao-Yong Jin.
Lattice QCD computes how quarks and gluons bind into protons,
on a grid of space-time points, on supercomputers.
Since 2024 it is the most active scientific Nim project we found.
The excerpt is from its examples: the plaquette,
written like the physics formula, run in parallel threads.
Curtis Peterson (Colorado) added Pauli-Villars
staggered simulations, used in papers with Anna Hasenfratz,
like symmetric mass generation (Phys. Rev. Lett. 2025).
Its docs are a book written with nimibook.
"""

template island2RocksSlide* = # 3.6
  slide:
    nbText: """
## ⚠️ Rocks ahead 🪨

A tiny ecosystem: pioneers build what they need,
or move where the libraries are
"""
    nbDiv("rocks-quotes", ""):
      nbQuote("""*I mostly switched to rust* since that's where
the bioinformatics libs are, but **I still really like nim**""",
        "Brent Pedersen, personal communication, 2026")
      nbQuote("""by choosing Nim [...] *I underestimated
the amount of code I would / had to write* [...]
**I learned way more than I would have otherwise**""",
        "Vindaar, in his thesis")
    speakerNote """
The first rocks ahead. Brent mostly switched to Rust:
ten years ago Nim and Rust were still contending,
and Nim could have grown; Rust grew a lot, Nim did not.
And when you want to do science you do not want to
build the ecosystem: you want it there.

Brent: his newer tools are in Rust, because that is
where the bioinformatics libraries are; he still likes Nim.
Vindaar: from the thesis appendix on why he wrote his own
analysis framework: the extra work delayed the thesis,
and he says he learned way more.
"""

template island2StoriesSection* =
  slide:
    mapSlide(2) # 3.1
    storiesIntroSlide
    bioSlide
    vindaarSlide
    qexSlide
    island2RocksSlide

when isMainModule: # this part of the deck on its own: docs/slides_island2.html
  buildDeckPart("island2", "slides/island2_stories.nim"):
    island2StoriesSection
