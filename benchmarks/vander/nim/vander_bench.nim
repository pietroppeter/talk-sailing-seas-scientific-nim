## Vandermonde benchmark, Nim version.
##
## Mirrors Figure 2-1 ("Julia implementation of vander") from
## Jeff Bezanson, "Abstraction in Technical Computing" (MIT, 2015),
## as closely as Nim allows, plus a variant that reproduces the
## "with dispatch" column of table 2.1.
##
## Build:
##   nim c -d:danger --mm:arc -o:vander_bench vander_bench.nim

import std/[monotimes, times, strformat, json, math]

# ---------------------------------------------------------------------------
# A minimal column-major matrix, so that the inner loop of `accumulate`
# walks contiguous memory exactly like the Julia version does.
# ---------------------------------------------------------------------------

type
  Matrix*[T] = object
    m*, n*: int
    data*: seq[T]

proc newMatrix*[T](m, n: int): Matrix[T] {.inline.} =
  # uninitialised, like Julia's `Array{T}(undef, M, N)` and NumPy's `empty`:
  # every element is written before it is read
  Matrix[T](m: m, n: n, data: newSeqUninit[T](m * n))

template `[]`*[T](a: Matrix[T], i, j: int): T =
  a.data[(j) * a.m + (i)]

template `[]=`*[T](a: var Matrix[T], i, j: int, val: T) =
  a.data[(j) * a.m + (i)] = val

# ---------------------------------------------------------------------------
# Static version: the element type and the operation are both known at
# compile time, so `op` is inlined into the loop.  This is the analogue of
# the plain "Julia" column.
# ---------------------------------------------------------------------------

func multiply*[T](a, b: T): T {.inline.} = a * b

proc accumulate*[T](op: static proc(a, b: T): T {.nimcall, inline.},
                    input: Matrix[T], output: var Matrix[T]) =
  let m = input.m
  let n = input.n
  for i in 1 ..< n:
    for j in 0 ..< m:
      output[j, i] = op(input[j, i], input[j, i - 1])

proc vander*[T](x: openArray[T], n: int): Matrix[T] =
  let m = x.len
  var v = newMatrix[T](m, n)
  if n > 0:
    for j in 0 ..< m:
      v[j, 0] = T(1)
  if n > 1:
    for i in 1 ..< n:
      for j in 0 ..< m:
        v[j, i] = x[j]
    accumulate(multiply[T], v, v)
  return v

# ---------------------------------------------------------------------------
# Dynamic-dispatch version: the analogue of "Julia with dispatch".
#
# The matrix is hidden behind a base class, so the element type is *not*
# known at the call site.  Each call to `accumulate` performs one runtime
# dispatch, which then runs a fully specialised inner loop -- i.e. exactly
# one layer of dispatch, as in the thesis.
# ---------------------------------------------------------------------------

type
  AbstractMatrix* = ref object of RootObj
    m*, n*: int
  MatrixF64* = ref object of AbstractMatrix
    data*: seq[float64]
  MatrixI64* = ref object of AbstractMatrix
    data*: seq[int64]

method accumulateMul*(a: AbstractMatrix) {.base.} =
  raise newException(ValueError, "no method for this matrix type")

method accumulateMul*(a: MatrixF64) =
  for i in 1 ..< a.n:
    for j in 0 ..< a.m:
      a.data[i * a.m + j] = a.data[i * a.m + j] * a.data[(i - 1) * a.m + j]

method accumulateMul*(a: MatrixI64) =
  for i in 1 ..< a.n:
    for j in 0 ..< a.m:
      a.data[i * a.m + j] = a.data[i * a.m + j] * a.data[(i - 1) * a.m + j]

method fill1*(a: AbstractMatrix) {.base.} = discard
method fill1*(a: MatrixF64) =
  for j in 0 ..< a.m: a.data[j] = 1.0
method fill1*(a: MatrixI64) =
  for j in 0 ..< a.m: a.data[j] = 1'i64

proc vanderDyn*(x: openArray[float64], n: int): AbstractMatrix =
  let m = x.len
  # `v` is statically only an AbstractMatrix from here on
  var v: AbstractMatrix = MatrixF64(m: m, n: n, data: newSeqUninit[float64](m * n))
  if n > 0:
    v.fill1()
  if n > 1:
    let mf = MatrixF64(v)
    for i in 1 ..< n:
      for j in 0 ..< m:
        mf.data[i * m + j] = x[j]
    v.accumulateMul()
  return v

# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

proc makeX(m: int): seq[float64] =
  result = newSeq[float64](m)
  for i in 0 ..< m:
    result[i] = if m == 1: 1.0 else: 0.9 + 0.2 * float64(i) / float64(m - 1)

proc checksum(v: Matrix[float64]): float64 =
  for a in v.data: result += a

proc checksumDyn(v: AbstractMatrix): float64 =
  let mf = MatrixF64(v)
  for a in mf.data: result += a

proc main() =
  var results = newJArray()
  const reps = 5
  let cases = @[(4, 250_000), (2000, 1)]

  for (m, iters) in cases:
    let x = makeX(m)

    # --- static ---
    block:
      var best = Inf
      var chk = 0.0
      for r in 0 ..< reps:
        let t0 = getMonoTime()
        var acc = 0.0
        for it in 0 ..< iters:
          let v = vander(x, m)
          # touch the last element: forces the allocation, the fill and the
          # whole accumulate loop to actually happen (defeats dead-code
          # elimination)
          acc += v[m - 1, m - 1]
        let dt = (getMonoTime() - t0).inNanoseconds.float64 / 1e9
        if dt < best: best = dt
        chk = checksum(vander(x, m))
        doAssert acc >= 0.0
      results.add %*{"impl": "nim (static)", "size": m, "iters": iters,
                     "seconds": best, "checksum": chk}
      stderr.writeLine &"nim (static)          {m}x{m} x{iters:<7} {best:9.4f} s  checksum={chk:.10e}"

    # --- dynamic dispatch ---
    block:
      var best = Inf
      var chk = 0.0
      for r in 0 ..< reps:
        let t0 = getMonoTime()
        var acc = 0.0
        for it in 0 ..< iters:
          let v = vanderDyn(x, m)
          acc += MatrixF64(v).data[(m - 1) * m + (m - 1)]
        let dt = (getMonoTime() - t0).inNanoseconds.float64 / 1e9
        if dt < best: best = dt
        chk = checksumDyn(vanderDyn(x, m))
        doAssert acc >= 0.0
      results.add %*{"impl": "nim (with dispatch)", "size": m, "iters": iters,
                     "seconds": best, "checksum": chk}
      stderr.writeLine &"nim (with dispatch)   {m}x{m} x{iters:<7} {best:9.4f} s  checksum={chk:.10e}"

  writeFile("results_nim.json",
            pretty(%*{"runtime": "Nim " & NimVersion, "results": results}))

when isMainModule:
  main()
