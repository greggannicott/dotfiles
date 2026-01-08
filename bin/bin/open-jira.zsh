#!/bin/zsh

usage="Usage: open-jira <ticket_id|c>

cp = open ticket for current project
cb = use contents of clipboard"

open_jira () {
    local id=$1

    # If no value is provided, use the contents of the clipboard
    if [[ -z "$id" ]]; then
        echo $usage 
        return 1
    fi

    if [[ $id = "cp" ]]; then
        id=$(get_current_project_jira_id)
        if [[ -z "$id" ]]; then
            echo "Unable to open ticket. No Jira ID found for current project."
            return 1
        fi
    fi

    if [[ $id = "cb" ]]; then
        id=$(pbpaste)
    fi

    open "https://jira.syncsort.com/browse/${id}"
}

get_current_project_jira_id () {
    echo $(curl --silent http://localhost:3123/projects/current | jq -r '.jiraId')
}

open_jira $1

