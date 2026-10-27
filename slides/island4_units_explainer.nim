import std / [math, strutils, strformat, json]
import nimib
import nimib / highlight
import unchained
from island4_units import SolarMass, Msun, EarthMass, Mearth

# A nimib document that explains the units example of Island 4
# (slides 5.4 and 5.5, in slides/island4_expressive.nim):
#   nim r slides/island4_units_explainer.nim
# writes docs/island4_units_explainer.html.
# The code below runs when the page is built, like on the slides.

# this path writes the page to docs/, not docs/slides/
nbInit(thisFileRel = "island4_units_explainer.nim")
# but with it nimib cannot find this file,
# so give the "Show Source" button its source here
const ownSource = staticRead("island4_units_explainer.nim")
nb.doc.source = ownSource
nb.doc.context["source"] = %nb.doc.source
nb.doc.context["source_highlighted"] = %highlightNim(nb.doc.source)
nb.useLatex
nbRawHtml("<style>\n" & """
pre { overflow-x: auto; }
.lines { font-size: 0.8em; color: #6b7280; margin-top: -0.5em; }
""" & "</style>")

const
  siUnitsSource = staticRead("../deps/unchained/src/unchained/si_units.nim")
  newUnitsSource = staticRead("island4_units.nim")

proc between(source, first, last: string): string =
  ## the lines of `source` from the one starting with `first`
  ## up to (not including) the one starting with `last`
  let lines = source.splitLines
  var start, stop = -1
  for i, line in lines:
    if start < 0 and line.startsWith(first): start = i
    elif start >= 0 and line.startsWith(last):
      stop = i - 1
      break
  doAssert start >= 0 and stop >= start,
    "explainer: code not found from '" & first & "' to '" & last & "'"
  lines[start .. stop].join("\n").strip(leading = false)

proc showCode(code, caption: string) =
  nbRawHtml &"""<pre><code class="nim hljs">{highlightNim(code)}</code></pre>
<p class="lines">{caption}</p>"""

nbText """
# Units with unchained

In the talk [Sailing Seas of Scientific
Nim](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/),
Island 4 shows metaprogramming with
[unchained](https://github.com/SciNim/unchained),
a library by Vindaar (Sebastian Schmidt) for physical
units checked at compile time.
On two slides we see how its `declareUnits` macro
declares units and lets us add our own,
and how Kepler's third law reads with units.
This page goes through what happens behind those
slides: what a unit is in unchained, what its macros
do, how to add units, and the pitfalls we met.
All the code on this page runs when the page is built,
and the output below each block is its real output.
"""

nbText """
## A unit is a distinct float

In unchained a value with a unit is just a float,
with a type that carries the unit.
A number followed by `.` and a unit makes one:
"""
nbCode:
  let mass = 80.kg
  echo mass
  echo typeof(mass)
  echo sizeof(mass) # bytes, like a float

nbText """
`KiloGram` is a `distinct` type: it has the same
representation as a float, so there is no cost at run
time, but none of the procedures of float.
`kg` is an alias of `KiloGram`, and `80.kg` is a call
of unchained's `.` macro, which reads the unit after
the dot when the program is compiled.
Units with powers and products are written with
superscripts and `•`, which are valid in Nim
identifiers (with ASCII spellings too, see the
[README](https://github.com/SciNim/unchained#readme)):
"""
nbCode:
  let g = 9.81.m•s⁻²
  let weight = mass * g
  echo weight
  echo typeof(weight)
  echo quantityOf(weight)

nbText """
The product of a mass and an acceleration is a force,
and unchained knows that a `kg•m•s⁻²` is a Newton.
`quantityOf` shows the unit in base quantities.
"""

nbText """
## Operators are macros

In Nim `*`, `/`, `+` and `-` are procedures, so a
library can define them for its own types.
unchained defines them as **macros**: code that runs in
the compiler, reads the types of the two arguments,
and writes the right expression with the right result
type.
For `*` it adds the powers of the two units, simplifies,
and finds the type of the result, defining it on the
spot if nobody wrote it before (like `m⁵` below);
conversion factors between prefixes and non-SI units
are computed at compile time too.
"""
nbCode:
  echo 1.m * 1.m * 1.m * 1.m * 1.m
  echo 5.kg + 500.g        # same quantity: converted
  echo 1.km / 20.min       # a new unit, km•min⁻¹
  echo (1.km / 20.min).to(m•s⁻¹)

nbText """
Adding two different quantities is not a wrong result,
it is a program that does not compile.
The `+` macro stops the compiler with the message
*Different quantities cannot be added!*, and functions
like `sqrt` only accept units that are perfect squares:
"""
nbCode:
  echo compiles(5.kg + 3.m)
  echo compiles(sqrt(4.m²))
  echo compiles(sqrt(4.m))

