import std / [strutils, json, random, math, algorithm]
import nimib
import nimib / highlight

# A nimib document that explains the bioinformatics work
# of Brent Pedersen (@brentp), the first success story of
# Island 2 (slide 3.2, in slides/island2_stories.nim):
#   nim r slides/island2_brentp_explainer.nim
# writes docs/island2_brentp_explainer.html.
# The toy code below runs when the page is built;
# the hts-nim and slivar snippets are quoted, not run.

# this path writes the page to docs/, not docs/slides/
nbInit(thisFileRel = "island2_brentp_explainer.nim")
# but with it nimib cannot find this file,
# so give the "Show Source" button its source here
const ownSource = staticRead("island2_brentp_explainer.nim")
nb.doc.source = ownSource
nb.doc.context["source"] = %nb.doc.source
nb.doc.context["source_highlighted"] = %highlightNim(nb.doc.source)
nbRawHtml("<style>\n" & """
pre { overflow-x: auto; }
.note { border-left: 4px solid #02A4BD; padding-left: 1em; }
table { font-size: 0.9em; }
""" & "</style>")

nbText """
# Brent Pedersen: genomics tools in Nim

In the talk [Sailing Seas of Scientific
Nim](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/),
Island 2 tells two success stories in forty seconds each.
The first is Brent Pedersen (@brentp on GitHub),
who wrote a set of genomics tools in Nim that are
published in journals, installed from bioconda
and used in many labs.

A slide can only name them. This page takes the time
to explain what they do, starting from the biology
you need to follow along (no background assumed),
then going tool by tool: hts-nim, mosdepth, slivar,
somalier and a few more. Two of the ideas are small
enough to rebuild here in a few lines of Nim, and that
code runs when this page is built, so the output you
see below each block is real.
"""

nbText """
## Genomics in five minutes

**DNA and the genome.** Your DNA is a long string over
a four letter alphabet, the bases A, C, G and T.
The human genome is about 3.1 billion bases, split into
chromosomes (1 to 22, plus X and Y, and the small
mitochondrial one). You carry two copies of each
chromosome, one from each parent (X and Y aside).
Positions in the genome are written like
`chr6:30816675`, a chromosome and an offset.

**The reference.** To talk about differences we need
something to compare to: the *reference genome*,
a consensus human sequence. There are two versions in
common use, GRCh37 (also called hg19) and GRCh38
(hg38), and coordinates differ between them.

**Variants and genotypes.** Two people differ at a few
million positions. A *variant* is a position where a
sample differs from the reference: a single base change
(SNP), a small insertion or deletion (indel), or a large
rearrangement (a *structural variant*, SV, such as a
deletion or a duplication of thousands of bases).
Since you have two copies, at each variant you are
*hom_ref* (both copies like the reference),
*het* (one copy each, heterozygous) or
*hom_alt* (both copies with the alternate allele).
That pair of alleles is your *genotype* there.

**Sequencing.** Machines cannot read a chromosome end
to end. Short-read sequencing (Illumina) shatters the
DNA into millions of fragments and reads about 150
bases from each end of each fragment (a *read pair*,
or two *mates*). Long-read technologies exist too,
but short reads are still the workhorse.
Sequencing the whole genome is *WGS*; sequencing only
the protein-coding parts (about 1-2% of the genome,
captured with probes) is *whole exome sequencing*, WES.

**Alignment.** Each read is then placed (*aligned*,
or *mapped*) on the reference, where it fits best.
The aligner also says how sure it is, the *mapping
quality*: a read from a repeated region could come
from many places, and gets a low score.

**Depth.** Pile up all aligned reads and count, for
each base of the reference, how many reads cover it:
that is the *depth*, or *coverage*. "30X WGS" means the
reads cover each base about 30 times on average.
Depth tells you if you have enough evidence to call
a genotype at a position, and dips or bumps in depth
over a long stretch hint at deletions or duplications.

**Variant calling.** Where the reads in the pile
disagree with the reference, a *variant caller*
decides which genotype best explains them, and writes
the result for one or many samples.

**Families and rare disease.** A classic design in
clinical genomics is the *trio*: a sick child and both
healthy parents. A *de novo* variant is one the child
has and neither parent has: a new mutation, and a prime
suspect for a rare genetic disease. A *pedigree file*
(`.ped`) says who is whose parent and who is affected.

**Population frequency.** A variant that many healthy
people carry is unlikely to cause a rare disease.
[gnomAD](https://gnomad.broadinstitute.org/) is a large
database of how often each variant is seen in the
population, used to filter out the common ones.
"""

