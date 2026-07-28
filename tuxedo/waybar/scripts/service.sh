#!/bin/bash
services=$(systemctl --user list-units --type=service --state=running --no-legend | awk '{print $1}' | sed 's/\.service//')
count=$(echo "$services" | grep -c .)
tooltip=$(echo "$services" | tr '\n' '\n')

jq -nc --arg text "  $count " --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip}'
