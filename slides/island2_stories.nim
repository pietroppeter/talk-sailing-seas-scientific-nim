import nimib, nimiSlides
import ../my

# Section 3: Island 2: Success Stories (see the latest outline in openspec)
# Two competent people did real science with Nim, one in bioinformatics and one in physics.
# Carries K3 (ready for more).

template brentSlide = # 3.2
  slide:
    nbText: """
### 🧬 Brent Pedersen · @brentp
"""
    nbRawHtml: """<p class="brent-intro">Genomics researcher and software developer:
6 papers on 6 Nim tools (2018-2022),
with 1,944 citations and 1,833 stars.
Others followed
(<a href="https://github.com/andreas-wilm/awesome-bionimformatics">awesome-bionimformatics</a>)</p>"""
    nbRawHtml: """<div class="brent-cols">
<table class="brent-table">
<thead><tr><th>tool</th><th>year</th><th>citations</th><th>stars</th></tr></thead>
<tbody>
<tr><td><a href="https://github.com/brentp/mosdepth">mosdepth</a></td><td>2018</td><td>1452</td><td>878</td></tr>
<tr><td><a href="https://github.com/brentp/somalier">somalier</a></td><td>2020</td><td>172</td><td>341</td></tr>
<tr><td><a href="https://github.com/brentp/slivar">slivar</a></td><td>2021</td><td>141</td><td>274</td></tr>
<tr><td><a href="https://github.com/brentp/duphold">duphold</a></td><td>2019</td><td>93</td><td>109</td></tr>
<tr><td><a href="https://github.com/quinlan-lab/STRling">STRling</a></td><td>2022</td><td>68</td><td>72</td></tr>
<tr><td><a href="https://github.com/brentp/hts-nim">hts-nim</a></td><td>2018</td><td>18</td><td>159</td></tr>
</tbody></table>
<pre><code class="language-nim"># read a file of DNA reads aligned to the genome
import hts
var b: Bam
open(b, "sample.bam", index=true)
# reads in a region of chromosome 6
for r in b.query("6", 30816675, 32816675):
  # keep reads placed with confidence
  if r.mapping_quality > 10u:
    # where each read sits on the genome
    echo r.chrom, r.start, r.stop</code></pre>
</div>"""
    reference """
[brentp.github.io](https://brentp.github.io/);
citations from Google Scholar, stars from GitHub (October 2026);
[the tools and the genomics behind them, explained](island2_brentp_explainer.html)
"""
    speakerNote """
hts-nim wraps htslib, the C library behind samtools.
The point of its paper: scripting languages are easy,
but slow at the scale of modern genomics data;
Nim gives a scripting-like syntax without that cost.
mosdepth computes sequencing depth: per base on a 30X genome
in about half the time of samtools (its README benchmark).
Many users install these tools from bioconda
without knowing they run Nim.
"""

template vindaarSlide = # 3.3
  slide:
    nbText: """
### ☀️ Sebastian Schmidt · @Vindaar

A PhD student in Physics searching for solar axions
at CERN's CAST:
the entire analysis code base is written in Nim.
He ended up building an important part
of the data stack in Nim

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

A tiny ecosystem: pioneers build what they need,
or move where the libraries are
"""
    nbRawHtml: """<div class="rocks-quotes">
<figure><blockquote>I mostly switched to rust since that's where
the bioinformatics libs are, but <strong>I still really like nim</strong></blockquote>
<figcaption>Brent Pedersen, personal communication, 2026</figcaption></figure>
<figure><blockquote>by choosing Nim [...] I underestimated
the amount of code I would / had to write [...]
<em>I learned way more than I would have otherwise</em></blockquote>
<figcaption>Vindaar, in his thesis</figcaption></figure>
</div>"""
    speakerNote """
Brent: his newer tools are in Rust, because that is
where the bioinformatics libraries are; he still likes Nim.
Vindaar: from the thesis appendix on why he wrote his own
analysis framework: the extra work delayed the thesis,
and he says he learned way more.
"""
    nbRawHtml: """<style>
.reveal .brent-intro { font-size: 0.8em; }
.reveal .brent-cols { display: grid; grid-template-columns: auto 1fr; gap: 1.2em; align-items: center; }
.reveal .brent-cols table { font-size: 0.5em; margin: 0; }
.reveal .brent-cols table td:nth-child(n+2), .reveal .brent-cols table th:nth-child(n+2) { text-align: right; font-variant-numeric: tabular-nums; }
.reveal .brent-cols pre { font-size: 0.42em; width: 100%; margin: 0; }
.reveal .rocks-quotes { display: grid; grid-template-columns: 1fr 1fr; gap: 1.5em; }
.reveal .rocks-quotes figure { margin: 0; }
.reveal .rocks-quotes blockquote { width: auto; margin: 0; font-size: 0.75em; }
.reveal .rocks-quotes figcaption { font-size: 0.55em; margin-top: 0.5em; }
</style>"""

template island2StoriesSection* =
  slide:
    mapSlide(2) # 3.1
    brentSlide
    vindaarSlide
    rocksAheadSlide
