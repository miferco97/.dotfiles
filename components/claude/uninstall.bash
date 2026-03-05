#!/bin/bash
set -e

# Stop the notification daemon
if [ -f ~/.claude/hooks/claude-notify-daemon.sh ]; then
    ~/.claude/hooks/claude-notify-daemon.sh --stop 2>/dev/null || true
fi

# Remove autostart entry
rm -f ~/.config/autostart/claude-notify-daemon.desktop

# Remove desktop file
rm -f ~/.local/share/applications/com.anthropic.claude.desktop
update-desktop-database ~/.local/share/applications/ 2>/dev/null || true

# Remove hook-events directory
rm -rf ~/.claude/hook-events

echo "Claude Code hooks uninstalled."
