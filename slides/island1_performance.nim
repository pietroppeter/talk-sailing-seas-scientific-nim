import std / [strutils, strformat, tables]
import nimib
import nimiSlides except speakerNote # blogpost.nim has its own (my.nim exports it)
import tabelline
import ../my

# Section 2: Island 1: Performance (see outline.md)
# Nim is as easy to write as Python and as fast as C, passed through quickly in one slide:
# performance is a given here and Mamy's talk in the same session goes deeper. Carries K2.
# The mini benchmark is bench/vandermonde (run.sh writes results.csv and machine.txt);
# its deep dive is deepdive/vandermonde.nim.

const
  benchDir = "../bench/vandermonde/"
  vanderPy = staticRead(benchDir & "vander.py")
  vanderNim = staticRead(benchDir & "vander.nim")
  benchCsv* = staticRead(benchDir & "results.csv")
  benchMachine* = staticRead(benchDir & "machine.txt")

func marked*(source: string): string =
  ## the code between `# >>> vander` and `# <<< vander` in a benchmark file
  source.split("# >>> vander\n")[1].split("# <<< vander")[0].strip

const
  vanderPyCode* = marked(vanderPy)
  vanderNimCode* = marked(vanderNim)

type BenchRow* = tuple[impl: string, ms: float, speedup: float]

proc benchRows*(benchCase: string): seq[BenchRow] =
  ## the rows of results.csv for `benchCase` ("large" or "small"),
  ## with the speed-up over the Python loops
  var base = 0.0
  for line in benchCsv.strip.splitLines[1 .. ^1]:
    let f = line.split(',')
    if f[0] != benchCase: continue
    result.add (impl: f[1], ms: f[2].parseFloat, speedup: 0.0)
    if f[1] == "Python loops": base = f[2].parseFloat
  for r in result.mitems: r.speedup = base / r.ms

proc benchTable*(benchCase = "large", stubhead = "1000 × 100"): Tabella =
  tabella(benchRows(benchCase), rownameCol = "impl")
    .tabStubhead(stubhead)
    .fmtNumber("ms", decimals = (if benchCase == "large": 2 else: 0))
    .fmtNumber("speedup", decimals = (if benchCase == "large": 0 else: 1), pattern = "{x}×")
    .colsLabel({"ms": "time (ms)", "speedup": "vs Python loops"})

proc benchMachineInfo*(): string =
  ## where the numbers come from: Python, NumPy, Nim, the CPU and the date (machine.txt)
  var info: Table[string, string]
  for line in benchMachine.strip.splitLines:
    let kv = line.split(": ", 1)
    info[kv[0]] = kv[1]
  &"{info[\"python\"]}, {info[\"nim\"]}, {info[\"cpu\"]}, {info[\"date\"]}"

template vandermondeSlide* =
  slide: # 2.2
    nbText "## Reads like Python, runs like C"
    nbDiv("perf-intro", ""):
      nbText "The Vandermonde matrix: row $i$ is $1, x_i, x_i^2, \\dots, x_i^{n-1}$"
    nbDiv("perf-cols", ""):
      nbShowCode(vanderPyCode, lang = "python")
      nbShowCode vanderNimCode
    nbTable benchTable().slideLook(fontSize = "0.5em").highlightRows(where(it["impl"] == "Nim loops"))
    nbTextSmall """
*No ceiling*: when you need it, go down to SIMD, threads,
GPUs and assembly.
"""
    reference &"""
Best of 100 runs: {benchMachineInfo()}.
🐋 [Benchmark code and details](deepdive/vandermonde.html)
"""
    speakerNote """
(Very little time here.) The main value proposition:
it is performant, it runs like C.
When you write a lot of Python you get scared of
for loops, and you think you need a library for
everything. You do not: for loops are easy to
understand, and in C they are cheap.

The Vandermonde matrix: row i holds the powers of x[i].
A classic example for the two-language problem.
Both sides are plain for loops, and look almost the same.
In Python loops are slow, so you are told not to write them:
you call NumPy, whose loop is written in C.
In Nim you are allowed to write for loops:
the loop is compiled, and it runs as fast as NumPy's C loop.
No ceiling: Nim compiles to C, so you can go as low as you want,
SIMD intrinsics, threads, GPU kernels, inline assembly.
Mamy's talk, in this same session, shows how far that goes.

In the words of people like Mamy, who talks after me,
Nim is one of the languages where you can push
performance the furthest, even more than Rust,
which is focused on safety, not only performance.
"""

template island1PerformanceSection* =
  slide:
    mapSlide(1) # 2.1
    vandermondeSlide # 2.2

when isMainModule: # this part of the deck on its own: docs/slides_island1.html
  buildDeckPart("island1", "slides/island1_performance.nim"):
    island1PerformanceSection
