#!/usr/bin/env bash
# The one supported way to run a Kimi K3 task via OpenCode (used by ~/.claude/agents/kimi-implementer.md).
# Usage: kimi-run.sh [--large] <repo-dir> <prompt-file> <log-file>
#   --large  use the k3-256k model, for very large prompts
# Stdin is closed because `opencode run` otherwise waits forever on piped stdin and never starts.
# Effort is pinned to low to save tokens. The run is killed after an hour.
set -euo pipefail

model='kimi-code-plan-global/k3#low'
if [ "${1:-}" = "--large" ]; then
  model='kimi-code-plan-global/k3-256k#low'
  shift
fi
if [ $# -ne 3 ]; then
  echo "usage: kimi-run.sh [--large] <repo-dir> <prompt-file> <log-file>" >&2
  exit 2
fi
repo=$1 prompt=$2 log=$3
[ -s "$prompt" ] || { echo "kimi-run.sh: prompt file missing or empty: $prompt" >&2; exit 2; }

cd "$repo"
exec perl -e 'alarm 3600; exec @ARGV' opencode run "$(cat "$prompt")" --model "$model" < /dev/null > "$log" 2>&1
