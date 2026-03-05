# Claude Code Hooks - Notifications & Sounds

## What it does

- Shows a desktop notification with sound when Claude finishes a long task (60+ seconds)
- Shows a notification with sound when Claude needs permission approval
- Notifications include the working directory and short session ID to distinguish sessions
- New notifications from the same session **replace** the previous one (no stacking)
- Notifications **auto-dismiss** when no longer relevant:
  - Permission notifications dismiss after you approve/deny
  - "Done" notifications dismiss when you send a new message
  - All notifications dismiss when the session ends
- Works across host and Docker containers via a shared event directory
- External apps can consume the JSON event files for custom integrations

## Architecture

```
┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐
│  Claude (host)  │   │ Claude (docker1) │   │ Claude (docker2) │
│  hook scripts   │   │  hook scripts    │   │  hook scripts    │
└────────┬────────┘   └────────┬─────────┘   └────────┬─────────┘
         │                     │                      │
         ▼                     ▼                      ▼
    ~/.claude/hook-events/  (shared directory, mounted in all containers)
         │
         │  JSON event files
         ▼
┌─────────────────────────┐
│  claude-notify daemon   │  (host-side, watches with inotifywait)
│  - desktop notifications│
│  - sounds               │
│  - any external consumer│
└─────────────────────────┘
```

Hook scripts write JSON events. The daemon watches for new files and triggers notifications
using GApplication (`org.gtk.Notifications`) for proper per-session replacement on GNOME.

**Note:** `notify-send --replace-id` does NOT work in GNOME Shell — replaced notifications
still stack in the tray. The solution is to use `Gio.Application.send_notification()` which
natively replaces notifications by ID, and `withdraw_notification()` to dismiss them.

### Event format

```json
{"event": "stop", "session_id": "abc-123", "cwd": "/home/user/project", "elapsed": 65, "timestamp": 1709640000}
{"event": "permission", "session_id": "abc-123", "cwd": "/home/user/project", "tool": "Bash", "timestamp": 1709640000}
{"event": "prompt_submit", "session_id": "abc-123", "cwd": "/home/user/project", "timestamp": 1709640000}
```

### Notification lifecycle

```
UserPromptSubmit ──→ dismiss previous notification + record timestamp
PermissionRequest ──→ show "Waiting for approval" + mark permission active
PostToolUse ────────→ dismiss notification (only if permission was active)
Stop ───────────────→ show "Done" (only if 60+ seconds elapsed)
UserPromptSubmit ──→ dismiss "Done" notification
SessionEnd ─────────→ dismiss any remaining notification
```

## Setup

### 1. Install dependencies

```bash
sudo apt install pipewire jq inotify-tools
```

- `jq` — JSON parsing for hook input
- `pw-play` — PipeWire sound player
- `inotifywait` — filesystem event watcher for the daemon
- Python 3 with `gi` (GObject Introspection) — usually pre-installed on GNOME systems

### 2. Create the hook scripts

Create the directory `~/.claude/hooks/` and add the following scripts:

**`~/.claude/hooks/notify-working.sh`** — Records timestamp and dismisses previous notification:
```bash
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
```

**`~/.claude/hooks/notify-done.sh`** — Writes a stop event with elapsed time:
```bash
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
```

**`~/.claude/hooks/notify-permission.sh`** — Writes a permission event:
```bash
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
```

**`~/.claude/hooks/notify-dismiss.sh`** — Dismisses permission notifications after approval:
```bash
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
```

Make them all executable:
```bash
chmod +x ~/.claude/hooks/notify-*.sh
```

### 3. Create the notification helper

**`~/.claude/hooks/claude-notify.py`** — Python script using GApplication for proper notification replacement and dismissal:
```python
#!/usr/bin/env python3
"""Send or withdraw a GNOME notification with proper per-ID replacement."""
import sys
import json
import gi
gi.require_version('Gio', '2.0')
from gi.repository import Gio, GLib

def main():
    data = json.loads(sys.argv[1])
    action = data.get("action", "send")
    notification_id = data["id"]

    app = Gio.Application.new("com.anthropic.claude", Gio.ApplicationFlags.FLAGS_NONE)
    app.register()

    if action == "withdraw":
        app.withdraw_notification(notification_id)
        return

    title = data["title"]
    body = data["body"]
    urgency = data.get("urgency", "normal")

    icon_path = data.get("icon")
    n = Gio.Notification.new(title)
    n.set_body(body)
    if icon_path:
        icon = Gio.FileIcon.new(Gio.File.new_for_path(icon_path))
        n.set_icon(icon)
    if urgency == "critical":
        n.set_priority(Gio.NotificationPriority.URGENT)

    app.send_notification(notification_id, n)

if __name__ == "__main__":
    main()
```

