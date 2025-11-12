# Include the following line to make profiling of your rc file possible.
# In order to perform the profiling, run `time ZSH_DEBUGRC=1 zsh -i -c exit`.
if [[ -n "$ZSH_DEBUGRC" ]]; then
  zmodload zsh/zprof
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Lazy load nvm
zstyle ':omz:plugins:nvm' lazy yes

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    vi-mode
    aliases
    golang
    ng
    z
    nvm
    brew
    fzf-tab 
    web-search
)

source $ZSH/oh-my-zsh.sh

# User configuration

# zsh-autosuggestions configuration
bindkey '^y' autosuggest-accept

# fzf-tab configuration - see https://github.com/Aloxaf/fzf-tab/wiki/Configuration

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# Enable group mode (so certain results are grouped) and set keys to move between groups
# zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' switch-group '<' '>'
# Customize how certain commands are handled by fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -a --color $realpath'
zstyle ':fzf-tab:complete:tree:*' fzf-preview 'tree -ld --noreport $realpath'

# Use colours when displaying files/directories
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Custom Functions

function copyCurrentBranchToClipboard()
{
    local currentBranchName=`git branch --show-current`
    echo $currentBranchName | pbcopy
    echo "✅ Current branch ($currentBranchName) copied to clipboard!"
}

tmux-too-young-search() {
    if [ $# -eq 0 ]; then
        tmux-too-young open
    else
        tmux-too-young open --search "$@"
    fi
}

# Add fzf completion for `add-worktree`
# Usage: `add-worktree **<TAB>`
_fzf_complete_add-worktree() {
    _fzf_complete "--multi --reverse" "$@" < <(
        cd `git rev-parse --git-common-dir` && cd ..
        remote_branches=`git branch --remote | sed 's/origin\///' | sed 's/[ ][ ]//'`
        local_directories=`ls --dirs -l | awk '{print $13}' | sed 's/\/$//'`
        difference=`comm -23 <(echo "$remote_branches" | sort) <(echo "$local_directories" | sort)`
        echo "$difference"
    )
}

# Interactive RipGreg (uses fzf).
# See https://junegunn.github.io/fzf/tips/ripgrep-integration/
interactive_rip_grep() (
  RELOAD='reload:rg --column --color=always --hidden --smart-case {q} || :'
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            nvim {1} +{2}     # No selection. Open the current line in Vim.
          else
            nvim +cw -q {+f}  # Build quickfix list for the selected items.
          fi'
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --query "$*"
)

# Aliases
alias gs="git status -s"
alias gss="git status"
alias gp="git push"
alias gpnv="git push --no-verify"
alias gmom="git fetch && git merge origin/main --no-edit"
functions[cbranch]=copyCurrentBranchToClipboard
functions[copybranch]=copyCurrentBranchToClipboard
alias kill-ng-serve='ps -eaf | grep "ng serve" | grep -v "grep" | awk "{ print $2 }" | xargs kill'
alias add-worktree="add-worktree-for-remote-branch.zsh"
alias irg="interactive_rip_grep"
alias remove-worktrees="delete-worktrees.zsh"
alias rsd="npm run start-dev"
alias nrsd="npm run start-dev"
alias ty="tmux-too-young-search"
alias gt="go test"
alias jira="open-jira.zsh" # First arg should be the Jira ID

alias run-hub-api="go run ."
alias rha="run-hub-api"
alias run-hub-service="go run . foreground"
alias rhs="run-hub-service"
alias run-hub-ui="npm run start"
alias rhu="run-hub-ui"

alias cdpr="cd $project_root"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Shell Integrations
eval "$(fzf --zsh)"

# Load local zshrc file if it exists
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

# Required to make profiling possible.
if [[ -n "$ZSH_DEBUGRC" ]]; then
  zprof
fi

# Configure globbing (based on the following video: https://youtu.be/g5BoVPhewWM?si=OAnJSGdyKFRjY6sI)
setopt dot_glob # include dotfiles
setopt extended_glob # match ~ # ^

# Required for Ruby to run via a Homebrew install
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"
