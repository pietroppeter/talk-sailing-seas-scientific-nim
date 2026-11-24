import std / strutils
import nimib, nimiSlides
import ../my, island4_bessel
export island4_bessel

# Section 5: Island 4: Interoperability (see outline.md)
# Two messages: a small ecosystem that reaches the bigger ones (C, C++, JavaScript natively;
# Python, R, Julia through bridges), and Nim as the language for the fast algorithm that other
# languages use (`uv add nimlang`, naffprop). Carries K2 (interop superpower) and K3.
# The details are in the deep dive, deepdive/interoperability.nim.

proc besselCode: string =
  ## the importc line of island4_bessel.nim, shown on slide 5.2 (without the export marker)
  const source = staticRead("island4_bessel.nim")
  source.strip.splitLines[^1].replace("j0*", "j0")

template island4InteropSection* =
  slide:
    mapSlide(4) # 5.1
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
**Through bridges**: Python ([nimpy](https://github.com/yglukhov/nimpy)),
R ([rnim](https://github.com/SciNim/rnim)),
Julia ([nimjl](https://github.com/SciNim/nimjl))
"""
      nbTextSmall """
[Interoperability, the deep dive](deepdive/interoperability.html)
"""
      speakerNote """
Nim's own ecosystem is small, and that matters less than it looks.
Nim compiles to C, C++ and JavaScript, so their libraries
are one pragma away: here the Bessel function from C's math library,
called when the slide was built (J0 of 1).
Python, R and Julia have their own runtime: bridges embed it
or load Nim from it. nimpy for Python is mature and works both ways,
rnim and nimjl are younger (rocks ahead).
"""
    slide: # 5.3
      nbText "## Write it in Nim, use it from Python"
      nbTextSmall """
`uv add nimlang`: the Nim compiler in a Python wheel,
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
      speakerNote """
The other direction: Nim as the language where you write the fast part,
and other languages use it. Python people do it with C, Cython, Rust.
For Nim the binding was there (nimpy), the toolchain was the hurdle.
nimlang is a Python package (mine, alpha) that ships the Nim compiler
and uses zig from PyPI as C compiler: uv add, write the Nim file, build, import.
Eight times faster on a toy that is all function calls.
The session is recorded (24 Nov 2026, Linux), not live.
It also builds wheels for five platforms from one Linux machine.
"""
    slide: # 5.4
      nbText "## A real package: naffprop"
      nbShowCode("""
from naffprop import AffinityPropagation

ap = AffinityPropagation().fit(X)             # drop-in for sklearn's
AffinityPropagation(n_clusters=5)             # exactly 5: R's apclusterK
AffinityPropagation(preference_quantile=0.1)  # fewer clusters: R's q
""", lang = "python")
      nbText """
- affinity propagation: R's features, scikit-learn's API
- the algorithm in plain Nim, built with nimlang
- `uv add naffprop`: wheels for five platforms
- 1.1 to 2.9 times faster than scikit-learn, less memory
"""
      speakerNote """
An example of a real package built this way.
Affinity propagation: points exchange messages until some emerge as exemplars,
no number of clusters fixed beforehand.
R's apcluster has the richer feature set, scikit-learn the familiar API:
naffprop gives both, with the core loop in Nim.
Same exemplars as scikit-learn on the test data, passes check_estimator.
Also mine, from this year, mostly written with an AI agent (its README says so).
"""
    slide: # 5.5
      nbText "## Rocks ahead"
      nbText """
- bridges of different maturity: nimpy is solid, rnim a prototype, nimjl needs Julia installed
- packaging Nim for Python had no maintained tool for years; nimlang is new and alpha
- few Python users know Nim: fewer examples and fewer people to ask than with Rust
"""
      speakerNote """
Python is the ecosystem Nim reaches best.
R and Julia bridges exist, built by the same few SciNim people.
nimporter, the previous packaging tool, has had no release since 2022.
nimlang is my answer to that, but its first release was in October.
And the honest one: Rust plus PyO3 and maturin has the momentum.
"""
