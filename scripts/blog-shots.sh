#!/usr/bin/env bash
# Screenshots of every slide of a deck for its blog post (blogpost.nim, blog.nim), with headless
# Chromium: one <outdir>/<h>-<v>.png per slide (reveal.js indices, as in the deck's address #/h/v),
# at the deck's size (1050x700, Quarto's proportions), every fragment shown, no controls.
# With Python's Pillow the pngs become webp (about 5 MB for the talk instead of 19).
# The blog post shows a screenshot where there is one and the live slide in a frame where there
# is none, so run this, then build again (`nim r build.nim slides`).
#
# usage: scripts/blog-shots.sh [deck.html] [outdir] [scale]
#        defaults: docs/slides.html docs/images/blog 1.5
set -euo pipefail

deck=$(realpath "${1:-docs/slides.html}"); outdir=$(realpath -m "${2:-docs/images/blog}"); scale=${3:-1.5}
mkdir -p "$outdir"
chromium=${CHROMIUM:-$(ls /opt/pw-browsers/chromium 2>/dev/null || command -v chromium || command -v chromium-browser || command -v google-chrome)}
query="?controls=false&progress=false&slideNumber=false&fragments=false&transition=none"

# reveal.js slide addresses h/v, in deck order (a slide that is not a vertical stack is h/0)
mapfile -t addrs < <(python3 - "$deck" <<'PY'
import re, sys
html = open(sys.argv[1]).read()
html = html[html.index('<div class="slides">'):]
depth, h, v, out = 0, -1, 0, []
for tag in re.findall(r'<section|</section>', html):
    if tag == '<section':
        if depth == 0:
            h += 1; v = 0; out.append([f"{h}/0"])
        else:
            if v == 0: out[-1] = []
            out[-1].append(f"{h}/{v}"); v += 1
        depth += 1
    else:
        depth -= 1
for group in out:
    print("\n".join(group))
PY
)

for a in "${addrs[@]}"; do
  png="$outdir/${a/\//-}.png"
  "$chromium" --headless --no-sandbox --disable-gpu --allow-file-access-from-files --hide-scrollbars \
    --window-size=1050,700 --force-device-scale-factor="$scale" --virtual-time-budget=5000 \
    --screenshot="$png" "file://$deck$query#/$a" 2>/dev/null >/dev/null
  echo "$png"
done

if python3 -c "import PIL" 2>/dev/null; then
  python3 - "$outdir" <<'PY'
import glob, os, sys
from PIL import Image
for png in glob.glob(os.path.join(sys.argv[1], "*.png")):
    Image.open(png).convert("RGB").save(png[:-4] + ".webp", "WEBP", quality=80, method=6)
    os.remove(png)
PY
  echo "== webp: $(du -sh "$outdir" | cut -f1)"
fi
