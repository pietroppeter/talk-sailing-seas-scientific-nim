#!/usr/bin/env python3
"""Compile times of Nim, Rust, Go and Zig, for the deep dive deepdive/compile_times.nim.

Three projects per language:
  hello: a hello world (hello/)
  same:  the same generated program in the four languages (gen.py: 50 modules,
         5000 small functions), the one like-for-like comparison
  mid:   a real mid-size program, with its dependencies
         Nim:  the Nim compiler itself (compiler/nim.nim, from the installed Nim)
         Rust: ripgrep 16.0.0 (from crates.io)
         Go:   fzf v0.75.0 (from the Go module proxy)
         Zig:  translate-c with its C front-end aro (shipped in Zig's lib/compiler)
Scenarios, each in debug and in release mode:
  clean:    no build cache of the project (the toolchain's own caches stay warm)
  rebuild:  one string literal changed in one source file of the project
  nochange: build again with nothing changed (mid only)
Median of a few runs, wall-clock seconds. Writes results.csv, sizes.csv, same.csv and machine.txt
next to this script; the deep dive reads them when it is built. Needs nim, cargo, go,
zig and a network connection the first time (crates.io, the Go proxy):

  python3 bench/compiletimes/run.py          # everything (about 40 minutes on 4 cores)
  python3 bench/compiletimes/run.py hello    # only the hello worlds (or same, or mid)
  python3 bench/compiletimes/run.py "Nim clang"   # only one language (Nim, Nim clang, Rust, Go, Zig)
"""
import json, os, shutil, statistics, subprocess, sys, time, urllib.request, tarfile, io, re, platform
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen  # the generated program of the project "same"

HERE = Path(__file__).resolve().parent
WORK = HERE / "work"  # gitignored: sources, caches, binaries
RUNS = {"hello": 5, "same": 3, "mid": 3}
RIPGREP = "16.0.0"
FZF = "v0.75.0"


def sh(cmd, cwd=None, env=None):
    e = dict(os.environ, **(env or {}))
    r = subprocess.run(cmd, cwd=cwd, env=e, shell=True, capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit(f"failed: {cmd}\n{r.stdout[-2000:]}\n{r.stderr[-2000:]}")
    return r.stdout


def timed(cmd, cwd=None, env=None):
    t = time.perf_counter()
    sh(cmd, cwd, env)
    return time.perf_counter() - t


def nim_dir():
    # nim dump writes its JSON on stdout or stderr (when stdout is a terminal)
    out = sh("nim dump --dump.format:json --hints:off x 2>&1")
    return Path(json.loads(out[out.index("{"):])["libpath"]).parent


def zig_lib():
    # zig env writes ZON; lib_dir can be relative to the current directory
    return Path.cwd() / re.search(r'\.lib_dir = "(.*)"', sh("zig env")).group(1)


# --- sources ---------------------------------------------------------------

def prepare():
    WORK.mkdir(exist_ok=True)
    src = WORK / "src"
    src.mkdir(exist_ok=True)
    # hello worlds: copied, so that the edits do not touch the repository
    if not (src / "hello").exists():
        shutil.copytree(HERE / "hello", src / "hello")
    # the Nim compiler, with the dist/ it imports (checksums)
    if not (src / "nim").exists():
        nd = nim_dir()
        (src / "nim").mkdir()
        shutil.copytree(nd / "compiler", src / "nim" / "compiler")
        shutil.copytree(nd / "dist", src / "nim" / "dist")
    # ripgrep, from crates.io (the crate has its Cargo.lock)
    rg = src / f"ripgrep-{RIPGREP}"
    if not rg.exists():
        url = f"https://static.crates.io/crates/ripgrep/ripgrep-{RIPGREP}.crate"
        data = urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "compile-times-bench"})).read()
        tarfile.open(fileobj=io.BytesIO(data)).extractall(src, filter="data")
        sh("cargo fetch", cwd=rg)
    # fzf, from the Go module proxy
    fz = src / "fzf"
    if not fz.exists():
        info = json.loads(sh(f"go mod download -json github.com/junegunn/fzf@{FZF}"))
        shutil.copytree(info["Dir"], fz)
        sh(f"chmod -R u+w {fz}")
        sh("go mod download", cwd=fz)
    # translate-c and aro, from Zig's lib/compiler, with a build.zig of ours
    tc = src / "translate-c"
    if not tc.exists():
        zl = zig_lib() / "compiler"
        tc.mkdir()
        shutil.copytree(zl / "aro", tc / "aro")
        shutil.copytree(zl / "translate-c", tc / "translate-c")
        shutil.copy(zl / "util.zig", tc / "util.zig")
        for f in ["build.zig", "root.zig"]:
            shutil.copy(HERE / "translate-c" / f, tc / f)
    # the same program in the four languages, generated (gen.py)
    if not (src / "same").exists():
        lines = gen.generate(src / "same")
        with open(HERE / "same.csv", "w") as f:
            f.write(f"lang,lines,modules,functions\n")
            for lang, n in lines.items():
                f.write(f"{lang},{n},{gen.MODULES},{gen.MODULES * gen.FUNCS}\n")
    return src


