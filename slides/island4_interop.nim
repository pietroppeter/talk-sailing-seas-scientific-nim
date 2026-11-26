import std / strutils
import nimib, nimiSlides
import ../my, island4_bessel
export island4_bessel

# Section 5: Island 4: Interoperability (see outline.md)
# Two messages: a small ecosystem that reaches the bigger ones (C, C++, JavaScript natively;
# Python, R, Julia through bridges), and Nim as the language for the fast algorithm that other
# languages use (nimlang-pypi, naffprop). Carries K2 (interop superpower) and K3.
# The details are in the deep dive, deepdive/interoperability.nim.

proc besselCode: string =
  ## the importc line of island4_bessel.nim, shown on slide 5.2 (without the export marker)
  const source = staticRead("island4_bessel.nim")
  source.strip.splitLines[^1].replace("j0*", "j0")

template nativeSlide* =
  slide: # 5.2
    nbText "## Small ecosystem, big neighbours"
    nbText """
**Natively**: C, C++, JavaScript,
with `importc`, `importcpp`, `importjs`
"""
    nbShowCode besselCode()
    nbCode:
      echo j0(1.0) # the Bessel function J0, from C
    nbText """
**Through bridges**: Python, R, Julia (next slide)
"""
    nbTextSmall """
🐋 [Interoperability, the deep dive](deepdive/interoperability.html)
"""
    speakerNote """
The ecosystem is not big, but you do not need much
ecosystem, because interoperability is very strong.
Nim compiles to C, C++ and JavaScript, so it can use a
library in any of those languages, or produce a library
for any of them.

Nim's own ecosystem is small, and that matters less than it looks.
Nim compiles to C, C++ and JavaScript, so their libraries
are one pragma away: here the Bessel function from C's math library,
called when the slide was built (J0 of 1).
Python, R and Julia have their own runtime: bridges embed it
or load Nim from it (next slide).
"""

template bridgesSlide* =
  slide: # 5.3
    nbText "## Bridges: Nim calls Python, R, Julia"
    nbTextSmall """
Each bridge embeds the other runtime, and its functions
are called like Nim procs:
"""
    compactColumns:
      column:
        nbText "**Python** · [nimpy](https://github.com/yglukhov/nimpy)"
        nbShowCode """
import nimpy

let np = pyImport "numpy"
let m = np.mean([1, 2, 3])
echo m.to(float)  # 2.0
"""
      column:
        nbText "**R** · [rnim](https://github.com/SciNim/rnim)"
        nbShowCode """
import rnim

let R = setupR()
let s = R.sum(@[1, 2, 3])
echo s.to(int)  # 6
"""
      column:
        nbText "**Julia** · [nimjl](https://github.com/SciNim/nimjl)"
        nbShowCode """
import nimjl

Julia.init()
let r = Julia.sqrt(4.0)
echo r.to(float)  # 2.0
"""
    nbTextSmall """
nimpy is the most stable. rnim (by Vindaar) and nimjl (by Clonkk)
are less stable and robust. Each needs its runtime installed.
"""
    speakerNote """
And you can reach the Python, R and Julia ecosystems.
(We have the creator and maintainer of the Nim-Julia
bridge in the room.) nimpy is very stable; rnim was
created and is maintained by Sebastian (Vindaar),
nimjl by Clonkk; those two are less stable and robust.

Three micro examples, from each library's README (shown, not run:
the build would need numpy, R and Julia).
nimpy imports a Python module and calls it with Nim values;
rnim starts an embedded R and calls its functions by name;
nimjl starts the Julia VM and does the same.
Conversions back to Nim are explicit with `to`.
Maturity differs: nimpy is the one to rely on.
"""

template nimInsideSlide* =
  slide: # 5.4
    nbText "## Bridges, the other way: Nim inside"
    nbTextSmall """
Nim compiled as a library (`nim c --app:lib`),
called from the other language:
"""
    compactColumns:
      column:
        nbText "**Python** · nimpy"
        nbShowCode """
import nimpy
proc add(x, y: int): int
    {.exportpy.} = x + y
"""
        nbShowCode("""
from add import add
add(1, 2)  # 3
""", lang = "python")
      column:
        nbText "**R** · rnim"
        nbShowCode """
import rnim
proc add(x, y: SEXP): SEXP
    {.exportR.} =
  nimToR(x.to(int) +
         y.to(int))
"""
        nbShowCode("""
source("add.R") # by rnim
add(1, 2)  # 3
""", lang = "r")
      column:
        nbText "**Julia** · C ABI"
        nbShowCode """
proc add(x, y: cint): cint
    {.exportc, dynlib.} =
  x + y
"""
        nbShowCode("""
ccall((:add, "./libadd.so"),
  Cint, (Cint, Cint), 1, 2)
""", lang = "julia")
    speakerNote """
Bridges work both ways: you can call Nim from Python,
R and Julia. This matters: Nim can compete with Rust
as the performant language behind Python libraries.

The other direction: the Nim code is the library.
nimpy's exportpy makes a Python extension module (next slide: how to build
and ship it without a Nim compiler for users).
rnim's exportR compiles to a shared library and writes the R wrapper to source.
Julia needs no bridge: any Nim proc exported with the C ABI
(exportc, dynlib) is one ccall away; the same works from any language with a C FFI.
"""

