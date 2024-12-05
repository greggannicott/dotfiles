#!/bin/zsh

clear

figlet "Delete Worktrees"

# Get the directory of the current script
script_directory="$(cd "$(dirname "$0")" && pwd)"

# Source the helper script
source "$script_directory/helper-functions.zsh"

original_dir=`pwd`

# Change to route of current repo
cd `git rev-parse --git-common-dir` && cd ..

# Obtain a list of all worktrees
worktrees=`git worktree list | awk '{print $1}' | grep -v ".bare$" | grep -v "main$"`

# Display list using `gum`. Allow user to select multiple worktrees.
selected_worktrees=$(echo $worktrees | gum choose --no-limit)

if [ -z "$selected_worktrees" ]; then
    output_error_message "No worktrees selected. Exiting..."
    exit 1
fi

output_heading "Deleting selected worktrees"

# For each selected worktree, delete it.
IFS=$'\n'
while IFS= read -r workspace; do
    git worktree remove $workspace --force
    if [ $? -eq 0 ]; then
        output_general_message "Successfully deleted $workspace"
    else
        output_error_message "Failed to delete $workspace"
    fi
done <<< $selected_worktrees

echo
output_general_message "Finished deleting worktrees"

cd $original_dir
