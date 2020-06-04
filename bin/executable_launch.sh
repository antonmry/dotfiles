#! /bin/bash

case $HOSTNAME in
  (gali7)
        killall chrome
        killall thunderbird
        killall alacritty
        killall slack
        killall pidgin
        killall minetime
        google-chrome &
        minetime &
        ~/bin/thunderbird.sh &
        i3-msg 'workspace 2:Terminal; exec tmux.sh' &
        idea &
        slack &
        pidgin &
      ;;
  (gali8)
        killall chrome
        killall alacritty
        killall slack
        google-chrome &
        i3-msg 'workspace 2:Terminal; exec tmux.sh' &
        idea &
        slack &
        xinput --set-button-map 13 1 1 3
      ;;
  (*)   echo "How did I get in the middle of nowhere?";;
esac

