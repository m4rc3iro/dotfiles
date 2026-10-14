#!/usr/bin/env bash
# The one supported way to run an OpenAI GPT-6.1-Sol task via the Codex CLI (used by ~/.claude/agents/openai-implementer.md).
# Usage: openai-run.sh <repo-dir> <prompt-file> <log-file>
# Stdin is closed so `codex exec` never waits on it. Effort is pinned to low to save quota, matching kimi-run.sh.
# Sandbox is workspace-write: Codex can edit the repo and run tests, but has no network and cannot write .git,
# so it cannot commit from a worktree; the relay commits. The run is killed after an hour.
set -euo pipefail

if [ $# -ne 3 ]; then
  echo "usage: openai-run.sh <repo-dir> <prompt-file> <log-file>" >&2
  exit 2
fi
repo=$1 prompt=$2 log=$3
[ -s "$prompt" ] || { echo "openai-run.sh: prompt file missing or empty: $prompt" >&2; exit 2; }

cd "$repo"
exec perl -e 'alarm 3600; exec @ARGV' codex exec "$(cat "$prompt")" \
  --model gpt-6.1-sol -c model_reasoning_effort=low --sandbox workspace-write \
  < /dev/null > "$log" 2>&1
