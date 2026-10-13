#!/bin/bash

default_sink=$(pactl get-default-sink 2>/dev/null) || exit 0

pactl --format=json list sinks 2>/dev/null | jq -r --arg default_sink "$default_sink" '
  .[] | select(.name == $default_sink)
  | (.properties["alsa.long_card_name"] // .description // .name | split(" at ")[0]) as $name
  | (.properties["api.bluez5.codec"] // .formats[0] // "PCM" | ascii_upcase) as $codec
  | "󰓃 " + $name + " · " + $codec
'
