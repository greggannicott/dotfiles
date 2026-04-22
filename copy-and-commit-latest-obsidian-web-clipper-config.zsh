#!/bin/zsh

# Copy latest file in
echo "Copying latest obsidian-web-clipper-settings.json file from ~/Downloads..."
echo
ls "$(ls -l -1 ~/Downloads/obsidian-web-clipper-settings*.json(om[1]))"
echo
cp "$(ls -l -1 ~/Downloads/obsidian-web-clipper-settings*.json(om[1]))" obsidian/web-clipper/obsidian-web-clipper-settings.json
echo "Done"
echo
ls -l obsidian/web-clipper/obsidian-web-clipper-settings.json
echo

# Stage file
echo "Staging file in git"
git add obsidian/web-clipper/obsidian-web-clipper-settings.json
echo 
git status -s
echo

# Offer to commit
read "response?Commit changes to git? (y/n): "

if [[ "$response" =~ ^[Yy]$ ]]; then
	git commit -m "obsidian: Update web clipper config"
	echo "Changes committed."
else
	echo "Changes NOT committed."
fi
