#!/bin/zsh

openJira () {
    local id=$1
    open "https://jira.syncsort.com/browse/${id}"
}

openJira $1

