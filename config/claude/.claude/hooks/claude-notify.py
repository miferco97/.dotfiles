#!/usr/bin/env python3
"""Send a GNOME notification that replaces previous ones with the same ID."""
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
