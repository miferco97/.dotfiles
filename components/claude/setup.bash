#!/bin/bash
set -e

# Install Claude Code CLI
if ! command -v claude &> /dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
fi

# Create directories
mkdir -p ~/.claude/hooks
mkdir -p ~/.claude/hook-events

# Download Claude icon
if [ ! -f ~/.claude/hooks/claude-icon.png ]; then
    curl -L -o ~/.claude/hooks/claude-icon.png "https://claude.ai/images/claude_app_icon.png" 2>/dev/null || true
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
update-desktop-database ~/.local/share/applications/ 2>/dev/null || true

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
if [ -f ~/.claude/hooks/claude-notify-daemon.sh ]; then
    ~/.claude/hooks/claude-notify-daemon.sh --start || true
fi

echo "Claude Code hooks setup complete."
