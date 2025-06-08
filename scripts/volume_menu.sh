#!/bin/bash

volume=$(pamixer --get-volume)
mute=$(pamixer --get-mute)
mute_icon=$([ "$mute" = true ] && echo "🔇" || echo "🔊")

options="$mute_icon 静音/取消静音
🎧 选择输出设备
🎵 媒体控制
🎛️ 打开音量控制器"

choice=$(echo -e "$options" | rofi -dmenu -p "当前音量: $volume%")

case "$choice" in
"🔇 静音/取消静音" | "🔊 静音/取消静音") pamixer -t ;;
"🎧 选择输出设备")
  options=""
  while IFS=$'\t' read -r index name rest; do
    desc=$(pactl list sinks | awk -v n="$name" '
      $0 ~ "Name: "n {found=1}
      found && /Description:/ {print; exit}
    ' | cut -d: -f2- | sed 's/^ *//')
    if [[ -n "$desc" ]]; then
      options+="${name} (${desc})"$'\n'
    fi
  done < <(pactl list short sinks)

  # 删除末尾最后一个换行符，防止空项
  options=$(echo -n "$options" | sed '/^$/d')

  selected=$(echo -e "$options" | rofi -dmenu -p "请选择输出设备：")
  device=$(echo "$selected" | awk '{print $1}')
  [[ -n "$device" ]] && pactl set-default-sink "$device"
  ;;
"🎵 媒体控制")
  media_option=$(echo -e "▶️ 播放/暂停\n⏭️ 下一首\n⏮️ 上一首\n🎶 当前播放信息" | rofi -dmenu -p "媒体控制选项：")
  case "$media_option" in
  "▶️ 播放/暂停") playerctl play-pause ;;
  "⏭️ 下一首") playerctl next ;;
  "⏮️ 上一首") playerctl previous ;;
  "🎶 当前播放信息") notify-send "当前播放" "$(playerctl metadata artist) - $(playerctl metadata title)" ;;
  esac
  ;;
"🎛️ 打开音量控制器") pavucontrol ;;
esac
