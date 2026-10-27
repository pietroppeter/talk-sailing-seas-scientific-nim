import std / [math, strutils, strformat, json]
import nimib
import nimib / highlight
import island4_vectors

# A nimib document that explains the custom operators example
# of Island 4 (slides 5.2 and 5.3, in slides/island4_expressive.nim):
#   nim r slides/island4_operators_explainer.nim
# writes docs/island4_operators_explainer.html.
# The code below runs when the page is built, like on the slides.

# this path writes the page to docs/, not docs/slides/
nbInit(thisFileRel = "island4_operators_explainer.nim")
# but with it nimib cannot find this file,
# so give the "Show Source" button its source here
const ownSource = staticRead("island4_operators_explainer.nim")
nb.doc.source = ownSource
nb.doc.context["source"] = %nb.doc.source
nb.doc.context["source_highlighted"] = %highlightNim(nb.doc.source)
nb.useLatex
nbRawHtml("<style>\n" & """
pre { overflow-x: auto; }
.lines { font-size: 0.8em; color: #6b7280; margin-top: -0.5em; }
""" & "</style>")

nbText """
# Custom operators: a shadow at sea

In the talk [Sailing Seas of Scientific
Nim](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/),
Island 4 shows, on two slides, how Nim lets you define
your own operators: with a few lines of geometry,
`Point + Point` makes a line, and a line and a plane
meet in a point, the shadow of a mast top on the sea.
A slide has room for little code, so this page takes
the time to explain it, and goes further:
how operators work in Nim, the geometry behind the
example, where it breaks, and one more operator to try.
All the code on this page runs when the page is built,
and the output below each block is its real output.
"""

nbText """
## Operators in Nim

In Nim an operator is just a procedure whose name is
made of operator characters:
`+  -  *  /  \  <  >  =  @  $  ~  &  %  !  ?  ^  .  |`.
You define it like any procedure, with the name between
backticks, and call it in infix position (`a + b`) or,
with one argument, in prefix position (`-a`).
Characters can be combined into new operators,
like `**`, `<+>` or `->`,
and a set of unicode symbols are operators too, like
`∙ ∘ × ⊗ ∧` and `± ⊕ ⊖ ∨`
(the full list is in the
[manual](https://nim-lang.org/docs/manual.html#lexical-analysis-unicode-operators)).
Operators are overloaded on the types of their
arguments, like any other procedure,
so the same `+` can add numbers, points and vectors.
A few keywords are operators too:
`and`, `or`, `not`, `div`, `mod`, `shl`, `in`, `is`...

There is no table of operators to register a new one
in: the precedence of an operator comes from its
**first character**, and its associativity from the
first character too (only operators starting with `^`
are right associative).
The [manual](https://nim-lang.org/docs/manual.html#syntax-precedence)
has the full table; from the highest precedence:
`$` and `^`, then `*` `%` `\` `/`, then `+` `-` `~` `|`,
then `&`, then `.`, then comparisons starting with
`=` `<` `>` `!`, then `@` `:` `?`.
Operators that end in `=` (like `+=`) are assignment
operators, with a precedence below all of these,
and arrow-like operators (`->`, `=>`) have the lowest
precedence.
Unary operators always bind tighter than binary ones.
Let's check some of these rules:
"""
nbCode:
  echo 2 ^ 3 ^ 2   # right associative: 2 ^ 9

  func `**`(a, b: int): int = a * b
  echo 2 + 3 ** 4  # `**` starts with `*`: 2 + 12

  func `<+>`(a, b: int): int = a + b
  echo 1 <+> 2 * 3 # `<+>` is a comparison: 1 <+> 6

  func `->`(a, b: int): string = $a & " to " & $b
  echo 1 + 2 -> 3 * 4 # `->` binds last

  echo -2 ^ 2      # unary minus first: (-2) ^ 2

nbText """
The unicode operators follow the same idea:
`∙ ∘ × ★ ⊗ ⊘ ⊙ ⊛ ⊠ ⊡ ∩ ∧ ⊓` have the precedence of `*`,
`± ⊕ ⊖ ⊞ ⊟ ∪ ∨ ⊔` that of `+`.
For example, a measurement with its error:
"""
nbCode:
  type Measure = object
    value, error: float

  func `±`(value, error: float): Measure =
    Measure(value: value, error: error)

  func `+`(a, b: Measure): Measure =
    a.value + b.value ± sqrt(a.error^2 + b.error^2)

  echo (1.0 ± 0.3) + (2.0 ± 0.4)