nbText """
Quantities like `Length` or `Mass` are
[concepts](https://nim-lang.org/docs/manual_experimental.html#concepts):
type classes that match any unit of that quantity.
A function can take any length and any mass,
but they have to be explicit generic parameters:
"""
nbCode:
  func density[M: Mass, L: Length](m: M, side: L): auto =
    m / side^3

  echo density(1.kg, 10.cm)
  echo density(1.kg, 10.cm).to(kg•m⁻³)

nbText """
## Declaring quantities and units

unchained itself is built with two macros.
`declareQuantities` lists the base quantities and the
derived ones, with their powers of the base quantities;
this is the start of unchained's `si_units.nim`:
"""
showCode(siUnitsSource.between("declareQuantities:", "    Torque:") &
  "\n    ...", "unchained's si_units.nim (excerpt)")

nbText """
`declareUnits` then gives each quantity its units: base
units first, then derived units, which can need a
conversion to the base ones:
"""
showCode(siUnitsSource.between("declareUnits:", "    Ampere:") &
  "\n    ...\n" &
  siUnitsSource.between("    AstronomicalUnit:", "    LightYear:") &
  "    ...", "unchained's si_units.nim (excerpt)")

nbText """
From these few lines the macros generate, at compile
time, the types and their aliases (`Meter`, `m`), the
SI prefixes (`km`, `mm`...), the concepts for the
quantities, and the tables that `*`, `/` and `.to` use
to compute units and conversion factors.
It is the same macro, `declareUnits`, that the talk
uses to add two units unchained does not have:
"""
showCode(newUnitsSource.between("declareUnits:", "# <<< new units"),
  "slides/island4_units.nim")
nbCode:
  echo 1.Msun.to(kg)
  echo 1.Msun / 1.Mearth # how many Earths in the Sun
  echo typeof(1.Msun / 1.Mearth)

nbText """
The ratio of two masses has no unit: `UnitLess`,
which converts to a plain float when needed.
A custom unit system can even start from scratch, with
its own quantities, as in unchained's
[example](https://github.com/SciNim/unchained/blob/master/examples/custom_unit_system.nim).
"""

nbText """
## Kepler's third law

A planet (or a moon) on an orbit with semi-major axis
$a$ around a body of mass $M$, much heavier than it,
goes around in a time
$$T = 2 \pi \sqrt{\frac{a^3}{G M}}$$
where $G$ is Newton's gravitational constant, in
unchained `G_Newton` (not `G`, which is the Giga
prefix).
Under the square root the units are
$\mathrm{m}^3 / (\mathrm{m}^3\,\mathrm{kg}^{-1}\,\mathrm{s}^{-2} \cdot \mathrm{kg}) = \mathrm{s}^2$,
so `sqrt` compiles and gives seconds:
"""
nbCode:
  func period[L: Length, M: Mass](a: L, mass: M): Second =
    (2 * PI * sqrt(a^3 / (G_Newton * mass))).to(Second)

  echo "Earth: ", period(1.AU, 1.Msun).to(day)
  echo "Mars: ", period(1.524.AU, 1.Msun).to(yr)
  echo "Jupiter: ", period(5.204.AU, 1.Msun).to(yr)
  echo "Moon: ", period(384_400.km, 1.Mearth).to(day)

nbText """
Astronomical units and kilometers, solar and Earth
masses, and Newton's constant in SI units all meet in
one formula, and the conversions are worked out by the
compiler.
The Earth comes out at about 365.25 days.
The Moon comes out at about 27.45 days, a bit more than
its real 27.32 days, because the formula leaves out the
mass of the Moon itself, which is not that small compared
to the Earth: with $G (M + m)$ in place of $G M$ the
match is better.
"""

nbText """
## Pitfalls

Nim identifiers are case insensitive after the first
letter, and ignore underscores.
With units that is a trap: the short name `kn` for a
knot would be the same identifier as `kN`, the
kilonewton, and on slide 5.3 our `pt` for points is the
same identifier as `pT`, the picotesla.
The slides import unchained without it
(`import unchained except pT`).

`declareUnits` also generates again the types of the
compound SI units (like `Meter•Second⁻¹`).
If those and unchained's are both visible, every use is
ambiguous, so our units live in their own module,
`slides/island4_units.nim`, and the slides import only
the four new names from it
(`from island4_units import SolarMass, Msun, EarthMass, Mearth`).
The `conversion:` of a unit has to be a literal
(`1.98847e30.kg`), not an expression.

These are the honest costs of a library that pushes
the compiler this far, and of a small ecosystem: few
people hit the corners before you.
"""

nbText """
## Try it

Add the mass of Jupiter, or the light year as a length
in your own unit system, and compute the period of
Io around Jupiter (421 700 km).
Clone [the
repository](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim)
and run `nim r slides/island4_units_explainer.nim`:
it builds this page in `docs/island4_units_explainer.html`.
The
[README](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim#readme)
explains how to install the dependencies.
"""
nbSave
