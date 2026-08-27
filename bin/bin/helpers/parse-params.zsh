#!/bin/zsh

# parse-params.zsh
# Generic command-line parameter parser for shell scripts.
#
# Scripts source this helper and register the parameters they accept.
# The helper then parses "$@" into the corresponding shell variables and
# provides a --help / -h flag with generated usage for the calling script.
#
# Usage:
#   source path/to/helpers/parse-params.zsh
#
#   1. Register each parameter before calling parse_params:
#        declare_param <cli-name> <variable> <description> [type]
#          cli-name      Flag as passed on the command line (--<cli-name>)
#          variable      Shell variable to set
#          description   One-line help shown in --help output
#          type          "string" (default) or "flag"
#
#      Examples:
#        declare_param "name" "name" "Project name"
#        declare_param "branch" "branch_name" "Branch name"
#        declare_param "create-worktree" "backend" "Create backend worktree" flag
#
#   2. Parse command-line arguments (after setting default values):
#        parse_params "$@"
#
#   String params are passed as --name=value or --name value; flags as
#   --create-worktree. --help / -h prints generated usage for the calling
#   script and exits 0. Unknown parameters cause an error.

PARAM_CLI_NAMES=()
PARAM_VAR_NAMES=()
PARAM_DESCRIPTIONS=()
PARAM_TYPES=()

declare_param() {
    PARAM_CLI_NAMES+=("$1")
    PARAM_VAR_NAMES+=("$2")
    PARAM_DESCRIPTIONS+=("$3")
    PARAM_TYPES+=("${4:-string}")
}

print_usage() {
    local script_name
    script_name="$(basename "${funcfiletrace[-1]%%:*}")"

    local -a specs=()
    local -a helps=()
    local i spec
    for ((i=1; i<=${#PARAM_CLI_NAMES}; i++)); do
        if [[ "${PARAM_TYPES[$i]}" == "flag" ]]; then
            spec="--${PARAM_CLI_NAMES[$i]}"
        else
            spec="--${PARAM_CLI_NAMES[$i]} <value>"
        fi
        specs+=("$spec")
        helps+=("${PARAM_DESCRIPTIONS[$i]}")
    done
    specs+=("--help, -h")
    helps+=("Show this help message")

    local max_len=0
    for spec in "${specs[@]}"; do
        if (( ${#spec} > max_len )); then
            max_len=${#spec}
        fi
    done

    echo "Usage: $script_name [options]"
    echo
    echo "Options:"
    for ((i=1; i<=${#specs}; i++)); do
        printf "  %-*s  %s\n" "$max_len" "${specs[$i]}" "${helps[$i]}"
    done
}

set_param() {
    local cli="$1"
    local value="$2"
    local given_type="$3"
    local i
    for ((i=1; i<=${#PARAM_CLI_NAMES}; i++)); do
        if [[ "${PARAM_CLI_NAMES[$i]}" == "$cli" ]]; then
            if [[ "${PARAM_TYPES[$i]}" != "$given_type" ]]; then
                if [[ "${PARAM_TYPES[$i]}" == "flag" ]]; then
                    echo "Parameter --$cli does not take a value." >&2
                else
                    echo "Parameter --$cli requires a value (--$cli=<value>)." >&2
                fi
                exit 1
            fi
            typeset -g "${PARAM_VAR_NAMES[$i]}=$value"
            return 0
        fi
    done
    echo "Unknown parameter: --$cli" >&2
    exit 1
}

param_type() {
    local cli="$1"
    local i
    for ((i=1; i<=${#PARAM_CLI_NAMES}; i++)); do
        if [[ "${PARAM_CLI_NAMES[$i]}" == "$cli" ]]; then
            echo "${PARAM_TYPES[$i]}"
            return 0
        fi
    done
    echo ""
    return 1
}

parse_params() {
    local arg key value
    while [[ $# -gt 0 ]]; do
        arg="$1"
        case "$arg" in
            --help|-h)
                print_usage
                exit 0
                ;;
            --*=*)
                key="${arg%%=*}"
                key="${key#--}"
                value="${arg#*=}"
                set_param "$key" "$value" string
                ;;
            --*)
                key="${arg#--}"
                if [[ "$(param_type "$key")" == "string" ]]; then
                    shift
                    if [[ $# -lt 1 ]]; then
                        echo "Parameter --$key requires a value." >&2
                        exit 1
                    fi
                    set_param "$key" "$1" string
                else
                    set_param "$key" true flag
                fi
                ;;
            *)
                echo "Unknown parameter: $arg" >&2
                exit 1
                ;;
        esac
        shift
    done
}