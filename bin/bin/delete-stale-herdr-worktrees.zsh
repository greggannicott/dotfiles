#!/bin/zsh

clear

figlet "Delete Stale Herdr Worktrees"

# Get the directory of the current script
script_directory="$(cd "$(dirname "$0")" && pwd)"

# Source the helper script
source "$script_directory/helper-functions.zsh"

# Check BFF connectivity
if ! curl -s -o /dev/null --max-time 5 "http://localhost:8082/status"; then
    output_error_message "Unable to connect to BFF. Check it is running."
    output_general_message "Press any key to exit..."
    read
    exit 1
fi

output_heading "Fetching projects"

# Fetch all projects and filter for stale worktree-backed projects
filtered_projects=$(curl -s "http://localhost:8082/projects/" | jq '[.[] | select(.projectType == "ChildProjectUsesWorktree" and (.projectStatus == "03 - Done" or .projectStatus == "04 - Abandoned" or .projectStatus == "05 - Won'\''t Do"))]')

project_count=$(echo "$filtered_projects" | jq 'length')

if [ "$project_count" -eq 0 ]; then
    output_general_message "No stale worktree projects found."
    output_general_message "Press any key to exit..."
    read
    exit 0
fi

output_general_message "Found $project_count stale worktree project(s)"

# Filter to only projects where the worktree directory exists on disk
eligible_projects="[]"
for i in $(seq 0 $((project_count - 1))); do
    project=$(echo "$filtered_projects" | jq ".[$i]")
    repo_path=$(echo "$project" | jq -r '.repo.repoPath')

    if [ -d "$repo_path" ]; then
        eligible_projects=$(echo "$eligible_projects" | jq --argjson project "$project" '. + [$project]')
    fi
done

eligible_count=$(echo "$eligible_projects" | jq 'length')

if [ "$eligible_count" -eq 0 ]; then
    output_general_message "No stale worktrees found on disk."
    output_general_message "Press any key to exit..."
    read
    exit 0
fi

output_general_message "$eligible_count worktree(s) found on disk"

# Fetch herdr workspaces to build a workspace ID lookup
workspace_data=$(herdr workspace list 2>/dev/null | jq '.result.workspaces')

# Build the selection items and a lookup from repoPath to workspace ID
selector_items=""
lookup="{}"

for i in $(seq 0 $((eligible_count - 1))); do
    project=$(echo "$eligible_projects" | jq ".[$i]")
    repo_path=$(echo "$project" | jq -r '.repo.repoPath')
    jira_id=$(echo "$project" | jq -r '.jiraId // "—"')
    name=$(echo "$project" | jq -r '.name')
    project_status=$(echo "$project" | jq -r '.projectStatus')
    branch=$(echo "$project" | jq -r '.repo.branch // "—"')

    # Find matching workspace ID
    workspace_id=$(echo "$workspace_data" | jq -r --arg path "$repo_path" '.[] | select(.worktree.checkout_path == $path) | .workspace_id // empty' | head -1)

    if [ -z "$workspace_id" ]; then
        continue
    fi

    display="$jira_id  |  $name  |  $project_status  |  $branch"
    selector_items="$selector_items
$display"

    lookup=$(echo "$lookup" | jq --arg key "$display" --arg wid "$workspace_id" '. + {($key): $wid}')
done

selector_items=$(echo "$selector_items" | sed '/^$/d')
selector_count=$(echo "$selector_items" | wc -l | tr -d ' ')

if [ "$selector_count" -eq 0 ]; then
    output_general_message "No matching herdr workspaces found."
    output_general_message "Press any key to exit..."
    read
    exit 0
fi

# Determine selector height
title_space=8
consumed_space=$title_space
list_height=$(($(tput lines) - $consumed_space))

# Display selector with all items pre-selected
selected_items=$(echo "$selector_items" | gum choose --no-limit --height=$list_height --selected "$selector_items" --header "Select worktrees to delete (all selected by default)")
check_exit_code $?

if [ -z "$selected_items" ]; then
    output_error_message "No worktrees selected. Exiting..."
    output_general_message "Press any key to exit..."
    read
    exit 1
fi

# Confirmation
selected_count=$(echo "$selected_items" | wc -l | tr -d ' ')

output_heading "Confirm deletion"
echo "$selected_items"
echo

if ! gum confirm --default=true --affirmative="Delete" --negative="Cancel" "Delete $selected_count worktree(s) and close their workspaces?"; then
    output_error_message "Deletion cancelled."
    output_general_message "Press any key to exit..."
    read
    exit 1
fi

output_heading "Deleting worktrees"

# Delete each selected worktree
while IFS= read -r item; do
    workspace_id=$(echo "$lookup" | jq -r --arg key "$item" '.[$key] // empty')

    if [ -z "$workspace_id" ]; then
        output_error_message "Could not find workspace ID for: $item"
        continue
    fi

    herdr worktree remove --workspace "$workspace_id" --force 2>/dev/null
    if [ $? -eq 0 ]; then
        output_general_message "Successfully deleted: $item"
    else
        output_error_message "Failed to delete: $item"
    fi
done <<< "$selected_items"

echo
output_general_message "Finished deleting stale worktrees"
output_general_message "Press any key to exit..."
read
