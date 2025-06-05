#!/bin/bash

# 加载提示，最多持续 5 秒
timeout 5s bash -c 'echo "正在扫描，请稍候..." | rofi --no-lazy-grab -dmenu -p "Wi-Fi" -lines 1' &
scan_pid=$!

# 触发 Wi-Fi 扫描
nmcli dev wifi rescan >/dev/null 2>&1

# 最多等待 5 秒，每 0.5 秒检查一次 Wi-Fi 列表是否有数据
for i in {1..10}; do
  sleep 0.5
  wifi_list=$(nmcli -f SSID,SIGNAL dev wifi | tail -n +2 | grep -v '^--' | awk 'NF >= 2')
  if [ -n "$wifi_list" ]; then
    break
  fi
done

# 杀掉加载提示（即使已经退出也无妨）
kill "$scan_pid" 2>/dev/null

# 如果仍然没有 Wi-Fi 网络，提示错误
if [ -z "$wifi_list" ]; then
  rofi --no-lazy-grab -e "未发现任何 Wi-Fi 网络"
  exit 1
fi

# 选择信号最强的网络（去重并排序）
top_networks=$(echo "$wifi_list" | awk '
{
    signal[$1] = ($2 > signal[$1]) ? $2 : signal[$1];
}
END {
    for (s in signal)
        print s;
}
' | sort)

# 弹出 Rofi 供用户选择网络
selected=$(echo "$top_networks" | rofi --no-lazy-grab -dmenu -p "选择 Wi-Fi 网络")

# 连接 Wi-Fi
if [ -n "$selected" ]; then
  nmcli dev wifi connect "$selected"
fi
