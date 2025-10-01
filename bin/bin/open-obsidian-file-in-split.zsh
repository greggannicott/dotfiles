#!/bin/zsh

# Displays a list of all markdown files in the Obsidian vault and opens the selected file in a new tmux pane using glow.
cd "`yq \".obsidian-directory\" ~/.workflow-config.yaml`"
find ./notes/ -name "*.md" | fzf-tmux -p --border --cycle --reverse --header="Select Obsidian File" --info="inline-right" | xargs -I {} tmux split-window -h -f glow -p "{}"
