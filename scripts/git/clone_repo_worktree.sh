#!/usr/bin/env bash

# Prompt for the clone URL using gum
clone_url=$(gum input --placeholder "Enter the clone URL")
# Check if the user canceled the prompt
if [[ -z "$clone_url" ]]; then
    exit 0
fi
# Extract the repository name from the URL
repo_name=$(basename "$clone_url" .git)
# Create the project folder
project_folder="$HOME/projects/$repo_name"
mkdir -p "$project_folder"
# Clone the repository as a bare repository
git clone --bare "$clone_url" "$project_folder/.bare"
# Determine the main branch
echo "Clone url: $clone_url"
cd $project_folder/.bare
main_branch=$(git remote show $clone_url | grep "HEAD branch" | sed 's/.*: //')
# Set up the worktree for the main branch
echo "gitdir: ./.bare" >"$project_folder/.git"
git -C "$project_folder" worktree add "$main_branch"
# Move into the main worktree in a new tmux session
export PATH="$HOME/.cargo/bin:$PATH"
sesh connect "$project_folder/$main_branch"
