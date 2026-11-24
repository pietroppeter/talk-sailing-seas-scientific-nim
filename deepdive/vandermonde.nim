import std / [strutils, sequtils]
import nimib
import tabelline, tabelline / nimib
import deepdive # useDeepDive, and the blocks of blocks.nim
import ../slides/island1_performance # the benchmark code and its results

# A nimib document that explains the benchmark of Island 1
# (slides 2.2 and 2.3, in slides/island1_performance.nim):
#   nim r deepdive/vandermonde.nim
# writes docs/deepdive/vandermonde.html.
# The timings are read from bench/vandermonde/results.csv, written by
# bench/vandermonde/run.sh; the Nim code below runs when the page is built.

nbInit(thisFileRel = "deepdive/vandermonde.nim")
const ownSource = staticRead("vandermonde.nim")
nb.useDeepDive("vandermonde", ownSource)
nb.useLatex

nbText """
# The Vandermonde matrix, with for loops

In the talk [Sailing Seas of Scientific
Nim](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/slides.html),
Island 1 (Accessible Performance) is two slides:
what the Vandermonde matrix is, then the same function
in Python and in Nim, side by side, both written with
plain for loops, and a mini benchmark.
Nim reads like Python and runs like C:
this page has the matrix, the code, the numbers and their
caveats, and where to go when you need more.
"""

nbText """
## What the Vandermonde matrix is

The Vandermonde matrix of the points $x_0, \dots, x_{m-1}$
has a row for each point, with its powers up to $n-1$:

$$
V = \begin{pmatrix}
1 & x_0 & x_0^2 & \cdots & x_0^{n-1} \\\\
1 & x_1 & x_1^2 & \cdots & x_1^{n-1} \\\\
\vdots & \vdots & \vdots & & \vdots \\\\
1 & x_{m-1} & x_{m-1}^2 & \cdots & x_{m-1}^{n-1}
\end{pmatrix},
\qquad V_{ij} = x_i^{\,j}.
$$

It is how polynomials meet linear algebra.
A polynomial $p(x) = a_0 + a_1 x + \dots + a_{n-1} x^{n-1}$
is its vector of coefficients $a$, and $V a$ is the vector
of its values at the points: $(V a)_i = p(x_i)$.
So:

- **Interpolation**: with as many points as coefficients
  ($m = n$, distinct points), the polynomial through the points
  $(x_i, y_i)$ is the solution of $V a = y$.
  The matrix can be inverted exactly when the points are
  distinct: its determinant is
  $\prod_{i < j} (x_j - x_i)$.
- **Fitting**: with more points than coefficients,
  the least squares polynomial minimises $\lVert V a - y \rVert$.
  This is what `np.polyfit` does, with `np.vander`
  (in the decreasing order of powers, NumPy's default).

In practice the monomials $1, x, x^2, \dots$
are a poor basis for high degrees: the Vandermonde matrix
gets badly conditioned, and numerical libraries prefer
orthogonal polynomials (Chebyshev, Legendre) for serious work.
For the benchmark it is just a good small loop.
"""

nbText """
## The function

Each power is the previous one times $x_i$,
so two nested loops fill the matrix.

In Python:
"""
nbShowCode(vanderPyCode, lang = "python",
  caption = "from [bench/vandermonde/vander.py](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim/blob/main/bench/vandermonde/vander.py)")

nbText """
And in Nim, line by line the same,
with types on the parameters and the result:
"""
nbCode:
  proc vander(x: seq[float], n: int): seq[seq[float]] =
    var v = newSeqWith(x.len, repeat(1.0, n))
    for i in 0 ..< x.len:
      for j in 1 ..< n:
        v[i][j] = v[i][j-1] * x[i]
    return v

  for row in vander(@[1.0, 2.0, 3.0, 4.0], 4):
    echo row
# the code above is the code that was timed
static: doAssert ownSource.contains(vanderNimCode.indent(2))

nbText """
With it, $V a$ evaluates a polynomial at all the points
at once. The coefficients of $1 + x + x^2$ are $(1, 1, 1)$:
"""
nbCode:
  let
    xs = @[0.0, 1.0, 2.0, 3.0]
    a = @[1.0, 1.0, 1.0] # 1 + x + x^2
  for row in vander(xs, a.len):
    var p = 0.0
    for j in 0 ..< a.len:
      p += row[j] * a[j]
    echo p

nbText """
## The benchmark

One matrix of 1000 points and 100 powers,
the best of 100 runs, with the Python loops,
with NumPy's `np.vander` and with the Nim loops
(compiled with `-d:release`, Nim's usual optimised build).
These are the numbers on the slide:
"""
nbTable benchTable("large", "1000 × 100")
nbText "Measured with " & benchMachineInfo() & "."

nbText """
The Python loops are more than ten times slower than the others.
That is why Python programmers are told not to write
for loops on numbers: `np.vander` is fast because its loop
is in C, inside NumPy. In Nim the loop *is* the fast code:
it is compiled to C, and from C to machine code,
so you are allowed to write for loops.
Nim and NumPy are in the same range here,
and that is what to expect: compiled loops are
comparable to NumPy, not faster than it.

All three compute the same matrix:
`vander.py` checks that the Python loops and `np.vander`
give the same numbers, and the sum of the matrix
(the checksum in `results.csv`) is the same for all three.
"""

