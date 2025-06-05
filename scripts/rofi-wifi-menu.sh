#!/bin/bash

# 显示“正在扫描，请稍候...”提示
rofi -e "正在扫描，请稍候..."

# 触发扫描并等待1秒
nmcli dev wifi rescan >/dev/null 2>&1 &
sleep 1

# 获取 Wi-Fi 列表
wifi_list=$(nmcli -f SSID,SIGNAL dev wifi | tail -n +2 | grep -v '^--' | awk 'NF >= 2')

# 按 SSID 分组，取信号最强的
top_networks=$(echo "$wifi_list" | awk '
{
    signal[$1] = ($2 > signal[$1]) ? $2 : signal[$1];
}
END {
    for (s in signal)
        print s;
}
' | sort)

# rofi 选择
selected=$(echo "$top_networks" | rofi -dmenu -p "Select Wi-Fi Network:")

# 尝试连接
if [ -n "$selected" ]; then
  nmcli dev wifi connect "$selected"
fi
