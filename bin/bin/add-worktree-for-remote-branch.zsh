#!/bin/zsh

if [ $# -eq 0 ]
then
    echo "No arguments supplied"
    echo "Usage: ./add-worktree-for-remote-branch.sh <branch_name>"
    exit 1
fi

branch_name=$1
original_dir=`pwd`

echo
echo "Changing to root of repo"
echo "----------------------------------------------------------------------------------------------------"
cd ~/code/ironstream-hub-ui-worktrees/

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
echo "Assocating '$branch_name' worktree with remote branch"
echo "----------------------------------------------------------------------------------------------------"
git branch --set-upstream-to=origin/$branch_name $branch_name

echo
echo "Installing node modules"
echo "----------------------------------------------------------------------------------------------------"
npm i

echo
echo "Returning to original directory: $original_dir"
echo "----------------------------------------------------------------------------------------------------"
cd $original_dir

echo
echo "Launching tmux session for '$branch_name' worktree"
echo "----------------------------------------------------------------------------------------------------"
./tmux-too-young $branch_name
