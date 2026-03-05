#!/bin/bash
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
WORKDIR=$(echo "$INPUT" | jq -r '.cwd')

# Calculate elapsed time from prompt submit event
PROMPT_FILE="$HOME/.claude/hook-events/${SESSION_ID}_prompt.json"
START=$(jq -r '.timestamp' "$PROMPT_FILE" 2>/dev/null || echo 0)
NOW=$(date +%s)
ELAPSED=$((NOW - START))

jq -n \
  --arg event "stop" \
  --arg session_id "$SESSION_ID" \
  --arg cwd "$WORKDIR" \
  --argjson elapsed "$ELAPSED" \
  --argjson timestamp "$NOW" \
  '{event: $event, session_id: $session_id, cwd: $cwd, elapsed: $elapsed, timestamp: $timestamp}' \
  > ~/.claude/hook-events/"${SESSION_ID}_stop_${NOW}.json"
