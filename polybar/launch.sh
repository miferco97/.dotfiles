#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use
# polybar-msg cmd quit

# Launch bar1 and bar
polybar example &

bool_external_monitor=$(xrandr | grep "HDMI-0 connected")
if [[ $bool_external_monitor != "" ]]; then
    polybar top_external &
fi
echo "Bars launched..."

