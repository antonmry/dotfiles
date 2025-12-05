# GNU utilities without 'g' prefix
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="~/bin:$PATH"

# Use newer bash
export PATH="/opt/homebrew/bin:$PATH"

set -o vi
bind -m vi-insert "\C-l":clear-screen

function title()
{
    export PROMPT_COMMAND="echo -ne '\033]0;$1\a'"
}

export PROMPT_DIRTRIM=2
export PS1="[\w]\[\e[34m\]\$\[\e[0m\] "

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
alias sed='gsed'
alias tar='gtar'
alias grep='ggrep --color=auto'
alias find='gfind'
alias cat='bat'
alias find='fd'
alias rg='rg --smart-case'
alias preview="fzf --preview 'bat --color=always {}'"
alias gdiff="git diff --staged > .agents/review.diff && nvim .agents/review.diff"
alias hack="zellij action new-tab -l ~/.config/zellij/layouts/hacking.kdl"

clip() {
    "$@" 2>&1 | tee >(pbcopy)
}

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion || {
    # if not found in /usr/local/etc, try the brew --prefix location
    [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ] && \
        . $(brew --prefix)/etc/bash_completion.d/git-completion.bash
}

source /opt/homebrew/opt/fzf/shell/key-bindings.bash
source /opt/homebrew/opt/fzf/shell/completion.bash
eval "$(zoxide init bash)"
. "$HOME/.cargo/env"

# Review a GitHub PR: view summary, inspect diff in nvim, then submit review
pr_review() {
    local pr_number="$1"
    if [[ -z "$pr_number" ]]; then
        echo "Usage: pr_review <pr-number>"
        return 1
    fi

    gh pr view "$pr_number" || return $?
    read -n 1 -s -r -p "Press any key to open diff in nvim..." && echo

    local tmpfile
    tmpfile=$(mktemp "/tmp/gh-pr-diff-${pr_number}-XXXX.patch") || {
        echo "Unable to create temp file"
        return 1
    }

    gh pr diff "$pr_number" > "$tmpfile" || {
        echo "gh pr diff failed"
        rm -f "$tmpfile"
        return 1
    }

    nvim "$tmpfile"
    rm -f "$tmpfile"

    gh pr review "$pr_number"
}
