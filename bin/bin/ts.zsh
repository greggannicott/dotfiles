# #!/bin/zsh

entries=()

# Find all git repos in ~/code
potential_repo_directories=$(find ~/code -d 1 -type d -prune -print | sed 's/ /SPACE/g')
for repo in $potential_repo_directories
do
    unescapedRepo=$(echo $repo | sed 's/SPACE/ /g')
    if [ -d "$unescapedRepo/.git/" ] || [ -e "$unescapedRepo/.git" ]; then
        for worktree in $(git -C "$unescapedRepo" worktree list --porcelain | grep branch | cut -d' ' -f2 | cut -d '/' -f3); do
            # git_repos+="${repo} -> ${worktree}\n"
            entry['path']="$unescapedRepo"
            entry['escaped_repo']="${repo}"
            entry['display_value']=$(printf "%s\t" "${unescapedRepo}->${worktree}")
            entries+=($entry)
        done
    fi
done
# selected_repo_and_branch=$(echo $git_repos | sed 's/SPACE/ /g' | fzf)
selected_repo_and_branch=$(printf "%s" "${entries[@]['display_value']}" | fzf --delimiter='\t' --with-nth=1)

# If user escapes at this point (ie. without selecting a repo) exit.
if [ -z "$selected_repo_and_branch" ]; then
    exit 0
fi

# Find out whether a session already exists for this repos
# path_name=$(echo $selected_repo_and_branch | awk -F " -> " '{ print $1 }')
# branch_name=$(echo $selected_repo_and_branch | awk -F " -> " '{ print $2 }')
# folder_name=$(basename $path_name)
# existing_session=$(tmux list-sessions |  cut -d ':' -f 1 | grep $folder_name )

# If no session exists, create one
# if [ -z $existing_session ]; then
#     # If we're not in tmux, create a new session and attach to it
#     if [ -z $TMUX ]; then
#         tmux new-session -s $folder_name -c $path_name
#         # If we're in tmux, create a new detached session and switch to it
#     else
#         tmux new-session -d -s $folder_name -c $path_name
#         tmux switch-client -t $folder_name
#     fi
#     # If a session exists, attach to it
# else
#     # If we're not in tmux, attach to the session
#     if [ -z $TMUX ]; then
#         tmux attach-session -t $existing_session
#         # If we're in tmux, switch to the session
#     else
#         tmux switch-client -t $existing_session
#     fi
# fi
