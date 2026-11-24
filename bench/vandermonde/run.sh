#!/usr/bin/env bash
# The mini benchmark of the performance slide (2.3) and of its deep dive (deepdive/vandermonde.nim):
# the Vandermonde matrix with for loops in Python and in Nim, and with NumPy's np.vander,
# best of a few runs, in two cases:
#   large: one 1000 x 100 matrix (the slide)
#   small: 250 000 matrices of 4 x 4 (the case of table 2.1 in Bezanson's thesis)
# Writes results.csv and machine.txt next to this script; the slide and the deep dive read
# them when they are built. Needs python3 with numpy, and nim. Run it on the laptop of the talk:
#
#   bash bench/vandermonde/run.sh
set -euo pipefail
cd "$(dirname "$0")"
nim c -d:release --hints:off -o:vander_nim vander.nim >/dev/null
{
  echo "case,impl,ms,checksum"
  python3 vander.py large 1000 100 1 100
  ./vander_nim large 1000 100 1 100
  python3 vander.py small 4 4 250000 3
  ./vander_nim small 4 4 250000 3
} > results.csv
rm -f vander_nim
{
  echo "cpu: $( (lscpu 2>/dev/null | sed -n 's/^Model name: *//p'; sysctl -n machdep.cpu.brand_string 2>/dev/null) | head -1)"
  echo "python: Python $(python3 -c 'import sys; print(sys.version.split()[0])'), NumPy $(python3 -c 'import numpy; print(numpy.__version__)')"
  echo "nim: Nim $(nim --version | head -1 | sed 's/Nim Compiler Version //; s/ \[.*//') -d:release"
  echo "date: $(date +%Y-%m-%d)"
} > machine.txt
cat results.csv machine.txt
