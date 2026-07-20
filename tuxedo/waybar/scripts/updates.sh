#!/bin/bash

pacman=$(checkupdates 2>/dev/null)
aur=$(yay -Qua 2>/dev/null)

pcount=$(echo "$pacman" | grep -c .)
acount=$(echo "$aur" | grep -c .)

tooltip="PACMAN:\n$pacman\n\nAUR:\n$aur"

if [ "$pcount" = "0" ]; then
    tooltip="PACMAN:\nAucune mise à jour"
fi

if [ "$acount" = "0" ]; then
    tooltip="$tooltip\n\nAUR:\nAucune mise à jour"
fi

printf '{"text":"󰏖 %s/%s","tooltip":"%s"}\n' "$pcount" "$acount" "$tooltip"
