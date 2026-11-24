# The Vandermonde matrix with for loops in Nim.
# Run by run.sh: `vander_nim <case> <m> <n> <calls> <repeat>` times `calls` calls of vander
# on m points with n columns, best of `repeat`, and prints one CSV line, as vander.py does.
import std / [monotimes, times, sequtils, strutils, strformat, os, math]

# >>> vander
proc vander(x: seq[float], n: int): seq[seq[float]] =
  var v = newSeqWith(x.len, repeat(1.0, n))
  for i in 0 ..< x.len:
    for j in 1 ..< n:
      v[i][j] = v[i][j-1] * x[i]
  v
# <<< vander

let
  label = paramStr(1)
  (m, n, calls, repeat) = (paramStr(2).parseInt, paramStr(3).parseInt,
                           paramStr(4).parseInt, paramStr(5).parseInt)
  x = toSeq(0 ..< m).mapIt(0.9 + 0.2 * it.float / m.float)

var
  best = int64.high
  v: seq[seq[float]]
for _ in 1 .. repeat:
  let start = getMonoTime()
  for _ in 1 .. calls:
    v = vander(x, n)
  best = min(best, (getMonoTime() - start).inNanoseconds)
let total = sum(v.mapIt(sum(it)))
echo &"{label},Nim loops,{best.float / 1e6:.4f},{total:.6f}"
