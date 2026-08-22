#!/bin/zsh

# Get the directory of the current script
script_directory="$(cd "$(dirname "$0")" && pwd)"

# Source helper functions
source "$script_directory/helper-functions.zsh"

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
COPY_BRANCH_NAME_OPTION="Copy branch name to clipboard"
# For some reason you need commas either end of the string. Without this the first and last options are not set by default.
DEFAULT_OPTIONS=",$OBSIDIAN_PROJECT_OPTION,$COPY_BRANCH_NAME_OPTION,"

# Set default values
name=""
branch_name="IS-"

# Prompt user for values.
name=$(gum input --header="Project Name:" --value="$name")
check_exit_code $?

branch_name=$(gum input --header="Branch Name:" --value="$branch_name")
check_exit_code $?

# Prompt user for options
script_options=("${(@f)$(gum choose $BACKEND_WORKTREE_OPTION $OBSIDIAN_PROJECT_OPTION $COPY_BRANCH_NAME_OPTION --no-limit --header 'Please select options' --selected "$DEFAULT_OPTIONS")}")
check_exit_code $?

backend=false
obsidian=false
copy_branch=false

if [[ "${script_options[@]}" =~ $BACKEND_WORKTREE_OPTION ]]; then
    backend=true
fi
if [[ "${script_options[@]}" =~ $OBSIDIAN_PROJECT_OPTION ]]; then
    obsidian=true
fi
if [[ "${script_options[@]}" =~ $COPY_BRANCH_NAME_OPTION ]]; then
    copy_branch=true
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
    # Extract JIRA ID from branch name
    jira_id=""
    if [[ $branch_name =~ ^([A-Z]+-[0-9]+) ]]; then
        jira_id=${match[1]}  # This captures the first group
    fi
    output_heading "Creating Obsidian project for '$name'"

    payload=$(jq -n \
        --arg name "$name" \
        --arg jiraId "$jira_id" \
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

# Copy branch name to clipboard as it might be handy
if [ "$copy_branch" = true ]; then
    output_heading "Copying branch name to clipboard"
    if command -v pbcopy >/dev/null 2>&1; then
        printf '%s' "$branch_name" | pbcopy
        output_general_message "Branch name copied to clipboard: $branch_name"
    elif command -v xclip >/dev/null 2>&1; then
        printf '%s' "$branch_name" | xclip -selection clipboard
        output_general_message "Branch name copied to clipboard: $branch_name"
    else
        output_error_message "No clipboard tool found (pbcopy/xclip). Skipping."
    fi
fi

output_heading "Finished!"
output_general_message "Press any key to exit..."
read
