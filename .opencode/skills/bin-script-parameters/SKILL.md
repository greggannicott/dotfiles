---
name: bin-script-parameters
description: Standard for command-line parameter handling in bin/bin scripts. Use when adding, editing, or reviewing parameters in a script under bin/bin/, or when working on the shared helpers/parse-params.zsh parser.
---

## The standard

Every script under `bin/bin/` that accepts command-line parameters MUST get them through the shared helper:

- **Source path:** `bin/bin/helpers/parse-params.zsh`, sourced via `$script_directory` alongside `helper-functions.zsh`
- Hand-rolled parsing, direct `$1`/`$2` handling, or per-script flag loops are NOT allowed. Other apps depend on a consistent interface.

## How it works

```zsh
source "$script_directory/helper-functions.zsh"
source "$script_directory/helpers/parse-params.zsh"

# 1. Register every parameter
declare_param "name" "name" "Project name"
declare_param "create-worktree" "backend" "Create backend worktree" flag
#              cli-name       var-name     description                type

# 2. Set defaults BEFORE parsing
name=""
backend=false

# 3. Parse command-line arguments
parse_params "$@"
```

### declare_param

`declare_param <cli-name> <variable> <description> [type]`

- `cli-name` — the flag as passed on the command line (without `--`)
- `variable` — the shell variable to set
- `description` — one-line text shown in `--help`
- `type` — `string` (default) or `flag`

Hyphenated CLI names can map to a differently-named variable (e.g. `--create-worktree` sets `$backend`).

### Accepted syntax

- String: `--name=value` or `--name value`
- Flag: `--create-worktree` (presence = true)
- `--help` / `-h`: generated usage for the calling script, exits 0
- Unknown params: error + exit 1
- Passing a value to a flag, or omitting a string's value: error + exit 1

## Rules

- CLI values PREFILL interactive prompts (`--value="$name"`); the user can still change them. Never skip a prompt just because a flag was passed — an external trigger may set values the user still needs to see and confirm.
- Register every accepted parameter; never accept unregistered flags.
- `--help` is free once a script registers its params — do not hand-write usage text.

## Reference

`bin/bin/create-story-or-bug.zsh` is the reference implementation.