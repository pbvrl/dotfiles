#!/usr/bin/env bash

# Go to the next panel to the left if there are any, if there aren't then to the next window.
# When there is only one window, it handles cycling back to the first pane after reaching the last one.

is_leftmost_pane=$(tmux display-message -p '#{pane_at_left}')
if [ "$is_leftmost_pane" -eq 1 ]; then
    window_count=$(tmux display-message -p '#{session_windows}')
    if [ "$window_count" -eq 1 ]; then
        tmux select-pane -L
    else
        tmux previous-window
    fi
else
    tmux select-pane -L
fi
