"""The same program in Nim, Rust, Go and Zig, generated: MODULES modules of FUNCS functions.

Each function runs a small loop of integer arithmetic; each module has a run function
that calls all of its functions; main calls every run function and prints
"Hello, sailor!" and a checksum, the same in the four languages.
Used by run.py as the project "same".
"""
from pathlib import Path

MODULES = 50
FUNCS = 100
MOD = 1000003


def nim(m):
    out = []
    for f in range(FUNCS):
        g = m * FUNCS + f
        out.append(f"""proc fun{g}*(x: int): int =
  var s = x
  for k in 0 ..< 10:
    if s mod 3 == 0:
      s = s div 3 + k
    else:
      s = (s * 2 + {g}) mod {MOD}
  s
""")
    calls = "\n".join(f"  result = (result + fun{m * FUNCS + f}(x)) mod {MOD}" for f in range(FUNCS))
    out.append(f"proc run{m}*(x: int): int =\n  result = 0\n{calls}\n")
    return "\n".join(out)


def rust(m):
    out = []
    for f in range(FUNCS):
        g = m * FUNCS + f
        out.append(f"""pub fn fun{g}(x: i64) -> i64 {{
    let mut s = x;
    for k in 0..10 {{
        if s % 3 == 0 {{
            s = s / 3 + k;
        }} else {{
            s = (s * 2 + {g}) % {MOD};
        }}
    }}
    s
}}
""")
    calls = "\n".join(f"    r = (r + fun{m * FUNCS + f}(x)) % {MOD};" for f in range(FUNCS))
    out.append(f"pub fn run{m}(x: i64) -> i64 {{\n    let mut r = 0;\n{calls}\n    r\n}}\n")
    return "\n".join(out)


def go(m):
    out = [f"package m{m}\n"]
    for f in range(FUNCS):
        g = m * FUNCS + f
        out.append(f"""func Fun{g}(x int) int {{
	s := x
	for k := 0; k < 10; k++ {{
		if s%3 == 0 {{
			s = s/3 + k
		}} else {{
			s = (s*2 + {g}) % {MOD}
		}}
	}}
	return s
}}
""")
    calls = "\n".join(f"\tr = (r + Fun{m * FUNCS + f}(x)) % {MOD}" for f in range(FUNCS))
    out.append(f"func Run(x int) int {{\n\tr := 0\n{calls}\n\treturn r\n}}\n")
    return "\n".join(out)


def zig(m):
    out = []
    for f in range(FUNCS):
        g = m * FUNCS + f
        out.append(f"""pub fn fun{g}(x: i64) i64 {{
    var s = x;
    var k: i64 = 0;
    while (k < 10) : (k += 1) {{
        if (@mod(s, 3) == 0) {{
            s = @divTrunc(s, 3) + k;
        }} else {{
            s = @mod(s * 2 + {g}, {MOD});
        }}
    }}
    return s;
}}
""")
    calls = "\n".join(f"    r = @mod(r + fun{m * FUNCS + f}(x), {MOD});" for f in range(FUNCS))
    out.append(f"pub fn run{m}(x: i64) i64 {{\n    var r: i64 = 0;\n{calls}\n    return r;\n}}\n")
    return "\n".join(out)


def generate(dest: Path):
    """write the four programs under dest/{nim,rust,go,zig}; returns the lines of each"""
    ms = range(MODULES)
    files = {}
    # Nim
    files["nim/main.nim"] = "".join(f"import m{m}\n" for m in ms) + "var t = 0\n" + "".join(
        f"t = (t + run{m}(t mod 1000 + {m})) mod {MOD}\n" for m in ms) + 'echo "Hello, sailor! ", t\n'
    for m in ms:
        files[f"nim/m{m}.nim"] = nim(m)
    # Rust: one crate, one module per file
    files["rust/Cargo.toml"] = '[package]\nname = "same"\nversion = "0.1.0"\nedition = "2021"\n\n[dependencies]\n'
    files["rust/src/main.rs"] = "".join(f"mod m{m};\n" for m in ms) + "\nfn main() {\n    let mut t: i64 = 0;\n" + "".join(
        f"    t = (t + m{m}::run{m}(t % 1000 + {m})) % {MOD};\n" for m in ms) + '    println!("Hello, sailor! {}", t);\n}\n'
    for m in ms:
        files[f"rust/src/m{m}.rs"] = rust(m)
    # Go: one package per module
    files["go/go.mod"] = "module same\n\ngo 1.23\n"
    files["go/main.go"] = 'package main\n\nimport (\n\t"fmt"\n' + "".join(f'\t"same/m{m}"\n' for m in ms) + ")\n\nfunc main() {\n\tt := 0\n" + "".join(
        f"\tt = (t + m{m}.Run(t%1000+{m})) % {MOD}\n" for m in ms) + '\tfmt.Println("Hello, sailor!", t)\n}\n'
    for m in ms:
        files[f"go/m{m}/m{m}.go"] = go(m)
    # Zig: one file per module
    files["zig/main.zig"] = 'const std = @import("std");\n' + "".join(f'const m{m} = @import("m{m}.zig");\n' for m in ms) + "\npub fn main() void {\n    var t: i64 = 0;\n" + "".join(
        f"    t = @mod(t + m{m}.run{m}(@mod(t, 1000) + {m}), {MOD});\n" for m in ms) + '    std.debug.print("Hello, sailor! {d}\\n", .{t});\n}\n'
    for m in ms:
        files[f"zig/m{m}.zig"] = zig(m)
    lines = {}
    for name, text in files.items():
        p = dest / name
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text)
        lang = name.split("/")[0]
        if not name.endswith((".toml", ".mod")):
            lines[lang] = lines.get(lang, 0) + text.count("\n")
    return lines


if __name__ == "__main__":
    import sys
    print(generate(Path(sys.argv[1])))