# --- the builds ------------------------------------------------------------
# each build: (source dir, file edited for a rebuild, literal to change,
#              command(mode, cache dir), env(mode, cache dir))

def builds(src):
    out = WORK / "out"
    out.mkdir(exist_ok=True)
    nimflags = {"debug": "", "release": "-d:release"}
    cargoflags = {"debug": "", "release": "--release"}
    goflags = {"debug": '-gcflags=all="-N -l"', "release": ""}
    zigmode = {"debug": "Debug", "release": "ReleaseFast"}
    h = src / "hello"
    sm = src / "same"
    bs = {
        ("Nim", "same"): dict(
            dir=sm / "nim", file=sm / "nim/main.nim", lit="Hello, sailor!",
            cmd=lambda m, c: f"nim c --hints:off {nimflags[m]} --nimcache:{c} -o:{out}/same_nim_{m} main.nim"),
        ("Rust", "same"): dict(
            dir=sm / "rust", file=sm / "rust/src/main.rs", lit="Hello, sailor!",
            cmd=lambda m, c: f"cargo build -q {cargoflags[m]} --target-dir {c}"),
        ("Go", "same"): dict(
            dir=sm / "go", file=sm / "go/main.go", lit="Hello, sailor!",
            cmd=lambda m, c: f"go build {goflags[m]} -o {out}/same_go_{m} .",
            env=lambda c: {"GOCACHE": str(c)}),
        ("Zig", "same"): dict(
            dir=sm / "zig", file=sm / "zig/main.zig", lit="Hello, sailor!",
            cmd=lambda m, c: f"zig build-exe -O {zigmode[m]} --cache-dir {c} -femit-bin={out}/same_zig_{m} main.zig"),
        ("Nim", "hello"): dict(
            dir=h, file=h / "hello.nim", lit="Hello, sailor!",
            cmd=lambda m, c: f"nim c --hints:off {nimflags[m]} --nimcache:{c} -o:{out}/hello_nim_{m} hello.nim"),
        ("Rust", "hello"): dict(
            dir=h / "rust", file=h / "rust/src/main.rs", lit="Hello, sailor!",
            cmd=lambda m, c: f"cargo build -q {cargoflags[m]} --target-dir {c}"),
        ("Go", "hello"): dict(
            dir=h / "go", file=h / "go/main.go", lit="Hello, sailor!",
            cmd=lambda m, c: f"go build {goflags[m]} -o {out}/hello_go_{m} .",
            env=lambda c: {"GOCACHE": str(c)}),
        ("Zig", "hello"): dict(
            dir=h / "zig", file=h / "zig/hello.zig", lit="Hello, sailor!",
            cmd=lambda m, c: f"zig build-exe -O {zigmode[m]} --cache-dir {c} -femit-bin={out}/hello_zig_{m} hello.zig"),
        ("Nim", "mid"): dict(
            dir=src / "nim", file=src / "nim/compiler/commands.nim", lit="by Andreas Rumpf",
            cmd=lambda m, c: f"nim c --hints:off --warnings:off {nimflags[m]} --nimcache:{c} -o:{out}/nim_{m} compiler/nim.nim"),
        ("Rust", "mid"): dict(
            dir=src / f"ripgrep-{RIPGREP}", file=src / f"ripgrep-{RIPGREP}/crates/core/main.rs", lit='{:#}',
            cmd=lambda m, c: f"cargo build -q --offline {cargoflags[m]} --target-dir {c}"),
        ("Go", "mid"): dict(
            dir=src / "fzf", file=src / "fzf/main.go", lit='revision = "devel',
            cmd=lambda m, c: f"go build {goflags[m]} -o {out}/fzf_{m} .",
            env=lambda c: {"GOCACHE": str(c), "GOFLAGS": "-mod=mod", "GOPROXY": "off"}),
        ("Zig", "mid"): dict(
            dir=src / "translate-c", file=src / "translate-c/translate-c/main.zig", lit="Usage {s}",
            cmd=lambda m, c: f"zig build -Doptimize={zigmode[m]} --cache-dir {c} --prefix {out}/translate-c_{m}"),
    }
    # Nim again, with clang as its C compiler instead of gcc
    for (lang, proj), b in list(bs.items()):
        if lang == "Nim":
            bs[("Nim clang", proj)] = dict(b, cmd=lambda m, c, cmd=b["cmd"]: cmd(m, c).replace("nim c ", "nim c --cc:clang ", 1))
    return bs


