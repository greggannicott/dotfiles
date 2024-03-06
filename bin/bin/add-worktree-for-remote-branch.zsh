#!/bin/zsh

# Parse arguments being passed in
run_npm_install=
run_npm_setup=

while getopts "is" opt; do
  case $opt in
    i)run_npm_install=1 ;;
    s)run_npm_setup=1 ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

shift $((OPTIND - 1))
branch_name=$1

if [ -z "$branch_name" ]
then
    echo "No branch name supplied"
    echo "Usage: ./add-worktree-for-remote-branch.sh <branch_name>"
    exit 1
fi

original_dir=`pwd`

echo
echo "Changing to root of repo"
echo "----------------------------------------------------------------------------------------------------"
cd `git rev-parse --git-common-dir` && cd ..
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

if [ ! -z "$run_npm_install" ]
then
    echo
    echo "Installing node modules"
    echo "----------------------------------------------------------------------------------------------------"
    npm i
fi

if [ ! -z "$run_npm_setup" ]
then
    echo
    echo "Installing setup script"
    echo "----------------------------------------------------------------------------------------------------"
    npm run setup
fi

echo
echo "Returning to original directory: $original_dir"
echo "----------------------------------------------------------------------------------------------------"
cd $original_dir

echo
echo "Launching tmux session for '$branch_name' worktree"
echo "----------------------------------------------------------------------------------------------------"
tmux-too-young $branch_name
