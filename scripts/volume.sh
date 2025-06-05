#!/bin/bash

DEVICE=$(wpctl status | grep -A 5 'Sinks:' | grep '\*' | sed 's/│//g' | awk '{print $2}')

if [ -z "$DEVICE" ]; then
  echo "无法获取默认音频设备ID"
  exit 1
fi

muted=$(wpctl get-mute "$DEVICE")
vol=$(wpctl get-volume "$DEVICE" | awk '{print $2}')

vol_percent=0
if [ -n "$vol" ]; then
  vol_percent=$(awk "BEGIN {printf \"%d\", $vol * 100}")
fi

if [ "$muted" = "true" ] || [ "$vol_percent" -eq 0 ]; then
  icon=""
elif [ "$vol_percent" -le 50 ]; then
  icon=""
else
  icon=""
fi

echo "$icon $vol_percent%"
