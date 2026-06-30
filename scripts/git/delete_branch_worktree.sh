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
selected_branch=$(echo "$worktree_branches" | gum choose --header="Choose a worktree to remove:")
# Check if the user canceled the prompt
if [[ -z "$selected_branch" ]]; then
    exit 0
fi

# Get the worktree path for the selected branch
worktree_path="$HOME/projects/$project_name/$selected_branch"
# Prompt for confirmation before removing the worktree and deleting the branch
if gum confirm "Are you sure you want to remove the worktree and delete the local branch '$selected_branch'?"; then
    # Remove the worktree
    if git worktree remove --force "$worktree_path"; then
        gum style --foreground 33 "Worktree removed successfully: $selected_branch"
    else
        gum style --foreground 196 "Failed to remove the worktree: $selected_branch"
        exit 1
    fi
    # Delete the local branch
    if git branch -D "$selected_branch"; then
        gum style --foreground 33 "Local branch deleted successfully: $selected_branch"
    else
        gum style --foreground 220 "Failed to delete the local branch: $selected_branch. If it was a local detached head, then it was already removed with the worktree."
    fi
else
    gum style --foreground 33 "Worktree removal and branch deletion canceled."
fi
