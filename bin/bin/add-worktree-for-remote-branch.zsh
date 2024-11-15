#!/bin/zsh

skip_init=false
branch_name=""

for (( i = 1; i <= $#; i++ )); do
    case "${(P)i}" in
        --skip-init)
            skip_init=true
            ;;
        *)
            # Assign the first non-flag argument to the branch_name variable
            if [[ -z "$branch_name" ]]; then
                branch_name="${(P)i}"
            fi
            ;;
    esac
done

# Get the directory of the current script
script_directory="$(cd "$(dirname "$0")" && pwd)"

# Source the helper script
source "$script_directory/helper-functions.zsh"

if [ -z "$branch_name" ]
then
    echo "No branch name supplied"
    echo "Usage: ./add-worktree-for-remote-branch.zsh <branch_name>"
    exit 1
fi

original_dir=`pwd`

output_heading "Changing to root of repo"

cd `git rev-parse --git-common-dir` && cd ..
repo_root=`pwd`
echo
echo "Current directory: `pwd`"

output_heading "Fetching latest from origin"

git fetch

output_heading "Adding '$branch_name' worktree"

git worktree add $branch_name
cd $branch_name
echo
echo "Current directory: `pwd`"

output_heading "Assocating '$branch_name' worktree with remote branch"

git branch --set-upstream-to=origin/$branch_name $branch_name

output_heading "Getting latest code from origin"


git merge origin/$branch_name

output_heading "Inialising repo (if required)"

if [[ -e ~/.workflow-config.yaml && $skip_init == false ]]; then
    init_command=`yq ".repos[] | select(.path == \"$repo_root\") | .init" ~/.workflow-config.yaml`
    if [ "$init_command" = "" ]
    then
        echo "No init command found. Skipping..."
    else
        echo "Running init command: '$init_command'"
        eval $init_command

        if [ $? -ne 0 ]
        then
            echo "$(tput setaf 1)Error running init command...$(tput sgr0)"
            cd $original_dir
            exit 1
        fi
    fi
elif [[ $skip_init == true ]]; then
    echo "Skipping init as specified by '--skip-init' flag"
else
    echo "Not attepting to initialise repo. 'workflow-config.yaml' not found..."
fi

output_heading "Returning to original directory: $original_dir"

cd $original_dir

output_heading "Launching tmux session for '$branch_name' worktree"

tmux-too-young open --search $branch_name
