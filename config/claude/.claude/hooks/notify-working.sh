#!/bin/bash
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
WORKDIR=$(echo "$INPUT" | jq -r '.cwd')

# Dismiss any existing notification for this session
python3 ~/.claude/hooks/claude-notify.py "$(jq -n \
  --arg action "withdraw" \
  --arg id "$SESSION_ID" \
  '{action: $action, id: $id}')" 2>/dev/null

# Record prompt timestamp
jq -n \
  --arg event "prompt_submit" \
  --arg session_id "$SESSION_ID" \
  --arg cwd "$WORKDIR" \
  --argjson timestamp "$(date +%s)" \
  '{event: $event, session_id: $session_id, cwd: $cwd, timestamp: $timestamp}' \
  > ~/.claude/hook-events/"${SESSION_ID}_prompt.json"
