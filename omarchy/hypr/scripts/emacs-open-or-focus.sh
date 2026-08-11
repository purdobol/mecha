#!/bin/bash

# Find existing Emacs workspace
EMACS_WS=$(hyprctl clients -j | jq -r '
  .[]
  | select(.class == "emacs")
  | .workspace.id
' | head -n1)

if [ -n "$EMACS_WS" ] && [ "$EMACS_WS" != "null" ]; then
    # Go to Emacs workspace
    hyprctl dispatch workspace "$EMACS_WS"

    # Focus Emacs
    hyprctl dispatch focuswindow "class:^emacs$"
else
    # Start Doom Emacs normally
    emacs &
fi
