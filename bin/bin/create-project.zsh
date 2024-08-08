#!/bin/zsh

output_heading ()
{
    echo
    echo $1
    echo "----------------------------------------------------------------------------------------------------"
    echo ""
}

install_dependencies ()
{
    id=$1
    output_heading "Installing dependencies for $id"
    if [ -e ~/.workflow-config.yaml ]; then
        init_command=`yq ".repos[] | select(.id == \"$id\") | .init" ~/.workflow-config.yaml`
        if [ "$init_command" = "" ]
        then
            echo "No init command found. Skipping..."
        else
            echo "Running init command: '$init_command'"
            eval $init_command

            if [ $? -ne 0 ]
            then
                echo "$(tput setaf 1)Error running init command...$(tput sgr0)"
            fi
        fi
    else
        echo "Not attepting to initialise repo. 'workflow-config.yaml' not found..."
    fi
}

create_worktree ()
{
    id=$1
    branch_name=$2
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
    git worktree add $branch_name
    cd $branch_name
    git fetch
    git merge origin/main
    if [ $skip_dependencies = false ]; then
        install_dependencies $id
    fi
    git push -u
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
    echo "  --branch        Specify the branch name (required)"
    echo "  --ui            Create a worktree for the UI"
    echo "  --bff           Create a worktree for the BFF"
    echo "  --shell         Create a worktree for the Shell"
    echo "  --copy-branch   Copy the branch name to the clipboard"
    echo "  --skip-notion   Skip creating a Notion project"
    echo "  --skip-dependencies   Skip installing dependencies"
    echo "  --help          Display this help message"
    exit 0
fi

if [ -z $name ]; then
    echo "Error: --name is required."
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
if [ $ui = true ]; then
    create_worktree "govern-bff" $branch_name $skip_dependencies
fi

# Create worktree for Shell
if [ $ui = true ]; then
    create_worktree "di-shell" $branch_name $skip_dependencies
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
    echo $branch_name | pbcopy
    echo ""
    echo "Branch name copied to clipboard: $branch_name"
    echo ""
fi

cd $original_dir
