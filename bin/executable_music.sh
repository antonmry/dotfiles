#!/bin/sh

exec alacritty -e tmux new-session "mopidy" \;  \
select-pane -t:.1 -P 'fg=white,bg=black' \; \
split-window -b "ncmpcpp" \; \
select-pane -t:.1 \; \
resize-pane -D 20 \; \
select-pane -t:.1 \; \
split-window "cava" \; \
select-pane -t:.1 \; \
resize-pane -D 10 \; 
# split-window "rsstail -r https://www.upwork.com/ab/feed/topics/rss?securityToken=`gopass websites/upwork/rss-token`&userUid=424214442304323584&orgUid=424214442308517889 | tac; read" \; \