nbText """
## The file formats

The data flows through a few standard formats:

| Format | What is in it |
|---|---|
| FASTQ | raw reads, with a quality score for each base |
| BAM / CRAM | reads aligned to the reference |
| VCF / BCF | variants and genotypes, one row per variant |
| BED | plain text list of regions, `chrom start end` |

The aligned reads of a 30X genome take tens of
gigabytes, while its variants fit in about a gigabyte.
BAM is the binary, compressed version of SAM, a text
format with one line per read. CRAM compresses further
by storing only the differences from the reference.
BCF is to VCF what BAM is to SAM.
An *index* (`.bai`, `.crai`, `.csi`, `.tbi`) lets a
program jump to a region without reading the whole file.

Each aligned read in a BAM carries, among other things:
its chromosome and start position, its mapping quality,
a set of *flags* (is it paired, is its mate mapped, is it
on the reverse strand, is it a duplicate...),
and a *CIGAR* string that says how it aligns:
`151M` means 151 bases that match position by position,
`100M2D51M` means 100 bases, then 2 bases of the
reference missing from the read (a deletion), then 51
more.

All of these formats are read and written by
[htslib](https://github.com/samtools/htslib), a C
library, and the command line tools built on it,
[samtools](https://www.htslib.org/) and bcftools.
Almost every genomics tool, in any language, sits on
htslib somewhere.
"""

nbText """
## hts-nim: htslib, from Nim

[hts-nim](https://github.com/brentp/hts-nim) is a Nim
wrapper of htslib. The paper
([Bioinformatics 2018](https://doi.org/10.1093/bioinformatics/bty358),
with Aaron Quinlan, University of Utah;
[preprint](https://www.biorxiv.org/content/10.1101/261735))
makes the case in one line: scripting languages are easy
to write but come with a substantial performance cost,
especially acute at the scale of modern genomics data;
Nim compiles to C, is fast, garbage collected, gives
control over memory reuse, and has a syntax that feels
familiar to Python (and Perl) users.

This is the example from the hts-nim README (quoted,
not run here: it needs htslib and a real BAM file),
with comments for what each line does:
"""

nbRawHtml("<pre><code class=\"nohighlight nim hljs\">" & highlightNim("""
import hts

# open a BAM (or CRAM) file, and its index
var b: Bam
open(b, "tests/HG02002.bam", index=true,
     fai="/data/human/g1k_v37_decoy.fa")

# every read in the file
for record in b:
  if record.mapping_quality > 10u:
    echo record.chrom, record.start, record.stop

# only the reads in a 2 million base region
# of chromosome 6 (the index makes this fast)
for record in b.query("6", 30816675, 32816675):
  # flags: properly paired and on the reverse strand
  if record.flag.proper_pair and record.flag.reverse:
    # the CIGAR, one operation at a time
    for op in record.cigar:
      echo $op, " ", op.consumes.reference, " ",
           op.consumes.query
    # tags: extra fields, here NM = number of
    # mismatches against the reference
    var mismatches = tag[int](record, "NM")
    if not mismatches.isNone and mismatches.get < 3:
      var rg = tag[string](record, "RG")""") & "</code></pre>")

nbText """
For a Python user this reads almost like
[pysam](https://github.com/pysam-developers/pysam),
the Python wrapper of the same library, but it compiles
to a native binary that runs at the speed of C and
ships as a single executable.
The hts-nim repository also has
[hts-nim-tools](https://github.com/brentp/hts-nim-tools),
small command line examples, and its
[wiki](https://github.com/brentp/hts-nim/wiki/Example-uses-of-hts-nim)
lists about fifteen projects by other people built on
it, including two from SeqOne, a genomics company.

Wrapping a C library is Island 5 of the talk:
hts-nim is a real world example of how far that goes.
"""

nbText """
## mosdepth: how deep is the coverage?

[mosdepth](https://github.com/brentp/mosdepth)
([Bioinformatics 2018](https://doi.org/10.1093/bioinformatics/btx699))
computes depth from a BAM or CRAM: per base, as the mean
over fixed-size windows (used to find copy number changes,
CNVs), as the mean over the regions of a BED file (the
exome capture regions, say), or as the fraction of bases
covered at least 10, 20, 30 times (a standard quality
check: "is 95% of the exome covered at 20X?").

It is the most used of Brent's tools: the paper has
around 1,200 citations on Google Scholar and the repo
about 900 stars on GitHub (October 2026).

**The trick.** Instead of piling up reads base by base,
mosdepth allocates one array of integers as long as the
chromosome. For each aligned read it adds 1 at the
position where the read starts and subtracts 1 where it
ends. The depth at a position is then the cumulative sum
of the array up to that position. One pass over the
reads, one pass over the array, no per-read objects.
(The real tool also follows the CIGAR, so that a read
with a deletion does not count over the deleted bases,
and avoids counting twice the overlap of two mates.)

Here is the idea on a toy chromosome of 60 bases
with 12 random reads of length 15:
"""