nbText """
The parentheses are needed: `±` has the precedence of
`+`, and both are left associative, so without them
`1.0 ± 0.3 + 2.0 ± 0.4` reads as
`((1.0 ± 0.3) + 2.0) ± 0.4`, and `Measure + float`
is not defined. The compiler rejects it:
"""
nbCode:
  echo compiles(1.0 ± 0.3 + 2.0 ± 0.4)

nbText """
That is the trade-off of custom operators:
code that reads like the math on paper,
with Nim's fixed rules for precedence instead of the
conventions of the paper,
and types that catch most of the misreadings.
Python and C++ let you overload a fixed set of
operators, R has user defined `%op%` operators, and
Julia, like Nim, accepts many unicode symbols;
in Nim you also make new operators by combining
operator characters, with no declaration other than the
procedure itself.
"""

nbText """
## Points are not vectors

The slides use a small helper module,
[`slides/island4_vectors.nim`](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim/blob/main/slides/island4_vectors.nim),
written for the talk, not part of the standard library
(`std/math` has no points or vectors):
"""
const vectorsSource = staticRead("island4_vectors.nim")
nbRawHtml &"""<pre><code class="nim hljs">{highlightNim(vectorsSource.strip)}</code></pre>
<p class="lines">slides/island4_vectors.nim</p>"""

nbText """
A `Point` is a position and a `Vec` is a displacement,
and they are different types even if both have three
coordinates: this is the classic distinction of
[affine space](https://en.wikipedia.org/wiki/Affine_space).
The difference of two points is a vector,
a point plus a vector is a point,
a number times a vector is a vector.
`∙` is the dot product, and `×` the cross product,
which gives a vector perpendicular to both of its
arguments.
`func` is a procedure without side effects, checked by
the compiler, and the `*` after a name exports it from
the module.

What is the sum of two points?
In affine space it means nothing:
it would depend on where you put the origin.
So the module does not define it,
and since no meaning is taken, we are free to give
`Point + Point` a new one.

Two separate object types are the simplest way to keep
points and vectors apart.
Another way is `distinct` types, which share the
representation of an existing type but not its
procedures, so you choose which ones to borrow:
it is the trick that unchained uses for units,
on the next slides of the talk.
"""

nbText """
## Join and meet

A line through point $p$ along direction $d$ is the set
of points $p + t d$, for every number $t$.
A plane through point $q$ with normal $n$ is the set of
points $x$ with $(x - q) \cdot n = 0$.
So two types, with a point and a vector each:
"""
nbCode:
  type
    Line = object   # through p, along d
      p: Point
      d: Vec
    Plane = object  # through p, normal n
      p: Point
      n: Vec

nbText """
Two points $a$ and $b$ are joined by the line through
$a$ along $b - a$.
A line and a point $c$ outside it are joined by a plane:
its normal must be perpendicular both to the direction
$d$ of the line and to $c - p$, the direction from the
line to the new point, and the cross product
$d \times (c - p)$ is exactly that.
So `+` is the **join**:
"""
nbCode:
  func `+`(a, b: Point): Line = Line(p: a, d: b - a)
  func `+`(l: Line, c: Point): Plane =
    Plane(p: l.p, n: l.d × (c - l.p))

nbText """
A line and a plane **meet** in a point.
Putting $x = p + t d$ into the equation of the plane
gives $(p + t d - q) \cdot n = 0$, so
$$t = \frac{(q - p) \cdot n}{d \cdot n}$$
and the code is that formula, with `*` as the meet:
"""
nbCode:
  func `*`(l: Line, s: Plane): Point =
    l.p + ((s.p - l.p) ∙ s.n) / (l.d ∙ s.n) * l.d

nbText """
In the last line `∙`, `/` and `*` all have the same
precedence and are left associative, so it reads as
`((s.p - l.p) ∙ s.n) / (l.d ∙ s.n)`, a number,
times `l.d`, a vector: the `*` defined in the helper
module for a number and a vector.

There are now three `+` in scope and two `*`,
and the compiler picks one from the types of the
arguments:
"""
nbCode:
  let a = pt(0, 0, 0)
  let b = pt(1, 2, 3)
  echo typeof(a + (b - a)) # Point + Vec
  echo typeof(a + b)       # Point + Point
  echo typeof(a + b + pt(0, 0, 1)) # Line + Point

nbText """
Join and meet are the names that
[projective geometry](https://en.wikipedia.org/wiki/Projective_geometry)
gives to these two operations, and
[geometric algebra](https://bivector.net)
writes them `∨` and `∧`, which are Nim operators too.
The slides use `+` and `*` instead, because they read
naturally and need no unicode keyboard.
"""

