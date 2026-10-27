import std / strformat

# Island 4 helper: points and vectors in space,
# used by the custom operators example (slide 5.2).
# `∙` (dot product) and `×` (cross product) are custom operators too:
# Nim accepts a set of unicode operator symbols.

type
  Point* = object
    x*, y*, z*: float
  Vec* = object
    x*, y*, z*: float

func pt*(x, y, z: float): Point = Point(x: x, y: y, z: z)
func `$`*(p: Point): string = &"({p.x:.2f}, {p.y:.2f}, {p.z:.2f})"

func `-`*(a, b: Point): Vec = Vec(x: a.x - b.x, y: a.y - b.y, z: a.z - b.z)
func `+`*(p: Point, v: Vec): Point = pt(p.x + v.x, p.y + v.y, p.z + v.z)
func `*`*(t: float, v: Vec): Vec = Vec(x: t * v.x, y: t * v.y, z: t * v.z)
func `∙`*(u, v: Vec): float = u.x * v.x + u.y * v.y + u.z * v.z
func `×`*(u, v: Vec): Vec =
  Vec(x: u.y * v.z - u.z * v.y,
      y: u.z * v.x - u.x * v.z,
      z: u.x * v.y - u.y * v.x)
