#!/bin/zsh

if [ $# -eq 0 ]
then
    echo "No arguments supplied"
    echo "Usage: ./create_branch.sh <branch_name>"
    exit 1
fi

output_heading ()
{
    echo
    echo $1
    echo "----------------------------------------------------------------------------------------------------"
}

branch_name=$1
original_dir=$(pwd)

output_heading "Changing to root of repo"

cd `git rev-parse --git-common-dir` && cd ..

output_heading "Adding new worktree with name '$branch_name'"

git worktree add $branch_name
cd $branch_name

output_heading "Fetching latest from origin"

git fetch

output_heading "Merging in latest from origin/main"

git merge origin/main

output_heading "Installing node modules"

npm install

output_heading "Creating remote branch and setting origin"

git push -u --no-verify

output_heading "Returning to original directory: $original_dir"

cd $original_dir

output_heading "Launching tmux session for '$branch_name' worktree"

tmux-too-young $branch_name