nbText """
### Why NumPy is not faster here

NumPy has no trick that the loops lack in this case.
`np.vander` (in NumPy's Python code) allocates the matrix,
fills its first column with 1 and every other column with $x$,
then calls `np.multiply.accumulate` along each row.
The C loop of `accumulate` does the same multiplications
as our loops, one row at a time, each power waiting for the
previous one, so the CPU cannot do them in parallel (no SIMD).
On top of that NumPy writes the matrix twice
(the copies of $x$, then the powers) and starts its C loop
once per row. That is why the Nim loops can come out level
with it, or a little ahead: on another machine,
or with another shape of matrix, NumPy can come out ahead.
"""

nbText """
## Where the example comes from

The Vandermonde matrix is the case study of section 2.1.1 of
Jeff Bezanson's PhD thesis,
[Abstraction in Technical Computing](https://dspace.mit.edu/handle/1721.1/99811)
(MIT, 2015), the thesis behind the Julia language.
It shows NumPy's own `vander`, written in Python on top of
NumPy's `multiply.accumulate`, next to a Julia version
written with loops, and times them in its table 2.1.
For one large matrix both are fast;
for many small matrices NumPy is much slower
(5.43 s against 0.072 s for 250 000 matrices of 4 × 4),
because each call goes through layers of Python
before reaching the loop in C.
It is the two-language problem in a page of code:
high-level code is easy to write, fast code is in another
language, and the boundary between the two has a cost.

For comparison, here is the same function with loops
in today's Julia. Julia stores a matrix column by column,
so the natural loop goes down each column,
the opposite order of the Python and Nim versions;
the multiplications of a column are independent,
which lets the compiler use SIMD.
This code is not run when the page is built
(there is no Julia here), and the thesis' own version,
written for the Julia of 2015, is in the talk's
[notes](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim/blob/main/notes/vandermonde-benchmark.md).
"""
nbShowCode("""
function vander(x, n)
    v = ones(length(x), n)
    for j in 2:n
        for i in eachindex(x)
            v[i, j] = v[i, j-1] * x[i]
        end
    end
    return v
end
""", lang = "julia")

nbText """
We can run the same small case with our three versions:
"""
nbTable benchTable("small", "250 000 × (4 × 4)")
nbText """
With matrices this small, NumPy is slower than
the Python loops: the call costs more than the work.
The Nim loops are called from Nim, so they pay no such price.
Called from Python (for example through
[nimpy](https://github.com/yglukhov/nimpy)), each call would
cross the same boundary and pay a similar price:
the boundary costs, whatever the language behind it.
"""

nbText """
## Caveats

A mini benchmark is a hint, not a proof:

- **One machine.** The numbers come from one run
  of `run.sh` on one machine (see above);
  on another machine they will differ.
- **Noise.** On the cloud machine where these numbers
  were measured, the Nim time of the large case
  moves between about 0.24 and 0.37 ms from one run of
  `run.sh` to the next, NumPy's around 0.3 ms,
  and Python's between about 4 and 5.5 ms.
  Nim and NumPy are in the same range,
  neither is clearly faster.
- **The same algorithm, not the best one.**
  Each version fills one row at a time,
  each power depending on the previous one.
  A seq of seqs, as Python's list of lists,
  allocates every row on its own.
  Filling a flat array column by column lets the
  C compiler use SIMD instructions, which can be several
  times faster again, in Nim as in Julia or C:
  that is loop structure, not language.
"""

nbText """
## No ceiling

The loops above are the start, not the limit.
Nim compiles to C (or C++), so when you need it
you can go as low as you want, from Nim:

- **Compile flags**: `-d:danger` drops the bound checks,
  `--passC:-march=native` targets your CPU.
- **Memory layout**: flat arrays, `ptr UncheckedArray`,
  your own allocators, no garbage collector in the hot loop.
- **SIMD and threads**: intrinsics
  (for example [nimsimd](https://github.com/guzba/nimsimd)),
  thread pools and task schedulers
  ([weave](https://github.com/mratsim/weave)).
- **GPUs and assembly**: bindings to CUDA and OpenCL
  (Arraymancer runs on both), inline assembly
  (`asm` statements);
  [constantine](https://github.com/mratsim/constantine),
  a cryptography library, generates its assembly with macros.

Mamy André-Ratsimbazafy, the author of weave,
constantine and Arraymancer, gives a talk on
high-performance computing for AI in Nim in the same
session as this talk: that is where this island goes deep.
"""

nbText """
## To learn more

- [Vandermonde matrix](https://en.wikipedia.org/wiki/Vandermonde_matrix)
  and [polynomial interpolation](https://en.wikipedia.org/wiki/Polynomial_interpolation)
  on Wikipedia: the definition, the determinant,
  and why the matrix can be inverted for distinct points.
- NumPy's
  [np.vander](https://numpy.org/doc/stable/reference/generated/numpy.vander.html)
  and
  [np.polyfit](https://numpy.org/doc/stable/reference/generated/numpy.polyfit.html),
  which fits a polynomial by least squares with it.
- Lloyd N. Trefethen,
  [Approximation Theory and Approximation Practice](https://people.maths.ox.ac.uk/trefethen/ATAP/)
  (SIAM, 2013): why monomials and Vandermonde matrices go
  wrong at high degree, and what to use instead.
- Jeff Bezanson,
  [Abstraction in Technical Computing](https://dspace.mit.edu/handle/1721.1/99811)
  (MIT, 2015), section 2.1.1: the Vandermonde matrix as the
  case study of the two-language problem.
"""

nbText """
## Run it yourself

The benchmark is in
[bench/vandermonde](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim/tree/main/bench/vandermonde)
in the talk's repository. With Python, NumPy and Nim installed:

```
bash bench/vandermonde/run.sh
```

compiles the Nim version, runs the three versions on both
cases and writes `results.csv` and `machine.txt`,
which the slide and this page read when they are built.
"""
nbSave
