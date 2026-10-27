import nimib, nimiSlides
import ../my

# Section 3: Island 2: Success Stories (see the latest outline in openspec)
# Two competent people did real science with Nim, one in bioinformatics and one in physics.
# Carries K3 (ready for more).

const githubMark = """<svg class="gh-mark" viewBox="0 0 16 16" aria-hidden="true"><path fill="currentColor" d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.28.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/></svg>"""

# a story title: emoji, name and GitHub handle with its logo, linked to the profile
template storyTitle(emoji, name, handle: string) =
  nbRawHtml "<h3>" & emoji & " " & name & " · <a href=\"https://github.com/" & handle & "\">" & githubMark & "@" & handle & "</a></h3>"

template brentSlide = # 3.2
  slide:
    storyTitle("🧬", "Brent Pedersen", "brentp")
    nbRawHtml: """<p class="story-intro">Genomics researcher and software developer:
6 papers on 6 Nim tools (2018-2022),
with 1,944 citations and 1,833 stars.<br>
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
    storyTitle("☀️", "Sebastian Schmidt", "Vindaar")
    nbRawHtml: """<p class="story-intro">A PhD student in Physics searching for solar axions
at CERN's CAST:
the entire analysis code base is written in Nim.<br>
He ended up building an important part
of the data stack in Nim</p>"""
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
.reveal .story-intro { font-size: 0.8em; }
.reveal h3 .gh-mark { height: 0.8em; width: 0.8em; vertical-align: -0.05em; margin-right: 0.15em; }
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
