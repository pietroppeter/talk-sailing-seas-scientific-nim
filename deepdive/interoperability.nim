import nimib
import deepdive # useDeepDive, and the blocks of blocks.nim

# A nimib document that goes deeper into Island 4, Interoperability
# (section 5, in slides/island4_interop.nim):
#   nim r deepdive/interoperability.nim
# writes docs/deepdive/interoperability.html.
# The C code below runs when the page is built; the Python sessions are
# recorded (uv and a Python project are not part of the build).

nbInit(thisFileRel = "deepdive/interoperability.nim")
const ownSource = staticRead("interoperability.nim")
nb.useDeepDive("interoperability", ownSource)

nbText """
# Interoperability: Nim with other languages

In the talk [Sailing Seas of Scientific
Nim](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/slides.html),
Island 4 makes two points:

1. Nim's ecosystem is small, and that is less of a problem
   than it looks: Nim reaches the bigger ecosystems,
   C, C++ and JavaScript natively,
   Python, R and Julia through bridges.
2. Nim can be the language where you write the fast
   algorithm, and other languages use it:
   `uv add nimlang` puts Nim inside a Python project,
   and naffprop is a Python package written that way.

This page goes through both, with the code and the
honest state of each bridge.
"""

nbText """
## A small ecosystem, open to bigger ones

A scientist who looks at a new language asks first
whether the libraries they need are there.
For Nim the answer is often "not in Nim", and often
it does not matter: Nim compiles to C, C++ or
JavaScript, so it can call their libraries directly,
with no wrapper layer at run time.
For Python, R and Julia there are bridges:
libraries that embed the other runtime, or let it
load a library written in Nim.
"""

nbText """
## C: one pragma away

A C function is declared in Nim with its signature and
the `importc` pragma; `header` tells the compiler which
C header declares it.
The [Bessel function](https://en.wikipedia.org/wiki/Bessel_function)
`j0` is in the C math library and not in Nim's
standard library.
Bessel functions are the solutions of a differential
equation that shows up wherever something vibrates or
spreads in a circle or a cylinder: a drum skin, heat in
a pipe, light through a round aperture.
`j0` is the first of them, J₀, a wave that slowly dies
out; its zeros set the circles that stay still on a
vibrating drum skin:
"""
nbCode:
  proc j0(x: cdouble): cdouble {.importc, header: "<math.h>".}

  echo j0(0.0)
  echo j0(2.404825557695773) # the first zero of J0
nbText """
That is the whole binding: Nim emits a call to `j0`
in the C it generates, and the C compiler does the rest.
Types (`cdouble`, `cint`, `cstring`, `ptr`) map one to
one, and C structs become Nim `object`s with the same
pragma.
For a library with many functions there are tools that
write the declarations:
[c2nim](https://github.com/nim-lang/c2nim) translates
C headers into Nim source once, and
[Futhark](https://github.com/PMunch/futhark) by PMunch
reads the headers with libclang when you compile, so
the binding follows the library's version.
Many Nim libraries are thin layers over a C library
this way: BLAS and LAPACK under Arraymancer, cairo
under ggplotnim (Island 3).
"""

nbText """
## C++: same idea, with templates

With `nim cpp` Nim generates C++, and `importcpp`
maps C++ classes, methods and templates
(this block is shown, not run: the page is built with
the C backend):
"""
nbShowCode """
type
  StdVector[T] {.importcpp: "std::vector", header: "<vector>".} = object

proc pushBack[T](v: var StdVector[T], x: T) {.importcpp: "#.push_back(@)".}
proc size(v: StdVector): csize_t {.importcpp: "#.size()".}

var v: StdVector[cdouble]
v.pushBack(1.5)
v.pushBack(2.5)
echo v.size  # 2
""", caption = "a C++ `std::vector` used from Nim, compiled with `nim cpp`"
nbText """
For readers new to C++: `std::vector` is the C++
standard library's growable array, the equivalent of
Nim's `seq` or a Python list.
`push_back` is its method that appends an element at
the end (Python's `append`, Nim's `add`), and `size`
returns how many elements it holds.
In the `importcpp` pattern, `#` is the object the method
is called on and `@` the remaining arguments, so
`v.pushBack(1.5)` becomes `v.push_back(1.5)` in the C++
that Nim generates: one line per method is enough.
To read more: [std::vector on
cppreference](https://en.cppreference.com/w/cpp/container/vector)
and the [importcpp
pragma](https://nim-lang.org/docs/manual.html#implementation-specific-pragmas-importcpp-pragma)
in the Nim manual.
"""

