#!/usr/bin/env bash
# Downloads local copies of the js/css/fonts that nimiSlides loads from CDNs
# (reveal.js with its highlight, notes and math plugins; KaTeX for the math plugin),
# of p5.js (for the p5nim sketches) and of the highlight.js code themes, and the files nimib pages load from CDNs
# (water.css, nimib's highlight.js and code theme, plotly.js for the interactive plots of the explainers)
# into docs/assets, so the slides, the explainers and the talk log work offline and on GitHub Pages without CDNs
# (`nim r build.nim check` fails when a built page still loads something from the network).
# The vendored files are committed: rerun only to change versions.
#
# usage: scripts/vendor-assets.sh   (needs git and npm)
set -euo pipefail

REVEAL_VERSION="${REVEAL_VERSION:-5.0.4}" # must match nimiSlides' reveal_version
KATEX_VERSION="${KATEX_VERSION:-0.16.47}"
P5_VERSION="${P5_VERSION:-1.11.13}" # p5nim binds the p5.js 1.x api
HLJS_VERSION="${HLJS_VERSION:-11.11.1}" # only its css: nimib highlights Nim code when the deck is built
HLJS_STYLES="github atom-one-light stackoverflow-light" # light code themes, picked in my.nim (codeTheme)
WATER_VERSION="${WATER_VERSION:-2.1.1}" # nimib's default stylesheet (water.css@2)
NIMIB_VERSION="${NIMIB_VERSION:-v0.4.3}" # nimib's highlight.min.js and code themes (its assets/ folder)
PLOTLY_VERSION="${PLOTLY_VERSION:-2.35.2}" # plotly.js for nbPlotly (slides/nbplotly.nim)

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

# p5.js: the minified library, loaded by the p5nim sketches (see my.nim)
mkdir -p "$tmp/p5" && (cd "$tmp/p5" && npm pack --silent "p5@$P5_VERSION" >/dev/null && tar xzf p5-*.tgz)
p5="$assets/p5"
rm -rf "$p5"
mkdir -p "$p5"
cp "$tmp/p5/package/license.txt" "$p5/LICENSE" 2>/dev/null || cp "$tmp/p5/package/LICENSE"* "$p5/LICENSE"
cp "$tmp/p5/package/lib/p5.min.js" "$p5/"
echo "$P5_VERSION" > "$p5/VERSION"

# highlight.js styles: the code theme css (see codeTheme in my.nim)
mkdir -p "$tmp/hljs" && (cd "$tmp/hljs" && npm pack --silent "highlight.js@$HLJS_VERSION" >/dev/null && tar xzf highlight.js-*.tgz)
hljs="$assets/highlight"
rm -rf "$hljs"
mkdir -p "$hljs"
cp "$tmp/hljs/package/LICENSE" "$hljs/"
for style in $HLJS_STYLES; do
  cp "$tmp/hljs/package/styles/$style.css" "$hljs/"
done
echo "$HLJS_VERSION" > "$hljs/VERSION"

# water.css: the stylesheet of nimib's default theme (see offline.nim)
mkdir -p "$tmp/water" && (cd "$tmp/water" && npm pack --silent "water.css@$WATER_VERSION" >/dev/null && tar xzf water.css-*.tgz)
water="$assets/water.css"
rm -rf "$water"
mkdir -p "$water"
cp "$tmp/water/package/LICENSE.md" "$water/LICENSE.md"
cp "$tmp/water/package/out/light.min.css" "$tmp/water/package/out/dark.min.css" "$tmp/water/package/out/water.min.css" "$water/"
echo "$WATER_VERSION" > "$water/VERSION"

# nimib's assets: the highlight.js build (with Nim) and the code themes of nimib's default theme (see offline.nim)
git -c advice.detachedHead=false clone -q --depth 1 -b "$NIMIB_VERSION" https://github.com/pietroppeter/nimib.git "$tmp/nimib"
nimibAssets="$assets/nimib"
rm -rf "$nimibAssets"
mkdir -p "$nimibAssets"
cp "$tmp/nimib/LICENSE" "$nimibAssets/"
cp "$tmp/nimib/assets/highlight.min.js" "$tmp/nimib/assets/atom-one-light.css" "$tmp/nimib/assets/androidstudio.css" "$nimibAssets/"
echo "$NIMIB_VERSION" > "$nimibAssets/VERSION"

# plotly.js: the interactive plots of the explainers (see slides/nbplotly.nim)
mkdir -p "$tmp/plotly" && (cd "$tmp/plotly" && npm pack --silent "plotly.js-dist-min@$PLOTLY_VERSION" >/dev/null && tar xzf plotly.js-dist-min-*.tgz)
plotly="$assets/plotly"
rm -rf "$plotly"
mkdir -p "$plotly"
cp "$tmp/plotly/package/LICENSE" "$plotly/"
cp "$tmp/plotly/package/plotly.min.js" "$plotly/"
echo "$PLOTLY_VERSION" > "$plotly/VERSION"

du -sh "$reveal" "$katex" "$p5" "$hljs" "$water" "$nimibAssets" "$plotly"
