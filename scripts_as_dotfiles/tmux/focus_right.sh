#!/usr/bin/env bash

# Go to the next panel to the right if there are any, if there aren't then to the next window.
# When there is only one window, it handles cycling back to the first pane after reaching the last one.

is_rightmost_pane=$(tmux display-message -p '#{pane_at_right}')
if [ "$is_rightmost_pane" -eq 1 ]; then
    window_count=$(tmux display-message -p '#{session_windows}')
    if [ "$window_count" -eq 1 ]; then
        tmux select-pane -R
    else
        tmux next-window
    fi
else
    tmux select-pane -R
fi
