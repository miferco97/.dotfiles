#!/bin/bash
# Only dismiss permission notifications, not "done" notifications
SESSION_ID=$(jq -r '.session_id' 2>/dev/null)
MARKER="/tmp/claude-notify-permission-${SESSION_ID}"

if [ -f "$MARKER" ]; then
  python3 ~/.claude/hooks/claude-notify.py "$(jq -n \
    --arg action "withdraw" \
    --arg id "$SESSION_ID" \
    '{action: $action, id: $id}')" 2>/dev/null
  rm -f "$MARKER"
fi
