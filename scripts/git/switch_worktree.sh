#!/usr/bin/env bash

# Get the current directory
current_dir=$(pwd)
# Check if the current directory is a subfolder of a subfolder of ~/projects
if [[ "$current_dir" != "$HOME/projects/"*/* ]]; then
    gum style --foreground 196 "This script must be run from a subfolder of a subfolder of ~/projects."
    exit 1
fi
# Extract the project name from the parent directory of the current directory
project_name=$(basename "$(dirname "$current_dir")")
# Get the list of branches and detached branches checked out in worktrees
worktree_branches=$(git worktree list --porcelain | awk '/^worktree/ {worktree=$2} /^branch|^detached/ {if ($1 == "branch") {sub(/^refs\/heads\//, "", $2); print $2} else if ($1 == "detached") {sub(/.*\//, "", worktree); print worktree}}')
# Check if there are any worktree branches
if [[ -z "$worktree_branches" ]]; then
    gum style --foreground 33 "No branches are checked out in worktrees."
    exit 0
fi

# Prompt the user to select a branch using gum
selected_branch=$(echo "$worktree_branches" | gum choose --header="Choose a branch to connect to:")
# Check if the user canceled the prompt
if [[ -z "$selected_branch" ]]; then
    exit 0
fi

# Check if the selected branch is the current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$selected_branch" == "$current_branch" ]]; then
    gum style --foreground 33 "You are already on the selected branch: $selected_branch"
    exit 0
fi
# Check if the worktree for the selected branch exists
worktree_path="$HOME/projects/$project_name/$selected_branch"
if [[ ! -d "$worktree_path" ]]; then
    gum style --foreground 196 "Worktree for the selected branch does not exist: $selected_branch"
    exit 1
fi
# Connect to the worktree in a new tmux session
export PATH="$HOME/.cargo/bin:$PATH"
sesh connect "$worktree_path"
