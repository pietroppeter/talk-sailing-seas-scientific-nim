#!/bin/bash
# SessionStart hook for Claude Code cloud sessions: installs the OpenSpec CLI.
# Runs synchronously (a few seconds), so /opsx commands work from the first prompt.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

OPENSPEC_VERSION="1.15.0"
if ! command -v openspec >/dev/null 2>&1 || [ "$(openspec --version)" != "$OPENSPEC_VERSION" ]; then
  npm install -g --no-fund --no-audit "@fission-ai/openspec@$OPENSPEC_VERSION" >/dev/null
fi
echo 'export OPENSPEC_TELEMETRY=0' >> "${CLAUDE_ENV_FILE:-/dev/null}"
openspec --version
