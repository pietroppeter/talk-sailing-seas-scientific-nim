#!/bin/bash
# SessionStart hook for Claude Code cloud sessions: installs Nim + atlas with
# scripts/install-nim.sh when they are missing. Async because a source build
# takes ~7 minutes; check `nim -v` before building slides.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ] || command -v nim >/dev/null 2>&1; then
  exit 0
fi

echo '{"async": true, "asyncTimeout": 900000}'
bash "$CLAUDE_PROJECT_DIR/scripts/install-nim.sh" >/tmp/install-nim.log 2>&1
