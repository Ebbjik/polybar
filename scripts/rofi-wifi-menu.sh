#!/bin/bash

# 加载提示，最多持续 5 秒
timeout 5s bash -c 'echo "正在扫描，请稍候..." | rofi --no-lazy-grab -dmenu -p "Wi-Fi" -lines 1' &
scan_pid=$!

# 触发 Wi-Fi 扫描
nmcli dev wifi rescan >/dev/null 2>&1

# 最多等待 5 秒，每 0.5 秒检查一次 Wi-Fi 列表是否有数据
for i in {1..10}; do
  sleep 0.5
  wifi_list=$(nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE dev wifi | grep -v '^:$')
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

# 处理列表，去重并选信号最强，格式：带锁图标（🔒）的SSID | 状态 | 信号
processed_list=$(echo "$wifi_list" | awk -F: '
{
  ssid=$1;
  signal=$2;
  security=$3;
  in_use=$4;
  if(ssid == "") next;

  # 判断是否加锁
  locked = (security ~ /^--*$/ || security ~ /^[[:space:]]*$/) ? 0 : 1;

  if (!(ssid in max_signal) || signal > max_signal[ssid]) {
    max_signal[ssid] = signal;
    max_security[ssid] = security;
    max_inuse[ssid] = in_use;
  }
}
END {
  for (s in max_signal) {
    sec = max_security[s];
    locked = (sec ~ /^--*$/ || sec ~ /^[[:space:]]*$/) ? 0 : 1;
    prefix = locked ? "🔒" : "";
    status = (max_inuse[s] == "*") ? "|已连接" : "";
    # 注意：将 signal 放到最前面，供 sort 使用
    print max_signal[s] "|" prefix s status "|" "📶" max_signal[s] "%";
  }
}' | sort -t'|' -k1 -nr | cut -d'|' -f2-)

# 第一层菜单：选择网络（只显示SSID + 状态 + 信号）
selected_line=$(echo "$processed_list" | rofi --no-lazy-grab -dmenu -p "选择 Wi-Fi 网络" -format 'i s')

if [ -z "$selected_line" ]; then
  exit 0
fi

selected_content=$(echo "$selected_line" | cut -d' ' -f2-)
raw_ssid=$(echo "$selected_content" | cut -d'|' -f1 | sed 's/^🔒//;s/[[:space:]]*$//')
selected_status=$(echo "$selected_content" | cut -d'|' -f2 | tr -d ' ')

# 操作菜单
actions="连接\n忘记网络\n取消"
action=$(echo -e "$actions" | rofi --no-lazy-grab -dmenu -p "操作: $raw_ssid")

if [ "$action" == "取消" ] || [ -z "$action" ]; then
  exit 0
fi

if [ "$action" == "忘记网络" ]; then
  con_name=$(nmcli -t -f NAME connection show | grep -Fx "$raw_ssid" | head -n1)
  if [ -n "$con_name" ]; then
    nmcli connection delete "$con_name"
    notify-send "Wi-Fi" "已忘记网络: $raw_ssid"
  else
    notify-send "Wi-Fi" "未找到该网络配置"
  fi
  exit 0
fi

if [ "$action" == "连接" ]; then
  if [ "$selected_status" == "已连接" ]; then
    notify-send "Wi-Fi" "已经连接到 $raw_ssid"
    exit 0
  fi

  nmcli dev wifi connect "$raw_ssid"

  if [ $? -eq 0 ]; then
    notify-send "Wi-Fi" "成功连接到 $raw_ssid"
  else
    notify-send "Wi-Fi" "连接失败，请检查密码或网络"
  fi
fi
