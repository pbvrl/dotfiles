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
# Prompt for the branch name using gum
branch_name=$(gum input --placeholder "Enter the branch name")
# Check if the user canceled the prompt
if [[ -z "$branch_name" ]]; then
    exit 0
fi
# Get the current commit hash
commit_hash=$(git rev-parse HEAD)
# Create the detached branch using worktree
git worktree add "../$branch_name" "$commit_hash"
# Check if the worktree creation was successful
if [[ $? -ne 0 ]]; then
    gum style --foreground 196 "Failed to create the new detached branch."
    exit 1
fi
# Move into the new detached branch folder in a new tmux session
export PATH="$HOME/.cargo/bin:$PATH"
sesh connect "$HOME/projects/$project_name/$branch_name"
