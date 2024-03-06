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
    echo "Usage: ./create-worktree.zsh <branch_name>"
    exit 1
fi

if [ -z "$run_npm_install" ] && [ -z "$run_npm_setup" ]; then
    echo "You haven't specified any actions to run after adding the worktree."
    echo
    echo "Do you wish to continue? (y/n)"
    read -k 1 continue
    if [ "$continue" != "y" ]; then
        echo
        echo "Exiting."
        exit 0
    fi
    echo
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

output_heading "Adding new worktree with name '$branch_name'"

git worktree add $branch_name
cd $branch_name

output_heading "Fetching latest from origin"

git fetch

output_heading "Merging in latest from origin/main"

git merge origin/main

if [ ! -z "$run_npm_install" ]
then
    output_heading "Installing node modules"
    npm i
fi

if [ ! -z "$run_npm_setup" ]
then
    output_heading "Running setup script"
    npm run setup

    if [ $? -ne 0 ]
    then
        echo
        echo "$(tput setaf 1)Setup script failed.$(tput sgr0)"
        echo
        echo "Check you are connected to the VPN."
        echo
        echo "Removing worktree and returning to original directory."
        echo
        git worktree remove -f $branch_name
        cd $original_dir
        exit 1
    fi
fi

output_heading "Creating remote branch and setting origin"

git push -u --no-verify

output_heading "Returning to original directory: $original_dir"

cd $original_dir

output_heading "Launching tmux session for '$branch_name' worktree"

tmux-too-young $branch_name
