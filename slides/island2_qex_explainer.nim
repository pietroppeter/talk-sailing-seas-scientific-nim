import std / [json, math, random, strformat]
import nimib
import nimib / highlight

# A nimib document that explains, in plain words, lattice QCD
# and QEX, the third success story of Island 2
# (slides/island2_stories.nim):
#   nim r slides/island2_qex_explainer.nim
# writes docs/island2_qex_explainer.html.
# The toy lattice below runs when the page is built;
# the QEX snippets are quoted, not run.

# this path writes the page to docs/, not docs/slides/
nbInit(thisFileRel = "island2_qex_explainer.nim")
# but with it nimib cannot find this file,
# so give the "Show Source" button its source here
const ownSource = staticRead("island2_qex_explainer.nim")
nb.doc.source = ownSource
nb.doc.context["source"] = %nb.doc.source
nb.doc.context["source_highlighted"] = %highlightNim(nb.doc.source)
nbRawHtml("<style>\n" & """
pre { overflow-x: auto; }
table { font-size: 0.9em; }
""" & "</style>")

nbText """
# Lattice QCD and QEX in plain words

In the talk [Sailing Seas of Scientific
Nim](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/),
Island 2 tells three success stories.
The third is QEX, Quantum EXpressions,
a framework for lattice QCD written in Nim
by James Osborn and Xiao-Yong Jin,
physicists at Argonne National Laboratory (US).

This page explains what lattice QCD is,
what QEX does, who uses it and where Nim comes in.
No physics background assumed.

## Quarks, gluons and a grid

Protons and neutrons are made of quarks,
held together by gluons.
The theory of this strong force is
quantum chromodynamics, QCD.
Its equations are known, but at the energies
of everyday matter they cannot be solved with pen and paper.

Lattice QCD replaces continuous space and time
with a four dimensional grid of points, the lattice.
Quark fields live on the points,
and the gluon field lives on the links between neighbours:
each link carries a small matrix (a 3 x 3 complex matrix
in the group SU(3)) that says how a quark changes
when it hops along that link.
The computer then samples many random configurations
of the gluon field, weighted by how likely they are,
and averages physical quantities over them.
Lattices with billions of numbers and months
of supercomputer time are normal in the field:
this is high performance computing.

## The plaquette

The simplest quantity is the plaquette:
walk around the smallest square of the lattice,
multiply the four link matrices you meet,
and take the trace.
Averaged over the lattice, it measures how strong
the gluon field is, and it is the building block
of the action, the formula that weighs configurations.

The slide shows how QEX writes it,
from its example `src/examples/ex1.nim`:
"""

nbRawHtml("<pre><code class=\"nohighlight nim hljs\">" & highlightNim("""
proc plaq*(g: seq[Field]): float =
  let lo = g[0].l
  let nd = lo.nDim
  var m = lo.ColorMatrix()
  var tr: type(trace(m))
  let t = newTransporters(g, g[0], 1)
  threads:
    m := 0
    for mu in 1..<nd:
      for nu in 0..<mu:
        m += (t[mu]^*g[nu]) * (t[nu]^*g[mu]).adj
    tr = trace(m)
  result = tr.re/(0.5*float(nd*(nd-1)*lo.physVol))""") & "</code></pre>")

nbText """
`g` holds one field of link matrices per direction,
`t[mu]^*g[nu]` transports a field one step along `mu`,
`.adj` is the conjugate transpose (walking a link backwards)
and `:=` and `+=` act on whole lattice fields at once,
inside `threads:`, which runs the loop in parallel.
These are the "quantum expressions" of the name:
the code reads like the formula, and QEX turns it
into fast loops with SIMD vector instructions.

## A toy lattice you can run

To get a feeling for it, here is a toy that runs
when this page is built: the gauge group U(1),
where each link is just an angle (a complex number
of length one) instead of a 3 x 3 matrix,
on a two dimensional 16 x 16 lattice.
The plaquette angle is the sum of the four link angles
around a square, taken backwards on the way back,
and the plaquette is its cosine.
"""

nbCode:
  const L = 16
  type Lattice = array[L, array[L, array[2, float]]] # angle of link (x, y, mu)

  proc plaquetteAngle(u: Lattice, x, y: int): float =
    let (xp, yp) = ((x + 1) mod L, (y + 1) mod L)
    u[x][y][0] + u[xp][y][1] - u[x][yp][0] - u[x][y][1]

  proc avgPlaquette(u: Lattice): float =
    for x in 0..<L:
      for y in 0..<L:
        result += cos(plaquetteAngle(u, x, y))
    result /= float(L * L)

  var cold: Lattice # all angles zero: no field at all
  var r = initRand(2026)
  var hot: Lattice # all angles random
  for x in 0..<L:
    for y in 0..<L:
      for mu in 0..1:
        hot[x][y][mu] = r.rand(-PI..PI)
  echo &"cold start: {avgPlaquette(cold):.3f}"
  echo &"hot start:  {avgPlaquette(hot):.3f}"

nbText """
Neither is physics yet.
The real simulation samples configurations with weight
exp(β Σ cos P), where β sets the strength of the coupling.
The classic way is Metropolis: propose a small change
to one link, keep it if it lowers the action,
and otherwise keep it with a probability
that falls with how much it raises it.
In two dimensions U(1) has an exact answer
for a large lattice, I₁(β) / I₀(β) (a ratio of
modified Bessel functions), so we can check the toy.
"""

