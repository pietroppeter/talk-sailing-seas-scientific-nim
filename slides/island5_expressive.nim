import std / [math, strformat]
import nimib, nimiSlides
import nimib / highlight
# `pT` (picotesla) would clash with `pt` (slide 6.3):
# identifiers are case insensitive after the first letter
import unchained except pT
import ../my, island5_vectors
from island5_units import SolarMass, Msun, EarthMass, Mearth
export math, island5_vectors
export unchained except pT
export SolarMass, Msun, EarthMass, Mearth

# Section 6: Island 5: An Expressive Language (see the latest outline in openspec)
# Two language features that make Nim good for scientific use. Carries K2 (metaprogramming superpower).

func codeHtml(code: string): string =
  &"""<pre style="width: 100%"><code class="nim hljs" data-noescape>{highlightNim(code.strip)}</code></pre>"""

proc newUnitsHtml: string =
  ## the declaration in island5_units.nim, between the markers, highlighted
  const source = staticRead("island5_units.nim")
  let code = source.split("# >>> new units\n")[1].split("# <<< new units")[0]
  codeHtml(code)

proc siUnitsHtml: string =
  ## some SI base units as unchained declares them in its si_units.nim
  ## (read from the dependency at build time, comments dropped)
  const source = staticRead("../deps/unchained/src/unchained/si_units.nim")
  var code = "declareUnits:\n  BaseUnits:\n"
  for unit in ["Gram", "Meter"]:
    let lines = source.split("\n    " & unit & ":\n")[1].splitLines
    code.add "    " & unit & ":\n"
    for line in lines:
      if not line.startsWith("      "): break
      code.add line.split(" #")[0] & "\n"
  code.add "    ..."
  codeHtml(code)

template island5ExpressiveSection* =
  slide:
    mapSlide(5) # 6.1
    slide: # 6.2
      nbText "## Custom Operators: defined"
      nbTextSmall """
You can define custom operators easily in Nim,
as a normal function, using backticks.
"""
      nbCode:
        type
          Line = object   # through p, along d
            p: Point
            d: Vec
          Plane = object  # through p, normal n
            p: Point
            n: Vec

        func `+`(a, b: Point): Line = Line(p: a, d: b - a)
        func `+`(l: Line, c: Point): Plane =
          Plane(p: l.p, n: l.d × (c - l.p))
        func `*`(l: Line, s: Plane): Point =
          l.p + ((s.p - l.p) ∙ s.n) / (l.d ∙ s.n) * l.d
      speakerNote """
Points, vectors, dot (∙) and cross (×) products
are a few lines in a helper module:
unicode operators are custom operators too.
`+` joins (two points make a line, a line and a point a plane),
`*` meets (a line hits a plane in a point).
"""
    slide: # 6.3
      nbText "## Custom Operators: applied"
      nbTextSmall """
A line is defined by two points,
a plane is defined by three points,
they generically intersect in one point.
"""
      nbCode:
        func pt(x, y, z: float): Point = Point(x: x, y: y, z: z)

        let
          line = pt(1, 2, 3) + pt(2, 3, 1)
          plane = pt(0, 0, 0) + pt(1, 0, 0) + pt(0, 1, 0)
        echo line * plane
      nbTextSmall """
[Explained step by step here](island5_operators_explainer.html).
"""
      speakerNote """
Two points make a line, three points a plane (here z = 0),
and the line meets the plane in a point.
The code reads like geometry, and the types check it:
`plane * line` and `plane + pt(1, 1, 1)` do not compile.
The explainer goes through the math, the edge cases
(parallel lines give infinities) and the meet of two planes.
"""
    slide: # 6.4
      nbText "## Macros to define Units"
      nbTextSmall """
[unchained](https://github.com/SciNim/unchained) by Vindaar:
units checked at compile time, plain floats at run time.
Its `declareUnits` macro declares the SI units,
and provides an API to add your own units:
"""
      columns:
        column:
          nbRawHtml siUnitsHtml()
        column:
          nbRawHtml newUnitsHtml()
      nbTextSmall """
The macro writes the types, the aliases and the conversions;
`*`, `/` and `+` are macros that work out the unit of the result.
"""
      speakerNote """
Left: two SI base units as unchained declares them (its si_units.nim),
right: our two new units (slides/island5_units.nim).
Our own units here: SolarMass and EarthMass (right column).
A macro is Nim code that runs in the compiler and writes Nim code.
declareUnits reads this block and generates distinct float types
(SolarMass, EarthMass) with their short names and conversions.
The arithmetic operators are macros too: at compile time they
compute the unit of the result (and define its type if needed).
"""
    slide: # 6.5
      nbText "## Units applied"
      nbTextSmall """
Kepler's third law:
how long is a year, for a planet or a moon?
"""
      nbCode:
        func period[L: Length, M: Mass](a: L, mass: M): Second =
          (2 * PI * sqrt(a^3 / (G_Newton * mass))).to(Second)

        echo "Mars: ", period(1.524.AU, 1.Msun).to(yr)
        echo "Moon: ", period(384_400.km, 1.Mearth).to(day)
        echo compiles(1.AU + 1.Msun) # Length + Mass
      nbTextSmall """
[Explained step by step here](island5_units_explainer.html).
"""
      speakerNote """
Astronomical units, kilometers, solar and Earth masses
and Newton's constant in one formula, converted for us.
Length and Mass are concepts: any unit of that quantity fits.
sqrt only compiles for a unit that is a perfect square.
Adding a length to a mass is a compile time error.
"""
    placeholderSlide("6.6", "Rocks ahead", """with great power: macros can make code hard to read for newcomers; concepts (compile-time duck typing) were not robust until possibly recently.""")
