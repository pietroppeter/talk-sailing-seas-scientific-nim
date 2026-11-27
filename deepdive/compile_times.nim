import std / [strutils, tables, strformat]
import nimib
import tabelline, tabelline / nimib
import deepdive # useDeepDive, and the blocks of blocks.nim

# A nimib document on compile times: Nim, Rust, Go and Zig,
# linked from the tooling row of slide 9.4 (slides/conclusion.nim).
#   nim r deepdive/compile_times.nim
# writes docs/deepdive/compile_times.html.
# The timings are read from bench/compiletimes/results.csv,
# sizes.csv, same.csv and machine.txt, written by
# bench/compiletimes/run.py: every number in a table is measured.

nbInit(thisFileRel = "deepdive/compile_times.nim")
const ownSource = staticRead("compile_times.nim")
nb.useDeepDive("compile_times", ownSource)

const
  benchDir = "../bench/compiletimes/"
  resultsCsv = staticRead(benchDir & "results.csv")
  sizesCsv = staticRead(benchDir & "sizes.csv")
  sameCsv = staticRead(benchDir & "same.csv")
  machineTxt = staticRead(benchDir & "machine.txt")
  historyCsv = staticRead(benchDir & "history.csv")

# --- the logbook: results.csv, the median of each scenario ----------------

var logbook: Table[string, float] # "Nim/mid/debug/clean" -> seconds
for line in resultsCsv.strip.splitLines[1 .. ^1]:
  let f = line.split(',')
  logbook[f[0 .. 3].join("/")] = f[4].parseFloat

proc secs(lang, project, mode, scenario: string): float =
  logbook[[lang, project, mode, scenario].join("/")]

proc s(lang, project, mode, scenario: string): string =
  ## a time for the text: "5.5 s"
  let t = secs(lang, project, mode, scenario)
  (if t < 10: formatFloat(t, ffDecimal, 1) else: $int(t + 0.5)) & " s"

proc times(a, b: (string, string), project, mode, scenario: string): string =
  ## how many times slower b is than a: "2.3×"
  formatFloat(secs(b[0], project, mode, scenario) /
    secs(a[0], project, mode, scenario), ffDecimal, 1) & "×"

var machine: Table[string, string]
for line in machineTxt.strip.splitLines:
  let kv = line.split(": ", 1)
  machine[kv[0]] = kv[1]

const langs = ["Nim", "Nim clang", "Rust", "Go", "Zig"]

func label(lang: string): string =
  if lang == "Nim clang": "Nim (clang)" else: lang

type TimesRow = tuple[lang: string, cleanDebug, cleanRelease,
                      editDebug, editRelease: float]

proc timesRows(project: string): seq[TimesRow] =
  for l in langs:
    result.add (lang: label(l),
      cleanDebug: secs(l, project, "debug", "clean"),
      cleanRelease: secs(l, project, "release", "clean"),
      editDebug: secs(l, project, "debug", "rebuild"),
      editRelease: secs(l, project, "release", "rebuild"))

proc timesTable(project, stubhead: string): Tabella =
  tabella(timesRows(project), rownameCol = "lang"):
    tabStubhead stubhead
    colsLabel {"cleanDebug": "clean debug", "cleanRelease": "clean release",
               "editDebug": "edit debug", "editRelease": "edit release"}
    fmtNumber ["cleanDebug", "cleanRelease", "editDebug", "editRelease"],
      decimals = 1
    tabSourceNote "🔬 Seconds, median of " &
      (if project == "hello": "5" else: "3") & " runs."

let measuredOn = &"""🔬 Measured on {machine["cpu"]}, on {machine["date"]}, with
{machine["nim"]}; {machine["rust"]}; {machine["go"]}; {machine["zig"]}."""

proc kLines(n: int): string =
  ## 65724 -> "66 k"
  $((n + 500) div 1000) & " k"

type SizeRow = tuple[lang, project, own, deps, what: string]
var sizeRows: seq[SizeRow]
for line in sizesCsv.strip.splitLines[1 .. ^1]:
  let f = line.split(',', 4)
  sizeRows.add (lang: f[0], project: f[1], own: kLines(f[2].parseInt),
                deps: kLines(f[3].parseInt), what: f[4])

var sameLines: Table[string, int]
var sameFunctions, sameModules: int
for line in sameCsv.strip.splitLines[1 .. ^1]:
  let f = line.split(',')
  sameLines[f[0]] = f[1].parseInt
  sameModules = f[2].parseInt
  sameFunctions = f[3].parseInt

