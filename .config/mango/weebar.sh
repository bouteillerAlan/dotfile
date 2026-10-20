#!/usr/bin/env sh

open_active_bars() {
  # Mango does not expose output names through the protocol Eww uses, so Eww
  # sees them as "Unknown". Use the left-to-right output order for Eww's index.
  mmsg get all-monitors | jq -r '.monitors[] | select(.width > 0) | .name' |
    while IFS= read -r monitor; do
      screen=$(mmsg get all-monitors | jq -r --arg monitor "$monitor" \
        '.monitors | sort_by([.x, .y]) | map(.name) | index($monitor)')
      case "$monitor" in
        DP-4) bar=bar-dp4 ;;
        DP-5) bar=bar-dp5 ;;
        DP-6) bar=bar-dp6 ;;
        eDP-1) bar=bar-edp1 ;;
        HDMI-A-1) bar=bar-hdmi1 ;;
        *) continue ;;
      esac

      notify-send "Mango" "eww active @ $bar, $monitor"
      eww active-windows | grep -Fq "$bar:" || eww open "$bar" --screen "$screen"
    done
}

open_active_bars

"$@"
