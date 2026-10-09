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
    output_general_message "No closed projects found."
    output_general_message "Press any key to exit..."
    read
    exit 0
fi

output_general_message "Found $project_count closed project(s)."

# Filter to only projects where the worktree actually exists on disk
eligible_projects="[]"
for i in $(seq 0 $((project_count - 1))); do
    project=$(echo "$filtered_projects" | jq ".[$i]")
    repo_path=$(echo "$project" | jq -r '.repo.repoPath')

    if git -C "$repo_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
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

# Build table rows (jira, name, status, branch) and the matching workspace IDs
typeset -a rows_jira rows_name rows_status rows_branch rows_workspace

for i in $(seq 0 $((eligible_count - 1))); do
    project=$(echo "$eligible_projects" | jq ".[$i]")
    repo_path=$(echo "$project" | jq -r '.repo.repoPath')

    # Find matching workspace ID
    workspace_id=$(echo "$workspace_data" | jq -r --arg path "$repo_path" '.[] | select(.worktree.checkout_path == $path) | .workspace_id // empty' | head -1)

    if [ -z "$workspace_id" ]; then
        continue
    fi

    rows_jira+=("$(echo "$project" | jq -r '.jiraId // "—"')")
    rows_name+=("$(echo "$project" | jq -r '.name')")
    rows_status+=("$(echo "$project" | jq -r '.projectStatus')")
    rows_branch+=("$(echo "$project" | jq -r '.repo.branch // "—"')")
    rows_workspace+=("$workspace_id")
done

if [ ${#rows_workspace[@]} -eq 0 ]; then
    output_general_message "No matching herdr workspaces found."
    output_general_message "Press any key to exit..."
    read
    exit 0
fi

# Column widths: widest value in each column (header included)
typeset -a headers=("ID" "Name" "Status" "Branch")
typeset -a widths=(${#headers[1]} ${#headers[2]} ${#headers[3]} ${#headers[4]})
for i in {1..${#rows_workspace[@]}}; do
    (( ${#rows_jira[$i]} > widths[1] )) && widths[1]=${#rows_jira[$i]}
    (( ${#rows_name[$i]} > widths[2] )) && widths[2]=${#rows_name[$i]}
    (( ${#rows_status[$i]} > widths[3] )) && widths[3]=${#rows_status[$i]}
    (( ${#rows_branch[$i]} > widths[4] )) && widths[4]=${#rows_branch[$i]}
done

# One Dark palette, matching herdr-launcher
reset=$'\033[0m'
c_header=$'\033[38;2;229;192;123m'
c_info=$'\033[38;2;86;182;194m'
c_fg=$'\033[38;2;171;178;191m'
c_dim=$'\033[2m'
fzf_color="fg:#abb2bf,bg:#282c34,hl:#61afef,fg+:#abb2bf,bg+:#3e4451,hl+:#61afef,info:#56b6c2,prompt:#61afef,pointer:#e06c75,marker:#98c379,spinner:#c678dd,header:#e5c07b,border:#4b5263,label:#abb2bf,query:#abb2bf,scrollbar:#4b5263,gutter:#282c34"

header_line=$(printf '%s%-*s%s  %s%-*s%s  %s%-*s%s  %s%-*s%s' \
    "$c_header" $widths[1] "ID" "$reset" \
    "$c_header" $widths[2] "Name" "$reset" \
    "$c_header" $widths[3] "Status" "$reset" \
    "$c_header" $widths[4] "Branch" "$reset")

# Each row is "<display>\t<workspace id>"; only the display part is shown
selector_items="$header_line"
for i in {1..${#rows_workspace[@]}}; do
    row=$(printf '%s%-*s%s  %s%-*s%s  %s%-*s%s  %s%-*s%s' \
        "$c_info" $widths[1] "${rows_jira[$i]}" "$reset" \
        "$c_fg" $widths[2] "${rows_name[$i]}" "$reset" \
        "$c_header" $widths[3] "${rows_status[$i]}" "$reset" \
        "$c_dim" $widths[4] "${rows_branch[$i]}" "$reset")
    selector_items+=$'\n'"$row"$'\t'"${rows_workspace[$i]}"
done

# Display selector with all items pre-selected (Tab toggles, Enter confirms)
selected_items=$(echo "$selector_items" | fzf --multi --ansi --no-sort --layout=reverse \
    --prompt="Delete worktrees> " --delimiter=$'\t' --with-nth=1 \
    --header-lines=1 --header-lines-border=inline --style=full \
    --bind 'start:select-all' --color="$fzf_color" \
    --footer "Tab: toggle  Ctrl-A: select all  Ctrl-D: deselect all  Enter: delete" \
    --bind 'ctrl-a:select-all,ctrl-d:deselect-all' \
    --no-hscroll)

if [ -z "$selected_items" ]; then
    output_error_message "No worktrees selected. Exiting..."
    output_general_message "Press any key to exit..."
    read
    exit 1
fi

# Confirmation
selected_count=$(echo "$selected_items" | wc -l | tr -d ' ')

output_heading "Confirm deletion"
# Rows are keyed by workspace ID, so map the selection back to its ID and branch
typeset -A branch_by_workspace jira_by_workspace
for i in {1..${#rows_workspace[@]}}; do
    jira_by_workspace[${rows_workspace[$i]}]="${rows_jira[$i]}"
    branch_by_workspace[${rows_workspace[$i]}]="${rows_branch[$i]}"
done

printf '  %s%-*s%s  %s%s%s\n' "$c_header" $widths[1] "ID" "$reset" "$c_header" "Branch" "$reset"
while IFS=$'\t' read -r _ workspace_id; do
    printf '  %s%-*s%s  %s%s%s\n' "$c_info" $widths[1] "${jira_by_workspace[$workspace_id]}" "$reset" "$c_dim" "${branch_by_workspace[$workspace_id]}" "$reset"
done <<< "$selected_items"
echo

if ! gum confirm --default=true --affirmative="Delete" --negative="Cancel" "Delete $selected_count worktree(s) and close their workspaces?"; then
    output_error_message "Deletion cancelled."
    output_general_message "Press any key to exit..."
    read
    exit 1
fi

output_heading "Deleting worktrees"

# Delete each selected worktree
while IFS=$'\t' read -r item workspace_id; do
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
