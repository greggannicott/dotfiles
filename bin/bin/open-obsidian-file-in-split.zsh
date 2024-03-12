#!/bin/zsh

# Displays a list of all markdown files in the Obsidian vault and opens the selected file in a new tmux pane using glow.
cd "/Users/greggannicott/Library/Mobile Documents/iCloud~md~obsidian/Documents/general/Knowledge Base/Knowledge Base/Knowledge Base/"
find . -name "*.md" | fzf-tmux -p --border --cycle --reverse --header="Select Obsidian File" --info="inline-right" | xargs -I {} tmux split-window -h -f glow -p "{}"
