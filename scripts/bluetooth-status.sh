# #!/bin/bash
#
# if ! bluetoothctl show | grep -q "Powered: yes"; then
#   echo " Disabled"
#   exit 0
# fi
#
# devices=$(bluetoothctl devices)
#
# if [ -z "$devices" ]; then
#   # 蓝牙开着，但没配对设备
#   echo " On"
#   exit 0
# fi
#
# connected_device=""
#
# while IFS= read -r line; do
#   mac=$(echo "$line" | awk '{print $2}')
#   name=$(echo "$line" | cut -d ' ' -f 3-)
#   if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
#     connected_device="$name"
#     break
#   fi
# done <<<"$devices"
#
# if [ -z "$connected_device" ]; then
#   echo " On"
# else
#   echo " On: $connected_device"
# fi
#!/bin/bash

if ! bluetoothctl show | grep -q "Powered: yes"; then
  echo " Disabled"
  exit 0
fi

devices=$(bluetoothctl devices)

if [ -z "$devices" ]; then
  echo " On"
  exit 0
fi

connected_device=""
battery=""

while IFS= read -r line; do
  mac=$(echo "$line" | awk '{print $2}')
  name=$(echo "$line" | cut -d ' ' -f 3-)
  if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
    connected_device="$name"

    battery_info=$(bluetoothctl info "$mac" | grep "Battery Percentage" | awk '{print $3}')

    if [[ "$battery_info" == 0x* ]]; then
      # 转换16进制电量到10进制
      battery_dec=$((battery_info))
      battery=" (${battery_dec}%)"
    elif [ -n "$battery_info" ]; then
      battery=" (${battery_info}%)"
    else
      if echo "$name" | grep -Ei "headset|headphone|earbud|airpods" >/dev/null; then
        battery=" (Battery unknown)"
      fi
    fi

    break
  fi
done <<<"$devices"

if [ -z "$connected_device" ]; then
  echo " On"
else
  echo " On: $connected_device$battery"
fi
