#!/bin/bash

sleep 3

hyprctl dispatch "hl.dsp.focus({ workspace = \"9\" })"

emacs
