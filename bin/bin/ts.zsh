#!/bin/zsh

# Find all git repos in ~/code
for repo in $(find ~/code -d 1 -type d -prune -print | sed 's/ /SPACE/g')
do
    unescapedRepo=$(echo $repo | sed 's/SPACE/ /g')
    if [ -d "$unescapedRepo/.git/" ] || [ -e "$unescapedRepo/.git" ]; then
        # Obtrain worktree details for this repo
        output=$(git -C "$unescapedRepo" worktree list --porcelain)

        # Split output of worktree list by line breaks (this is what the `@f` does...)
        lines=("${(@f)output}")

        # Create an associative array to handle this worktree.
        # We'll work through each line builing up information about the worktree.
        # When we reach the line regarding the branch we know it is the final one for that
        # branch and we can then go about adding that entry to the list.
        typeset -A current_entry
        for line in "${lines[@]}"; do
            key=$(echo $line | cut -d ' ' -f 1)
            value=$(echo $line | cut -d ' ' -f 2-)

            # Read the key/value pair in this line, and note the key type
            if [ "$key" = "worktree" ]; then
                current_entry[worktree]="${value}"
                key_type="worktree"
            elif [[ "$key" = "branch" ]]; then
                current_entry[branch]=$value
                key_type="branch"
            else
                key_type="unknown"
            fi

            # If the key type is branch, then we can consider this the last key to processs and act on the worktree entry as a whole.
            if [ "$key_type" = "branch" ]; then
                if [ $current_entry[worktree] =  $unescapedRepo ]; then
                    # If the worktree parth equals the repo path, we're not dealing with a worktree
                    # and we shouldn't print the branch name
                    git_repos+="${repo}\n"
                else
                    # If they don't equal, we're dealing with a worktree and we should include the branch name
                    git_repos+="${repo} -> ${current_entry[branch]}\n"
                fi
            fi
        done

    fi
done
selected_repo_and_branch=$(echo $git_repos | sed 's/SPACE/ /g' | fzf)

# If user escapes at this point (ie. without selecting a repo) exit.
if [ -z "$selected_repo_and_branch" ]; then
    exit 0
fi

# Determine the path, branch and folder name for the selected repo
path_name=$(echo $selected_repo_and_branch | awk -F " -> " '{ print $1 }')
branch_name=$(echo $selected_repo_and_branch | awk -F " -> " '{ print $2 }')
friendly_branch_name=$(echo $branch_name | sed 's/refs\/heads\///g')
folder_name=$(basename $path_name)

# Determine the path that needs to be opened. This depends on whether we're dealing with a worktree or not.
if [ -z "$branch_name" ]; then
    # If we're not dealing with a worktree, we can just open the repo path
    path_to_open=$path_name
    session_name=$folder_name
else
    git -C "$path_name" worktree list --porcelain | while IFS= read -r line; do
        case $line in
            worktree*)
                worktree=${line#worktree }
                ;;
            HEAD*)
                head=${line#HEAD }
                ;;
            branch*)
                branch=${line#branch }
                if [ "$branch" = "$branch_name" ]; then
                    path_to_open=$worktree
                    session_name="$folder_name -> $friendly_branch_name"
                fi
                ;;
        esac
    done
fi

# Get a session for the selected entry if one already exists
existing_session=$(tmux list-sessions |  cut -d ':' -f 1 | grep $session_name )

# Open repo/branch in tmux
if [ -z $existing_session ]; then
    # If we're not in tmux, create a new session and attach to it
    if [ -z $TMUX ]; then
        tmux new-session -s $session_name -c $path_to_open
        # If we're in tmux, create a new detached session and switch to it
    else
        tmux new-session -d -s $session_name -c $path_to_open
        tmux switch-client -t $session_name
    fi
    # If a session exists, attach to it
else
    # If we're not in tmux, attach to the session
    if [ -z $TMUX ]; then
        tmux attach-session -t $existing_session
        # If we're in tmux, switch to the session
    else
        tmux switch-client -t $existing_session
    fi
fi
