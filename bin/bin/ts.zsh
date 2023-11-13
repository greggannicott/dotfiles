repos=$(find ~/code -d 1 -type d -prune -print | sed 's/ /SPACE/g')

for repo in $repos
do
    unescapedRepo=$(echo $repo | sed 's/SPACE/ /g')
    if [ -d "$unescapedRepo/.git/" ]; then
        git_repos+="${repo}\n"
    fi
done
selected_repo=$(printf $git_repos | sed 's/SPACE/ /g' | fzf-tmux)
echo $selected_repo
