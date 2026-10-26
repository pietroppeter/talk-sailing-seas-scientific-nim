#!/usr/bin/env bash
# Screenshot nimiSlides html decks with headless Chromium (one png per slide).
# reveal.js and KaTeX are vendored in docs/assets, so no network is needed.
#
# usage: scripts/screenshot.sh <deck.html> <outdir> [nslides]
# writes <outdir>/<deck>-<n>.png for slides 0..nslides-1 (default: all slides)
set -euo pipefail

deck=$(realpath "$1"); outdir=$(realpath -m "$2"); mkdir -p "$outdir"
chromium=${CHROMIUM:-$(ls /opt/pw-browsers/chromium 2>/dev/null || command -v chromium || command -v chromium-browser)}

n=${3:-$(grep -c '<section' "$deck")}
name=$(basename "$deck" .html)
for ((i = 0; i < n; i++)); do
  "$chromium" --headless --no-sandbox --disable-gpu --allow-file-access-from-files \
    --window-size=1280,720 --virtual-time-budget=5000 \
    --screenshot="$outdir/$name-$i.png" "file://$deck#/$i" 2>/dev/null >/dev/null
  echo "$outdir/$name-$i.png"
done
