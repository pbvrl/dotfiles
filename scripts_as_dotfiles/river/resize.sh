#!/usr/bin/env bash

# Requires:
#   gum

DELTA_W=$(gum input --prompt "Width delta: " --placeholder "e.g. 100 or -100" --value 0)
DELTA_H=$(gum input --prompt "Height delta: " --placeholder "e.g. 100 or -100" --value 0)
DELTA_Y0=$(gum input --prompt "y0 delta: " --placeholder "e.g. 100 or -100" --value 0)
for tag in 4096 8192 16384 32768 65536; do
    riverctl set-focused-tags "$tag"
    riverctl resize horizontal "$DELTA_W"
    riverctl resize vertical "$DELTA_H"
    riverctl move up "$DELTA_Y0"
done
riverctl set-focused-tags 1
