#!/bin/zsh

current_dir=`pwd`

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
    jira=$2

    output_heading "Creating worktree for '$id'"

    # Obtain the path of the repo
    repo_path=`yq ".repos[] | select(.id == \"$id\") | .path" ~/.workflow-config.yaml`

    # Change to repo repo path
    cd $repo_path
    if [ -z "$repo_path" ]
    then
        echo "$(tput setaf 1)No path found for $id in 'workflow-config.yaml'$(tput sgr0)"
        exit 1
    fi

    # See which branches are available on the repo containing the jira id.
    git fetch
    branches=`git ls-remote --heads --quiet | awk -F '\/' '{print $3}' | grep -i $jira`

    # If there is more than one, prompt the user to select one using fzf.
    if [[ `echo $branches | wc -l` -gt 1 ]]
    then
        branch=`echo $branches | fzf --header "Multiple branches exist with the Jira ID. Please select a '"$id"' branch"`
    elif [[ `echo $branches | wc -l` -eq 0 ]]; then
        echo "No branches found with the Jira ID '$jira' for '$id'. Skipping..."
        return
    else
        branch=$branches
    fi

    # See if worktree already exists
    existing_worktree_directory=`ls -d | awk '{ print $2 }' | sed 's/\/$//' | grep "^$branch$"`

    # If worktree already exists, display a message and skip
    if [[ -n $existing_worktree_directory ]]
    then
        echo "Worktree for branch '$branch' already exists. Skipping..."
        return
    fi

    # Create the worktree
    git worktree add $branch
    cd $branch
    git branch --set-upstream-to=origin/$branch_name $branch_name
    git fetch
    git merge origin/main
    install_dependencies $id
    git push -u
}

# Default values
jira_id=""
ui=false
bff=false
shell=false
help=false

# Parse arguments
for (( i = 1; i <= $#; i++ )); do
    case "${(P)i}" in
        --jira-id)
            # Check if the next argument exists
            if [[ $((i + 1)) -le $# ]]; then
                jira_id="${(P)$((i + 1))}"
                ((i++))  # Skip the next argument since it's the value for --branch
            else
                echo "Error: --jira-id requires a value."
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
    echo "Usage: checkout-branches.zsh [options]"
    echo ""
    echo "Checkout multiple branches at once across repos."
    echo ""
    echo "Options:"
    echo "  --jira-id       Specify the Jira ID (required)"
    echo "  --ui            Create a worktree for the UI"
    echo "  --bff           Create a worktree for the BFF"
    echo "  --shell         Create a worktree for the Shell"
    echo "  --help          Display this help message"
    exit 0
fi

# Create worktree for UI
if [ $ui = true ]; then
    create_worktree "govern-ui" $jira_id
fi

# Create worktree for BFF
if [ $bff = true ]; then
    create_worktree "govern-bff" $jira_id
fi

# Create worktree for Shell
if [ $shell = true ]; then
    create_worktree "di-shell" $jira_id
fi

cd $current_dir

echo
echo "New worktrees created where required. Launching tmux-too-young..."
tmux-too-young open --search $jira_id