const
  nim = ("Nim", "")
  clang = ("Nim clang", "")
  rust = ("Rust", "")

# --- the page ----------------------------------------------------------------

nbText """
# Compile times: Nim, Rust, Go and Zig

In the talk [Sailing Seas of Scientific
Nim](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/slides.html),
the slide *Why still niche?* said that Nim's tooling has
"editor support and compile times behind Rust's".
Right after the talk the second half sounded wrong:
Nim has a reputation for compiling fast, Rust for
compiling slowly. So we set out to write the correction.

Then we measured, and the numbers corrected the correction.
"""

nbNote &"""
**In short.** In the loop of daily work (debug builds),
Rust compiled faster than Nim with its default C compiler, gcc,
in every scenario we tried: from scratch and after an edit.
With clang as its C compiler, Nim catches up on builds from
scratch ({s("Nim clang", "same", "debug", "clean")} against
{s("Rust", "same", "debug", "clean")} on the same program).
Where Nim wins is the optimised build after an edit
in a program made of one crate:
it recompiles only the C of the modules that changed,
while Rust and Zig optimise the whole crate again
({s("Nim", "same", "release", "rebuild")} against
{s("Rust", "same", "release", "rebuild")} and
{s("Zig", "same", "release", "rebuild")}).
Go is the fastest all round.
Nim's weak spot is a big project: it reads the whole program
again on every build, because it has no incremental
compilation yet. So the slide was not wrong; it was vague.
"""

nbText """
Every number on this page carries its flag:

- 🔬 **measured**: timed by
  [bench/compiletimes/run.py](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim/tree/main/bench/compiletimes),
  read from its `results.csv` when the page is built;
  all the tables are measured;
- 📚 **cited**: from a source linked next to it;
- 🧭 **estimated**: our own reckoning, said as such.
"""

nbText """
## The fleet

Four compiled languages, four ways to reach machine code:

- **Nim** compiles to C (or C++, or JavaScript), then a C
  compiler (gcc by default on Linux, clang on macOS) turns
  the C into machine code. The Nim part reads the whole program
  every time, on one thread; the C part is cached file by file
  in the `nimcache` folder, so only the C files that changed are
  compiled again, in parallel.
  The standard library is compiled with your program.
- **Rust** compiles each crate (a package) through LLVM.
  The standard library comes precompiled; the crates you
  depend on are compiled once per project and cached in
  `target/`, many at a time. Debug builds are incremental:
  after an edit, rustc reuses what it can of its previous work.
  Release builds of a crate start over.
- **Go** has its own compiler and linker, with no LLVM.
  It compiles package by package and caches each one
  (in `GOCACHE`), standard library included.
  It has no debug or release mode: `go build` always
  optimises a little. For debugging,
  `-gcflags=all="-N -l"` turns that off,
  and that is our "debug".
- **Zig** has its own x86-64 backend for debug builds
  (the default on Linux since 0.15) and uses LLVM
  for the release modes. It compiles the program with the
  parts of the standard library it uses, as one unit,
  and only what is reachable from `main`.
"""

nbText &"""
## The course

Three projects for each language:

1. **Hello, sailor**: a hello world.
2. **The same program**, generated in the four languages by
   [gen.py](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim/blob/main/bench/compiletimes/gen.py):
   {sameModules} modules of {sameFunctions div sameModules}
   small functions (a loop of integer arithmetic each),
   and a main that calls them all and prints the same checksum
   in all four. About {kLines(sameLines["nim"])} lines in Nim and
   {kLines(sameLines["rust"])} in Rust, with no dependencies.
   It is the one like-for-like comparison, and the code is
   simpler than real code (no generics, no macros).
3. **A real program** of each language, with its dependencies:
"""
let sizesTable = tabella(sizeRows, rownameCol = "lang"):
  tabStubhead ""
  colsLabel {"project": "program", "own": "its lines",
             "deps": "dependencies' lines", "what": "dependencies"}
  colsAlign alRight, ["own", "deps"]
  tabSourceNote "🔬 Lines of source in the files compiled, comments and blank lines included."
nbTable sizesTable

