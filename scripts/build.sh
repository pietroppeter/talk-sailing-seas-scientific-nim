#!/usr/bin/env bash
# Builds the talk's pages into docs/ (run from anywhere; needs `atlas install` first).
#
#   scripts/build.sh              everything (what the pages workflow publishes)
#   scripts/build.sh slides       the deck, the style test deck, the Thank You slide, the easter egg
#   scripts/build.sh themes       the deck once per explored theme (docs/index_<theme>.html)
#   scripts/build.sh explainers   every slides/*_explainer.nim
#   scripts/build.sh devlog       every talk log post, then the talk log index
#   scripts/build.sh check        only checks that the built pages load nothing from the network
#
# Several groups can be given at once (scripts/build.sh slides explainers).
# Explainers and talk log posts are found by name, so a new one needs no change here.
# Extra flags for nim go in NIMFLAGS, e.g. NIMFLAGS=-d:release scripts/build.sh explainers
set -euo pipefail
cd "$(dirname "$0")/.."

run() {
  echo "== nim r $*"
  # shellcheck disable=SC2086
  nim r --hints:off ${NIMFLAGS:-} "$@"
}

slides() {
  run index.nim
  run my.nim
  run slides/thank_you.nim
  run slides/emilia.nim
}

themes() {
  scripts/build-themes.sh
}

explainers() {
  for f in slides/*_explainer.nim; do run "$f"; done
}

devlog() {
  # devlog/devlog.nim is the shared helper, devlog/index.nim lists the posts: it goes last
  for f in devlog/*.nim; do
    case "$f" in devlog/devlog.nim|devlog/index.nim) ;; *) run "$f" ;; esac
  done
  run devlog/index.nim
}

# Fails when a built page loads a script, a stylesheet, a font or an image from another site,
# or links a stylesheet that does (an @import or url() to another site): everything a page needs
# is in docs/assets/ (scripts/vendor-assets.sh), so the pages work offline. Links (<a href>) are fine.
check() {
  local remote='(https?:)?//[^"'"'"' >)]+'
  local found css
  found=$(grep -rnoE --include='*.html' "<(script|link|img|iframe|source|video|audio)[^>]*(src|href)=[\"']?$remote" docs || true)
  found+=$'\n'$(grep -rnoE --include='*.html' "(url\\(|@import)[\"' ]*$remote" docs || true)
  # the stylesheets the pages link, resolved from each page's folder
  while IFS=: read -r page href; do
    css="$(dirname "$page")/$href"
    [ -f "$css" ] && found+=$'\n'$(grep -noE "(url\\(|@import)[\"' ]*$remote" "$css" | sed "s|^|$css:|" || true)
  done < <(grep -roE --include='*.html' "<link[^>]*href=[\"'][^\"']+\\.css" docs | sed -E "s/<link.*href=[\"']//" | sort -u)
  found=$(echo "$found" | sed '/^$/d')
  if [ -n "$found" ]; then
    echo "== pages that load something from the network (vendor it in docs/assets/):"
    echo "$found"
    return 1
  fi
  echo "== check: no page loads anything from the network"
}

# works with macOS' bash 3.2 too
[ $# -eq 0 ] && set -- all
for g in "$@"; do
  case "$g" in
    slides|themes|explainers|devlog|check) "$g" ;;
    all) slides; themes; explainers; devlog; check ;;
    *) echo "unknown group: $g (slides, themes, explainers, devlog, check, all)"; exit 2 ;;
  esac
done
