#!/usr/bin/env bash
# Run every benchmark that has a toolchain available and print the table.
set -u
cd "$(dirname "$0")"
mkdir -p results

echo "== python / numpy =="
if command -v python3 >/dev/null && python3 -c "import numpy" 2>/dev/null; then
    (cd python && python3 vander_bench.py && mv results_python.json ../results/)
else
    echo "  skipped: python3 with numpy not found"
fi

echo "== julia =="
if command -v julia >/dev/null; then
    (cd julia && julia -O3 --check-bounds=no vander_bench.jl \
        && mv results_julia.json ../results/)
else
    echo "  skipped: julia not on PATH"
fi

echo "== nim =="
if command -v nim >/dev/null; then
    (cd nim && nim c -d:danger --mm:arc --hints:off -o:vander_bench vander_bench.nim \
        && ./vander_bench && mv results_nim.json ../results/)
else
    echo "  skipped: nim not on PATH"
fi

echo
echo "== summary =="
python3 bench_table.py results
