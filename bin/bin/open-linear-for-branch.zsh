#!/bin/zsh

script_directory="$(cd "$(dirname "$0")" && pwd)"

cd "${LAUNCH_DIR:-$PWD}"

id=$(git branch --show-current | grep -oEi '[a-z0-9]+-[0-9]+')

if [[ -z "$id" ]]; then
    echo "Unable to open Linear ticket. No ID found in current branch name."
    exit 1
fi

"$script_directory/open-linear-id.zsh" "$id"