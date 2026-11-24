#!/bin/bash
# Installs the Nim toolchain (nim, nimble, atlas) into /opt/nim and links the
# binaries into /usr/local/bin. Meant for Claude Code cloud environments.
#
# Uses the prebuilt tarball from nim-lang.org when that host is reachable,
# otherwise builds from source with a git clone of github.com/nim-lang/Nim
# (git to GitHub works through the cloud proxy; the build takes ~7 minutes).
# Safe to run more than once.
set -euo pipefail

NIM_VERSION="${NIM_VERSION:-2.2.12}"
NIM_DIR="${NIM_DIR:-/opt/nim}"

# nimib's markdown dependency loads libpcre at runtime
if ! ldconfig -p | grep -q 'libpcre\.so\.3'; then
  apt-get install -y -q libpcre3 >/dev/null 2>&1 ||
    { apt-get update -q >/dev/null 2>&1 && apt-get install -y -q libpcre3 >/dev/null; }
fi

if [ -x "$NIM_DIR/bin/nim" ] && "$NIM_DIR/bin/nim" -v | head -1 | grep -q "Version $NIM_VERSION "; then
  echo "Nim $NIM_VERSION already installed in $NIM_DIR"
else
  rm -rf "$NIM_DIR"
  tarball="https://nim-lang.org/download/nim-$NIM_VERSION-linux_x64.tar.xz"
  if curl -fsSL --max-time 120 "$tarball" -o /tmp/nim.tar.xz 2>/dev/null; then
    mkdir -p "$NIM_DIR"
    tar -xJf /tmp/nim.tar.xz -C "$NIM_DIR" --strip-components=1
    rm -f /tmp/nim.tar.xz
  else
    echo "nim-lang.org not reachable, building Nim $NIM_VERSION from source"
    git clone -q --depth 1 -b "v$NIM_VERSION" https://github.com/nim-lang/Nim "$NIM_DIR"
    (cd "$NIM_DIR" && sh build_all.sh >/tmp/nim-build.log 2>&1) ||
      { tail -20 /tmp/nim-build.log >&2; exit 1; }
  fi
  # atlas is built by build_all.sh but not always shipped in the tarball
  if [ ! -x "$NIM_DIR/bin/atlas" ]; then
    (cd "$NIM_DIR" && ./bin/nim c --hints:off koch >/dev/null && ./koch tools >/tmp/nim-tools.log 2>&1) ||
      { tail -20 /tmp/nim-tools.log >&2; exit 1; }
  fi
fi

for tool in nim nimble atlas nimsuggest nimpretty; do
  [ -x "$NIM_DIR/bin/$tool" ] && ln -sf "$NIM_DIR/bin/$tool" "/usr/local/bin/$tool"
done
nim -v | head -1
atlas --version | head -1
