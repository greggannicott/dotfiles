#!/bin/zsh

# Get the directory of the current script
script_directory="$(cd "$(dirname "$0")" && pwd)"

# Source helper functions
source "$script_directory/helper-functions.zsh"

output_heading "Copy Current Branch to Clipboard"

currentBranchName=$(git branch --show-current)

if [ -z "$currentBranchName" ]; then
    output_error_message "Not on a branch (detached HEAD or no git repo)."
    output_general_message "Press any key to exit..."
    read
    exit 1
fi

echo -n "$currentBranchName" | pbcopy

output_general_message "Current branch [$currentBranchName] copied to clipboard."
output_general_message "Press any key to exit..."
read
