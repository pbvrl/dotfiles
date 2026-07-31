#!/usr/bin/env bash

# Prompt for the project name
project_name=$(gum input --placeholder "Enter the project name")

# Check if the user canceled the prompt
if [[ -z "$project_name" ]]; then
    exit 0
fi

# Create the project folder
project_folder="$HOME/projects/$project_name"
git init "$project_folder.tmp"
cd $project_folder.tmp
git commit --allow-empty -m "initial commit"
# cd ..
mkdir $project_folder
cd $project_folder
git clone --bare "$project_folder.tmp" .bare
echo "gitdir: ./.bare" >.git
rm -rf $project_folder.tmp/.git
rmdir $project_folder.tmp
git worktree add master

# Move into the project folder in a new tmux session
export PATH="$HOME/.cargo/bin:$PATH"
sesh connect "$project_folder/master"