nbCode:
  randomize(2026)
  const chromLen = 60
  const readLen = 15
  var reads: seq[(int, int)] # (start, stop), stop excluded
  for i in 1 .. 12:
    let start = rand(chromLen - readLen)
    reads.add (start, start + readLen)
  reads.sort()

  # the mosdepth array: +1 at start, -1 at stop
  var delta = newSeq[int](chromLen + 1)
  for (start, stop) in reads:
    inc delta[start]
    dec delta[stop]

  # depth = cumulative sum
  var depth = newSeq[int](chromLen)
  var running = 0
  for i in 0 ..< chromLen:
    running += delta[i]
    depth[i] = running

  # draw the reads and the depth
  for (start, stop) in reads:
    echo " ".repeat(start) & "=".repeat(stop - start)
  echo "-".repeat(chromLen)
  echo depth.join("")
  echo "max depth: ", depth.max,
    ", mean depth: ", formatFloat(depth.sum / chromLen, ffDecimal, 1)

nbText """
Each row of `=` is a read; the bottom row is the depth
at each base, and it matches what you get by counting
the reads above it. The same few lines scale to the
249 million bases of chromosome 1: the README notes
that the array then takes about 1 GB of memory,
the price paid for the speed.

From the mosdepth README, on a 30X genome
(per-base depth, single thread, BAM):

| Tool | Run time |
|---|---|
| mosdepth | 25 min |
| samtools depth | 50 min |
| bedtools genomecov | 2 h 14 min |
| sambamba | 2 h 24 min |

With 3 threads mosdepth goes down to about 14 minutes,
and window mode to under 9.

<div class="note">

One honest note from the README: mosdepth "must be built
with the `--mm:refc` flag for optimal performance and
correct operation", that is with Nim's older memory
manager, not the ORC default of Nim 2.

</div>
"""

nbText """
## slivar: one-line rules for families

[slivar](https://github.com/brentp/slivar)
([npj Genomic Medicine 2021](https://www.nature.com/articles/s41525-021-00227-3))
filters and annotates variants in a VCF with short
expressions, written in JavaScript, applied to every
family in a cohort. Given a VCF with 200 trios and their
pedigree file, an expression that talks about `kid`,
`mom` and `dad` is tested on each of the 200 trios.
This is the de novo rule from the README:
"""

nbRawHtml("""<pre><code class="nohighlight javascript hljs">variant.FILTER == 'PASS' &&
variant.call_rate > 0.95 &&   // genotype known for most of the cohort
INFO.gnomad_af < 0.001 &&     // rare in gnomAD
kid.het && mom.hom_ref && dad.hom_ref &&
kid.DP > 7 && mom.DP > 7 && dad.DP > 7 &&  // enough depth in all three
(mom.AD[1] + dad.AD[1]) == 0  // no read with the variant in the parents</code></pre>""")

nbText """
Read it with the glossary above: the variant passed the
caller's filters, is rare in the population, the child is
heterozygous, both parents look like the reference,
each of the three has more than 7 reads there (`DP`,
the depth), and not a single parental read supports the
alternate allele (`AD`, the allele depths: `AD[0]` reads
for the reference, `AD[1]` for the alternate).

slivar also annotates variants with gnomAD frequencies
at more than 30,000 variants per second from a 1.5 GB
compressed file, and finds compound heterozygotes
(two different damaging variants, one from each parent,
in the same gene). The paper uses it to estimate how
many candidate variants a rare disease study should
expect per trio, after good filtering: about ten per
exome, under twenty per genome.

How does a Nim program run JavaScript? slivar embeds
[duktape](https://duktape.org/), a small JavaScript
engine written in C, through a Nim wrapper
(duktape-nim, also by Brent). Interop again, in the
other direction: the fast loop is Nim, the user-facing
rules are JavaScript.

Here is the same de novo rule written as a Nim proc,
on four made-up variants in one trio:
"""

