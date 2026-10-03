#!/bin/bash
pacman=$(checkupdates 2>/dev/null)
aur=$(yay -Qua 2>/dev/null)

pcount=$(echo -n "$pacman" | grep -c . )
acount=$(echo -n "$aur" | grep -c . )

pacman_list=$(printf '%s' "$pacman" | jq -R -s -c 'split("\n") | map(select(length>0))')
aur_list=$(printf '%s' "$aur" | jq -R -s -c 'split("\n") | map(select(length>0))')

jq -n -c \
  --arg text "󰏖 $pcount/$acount" \
  --argjson pacman "$pacman_list" \
  --argjson aur "$aur_list" \
  '{
    text: $text,
    tooltip: ("PACMAN:\n" + ($pacman | join("\n")) + "\n\nAUR:\n" + ($aur | join("\n")))
  }'
