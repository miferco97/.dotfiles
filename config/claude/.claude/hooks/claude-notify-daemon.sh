#!/bin/bash
# Claude Code notification daemon
# Watches ~/.claude/hook-events/ for event files and triggers notifications
# Uses GApplication notifications for proper replacement (one per session)
#
# Usage:
#   ~/.claude/hooks/claude-notify-daemon.sh          # run in foreground
#   ~/.claude/hooks/claude-notify-daemon.sh --start   # run in background
#   ~/.claude/hooks/claude-notify-daemon.sh --stop    # stop background daemon
#   ~/.claude/hooks/claude-notify-daemon.sh --status  # check if running

EVENTS_DIR="$HOME/.claude/hook-events"
ICON="$HOME/.claude/hooks/claude-icon.png"
NOTIFY_PY="$HOME/.claude/hooks/claude-notify.py"
PID_FILE="/tmp/claude-notify-daemon.pid"
MIN_SECONDS=60

case "${1:-}" in
  --start)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "Daemon already running (PID $(cat "$PID_FILE"))"
      exit 0
    fi
    # Kill any orphaned instances
    pkill -f "claude-notify-daemon.sh" --older 2 2>/dev/null
    pkill -f "inotifywait.*hook-events" 2>/dev/null
    sleep 0.5
    nohup "$0" > /tmp/claude-notify-daemon.log 2>&1 &
    echo $! > "$PID_FILE"
    echo "Daemon started (PID $!)"
    exit 0
    ;;
  --stop)
    pkill -f "claude-notify-daemon.sh" --older 2 2>/dev/null
    pkill -f "inotifywait.*hook-events" 2>/dev/null
    rm -f "$PID_FILE"
    echo "Daemon stopped"
    exit 0
    ;;
  --status)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "Running (PID $(cat "$PID_FILE"))"
    else
      echo "Not running"
      rm -f "$PID_FILE" 2>/dev/null
    fi
    exit 0
    ;;
esac

mkdir -p "$EVENTS_DIR"

# Clean up stale events on start
find "$EVENTS_DIR" -name "*_stop_*.json" -o -name "*_permission_*.json" | xargs rm -f 2>/dev/null

echo "Claude notify daemon started, watching $EVENTS_DIR"

inotifywait -m -e close_write --format '%f' "$EVENTS_DIR" | while read -r filename; do
  # Skip prompt files — they're just timestamps
  [[ "$filename" == *_prompt.json ]] && continue

  filepath="$EVENTS_DIR/$filename"
  [ -f "$filepath" ] || continue

  EVENT=$(jq -r '.event' "$filepath" 2>/dev/null)
  SESSION_ID=$(jq -r '.session_id' "$filepath" 2>/dev/null)
  SHORT_ID="${SESSION_ID:0:8}"
  WORKDIR=$(basename "$(jq -r '.cwd' "$filepath" 2>/dev/null)")

  case "$EVENT" in
    stop)
      ELAPSED=$(jq -r '.elapsed' "$filepath" 2>/dev/null)
      if [ "$ELAPSED" -ge "$MIN_SECONDS" ] 2>/dev/null; then
        pw-play /usr/share/sounds/freedesktop/stereo/message.oga &
        python3 "$NOTIFY_PY" "$(jq -n \
          --arg title "Claude [$WORKDIR:$SHORT_ID]" \
          --arg body "Done (${ELAPSED}s)" \
          --arg id "$SESSION_ID" \
          --arg icon "$ICON" \
          '{title: $title, body: $body, id: $id, icon: $icon}')"
      fi
      rm -f "$filepath"
      ;;
    permission)
      TOOL=$(jq -r '.tool' "$filepath" 2>/dev/null)
      pw-play /usr/share/sounds/freedesktop/stereo/dialog-information.oga &
      python3 "$NOTIFY_PY" "$(jq -n \
        --arg title "Claude [$WORKDIR:$SHORT_ID]" \
        --arg body "Waiting for approval: $TOOL" \
        --arg id "$SESSION_ID" \
        --arg icon "$ICON" \
        --arg urgency "critical" \
        '{title: $title, body: $body, id: $id, icon: $icon, urgency: $urgency}')"
      rm -f "$filepath"
      ;;
  esac
done
