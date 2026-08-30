#!/usr/bin/env bash
set -euo pipefail

clients=$(hyprctl clients -j)

mapfile -t addresses < <(jq -r '.[] | select(.mapped) | .address' <<<"$clients")
[[ ${#addresses[@]} -gt 0 ]] || exit 0

idx=$(jq -r '.[] | select(.mapped) | "\(.title)\u0000icon\u001f\(.class | ascii_downcase)"' <<<"$clients" \
    | rofi -dmenu -show-icons -format i -p "" -theme ~/.config/rofi/alttab.rasi)

[[ -n "${idx:-}" ]] || exit 0


hyprctl dispatch "hl.dsp.focus({ window = '${addresses[$idx]}' })"
