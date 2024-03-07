#!/bin/zsh

branch_name=$1

if [ -z "$branch_name" ]
then
    echo "No branch name supplied"
    echo "Usage: ./create-worktree.zsh <branch_name>"
    exit 1
fi

output_heading ()
{
    echo
    echo $1
    echo "----------------------------------------------------------------------------------------------------"
}

echo "Creating new worktree with name '$branch_name'"

original_dir=$(pwd)

output_heading "Changing to root of repo"

cd `git rev-parse --git-common-dir` && cd ..
repo_root=`pwd`

output_heading "Adding new worktree with name '$branch_name'"

git worktree add $branch_name
cd $branch_name

output_heading "Fetching latest from origin"

git fetch

output_heading "Merging in latest from origin/main"

git merge origin/main

output_heading "Inialising repo (if required)"

init_command=`yq ".repositories[] | select(.path == \"$repo_root\") | .init" ~/.repositories.yaml`
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


output_heading "Creating remote branch and setting origin"

git push -u --no-verify

output_heading "Returning to original directory: $original_dir"

cd $original_dir

output_heading "Launching tmux session for '$branch_name' worktree"

tmux-too-young open --search $branch_name
