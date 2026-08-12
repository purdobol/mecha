#!/bin/bash

# Find existing Emacs workspace

EMACS_WS=$(hyprctl clients -j | jq -r '
.[]
| select(.class == "emacs")
| .workspace.id
' | head -n1)

if [ -n "$EMACS_WS" ] && [ "$EMACS_WS" != "null" ]; then
    # Go to Emacs workspace
    hyprctl dispatch "hl.dsp.focus({ workspace = \"$EMACS_WS\" })"

    # Focus Emacs
    hyprctl dispatch "hl.dsp.focus({ window = \"class:^emacs$\" })"
else
    # Start Doom Emacs normally
    emacs &
fi
