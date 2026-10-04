#!/usr/bin/env bash
# Screenshot nimiSlides html decks with headless Chromium, for sessions where
# the reveal.js / KaTeX CDNs are blocked (e.g. Claude cloud sessions):
# CDN links are rewritten to local copies (reveal.js via git, KaTeX via npm).
#
# usage: scripts/screenshot.sh <deck.html> <outdir> [nslides]
# writes <outdir>/<deck>-<n>.png for slides 0..nslides-1 (default: all slides)
set -euo pipefail

deck=$(realpath "$1"); outdir=$(realpath -m "$2"); mkdir -p "$outdir"
cache=${PREVIEW_CACHE:-$HOME/.cache/nimislides-preview}
chromium=${CHROMIUM:-$(ls /opt/pw-browsers/chromium 2>/dev/null || command -v chromium || command -v chromium-browser)}
revealVersion=$(grep -o 'reveal.js/[0-9.]*/reveal.js' "$deck" | head -1 | cut -d/ -f2)
mkdir -p "$cache"
if [ ! -d "$cache/reveal-$revealVersion" ]; then
  git clone -q --depth 1 -b "$revealVersion" https://github.com/hakimel/reveal.js.git "$cache/reveal-$revealVersion"
fi
if [ ! -d "$cache/katex" ]; then
  (cd "$cache" && npm pack katex@0.16 --silent >/dev/null && tar xzf katex-*.tgz && mv package katex && rm katex-*.tgz)
fi

reveal="$cache/reveal-$revealVersion"
cdn="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/$revealVersion"
preview="$(dirname "$deck")/.preview-$(basename "$deck")"
sed -e "s#$cdn/reveal.min.css#file://$reveal/dist/reveal.css#" \
    -e "s#$cdn/theme/\([a-z]*\).min.css#file://$reveal/dist/theme/\1.css#" \
    -e "s#$cdn/reveal.js#file://$reveal/dist/reveal.js#" \
    -e "s#$cdn/plugin/highlight/monokai.min.css#file://$reveal/plugin/highlight/monokai.css#" \
    -e "s#$cdn/plugin/\([a-z]*\)/\([a-z]*\).min.js#file://$reveal/plugin/\1/\2.js#" \
    -e "s#Reveal.initialize({#Reveal.initialize({ katex: { local: 'file://$cache/katex' },#" \
    "$deck" > "$preview"
trap 'rm -f "$preview"' EXIT

n=${3:-$(grep -c '<section' "$deck")}
name=$(basename "$deck" .html)
for ((i = 0; i < n; i++)); do
  "$chromium" --headless --no-sandbox --disable-gpu --allow-file-access-from-files \
    --window-size=1280,720 --virtual-time-budget=5000 \
    --screenshot="$outdir/$name-$i.png" "file://$preview#/$i" 2>/dev/null >/dev/null
  echo "$outdir/$name-$i.png"
done
