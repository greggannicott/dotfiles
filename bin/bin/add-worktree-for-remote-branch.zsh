#!/bin/zsh

branch_name=$1

if [ -z "$branch_name" ]
then
    echo "No branch name supplied"
    echo "Usage: ./add-worktree-for-remote-branch.zsh <branch_name>"
    exit 1
fi

original_dir=`pwd`

echo
echo "Changing to root of repo"
echo "----------------------------------------------------------------------------------------------------"
cd `git rev-parse --git-common-dir` && cd ..
repo_root=`pwd`
echo
echo "Current directory: `pwd`"

echo
echo "Fetching latest from origin"
echo "----------------------------------------------------------------------------------------------------"
git fetch

echo
echo "Adding '$branch_name' worktree"
echo "----------------------------------------------------------------------------------------------------"
git worktree add $branch_name
cd $branch_name
echo
echo "Current directory: `pwd`"

echo
echo "Assocating '$branch_name' worktree with remote branch"
echo "----------------------------------------------------------------------------------------------------"
git branch --set-upstream-to=origin/$branch_name $branch_name

echo
echo "Getting latest code from origin"
echo "----------------------------------------------------------------------------------------------------"

git merge origin/$branch_name

echo
echo "Inialising repo (if required)"
echo "----------------------------------------------------------------------------------------------------"

if [ -e "~/.workflow-config.yaml" ]; then
    init_command=`yq ".init-scripts[] | select(.path == \"$repo_root\") | .init" ~/.workflow-config.yaml`
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
else
    echo "Not attepting to initialise repo. 'workflow-config.yaml' not found..."
fi

echo
echo "Returning to original directory: $original_dir"
echo "----------------------------------------------------------------------------------------------------"
cd $original_dir

echo
echo "Launching tmux session for '$branch_name' worktree"
echo "----------------------------------------------------------------------------------------------------"
tmux-too-young open --search $branch_name
