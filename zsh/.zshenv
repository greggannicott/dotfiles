# Commented out the following.
# I don't know how it got there but it was resulting in the .zshrc file being called twice when
# a new iTerm2 tab was opened, and thrice when a new tmux window was opened.
# You feel like it was added for a reason but can't remember why.
#source ~/.zshrc

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Add your custom scripts to the path.
export PATH="$HOME/bin:$PATH"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Add homebrew's ruby to the path. Required for `colorls`.
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
PATH=$PATH:$(ruby -e 'puts Gem.bindir')

# Use `neovim` to display man pages
export MANPAGER='nvim +Man!'
export MANWIDTH=999

# Configure vi-mode (handled by the `vi-mode` plugin)
export VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
export VI_MODE_SET_CURSOR=true

# Required for tmuxp
export DISABLE_AUTO_TITLE='true'

# Add Go
export PATH=$PATH:$GOPATH/bin

