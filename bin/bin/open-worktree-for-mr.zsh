#!/bin/zsh

merge_requests=''

# Generate list of merge requests to choose from
glab mr list | sed '1,2d;$d'| while IFS= read -r line
do
    name=`echo $line | awk -F '\t' '{print $3}'`
    branches=`echo $line | awk -F '\t' '{print $4}'`
    merge_requests+="'$name' -- $branches\n"
done

# Obtain selection from user
selected_merge_request=` echo $merge_requests | fzf `

if [[ -z $selected_merge_request ]]
then
    echo "No merge request selected. Exiting..."
    exit 1
fi

# Extract branch from selection
source_branch=`echo $selected_merge_request | awk -F ' -- ' '{print $2}' | awk -F ' ← ' '{print $2}' | sed 's/^(//' | sed 's/)$//'`

# See if worktree already exists
existing_worktree_count=`git worktree list | awk '{ print $3 }' | sed 's/^\[//' | sed 's/\]$//' | grep --count $source_branch`

# If worktree exists, open tmux session
if [[ $existing_worktree_count -eq 1 ]]
then
    echo "Worktree for branch '$source_branch' already exists. Opening tmux session for you..."
    tmux-too-young open --search $source_branch
else
    echo "Worktree for branch '$source_branch' does not exist."
    echo
    echo "At present this script does not support creating the worktree."
fi

echo

