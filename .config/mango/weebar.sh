#!/usr/bin/env sh

open_active_bars() {
  mmsg get all-monitors | jq -r '.monitors[] | select(.width > 0) | .name' |
    while IFS= read -r monitor; do
      case "$monitor" in
        DP-4) bar=bar-dp4 ;;
        DP-5) bar=bar-dp5 ;;
        DP-6) bar=bar-dp6 ;;
        eDP-1) bar=bar-edp1 ;;
        HDMI-A-1) bar=bar-hdmi1 ;;
        *) continue ;;
      esac

      eww active-windows | grep -Fq "$bar:" || eww open "$bar" --screen "$monitor"
    done
}
open_active_bars

"$@"
