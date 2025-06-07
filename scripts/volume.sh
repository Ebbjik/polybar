#!/bin/bash

DEFAULT_SINK=$(pactl info | grep 'Default Sink' | cut -d ':' -f2 | xargs)

muted=$(pactl get-sink-mute "$DEFAULT_SINK" | awk '{print $2}')
vol=$(pactl get-sink-volume "$DEFAULT_SINK" | head -n1 | grep -oP '\d+?(?=%)' | head -n1)

if [ "$muted" = "yes" ]; then
  icon="" # 静音图标，只显示图标
  echo "$icon"
else
  if [ "$vol" -le 50 ]; then
    icon=""
  else
    icon=""
  fi
  echo "$icon $vol%"
fi