def edit(b, i):
    """change the string literal: a different text every time"""
    f = b["file"]
    text, n = re.subn(re.escape(b["lit"]) + r"( ~\d+)?", lambda _: f"{b['lit']} ~{i}", f.read_text(), count=1)
    assert n == 1, f"literal not found in {f}"
    f.write_text(text)


def measure(lang, proj, b, mode):
    cache = WORK / "cache" / f"{lang.replace(' ', '_')}-{proj}-{mode}"
    run = lambda: timed(b["cmd"](mode, cache), b["dir"], b.get("env", lambda c: {})(cache))
    rows = []
    n = RUNS[proj]
    clean = []
    for _ in range(n):
        shutil.rmtree(cache, ignore_errors=True)
        clean.append(run())
    rows.append(("clean", clean))
    rebuild = []
    for i in range(n):
        edit(b, i + 1)
        rebuild.append(run())
    rows.append(("rebuild", rebuild))
    if proj == "mid":
        rows.append(("nochange", [run() for _ in range(n)]))
    return [(lang, proj, mode, scen, statistics.median(ts), min(ts), max(ts)) for scen, ts in rows]


# --- sizes: lines of code compiled -----------------------------------------

def lines(paths):
    n = 0
    for p in paths:
        try:
            n += sum(1 for _ in open(p, errors="ignore"))
        except OSError:
            pass
    return n


