#!/usr/bin/env bash
# Exports the Shiny for Python apps in shiny/ with shinylive into docs/shiny/<app>/:
# a static site where Python runs in the browser (Pyodide, WebAssembly), with every
# file it needs (about 50 MB, not committed), so the app works offline.
# build.nim runs it when docs/shiny/plant/ is missing; it needs the network the first
# time (pip, and the shinylive assets from GitHub, cached in ~/.cache/shinylive).
# Serve docs/ over http to try it (a service worker does not run from file://):
#   python3 -m http.server -d docs
#
# usage: scripts/shinylive.sh   (needs python3)
set -euo pipefail

SHINYLIVE_VERSION="${SHINYLIVE_VERSION:-0.8.13}" # pins the shinylive assets (0.10.16: Pyodide, Shiny 1.9)

root=$(cd "$(dirname "$0")/.." && pwd)
venv="${XDG_CACHE_HOME:-$HOME/.cache}/shinylive-venv-$SHINYLIVE_VERSION"
if [ ! -x "$venv/bin/shinylive" ]; then
  python3 -m venv "$venv"
  "$venv/bin/pip" install -q --upgrade pip
  "$venv/bin/pip" install -q "shinylive==$SHINYLIVE_VERSION"
fi
for app in "$root"/shiny/*/; do
  name=$(basename "$app")
  rm -rf "$root/docs/shiny/$name"
  mkdir -p "$root/docs/shiny"
  "$venv/bin/shinylive" export "$app" "$root/docs/shiny/$name"
done
