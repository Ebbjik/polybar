#!/bin/bash

# Kill existing polybar instances
killall -q polybar

# Wait until processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch polybar
polybar mybar &

echo "Polybar launched..."
