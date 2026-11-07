#!/usr/bin/env bash
# Builds the deck once per explored theme (see themes.nim and slides/themes_explainer.nim):
# docs/index_<theme>.html for pirate, book and chart. docs/index.html stays the default theme.
#
# usage: scripts/build-themes.sh [themes...]
set -euo pipefail
cd "$(dirname "$0")/.."
cp docs/index.html /tmp/index-default.html 2>/dev/null || true
for theme in "${@:-pirate book chart}"; do
  for t in $theme; do
    nim r --hints:off -d:slideTheme="$t" index.nim >/dev/null
    mv docs/index.html "docs/index_$t.html"
    echo "docs/index_$t.html"
  done
done
[ -f /tmp/index-default.html ] && mv /tmp/index-default.html docs/index.html || true
