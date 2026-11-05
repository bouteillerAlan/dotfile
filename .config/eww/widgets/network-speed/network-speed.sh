#!/bin/bash
# Keep the sampling wait outside Eww's polling tasks

previous_interface=""
previous_rx=0
previous_tx=0
previous_time=0

while true; do
  interface=$(nmcli -t -f DEVICE,TYPE,STATE device 2>/dev/null |
    awk -F: '$3 == "connected" {print $1; exit}')
  statistics="/sys/class/net/$interface/statistics"

  if [[ -n "$interface" ]] &&
    read -r rx < "$statistics/rx_bytes" &&
    read -r tx < "$statistics/tx_bytes" &&
    read -r now _ < /proc/uptime; then
    if [[ "$interface" == "$previous_interface" ]]; then
      awk -v rx="$rx" -v tx="$tx" -v previous_rx="$previous_rx" -v previous_tx="$previous_tx" \
        -v now="$now" -v previous_time="$previous_time" '
        function format_speed(value) {
          if (value >= 1048576) return sprintf("%4.1fM", value / 1048576)
          if (value >= 1024) return sprintf("%4.1fK", value / 1024)
          return sprintf("%4.0fB", value)
        }
        BEGIN {
          elapsed = now - previous_time
          down = elapsed > 0 && rx >= previous_rx ? (rx - previous_rx) / elapsed : 0
          up = elapsed > 0 && tx >= previous_tx ? (tx - previous_tx) / elapsed : 0
          printf "↑ %s ↓ %s\n", format_speed(up), format_speed(down)
        }'
    else
      printf '↑    0B ↓    0B\n'
    fi
    previous_interface="$interface"
    previous_rx="$rx"
    previous_tx="$tx"
    previous_time="$now"
  else
    previous_interface=""
    printf '↑    0B ↓    0B\n'
  fi
  sleep 1
done
