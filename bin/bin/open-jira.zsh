#!/bin/zsh

usage="Usage: open-jira <ticket_id|c>

c = open ticket for current project"

open_jira () {
    local id=$1

    if [[ -z "$id" ]]; then
        echo $usage 
        return 1
    fi

    if [[ $id = "c" ]]; then
        id=$(get_current_project_jira_id)
        if [[ -z "$id" ]]; then
            echo "Unable to open ticket. No Jira ID found for current project."
            return 1
        fi
    fi
    open "https://jira.syncsort.com/browse/${id}"
}

get_current_project_jira_id () {
    echo $(curl --silent http://localhost:3123/projects/current | jq -r '.jiraId')
}

open_jira $1

