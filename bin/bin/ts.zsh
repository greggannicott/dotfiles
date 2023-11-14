# #!/bin/zsh

# Find all git repos in ~/code
repos=$(find ~/code -d 1 -type d -prune -print | sed 's/ /SPACE/g')

for repo in $repos
do
    unescapedRepo=$(echo $repo | sed 's/SPACE/ /g')
    if [ -d "$unescapedRepo/.git/" ]; then
        git_repos+="${repo}\n"
    fi
done
selected_repo_path=$(printf $git_repos | sed 's/SPACE/ /g' | fzf-tmux)


# Find out whether a session already exists for this repos
folder_name=$(basename $selected_repo_path)
existing_session=$(tmux list-sessions |  cut -d ':' -f 1 | grep $folder_name )

# If no session exists, create one
if [ -z $existing_session ]; then
    # If we're not in tmux, create a new session and attach to it
    if [ -z $TMUX ]; then
        tmux new-session -s $folder_name -c $selected_repo_path
        # If we're in tmux, create a new detached session and switch to it
    else
        tmux new-session -d -s $folder_name -c $selected_repo_path
        tmux switch-client -t $folder_name
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
