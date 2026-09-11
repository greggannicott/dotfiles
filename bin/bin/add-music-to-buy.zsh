#!/bin/zsh

# Get the directory of the current script
script_directory="$(cd "$(dirname "$0")" && pwd)"

# Source helper functions
source "$script_directory/helper-functions.zsh"

# Check BFF connectivity
if ! curl -s -o /dev/null --max-time 5 "http://localhost:8082/status"; then
    echo "$(tput setaf 1)Warning: Unable to connect to $(tput sgr0)$(tput bold)BFF$(tput sgr0)$(tput setaf 1). Check it is running.$(tput sgr0)"
	echo
fi

output_heading "Add Music To Buy"

discogs_url=$(gum input --header="Discogs URL:" --placeholder="https://www.discogs.com/...")
check_exit_code $?

if [ -z "$discogs_url" ]; then
    output_error_message "Discogs URL is required."
    output_general_message "Press any key to exit..."
    read
    exit 1
fi

payload=$(jq -n \
    --arg discogsUrl "$discogs_url" \
    '{discogsUrl: $discogsUrl}')

output_heading "BFF Request Details"
echo "URL: http://localhost:8082/pkm/music-to-buy/"
echo "Method: POST"
echo "Payload:"
echo "$payload" | jq .

response=$(curl -s "http://localhost:8082/pkm/music-to-buy/" \
    -H "Content-Type: application/json" \
    --data "$payload")
echo
echo "Response:"
echo "$response" | jq .

output_heading "Finished!"
output_general_message "Press any key to exit..."
read