nbText """
## JavaScript: the third backend

`nim js` compiles Nim to JavaScript, and `importjs`
binds any JavaScript function or object the same way.
Island 6 shows a whole app compiled to JavaScript,
and the last slide of the talk is an animation written
in Nim with [p5nim](https://github.com/pietroppeter/p5nim),
a binding to p5.js
([how it works](thank_you_sketch.html)).
"""

nbText """
## Bridges to Python, R and Julia

These languages have their own runtime, so a bridge
either embeds it in a Nim program or builds a Nim
library that the runtime loads.
Their maturity differs a lot:

| language | bridge | what it does | state |
|---|---|---|---|
| Python | [nimpy](https://github.com/yglukhov/nimpy) by Yuriy Glukhov | both ways: Nim calls Python modules, Python imports Nim modules | mature, the most used |
| R | [rnim](https://github.com/SciNim/rnim) by Vindaar | both ways: an embedded R from Nim, Nim shared libraries from R | a prototype, in its own words "barely working" |
| Julia | [nimjl](https://github.com/SciNim/nimjl) by Clonkk | embeds Julia in Nim, to call Julia functions on Nim data | works, needs a Julia install |

With nimpy, calling Python from Nim reads like Python:
"""
nbShowCode """
import nimpy

let np = pyImport("numpy")
let a = np.linspace(0, 1, 5)
echo a.sum().to(float)  # 2.5
""", caption = "Nim calling numpy through nimpy"
nbText """
and the other way, a Nim procedure with the `exportpy`
pragma becomes a function of a Python extension
module, the subject of the next section.
[nimpy_numpy](https://github.com/pietroppeter/nimpy-numpy)
passes numpy arrays to Nim without copies.
"""

