#!/bin/sh
#exec alacritty -e tmux 
#exec gnome-terminal -e tmux

exec alacritty -e tmux new-session \
"gcalcli --calendar 'Anton Rodríguez Yuste' agenda 00:00 23:59; read" \;  \
split-window "curl wttr.in/ponteceso; read" \; \
resize-pane -y 40 \; \
select-pane -t:.2 -P 'fg=white,bg=black' \; \
select-pane -t:.1 \; \
split-window -h "todo.sh ls | tac; read" \; \
select-pane -t:.1 \; \
split-window "cowsay 'Bos días!!'; read" \; \
new-window \; next-window \; \
# split-window "rsstail -r https://www.upwork.com/ab/feed/topics/rss?securityToken=`gopass websites/upwork/rss-token`&userUid=424214442304323584&orgUid=424214442308517889 | tac; read" \; \
