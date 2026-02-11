# GNU utilities without 'g' prefix
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="/usr/local/sessionmanagerplugin/bin:$PATH"
export PATH="~/bin:$PATH"

export LC_COLLATE="en_US.UTF-8"

# Use newer bash
export PATH="/opt/homebrew/bin:$PATH"

set -o vi
bind -m vi-insert "\C-l":clear-screen

function title()
{
    export PROMPT_COMMAND="echo -ne '\033]0;$1\a'"
}

export PROMPT_DIRTRIM=2
# Host-colored prompt: pink on gali10, blue on gali11 (default blue)
host_color="\[\e[34m\]"
case "$(hostname -s)" in
  gali10) host_color="\[\e[95m\]" ;;
  gali11) host_color="\[\e[34m\]" ;;
esac
export PS1="[\w]${host_color}\$\[\e[0m\] "

export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

export EDITOR="nvim"

alias bbic="brew update &&\
    brew bundle install --cleanup --file=~/.config/Brewfile &&\
    brew upgrade"
alias docker="podman"
alias obs="$HOME/Workspace/Galiglobal/nvim-playground/obsidian/obs.sh --vault $HOME/Workspace/Galiglobal/obsidian"


alias vi=nvim
alias vim=nvim
alias more="less -R"
alias ls='eza'
alias ll='eza -l'
alias la='eza -la'
alias lt='eza --tree'
alias cat='bat'
alias rg='rg --smart-case'
alias preview="fzf --preview 'bat --color=always {}'"
alias gdiff="git diff --staged > /tmp/review.diff && nvim /tmp/review.diff"
alias hack="zellij action new-tab -l ~/.config/zellij/layouts/hacking.kdl"

# Host-specific GNU coreutils aliases
case "$(hostname -s)" in
  gali11)
    alias sed='gsed'
    alias tar='gtar'
    alias grep='ggrep --color=auto'
    alias find='gfind'
    ;;
  gali10)
    alias vi=~/bin/nvim-linux-x86_64/bin/nvim
    alias nvim=~/bin/nvim-linux-x86_64/bin/nvim
    export EDITOR="$HOME/bin/nvim-linux-x86_64/bin/nvim"
    ;;
esac

lima-start() { limactl start "${1:-default}" --mount "$PWD:rw"; }

clip() {
    "$@" 2>&1 | tee >(pbcopy)
}

# Bash completion setup (supports both macOS with brew and Linux)
if [[ "$OSTYPE" == darwin* ]] && command -v brew &>/dev/null; then
    BREW_PREFIX="$(brew --prefix)"
    # Bash completion
    if [ -f "$BREW_PREFIX/etc/bash_completion" ]; then
        . "$BREW_PREFIX/etc/bash_completion"
    elif [ -f "$BREW_PREFIX/etc/bash_completion.d/git-completion.bash" ]; then
        . "$BREW_PREFIX/etc/bash_completion.d/git-completion.bash"
    fi
    # fzf
    [ -f "$BREW_PREFIX/opt/fzf/shell/key-bindings.bash" ] && source "$BREW_PREFIX/opt/fzf/shell/key-bindings.bash"
    [ -f "$BREW_PREFIX/opt/fzf/shell/completion.bash" ] && source "$BREW_PREFIX/opt/fzf/shell/completion.bash"
else
    # Linux
    [ -f /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion
    # fzf key-bindings (completion is loaded via bash_completion.d)
    [ -f /usr/share/fzf/shell/key-bindings.bash ] && source /usr/share/fzf/shell/key-bindings.bash
    # Load git completion explicitly (fzf's default handler intercepts lazy loading)
    [ -f /usr/share/bash-completion/completions/git ] && source /usr/share/bash-completion/completions/git
fi
eval "$(zoxide init bash)"
. "$HOME/.cargo/env"