nbCode:
  type
    Genotype = enum homRef, het, homAlt
    Call = object
      gt: Genotype
      depth: int     # DP
      altReads: int  # AD[1]
    TrioVariant = object
      name: string
      popFreq: float # gnomAD allele frequency
      kid, mom, dad: Call

  proc isDeNovo(v: TrioVariant): bool =
    v.popFreq < 0.001 and
      v.kid.gt == het and v.mom.gt == homRef and v.dad.gt == homRef and
      v.kid.depth > 7 and v.mom.depth > 7 and v.dad.depth > 7 and
      v.mom.altReads + v.dad.altReads == 0

  let variants = [
    TrioVariant(name: "chr2:1000", popFreq: 0.0,
      kid: Call(gt: het, depth: 31, altReads: 14),
      mom: Call(gt: homRef, depth: 28), dad: Call(gt: homRef, depth: 35)),
    TrioVariant(name: "chr7:2000 (common)", popFreq: 0.12,
      kid: Call(gt: het, depth: 30, altReads: 15),
      mom: Call(gt: homRef, depth: 29), dad: Call(gt: homRef, depth: 33)),
    TrioVariant(name: "chr9:3000 (dad has 2 alt reads)", popFreq: 0.0,
      kid: Call(gt: het, depth: 27, altReads: 12),
      mom: Call(gt: homRef, depth: 30), dad: Call(gt: homRef, depth: 25, altReads: 2)),
    TrioVariant(name: "chr12:4000 (mom depth 5)", popFreq: 0.0,
      kid: Call(gt: het, depth: 33, altReads: 16),
      mom: Call(gt: homRef, depth: 5), dad: Call(gt: homRef, depth: 31)),
  ]
  for v in variants:
    echo (if v.isDeNovo: "de novo   " else: "filtered  "), v.name

nbText """
## somalier: is this sample who we think it is?

Large studies handle thousands of samples, and tubes get
swapped, labels get mixed, a "sibling" turns out to be a
duplicate. [somalier](https://github.com/brentp/somalier)
([Genome Medicine 2020](https://genomemedicine.biomedcentral.com/articles/10.1186/s13073-020-00761-2))
checks it quickly. It first *extracts*, for each sample,
the genotypes at a fixed set of common variant sites (a
small "sketch" of the sample), directly from the BAM/CRAM
or from a VCF. Then it *relates* all the sketches:
for every pair of samples it measures how many genotypes
they share and computes their relatedness, which should
be about 1 for the same person, 0.5 for parent and child
or siblings, 0 for unrelated people. Comparing that with
the pedigree file flags the swaps.
The relate step is fast: per the README, under 2 seconds
for 600 samples and about a minute for 4,500, with an
interactive HTML report
([example](https://brentp.github.io/somalier/ex.html)).
"""

nbText """
## And more

A few more of his Nim tools, from his GitHub profile
(stars as of October 2026):

| Tool | What it does | Stars |
|---|---|---|
| [mosdepth](https://github.com/brentp/mosdepth) | depth from BAM/CRAM | 878 |
| [somalier](https://github.com/brentp/somalier) | sample identity and relatedness | 341 |
| [slivar](https://github.com/brentp/slivar) | variant filtering with expressions | 274 |
| [hts-nim](https://github.com/brentp/hts-nim) | htslib for Nim | 159 |
| [jigv](https://github.com/brentp/jigv) | self-contained igv.js pages to look at reads and variants | 132 |
| [duphold](https://github.com/brentp/duphold) | adds depth evidence to deletion and duplication calls | 109 |
| [seqcover](https://github.com/brentp/seqcover) | coverage across many genes and samples | 51 |

duphold is a nice follow-up of the depth story: a
structural variant caller may claim a deletion from the
shape of the read pairs, and duphold checks whether the
depth actually drops there ("we will be skeptical of
deletion calls that do not have lower than average
coverage"). Altogether he has 32 Nim repositories,
including small libraries like
[nim-lapper](https://github.com/brentp/nim-lapper)
(fast interval overlaps) that others reuse.
Several of these tools are installed from
[bioconda](https://bioconda.github.io/), the conda
channel of bioinformatics, so many users run them
without ever knowing they are written in Nim.
"""

nbText """
## Why this is a success story

For the talk the point is simple: a competent scientist
picked a niche language and used it to build tools for
real research. They are published in peer reviewed
journals, cited and installed by people who never need
to know which language they are written in.
Nim gave him a scripting-like syntax with the speed
of C, and the C ecosystem of genomics (htslib, duktape,
libBigWig) a few lines of wrapping away.

The rocks ahead are real too: the genomics ecosystem
in Nim is small, so he wrapped or wrote what he needed
himself, from the htslib bindings to an interval tree.
That is the price of being a pioneer.

## Sources

[hts-nim paper](https://doi.org/10.1093/bioinformatics/bty358),
[mosdepth paper](https://doi.org/10.1093/bioinformatics/btx699),
[slivar paper](https://www.nature.com/articles/s41525-021-00227-3),
[somalier paper](https://genomemedicine.biomedcentral.com/articles/10.1186/s13073-020-00761-2),
[duphold paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6479422/),
the READMEs of each repository, and
[his Nim repositories](https://github.com/brentp?tab=repositories&language=nim&sort=stargazers).
"""

nbSave