def sizes(src):
    rows = []
    # Nim: the modules whose C files are in the nimcache of the release build
    # (@m..@sdist@sx.nim.c is ../dist/x.nim, relative to compiler/), own (compiler/) and the rest
    nc = WORK / "cache" / "Nim-mid-release"
    comp = src / "nim" / "compiler"
    own = dep = 0
    for c in nc.glob("@m*.nim.c"):
        p = (comp / c.name[2:-2].replace("@s", "/")).resolve()
        if p.parent == comp.resolve():
            own += lines([p])
        else:
            dep += lines([p])
    rows.append(("Nim", "the Nim compiler", own, dep, "stdlib and checksums"))
    # Rust: ripgrep's own crate and every crate it builds on Linux
    rg = src / f"ripgrep-{RIPGREP}"
    meta = json.loads(sh("cargo metadata --format-version 1 --offline --filter-platform x86_64-unknown-linux-gnu", cwd=rg))
    used = {n["id"] for n in meta["resolve"]["nodes"]}
    own = dep = 0
    for p in meta["packages"]:
        if p["id"] not in used:
            continue
        d = Path(p["manifest_path"]).parent
        files = [f for f in d.rglob("*.rs") if not ({"tests", "benches", "examples"} & set(f.relative_to(d).parts))]
        if p["name"] == "ripgrep":
            own += lines(files)
        else:
            dep += lines(files)
    rows.append(("Rust", f"ripgrep {RIPGREP}", own, dep, f"{len(used) - 1} crates"))
    # Go: fzf's own packages, the modules it needs, the standard library it compiles
    fz = src / "fzf"
    out = sh("go list -deps -f '{{.Standard}}|{{.Module}}|{{.Dir}}|{{join .GoFiles \",\"}}' .", cwd=fz, env={"GOFLAGS": "-mod=mod", "GOPROXY": "off"})
    own = dep = std = 0
    for line in out.splitlines():
        standard, mod, d, files = line.split("|")
        k = lines([Path(d) / f for f in files.split(",") if f])
        if standard == "true":
            std += k
        elif mod.startswith("github.com/junegunn/fzf"):
            own += k
        else:
            dep += k
    rows.append(("Go", f"fzf {FZF}", own, dep, f"modules; plus {round(std / 1000)} k lines of the standard library"))
    # Zig: translate-c is the program, aro its C front-end
    tc = src / "translate-c"
    own = lines(list((tc / "translate-c").rglob("*.zig")) + [tc / "util.zig"])
    dep = lines((tc / "aro").rglob("*.zig"))
    rows.append(("Zig", "translate-c", own, dep, "aro, the C front-end"))
    with open(HERE / "sizes.csv", "w") as f:
        f.write("lang,project,own_lines,dep_lines,deps\n")
        for r in rows:
            f.write(",".join(str(x) for x in r) + "\n")


def machine():
    cpu = ""
    try:
        cpu = re.search(r"model name\s*:\s*(.*)", open("/proc/cpuinfo").read()).group(1)
    except Exception:
        cpu = platform.processor() or sh("sysctl -n machdep.cpu.brand_string").strip()
    first = lambda s: s.strip().splitlines()[0]
    with open(HERE / "machine.txt", "w") as f:
        f.write(f"cpu: {cpu}, {os.cpu_count()} cores\n")
        f.write(f"nim: {first(sh('nim --version'))}, C compilers: {first(sh('gcc --version'))}, {first(sh('clang --version'))}\n")
        f.write(f"rust: {first(sh('rustc --version'))}\n")
        f.write(f"go: {first(sh('go version'))}\n")
        f.write(f"zig: zig {first(sh('zig version'))}\n")
        f.write(f"date: {time.strftime('%Y-%m-%d')}\n")


def main():
    args = sys.argv[1:]
    which = [a for a in args if a in RUNS] or list(RUNS)
    langs = [a for a in args if a not in RUNS] or ["Nim", "Nim clang", "Rust", "Go", "Zig"]
    src = prepare()
    bs = builds(src)
    old = []
    res = HERE / "results.csv"
    if res.exists():
        old = [l for l in res.read_text().splitlines()[1:]
               if not (l.split(",")[1] in which and l.split(",")[0] in langs)]
    rows = []
    for (lang, proj), b in bs.items():
        if proj not in which or lang not in langs:
            continue
        for mode in ["debug", "release"]:
            for r in measure(lang, proj, b, mode):
                print(*r, sep=",", flush=True)
                rows.append(",".join([*r[:4], *(f"{x:.2f}" for x in r[4:])]))
    with open(res, "w") as f:
        f.write("lang,project,mode,scenario,median_s,min_s,max_s\n")
        f.write("\n".join(old + rows) + "\n")
    if "mid" in which and "Nim" in langs and "Rust" in langs:
        sizes(src)
    machine()


if __name__ == "__main__":
    main()