nbCode:
  proc besselI(n: int, z: float): float =
    # power series, fine for small z
    var term = pow(z / 2, float(n)) / float(fac(n))
    for k in 0..40:
      result += term
      term *= (z / 2) ^ 2 / float((k + 1) * (k + 1 + n))

  proc localAction(u: Lattice, x, y, mu: int, beta: float): float =
    # the two plaquettes that contain link (x, y, mu)
    let (xm, ym) = ((x - 1 + L) mod L, (y - 1 + L) mod L)
    if mu == 0:
      -beta * (cos(plaquetteAngle(u, x, y)) + cos(plaquetteAngle(u, x, ym)))
    else:
      -beta * (cos(plaquetteAngle(u, x, y)) + cos(plaquetteAngle(u, xm, y)))

  proc sweep(u: var Lattice, beta: float, r: var Rand) =
    for x in 0..<L:
      for y in 0..<L:
        for mu in 0..1:
          let old = u[x][y][mu]
          let before = localAction(u, x, y, mu, beta)
          u[x][y][mu] = old + r.rand(-1.0..1.0)
          let after = localAction(u, x, y, mu, beta)
          if r.rand(1.0) >= exp(before - after):
            u[x][y][mu] = old # rejected

  for beta in [1.0, 2.0, 4.0]:
    var u = hot
    for i in 1..200: sweep(u, beta, r) # thermalize
    var total = 0.0
    for i in 1..500:
      sweep(u, beta, r)
      total += avgPlaquette(u)
    echo &"beta {beta}: toy {total / 500:.3f}, exact {besselI(1, beta) / besselI(0, beta):.3f}"

nbText """
A few lines of plain Nim get close to the exact numbers.
QEX does the same kind of work in four dimensions
with SU(3) matrices, with quarks too,
on many cores and many machines,
and with much better algorithms
(hybrid Monte Carlo, conjugate gradient solvers).

## What QEX is

QEX started in 2016 and is still very active:
1,477 commits by October 2026, 298 of them in 2026.
James Osborn and Xiao-Yong Jin wrote most of it,
and Curtis Peterson (University of Colorado)
is the third main contributor, since 2022.

| author | commits |
|---|---|
| James Osborn | 712 |
| Xiao-Yong Jin | 577 |
| Curtis Peterson | 185 |
| others | 3 |

Its README lists what it supports:
U(1) and SU(2) to SU(4) gauge fields in any dimension,
SciDAC I/O, gauge fixing, staggered solvers and forces
(Asqtad, HISQ, nHYP), a Wilson solver,
and interfaces to Chroma, Grid and QUDA,
the big C++ lattice codes.
That last point is Nim's interop at work:
"Since Nim compiles to native C/C++, directly calling
any C/C++ lattice code or library from QEX
is relatively easy to do."
It runs on CPUs with SIMD support,
and native GPU support is experimental.

The documentation is a book written with
[nimibook](https://github.com/pietroppeter/nimibook),
the nimib based book generator, in the folder `nbook/`.

## Papers

The framework was presented in two proceedings:

| paper | where |
|---|---|
| [QEX: a framework for lattice field theories](https://arxiv.org/abs/1612.02750) | ICHEP 2016, [PoS(ICHEP2016)187](https://doi.org/10.22323/1.282.0187) |
| [Introduction to the Quantum EXpressions (QEX) framework](https://doi.org/10.22323/1.256.0271) | Lattice 2016, PoS(LATTICE2016)271 |

They explain the choice of Nim: its metaprogramming
lets a physicist write natural expressions
as in a scripting language, while keeping the control
needed for low level optimizations,
all in one language.

Other physicists use it for new results.
Simulations with Pauli-Villars fields,
added to QEX by Curtis Peterson, are behind
recent work of the University of Colorado group
on symmetric mass generation,
a way for particles to get a mass
without breaking a symmetry:

| paper | authors | where |
|---|---|---|
| [Symmetric Mass Generation with four SU(2) doublet fermions](https://arxiv.org/abs/2409.02062) | Nouman Butt, Simon Catterall, Anna Hasenfratz | Phys. Rev. Lett. (2025) |
| [Investigating SU(3) with Nf=8 fundamental fermions at strong renormalized coupling](https://arxiv.org/abs/2412.10322) | Anna Hasenfratz, Oliver Witzel | Lattice 2024 |

Peterson's fork,
[ctpeterson/qex](https://github.com/ctpeterson/qex),
adds a full staggered hybrid Monte Carlo
and gradient flow suite.

## Machine learning on the lattice

Xiao-Yong Jin also works on neural networks
that transform gauge fields to make simulations
sample better
([arXiv:2201.01862](https://arxiv.org/abs/2201.01862),
[arXiv:2405.19692](https://arxiv.org/abs/2405.19692)).
In September 2026 QEX gained
"learned U(1) field transformations"
(`src/experimental/nnft`): neural network layers
(convolutions, GELU) built on QEX fields,
with NumPy/JAX array interchange,
on the same two dimensional U(1) lattice as the toy above.

## Sources

[QEX on GitHub](https://github.com/jcosborn/qex)
(commit counts from its git history, October 2026),
the papers linked above.
"""

nbSave
