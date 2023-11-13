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

# If no session exists, create one. Otherwise, attach to the existing session
if [ -z $existing_session ]; then
    tmux new-session -s $folder_name -c $selected_repo_path
else
    tmux attach-session -t $existing_session
fi
