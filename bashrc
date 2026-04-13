# GNU utilities without 'g' prefix
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/usr/local/sessionmanagerplugin/bin:$PATH"
export PATH="~/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

export LC_COLLATE="en_US.UTF-8"

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
export PROMPT_COMMAND="history -a; history -c; history -r"

export EDITOR="nvim"

export SKIM_DEFAULT_OPTIONS="--color=light"

alias bbic="brew update &&\
    brew bundle install --cleanup --file=~/.config/Brewfile &&\
    brew upgrade"
alias docker="podman"

alias vi=nvim
alias vim=nvim
alias more="less -R"
alias ls='eza'
alias ll='eza -l'
alias la='eza -la'
alias lt='eza --tree'
alias cat='bat'
alias rg='rg --smart-case'
alias preview="sk --preview 'bat --color=always {}'"
alias gdiff="git diff --staged > /tmp/review.diff && nvim /tmp/review.diff"
alias hack="zellij action new-tab -l ~/.config/zellij/layouts/hacking.kdl"
alias fzf="sk --color=light"

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
else
    # Linux
    [ -f /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion
    # Load git completion explicitly (fzf's default handler intercepts lazy loading)
    [ -f /usr/share/bash-completion/completions/git ] && source /usr/share/bash-completion/completions/git
fi
eval "$(zoxide init bash)"
source <(sk --shell bash --shell-bindings)

# sk 3.6.x emits history entries with awk "\0", which BSD awk treats as a
# string terminator. That collapses Ctrl+R history into a single long item.
# Override the widget to emit NUL safely via "%c", 0.
if declare -f __skim_history__ >/dev/null 2>&1; then
    __skim_history__() {
        local output
        local c_idx='' c_reset='' ansi_opt=''
        if [[ ! -v NO_COLOR ]]; then
            c_idx="${SKIM_CTRL_R_IDX_COLOR:-\033[2m}"
            c_reset='\033[0m'
            ansi_opt='--ansi'
        fi
        output=$(
            builtin fc -lnr -2147483648 |
                last_hist=$(HISTTIMEFORMAT='' builtin history 1) awk -v last_hist="$last_hist" -v c_idx="$c_idx" -v c_reset="$c_reset" '
                BEGIN { HISTCMD = last_hist + 1; cmd = ""; idx = 0 }
                /^\t/ {
                  if (cmd != "" && !seen[cmd]++) printf "%s%d%s\t%s%c", c_idx, HISTCMD - idx, c_reset, cmd, 0
                  idx++; cmd = substr($0, 2); sub(/^[ *]/, "", cmd); next
                }
                { cmd = cmd "\n" $0 }
                END { if (cmd != "" && !seen[cmd]++) printf "%s%d%s\t%s%c", c_idx, HISTCMD - idx, c_reset, cmd, 0 }
            ' |
                SKIM_DEFAULT_OPTIONS="$SKIM_DEFAULT_OPTIONS -n2..,.. --bind=ctrl-r:toggle-sort $SKIM_CTRL_R_OPTS --no-multi --read0 $ansi_opt" "$(__skimcmd)" --query "$READLINE_LINE"
        ) || return
        echo -e "\033[0m"
        READLINE_LINE=${output#*$'\t'}
        if [ "$READLINE_POINT" = "" ]; then
            echo "$READLINE_LINE"
        else
            READLINE_POINT=0x7fffffff
        fi
    }
fi

. "$HOME/.cargo/env"
eval "$(breo setup bash)"

# if command -v coral &>/dev/null; then
#   source <(coral completion bash)
# fi
