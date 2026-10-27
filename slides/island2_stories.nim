import nimib, nimiSlides
import ../my

# Section 3: Island 2: Success Stories (see the latest outline in openspec)
# Two competent people did real science with Nim, one in bioinformatics and one in physics.
# Carries K3 (ready for more).

template brentSlide = # 3.2
  slide:
    nbText: """
## Brent Pedersen

### @brentp · bioinformatics

Genomics tools in Nim, each with its paper,
installed from bioconda:
**hts-nim**, **mosdepth**, **somalier**, **slivar**

```nim
import hts
var b: Bam
open(b, "sample.bam", index=true)
for record in b.query("6", 30816675, 32816675):
  if record.mapping_quality > 10u:
    echo record.chrom, record.start, record.stop
```
"""
    reference """
[hts-nim](https://github.com/brentp/hts-nim) (Bioinformatics 2018),
[mosdepth](https://github.com/brentp/mosdepth) (Bioinformatics 2018),
[somalier](https://github.com/brentp/somalier) (Genome Medicine 2020),
[slivar](https://github.com/brentp/slivar) (npj Genomic Medicine 2021)
"""
    speakerNote """
hts-nim wraps htslib, the C library behind samtools.
The point of its paper: scripting languages are easy,
but slow at the scale of modern genomics data;
Nim gives a scripting-like syntax without that cost.
mosdepth computes sequencing depth: per base on a 30X genome
in about half the time of samtools (its README benchmark).
Many users install these tools without knowing they run Nim.
"""

template vindaarSlide = # 3.3
  slide:
    nbText: """
## Sebastian Schmidt

### @Vindaar · physics

A PhD searching for solar axions at CERN's CAST:
the entire analysis code base is written in Nim

```nim
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
[data](https://zenodo.org/uploads/10521887)
"""
    speakerNote """
A GridPix detector at the CERN Axion Solar Telescope.
Code, thesis and data are all public.
The excerpt is from the thesis: the axion flux,
with physical units in the types, checked at compile time.
Why Nim, in his words: "the language gets out of my way".
"""

template rocksAheadSlide = # 3.4
  slide:
    nbText: """
## Rocks ahead

A tiny ecosystem: pioneers build what they need

> by choosing Nim as the target language
> I underestimated the amount of code
> I would / had to write [...]
> I learned *way* more than I would have otherwise

Vindaar, in his thesis
"""
    speakerNote """
From the thesis appendix on why he wrote his own
analysis framework: the extra work delayed the thesis,
and he says he learned way more.
"""

template island2StoriesSection* =
  slide:
    mapSlide(2) # 3.1
    brentSlide
    vindaarSlide
    rocksAheadSlide
