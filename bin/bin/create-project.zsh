#!/bin/zsh

figlet "Create Project"

# Get the directory of the current script
script_directory="$(cd "$(dirname "$0")" && pwd)"

# Source the helper script
source "$script_directory/helper-functions.zsh"

check_exit_code() {
if [ $1 -ne 0 ]; then
    echo "$(tput setaf 1)Script exited prematurely...$(tput sgr0)"
    exit 1
fi
}

create_worktree ()
{
    id=$1
    branch=$2
    install_dependencies=$3
    output_heading "Creating worktree for $id"

    ## Obtain the path of the repo

    repo_path=`yq ".repos[] | select(.id == \"$id\") | .path" ~/.workflow-config.yaml`

    if [ -z "$repo_path" ]
    then
        echo "$(tput setaf 1)No path found for $id in 'workflow-config.yaml'$(tput sgr0)"
        exit 1
    fi

    ## Create the worktree
    cd $repo_path
    git worktree add $branch
    cd $branch
    git fetch
    git merge origin/main
    if [ $install_dependencies = true ]; then
        install_dependencies $id
    fi
    git push -u
}

update_catalog_govern_json ()
{
    branch=$1
    repo_path=`yq ".repos[] | select(.id == \"di-shell\") | .path" ~/.workflow-config.yaml`
    branch_path="$repo_path/$branch"
    json_file="$branch_path/client/src/assets/remotes/catalog-govern.json"
    temp_file="$branch_path/client/src/assets/remotes/catalog-govern.temp.json"
    output_heading "Updating catalog-govern.json"
    jq 'map(.application |= del(.namespace))' $json_file > $temp_file && mv $temp_file $json_file 
    jq 'map(.federation.remoteEntry = "http://localhost:4200/remoteEntry.js")' $json_file > $temp_file && mv $temp_file $json_file 
}

# Setup possible options
UI_WORKTREE_OPTION="Create UI Worktree"
BFF_WORKTREE_OPTION="Create BFF Worktree"
SHELL_WORKTREE_OPTION="Create Shell Worktree"
NOTION_PROJECT_OPTION="Create Notion Project"
INSTALL_DEPENDENCIES_OPTION="Install Dependencies"
OPEN_TMUX_TOO_YOUNG_OPTION="Open tmux-too-young following creation of project"
COPY_BRANCH_NAME_OPTION="Copy branch name to clipboard"

# Set default values
name=""
project_type="bug"
branch_name="DIUI-"
# For some reason you need commas either end of the string. Without this the first and last options are not set by default.
DEFAULT_OPTIONS=",$NOTION_PROJECT_OPTION,$INSTALL_DEPENDENCIES_OPTION,$OPEN_TMUX_TOO_YOUNG_OPTION,$COPY_BRANCH_NAME_OPTION,"

# Prompt user for values. 
name=$(gum input --header="Project Name:" --value="$name")
check_exit_code $?

project_type=$(gum choose "story" "bug" --header="Project Type:" --selected="$project_type")
check_exit_code $?

branch_name=$(gum input --header="Branch Name:" --value="$branch_name")
check_exit_code $?

# Prompt user for options
script_options=("${(@f)$(gum choose $UI_WORKTREE_OPTION $BFF_WORKTREE_OPTION $SHELL_WORKTREE_OPTION $NOTION_PROJECT_OPTION $INSTALL_DEPENDENCIES_OPTION $OPEN_TMUX_TOO_YOUNG_OPTION $COPY_BRANCH_NAME_OPTION --no-limit --header 'Please select options' --selected \"$DEFAULT_OPTIONS\")}")
check_exit_code $?

if [[ "${script_options[@]}" =~ $UI_WORKTREE_OPTION ]]; then
    ui=true
fi
if [[ "${script_options[@]}" =~ $BFF_WORKTREE_OPTION ]]; then
    bff=true
fi
if [[ "${script_options[@]}" =~ $SHELL_WORKTREE_OPTION ]]; then
    shell=true
fi
if [[ "${script_options[@]}" =~ $NOTION_PROJECT_OPTION ]]; then
    notion=true
fi
if [[ "${script_options[@]}" =~ $INSTALL_DEPENDENCIES_OPTION ]]; then
    install_dependencies=true
fi
if [[ "${script_options[@]}" =~ $OPEN_TMUX_TOO_YOUNG_OPTION ]]; then
    open_tmux_too_young=true
fi
if [[ "${script_options[@]}" =~ $COPY_BRANCH_NAME_OPTION ]]; then
    copy_branch=true
fi

# Validate inputs
if [[ -z $name && $notion == true ]]; then
    echo "Error: Project Name is required when Notion project is being created."
    exit 1
fi

if [ -z $branch_name ]; then
    echo "Error: Branch is required."
    exit 1
fi

# Create the project.

## Obtain current working directory so we can switch back
original_dir=$(pwd)

# Create worktree for UI
if [ "$ui" = "true" ]; then
    create_worktree "govern-ui" $branch_name $install_dependencies
fi

# Create worktree for BFF
if [ "$bff" = "true" ]; then
    create_worktree "govern-bff" $branch_name $install_dependencies
fi

# Create worktree for Shell
if [ "$shell" = "true" ]; then
    create_worktree "di-shell" $branch_name $install_dependencies
    update_catalog_govern_json $branch_name
fi

if [ "$notion" = "true" ]; then
    # Extract JIRA ID from branch name
    if [[ $branch_name =~ ^([A-Z]+-[0-9]+) ]]; then
        jira_id=${match[1]}  # This captures the first group
        echo "Jira ID" $jira_id
    fi
    output_heading "Creating Notion project for '$name'"
    create-notion-project.zsh --name $name --jira-id $jira_id --branch $branch_name --type $project_type --current
fi

# Copy branch name to clipboard as it might be handy
if [ "$copy_branch" = "true" ]; then
    output_heading "Copying branch name to clipboard"
    echo $branch_name | pbcopy
    echo ""
    echo "Branch name copied to clipboard: $branch_name"
    echo ""
fi

# Copy branch name to clipboard as it might be handy
if [ "$open_tmux_too_young" = "true" ]; then
    output_heading "Opening project with tmux-too-young"
    echo ""
    tmux-too-young open --search $branch_name
fi

cd $original_dir
