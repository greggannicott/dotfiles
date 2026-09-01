#!/bin/zsh

# Get the directory of the current script
script_directory="$(cd "$(dirname "$0")" && pwd)"

# Source helper functions
source "$script_directory/helper-functions.zsh"

repos=(
    ~/dotfiles
    ~/code/go-bff/
    ~/code/herdr-launcher/
    ~/code/ironstream-hub-backend/
    ~/code/ironstream-hub-frontend/
    ~/code/playgrounds/obsidian-playground/.obsidian/plugins/conductor-obsidian
)

output_heading "Fetch All Repos"

failures=()
for repo in $repos; do
    if [[ ! -d "$repo/.git" ]] && ! git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        output_error_message "Skipping (not a git repo): $repo"
        failures+=("$repo")
        continue
    fi

    if git -C "$repo" fetch; then
        output_general_message "Fetched: $repo"
    else
        output_error_message "Fetch failed: $repo"
        failures+=("$repo")
    fi
done

echo
if [[ ${#failures[@]} -eq 0 ]]; then
    output_heading "Success!"
    output_general_message "All repos fetched successfully."
else
    output_heading "Completed with failures"
    output_error_message "${#failures[@]} repo(s) failed to fetch:"
    for repo in $failures; do
        output_error_message "  $repo"
    done
fi

output_general_message "Press any key to exit..."
read