template nimlangPypiSlide* =
  slide: # 5.5
    nbText "## 👑 `uv add nimlang` 🐍"
    nbTextSmall """
`nimlang-pypi` (`uv add nimlang`, weeks old, made with AI): the Nim compiler in a Python wheel,
with `zig cc` as the C compiler. Nothing else to install.
`fast.nim` is the Nim twin of `fib` in `slow.py`:
"""
    nbShowCode """
import nimpy

proc fib(n: int): int {.exportpy.} =
  if n < 2: n else: fib(n - 1) + fib(n - 2)
"""
    nbShowCode("""
$ uv add nimlang && uv run nimlang add nimpy
$ uv run nimlang build-ext fast.nim
$ uv run python -m timeit -s "from slow import fib" "fib(30)"
2 loops, best of 5: 95.8 msec per loop
$ uv run python -m timeit -s "from fast import fib" "fib(30)"
20 loops, best of 5: 11.5 msec per loop
""", lang = "sh")
    nbTextSmall """
It also builds the wheels: ship Nim-powered libraries to Python users
with no Nim compiler on their side, as Rust does with maturin.
"""
    speakerNote """
A project I made with AI, weeks old: nimlang-pypi.
Now with `uv add nimlang` you get the Nim compiler, and
you can package and ship Python libraries easily,
without the user even knowing about Nim.

The other direction: Nim as the language where you write the fast part,
and other languages use it. Python people do it with C, Cython, Rust.
For Nim the binding was there (nimpy), the toolchain was the hurdle.
nimlang-pypi is a Python package (mine, alpha) that ships the Nim compiler
and uses zig from PyPI as C compiler: uv add, write the Nim file, build, import.
Eight times faster on a toy that is all function calls.
The session is recorded (24 Nov 2026, Linux), not live.
And the point for library authors: nimlang-pypi builds wheels, for five platforms
from one Linux machine, so Python users pip install a Nim-powered library
without a Nim compiler. That is what Rust has with PyO3 and maturin,
which made Rust the default for fast Python libraries (polars, pydantic-core).
"""

template naffpropSlide* =
  slide: # 5.6
    nbText "## A real package: naffprop"
    columns:
      column:
        nbShowCode("""
import naffprop

ap = naffprop.AffinityPropagation(
  n_clusters=5)  # R's apclusterK
ap.fit(X).labels_
""", lang = "python")
        nbTextSmall """
Affinity propagation clustering:
R's features, scikit-learn's API.
The algorithm in plain Nim, built with `nimlang-pypi`:
`uv add naffprop`, wheels for five platforms,
1.1 to 2.9 times faster than scikit-learn, with less memory.
"""
      column:
        nbFrame("assets/naffprop/index.html", "How exemplars emerge, naffprop's interactive figure")
        nbTextSmall """
🐋 [How exemplars emerge](https://pietroppeter.github.io/naffprop/):
the same Nim, compiled to JavaScript
"""
    speakerNote """
In a past life I used affinity propagation a lot, and
I needed features that scikit-learn did not have, so I
had to wrap the R library. Now I made a library with a
powerful affinity propagation: features from Python,
from R, and from papers I read that add to it. And I can
write explainers that make me understand better how
affinity propagation works: how exemplars emerge.

An example of a real package built this way.
Affinity propagation: points exchange messages until some emerge as exemplars,
no number of clusters fixed beforehand.
R's apcluster has the richer feature set, scikit-learn the familiar API:
naffprop gives both, with the core loop in Nim.
Same exemplars as scikit-learn on the test data, passes check_estimator.
On the right, live: its interactive explanation, the paper's Fig. 1A one iteration
at a time; the same Nim code compiled to JavaScript (press Play).
Also mine, from this year, mostly written with an AI agent (its README says so).
"""

template island4RocksSlide* =
  slide: # 5.7
    nbText "## ⚠️ Rocks ahead 🪨"
    nbText """
- bridges of different maturity: nimpy is solid, rnim and nimjl less so
- packaging Nim for Python had no maintained tool for years; `nimlang-pypi` is new and alpha
- few Python users know Nim: fewer examples and fewer people to ask than with Rust
"""
    speakerNote """
Python is the ecosystem Nim reaches best.
R and Julia bridges exist, built by the same few SciNim people.
nimporter, the previous packaging tool, has had no release since 2022.
nimlang-pypi is my answer to that, but its first release was in October.
And the honest one: Rust plus PyO3 and maturin has the momentum.
"""

template island4InteropSection* =
  slide:
    mapSlide(4) # 5.1
    nativeSlide # 5.2
    bridgesSlide # 5.3
    nimInsideSlide # 5.4
    nimlangPypiSlide # 5.5
    naffpropSlide # 5.6
    island4RocksSlide # 5.7

when isMainModule: # this part of the deck on its own: docs/slides_island4.html
  buildDeckPart("island4", "slides/island4_interop.nim"):
    island4InteropSection
