#!/bin/bash

# 自动检测默认网络接口
INTERFACE=$(ip route | awk '/default/ {print $5; exit}')

# 获取当前 Wi-Fi 名称（如果是无线接口）
WIFI_NAME=$(iwgetid -r)
# 设置 Wi-Fi 图标（如果不是 Wi-Fi，就不显示）
if [ -n "$WIFI_NAME" ]; then
  WIFI_ICON=""
else
  WIFI_ICON=""
  WIFI_NAME=""
fi

# 获取前一秒的收发字节数
rx_prev=$(cat /sys/class/net/"$INTERFACE"/statistics/rx_bytes)
tx_prev=$(cat /sys/class/net/"$INTERFACE"/statistics/tx_bytes)
sleep 1
rx_now=$(cat /sys/class/net/"$INTERFACE"/statistics/rx_bytes)
tx_now=$(cat /sys/class/net/"$INTERFACE"/statistics/tx_bytes)

# 计算速率（KB/s）
rx_rate=$(((rx_now - rx_prev) / 1024))
tx_rate=$(((tx_now - tx_prev) / 1024))

# 格式化速率显示
if [ "$rx_rate" -ge 1024 ]; then
  rx_disp=$(awk "BEGIN {printf \"%.1f MB/s\", $rx_rate/1024}")
else
  rx_disp="${rx_rate} KB/s"
fi

if [ "$tx_rate" -ge 1024 ]; then
  tx_disp=$(awk "BEGIN {printf \"%.1f MB/s\", $tx_rate/1024}")
else
  tx_disp="${tx_rate} KB/s"
fi

# 输出：Wi-Fi图标 + 名称 ↓ x ↑ x
if [ -n "$WIFI_NAME" ]; then
  echo "$WIFI_ICON $WIFI_NAME  $rx_disp  $tx_disp"
else
  echo " $rx_disp  $tx_disp"
fi
