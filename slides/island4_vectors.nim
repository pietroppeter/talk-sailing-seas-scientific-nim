import std / strformat

# Island 4 helper: points and vectors in space,
# used by the custom operators example (slide 5.2).
# `∙` (dot product) and `×` (cross product) are custom operators too:
# Nim accepts a set of unicode operator symbols.

# A vector has the same coordinates as a point, but it is a distinct type:
# it borrows field access (`.`) and `$`, and nothing else from Point.

type
  Point* = object
    x*, y*, z*: float
  Vec* {.borrow: `.`.} = distinct Point

func pt*(x, y, z: float): Point = Point(x: x, y: y, z: z)
func vec*(x, y, z: float): Vec = Vec(pt(x, y, z))
func `$`*(p: Point): string = &"({p.x:.2f}, {p.y:.2f}, {p.z:.2f})"
func `$`*(v: Vec): string {.borrow.}

func `-`*(a, b: Point): Vec = vec(a.x - b.x, a.y - b.y, a.z - b.z)
func `+`*(p: Point, v: Vec): Point = pt(p.x + v.x, p.y + v.y, p.z + v.z)
func `*`*(t: float, v: Vec): Vec = vec(t * v.x, t * v.y, t * v.z)
func `∙`*(u, v: Vec): float = u.x * v.x + u.y * v.y + u.z * v.z
func `×`*(u, v: Vec): Vec =
  vec(u.y * v.z - u.z * v.y,
      u.z * v.x - u.x * v.z,
      u.x * v.y - u.y * v.x)
