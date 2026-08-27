#!/bin/zsh

# Get the directory of the current script
script_directory="$(cd "$(dirname "$0")" && pwd)"

# Source helper functions
source "$script_directory/helper-functions.zsh"
source "$script_directory/helpers/parse-params.zsh"

# Check BFF connectivity
if ! curl -s -o /dev/null --max-time 5 "http://localhost:8082/status"; then
    echo "$(tput setaf 1)Warning: Unable to connect to $(tput sgr0)$(tput bold)BFF$(tput sgr0)$(tput setaf 1). Check it is running.$(tput sgr0)"
	echo
fi

# Check VPN connectivity
ssh_output=$(ssh -T -o ConnectTimeout=5 -o StrictHostKeyChecking=no git@sourcefront.syncsort.com 2>&1)
ssh_exit_code=$?
if [ $ssh_exit_code -ne 0 ] && [ $ssh_exit_code -ne 1 ] && ! echo "$ssh_output" | grep -q "shell request failed"; then
    echo "$(tput setaf 1)Warning: Unable to connect to $(tput sgr0)$(tput bold)Bitbucket$(tput sgr0)$(tput setaf 1). Check you are connected to the VPN.$(tput sgr0)"
	echo
fi

output_heading "Create Story or Bug"

create_worktree_for_id ()
{
    id=$1
    branch=$2

    ## Obtain details regarding the repo

    repo_path=$(yq ".repos[] | select(.id == \"$id\") | .path // \"\"" ~/.workflow-config.yaml)
    origin_branch=$(yq ".repos[] | select(.id == \"$id\") | .defaultBranch // \"main\"" ~/.workflow-config.yaml)

    if [ -z "$repo_path" ]
    then
        output_error_message "No path found for $id in 'workflow-config.yaml'"
        output_general_message "Press any key to exit..."
        read
        exit 1
    fi

    base_ref="origin/$origin_branch"
    if ! git rev-parse --verify "$base_ref" >/dev/null 2>&1; then
        base_ref="$origin_branch"
    fi

    output_heading "Creating worktree and workspace for $id"
    output_general_message "Repo: $repo_path"
    output_general_message "Branch: $branch"
    output_general_message "Base: $base_ref"

    git -C "$repo_path" fetch origin --quiet || output_error_message "git fetch failed; using local ref for base"

    herdr worktree create \
        --cwd "$repo_path" \
        --branch "$branch" \
        --base "$base_ref" \
        --no-focus
}

# Setup possible options
BACKEND_WORKTREE_OPTION="Create Backend Worktree"
OBSIDIAN_PROJECT_OPTION="Create Obsidian Project"

# Register CLI parameters
declare_param "name" "name" "Project name"
declare_param "id" "id" "ID (optional)"
declare_param "branch" "branch_name" "Branch name"
declare_param "create-worktree" "backend" "Create backend worktree" flag
declare_param "create-project" "obsidian" "Create Obsidian project" flag

# Set default values
name=""
id=""
branch_name=""
backend=false
obsidian=false

# Parse command-line parameters (overrides defaults)
parse_params "$@"

# Prompt user for values (prefilled from CLI params).
name=$(gum input --header="Project Name:" --value="$name")
check_exit_code $?

id=$(gum input --header="ID (optional):" --value="$id")
check_exit_code $?

branch_name=$(gum input --header="Branch Name:" --value="$branch_name")
check_exit_code $?

# Prompt user for options (pre-selected from CLI flags)
SELECTED_OPTIONS=""
[ "$backend" = true ] && SELECTED_OPTIONS="$SELECTED_OPTIONS,$BACKEND_WORKTREE_OPTION"
[ "$obsidian" = true ] && SELECTED_OPTIONS="$SELECTED_OPTIONS,$OBSIDIAN_PROJECT_OPTION"
SELECTED_OPTIONS="$SELECTED_OPTIONS,"

script_options=("${(@f)$(gum choose $BACKEND_WORKTREE_OPTION $OBSIDIAN_PROJECT_OPTION --no-limit --header 'Please select options' --selected "$SELECTED_OPTIONS")}")
check_exit_code $?

backend=false
obsidian=false

if [[ "${script_options[@]}" =~ $BACKEND_WORKTREE_OPTION ]]; then
    backend=true
fi
if [[ "${script_options[@]}" =~ $OBSIDIAN_PROJECT_OPTION ]]; then
    obsidian=true
fi

if [[ -z "$name" && "$obsidian" == true ]]; then
    output_error_message "Project Name is required when Obsidian project is being created."
    output_general_message "Press any key to exit..."
    read
    exit 1
fi

if [ -z "$branch_name" ]; then
    output_error_message "Branch is required."
    output_general_message "Press any key to exit..."
    read
    exit 1
fi

# Create worktree for the Backend
if [ "$backend" = true ]; then
    create_worktree_for_id "ironstream-hub-backend" "$branch_name"
fi

if [ "$obsidian" = true ]; then
    output_heading "Creating Obsidian project for '$name'"

    payload=$(jq -n \
        --arg name "$name" \
        --arg jiraId "$id" \
        --arg branch "$branch_name" \
        '{
            name: $name,
            jiraId: $jiraId,
            context: "Work",
            ongoing: false,
            projectStatus: "02 - In Progress",
            parents: [
                {
                    projectFile: "Projects/Work/Ironstream Hub Backend",
                    branch: $branch
                }
            ]
        }')

    curl -s "http://localhost:8082/projects/" \
        -H "Content-Type: application/json" \
        --data "$payload" | jq
fi

output_heading "Finished!"
output_general_message "Press any key to exit..."
read
