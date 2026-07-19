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
# Fetch the list of remote branches
remote_branches=$(git branch | sed 's/^[[:space:]]*origin\///g' | grep -v HEAD | sed 's/^[[:space:]]*//g')
# Check if there are any remote branches
if [[ -z "$remote_branches" ]]; then
    gum style --foreground 33 "No remote branches found."
    exit 0
fi

# Prompt the user to select a branch using gum
selected_branch=$(echo "$remote_branches" | gum choose --header="Choose a branch to create a worktree for:")
# Check if the user canceled the prompt
if [[ -z "$selected_branch" ]]; then
    exit 0
fi

# Create the worktree for the selected branch
git worktree add "../$selected_branch" "$selected_branch"
# Check if the worktree creation was successful
if [[ $? -ne 0 ]]; then
    gum style --foreground 196 "Failed to create the worktree for the selected branch."
    exit 1
fi
# Move into the new worktree in a new tmux session
export PATH="$HOME/.cargo/bin:$PATH"
sesh connect "$HOME/projects/$project_name/$selected_branch"
