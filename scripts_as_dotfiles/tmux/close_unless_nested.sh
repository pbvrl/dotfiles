#!/usr/bin/env bash

# Close the current pane, unless it, or any descendant process, contains:
# "ssh", "mosh-client", or "tmux"

pane_pid=$(tmux display-message -p '#{pane_pid}')

queue=("$pane_pid")
while [ ${#queue[@]} -gt 0 ]; do
    current="${queue[0]}"
    queue=("${queue[@]:1}")
    cmd=$(</proc/"$current"/comm)
    case "$cmd" in
        ssh|mosh-client|tmux)
            tmux display-message "Nested session in pane: ($cmd) Avoiding closing. See scripts_as_dotfiles/tmux/close_unless_nested.sh"
            exit 0
            ;;
    esac
    for child in $(pgrep -P "$current"); do
        queue+=("$child")
    done
done

tmux kill-pane
