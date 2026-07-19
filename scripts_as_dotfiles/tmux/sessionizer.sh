#!/usr/bin/env bash

# https://github.com/joshmedeski/sesh

# Requires:
#  zoxide
#  sesh
#  fzf
#  tmux-fzf
#  fd

SELF_PATH="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$(basename -- "${BASH_SOURCE[0]}")"
FD_CMD=$(command -v fd)
SESH_CMD=$(command -v sesh)

find_dirs() {
    # Project dirs, including worktree projects
    if [[ -d "$HOME/projects" ]]; then
        "$FD_CMD" -H -d 1 -t d -E .Trash "" "$HOME/projects/" | while read -r dir; do
            if [ -d "$dir/.bare" ]; then
                if [ -d "$dir/master" ]; then
                    echo "$dir/master"
                elif [ -d "$dir/main" ]; then
                    echo "$dir/main"
                else
                    echo "$dir"
                fi
            else
                echo "$dir"
            fi
        done
    fi
    # Other dirs
    for dir in "$HOME/.config/nixos/" "$HOME/notes/"; do
        if [[ -d "$dir" ]]; then
            echo "$dir"
        fi
    done
}
if [[ "$1" == "--find" ]]; then
    find_dirs
    exit 0
fi

selection=$(
    "$SESH_CMD" list -t | fzf-tmux -p 40%,70% \
        --no-sort --prompt '📁  ' --reverse \
        --color=bg:#1c1c1c,bg+:#1c1c1c,fg:#e4e4e4 \
        --header '  ^a all ^t tmux ^x zoxide ^f find' \
        --bind 'tab:down,btab:up' \
        --bind "ctrl-a:change-prompt(⚡  )+reload($SESH_CMD list)" \
        --bind "ctrl-t:change-prompt(🪟  )+reload($SESH_CMD list -t)" \
        --bind "ctrl-x:change-prompt(📁  )+reload($SESH_CMD list -z)" \
        --bind "ctrl-f:change-prompt(🔎  )+reload(FD_CMD='$FD_CMD' '$SELF_PATH' --find)" \
)
"$SESH_CMD" connect "$selection"
