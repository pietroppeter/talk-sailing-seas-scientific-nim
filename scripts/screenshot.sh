#!/usr/bin/env bash
# Screenshot nimiSlides html decks with headless Chromium (one png per slide).
# reveal.js and KaTeX are vendored in docs/assets, so no network is needed.
#
# usage: scripts/screenshot.sh <deck.html> <outdir> [nslides]
# writes <outdir>/<deck>-<n>.png for slides 0..nslides-1 in deck order (default: all slides),
# vertical stacks included
set -euo pipefail

deck=$(realpath "$1"); outdir=$(realpath -m "$2"); mkdir -p "$outdir"
chromium=${CHROMIUM:-$(ls /opt/pw-browsers/chromium 2>/dev/null || command -v chromium || command -v chromium-browser)}

# reveal.js slide addresses (h or h/v for vertical stacks), in deck order
mapfile -t addrs < <(python3 - "$deck" <<'PY'
import re, sys
html = open(sys.argv[1]).read()
html = html[html.index('<div class="slides">'):]
depth, h, v, out = 0, -1, 0, []
for tag in re.findall(r'<section|</section>', html):
    if tag == '<section':
        if depth == 0:
            h += 1; v = 0; out.append([str(h)])
        else:
            out[-1].append(f"{h}/{v}"); v += 1
        depth += 1
    else:
        depth -= 1
for group in out:
    print("\n".join(group[1:] or group[:1]))
PY
)

n=${3:-${#addrs[@]}}
name=$(basename "$deck" .html)
for ((i = 0; i < n; i++)); do
  "$chromium" --headless --no-sandbox --disable-gpu --allow-file-access-from-files \
    --window-size=1280,720 --virtual-time-budget=5000 \
    --screenshot="$outdir/$name-$i.png" "file://$deck#/${addrs[$i]}" 2>/dev/null >/dev/null
  echo "$outdir/$name-$i.png"
done
