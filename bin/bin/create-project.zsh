#!/bin/zsh

# Get the directory of the current script
script_directory="$(cd "$(dirname "$0")" && pwd)"

# Source the helper script
source "$script_directory/helper-functions.zsh"

create_worktree ()
{
    id=$1
    branch=$2
    skip_dependencies=$3
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
    if [ $skip_dependencies = false ]; then
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

pre_selected_ui="No"
pre_selected_bff="No"
pre_selected_shell="No"
pre_selected_skip_notion="No"
pre_selected_skip_dependencies="No"
pre_selected_open_tmux_too_young="No"
copy_branch=false
help=false

# Parse arguments
for (( i = 1; i <= $#; i++ )); do
    case "${(P)i}" in
        --name)
            # Check if the next argument exists
            if [[ $((i + 1)) -le $# ]]; then
                name="${(P)$((i + 1))}"
                ((i++))  # Skip the next argument since it's the value for --branch
            else
                echo "Error: --name requires a value."
                exit 1
            fi
            ;;
        --type)
            # Check if the next argument exists
            if [[ $((i + 1)) -le $# ]]; then
                project_type="${(P)$((i + 1))}"
                ((i++))  # Skip the next argument since it's the value for --branch
            else
                echo "Error: --type requires a value."
                exit 1
            fi
            ;;
        --branch)
            # Check if the next argument exists
            if [[ $((i + 1)) -le $# ]]; then
                branch_name="${(P)$((i + 1))}"
                ((i++))  # Skip the next argument since it's the value for --branch
            else
                echo "Error: --branch requires a value."
                exit 1
            fi
            ;;
        --ui)
            pre_selected_ui="Yes"
            ;;
        --bff)
            pre_selected_bff="Yes"
            ;;
        --shell)
            pre_selected_shell="Yes"
            ;;
        --skip-notion)
            pre_selected_skip_notion="Yes"
            ;;
        --skip-dependencies)
            pre_selected_skip_dependencies="Yes"
            ;;
        --open-tmux-too-young)
            pre_selected_open_tmux_too_young="Yes"
            ;;
        --copy-branch)
            copy_branch=true
            ;;
        --help)
            help=true
            ;;
        *)
            echo "Unknown option: ${(P)i}"
            exit 1
            ;;
    esac
done

if [ $help = true ]; then
    echo "Usage: create-project.zsh [options]"
    echo ""
    echo "Options:"
    echo "  --name        Specify the project name (required)"
    echo "  --type        Specify the project type (default: 'story')"
    echo "  --branch        Specify the branch name. Jira ID is extracted from this (required)"
    echo "  --ui            Create a worktree for the UI"
    echo "  --bff           Create a worktree for the BFF"
    echo "  --shell         Create a worktree for the Shell"
    echo "  --skip-notion   Skip creating a Notion project"
    echo "  --skip-dependencies   Skip installing dependencies"
    echo "  --open-tmux-too-young   Opens tmux-too-young following creation of project"
    echo "  --copy-branch   Copy the branch name to the clipboard"
    echo "  --help          Display this help message"
    exit 0
fi

# Prompt user for values. Pre-populate with any that have been provided via command line
name=$(gum input --header="Project Name:" --value="$name")
project_type=$(gum choose "story" "bug" --header="Project Type:" --selected="$project_type")
branch_name=$(gum input --header="Branch Name:" --value="$branch_name")

ui_choice=$(gum choose "Yes" "No" --header="Create UI Worktree?" --selected="$pre_selected_ui")
if [ $ui_choice = "Yes" ]; then
    ui=true
else
    ui=false
fi

bff_choice=$(gum choose "Yes" "No" --header="Create BFF Worktree?" --selected="$pre_selected_bff")
if [ $bff_choice = "Yes" ]; then
    bff=true
else
    bff=false
fi

shell_choice=$(gum choose "Yes" "No" --header="Create Shell Worktree?" --selected="$pre_selected_shell")
if [ $shell_choice = "Yes" ]; then
    shell=true
else
    shell=false
fi

skip_notion_choice=$(gum choose "Yes" "No" --header="Skip creating Notion Project?" --selected="$pre_selected_skip_notion")
if [ $skip_notion_choice = "Yes" ]; then
    skip_notion=true
else
    skip_notion=false
fi

skip_dependencies_choice=$(gum choose "Yes" "No" --header="Skip installing dependencies?" --selected="$pre_selected_skip_dependencies")
if [ $skip_dependencies_choice = "Yes" ]; then
    skip_dependencies=true
else
    skip_dependencies=false
fi

open_tmux_too_young_choice=$(gum choose "Yes" "No" --header="Open tmux-too-young following creation of project?" --selected="$pre_selected_open_tmux_too_young")
if [ $open_tmux_too_young_choice = "Yes" ]; then
    open_tmux_too_young=true
else
    open_tmux_too_young=false
fi

if [[ -z $name && $skip_notion == false ]]; then
    echo "Error: Project Name is required when Notion project is being created."
    exit 1
fi

if [ -z $branch_name ]; then
    echo "Error: Branch is required."
    exit 1
fi

## Obtain current working directory so we can switch back
original_dir=$(pwd)

# Create worktree for UI
if [ $ui = true ]; then
    create_worktree "govern-ui" $branch_name $skip_dependencies
fi

# Create worktree for BFF
if [ $bff = true ]; then
    create_worktree "govern-bff" $branch_name $skip_dependencies
fi

# Create worktree for Shell
if [ $shell = true ]; then
    create_worktree "di-shell" $branch_name $skip_dependencies
    update_catalog_govern_json $branch_name
fi

if [ $skip_notion = false ]; then
    # Extract JIRA ID from branch name
    if [[ $branch_name =~ ^([A-Z]+-[0-9]+) ]]; then
        jira_id=${match[1]}  # This captures the first group
        echo "Jira ID" $jira_id
    fi
    output_heading "Creating Notion project for '$name'"
    create-notion-project.zsh --name $name --jira-id $jira_id --branch $branch_name --type $project_type --current
fi

# Copy branch name to clipboard as it might be handy
if [ $copy_branch = true ]; then
    output_heading "Copying branch name to clipboard"
    echo $branch_name | pbcopy
    echo ""
    echo "Branch name copied to clipboard: $branch_name"
    echo ""
fi

# Copy branch name to clipboard as it might be handy
if [ $open_tmux_too_young = true ]; then
    output_heading "Opening project with tmux-too-young"
    echo ""
    tmux-too-young open --search $branch_name
fi

cd $original_dir
