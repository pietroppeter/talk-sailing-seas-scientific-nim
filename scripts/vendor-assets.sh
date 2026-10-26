#!/usr/bin/env bash
# Downloads local copies of the js/css/fonts that nimiSlides loads from CDNs
# (reveal.js with its highlight, notes and math plugins; KaTeX for the math plugin)
# into docs/assets, so the slides work offline and on GitHub Pages without CDNs.
# The vendored files are committed: rerun only to change versions.
#
# usage: scripts/vendor-assets.sh   (needs git and npm)
set -euo pipefail

REVEAL_VERSION="${REVEAL_VERSION:-5.0.4}" # must match nimiSlides' reveal_version
KATEX_VERSION="${KATEX_VERSION:-0.16.47}"

root=$(cd "$(dirname "$0")/.." && pwd)
assets="$root/docs/assets"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# reveal.js: the dist bundle (css, js, themes and their fonts) and the plain js plugins
git -c advice.detachedHead=false clone -q --depth 1 -b "$REVEAL_VERSION" https://github.com/hakimel/reveal.js.git "$tmp/reveal"
reveal="$assets/reveal.js"
rm -rf "$reveal"
mkdir -p "$reveal/dist" "$reveal/plugin"
cp "$tmp/reveal/LICENSE" "$reveal/"
cp "$tmp/reveal/dist/reset.css" "$tmp/reveal/dist/reveal.css" "$tmp/reveal/dist/reveal.js" "$reveal/dist/"
cp -r "$tmp/reveal/dist/theme" "$reveal/dist/"
for plugin in highlight/highlight.js highlight/monokai.css notes/notes.js math/math.js; do
  mkdir -p "$reveal/plugin/$(dirname "$plugin")"
  cp "$tmp/reveal/plugin/$plugin" "$reveal/plugin/$plugin"
done
echo "$REVEAL_VERSION" > "$reveal/VERSION"

# KaTeX: the files reveal's math plugin loads from <local>/dist/ (see plugin/math/katex.js)
(cd "$tmp" && npm pack --silent "katex@$KATEX_VERSION" >/dev/null && tar xzf katex-*.tgz)
katex="$assets/katex"
rm -rf "$katex"
mkdir -p "$katex/dist/contrib"
cp "$tmp/package/LICENSE" "$katex/"
cp "$tmp/package/dist/katex.min.js" "$tmp/package/dist/katex.min.css" "$katex/dist/"
cp -r "$tmp/package/dist/fonts" "$katex/dist/"
cp "$tmp/package/dist/contrib/auto-render.min.js" "$tmp/package/dist/contrib/mhchem.min.js" "$katex/dist/contrib/"
echo "$KATEX_VERSION" > "$katex/VERSION"

du -sh "$reveal" "$katex"