nbText """
## Nim inside Python: `uv add nimlang`

The second point of the island is the other direction:
write the slow part of a Python project in Nim.
Python people already do this with C, Cython or Rust;
for Rust, [maturin](https://www.maturin.rs/) and PyO3
made it a two-command affair.
For Nim the binding was there (nimpy), what was
missing was the toolchain: a Python user had to install
Nim and a C compiler, and the packaging tool,
[nimporter](https://github.com/Pebaz/nimporter),
has had no release since 2022.

[nimlang-pypi](https://github.com/pietroppeter/uv-add-nimlang)
(on PyPI as [nimlang](https://pypi.org/project/nimlang/),
the name you install for now) is a
Python package that ships the Nim compiler in its
wheels and compiles the C through `zig cc`, from the
[ziglang](https://pypi.org/project/ziglang/) package:
with uv you need nothing else.
Nim dependencies are declared in `pyproject.toml`
next to the Python ones, and pinned in a lock file.

This is the session from its README, run in a cloud
container (Linux x86_64, Python 3.13) on 24 November
2026, with nimlang-pypi 0.0.3 and its Nim 2.2.6.
A project and its Nim dependency:
"""
nbShowCode """
$ uv init uv-add-nimlang-demo && cd uv-add-nimlang-demo
$ uv add nimlang
 + nimlang==0.0.3
 + tomlkit==0.15.3
 + ziglang==0.17.1
$ uv run nimlang add nimpy
nimlang: locked 1 Nim package(s) in nimlang.lock
$ uv run nimlang info
        nim: 2.2.6 at .venv/lib/python3.13/site-packages/nimlang/nim
   nim deps: nimpy
""", lang = "sh", caption = "output shortened"
nbText """
A slow function in Python, `slow.py`:
"""
nbShowCode """
def fib(n):
    return n if n < 2 else fib(n - 1) + fib(n - 2)
""", lang = "python"
nbText """
the same function in Nim, `fast.nim`, exported to
Python by nimpy's `exportpy`:
"""
nbShowCode """
import nimpy

proc fib(n: int): int {.exportpy.} =
  if n < 2: n else: fib(n - 1) + fib(n - 2)
"""
nbText """
Build the extension module and time both:
"""
nbShowCode """
$ uv run nimlang build-ext fast.nim
nimlang: built fast.cpython-313-x86_64-linux-gnu.so
$ uv run python -m timeit -s "from slow import fib" "fib(30)"
2 loops, best of 5: 95.8 msec per loop
$ uv run python -m timeit -s "from fast import fib" "fib(30)"
20 loops, best of 5: 11.5 msec per loop
""", lang = "sh"
nbText """
About eight times faster, for a toy function that is
all function calls; the point is less the number than
how little stood between a Python project and Nim.
The first build compiles nimpy too and takes about
twenty seconds; later builds are faster.

To ship Nim code to Python users, nimlang-pypi is also a
build requirement with a hatch hook: `uv build` makes
one wheel per platform that works on every CPython 3,
and cross-compiles the other platforms from Linux.
Users of the package get prebuilt wheels and need
neither nimlang-pypi nor a compiler:
"""
nbShowCode """
[build-system]
requires = ["hatchling", "nimlang"]
build-backend = "hatchling.build"

[tool.hatch.build.hooks.nimlang]
extensions = ["src/mypkg/fast.nim"]  # importable as mypkg.fast

[tool.nimlang]
dependencies = ["nimpy"]
""", lang = "toml", caption = "the `pyproject.toml` of a package with a Nim extension"
nbText """
## Compared with Rust

Rust is where the Python ecosystem goes today for a
fast library, and the comparison is not flattering
for Nim.
[PyO3](https://pyo3.rs) binds Rust and Python,
[maturin](https://www.maturin.rs/) builds and publishes
the wheels, and widely used packages ship that way,
like [polars](https://pola.rs/),
pydantic-core (the core of pydantic) and orjson:
the path is tested every day by many projects and
many users.

| | Rust | Nim |
|---|---|---|
| binding | PyO3 | nimpy, stable for years |
| build and ship wheels | maturin | nimporter (no release since 2022), now nimlang-pypi (alpha, 2026) |
| numpy arrays | rust-numpy | nimpy_numpy |
| compiler on the user's side | none, prebuilt wheels | none, prebuilt wheels (with nimlang-pypi) |
| packages built this way | many, some among the most downloaded | a few, like naffprop |
| how tested | by a large ecosystem | by a few projects |

The binding is not the gap: nimpy has been stable for
a long time and makes the Nim side short.
The gap is everything around it: a maintained build
and packaging tool, examples to copy, and enough users
that the corners are found before you find them.
nimlang-pypi closes the first; the others need users.

## Other ways

Other ways to offer Nim code to other languages:
a shared library with `exportc` and `dynlib`, which
any language with a C FFI can load, and
[genny](https://github.com/treeform/genny) by treeform,
which generates bindings with a nice API for Python,
Node.js and C from one Nim library.
"""

nbText """
## An example: naffprop

[naffprop](https://github.com/pietroppeter/naffprop)
(on [PyPI](https://pypi.org/project/naffprop/)) is a
Python package for
[affinity propagation](https://en.wikipedia.org/wiki/Affinity_propagation),
a clustering method by Frey and Dueck (Science, 2007)
in which the points exchange messages until some of
them emerge as exemplars, the centers of the clusters,
without fixing the number of clusters beforehand.
"""

nbText """
### Affinity propagation in brief

Most clustering methods ask first how many clusters you
want (k-means needs k) and then invent centers.
Affinity propagation starts from a similarity between
every pair of points (for example minus their squared
distance) and lets the data choose: every point is a
candidate exemplar, and the points exchange two kinds
of messages until a few candidates win.

- The **responsibility** r(i, k), sent from point i to
  candidate k: how well k would serve as i's exemplar,
  compared with the other candidates for i.
- The **availability** a(i, k), sent back from k to i:
  how much sense it makes for i to pick k, given how
  many other points already back k.

Each round updates both messages (with some damping, so
they do not oscillate); a point is an exemplar when
r(k, k) + a(k, k) > 0, and every other point joins the
exemplar most similar to it.
The number of clusters is not fixed, it follows from
the *preference*, the similarity of each point with
itself: a higher preference makes more exemplars.
The exemplars are real data points, not averages, and
the similarity can be anything you can compute for a
pair, even one that is not a distance.
The price is the n × n matrices: time and memory grow
with the square of the points, so it fits thousands or
tens of thousands of points, not millions.

It is used where a representative example says more
than an average, or where only similarities are
available. The original paper clustered face images
(picking representative faces), found genes in
microarray data, chose a few sentences to summarize a
manuscript, and found cities that are easy to reach by
air; in bioinformatics it clusters protein and gene
sequences from their alignment scores, which is where
R's apcluster comes from.
A playful use is a color palette: cluster the colors
of an image and keep the exemplars.
[appalette](https://claude.ai/artifact/SW4Bqy8xrCmWeMrq22ST8L)
does that in the browser, with a perceptual color
difference (CIEDE2000) as the similarity: you see the
palettes that stay stable as the preference changes,
and keep the colors you like.
The algorithm also runs step by step in naffprop's own
[How exemplars emerge](https://pietroppeter.github.io/naffprop/),
the figure on the naffprop slide.
"""

