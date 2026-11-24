# Vandermonde benchmark — NumPy vs Julia vs Nim

Reproduction of the case study in section 2.1.1 and table 2.1 of Jeff Bezanson,
*Abstraction in Technical Computing* (MIT PhD thesis, 2015), extended with a Nim
implementation. It is supporting material for the talk, not part of the site
build: nothing here is compiled by `build.nim`, and the numbers are meant to be
re-measured on the machine that will be quoted on a slide. See
[notes/vandermonde-benchmark.md](../../notes/vandermonde-benchmark.md) for how it
fits the talk.

The benchmark computes `vander(x, N)` — the Vandermonde matrix of a vector `x` —
for 4·10⁶ total points, arranged either as many tiny matrices (4×4, 250 000
times) or as one big matrix (2000×2000, once). The small case measures *per-call
abstraction overhead*; the large case measures *inner-loop throughput*.

```
benchmarks/vander/
├── python/vander_bench.py   # thesis' copy of NumPy's user-level vander
├── julia/vander_bench.jl    # Figure 2-1, updated to Julia 1.x
├── nim/vander_bench.nim     # Nim port (static + dynamic-dispatch variants)
├── bench_table.py           # merges results/*.json into the table below
└── run_all.sh               # runs whatever toolchains are on PATH
```

## Results measured in this sandbox

Intel Xeon @ 2.10 GHz (1 vCPU, 260 MiB L3 — the whole 2000×2000 matrix, 32 MB,
fits in cache), Ubuntu 24.04, CPython 3.12.3 / NumPy 2.4.4, Nim 2.2.11 with GCC
13.3.0 (`-d:danger --mm:arc`). Each number is the best of 5 repetitions.

| implementation | 4×4 ×250 000 | 2000×2000 ×1 |
|---|---|---|
| numpy (thesis `vander`) | 0.699 s | 0.0147 s |
| numpy (`np.vander` builtin) | 0.784 s | 0.0145 s |
| **julia** | *not run here — see below* | |
| **julia (with dispatch)** | *not run here — see below* | |
| nim (static) | **0.0067 s** | **0.0032 s** |
| nim (with dispatch) | 0.0118 s | 0.0050 s |

All four implementations agree to the last bit on both checksums
(`Σvᵢⱼ = 16.088888888888889` for 4×4, `3.684802627825493e+84` for 2000×2000).

**Julia is missing because this sandbox cannot reach the Julia download servers.**
The egress proxy allows only `github.com`, `pypi.org`, `archive.ubuntu.com` and a
few others; `julialang-s3.julialang.org`, `install.julialang.org` and
`cache.julialang.org` all return `403 host_not_allowed`, GitHub carries only
Julia *source* tarballs (a from-source build is hours on one core), and Ubuntu
24.04 has no `julia` package. Nim installed fine from the `nim-lang/nightlies`
GitHub release assets. `julia/vander_bench.jl` is complete and writes the same
JSON as the others, so running `./run_all.sh` locally with `julia` on PATH fills
in the two missing rows.

For reference, the original thesis numbers (2015 hardware, Julia 0.3-era):

| Size | # iter | NumPy | Julia | Julia with dispatch |
|---|---|---|---|---|
| 4×4 | 250000 | 5.43 | 0.072 | 0.204 |
| 2000×2000 | 1 | 0.420 | 0.037 | 0.037 |

## What the numbers say

**Small matrices — the thesis' main point survives, amplified.** NumPy needs
~2.8 µs per `vander(x, 4)` call; Nim needs ~27 ns. That is a factor of ~104
(the thesis got 75× for Julia on 2015 hardware; NumPy itself has got 7.7× faster
in wall-clock terms since then, on a different machine). Essentially all of NumPy's time is interpreter dispatch,
argument normalisation, `promote_types`, view creation and ufunc setup — the 12
multiplications are noise. This is Bezanson's "abstraction overhead is important
and involves the whole program, not just inner loops".

**Large matrix — here my numbers diverge from the thesis.** In 2015 NumPy was
11× *slower* than Julia on 2000×2000; today it is only 4.6× slower than Nim, and
the gap is no longer dispatch at all. Breaking the 14.7 ms down: 1.6 ms to fill
the columns, 13.6 ms inside `multiply.accumulate` itself. The reason is loop
structure, not language:

- NumPy's array is row-major and `accumulate(..., axis=1)` runs along the
  *contiguous* axis, so each step depends on the previous one — a serial
  dependency chain that cannot be vectorised.
- The Julia/Nim version is column-major with the accumulation over `i`
  (columns) and the inner loop over `j` (rows). Successive inner-loop elements
  are independent, so GCC vectorises it: the disassembly of `vander` contains a
  packed `mulpd` (2-wide SSE2, the x86-64 baseline) plus a scalar tail.

Supporting evidence for the serial-chain reading: NumPy spends 13.6 ms on
4·10⁶ multiplies, i.e. 3.4 ns ≈ 7 cycles per element at 2.1 GHz — about what a
dependent chain of `mulsd` (4–5 cycle latency) plus load/store costs, and far
off what a bandwidth- or throughput-bound loop would give.

