## The plant of Island 6: the curve of Nick Strayer's Shiny for Python app
## (shiny/plant/app.py), in Nim. Any backend: the app (island6_plant_app.nim)
## draws it in the browser (JavaScript), the deep dive plots it with ggplotnim
## when the page is built (C).
import std / math

type Plant* = object
  leafiness*, order*, waviness*: int
  simplicity*: float

proc linspace*(a, b: float, n: int): seq[float] =
  for i in 0 ..< n:
    result.add a + (b - a) * i.float / float(n - 1)

proc curve*(p: Plant): tuple[x, y: seq[float]] =
  for t in linspace(0, p.leafiness.float * PI / 2, 1000):
    result.x.add t * cos(t) ^ 3
    result.y.add p.order.float * t * sqrt(abs(cos(t))) +
      t * sin(p.simplicity * t) * cos(p.waviness.float * t)