Make it executable:
```bash
chmod +x ~/.claude/hooks/claude-notify.py
```

Register the app with GNOME by creating `~/.local/share/applications/com.anthropic.claude.desktop`:
```ini
[Desktop Entry]
Type=Application
Name=Claude Code
Icon=/home/YOUR_USER/.claude/hooks/claude-icon.png
Exec=true
NoDisplay=true
```

### 4. Add a notification icon

```bash
curl -L -o ~/.claude/hooks/claude-icon.png "https://claude.ai/images/claude_app_icon.png"
```

### 5. Create the daemon

**`~/.claude/hooks/claude-notify-daemon.sh`** — Host-side daemon that watches for events:
```bash
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
```

Make it executable:
```bash
chmod +x ~/.claude/hooks/claude-notify-daemon.sh
```

### 6. Configure hooks in settings

Add the following `hooks` section to `~/.claude/settings.json`:

```json
"hooks": {
  "UserPromptSubmit": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/notify-working.sh"
        }
      ]
    }
  ],
  "PostToolUse": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/notify-dismiss.sh"
        }
      ]
    }
  ],
  "PermissionRequest": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/notify-permission.sh"
        }
      ]
    }
  ],
  "Stop": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/notify-done.sh"
        }
      ]
    }
  ],
  "SessionEnd": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/notify-dismiss.sh"
        }
      ]
    }
  ]
}
```

### 7. Auto-start on login

Create `~/.config/autostart/claude-notify-daemon.desktop`:
```ini
[Desktop Entry]
Type=Application
Name=Claude Notify Daemon
Comment=Watches Claude Code hook events and triggers notifications
Exec=/home/YOUR_USER/.claude/hooks/claude-notify-daemon.sh --start
Terminal=false
X-GNOME-Autostart-enabled=true
```

### 8. Docker container support

Add these mounts to your devenv compose template so containers share the event directory:
```yaml
volumes:
  # hook events: shared directory for notification daemon
  - ~/.claude/hook-events/:/home/$USERNAME/.claude/hook-events/:rw
  - ~/.claude/hooks/:/home/$USERNAME/.claude/hooks/:ro
```

Also ensure `jq` is installed in the container image (add to Dockerfile).

## Managing the daemon

```bash
~/.claude/hooks/claude-notify-daemon.sh --start    # start in background
~/.claude/hooks/claude-notify-daemon.sh --stop     # stop (kills all instances)
~/.claude/hooks/claude-notify-daemon.sh --status   # check if running
```

Logs are at `/tmp/claude-notify-daemon.log`.

## Configuration

| Setting | Where | Default |
|---|---|---|
| Min seconds before "done" notification | `MIN_SECONDS` in `claude-notify-daemon.sh` | 60 seconds |
| Done sound | `message.oga` in `claude-notify-daemon.sh` | `/usr/share/sounds/freedesktop/stereo/message.oga` |
| Permission sound | `dialog-information.oga` in `claude-notify-daemon.sh` | `/usr/share/sounds/freedesktop/stereo/dialog-information.oga` |

## How to disable

Stop the daemon and remove the hooks from settings:
```bash
~/.claude/hooks/claude-notify-daemon.sh --stop
```

Remove the `"hooks"` block from `~/.claude/settings.json`.

To disable auto-start, remove `~/.config/autostart/claude-notify-daemon.desktop`.

## Troubleshooting

- **Multiple notifications stacking:** Old daemon instances may be running. Run `--stop` then `--start` to clean up.
- **No notifications:** Check `~/.claude/hooks/claude-notify-daemon.sh --status` and `/tmp/claude-notify-daemon.log`.
- **No sound:** Verify `pw-play` works: `pw-play /usr/share/sounds/freedesktop/stereo/message.oga`
- **Notifications not replacing:** Make sure `com.anthropic.claude.desktop` exists in `~/.local/share/applications/`. GNOME's `notify-send --replace-id` does NOT work for tray notifications — the Python GApplication approach is required.
- **"Failed to launch" error on click:** Ensure the `.desktop` file has `Exec=true`.
- **Notifications not dismissing after approval:** Check that `notify-permission.sh` creates the marker file at `/tmp/claude-notify-permission-${SESSION_ID}`.
