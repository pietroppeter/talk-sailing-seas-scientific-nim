import nimib, nimiSlides
import tabelline
import ../my

# Section 3: Island 2: Success Stories (see outline.md)
# Competent people did real science with Nim: in bioinformatics, in physics and in lattice QCD.
# Carries K3 (ready for more).

template storiesIntroSlide = # 3.2
  slide:
    nbText: """
## Success stories

How do we define success stories in scientific computing?
By looking at people who used Nim to advance science.

The following are three stories:  
🧬 Bioinformatics, ☀️ Physics and ⚛️ Lattice QCD
"""
    reference """
Beyond science, Nim runs on the web, in blockchains,
security tools, games, chips and more:
[Nim success stories beyond science](deepdive/beyond_science.html)
"""
    speakerNote """
Success here means people who used Nim to advance science:
published, cited, used by others.
For the curious, the deep dive collects stories
outside science, to show the breadth.
"""

template bioSlide = # 3.3
  slide:
    nbText "### 🧬 Nim in Bioinformatics"
    nbLede("""Started by Brent Pedersen
([@brentp](https://github.com/brentp)) with hts-nim (2018):
6 papers on Nim tools he wrote or co-wrote, 1,944 citations.  
Others followed, with papers of their own""", "story")
    let bioTools = @[
      (tool: "[mosdepth](https://github.com/brentp/mosdepth)", by: "Brent Pedersen",
       paper: "Bioinformatics 2018", stars: 883),
      (tool: "[somalier](https://github.com/brentp/somalier)", by: "Brent Pedersen",
       paper: "Genome Medicine 2020", stars: 345),
      (tool: "[slivar](https://github.com/brentp/slivar)", by: "Brent Pedersen",
       paper: "npj Genomic Medicine 2021", stars: 275),
      (tool: "[SeqFu](https://github.com/telatin/seqfu2)", by: "Andrea Telatin",
       paper: "Bioengineering 2021", stars: 133),
      (tool: "[STRling](https://github.com/quinlan-lab/STRling)", by: "Harriet Dashnow",
       paper: "Genome Biology 2022", stars: 72),
      (tool: "[BamToCov](https://github.com/telatin/bamtocov)", by: "Giovanni Birolo",
       paper: "Bioinformatics 2022", stars: 68)]
    let bioTable = tabella(bioTools, rownameCol = "tool")
      .tabStubhead("tool")
      .colsLabel("by", "first author")
      .fmtMarkdown("tool")
      .barBefore("stars")
      .fmtInteger("stars")
      .slideLook(fontSize = "0.5em")
    nbTable bioTable
    reference """
Stars from GitHub (November 2026), citations from Google Scholar (October 2026);
more tools in [awesome-bionimformatics](https://github.com/andreas-wilm/awesome-bionimformatics);
[the tools, the people and the genomics, explained](deepdive/bioinformatics.html)
"""
    speakerNote """
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

template vindaarSlide = # 3.4
  slide:
    nbGithubTitle("☀️ Sebastian Schmidt", "Vindaar")
    nbLede("""A PhD student in Physics searching for solar axions
at CERN's CAST:
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
[the thesis in plain words](deepdive/vindaar.html)
"""
    speakerNote """
A GridPix detector at the CERN Axion Solar Telescope.
Code, thesis and data are all public.
The excerpt is from the thesis: the axion flux,
with physical units in the types, checked at compile time.
Why Nim, in his words: "the language gets out of my way".
"""

template qexSlide = # 3.5
  slide:
    nbGithubTitle("⚛️ Osborn &amp; Jin", "jcosborn/qex", "QEX")
    nbLede("""Two physicists at Argonne National Laboratory
build a lattice QCD framework in Nim:
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
[lattice QCD and QEX in plain words](deepdive/qex.html)
"""
    speakerNote """
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

template rocksAheadSlide = # 3.6
  slide:
    nbText: """
## Rocks ahead

A tiny ecosystem: pioneers build what they need,
or move where the libraries are
"""
    nbDiv("rocks-quotes", ""):
      nbQuote("""I mostly switched to rust since that's where
the bioinformatics libs are, but **I still really like nim**""",
        "Brent Pedersen, personal communication, 2026")
      nbQuote("""by choosing Nim [...] I underestimated
the amount of code I would / had to write [...]
*I learned way more than I would have otherwise*""",
        "Vindaar, in his thesis")
    speakerNote """
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
    rocksAheadSlide
