#!/bin/bash

# Install Claude Code
if ! command -v claude &> /dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

# Install dependencies
sudo apt install -y jq inotify-tools pipewire

# Create directories
mkdir -p ~/.claude/hooks
mkdir -p ~/.claude/hook-events

# Copy hook scripts
SCRIPT_DIR="$(dirname "$0")/../config/claude/.claude/hooks"
cp "$SCRIPT_DIR"/notify-working.sh ~/.claude/hooks/
cp "$SCRIPT_DIR"/notify-done.sh ~/.claude/hooks/
cp "$SCRIPT_DIR"/notify-permission.sh ~/.claude/hooks/
cp "$SCRIPT_DIR"/notify-dismiss.sh ~/.claude/hooks/
cp "$SCRIPT_DIR"/claude-notify.py ~/.claude/hooks/
cp "$SCRIPT_DIR"/claude-notify-daemon.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/notify-*.sh ~/.claude/hooks/claude-notify-daemon.sh ~/.claude/hooks/claude-notify.py

# Download Claude icon
if [ ! -f ~/.claude/hooks/claude-icon.png ]; then
  curl -L -o ~/.claude/hooks/claude-icon.png "https://claude.ai/images/claude_app_icon.png" 2>/dev/null
fi

# Register GNOME app for notification replacement
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/com.anthropic.claude.desktop << EOF
[Desktop Entry]
Type=Application
Name=Claude Code
Icon=$HOME/.claude/hooks/claude-icon.png
Exec=true
NoDisplay=true
EOF
update-desktop-database ~/.local/share/applications/ 2>/dev/null

# Auto-start daemon on login
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/claude-notify-daemon.desktop << EOF
[Desktop Entry]
Type=Application
Name=Claude Notify Daemon
Comment=Watches Claude Code hook events and triggers notifications
Exec=$HOME/.claude/hooks/claude-notify-daemon.sh --start
Terminal=false
X-GNOME-Autostart-enabled=true
EOF

# Start daemon now
~/.claude/hooks/claude-notify-daemon.sh --start

echo "Claude Code hooks setup complete"
