#!/usr/bin/env bash

# Requires:
#   tmux-fzf

function command_palette() {
	local options=("Clone repo" "New repo" "Clone repo - worktree" "New repo - worktrees" "Switch worktree" "New branch - worktrees" "New branch from remote" "New branch detached head" "Delete branch - worktrees")
	local selected=$(printf "%s\n" "${options[@]}" | fzf-tmux -p 55%,60% --reverse --color=bg:#1c1c1c,bg+:#1c1c1c,fg:#e4e4e4 --bind 'tab:down,btab:up')
	case $selected in
	"Clone repo")
		~/.config/nixos/scripts/git/clone_repo.sh
		;;
	"New repo")
		~/.config/nixos/scripts/git/new_repo.sh
		;;
	"Clone repo - worktrees")
		~/.config/nixos/scripts/git/clone_repo_worktree.sh
		;;
	"New repo - worktrees")
		~/.config/nixos/scripts/git/new_repo_worktree.sh
		;;
	"Switch worktree")
		~/.config/nixos/scripts/git/switch_worktree.sh
		;;
	"New branch - worktrees")
		~/.config/nixos/scripts/git/new_branch_worktree.sh
		;;
	"New branch from remote")
		~/.config/nixos/scripts/git/new_branch_from_remote_worktree.sh
		;;
	"Delete branch - worktrees")
		~/.config/nixos/scripts/git/delete_branch_worktree.sh
		;;
	"New branch detached head")
		~/.config/nixos/scripts/git/new_branch_detached_head_worktree.sh
		;;
	*)
		echo "Invalid selection"
		;;
	esac
}

if [[ $# -eq 1 ]]; then
	command_palette "$1"
else
	command_palette
fi
