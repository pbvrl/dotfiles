#!/usr/bin/env bash
 
# Toggle a window with lazygit running on the working dir of the current tmux session

export PATH="$HOME/.cargo/bin:$PATH" # git-delta
LAZYGIT_WINDOW="lazygit"
CURRENT_WINDOW=$(tmux display-message -p "#{window_name}")
EXISTS=$(tmux list-windows -F "#{window_name}" | awk -v win_name="$LAZYGIT_WINDOW" '$0 == win_name')
if [ "$CURRENT_WINDOW" = $LAZYGIT_WINDOW ]; then
	tmux last-window
elif [ -n "$EXISTS" ]; then
	tmux select-window -t $LAZYGIT_WINDOW
else
	tmux new-window -b -n $LAZYGIT_WINDOW "lazygit"
fi

