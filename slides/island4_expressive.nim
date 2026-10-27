import std / [math, strformat]
import nimib, nimiSlides
import nimib / highlight
import unchained
import ../my, island4_vectors
from island4_units import SolarMass, Msun, EarthMass, Mearth
export math, unchained, island4_vectors
export SolarMass, Msun, EarthMass, Mearth

# Section 5: Island 4: An Expressive Language (see the latest outline in openspec)
# Two language features that make Nim good for scientific use. Carries K2 (metaprogramming superpower).

proc newUnitsHtml: string =
  ## the declaration in island4_units.nim, between the markers, highlighted
  const source = staticRead("island4_units.nim")
  let code = source.split("# >>> new units\n")[1].split("# <<< new units")[0]
  &"""<pre style="width: 100%"><code class="nim hljs" data-noescape>{highlightNim(code.strip)}</code></pre>"""

template island4ExpressiveSection* =
  slide:
    mapSlide(4) # 5.1
    slide: # 5.2
      nbText "## Custom operators"
      nbTextSmall """
`Point + Point` is not a point:
let it be the line through them.
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
    slide: # 5.3
      nbText "## Where a line meets a plane"
      nbTextSmall """
The plane through three points, the line through two.
"""
      nbCode:
        let
          plane = pt(0, 0, 0) + pt(1, 0, 0) + pt(0, 1, 0)
          line = pt(1, 2, 3) + pt(2, 3, 1)
        echo line * plane
      nbTextSmall """
[Explained step by step here](island4_operators_explainer.html).
"""
      speakerNote """
Three points make a plane (here z = 0), two points a line,
and the line meets the plane in a point.
The code reads like geometry, and the types check it:
`plane * line` and `plane + pt(1, 1, 1)` do not compile.
The explainer goes through the math, the edge cases
(parallel lines give infinities) and the meet of two planes.
"""
    slide: # 5.4
      nbText "## Units with a macro"
      nbTextSmall """
[unchained](https://github.com/SciNim/unchained) by Vindaar:
units checked at compile time, plain floats at run time.
Its `declareUnits` macro adds two masses to SI:
"""
      nbRawHtml newUnitsHtml()
      nbTextSmall """
The macro writes the types, the aliases and the conversions;
`*`, `/` and `+` are macros that work out the unit of the result.
"""
      speakerNote """
A macro is Nim code that runs in the compiler and writes Nim code.
declareUnits reads this block and generates distinct float types
(SolarMass, EarthMass) with their short names and conversions.
The arithmetic operators are macros too: at compile time they
compute the unit of the result (and define its type if needed).
"""
    slide: # 5.5
      nbText "## Kepler's third law"
      nbTextSmall """
How long is a year, for a planet or a moon?
"""
      nbCode:
        func period[L: Length, M: Mass](a: L, mass: M): Second =
          (2 * PI * sqrt(a^3 / (G_Newton * mass))).to(Second)

        echo "Mars: ", period(1.524.AU, 1.Msun).to(yr)
        echo "Moon: ", period(384_400.km, 1.Mearth).to(day)
        echo compiles(1.AU + 1.Msun) # Length + Mass
      speakerNote """
Astronomical units, kilometers, solar and Earth masses
and Newton's constant in one formula, converted for us.
Length and Mass are concepts: any unit of that quantity fits.
sqrt only compiles for a unit that is a perfect square.
Adding a length to a mass is a compile time error.
"""
    placeholderSlide("5.6", "Rocks ahead", """with great power: macros can make code hard to read for newcomers; concepts (compile-time duck typing) were not robust until possibly recently.""")
