#!/bin/bash

workspace=$(hyprctl activeworkspace -j | jq -r '.id')

omarchy-launch-browser --private &

for _ in {1..40}; do
    sleep 0.05

    addr=$(hyprctl clients -j | jq -r '
        [.[] | select(
            .class == "zen" and
            (.title | test("Private|Incognito"))
        )]
        | .[-1].address
    ')

    [[ -n "$addr" && "$addr" != "null" ]] && break
done

if [[ -n "$addr" && "$addr" != "null" ]]; then
    hyprctl dispatch movetoworkspacesilent "$workspace,address:$addr"
    hyprctl dispatch focuswindow "address:$addr"
fi