nbText """
scikit-learn and R both have it, with different
features: R's [apcluster](https://cran.r-project.org/package=apcluster)
has more of them (a preference as a quantile, ask for
exactly k clusters, sparse similarities, leveraged AP
for large data), scikit-learn has the API Python users
know.
naffprop puts R's features behind scikit-learn's API,
with the algorithm written in Nim and built with
nimlang-pypi:
"""
nbShowCode """
from naffprop import AffinityPropagation

ap = AffinityPropagation().fit(X)             # drop-in for sklearn's
ap.labels_, ap.cluster_centers_indices_

AffinityPropagation(preference_quantile=0.1)  # fewer clusters: R's q
AffinityPropagation(n_clusters=5)             # exactly 5: R's apclusterK
AffinityPropagation().fit(X.astype("float32"))  # half the memory
""", lang = "python", caption = "from naffprop's README"
nbText """
What the Nim side looks like, from its README:

- the algorithm is plain Nim (`ap.nim`), on a 20-line
  row-major matrix type: affinity propagation needs
  elementwise updates, row maxima and column sums,
  no linear algebra library;
- `core.nim` exports it with nimpy, and the
  scikit-learn estimator is a thin Python class on top;
- with the same inputs it finds the same exemplars as
  scikit-learn and as a numpy port of the original
  MATLAB code (both are in its tests), and it passes
  scikit-learn's `check_estimator`;
- one Linux CI job cross-compiles the wheels for five
  platforms (Linux x86_64 and aarch64, macOS arm64 and
  x86_64, Windows x86_64).

On its benchmark (blobs, the same similarities and
parameters for both) it has been 1.1 to 2.9 times
faster than scikit-learn and needed a third to three
quarters of its extra memory in float64.
In float32, without a copy of the similarities, it
needs about a quarter of what scikit-learn needs.
A cloud container, with R's defaults:
"""
nbText """
| points | naffprop (s) | scikit-learn (s) | speedup | naffprop (MiB) | scikit-learn (MiB) |
|--:|--:|--:|--:|--:|--:|
| 500 | 0.32 | 0.46 | 1.5x | 6 | 8 |
| 1,000 | 1.72 | 3.72 | 2.2x | 23 | 32 |
| 2,000 | 5.47 | 14.51 | 2.7x | 93 | 125 |
| 4,000 | 22.64 | 65.69 | 2.9x | 377 | 494 |

Memory is the extra peak memory of the fit, on top of
the similarity matrix; on an Apple M3 Pro the speedup
is smaller (1.2x to 1.3x).
The full tables and the machine details are in
[naffprop's README](https://github.com/pietroppeter/naffprop#benchmark).
"""
nbNote """
nimlang-pypi and naffprop are the speaker's own projects,
both from 2026 and both mostly written by an AI coding
agent with the human writing the specs (their READMEs
say so). nimlang-pypi is alpha.
"""

nbText """
## Rocks ahead

- The bridges are of different maturity: nimpy is
  solid, rnim is a prototype, nimjl needs Julia installed
  and has few users. Python is the ecosystem Nim reaches
  best.
- Packaging Nim for Python had no maintained tool
  for a few years; nimlang-pypi is new and alpha, and bundles
  one Nim version for now.
- Writing a Python extension in Nim is easy, but few
  Python users know Nim: compared with Rust and PyO3,
  there are fewer examples to copy and fewer people to
  ask.
"""

nbText """
## Try it

The quickest test is the session above:
`uv init`, `uv add nimlang`, and the two files.
To run this page, clone [the
repository](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim)
and run `nim r deepdive/interoperability.nim`:
it builds `docs/deepdive/interoperability.html`.
"""
nbSave
