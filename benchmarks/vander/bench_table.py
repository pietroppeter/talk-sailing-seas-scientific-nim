#!/usr/bin/env python3
"""Merge results_*.json produced by the three benchmarks into one table."""

import glob
import json
import os
import sys

ORDER = [
    "numpy (thesis vander)",
    "numpy (np.vander builtin)",
    "julia",
    "julia (with dispatch)",
    "nim (static)",
    "nim (with dispatch)",
]


def main(resdir="results"):
    rows = {}
    runtimes = []
    for path in sorted(glob.glob(os.path.join(resdir, "results_*.json"))):
        with open(path) as f:
            blob = json.load(f)
        runtimes.append(blob["runtime"])
        for r in blob["results"]:
            rows.setdefault(r["impl"], {})[r["size"]] = r
    if not rows:
        print(f"no results_*.json found in {resdir}/", file=sys.stderr)
        return 1

    sizes = sorted({s for v in rows.values() for s in v})
    keys = [k for k in ORDER if k in rows] + [k for k in rows if k not in ORDER]

    header = ["implementation"] + [f"{s} x {s}" for s in sizes] + ["checksum (4x4)"]
    print("| " + " | ".join(header) + " |")
    print("|" + "|".join(["---"] * len(header)) + "|")
    for k in keys:
        cells = [k]
        for s in sizes:
            r = rows[k].get(s)
            cells.append(f"{r['seconds']:.4f} s" if r else "-")
        c4 = rows[k].get(sizes[0])
        cells.append(f"{c4['checksum']:.12g}" if c4 else "-")
        print("| " + " | ".join(cells) + " |")

    print()
    for rt in runtimes:
        print(f"* {rt}")
    return 0


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:]))
