# About

This repo contains my configuration files for various applications.

# Requirements

## GNU Stow

Before using this, you must first install GNU Stow. This is used to handle the symbolic links.

On MacOS this can be performed using `brew`:

```zsh
brew install stow
```

## Oh My Zsh!

Required for the `.zshrc` file.

## fzf-tab

Running the following is required to use (https://github.com/Aloxaf/fzf-tab)[fzf-tab], which makes it possible to use `fzf` when completing cd commands, entering flags etc.

```bash
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
```

## TPM - Tmux Plugin Manager

Instructions:

```zsh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## Bat

In order to use the "Catppuccin Mocha" on a fresh install, you need to run:

```zsh
bat cache --build
```

# Maintaining

Each folder in this repo represents an application configuration.

The contents of each directory should represent the files you wish to include if that particular directory symbolic links added into your home (ie. `~/`) directory.

For example, `/nvim/.config/nvim/init.lua` will have a symbolic link created in `~/.config/nvim/init.lua`.

# Usage

- Clone the repo into your home directory.

```zsh
cd ~/
git clone https://github.com/greggannicott/dotfiles.git
```

- Change directories into the repo

```zsh
cd dotfiles
```

- Execute `stow <directory name>` for every directory you wish to create a symbolic link for. eg.

```zsh
stow nvim
```

- Note wildcards can be used. eg. the following will handle all the directories:

```zsh
stow /*
```

# Local .zshrc.local file

The `.zshrc` file includes a line to source a `.zshrc.local` file if it exists.

Use this if you wish to run commands that are specific to your local machine.

# Config file

Some of the scripts included in this repo depend on the `~/.workflow-config.yaml` config file.

This file isn't included in the repo as it is specific to each machine, and so needs to be manually created.

It resembles the following:

```yaml
init-scripts:
  - path: "path to a repo that uses worktrees"
    init: "command used to initiate repo, eg npm install"
obsidian-directory: "path to obsidian directory containing your knowledge base"
```