nbText """
They are not the same program, nor the same size:
each is a well known program of its language that builds
without fuss. The Nim compiler is the biggest of the four
in its own code. ripgrep is small, on top of many crates;
the count of their lines is inflated by code that is not
compiled on Linux (libc has every platform) and by data tables
(encoding_rs, the Unicode tables of the regex crates).
fzf leans on the Go standard library; translate-c is the part
of the Zig toolchain that turns C headers into Zig,
with aro, a C compiler written in Zig, as its library.

Four builds each:

- **clean**: no cache of the project (the toolchain is
  installed and warm), as on the first build, in CI,
  or after `cargo clean`;
- **edit**: change one string literal in one source file
  of the program, and build again: the loop of a programmer
  at work;
- each in **debug** (fast to compile, slower to run)
  and **release** mode (optimised): `nim c` and
  `nim c -d:release`, `cargo build` and
  `cargo build --release`, `go build` with and without
  `-N -l`, Zig's Debug and ReleaseFast.

Nim runs twice: with gcc, its default C compiler on Linux,
and with clang (`--cc:clang`).
"""

nbText "## The logbook"
nbText measuredOn

nbText "### The same program"
nbTable timesTable("same", "same program")

nbText &"""
On the like-for-like program, Rust's debug build from scratch
is faster than Nim with gcc
({times(rust, nim, "same", "debug", "clean")}), and Nim with clang
is a little faster than Rust. In release mode, Rust is
{times(rust, nim, "same", "release", "clean")} faster than Nim
with gcc, and clang again closes most of the gap.

The edit is where the designs show.
In debug mode Rust's incremental compilation redoes little,
and wins ({s("Rust", "same", "debug", "rebuild")} against
{s("Nim", "same", "debug", "rebuild")}).
In release mode Rust optimises the whole crate again,
and takes as long as from scratch, while Nim compiles
only the C file of the one module that changed:
{s("Nim", "same", "release", "rebuild")}, against
{s("Rust", "same", "release", "rebuild")}.
A release build after an edit is the one scenario where
Nim is the fastest of the four after Go.

Go is fast everywhere. Zig's own backend is the fastest
in debug mode, and its LLVM release build is the slowest
of all: the whole program is one unit, optimised on one
thread, again after every edit.
"""

nbText "### A real program"
nbTable timesTable("mid", "real program")

nbText &"""
On the real programs Nim takes the longest in debug mode:
{s("Nim", "mid", "debug", "clean")} from scratch
for its own compiler, and {s("Nim", "mid", "debug", "rebuild")}
after an edit, against {s("Rust", "mid", "debug", "clean")}
and {s("Rust", "mid", "debug", "rebuild")} for ripgrep.
The Nim compiler is the biggest of the four own codes,
so part of this is size. In release mode Rust wins the edit
too ({s("Rust", "mid", "release", "rebuild")} against
{s("Nim", "mid", "release", "rebuild")}): ripgrep is split into
many crates, and only its small main crate is optimised again.
Look at the build with nothing changed at all:
"""

type NoChangeRow = tuple[lang: string, debug, release: float]
var noChange: seq[NoChangeRow]
for l in langs:
  noChange.add (lang: label(l), debug: secs(l, "mid", "debug", "nochange"),
                release: secs(l, "mid", "release", "nochange"))
let noChangeTable = tabella(noChange, rownameCol = "lang"):
  tabStubhead "nothing changed"
  fmtNumber ["debug", "release"], decimals = 2
  tabSourceNote "🔬 Seconds, median of 3 runs: build again with no edit."
nbTable noChangeTable

nbText &"""
The others check their caches and stop in a blink.
Nim reads, checks and generates the whole program again
({s("Nim", "mid", "debug", "nochange")} for the compiler),
then sees that no C file changed. That is the cost of having
no incremental compilation: a fixed toll on every build,
which grows with the size of the program.
In a small project it is a second; in a big one,
the edit-compile loop is slower than Rust's.
"""

nbText "### Hello, sailor"
nbTable timesTable("hello", "hello world")

nbText """
Everyone is quick, and Rust has the head start:
its standard library comes precompiled, so there is little
left to compile. Nim compiles the bits of its standard library
it needs to C, then the C. Go's clean build compiles the parts
of its standard library it uses into an empty cache, and that
is most of its time; once cached, it is instant.
Zig in release mode hands its standard library to LLVM every
time, and takes 15 seconds to say hello.
"""

# --- history.csv: older toolchains on the same program -------------------

var history: Table[string, float] # "Rust 1.24.0/debug/clean" -> seconds
var toolchains: seq[string]
for line in historyCsv.strip.splitLines[1 .. ^1]:
  let f = line.split(',')
  history[[f[0], f[2], f[3]].join("/")] = f[4].parseFloat
  if f[0] notin toolchains: toolchains.add f[0]

