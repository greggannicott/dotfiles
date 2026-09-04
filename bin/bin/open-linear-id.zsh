#!/bin/zsh

script_directory="$(cd "$(dirname "$0")" && pwd)"
source "$script_directory/helper-functions.zsh"

usage="Usage: open-linear-id [linear_id|cb]

cb = use contents of clipboard"

open_linear () {
    local id=$1

    if [[ -z "$id" ]]; then
        id=$(gum input --header="Linear ID:")
        check_exit_code $?
    fi

    if [[ $id = "cb" ]]; then
        id=$(pbpaste)
    fi

    if [[ -z "$id" ]]; then
        id=$(gum input --header="Linear ID:")
        check_exit_code $?
    fi

    open "https://linear.app/precisely/issue/${id}"
}

open_linear $1