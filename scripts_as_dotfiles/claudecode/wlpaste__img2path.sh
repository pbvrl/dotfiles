#!/usr/bin/env bash

# For pasting images into claude-code.

# This script is assigned a keybinding in tmux, where claudecode runs.
# https://github.com/anthropics/claude-code/issues/834#issuecomment-3145895993

# Requires:
#   wl-paste

: '
Checks the system clipboard.
  If it is an image, save it to a temp file and print the file path.
  If it is text, print the text.
'

clipboard_types=$(wl-paste --list-types)
if echo "$clipboard_types" | grep -q "image/png"; then
    IMG_PATH="/tmp/paste-$(date +%s).png"
    wl-paste --type "image/png" > "$IMG_PATH"
    echo "$IMG_PATH"
elif echo "$clipboard_types" | grep -q "text/plain"; then
    wl-paste --no-newline
fi
