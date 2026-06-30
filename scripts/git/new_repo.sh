#!/usr/bin/env bash
# Prompt for the project name
project_name=$(gum input --placeholder "Enter the project name")
# Check if the user canceled the prompt
if [[ -z "$project_name" ]]; then
    exit 0
fi
# Create the project folder
mkdir -p "$HOME/projects"
project_folder="$HOME/projects/$project_name"
mkdir -p "$project_folder"
# Move into the project folder in a new tmux session
export PATH="$HOME/.cargo/bin:$PATH"
sesh connect "$project_folder"