nbText """
## A shadow at sea

The sea is the plane through three points at height 0,
the sun is a point up in the sky, and the mast top is
12 meters above the origin, where the mast stands.
The line from the sun through the mast top meets the
sea where the shadow of the mast top falls:
"""
nbCode:
  let
    sea = pt(0, 0, 0) + pt(1, 0, 0) + pt(0, 1, 0)
    sun = pt(-30, 0, 40)
    mastTop = pt(0, 0, 12)
    shadow = (sun + mastTop) * sea
  echo shadow

nbText """
`pt(0, 0, 0) + pt(1, 0, 0) + pt(0, 1, 0)` is
`(Point + Point) + Point`, so `Line + Point`, a `Plane`.
Each step has a type, and the compiler checks them:
"""
nbCode:
  echo typeof(sun + mastTop)
  echo typeof(sun + mastTop + shadow)
  echo compiles(sea * sun) # a plane times a point
  echo compiles(sun + mastTop + shadow + sun)

nbText """
The second line is a plane through the sun, the mast
top and its shadow, which is a vertical plane, since the
sun is right above the x axis.
The last two lines do not compile: there is no meet of
a plane and a point, and no join of a plane and a point
in three dimensions (it would be the whole space).

A real sun is not a point 50 meters away:
it is so far that its rays are parallel,
and the line of a ray is better given by a point and a
direction.
Projective geometry handles this with *points at
infinity*: a direction is a point at infinity, and a
point plus a point at infinity is the line through the
first point along that direction.
In homogeneous coordinates (four numbers for a point
in space) join and meet become a single formula each,
with no special cases, which is how computer graphics
and geometric algebra do it.
Here we keep three coordinates, and a sun 50 meters
away.
"""

nbText """
## Where it breaks

The types catch nonsense, not degenerate geometry.
Three points on one line do not make a plane,
a line parallel to the sea never meets it,
and a line lying on the sea meets it everywhere.
The code does not check, and floats do what they do:
"""
nbCode:
  let flat = pt(0, 0, 12) + pt(1, 0, 12)
  echo "parallel line: ", flat * sea
  let onSea = pt(0, 0, 0) + pt(1, 1, 0)
  echo "line on the sea: ", onSea * sea
  let notAPlane = pt(0, 0, 0) + pt(1, 0, 0) + pt(2, 0, 0)
  echo "normal of three points on a line: ", notAPlane.n
  echo "meet with it: ", (sun + mastTop) * notAPlane

nbText """
For a parallel line $d \cdot n = 0$ and the division
gives infinities; for a line on the plane, or a plane
with zero normal, it is $0 / 0$, so NaN (not a number).
A library would check $d \cdot n$ against a tolerance,
and return an `Option[Point]` or raise an error;
the slide leaves it out to fit.
"""

nbText """
## Try it: two planes meet in a line

Two planes that are not parallel meet in a line.
Its direction is perpendicular to both normals, so it is
their cross product $n_1 \times n_2$.
For a point on it, look for $x = \alpha n_1 + \beta n_2$
(from the origin) on both planes: with
$c_i = q_i \cdot n_i$ the equations
$x \cdot n_i = c_i$ are two linear equations in
$\alpha$ and $\beta$.
Try to write the `*` of two planes before reading the
solution below.
Then use it for the shadow of the whole mast:
the plane through the sun, the foot of the mast and its
top meets the sea in the line of the shadow.

Solving the two equations with Cramer's rule:
"""
nbCode:
  func `+`(u, v: Vec): Vec = Vec(x: u.x + v.x, y: u.y + v.y, z: u.z + v.z)

  func `*`(a, b: Plane): Line =
    let
      o = pt(0, 0, 0)
      (n1, n2) = (a.n, b.n)
      (c1, c2) = ((a.p - o) ∙ n1, (b.p - o) ∙ n2)
      det = (n1 ∙ n1) * (n2 ∙ n2) - (n1 ∙ n2)^2
      alpha = (c1 * (n2 ∙ n2) - c2 * (n1 ∙ n2)) / det
      beta = (c2 * (n1 ∙ n1) - c1 * (n1 ∙ n2)) / det
    Line(p: o + (alpha * n1 + beta * n2), d: n1 × n2)

  let
    mastFoot = pt(0, 0, 0)
    mastShadow = (sun + mastFoot + mastTop) * sea
  echo mastShadow.p, " along ", mastShadow.d

nbText """
The shadow of the mast lies on the x axis (it goes
through the origin, along $x$): it starts at the foot of
the mast and ends at the shadow of the mast top found
above.
If the planes are parallel, `det` is 0 and we are back
to the previous section.

To play with the code, clone [the
repository](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim)
and run `nim r slides/island4_operators_explainer.nim`:
it builds this page in
`docs/island4_operators_explainer.html`.
The
[README](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim#readme)
explains how to install the dependencies.
"""
nbSave
