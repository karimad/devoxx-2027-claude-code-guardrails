#!/usr/bin/env bash
# SessionEnd hook: fire-and-forget trigger for the wiki-session-sync skill.
# Must never block session shutdown and must never fail the session.
set -uo pipefail

STATE_DIR="${HOME}/.claude/wiki-session-sync"
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0

THROTTLE_FILE="$STATE_DIR/last-triggered"
THROTTLE_SECONDS=1200   # don't re-trigger more than once every 20 min (parallel/rapid session ends)

now=$(date +%s)
if [[ -f "$THROTTLE_FILE" ]]; then
  last=$(cat "$THROTTLE_FILE" 2>/dev/null || echo 0)
  if (( now - last < THROTTLE_SECONDS )); then
    exit 0
  fi
fi

# Cheap relevance check: skip trivial sessions (few messages) to avoid
# spending a headless Claude run on toy/one-off conversations.
input=$(cat)
transcript=$(echo "$input" | jq -r '.transcript_path // empty' 2>/dev/null)
if [[ -n "$transcript" && -f "$transcript" ]]; then
  lines=$(wc -l < "$transcript" 2>/dev/null || echo 0)
  if (( lines < 20 )); then
    exit 0
  fi
fi

echo "$now" > "$THROTTLE_FILE"

# Non-blocking: hand off to a detached background process and return immediately.
(
  claude -p "/wiki-session-sync" \
    >> "$STATE_DIR/runs.log" 2>&1
) >/dev/null 2>&1 &
disown

exit 0