proc h(toolchain, mode, scenario: string): string =
  formatFloat(history[[toolchain, mode, scenario].join("/")], ffDecimal, 1) & " s"

const released = {"Rust 1.24.0": "Feb 2018", "Rust 1.40.0": "Dec 2019",
  "Rust 1.60.0": "Apr 2022", "Rust 1.97.0": "Jul 2026",
  "Nim 1.6.14": "2023", "Nim 2.2.4": "Apr 2025"}.toTable

type HistoryRow = tuple[toolchain, released: string, cleanDebug, cleanRelease,
                        editDebug, editRelease: float]
var historyRows: seq[HistoryRow]
for t in toolchains:
  historyRows.add (toolchain: t, released: released.getOrDefault(t, ""),
    cleanDebug: history[t & "/debug/clean"], cleanRelease: history[t & "/release/clean"],
    editDebug: history[t & "/debug/rebuild"], editRelease: history[t & "/release/rebuild"])

nbText """
## Where the reputation comes from

So why does everyone "know" that Nim compiles fast
and Rust slowly? Three reasons, and one thing
that is not a reason.

**Nim says so, and it is true of Nim itself.**
📚 The [release candidate of Nim 2.0](https://nim-lang.org/blog/2022/12/21/version-20-rc.html)
(December 2022) lists among Nim's features: "Fast compile
times: a full compiler rebuild takes ~12s (Rust: 15min,
gcc: 30min+, clang: 1hr+, Go: 90s)", on an 8-core 2019
Intel Mac. The same page boasts small binaries:
"echo "hello world" generates a 67K binary
(Go: 2MB, Rust: 377K, C++: 56K)".
Both are fair measurements, but the first compares
compilers, not languages: rustc is a far bigger program
than the Nim compiler, with LLVM behind it.
A small compiler written in a language that compiles
through C builds fast: 🔬 here the Nim compiler builds
in 23 s (debug) on 4 slower cores.

**Rust really was slow.**
The complaints are from the years around Rust 1.0 (2015):
incremental compilation was only switched on by default
in 📚 [Rust 1.24](https://blog.rust-lang.org/2018/02/15/Rust-1.24/)
(February 2018). Since then the Rust project has measured
and shaved its compiler year after year. 📚 Nicholas Nethercote,
who wrote a long series of posts on it, counted compile times
on real code going down by
[10 to 40%, and up to 58%, from August 2020 to November 2021](https://nnethercote.github.io/2021/11/12/the-rust-compiler-has-gotten-faster-again.html),
and a [37% reduction from 2020 to 2024](https://nnethercote.github.io/2024/03/06/how-to-speed-up-the-rust-compiler-in-march-2024.html).
We could check that here: rustup still installs old Rust
releases, and the Ubuntu package has Nim 1.6.
The same generated program, the same machine:
"""

let historyTable = tabella(historyRows, rownameCol = "toolchain"):
  tabStubhead "same program"
  colsLabel {"released": "released", "cleanDebug": "clean debug",
             "cleanRelease": "clean release", "editDebug": "edit debug",
             "editRelease": "edit release"}
  fmtNumber ["cleanDebug", "cleanRelease", "editDebug", "editRelease"], decimals = 1
  tabSourceNote "🔬 Seconds, median of 3 runs (bench/compiletimes/history.py). Nim 1.6.14 is the Ubuntu 24.04 package, with gcc."
nbTable historyTable

nbText &"""
🔬 In debug mode Rust is about four times faster than in 2018:
{h("Rust 1.24.0", "debug", "clean")} then, {h("Rust 1.97.0", "debug", "clean")}
now from scratch, {h("Rust 1.24.0", "debug", "rebuild")} then,
{h("Rust 1.97.0", "debug", "rebuild")} now after an edit.
The release build has not moved much: that time is spent
in LLVM, optimising, and Rust 1.40 was even slower.
A Nim user who compared the two in 2018 had good reasons
to call Rust slow; the comparison has aged.

**Nim did not get slower.** 🔬 Nim 2.2 compiles the program
as fast as Nim 1.6 in debug mode, and twice as fast in
release mode ({h("Nim 1.6.14", "release", "clean")} against
{h("Nim 2.2.4", "release", "clean")}). Nim 2 changed the default
memory management (ORC instead of the old garbage collector),
which changes the C that Nim writes, so this is not only the
compiler getting faster. Either way, the reputation did not
change because Nim slowed down: Rust caught up.

**Rust projects are big.** 🧭 The third reason is the
way people use the two languages. A Rust program stands on
crates: ripgrep, a small program of 14 k lines, builds
43 crates, some with procedural macros (`serde`'s derive
needs the `syn` parser), and web services build hundreds.
Cargo compiles all of them on the first build, in CI, after
a toolchain update, and that is the wait people remember.
A Nim program usually has few dependencies and compiles its
standard library from source in seconds. On the same program,
as we saw above, they are in the same league; on the projects
people actually write, Rust has more to compile.
"""

