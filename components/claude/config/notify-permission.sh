#!/bin/bash
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
WORKDIR=$(echo "$INPUT" | jq -r '.cwd')
TOOL=$(echo "$INPUT" | jq -r '.tool_name // "action"')

NOW=$(date +%s)

jq -n \
  --arg event "permission" \
  --arg session_id "$SESSION_ID" \
  --arg cwd "$WORKDIR" \
  --arg tool "$TOOL" \
  --argjson timestamp "$NOW" \
  '{event: $event, session_id: $session_id, cwd: $cwd, tool: $tool, timestamp: $timestamp}' \
  > ~/.claude/hook-events/"${SESSION_ID}_permission_${NOW}.json"

# Mark that a permission notification is active for this session
touch "/tmp/claude-notify-permission-${SESSION_ID}"
