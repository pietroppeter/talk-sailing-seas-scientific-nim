"""Vandermonde benchmark, NumPy version.

Reproduces section 2.1.1 ("Case study: Vandermonde matrices") of
Jeff Bezanson, "Abstraction in Technical Computing" (MIT, 2015), table 2.1.

The `vander` function below is the thesis' lightly-edited copy of NumPy's
user-level implementation.
"""

import sys
import time
import json

import numpy as np
from numpy import asarray, empty, promote_types, multiply


# --- the implementation as printed in the thesis (section 2.1.1) -------------
def vander(x, N):
    x = asarray(x)
    if x.ndim != 1:
        raise ValueError("x must be a one-dimensional array or sequence.")

    v = empty((len(x), N), dtype=promote_types(x.dtype, int))

    if N > 0:
        v[:, 0] = 1
    if N > 1:
        v[:, 1:] = x[:, None]
        multiply.accumulate(v[:, 1:], out=v[:, 1:], axis=1)

    return v


# --- deterministic input, identical in all three languages -------------------
def make_x(m):
    # values in [0.9, 1.1] so that x^2000 stays inside the normal range of
    # Float64 (no overflow, no denormals -> no timing artefacts)
    if m == 1:
        return np.array([1.0])
    return np.array([0.9 + 0.2 * i / (m - 1) for i in range(m)])


def bench(fn, x, n, iters, reps):
    best = float("inf")
    checksum = 0.0
    for _ in range(reps):
        t0 = time.perf_counter()
        for _ in range(iters):
            v = fn(x, n)
        t1 = time.perf_counter()
        best = min(best, t1 - t0)
        checksum = float(v.sum())
    return best, checksum


def main():
    results = []
    cases = [(4, 250_000, 5), (2000, 1, 5)]

    for m, iters, reps in cases:
        x = make_x(m)
        for label, fn in (("numpy (thesis vander)", vander),
                          ("numpy (np.vander builtin)",
                           lambda x, n: np.vander(x, n, increasing=True))):
            secs, chk = bench(fn, x, m, iters, reps)
            results.append(dict(impl=label, size=m, iters=iters,
                                seconds=secs, checksum=chk))
            print(f"{label:28s} {m}x{m} x{iters:<7d} {secs:9.4f} s  "
                  f"checksum={chk:.10e}", file=sys.stderr)

    with open("results_python.json", "w") as f:
        json.dump(dict(runtime=f"CPython {sys.version.split()[0]} / "
                               f"NumPy {np.__version__}",
                       results=results), f, indent=2)


if __name__ == "__main__":
    main()
