#!/bin/bash

render() {
  local sink_inputs sinks

  sink_inputs=$(pactl --format=json list sink-inputs 2>/dev/null) || {
    printf '%s\n' '{"text":"","class":"hidden"}'
    return
  }
  sinks=$(pactl --format=json list sinks 2>/dev/null) || {
    printf '%s\n' '{"text":"","class":"hidden"}'
    return
  }

  jq -cn --argjson sink_inputs "$sink_inputs" --argjson sinks "$sinks" '
    def shorten($limit): if length > $limit then .[0:$limit] + "…" else . end;
    [$sink_inputs[] | select(.corked == false) | .sink] | unique as $active_sinks
    | [$sinks[] | select(.index as $index | $active_sinks | index($index))] as $sinks
    | if ($sinks | length) == 0 then
        {text: "", class: "hidden"}
      elif ($sinks | length) == 1 then
        $sinks[0] as $sink
        | ($sink.description // $sink.name) as $full_name
        | ($full_name | shorten(10)) as $name
        | ($sink.properties["api.bluez5.codec"] // "") as $codec
        | if $codec == "" then
            {text: ("󰓃 " + $name), tooltip: $full_name, class: "active"}
          else
            {text: (" " + $name + " · " + ($codec | ascii_upcase)), tooltip: ($full_name + "\nCodec: " + ($codec | ascii_upcase)), class: ["active", "bluetooth"]}
          end
      else
        [$sinks[] | (.description // .name) + (if .properties["api.bluez5.codec"] then " · " + (.properties["api.bluez5.codec"] | ascii_upcase) else "" end)] as $names
        | {text: ("󰓃 " + ($sinks | length | tostring) + " outputs"), tooltip: ($names | join("\n")), class: ["active", "multiple"]}
      end
  '
}

render
pactl subscribe 2>/dev/null | while IFS= read -r event; do
  case "$event" in
    *" on sink #"* | *" on sink-input #"* | *" on server #"*)
      render
      ;;
  esac
done
