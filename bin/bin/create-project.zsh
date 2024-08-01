#!/bin/zsh

output_heading ()
{
    echo
    echo $1
    echo "----------------------------------------------------------------------------------------------------"
    echo ""
}

create_worktree ()
{
    id=$1
    branch_name=$2
    output_heading "Creating worktree for $id"

    ## Obtain the path of the repo

    repo_path=`yq ".repos[] | select(.id == \"$id\") | .path" ~/.workflow-config.yaml`

    if [ -z "$repo_path" ]
    then
        echo "No path found for $id in 'workflow-config.yaml'"
        exit 1
    fi

    ## Create the worktree
    cd $repo_path
    git worktree add $branch_name
    cd $branch_name
    git fetch
    git merge origin/main
    git push -u
}

# Default values
ui=false
bff=false
shell=false
copy_branch=false
branch_name=""

# Parse arguments
for (( i = 1; i <= $#; i++ )); do
    case "${(P)i}" in
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
        *)
            echo "Unknown option: ${(P)i}"
            exit 1
            ;;
    esac
done

## Obtain current working directory so we can switch back
original_dir=$(pwd)

# Create worktree for UI
if [ $ui = true ]; then
    create_worktree "govern-ui" $branch_name
fi

# Create worktree for BFF
if [ $ui = true ]; then
    create_worktree "govern-bff" $branch_name
fi

# Create worktree for Shell
if [ $ui = true ]; then
    create_worktree "di-shell" $branch_name
fi

# Copy branch name to clipboard as it might be handy
if [ $copy_branch = true ]; then
    echo $branch_name | pbcopy
    echo ""
    echo "Branch name copied to clipboard: $branch_name"
    echo ""
fi

cd $original_dir
