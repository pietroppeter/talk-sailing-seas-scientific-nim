#!/usr/bin/env python3
"""Has Rust got faster? Has Nim got slower? The same generated program (gen.py, the project
"same" of run.py) compiled by older toolchains next to today's, on the same machine.

  Rust: 1.24 (Feb 2018, incremental compilation on by default), 1.40 (Dec 2019),
        1.60 (Apr 2022) and the current stable, installed with rustup
  Nim:  1.6 (the Ubuntu package, /usr/bin/nim) and the current nim on the PATH

Writes history.csv next to this script; the deep dive deepdive/compile_times.nim reads it.

  rustup toolchain install 1.24.0 1.40.0 1.60.0 --profile minimal
  apt-get install nim            # Nim 1.6.14 on Ubuntu 24.04, in /usr/bin
  python3 bench/compiletimes/history.py
"""
import shutil, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import run, gen

RUST = ["1.24.0", "1.40.0", "1.60.0", "stable"]
OLD_NIM = "/usr/bin/nim"


def first(s):
    return s.strip().splitlines()[0]


def main():
    src = run.WORK / "src" / "history"
    if not src.exists():
        gen.generate(src)
        # no edition key: Rust 1.24 and 1.40 do not know the 2021 edition (the code is the same in 2015)
        toml = src / "rust" / "Cargo.toml"
        toml.write_text(toml.read_text().replace('edition = "2021"\n', ""))
    out = run.WORK / "out"
    out.mkdir(exist_ok=True)
    cargoflags = {"debug": "", "release": "--release"}
    nimflags = {"debug": "", "release": "-d:release"}
    builds = {}
    for t in RUST:
        v = first(run.sh(f"rustc +{t} --version")).split()[1]
        builds[f"Rust {v}"] = dict(dir=src / "rust", file=src / "rust/src/main.rs", lit="Hello, sailor!",
            cmd=lambda m, c, t=t: f"cargo +{t} build -q {cargoflags[m]}",
            env=lambda c: {"CARGO_TARGET_DIR": str(c)})  # cargo 1.24 has no --target-dir
    for nim in [OLD_NIM, "nim"]:
        v = first(run.sh(f"{nim} --version")).split()[3]
        builds[f"Nim {v}"] = dict(dir=src / "nim", file=src / "nim/main.nim", lit="Hello, sailor!",
            cmd=lambda m, c, nim=nim: f"{nim} c --hints:off {nimflags[m]} --nimcache:{c} -o:{out}/history_nim_{m} main.nim")
    rows = []
    for name, b in builds.items():
        for mode in ["debug", "release"]:
            for r in run.measure(name, "same", b, mode):
                print(*r, sep=",", flush=True)
                rows.append(",".join([*r[:4], *(f"{x:.2f}" for x in r[4:])]))
    with open(run.HERE / "history.csv", "w") as f:
        f.write("toolchain,project,mode,scenario,median_s,min_s,max_s\n")
        f.write("\n".join(rows) + "\n")


if __name__ == "__main__":
    main()