So the large-matrix column is mostly measuring "vectorisable loop vs serial
dependency", which is worth flagging if you reuse this in a talk. Compiling Nim
with `--passC:-march=native --passC:-flto` changes nothing measurable (0.0030 s),
confirming the loop is already memory/dependency-bound rather than ISA-bound.

**The dispatch column.** `nim (with dispatch)` costs +76% on the small case
(+20 ns/call) and +56% on the large one. The Nim version hides the matrix behind
a base class so the element type is unknown at the call site; each `accumulate`
call goes through one `method` dispatch and then runs a fully specialised loop —
the "single layer of dispatch" the thesis describes.

The large case deserves a caveat: Julia's table shows 0.037 → 0.037, i.e. one
dispatch amortised to nothing, and one dispatch obviously cannot account for
Nim's +1.8 ms either. The real cause is a knock-on effect — because the loop now
lives inside a `method` body rather than inlined into `vander`, GCC no longer
versions it against aliasing and emits scalar `mulsd` instead of packed `mulpd`
(confirmed in the disassembly). So the Nim dispatch row on the large matrix is
measuring lost vectorisation, not dispatch.

## Reproducing locally

```bash
cd benchmarks/vander
./run_all.sh          # runs every toolchain it finds, prints the table
```

### Python

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install numpy
cd python && python3 vander_bench.py     # writes results_python.json
```

### Julia

```bash
curl -fsSL https://install.julialang.org | sh     # juliaup
# or grab a tarball from https://julialang.org/downloads/
exec $SHELL
cd julia && julia -O3 --check-bounds=no vander_bench.jl   # writes results_julia.json
```

No packages needed — only stdlib `Printf`. The script warms up each function
before timing, so JIT compilation is not counted.

### Nim

```bash
curl https://nim-lang.org/choosenim/init.sh -sSf | sh     # or: apt install nim
cd nim
nim c -d:danger --mm:arc -o:vander_bench vander_bench.nim
./vander_bench                            # writes results_nim.json
```

If, like this sandbox, you can only reach GitHub, the nightly tarballs work as a
drop-in:

```bash
curl -L -o nim.tar.xz \
  https://github.com/nim-lang/nightlies/releases/download/latest-version-2-2/linux_x64.tar.xz
tar -xJf nim.tar.xz && export PATH="$PWD/nim-2.2.11/bin:$PATH"
```

Then merge whatever you have:

```bash
python3 bench_table.py results
```

## Benchmark design notes

- **Input.** `x[i] = 0.9 + 0.2·i/(M−1)`, identical in all three languages —
  deterministic, and chosen so `x^2000` stays inside Float64's normal range (no
  overflow, no denormals, which would otherwise distort the large-matrix timing).
  Element type is Float64, so `promote_type(eltype(x), Int)` is Float64.
- **Protocol.** Best of 5 repetitions; wall clock (`perf_counter`, `time_ns`,
  `getMonoTime`). Each timed iteration includes the allocation of the output
  matrix, as in the thesis. Every implementation touches `v[M,N]` after each call
  so nothing can be dead-code eliminated.
- **Allocation parity.** NumPy `empty`, Julia `Array{T}(undef, …)` and Nim
  `newSeqUninit` all leave memory uninitialised; every element is written before
  it is read. (Using Nim's zero-filling `newSeq` instead costs ~45% on the large
  case — worth knowing.)
- **Structural parity.** The thesis' `v[:, i] = x` column assignments are written
  as explicit loops in all three languages so that each does the same work.
- **Nim static variant.** `accumulate` takes the operation as a
  `static proc(a, b: T): T {.nimcall, inline.}` parameter, so it is specialised
  and inlined at compile time — the equivalent of Julia specialising on the
  singleton type of `multiply`. The matrix is column-major, so the inner loop
  over rows is contiguous, matching the Julia version exactly.
- **Nim dispatch variant.** `AbstractMatrix` base class with `MatrixF64` /
  `MatrixI64` subclasses and `method accumulateMul` — real virtual dispatch (two
  subtypes exist, so it cannot be devirtualised), once per call, then a
  monomorphic loop.
- **Julia dispatch variant.** `Ref{Any}(v)[]` as inference barrier, so the call
  to `myaccumulate!` is resolved at run time; the method that runs is still fully
  specialised. `accumulate` is renamed `myaccumulate!` because Base exports
  `accumulate` in Julia 1.x.

## Caveats

- The Julia file is written for Julia 1.x but has **not been executed** — I had
  no interpreter to run it against. It is short and stdlib-only, but treat the
  first local run as a smoke test.
- Single-vCPU cloud VM with an unusually large L3; absolute numbers will differ
  on a laptop, and the 2000×2000 case in particular will look worse everywhere
  once the matrix stops fitting in cache. Ratios within one machine are the
  meaningful part.
- NumPy 2.4 is far from the NumPy the thesis measured; the *shape* of the result
  (huge per-call overhead, competitive inner loop) is what carries over, not the
  magnitudes.
