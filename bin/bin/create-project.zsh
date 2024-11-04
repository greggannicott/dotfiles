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

# Default values
ui=false
bff=false
shell=false
name=""
project_type="story"
branch_name=""
skip_notion=false
skip_dependencies=false
copy_branch=false
open_tmux_too_young=false
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
            ui=true
            ;;
        --bff)
            bff=true
            ;;
        --shell)
            shell=true
            ;;
        --copy-branch)
            copy_branch=true
            ;;
        --open-tmux-too-young)
            open_tmux_too_young=true
            ;;
        --skip-notion)
            skip_notion=true
            ;;
        --skip-dependencies)
            skip_dependencies=true
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
    echo "  --copy-branch   Copy the branch name to the clipboard"
    echo "  --open-tmux-too-young   Opens tmux-too-young following creation of project"
    echo "  --skip-notion   Skip creating a Notion project"
    echo "  --skip-dependencies   Skip installing dependencies"
    echo "  --help          Display this help message"
    exit 0
fi

if [[ -z $name && $skip_notion == false ]]; then
    echo "Error: --name is required when Notion project is being created."
    exit 1
fi

if [ -z $branch_name ]; then
    echo "Error: --branch is required."
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
