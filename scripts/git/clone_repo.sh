#!/usr/bin/env bash

# Prompt for the clone URL
clone_url=$(gum input --placeholder "Enter the clone URL")
# Check if the user canceled the prompt
if [[ -z "$clone_url" ]]; then
    exit 0
fi
# Extract the repository name from the URL
repo_name=$(basename "$clone_url" .git)
# Clone the repository inside ~/projects/
mkdir -p "$HOME/projects"
git clone "$clone_url" "$HOME/projects/$repo_name"
# Move into the cloned repository in a new tmux session
export PATH="$HOME/.cargo/bin:$PATH"
sesh connect "$HOME/projects/$repo_name"