nbText """
## What the others say

📚 Cited, to put our numbers in context:

- **Rust**: compile times are the best known complaint
  about Rust. The Rust project ran its first
  [compiler performance survey](https://blog.rust-lang.org/2025/09/10/rust-compiler-performance-survey-2025-results/)
  in 2025: waiting for the rebuild after a small change
  was the most common complaint, and long compile times
  were among the reasons given by people who stopped
  using Rust. The project keeps working on it (a parallel
  front-end, the Cranelift backend for debug builds,
  faster linkers), and our numbers show the incremental
  debug rebuild is already good.
- **Go**: in [Go at Google](https://go.dev/talks/2012/splash.article)
  (2012), Rob Pike explains how Go handles dependencies,
  "the single biggest reason why Go compilations are faster
  than C or C++ compilations". The build is designed to be fast.
- **Zig**: the
  [0.15.1 release notes](https://ziglang.org/download/0.15.1/release-notes.html)
  report debug compilation 5 times faster with its own x86
  backend, now the default. Zig also works on incremental
  compilation (`-fincremental` with `--watch`), which
  recompiles only the functions that changed:
  we did not time it.
- **Nim**: the classic compiler has an experimental
  [incremental compilation](https://nim-lang.github.io/Nim/ic.html)
  mode, not ready for daily use. Nimony, the next compiler,
  is built around NIF, a format in which every stage of the
  compiler writes its result to disk, so that a rebuild
  only redoes the modules that changed.
  That is the toll of the table above, and the slide was
  right that Nimony and NIF are the way to remove it.
"""

nbText """
## Rocks under the surface

So that nobody runs aground on these numbers:

- **One machine.** A cloud machine with 4 cores,
  shared with others: a recent laptop is faster,
  and the noise is a few tenths of a second.
  🧭 The ratios between languages should hold better than
  the seconds, but we only measured here.
- **Different programs.** The real programs do different
  things in different amounts of code; the generated program
  is the same everywhere, but simpler than real code.
  Neither is a controlled experiment of the languages:
  together they are a fair picture of the toolchains.
- **Different caches.** "Clean" removes the cache of the
  project, not of the toolchain: Rust's precompiled standard
  library stays, and so does Zig's compiled runtime in its
  global cache. The very first Zig build on a machine takes
  longer (🔬 about a minute and a half more for translate-c,
  once).
- **Defaults, mostly.** Rust can use the Cranelift backend,
  the mold linker or sccache; Nim can use tcc for the fastest
  debug builds; Zig's incremental mode is there to try.
  We changed one knob, Nim's C compiler, because it changes
  the picture: clang was clearly faster than gcc here.
- **Compile time is not run time.** Release builds take
  longer because they optimise more; that is the deal.
"""

nbText """
## Back to the slide

The tooling row of *Why still niche?* now reads:
"editor support behind Rust's, compile times close but not
incremental yet; Nimony and NIF to catch up", with a whale
that brings you here. What the talk said was not false,
but it hid the interesting part: from scratch Nim is in
Rust's league (with clang), after an edit it is slower in
debug, faster in release when Rust has to optimise a big
crate again, and the gap is the incremental compilation
that Nimony is built for.
"""

nbText """
## Run it yourself

The benchmark is in
[bench/compiletimes](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim/tree/main/bench/compiletimes)
in the talk's repository. With Nim, gcc, clang, Rust (cargo),
Go and Zig installed, and a connection the first time
(it downloads ripgrep from crates.io and fzf from the Go
module proxy, and takes the Nim compiler and translate-c
from the installed Nim and Zig):

```
python3 bench/compiletimes/run.py
```

runs every build (about an hour on 4 cores) and writes
`results.csv`, `sizes.csv`, `same.csv` and `machine.txt`,
which this page reads when it is built.
`run.py same` runs one project, `run.py Rust` one language.
`history.py` times the older toolchains of the table in
*Where the reputation comes from* (Rust 1.24, 1.40 and 1.60
from rustup, Nim 1.6 from the Ubuntu package) and writes
`history.csv`.
"""
nbSave
