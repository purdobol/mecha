#!/bin/bash

workspace=$(hyprctl activeworkspace -j | jq -r '.id')

omarchy-launch-browser --private &

addr=""

for _ in {1..40}; do
    sleep 0.05

    addr=$(hyprctl clients -j | jq -r '
        [.[] | select(
            .class == "zen" and
            (.title | test("Private|Incognito"))
        )]
        | .[-1].address
    ')

    if [[ -n "$addr" && "$addr" != "null" ]]; then
        break
    fi
done

if [[ -n "$addr" && "$addr" != "null" ]]; then
    # Move the private browser window silently to the workspace
    hyprctl dispatch "hl.dsp.window.move({ workspace = \"$workspace\", follow = false, window = \"address:$addr\" })"

    # Focus the private browser window
    hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })"
fi
